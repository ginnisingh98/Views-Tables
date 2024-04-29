--------------------------------------------------------
--  DDL for Package Body BIS_ICX_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_ICX_SECURITY_PVT" as
/* $Header: BISVSECB.pls 115.5 2003/03/11 10:32:01 nkishore noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_ICX_SECURITY_PVT
--                                                                        --
--  DESCRIPTION:  Private package to simulate ICX login
--                and get the session_id, cookie_value and transaction id
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                --
--  02-25-00   amkulkar   Initial creation                                --
--  02-17-03   nkishore   Adding Resp id, appl id, sec grp id and update  --
--                        session context                                 --
----------------------------------------------------------------------------
PROCEDURE  CREATE_ICX_SESSION
(p_user_id      		IN      VARCHAR2
,p_resp_appl_id			IN	NUMBER DEFAULT NULL
,p_responsibility_id		IN	NUMBER DEFAULT NULL
,p_security_group_id		IN	NUMBER DEFAULT NULL
,p_menu_id			IN	NUMBER DEFAULT NULL
,p_function_id			IN	NUMBER DEFAULT NULL
,p_page_id			IN	NUMBER DEFAULT NULL
,x_session_id 			OUT 	NOCOPY NUMBER
,x_cookie_value			OUT	NOCOPY VARCHAR2
,x_cookie_name			OUT	NOCOPY VARCHAR2
,x_transaction_id		OUT	NOCOPY VARCHAR2
,x_dbc_name			OUT	NOCOPY VARCHAR2
,x_apps_web_agent		OUT	NOCOPY VARCHAR2
,x_apps_fwk_agent		OUT	NOCOPY VARCHAR2
,x_language_code		OUT	NOCOPY VARCHAR2
,x_return_Status 		OUT     NOCOPY VARCHAR2
,x_msg_Data    			OUT     NOCOPY VARCHAR2
,x_msg_count    		OUT     NOCOPY NUMBER
)
IS
  l_session_id 			NUMBER;
  l_cookie_name			VARCHAR2(32000);
  l_cookie_value		VARCHAR2(32000);
  l_transaction_id		VARCHAR2(32000);
  l_profile_defined             boolean;
  l_language    		varchar2(32000);
BEGIN
  if p_security_group_id is null then
    l_session_id := icx_sec.createsession(p_user_id => p_user_id);
  else
    l_session_id := icx_sec.createsession(p_user_id => p_user_id
                                         , c_sec_grp_id => p_security_group_id);
  end if;

  l_cookie_name := icx_sec.getsessioncookiename();
  l_cookie_value := icx_call.encrypt3(l_session_id);
  if p_responsibility_id is null then
    l_transaction_id := icx_sec.createtransaction(l_session_id);
  else
    l_transaction_id := icx_sec.createtransaction(p_session_id  => l_session_id
                                                , p_resp_appl_id => p_resp_appl_id
                                                , p_responsibility_id => p_responsibility_id
                                                , p_security_group_id => p_security_group_id);
  end if;
  if p_responsibility_id is not null then
     icx_sec.updateSessionContext(
                                p_application_id         => p_resp_appl_id,
                                p_responsibility_id      => p_responsibility_id,
                                p_security_group_id      => p_security_group_id,
                                p_session_id             => l_session_id,
                                p_transaction_id         => l_transaction_id);
  end if;

  x_session_id := l_session_id;
  x_cookie_value := l_cookie_value;
  x_cookie_name := l_cookie_name;
  x_transaction_id := icx_call.encrypt3(l_transaction_id);
  x_dbc_name := FND_WEB_CONFIG.DATABASE_ID;
  x_apps_web_agent := FND_WEB_CONFIG.TRAIL_SLASH(fnd_profile.value('APPS_WEB_AGENT'));
  FND_PROFILE.GET_SPECIFIC(name_z  =>  'ICX_LANGUAGE'
			  ,user_id_z => p_user_id
			  ,val_z     => x_apps_fwk_Agent
			  ,defined_z => l_profile_defined
			  );
  x_apps_fwk_agent := FND_WEB_CONFIG.TRAIL_SLASH(x_apps_fwk_agent);
  FND_PROFILE.GET_SPECIFIC(name_z  => 'ICX_LANGUAGE'
			  ,user_id_z => p_user_id
			  ,val_z     => l_language
			  ,defined_z => l_profile_Defined
			  );
  if l_language is null then
     select upper(value) into l_language
     from v$nls_parameters
     where parameter='NLS_LANGUAGE';
  end if;
  SELECT language_code INTO x_language_Code
  FROM fnd_languages
  WHERE nls_language = l_language;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Count_And_get
  (p_count	=>	x_msg_count,
   p_data	=>	x_msg_data
  );
EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_get
  (p_count	=>	x_msg_count,
   p_data	=>	x_msg_data
  );
END;
END BIS_ICX_SECURITY_PVT;

/
