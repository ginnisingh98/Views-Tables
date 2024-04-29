--------------------------------------------------------
--  DDL for Package Body FND_ICX_SEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ICX_SEC" as
/* $Header: aficxscb.pls 115.4 2002/06/20 19:14:12 dbowles ship $ */

--- Check_Session function, returns the status of the ICX session id
--- passed to the function
function Check_Session (p_icx_session_id  in  varchar2,
                        p_resp_id in varchar2 default null,
                        p_app_resp_id in varchar2 default null) return varchar2 IS

session_stat varchar2(30);

BEGIN
   session_stat := ICX_SEC.Check_Session(p_icx_session_id,
                                         p_resp_id,
                                         p_app_resp_id);
   return session_stat;
END Check_Session;

--- recreateURL returns the URL that is used to display an ICX
--- logon HTML page;

function recreateURL (p_icx_session_id  in  varchar2,
                      p_user_name       in  varchar2
                      ) return varchar2 IS

url  varchar2(255);
BEGIN
   url := ICX_SEC.recreateURL(p_icx_session_id,
                              p_user_name);
   return url;
END recreateURL;

end FND_ICX_SEC;

/
