--------------------------------------------------------
--  DDL for Package JTF_UM_FORGOT_PASSWD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_FORGOT_PASSWD" AUTHID CURRENT_USER as
/* $Header: JTFVUPWS.pls 115.5 2003/06/23 17:51:40 pseo ship $ */

--  *******************************************
--     Procedure ForgotPwd
--  *******************************************
--procedure ForgotPwd (c_user_name in varchar2);

procedure ForgotPwd (p_user_name in varchar2,
                     x_return_status out NOCOPY varchar2,
                     x_message_data  out NOCOPY varchar2) ;

procedure ForgotPwd (p_user_name in varchar2,
                     x_return_status out NOCOPY varchar2,
                     x_message_name out  NOCOPY varchar2,
                     x_message_data  out NOCOPY varchar2) ;
procedure ForgotPwd (p_user_name in varchar2,
                     p_user_appr_msg_name in varchar2,
                     p_pwd_reset_msg_name in varchar2,
                     x_return_status out NOCOPY varchar2,
                     x_message_data  out NOCOPY varchar2) ;

procedure ForgotPwd (p_user_name in varchar2,
                     p_user_appr_msg_name in varchar2,
                     p_pwd_reset_msg_name in varchar2,
                     x_return_status out NOCOPY varchar2,
	             x_message_name out  NOCOPY varchar2,
                     x_message_data  out NOCOPY varchar2) ;

Procedure UpdatePassword_WF(itemtype  in varchar2,
                             itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout in out NOCOPY varchar2);

Procedure CreateRole(itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout in out  NOCOPY varchar2);

Procedure SetPassword_WF(itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout in out  NOCOPY varchar2);

end JTF_UM_FORGOT_PASSWD;

 

/
