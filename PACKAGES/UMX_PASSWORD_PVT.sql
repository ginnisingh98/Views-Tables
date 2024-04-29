--------------------------------------------------------
--  DDL for Package UMX_PASSWORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_PASSWORD_PVT" AUTHID CURRENT_USER AS
/* $Header: UMXVUPWS.pls 120.2.12010000.2 2009/02/02 22:39:48 jstyles ship $ */

  -- Procedure  : validate_password
  -- Type       : Private
  -- Pre_reqs   :
  -- Description: This API will validate the user's password.
  -- Parameters
  -- input parameters :
  --    p_username - username of the password's owner
  --    p_password - password to validate
  -- output parameters:
  --    x_return_status - Returns FND_API.G_RET_STS_SUCCESS if success
  --                    - Returns FND_API.G_RET_STS_ERROR if failed
  --    x_message_data  - Reason why it is failed.
  -- Errors      :
  -- Other Comments :
  Procedure validate_password (p_username      in fnd_user.user_name%type,
                               p_password      in varchar2,
                               x_return_status out NOCOPY varchar2,
                               x_message_data  out NOCOPY varchar2);

  --  *******************************************
  --     Procedure ResetPwd
  --  *******************************************
  procedure ResetPwd (p_username           in fnd_user.user_name%type,
                      p_password           in varchar2 default null,
                      p_user_appr_msg_name in varchar2 default null,
                      p_pwd_reset_msg_name in varchar2 default null,
                      p_check_identity     in varchar2 default 'Y',
                      p_htmlagent          in varchar2 default null,
                      x_return_status      out NOCOPY varchar2,
                      x_message_data       out NOCOPY varchar2) ;

  Procedure UpdatePassword_WF(itemtype  in varchar2,
                              itemkey   in varchar2,
                              actid     in number,
                              funcmode  in varchar2,
                              resultout in out NOCOPY varchar2);

  Procedure CreateRole(itemtype   in varchar2,
                        itemkey   in varchar2,
                        actid     in number,
                        funcmode  in varchar2,
                        resultout in out NOCOPY varchar2);

  Procedure SetPassword_WF(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2);

  procedure ForgotPwd(p_username           in fnd_user.user_name%type,
                      p_user_appr_msg_name in varchar2 default null,
                      p_pwd_reset_msg_name in varchar2 default null,
                      p_check_identity     in varchar2 default 'Y',
                      p_htmlagent          in varchar2 default null,
                      x_return_status      out NOCOPY varchar2,
                      x_message_name       out NOCOPY varchar2,
                      x_message_data       out NOCOPY varchar2) ;

  -------------------------------------------------------------------
  -- Name:        clean_up_ad_hoc_role
  -- Description: This API set the status to inactive and expiration
  --              date to sysdate of the ad hoc role created by the password
  --              workflow.
  -------------------------------------------------------------------
  Procedure clean_up_ad_hoc_role (itemtype  in varchar2,
                                  itemkey   in varchar2,
                                  actid     in number,
                                  funcmode  in varchar2,
                                  resultout in out NOCOPY varchar2);

end UMX_PASSWORD_PVT;

/
