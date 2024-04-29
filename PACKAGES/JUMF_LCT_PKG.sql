--------------------------------------------------------
--  DDL for Package JUMF_LCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JUMF_LCT_PKG" AUTHID CURRENT_USER as
/* $Header: JTFUMLSS.pls 120.0 2005/09/26 14:04:58 vimohan noship $ */
procedure LOAD_SEED_TEMPLATES(
 x_upload_mode           in  varchar2,
 x_template_name         in  varchar2,
 x_description           in  varchar2,
 x_owner                 in  varchar2,
 x_template_key          in  varchar2,
 x_page_name             in  varchar2,
 x_template_handler      in  varchar2,
 x_template_type_code    in  varchar2,
 x_enabled_flag          in  varchar2,
 x_application_id        in  varchar2,
 x_effective_start_date  in  varchar2,
 x_effective_end_date    in  varchar2,
 x_last_update_date      in  varchar2,
 x_custom_mode           in  varchar2
);



procedure LOAD_SEED_APPROVALS(
x_upload_mode in varchar2,
x_approval_key in varchar2,
x_approval_key_start_date in varchar2,
x_approval_name in varchar2,
x_description in varchar2,
x_owner in varchar2,
x_enabled_flag in varchar2,
x_application_id in varchar2,
x_wf_item_type in varchar2,
x_use_pending_req_flag in varchar2,
x_effective_end_date in varchar2,
x_last_update_date in varchar2,
x_custom_mode in varchar2 );

procedure LOAD_SEED_APPROVERS(
    x_upload_mode in varchar2,
    x_effective_start_date in varchar2,
    x_approval_key_start_date in varchar2,
    x_user_name in varchar2,
    x_approval_key in varchar2,
    x_approver_seq in varchar2,
    x_effective_end_date in varchar2,
    x_owner in varchar2,
    x_last_update_date in varchar2,
    x_custom_mode  in varchar2
    );


 procedure LOAD_SEED_USERTYPES(
    x_upload_mode in varchar2,
    x_usertype_key in varchar2,
    x_usertype_key_start_date in varchar2,
    x_usertype_name in varchar2,
    x_usertype_shortname in varchar2,
    x_description in varchar2,
    x_owner in varchar2,
    x_is_self_service_flag in varchar2,
    x_email_notification_flag in varchar2,
    x_enabled_flag in varchar2,
    x_approval_key in varchar2,
    x_approval_key_start_date in varchar2,
    x_application_id in varchar2,
    x_effective_end_date in varchar2,
    x_display_order in varchar2,
    x_last_update_date in varchar2,
    x_custom_mode in varchar2
    );


procedure LOAD_SEED_USERTYPE_TMPL(
x_upload_mode in varchar2,
x_usertype_key in varchar2,
x_usertype_key_start_date in varchar2,
x_template_key in varchar2,
x_template_key_start_date in varchar2,
x_effective_start_date in varchar2,
x_effective_end_date in varchar2,
x_owner in varchar2,
x_last_update_date in varchar2,
x_custom_mode in varchar2
);

procedure LOAD_SEED_USERTYPE_ROLE(
    x_upload_mode in varchar2,
    x_usertype_key in varchar2,
    x_usertype_key_start_date in varchar2,
    x_principal_name in varchar2,
    x_effective_start_date in varchar2,
    x_effective_end_date in varchar2,
    x_owner in varchar2,
    x_last_update_date in varchar2,
    x_custom_mode in varchar2
 );


procedure LOAD_SEED_USERTYPE_RESP(
  x_upload_mode                 in varchar2,
  x_usertype_key                in varchar2,
  x_usertype_key_start_date     in varchar2,
  x_responsibility_key          in varchar2,
  x_effective_start_date        in varchar2,
  x_is_default_flag             in varchar2,
  x_effective_end_date          in varchar2,
  x_owner                       in varchar2,
  x_application_id              in varchar2,
  x_last_update_date            in varchar2,
  x_custom_mode                 in varchar2
);


procedure LOAD_SEED_SUBSCRIPTIONS(
x_upload_mode in varchar2,
x_subscription_key in varchar2,
x_subscription_key_start_date in varchar2,
x_subscription_name in varchar2,
x_description in varchar2,
x_owner in varchar2,
x_availability_code in varchar2,
x_logon_display_frequency in varchar2,
x_parent_subscription_key in varchar2,
x_parent_key_start_date in varchar2,
x_application_id in varchar2,
x_enabled_flag in varchar2,
x_approval_key in varchar2,
x_approval_key_start_date in varchar2,
x_auth_delegation_role_id in varchar2,
x_effective_end_date in varchar2,
x_last_update_date in varchar2,
x_custom_mode   in varchar2
);


procedure LOAD_SEED_SUBSCRIPTION_TMPL(
x_upload_mode in varchar2,
x_subscription_key in varchar2,
x_subscription_key_start_date in varchar2,
x_template_key in varchar2,
x_template_key_start_date in varchar2,
x_effective_start_date in varchar2,
x_effective_end_date in varchar2,
x_owner in varchar2,
x_last_update_date in varchar2,
x_custom_mode   in varchar2
);


procedure LOAD_SEED_SUBSCR_USERTYPE(
x_upload_mode in varchar2,
x_subscription_key in varchar2,
x_subscription_key_start_date in varchar2,
x_usertype_key in varchar2,
x_usertype_key_start_date in varchar2,
x_effective_start_date in varchar2,
x_subscription_flag in varchar2,
x_subscription_display_order in varchar2,
x_effective_end_date in varchar2,
x_owner in varchar2,
x_last_update_date in varchar2,
x_custom_mode   in varchar2
);



procedure LOAD_SEED_SUBSCRIPTION_ROLE(
x_upload_mode in varchar2,
x_subscription_key in varchar2,
x_subscription_key_start_date in varchar2,
x_principal_name in varchar2,
x_effective_start_date in varchar2,
x_effective_end_date in varchar2,
x_owner in varchar2,
x_last_update_date in varchar2,
x_custom_mode   in varchar2
);



procedure LOAD_SEED_SUBSCRIPTION_RESP(
x_upload_mode in varchar2,
x_subscription_key in varchar2,
x_subscription_key_start_date in varchar2,
x_responsibility_key in varchar2,
x_effective_start_date in varchar2,
x_effective_end_date in varchar2,
x_owner in varchar2,
x_application_id in varchar2,
x_last_update_date in varchar2,
x_custom_mode   in varchar2
);
end jumf_lct_pkg;

 

/
