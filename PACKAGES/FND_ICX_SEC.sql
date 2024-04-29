--------------------------------------------------------
--  DDL for Package FND_ICX_SEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ICX_SEC" AUTHID CURRENT_USER as
/* $Header: aficxscs.pls 115.4 2002/06/20 19:13:33 dbowles ship $ */


function Check_Session (
  p_icx_session_id  in  varchar2,
  p_resp_id in varchar2 default null,
  p_app_resp_id in varchar2 default null)
return varchar2;

function recreateURL (
  p_icx_session_id  in  varchar2,
  p_user_name       in  varchar2
  )
return varchar2;

END FND_ICX_SEC;

 

/
