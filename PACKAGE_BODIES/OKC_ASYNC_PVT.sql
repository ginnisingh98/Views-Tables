--------------------------------------------------------
--  DDL for Package Body OKC_ASYNC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ASYNC_PVT" as
/* $Header: OKCRASNB.pls 120.3 2005/12/14 22:11:36 npalepu noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_MUTE_PROFILE	CONSTANT VARCHAR2(30)   :=  'OKC_SUPPRESS_EMAILS';
  G_APP_NAME	        CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME	        CONSTANT VARCHAR2(200) := 'OKC_ASYNC_PVT';
  G_LEVEL	        CONSTANT VARCHAR2(4)   := '_PVT';
  l_api_version         CONSTANT NUMBER := 1;


--
-- private procedure to be called by wf start api
-- to save session context in wf attributes
--
procedure save_env(p_wf_name varchar2, p_key varchar2) is
  p_recipient varchar2(100);
  l_nls_language varchar2(100);
  l_nls_territory varchar2(100);
  l_ntf_pref varchar2(30);

--
-- changed to go of users directly JEG 11/30/2000
--
  cursor nls_csr is
select
NVL(wf_pref.get_pref(USR.USER_NAME, 'LANGUAGE'), FNDL.NLS_LANGUAGE) language,
NVL(wf_pref.get_pref(USR.USER_NAME, 'TERRITORY'), FNDL.NLS_TERRITORY) territory,
NVL(wf_pref.get_pref(USR.USER_NAME,'MAILTYPE'),'MAILHTML')
notification_preference
from fnd_languages fndl,
fnd_user usr
where usr.user_name = p_recipient
and fndl.installed_flag = 'B';

   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'save_env';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
     okc_debug.Log('10: p_wf_name : '||p_wf_name,2);
     okc_debug.Log('10: p_key : '||p_key,2);
  END IF;
  --
  -- save apps context
  --
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'USER_ID',
						avalue	=> fnd_global.user_id);
          IF (l_debug = 'Y') THEN
             okc_debug.Log('001 in set_env user_id:'||fnd_global.user_id,2);
          END IF;
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'USER_ID');
	    wf_engine.SetItemAttrNumber(itemtype	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'USER_ID',
						avalue	=> fnd_global.user_id);
          IF (l_debug = 'Y') THEN
             okc_debug.Log('002 in set_env user_id:'||fnd_global.user_id,2);
          END IF;
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'RESP_ID',
						avalue	=> fnd_global.resp_id);
          IF (l_debug = 'Y') THEN
             okc_debug.Log('003 in set_env resp_id:'||fnd_global.resp_id,2);
          END IF;
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'RESP_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'RESP_ID',
						avalue	=> fnd_global.resp_id);
          IF (l_debug = 'Y') THEN
             okc_debug.Log('004 in set_env resp_id:'||fnd_global.resp_id,2);
          END IF;
    end;
    begin
      wf_engine.SetItemAttrNumber (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'RESP_APPL_ID',
						avalue	=> fnd_global.RESP_APPL_id);
          IF (l_debug = 'Y') THEN
             okc_debug.Log('005 in set_env resp_id:'||fnd_global.resp_appl_id,2);
          END IF;
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'RESP_APPL_ID');
	    wf_engine.SetItemAttrNumber(itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'RESP_APPL_ID',
						avalue	=> fnd_global.RESP_APPL_id);
          IF (l_debug = 'Y') THEN
             okc_debug.Log('006 in set_env resp_id:'||fnd_global.resp_appl_id,2);
          END IF;
    end;
  --
  -- save NLS/NTF preferences from P_RESOLVER/P_S_RECIPIENT/P_E_RECIPIENT/apps
  --
    p_recipient := NVL( wf_engine.GetItemAttrText(p_wf_name,p_key,'P_RESOLVER'),
			   NVL(wf_engine.GetItemAttrText(p_wf_name,p_key,'P_S_RECIPIENT'),
				wf_engine.GetItemAttrText(p_wf_name,p_key,'P_E_RECIPIENT')));
    select value into L_NLS_LANGUAGE
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_LANGUAGE';
    select value into L_NLS_TERRITORY
    from NLS_SESSION_PARAMETERS
    where PARAMETER='NLS_TERRITORY';
    open nls_csr;
    fetch nls_csr into l_nls_language, l_nls_territory, l_ntf_pref;
    close nls_csr;
--
           if ( l_ntf_pref='MAILTEXT' ) then
             wf_engine.SetItemAttrText (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'PREFORMAT',
						avalue	=> '');
             wf_engine.SetItemAttrText (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'PREFORMAT_',
						avalue	=> '');
          IF (l_debug = 'Y') THEN
             okc_debug.Log('007 in set_env l_ntf_pref:'||l_ntf_pref,2);
          END IF;
	     end if;
--
    begin
      wf_engine.SetItemAttrText (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'NLS_LANGUAGE',
						avalue	=> ''''||l_nls_language||'''');
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'NLS_LANGUAGE');
	    wf_engine.SetItemAttrText(itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'NLS_LANGUAGE',
						avalue	=> ''''||l_nls_language||'''');
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'NLS_TERRITORY',
						avalue	=> ''''||l_nls_territory||'''');
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'NLS_TERRITORY');
	    wf_engine.SetItemAttrText(itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'NLS_TERRITORY',
						avalue	=> ''''||l_nls_territory||'''');
    end;
    begin
      wf_engine.SetItemAttrText (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'NTF_PREF',
						avalue	=> l_ntf_pref);
    exception
      when others then
	    wf_engine.AddItemAttr (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'NTF_PREF');
      wf_engine.SetItemAttrText (itemtype 	=> p_wf_name,
	      				itemkey  	=> p_key,
  	      				aname 	=> 'NTF_PREF',
						avalue	=> l_ntf_pref);
          IF (l_debug = 'Y') THEN
             okc_debug.Log('008 in set_env l_ntf_pref:'||l_ntf_pref,2);
          END IF;
    end;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
             okc_debug.Log('008 leaving set_env',2);
     okc_debug.Reset_Indentation;
  END IF;

end save_env;

--
-- wf start API (Branch 2)
--
procedure wf_call(
			--
			-- common API parameters
			--
				p_api_version	IN	NUMBER,
                     	p_init_msg_list	IN	VARCHAR2 ,
                     	x_return_status	OUT 	NOCOPY	VARCHAR2,
                     	x_msg_count		OUT 	NOCOPY	NUMBER,
                     	x_msg_data		OUT 	NOCOPY	VARCHAR2,
			--
			-- params for dynamic proc call
			--
			   	p_proc		IN	VARCHAR2 ,
                     	p_subj_first_msg	IN	VARCHAR2 ,
			--
			-- notification params
			--
			   	p_ntf_type		IN	VARCHAR2 ,
			   	p_e_recipient	IN	VARCHAR2  ,
			   	p_s_recipient	IN	VARCHAR2 ,
			--
			-- extra wf params (wf attr. / other than 3 previous - i.e. CONTRACT_ID)
			--
				p_wf_par_tbl 	IN 	par_tbl_typ
			) is

  l_api_name                     CONSTANT VARCHAR2(30) := 'WF_CALL';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_key varchar2(100);
  c 	NUMBER;
  i 	NUMBER;
  j 	NUMBER;
  P_VERSION NUMBER := 2;
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'wf_call';
   --

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
     okc_debug.Log('20: G_WF_NAME : '||G_WF_NAME,2);
     okc_debug.Log('20: G_PROCESS_NAME : '||G_PROCESS_NAME,2);
     okc_debug.Log('20: p_api_version : '||p_api_version,2);
     okc_debug.Log('20: p_init_msg_list : '||p_init_msg_list,2);
     okc_debug.Log('20: p_proc : '||p_proc,2);
     okc_debug.Log('20: p_subj_first_msg : '||p_subj_first_msg,2);
     okc_debug.Log('20: p_ntf_type : '||p_ntf_type,2);
     okc_debug.Log('20: p_e_recipient : '||p_e_recipient,2);
     okc_debug.Log('20: p_s_recipient : '||p_s_recipient,2);
  END IF;

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
-- create process
--
  select to_char(okc_wf_notify_s1.nextval) into l_key from dual;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('30: l_key : '||l_key,2);
  END IF;

  wf_engine.CreateProcess( 	ItemType 	=> G_WF_NAME,
				 	ItemKey 	=> L_KEY,
				 	process 	=> G_PROCESS_NAME);
  wf_engine.SetItemUserKey (	ItemType	=> G_WF_NAME,
					ItemKey	=> L_KEY,
					UserKey	=> L_KEY);
--
-- design time attr !
--
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_PROC',
						avalue	=> P_PROC);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_SUBJ_FIRST_MSG',
						avalue	=> P_SUBJ_FIRST_MSG);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_NTF_TYPE',
						avalue	=> P_NTF_TYPE);
--
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_E_RECIPIENT',
						avalue	=> P_E_RECIPIENT);
--
          if (p_proc is NULL and p_s_recipient is NULL) then
	      wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_S_RECIPIENT',
						avalue	=> fnd_global.user_name);
          IF (l_debug = 'Y') THEN
             okc_debug.Log('009 in wf_call p_s_recipient :'||fnd_global.user_name,2);
          END IF;
	    else
	      wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_S_RECIPIENT',
						avalue	=> P_S_RECIPIENT);
          IF (l_debug = 'Y') THEN
             okc_debug.Log('010 in wf_call p_s_recipient :'||P_S_RECIPIENT,2);
          END IF;
	    end if;
--
--  design time attr ! other wf parameters
--
    c := p_wf_par_tbl.COUNT;

    IF (l_debug = 'Y') THEN
       okc_debug.Log('40: p_wf_par_tbl.COUNT : '||c,2);
    END IF;

    if (c>0) then
      i := p_wf_par_tbl.FIRST;
      LOOP
              IF (l_debug = 'Y') THEN
                 okc_debug.Log('50: Inside Loop ',2);
              END IF;
	  if ( (p_wf_par_tbl(i).par_type is NULL) or (p_wf_par_tbl(i).par_type = 'C') ) then
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> p_wf_par_tbl(i).par_name,
				        avalue	=> p_wf_par_tbl(i).par_value);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('60: p_wf_par_tbl(i).par_name : '||p_wf_par_tbl(i).par_name,2);
                   okc_debug.Log('60: p_wf_par_tbl(i).par_value : '||p_wf_par_tbl(i).par_value,2);
                END IF;
 	    if (p_wf_par_tbl(i).par_name = 'P_DOC_PROC') then
	      P_VERSION := 4;
               IF (l_debug = 'Y') THEN
                  okc_debug.Log('60: P_VERSION := 4 ',2);
               END IF;
	    end if;
	  elsif (p_wf_par_tbl(i).par_type = 'N') then
	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> p_wf_par_tbl(i).par_name,
						avalue	=> to_number(p_wf_par_tbl(i).par_value));
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('70: p_wf_par_tbl(i).par_name : '||p_wf_par_tbl(i).par_name,2);
                   okc_debug.Log('70: p_wf_par_tbl(i).par_value : '||p_wf_par_tbl(i).par_value,2);
                END IF;
	  elsif (p_wf_par_tbl(i).par_type = 'D') then
	    wf_engine.SetItemAttrDate (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> p_wf_par_tbl(i).par_name,
						avalue	=> to_date(p_wf_par_tbl(i).par_value,'YYYY/MM/DD'));
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('80: p_wf_par_tbl(i).par_name : '||p_wf_par_tbl(i).par_name,2);
                   okc_debug.Log('80: p_wf_par_tbl(i).par_value : '||p_wf_par_tbl(i).par_value,2);
                END IF;
	  end if;
        c := c-1;
        EXIT WHEN (c=0);
        i := p_wf_par_tbl.NEXT(i);
      END LOOP;
      IF (l_debug = 'Y') THEN
         okc_debug.Log('90: out nocopy of Loop ',2);
      END IF;
    end if;
--
    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_KEY',
						avalue	=> L_KEY);
    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_VERSION',
						avalue	=> P_VERSION);

--
-- end wf parameters
--

--
-- save env / start
--
    save_env(G_WF_NAME, l_key);
    wf_engine.SetItemOwner (	itemtype => G_WF_NAME,
					itemkey  => L_KEY,
					owner	   => fnd_global.user_name);

      IF (l_debug = 'Y') THEN
         okc_debug.Log('100: WF Owner : '||fnd_global.user_name,2);
      END IF;

    wf_engine.StartProcess( 	itemtype => G_WF_NAME,
	      			itemkey  => L_KEY);

    IF (l_debug = 'Y') THEN
       okc_debug.Log('110: Started WF ',2);
    END IF;

--    commit;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.Log('120: x_msg_count : '||x_msg_count,2);
     okc_debug.Log('130: x_msg_data : '||x_msg_data,2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
    IF (l_debug = 'Y') THEN
       okc_debug.Log('4000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
    IF (l_debug = 'Y') THEN
       okc_debug.Log('5000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
end wf_call;

--
-- set_env - private procedure to be called by Selector
--
procedure set_env(	p_wf_name varchar2,
				p_key varchar2) is
l_nls_language varchar2(100);
l_nls_territory varchar2(100);
l1 varchar2(100);
cursor c1(p varchar2) is
  select ''''||value||''''
  from NLS_SESSION_PARAMETERS
  where PARAMETER=p;
  l_version number;
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'set_env';
   --
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('20: p_wf_name : '||p_wf_name,2);
     okc_debug.Log('20: p_key : '||p_key,2);
  END IF;
  --
  -- do nothing for previous version
  --
    begin
      l_version := wf_engine.GetItemAttrNumber(p_wf_name,p_key,'P_VERSION');
    exception
      when others then
        l_version := 1;
    end;
    if (l_version < 2) then

       IF (l_debug = 'Y') THEN
          okc_debug.Log('100: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;

     return;
    end if;
  --
  -- set apps context
  --
  fnd_global.apps_initialize
    (
	user_id =>
     		wf_engine.GetItemAttrNumber(p_wf_name,p_key,'USER_ID'),
	resp_id =>
     		wf_engine.GetItemAttrNumber(p_wf_name,p_key,'RESP_ID'),
	resp_appl_id =>
     		wf_engine.GetItemAttrNumber(p_wf_name,p_key,'RESP_APPL_ID')
  );
            IF (l_debug = 'Y') THEN
                  okc_debug.Log('100-11: Printing Apps Context in okc_asynch_pvt.set_env after call to fnd_global.apps_initialize...',2);
                  okc_debug.Log('100-12: USER_ID = '|| to_char(fnd_global.user_id),2);
                  okc_debug.Log('100-13: RESP_ID = '|| to_char(fnd_global.resp_id),2);
                  okc_debug.Log('100-14: RESP_APPL_ID = '|| to_char(fnd_global.resp_appl_id),2);
            END IF;


--
  -- set nls context if different
  --
    l_nls_language  := wf_engine.GetItemAttrText(p_wf_name,p_key,'NLS_LANGUAGE');
    l_nls_territory := wf_engine.GetItemAttrText(p_wf_name,p_key,'NLS_TERRITORY');
    open c1('NLS_LANGUAGE');
    fetch c1 into L1;
    close c1;
   if (L1<>l_nls_language) then
	sys.dbms_session.set_nls('NLS_LANGUAGE',l_nls_language);
    end if;
    open c1('NLS_TERRITORY');
    fetch c1 into L1;
    close c1;
   if (L1<>l_nls_territory) then
	sys.dbms_session.set_nls('NLS_TERRITORY',l_nls_territory);
    end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

end set_env;

--
-- Selector sets environment for version > 1
--
procedure Selector  ( 	item_type	in varchar2,
				item_key  	in varchar2,
				activity_id	in number,
				command	in varchar2,
				resultout out nocopy varchar2	) is
-- local declarations
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'Selector';
   --
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('20: item_type : '||item_type,2);
     okc_debug.Log('20: item_key : '||item_key,2);
     okc_debug.Log('20: activity_id : '||activity_id,2);
     okc_debug.Log('20: command : '||command,2);
  END IF;

	resultout := ''; -- return value for other possible modes
	--
	-- RUN mode - normal process execution
	--
	if (command = 'RUN') then
		--
		-- Return process to run
		--
		resultout := G_PROCESS_NAME;

               IF (l_debug = 'Y') THEN
                  okc_debug.Log('30: resultout : '||resultout,2);
                  okc_debug.Log('100: Leaving ',2);
                  okc_debug.Reset_Indentation;
               END IF;

		return;
	end if;
       IF (l_debug = 'Y') THEN
          okc_debug.Log('100-15: Inside Selector selector/callback mode : '||command,2);
          okc_debug.Log('100-16: Inside Selector resultout is : '||resultout,2);
       END IF;

	--
	-- SET_CTX mode - set context for new DB session
	--
	if (command = 'SET_CTX') then
	set_env(p_wf_name => item_type,p_key  => item_key);

         IF (l_debug = 'Y') THEN
           okc_debug.Log('100-17: Inside Selector if mode is SET_CTX resultout is : '||resultout,2);
           okc_debug.Log('200: Leaving ',2);
           okc_debug.Reset_Indentation;
         END IF;


		return;
	end if;

	--
	-- TEST_CTX mode - test context
	--
	if (command = 'TEST_CTX') then
		-- test code
        -- Bug#2909586 Changed resultout to FALSE so that wworkflow will always set the context
		resultout := 'FALSE';

       IF (l_debug = 'Y') THEN
          okc_debug.Log('100-18: Inside Selector if mode is TEST_CTX resultout is : '||resultout,2);
          okc_debug.Log('40: resultout : '||resultout,2);
          okc_debug.Log('300: Leaving ',2);
          okc_debug.Reset_Indentation;
       END IF;


		return;
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'SELECTOR',
		item_type,
		item_key,
		to_char(activity_id),
		command);
         IF (l_debug = 'Y') THEN
          okc_debug.Log('100-19: Inside Selector exception resultout is : '||resultout,2);
          okc_debug.Log('2000: Leaving ',2);
          okc_debug.Reset_Indentation;
         END IF;
	  raise;
end Selector;

--
-- get_version returns '1' for previous wf branch, '2' for new
--
procedure get_version(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
P_VERSION varchar2(6) := '1';
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'get_version';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('20: itemtype : '||itemtype,2);
     okc_debug.Log('20: itemkey : '||itemkey,2);
     okc_debug.Log('20: actid : '||actid,2);
     okc_debug.Log('20: funcmode : '||funcmode,2);
  END IF;
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
        begin
          P_VERSION := to_char(wf_engine.GetItemAttrNumber(itemtype,itemkey,'P_VERSION'));
          IF (l_debug = 'Y') THEN
             okc_debug.Log('30: P_VERSION : '||P_VERSION,2);
          END IF;
	  exception
	    when others then
	      P_VERSION := '1';
	  end;
  	  resultout := 'COMPLETE:'||P_VERSION;
          IF (l_debug = 'Y') THEN
             okc_debug.Log('40: resultout : '||resultout,2);
          END IF;
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('50: resultout : '||resultout,2);
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('60: resultout : '||resultout,2);
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'GET_VERSION',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end get_version;

--
-- proc_call private procedure that
-- executes dynamic sql comming from attribute p_proc/p_accept_proc/...
--
procedure proc_call(
				p_key 		varchar2,
				p_attr_name		varchar2,
                     	x_return_status	IN OUT NOCOPY VARCHAR2
			) is
  j 			number;
  P_PROC 		varchar2(8000);
  P_SUBJ_FIRST_MSG varchar2(1);
  P_VERSION number;
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'proc_call';
   --
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('20: p_key : '||p_key,2);
     okc_debug.Log('20: p_attr_name : '||p_attr_name,2);
  END IF;

        x_return_status := 'S';
        P_PROC := wf_engine.GetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> P_KEY,
  	      				aname 	=> p_attr_name);
-- marat start (bug#2477385)
        okc_wf.init_wf_string(   wf_engine.GetItemAttrText (   itemtype => G_WF_NAME,
	      				                                          itemkey 	=> P_KEY,
  	      				                                          aname 	=> 'EXTRA_ATTR_TEXT'));
-- marat end
	  P_VERSION := wf_engine.GetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> P_KEY,
  	      				aname 	=> 'P_VERSION');
        savepoint exec_call_sp;
        if (P_VERSION in (2,5)) then
          begin
            EXECUTE IMMEDIATE P_PROC USING IN OUT x_return_status;
	    exception
              when others then
          IF (l_debug = 'Y') THEN
             okc_debug.Log('011 in proc_call exception block:'||substr(sqlerrm,1,200),2);
          END IF;
		begin
              rollback to exec_call_sp;
              EXECUTE IMMEDIATE P_PROC;
	      exception when others then
		  x_return_status := 'U';
		end;
	    end;
	    IF (x_return_status in ('E','U')) then
            rollback to exec_call_sp;
 	    end if;
        elsif (P_VERSION = 3) then
	    begin
            EXECUTE IMMEDIATE P_PROC USING
		                wf_engine.GetItemAttrText (
					itemtype 	=> G_WF_NAME,
	      			itemkey  	=> P_KEY,
  	      			aname 	=> 'NOTE');
          EXCEPTION WHEN OTHERS THEN
		begin
              rollback to exec_call_sp;
              EXECUTE IMMEDIATE P_PROC;
	      exception when others then
              rollback to exec_call_sp;
	      end;
          end;
	  end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

end proc_call;

-- Procedure Name  : load_mess
-- Description     : Private procedure to load messages into attributes
--				to be called by nun_generic

procedure load_mess(itemtype    in varchar2,
                    itemkey     in varchar2,
                    --NPALEPU
                    --14-DEC-2005
                    --Bug # 4699009
                    p_proc_success_flag IN VARCHAR2
                    --END NPALEPU
			) is
  i integer; -- fnd_message counter
  j integer; -- fnd_message number
  k integer; -- MESSAGE counter
  P_SUBJ_FIRST_MSG varchar2(1);
  msg_buf varchar2(4000);
  fnd_buf varchar2(2000);
  nl varchar2(4);
  text_limit number := 32000;
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'load_mess';
   --
   --NPALEPU
   --14-DEC-2005
   --for bug # 4699009
   l_contract_id        NUMBER;
   l_contract_number    OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
   l_proc_name          VARCHAR2(4000);

   CURSOR l_contract_number_csr(contract_id NUMBER) IS
   SELECT CONTRACT_NUMBER
   FROM   OKC_K_HEADERS_ALL_B
   WHERE  ID = contract_id;

   --END NPALEPU
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  nl:=fnd_global.NewLine;
  P_SUBJ_FIRST_MSG := wf_engine.GetItemAttrText(itemtype,itemkey,'P_SUBJ_FIRST_MSG');
  j := NVL(FND_MSG_PUB.Count_Msg,0);

  if (j=0) then

    --NPALEPU
    --14-DEC-2005
    --bug # 4699009

    IF (l_debug = 'Y') THEN
       okc_debug.Log('50: Message Count is Zero ',2);
       okc_debug.Reset_Indentation;
    END IF;

    l_contract_id  := (wf_engine.GetItemAttrText (itemtype      => itemtype,
                                                  itemkey       => itemkey,
                                                  aname         => 'CONTRACT_ID'));
    l_proc_name    := (wf_engine.GetItemAttrText (itemtype      => itemtype,
                                                  itemkey       => itemkey,
                                                  aname         => 'P_PROC_NAME'));
    IF l_contract_id IS NOT NULL THEN
        BEGIN
           OPEN l_contract_number_csr(l_contract_id);
           FETCH l_contract_number_csr INTO l_contract_number;
           CLOSE l_contract_number_csr;
        EXCEPTION
           WHEN OTHERS THEN
              l_contract_number := NULL;
        END;
    END IF;

    IF p_proc_success_flag = 'S' THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKC_OUTCOME_SUCCESS',
                            p_token1       => 'CONTRACT_NUMBER',
                            p_token1_value => l_contract_number,
                            p_token2       => 'PROCESS_NAME',
                            p_token2_value => l_proc_name);

        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKC_OUTCOME_SUCCESS',
                            p_token1       => 'CONTRACT_NUMBER',
                            p_token1_value => l_contract_number,
                            p_token2       => 'PROCESS_NAME',
                            p_token2_value => l_proc_name);
    ELSE
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKC_OUTCOME_FAILURE',
                            p_token1       => 'CONTRACT_NUMBER',
                            p_token1_value => l_contract_number,
                            p_token2       => 'PROCESS_NAME',
                            p_token2_value => l_proc_name);

        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKC_OUTCOME_FAILURE',
                            p_token1       => 'CONTRACT_NUMBER',
                            p_token1_value => l_contract_number,
                            p_token2       => 'PROCESS_NAME',
                            p_token2_value => l_proc_name);
    END IF;

    wf_engine.SetItemAttrText (itemtype         => itemtype,
                               itemkey          => itemkey,
                               aname            => 'MESSAGE0',
                               avalue           => FND_MSG_PUB.Get(2,p_encoded =>FND_API.G_FALSE ));

    wf_engine.SetItemAttrText (itemtype         => itemtype,
                               itemkey          => itemkey,
                               aname            => 'MESSAGE1',
                               avalue           => FND_MSG_PUB.Get(1,p_encoded =>FND_API.G_FALSE ));
    --END NPALEPU

    IF (l_debug = 'Y') THEN
       okc_debug.Log('100: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    return;

  end if;

  if (P_SUBJ_FIRST_MSG = 'T') then
    wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      			itemkey  	=> itemkey,
  	      			aname 	=> 'MESSAGE0',
					avalue	=> FND_MSG_PUB.Get(1,p_encoded =>FND_API.G_FALSE ));
    i:=2;
  else
    wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      			itemkey  	=> itemkey,
  	      			aname 	=> 'MESSAGE0',
					avalue	=> FND_MSG_PUB.Get(j,p_encoded =>FND_API.G_FALSE ));
    j:=j-1;
    i:=1;
  end if;
  text_limit:=text_limit-length(wf_engine.GetItemAttrText (itemtype 	=> itemtype,
	      			itemkey  	=> itemkey,
  	      			aname 	=> 'MESSAGE0'));
  k:=1; -- msg index
  LOOP
     if (i>j) then exit; end if;
     msg_buf:='';
     LOOP
	 fnd_buf := FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE );
	 if (length(msg_buf)+4+length(fnd_buf))>4000 then
         exit;
       end if;
       if msg_buf is NULL then
  	   msg_buf := fnd_buf;
       else
	   msg_buf := msg_buf||nl||fnd_buf;
	 end if;
	 i:=i+1;
	 if (i>j) then exit; end if;
     END LOOP;
      wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      			itemkey  	=> itemkey,
  	      			aname 	=> 'MESSAGE'||to_char(k),
					avalue	=> msg_buf);
      text_limit:=text_limit-length(msg_buf);
      if (text_limit<0) then
        wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      			itemkey  	=> itemkey,
  	      			aname 	=> 'MESSAGE'||to_char(k),
					avalue	=> '');
        exit;
      end if;
      k := k+1;
      if (k>9) then exit; end if;
    END LOOP;
end;


--
-- procedure fun_generic
-- returns 'S' if notify about success
-- returns 'E' if notify about error
-- returns 'X' if noone to notify
--
--
procedure fun_generic(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
x_return_status varchar2(1);
l_subj_first varchar2(1);
--
p_recipient varchar2(100);
l_pref varchar2(100);
l_timeout_minutes NUMBER := 0;

--
-- changed to go of users directly JEG 11/30/2000
--
cursor pref_csr is
select
NVL(wf_pref.get_pref(USR.USER_NAME,'MAILTYPE'),'MAILHTML')
notification_preference
from fnd_user usr
where usr.user_name = p_recipient;

--
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'fun_generic';
   --
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;
	--
	-- RUN mode - normal process execution
	--
/* MSENGUPT: Introduced the following code to re-read and reset the profile option  in case of timeouts due to errors */
	if (funcmode <> 'RUN') then
            l_timeout_minutes := fnd_profile.value('OKC_ALERT_TIMEOUT');
            if l_timeout_minutes IS NOT NULL then
	        wf_engine.SetItemAttrNumber (itemtype, itemkey, 'P_TIMEOUT_MINUTES', L_TIMEOUT_MINUTES);
            end if;
        end if;
/* End of code insert */

	if (funcmode = 'RUN') then
          IF (l_debug = 'Y') THEN
             okc_debug.Log('20: funcmode = RUN ',2);
          END IF;
	  FND_MSG_PUB.initialize;
          IF (l_debug = 'Y') THEN
             okc_debug.Log('30: ',2);
          END IF;
	  if (wf_engine.GetItemAttrText(itemtype,itemkey,'P_PROC') is NULL) then
          IF (l_debug = 'Y') THEN
             okc_debug.Log('40 ',2);
          END IF;
  	    resultout := 'COMPLETE:S';
          else
        if (wf_engine.GetItemAttrNumber(itemtype,itemkey,'P_VERSION') = 5) then
	  wf_engine.SetItemAttrText (
	  	itemtype 	=> itemtype,
	      	itemkey  	=> itemkey,
  	      	aname 	=> 'MESSAGE0',
		avalue	=> '');
	  wf_engine.SetItemAttrText (
	  	itemtype 	=> itemtype,
	      	itemkey  	=> itemkey,
  	      	aname 	=> 'MESSAGE1',
		avalue	=> '');
	  wf_engine.SetItemAttrText (
	  	itemtype 	=> itemtype,
	      	itemkey  	=> itemkey,
  	      	aname 	=> 'MESSAGE2',
		avalue	=> '');
	  wf_engine.SetItemAttrText (
	  	itemtype 	=> itemtype,
	      	itemkey  	=> itemkey,
  	      	aname 	=> 'MESSAGE3',
		avalue	=> '');
	  wf_engine.SetItemAttrText (
	  	itemtype 	=> itemtype,
	      	itemkey  	=> itemkey,
  	      	aname 	=> 'MESSAGE4',
		avalue	=> '');
	  wf_engine.SetItemAttrText (
	  	itemtype 	=> itemtype,
	      	itemkey  	=> itemkey,
  	      	aname 	=> 'MESSAGE5',
		avalue	=> '');
	  wf_engine.SetItemAttrText (
	  	itemtype 	=> itemtype,
	      	itemkey  	=> itemkey,
  	      	aname 	=> 'MESSAGE6',
		avalue	=> '');
	  wf_engine.SetItemAttrText (
	  	itemtype 	=> itemtype,
	      	itemkey  	=> itemkey,
  	      	aname 	=> 'MESSAGE7',
		avalue	=> '');
	  wf_engine.SetItemAttrText (
	  	itemtype 	=> itemtype,
	      	itemkey  	=> itemkey,
  	      	aname 	=> 'MESSAGE8',
		avalue	=> '');
	  wf_engine.SetItemAttrText (
	  	itemtype 	=> itemtype,
	      	itemkey  	=> itemkey,
  	      	aname 	=> 'MESSAGE9',
		avalue	=> '');
	end if;
 	    proc_call(p_key => itemkey,p_attr_name => 'P_PROC',
                  x_return_status => x_return_status);
            IF (l_debug = 'Y') THEN
               okc_debug.Log('50 ',2);
            END IF;
	    if ((x_return_status = 'S') and
		   (wf_engine.GetItemAttrText(itemtype,itemkey,'P_S_RECIPIENT') is not NULL)) then
                   --NPALEPU
                   --14-DEC-2005
                   --For bug # 4699009
              /* load_mess(itemtype,itemkey); */
              load_mess(itemtype,itemkey,x_return_status);
                  --END NPALEPU
--
           p_recipient := wf_engine.GetItemAttrText(itemtype,itemkey,'P_S_RECIPIENT');
           IF (l_debug = 'Y') THEN
              okc_debug.Log('60 ',2);
           END IF;
           open pref_csr;
           fetch pref_csr into l_pref;
           close pref_csr;

           IF (l_debug = 'Y') THEN
              okc_debug.Log('70 l_pref : '||l_pref);
           END IF;

           if (l_pref='MAILTEXT') then
             wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 	=> 'PREFORMAT',
						avalue	=> '');
             wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 	=> 'PREFORMAT_',
						avalue	=> '');
	     end if;
--
  	      resultout := 'COMPLETE:S';
          elsif ((x_return_status in ('E','U')) and
		   (wf_engine.GetItemAttrText(itemtype,itemkey,'P_E_RECIPIENT') is not NULL)) then
               --NPALEPU
               --14-DEC-2005
               --For bug # 4699009
              /* load_mess(itemtype,itemkey); */
              load_mess(itemtype,itemkey,x_return_status);
               --END NPALEPU
--
           p_recipient := wf_engine.GetItemAttrText(itemtype,itemkey,'P_E_RECIPIENT');
           open pref_csr;
           fetch pref_csr into l_pref;
           close pref_csr;

           IF (l_debug = 'Y') THEN
              okc_debug.Log('80 l_pref : '||l_pref);
           END IF;

           if (l_pref='MAILTEXT') then
             wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 	=> 'PREFORMAT',
						avalue	=> '');
             wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      				itemkey  	=> itemkey,
  	      				aname 	=> 'PREFORMAT_',
						avalue	=> '');
	     end if;
--
  	      resultout := 'COMPLETE:E';
	    else
  	      resultout := 'COMPLETE:X';
	    end if;
            IF (l_debug = 'Y') THEN
               okc_debug.Log('81: ',2);
            END IF;

	  end if;
          IF (l_debug = 'Y') THEN
             okc_debug.Log('82: ',2);
          END IF;

	end if;
        IF (l_debug = 'Y') THEN
           okc_debug.Log('83: ',2);
        END IF;
	--
  	-- CANCEL mode
	--

  	if (funcmode = 'CANCEL') then
		--
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('90 funcmode = CANCEL',2);
                END IF;

    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('110 funcmode = TIMEOUT',2);
                END IF;

    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'FUN_GENERIC',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end fun_generic;

--
-- accept
--
procedure accept(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2) is
x_return_status varchar2(1);
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'accept';
   --
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
		--
 	      proc_call(p_key => itemkey,p_attr_name => 'P_ACCEPT_PROC',
                  x_return_status => x_return_status);
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('300: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'ACCEPT',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end accept;


--
-- reject
--
procedure reject(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2) is
x_return_status varchar2(1);
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'reject';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
		--
 	      proc_call(p_key => itemkey,p_attr_name => 'P_REJECT_PROC',
                  x_return_status => x_return_status);
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('300: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'REJECT',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end reject;

--
-- timeout
--
procedure timeout(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2) is
x_return_status varchar2(1);
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'timeout';
   --
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
		--
 	      proc_call(p_key => itemkey,p_attr_name => 'P_TIMEOUT_PROC',
                  x_return_status => x_return_status);
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('300: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'TIMEOUT',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end timeout;

--
-- wf start API (Branch 3)
--
procedure resolver_call(
			--
			-- common API parameters
			--
				p_api_version	IN	NUMBER,
                     	p_init_msg_list	IN	VARCHAR2 ,
                     	x_return_status	OUT 	NOCOPY	VARCHAR2,
                     	x_msg_count		OUT 	NOCOPY	NUMBER,
                     	x_msg_data		OUT 	NOCOPY	VARCHAR2,
			--
			-- wf attributes
			--
			   	p_resolver		IN	VARCHAR2,
			   	p_msg_subj_resolver IN	VARCHAR2,
			   	p_msg_body_resolver IN	VARCHAR2,
				p_note		IN VARCHAR2 ,
				p_accept_proc	IN VARCHAR2,
				p_reject_proc	IN VARCHAR2,
				p_timeout_proc	IN VARCHAR2 ,
				p_timeout_minutes IN NUMBER ,
			--
			-- hidden notification attributes
			--
				p_ntf_type		IN VARCHAR2 ,
				p_contract_id	IN NUMBER ,
				p_task_id		IN NUMBER ,
				p_extra_attr_num	IN NUMBER ,
				p_extra_attr_text	IN VARCHAR2 ,
				p_extra_attr_date	IN DATE
			) is

  l_api_name                     CONSTANT VARCHAR2(30) := 'RESOLVER_CALL';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_key varchar2(100);
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'resolver_call';
   --

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

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
-- create process
--
  select to_char(okc_wf_notify_s1.nextval) into l_key from dual;
  wf_engine.CreateProcess( 	ItemType 	=> G_WF_NAME,
				 	ItemKey 	=> L_KEY,
				 	process 	=> G_PROCESS_NAME);
  wf_engine.SetItemUserKey (	ItemType	=> G_WF_NAME,
					ItemKey	=> L_KEY,
					UserKey	=> L_KEY);
--
-- design time attr !
--

	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_RESOLVER',
						avalue	=> P_RESOLVER);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'MSG_SUBJ_RESOLVER',
						avalue	=> P_MSG_SUBJ_RESOLVER);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'MSG_BODY_RESOLVER',
						avalue	=> P_MSG_BODY_RESOLVER);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'NOTE',
						avalue	=> P_NOTE);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_ACCEPT_PROC',
						avalue	=> P_ACCEPT_PROC);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_REJECT_PROC',
						avalue	=> P_REJECT_PROC);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_TIMEOUT_PROC',
						avalue	=> NVL(P_TIMEOUT_PROC,P_REJECT_PROC));
	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_TIMEOUT_MINUTES',
						avalue	=> P_TIMEOUT_MINUTES);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_NTF_TYPE',
						avalue	=> P_NTF_TYPE);
	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> P_CONTRACT_ID);
	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'TASK_ID',
						avalue	=> P_TASK_ID);
	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'EXTRA_ATTR_NUM',
						avalue	=> P_EXTRA_ATTR_NUM);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'EXTRA_ATTR_TEXT',
						avalue	=> P_EXTRA_ATTR_TEXT);
	    wf_engine.SetItemAttrDate (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'EXTRA_ATTR_DATE',
						avalue	=> P_EXTRA_ATTR_DATE);
	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_VERSION',
						avalue	=> 3);
--
-- save env / start
--
    save_env(G_WF_NAME, l_key);
    wf_engine.SetItemOwner (	itemtype => G_WF_NAME,
					itemkey  => L_KEY,
					owner	   => fnd_global.user_name);
    wf_engine.StartProcess( 	itemtype => G_WF_NAME,
	      			itemkey  => L_KEY);
--    commit;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('3000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('4000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('5000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
end resolver_call;

--
-- periodic returns 'T'/'F'
--
procedure periodic(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
P_PERIOD_DAYS number;
P_STOP_DATE date;
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'periodic';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
        begin
          P_PERIOD_DAYS := wf_engine.GetItemAttrNumber(itemtype,itemkey,'P_PERIOD_DAYS');
          P_STOP_DATE := wf_engine.GetItemAttrDate(itemtype,itemkey,'P_STOP_DATE');
	  exception
	    when others then
	      NULL;
	  end;
        if ((P_PERIOD_DAYS is NULL) or (P_PERIOD_DAYS = 0) or
		(P_STOP_DATE is NULL) or (sysdate+P_PERIOD_DAYS >= P_STOP_DATE))
        then
  	    resultout := 'COMPLETE:F';
	  else
  	    resultout := 'COMPLETE:T';
  	  end if;
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;

    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'PERIODIC',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end periodic;

--
-- periodic returns 'T'/'F'
--
procedure time_over(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'time_over';
   --
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
        if (sysdate >= wf_engine.GetItemAttrDate(itemtype,itemkey,'P_STOP_DATE')) then
  	    resultout := 'COMPLETE:T';
	  else
  	    resultout := 'COMPLETE:F';
  	  end if;
	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'TIME_OVER',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end time_over;

--
-- calls p_doc_proc
--
procedure get_doc(document_id in varchar2,
		display_type in varchar2,
		document in out nocopy CLOB,
		document_type in out nocopy varchar2) is
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'get_doc';
   --
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('20: document_id : '||document_id,2);
     okc_debug.Log('20: display_type : '||display_type,2);
     okc_debug.Log('20: document_type : '||document_type,2);
  END IF;

  savepoint get_doc;
  begin
    EXECUTE IMMEDIATE wf_engine.GetItemAttrText(G_WF_NAME,document_id,'P_DOC_PROC') USING IN OUT document;
  exception
    when others then
    rollback to get_doc;
  end;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('100: document_type out nocopy : '||document_type,2);
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


end;

--
-- wf start API (Branch 5)
--
procedure loop_call(
		--
		-- common API parameters
		--
			p_api_version	IN	NUMBER,
                 	p_init_msg_list	IN	VARCHAR2 ,
                 	x_return_status	OUT 	NOCOPY	VARCHAR2,
                 	x_msg_count		OUT 	NOCOPY	NUMBER,
                 	x_msg_data		OUT 	NOCOPY	VARCHAR2,
		--
		-- specific parameters
		--
		   	p_proc			IN	VARCHAR2,
                        --NPALEPU
                        --14-DEC-2005
                        --Added new parameter P_PROC_NAME for bug # 4699009.
                        p_proc_name             IN      VARCHAR2 DEFAULT NULL,
                        --END NPALEPU
			p_s_recipient		IN	VARCHAR2 ,
			p_e_recipient		IN	VARCHAR2 ,
			p_timeout_minutes IN NUMBER ,
			p_loops 			IN 	NUMBER ,
	            p_subj_first_msg		IN	VARCHAR2 ,
		--
		-- hidden notification attributes
		--
			p_ntf_type		IN	VARCHAR2 ,
			p_contract_id	IN	NUMBER ,
			p_task_id		IN	NUMBER ,
			p_extra_attr_num	IN	NUMBER ,
			p_extra_attr_text	IN	VARCHAR2 ,
			p_extra_attr_date	IN	DATE
) is
  l_api_name                     CONSTANT VARCHAR2(30) := 'LOOP_CALL';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_key varchar2(100);

   --
   CURSOR c_wf_timeout IS
   SELECT NUMBER_DEFAULT
   from   WF_ITEM_ATTRIBUTES
   where  ITEM_TYPE = G_WF_NAME
   and    NAME      = 'P_TIMEOUT_MINUTES';
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'loop_call';
   --
   l_timeout_minutes    NUMBER := p_timeout_minutes;
   l_wf_timeout_minutes NUMBER;
   --
BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('20: p_api_version : '||p_api_version,2);
     okc_debug.Log('20: p_init_msg_list : '||p_init_msg_list,2);
     okc_debug.Log('20: p_proc : '||p_proc,2);
     --NPALEPU
     --14-DEC-2005
     --BUG # 4699009
     okc_debug.Log('20: p_proc_name : '||p_proc_name,2);
     --END NPALEPU
     okc_debug.Log('20: p_s_recipient : '||p_s_recipient,2);
     okc_debug.Log('20: p_e_recipient : '||p_e_recipient,2);
     okc_debug.Log('20: p_timeout_minutes : '||p_timeout_minutes,2);
     okc_debug.Log('20: p_loops : '||p_loops,2);
     okc_debug.Log('20: p_subj_first_msg : '||p_subj_first_msg,2);
     okc_debug.Log('20: p_ntf_type : '||p_ntf_type,2);
     okc_debug.Log('20: p_contract_id : '||p_contract_id,2);
     okc_debug.Log('20: p_task_id : '||p_task_id,2);
     okc_debug.Log('20: p_extra_attr_num : '||p_extra_attr_num,2);
     okc_debug.Log('20: p_extra_attr_text : '||p_extra_attr_text,2);
     okc_debug.Log('20: p_extra_attr_date : '||p_extra_attr_date,2);
  END IF;

  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              G_LEVEL,
                                              x_return_status);

  IF (l_debug = 'Y') THEN
     okc_debug.Log('30: l_return_status : '||l_return_status,2);
  END IF;

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

/* MSENGUPT: The following code is changed from the previous version to make it more effucient. ie. read c_wf_timeout only
   if l_timeout_minutes from profile options is NULL...... very less likely */
  -- determine the value of p_timeout_minutes
  If l_timeout_minutes IS NULL THEN
     l_timeout_minutes := fnd_profile.value('OKC_ALERT_TIMEOUT');
     IF l_timeout_minutes IS NULL THEN
  -- get the defualt value for p_timeout_minutes from the OKCALERT workflow
        OPEN  c_wf_timeout;
        FETCH c_wf_timeout INTO l_wf_timeout_minutes;
        IF    c_wf_timeout%NOTFOUND THEN
              l_wf_timeout_minutes  := 2880;
        END IF;
        CLOSE c_wf_timeout;
        l_timeout_minutes := l_wf_timeout_minutes;
     END IF;
  END IF;
/* End of code change */
--
-- create process
--
  select to_char(okc_wf_notify_s1.nextval) into l_key from dual;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('40: l_key : '||l_key,2);
     okc_debug.Log('40: G_WF_NAME : '||G_WF_NAME,2);
     okc_debug.Log('40: G_PROCESS_NAME : '||G_PROCESS_NAME,2);
  END IF;

  wf_engine.CreateProcess( 	ItemType 	=> G_WF_NAME,
				 	ItemKey 	=> L_KEY,
				 	process 	=> G_PROCESS_NAME);
  wf_engine.SetItemUserKey (	ItemType	=> G_WF_NAME,
					ItemKey	=> L_KEY,
					UserKey	=> L_KEY);
--
-- design time attr !
--

	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_VERSION',
						avalue	=> 5);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_PROC',
						avalue	=> P_PROC);
            --NPALEPU,14-DEC-2005
            --bug # 4699009
            wf_engine.SetItemAttrText (itemtype => G_WF_NAME,
                                       itemkey  => L_KEY,
                                       aname    => 'P_PROC_NAME',
                                       avalue   => P_PROC_NAME);
            --END NPALEPU
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_S_RECIPIENT',
						avalue	=> P_S_RECIPIENT);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_E_RECIPIENT',
						avalue	=> P_E_RECIPIENT);
	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_TIMEOUT_MINUTES',
						avalue	=> L_TIMEOUT_MINUTES);
	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_LOOPS',
						avalue	=> P_LOOPS);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_SUBJ_FIRST_MSG',
						avalue	=> P_SUBJ_FIRST_MSG);
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'P_NTF_TYPE',
						avalue	=> P_NTF_TYPE);
	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'CONTRACT_ID',
						avalue	=> P_CONTRACT_ID);
	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'TASK_ID',
						avalue	=> P_TASK_ID);
	    wf_engine.SetItemAttrNumber (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'EXTRA_ATTR_NUM',
						avalue	=> P_EXTRA_ATTR_NUM);
-- marat start (bug#2477385)
	    wf_engine.SetItemAttrText (  itemtype 	=> G_WF_NAME,
	      				               itemkey  	=> L_KEY,
  	      				               aname 	   => 'EXTRA_ATTR_TEXT',
						                  avalue	   => okc_wf.get_wf_string);
-- marat end
/* - we'll use EXTRA_ATTR_TEXT item attr for sending outcome params to wf process
-- (bug#2477385)
-- below commented out by marat
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'EXTRA_ATTR_TEXT',
						avalue	=> P_EXTRA_ATTR_TEXT);
-- above commented out by marat
*/
	    wf_engine.SetItemAttrDate (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> L_KEY,
  	      				aname 	=> 'EXTRA_ATTR_DATE',
						avalue	=> P_EXTRA_ATTR_DATE);
--
-- save env / start
--
    save_env(G_WF_NAME, l_key);
    wf_engine.SetItemOwner (	itemtype => G_WF_NAME,
					itemkey  => L_KEY,
					owner	   => fnd_global.user_name);

    IF (l_debug = 'Y') THEN
       okc_debug.Log('50: WF Owner : '||fnd_global.user_name,2);
    END IF;

    wf_engine.StartProcess( 	itemtype => G_WF_NAME,
	      			itemkey  => L_KEY);
--    commit;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.Log('60: x_return_status : '||x_return_status,2);
  END IF;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('3000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('4000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('5000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
end loop_call;

-- Start of comments
--
-- Procedure Name  : No_Email
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Post_Approval   : 1.0
-- End of comments

procedure No_Email(		itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'No_Email';
   --
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;
	--
	-- RESPOND mode
	--
	if (funcmode = 'RESPOND') then
	  update wf_notifications
	  set mail_status=NULL
	  where NOTIFICATION_ID=wf_engine.context_nid;

           IF (l_debug = 'Y') THEN
              okc_debug.Log('100: Leaving ',2);
              okc_debug.Reset_Indentation;
           END IF;


    	  return;
	end if;
	--
	-- if other mode mode
	--

               IF (l_debug = 'Y') THEN
                  okc_debug.Log('1000: Leaving ',2);
                  okc_debug.Reset_Indentation;
               END IF;

		--
    		return;
		--

exception
	when others then
	  wf_core.context('OKC_ASYNC_PVT',
		'NO_EMAIL',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end No_Email;

procedure success_mute(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
l_ntf_type varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'P_NTF_TYPE');
l_user_name varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'P_S_RECIPIENT');
cursor c1(p_name varchar2) is
  select user_id from fnd_user
  where user_name=p_name;
l_user_id number;
l_p_value varchar2(3);
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'success_mute';
   --
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	if (funcmode = 'RUN') then
	  open c1(l_user_name);
	  fetch c1 into l_user_id;
	  close c1;
	  l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE||'_'||l_ntf_type,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID => NULL,
				 APPLICATION_ID 	=> NULL);
	  if (l_p_value is NULL) then
	    l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID=> NULL,
				 APPLICATION_ID 	=> NULL);
	  end if;
	  if (l_p_value is NULL or l_p_value='N') then
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> itemkey,
  	      				aname 	=> '.MAIL_QUERY',
 						avalue	=> ' ');
	  else
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> itemkey,
  	      				aname 	=> '.MAIL_QUERY',
						avalue	=> l_user_name);
  	  end if;
	end if;
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'SUCCESS_MUTE',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end success_mute;

procedure error_mute(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	) is
l_ntf_type varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'P_NTF_TYPE');
l_user_name varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'P_E_RECIPIENT');
cursor c1(p_name varchar2) is
  select user_id from fnd_user
  where user_name=p_name;
l_user_id number;
l_p_value varchar2(3);
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'error_mute';
   --
begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	if (funcmode = 'RUN') then
	  open c1(l_user_name);
	  fetch c1 into l_user_id;
	  close c1;
	  l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE||'_'||l_ntf_type,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID=> NULL,
				 APPLICATION_ID 	=> NULL);
	  if (l_p_value is NULL) then
	    l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID=> NULL,
				 APPLICATION_ID 	=> NULL);
	  end if;
	  if (l_p_value is NULL or l_p_value='N') then
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> itemkey,
  	      				aname 	=> '.MAIL_QUERY',
 						avalue	=> ' ');
	  else
	    wf_engine.SetItemAttrText (itemtype 	=> G_WF_NAME,
	      				itemkey  	=> itemkey,
  	      				aname 	=> '.MAIL_QUERY',
						avalue	=> l_user_name);
  	  end if;
	end if;
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'ERROR_MUTE',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end error_mute;

-- Disables sending of email notifications
--
procedure fyi_mute(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		   in number,
				funcmode	   in varchar2,
				resultout out nocopy varchar2	) is

l_ntf_type varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'P_NTF_TYPE');
-- value NEXT_INFORMED_RECIPIENT used in Contract Approval workflow attribute and messages
l_user_name varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'NEXT_INFORMED_USERNAME');

cursor c1(p_name varchar2) is
  select user_id from fnd_user
  where user_name=p_name;

l_user_id number;
l_p_value varchar2(3);
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'fyi_mute';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	if (funcmode = 'RUN') then
	  open c1(l_user_name);
	  fetch c1 into l_user_id;
	  close c1;
	  l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE||'_'||l_ntf_type,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID=> NULL,
				 APPLICATION_ID 	=> NULL);
	  if (l_p_value is NULL) then
	    l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID=> NULL,
				 APPLICATION_ID 	=> NULL);
	  end if;
	  if (l_p_value is NULL or l_p_value='N') then
       -- UnMute Recipient
	    wf_engine.SetItemAttrText (itemtype 	=> itemtype, -- may need to hard code value OKCAUKAP
	      				itemkey  	=> itemkey,
  	      				aname 	   => '.MAIL_QUERY',
 						   avalue	   => ' ');
	  else
       -- Suppress Recipient (Mute)
	    wf_engine.SetItemAttrText (itemtype 	=> itemtype, -- may need to hard code value OKCAUKAP
	      				itemkey  	=> itemkey,
  	      				aname 	   => '.MAIL_QUERY',
						   avalue	   => l_user_name);
  	  end if;
	end if;
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'FYI_MUTE',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end fyi_mute;

-- Disables sending of Next Performer email notifications
--
procedure mute_nxt_pfmr(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		   in number,
				funcmode	   in varchar2,
				resultout out nocopy varchar2	) is

l_ntf_type varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'P_NTF_TYPE');
-- value NEXT_PERFORMER_USERNAME used in Contract Approval workflow attribute and messages
l_user_name varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'NEXT_PERFORMER_USERNAME');

cursor c1(p_name varchar2) is
  select user_id from fnd_user
  where user_name=p_name;

l_user_id number;
l_p_value varchar2(3);
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'mute_nxt_pfmr';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	if (funcmode = 'RUN') then
	  open c1(l_user_name);
	  fetch c1 into l_user_id;
	  close c1;
	  l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE||'_'||l_ntf_type,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID=> NULL,
				 APPLICATION_ID 	=> NULL);
	  if (l_p_value is NULL) then
	    l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID=> NULL,
				 APPLICATION_ID 	=> NULL);
	  end if;
	  if (l_p_value is NULL or l_p_value='N') then
       -- UnMute Recipient
	    wf_engine.SetItemAttrText (itemtype 	=> itemtype, -- may need to hard code value OKCAUKAP
	      				itemkey  	=> itemkey,
  	      				aname 	   => '.MAIL_QUERY',
 						   avalue	   => ' ');
	  else
       -- Suppress Recipient (Mute)
	    wf_engine.SetItemAttrText (itemtype 	=> itemtype, -- may need to hard code value OKCAUKAP
	      				itemkey  	=> itemkey,
  	      				aname 	   => '.MAIL_QUERY',
						   avalue	   => l_user_name);
  	  end if;
	end if;
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'MUTE_NXT_PFMR',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end mute_nxt_pfmr;

-- Disables sending of Contract Admin email notifications
--
procedure mute_k_admin(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		   in number,
				funcmode	   in varchar2,
				resultout out nocopy varchar2	) is

l_ntf_type varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'P_NTF_TYPE');
-- value CONTRACT_ADMIN_USERNAME used in Contract Approval workflow attribute and messages
l_user_name varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'CONTRACT_ADMIN_USERNAME');

cursor c1(p_name varchar2) is
  select user_id from fnd_user
  where user_name=p_name;

l_user_id number;
l_p_value varchar2(3);
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'mute_k_admin';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	if (funcmode = 'RUN') then
	  open c1(l_user_name);
	  fetch c1 into l_user_id;
	  close c1;
	  l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE||'_'||l_ntf_type,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID=> NULL,
				 APPLICATION_ID 	=> NULL);
	  if (l_p_value is NULL) then
	    l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID=> NULL,
				 APPLICATION_ID 	=> NULL);
	  end if;
	  if (l_p_value is NULL or l_p_value='N') then
       -- UnMute Recipient
	    wf_engine.SetItemAttrText (itemtype 	=> itemtype, -- may need to hard code value OKCAUKAP
	      				itemkey  	=> itemkey,
  	      				aname 	   => '.MAIL_QUERY',
 						   avalue	   => ' ');
	  else
       -- Suppress Recipient (Mute)
	    wf_engine.SetItemAttrText (itemtype 	=> itemtype, -- may need to hard code value OKCAUKAP
	      				itemkey  	=> itemkey,
  	      				aname 	   => '.MAIL_QUERY',
						   avalue	   => l_user_name);
  	  end if;
	end if;
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'MUTE_K_ADMIN',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end mute_k_admin;

-- Disables sending of Contract Signatory email notifications
--
procedure mute_signer(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		   in number,
				funcmode	   in varchar2,
				resultout out nocopy varchar2	) is

l_ntf_type varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'P_NTF_TYPE');
-- value SIGNATORY_USERNAME used in Contract Approval workflow attribute and messages
l_user_name varchar2(100) := wf_engine.GetItemAttrText(itemtype,itemkey,'SIGNATORY_USERNAME');

cursor c1(p_name varchar2) is
  select user_id from fnd_user
  where user_name=p_name;

l_user_id number;
l_p_value varchar2(3);
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'mute_signer';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	if (funcmode = 'RUN') then
	  open c1(l_user_name);
	  fetch c1 into l_user_id;
	  close c1;
	  l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE||'_'||l_ntf_type,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID=> NULL,
				 APPLICATION_ID 	=> NULL);
	  if (l_p_value is NULL) then
	    l_p_value := FND_PROFILE.VALUE_SPECIFIC
				(NAME 		=> G_MUTE_PROFILE,
				 USER_ID 		=> l_user_id,
				 RESPONSIBILITY_ID=> NULL,
				 APPLICATION_ID 	=> NULL);
	  end if;
	  if (l_p_value is NULL or l_p_value='N') then
       -- UnMute Recipient
	    wf_engine.SetItemAttrText (itemtype 	=> itemtype, -- may need to hard code value OKCAUKAP
	      				itemkey  	=> itemkey,
  	      				aname 	   => '.MAIL_QUERY',
 						   avalue	   => ' ');
	  else
       -- Suppress Recipient (Mute)
	    wf_engine.SetItemAttrText (itemtype 	=> itemtype, -- may need to hard code value OKCAUKAP
	      				itemkey  	=> itemkey,
  	      				aname 	   => '.MAIL_QUERY',
						   avalue	   => l_user_name);
  	  end if;
	end if;
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'MUTE_SIGNER',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end mute_signer;

-- Enables sending of email notifications
--
procedure unmute(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		   in number,
				funcmode	   in varchar2,
				resultout out nocopy varchar2	) is

   --
   l_proc varchar2(72) := '  OKC_ASYNC_PVT.'||'unmute';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

	if (funcmode = 'RUN') then

       -- UnMute Recipient
	    wf_engine.SetItemAttrText (itemtype 	=> itemtype, -- may need to hard code value OKCAUKAP
	      				itemkey  	=> itemkey,
  	      				aname 	   => '.MAIL_QUERY',
 						   avalue	   => ' ');
	end if;
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('100: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:';

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('200: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;


    		return;
		--
	end if;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


exception
	when others then
	  wf_core.context(G_PKG_NAME,
		'UNMUTE',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('2000: Leaving ',2);
                   okc_debug.Reset_Indentation;
                END IF;
	  raise;
end unmute;


begin
  G_WF_NAME 	:= 'OKCALERT';
  G_PROCESS_NAME 	:= 'ALERT_PROCESS';
end OKC_ASYNC_PVT;

/
