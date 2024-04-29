--------------------------------------------------------
--  DDL for Package IEM_CLIENTLAUNCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_CLIENTLAUNCH_PUB" AUTHID CURRENT_USER as
/* $Header: iempuwqs.pls 115.7 2003/04/15 00:09:20 liangxia shipped $*/

--
--
-- Purpose: Maintain Launch Email Client
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia  4/14/2003    Launch Message Component
-- ---------   ------  -------------------------------
/***************************************************************/
-- Start of Comments
--  API name 	: launchInbound();
--  Type	     : Public
--  Function	: Used by UWQ to launch Email Client. Invoked when
--             : an agent clicks on the Get Work button to pick up
--             : a new processed email / Inbound email.
--  Pre-reqs	: UWQ media integration packages.
--  Parameters	:
--	IN
--     p_ieu_media_data  IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
--
--   OUT
--     x_action_type     OUT number,
--     x_action_name     OUT varchar2,
--     x_action_param    OUT varchar2,
--     x_msg_name        OUT varchar2,
--     x_msg_param       OUT varchar2,
--     x_dialog_style    OUT number
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE launchInbound ( p_ieu_media_data  IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
   	                  x_action_type     OUT NOCOPY number,
                          x_action_name     OUT NOCOPY varchar2,
                          x_action_param    OUT NOCOPY varchar2,
                          x_msg_name        OUT NOCOPY varchar2,
                          x_msg_param       OUT NOCOPY varchar2,
                          x_dialog_style    OUT NOCOPY number,
                          x_msg_appl_short_name OUT NOCOPY varchar2
                         );

/***************************************************************/
-- Start of Comments
--  API name   : launchAcquired();
--  Type       : Public
--  Function   : Used by UWQ to launch Email Client. Invoked when
--             : an agent clicks on an email already assigned to
--             : him and which is present in his Inbox on any
--             : account.
--  Pre-reqs   : UWQ media integration packages.
--  Parameters :
--   IN
--     p_ieu_media_data  IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
--
--   OUT
--     x_action_type     OUT number,
--     x_action_name     OUT varchar2,
--     x_action_param    OUT varchar2,
--     x_msg_name        OUT varchar2,
--     x_msg_param       OUT varchar2,
--     x_dialog_style    OUT number
--
--   Version   : 1.0
--   Notes          :
--
-- End of comments
-- **********************************************************


PROCEDURE launchAcquired( p_ieu_media_data  IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
                          x_action_type     OUT NOCOPY number,
                          x_action_name     OUT NOCOPY varchar2,
                          x_action_param    OUT NOCOPY varchar2,
                          x_msg_name        OUT NOCOPY varchar2,
                          x_msg_param       OUT NOCOPY varchar2,
                          x_dialog_style    OUT NOCOPY number,
                          x_msg_appl_short_name OUT NOCOPY VARCHAR2
                         );


/********************************************************************/
END IEM_CLIENTLAUNCH_PUB;

 

/
