--------------------------------------------------------
--  DDL for Package BIS_ICX_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_ICX_SECURITY_PVT" AUTHID CURRENT_USER as
/* $Header: BISVSECS.pls 115.4 2002/11/20 19:02:32 kiprabha noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
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
);
END BIS_ICX_SECURITY_PVT;

 

/
