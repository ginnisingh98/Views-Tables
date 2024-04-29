--------------------------------------------------------
--  DDL for Package UMX_LOGIN_HELP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_LOGIN_HELP_PVT" AUTHID CURRENT_USER AS
/* $Header: UMXLHLPS.pls 120.4.12010000.3 2016/01/08 10:04:45 avelu ship $ */


   /******************************************************************************
   * UserNameList
   *
   ******************************************************************************/
   type UsersWEmailList is Record
     (
        --email                   fnd_user.email_address%type,
        --role_name               WF_LOCAL_ROLES.name%type,
        user_name               FND_USER.USER_NAME%TYPE,
        notification_preference WF_LOCAL_ROLES.NOTIFICATION_PREFERENCE%type
     );

   type UsersWEmail is table of UsersWEmailList
         index by binary_integer;


  procedure ForgottenPwd(p_username           in fnd_user.user_name%type,
											p_parent_item_key   in varchar2 default null,
						p_orig_page		   in varchar2,
                      x_return_status      out NOCOPY varchar2,
                      x_message_name       out NOCOPY varchar2) ;

  procedure ForgottenUname
                     (p_email              in fnd_user.email_address%type,
						p_orig_page		   in varchar2,
                      x_return_status      out NOCOPY varchar2,
                      x_message_name       out NOCOPY varchar2);

  Procedure CreateRole(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout in out NOCOPY varchar2);


  Procedure GenAuthKey(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2);

  Procedure GenUrl2ResetPwdPg(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2);
  Procedure GenUrl2LoginPg(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2);
  Procedure DisableAccount(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2);
  procedure CompleteActivity( p_itemKey          in varchar2,
                            x_return_status      out NOCOPY varchar2,
                            x_message_name       out NOCOPY varchar2);
  procedure ResetPassword(  p_username           in fnd_user.user_name%type,
                            --p_usernameurl        in fnd_user.user_name%type,
                            p_password           in varchar2 default null,
                            p_itemkey            in varchar2,
                            p_authkey            in varchar2,
                            x_no_attempts        out NOCOPY varchar2,
                            x_return_status      out NOCOPY varchar2,
                            x_message_name       out NOCOPY varchar2,
                            x_message_data       out NOCOPY varchar2);


  PROCEDURE ValidateResetPwdReq (p_username           in fnd_user.user_name%type,
                                 p_authkey            in varchar2,
                                 p_itemkey            in varchar2,
                                 x_no_attempts        out NOCOPY varchar2,
                                 x_return_status      out NOCOPY varchar2,
                                 x_message_name       out NOCOPY varchar2);
  PROCEDURE ValidateAuthKey( p_authkey            in varchar2,
                                 p_itemkey            in varchar2,
                                 x_no_attempts        out NOCOPY varchar2,
                                 x_return_status      out NOCOPY varchar2,
                                 x_message_name       out NOCOPY varchar2);

  procedure complete_workflow(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out NOCOPY varchar2);

end UMX_LOGIN_HELP_PVT;

/
