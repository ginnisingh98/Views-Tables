--------------------------------------------------------
--  DDL for Package HXC_APP_COMP_NOTIFICATIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APP_COMP_NOTIFICATIONS_BK1" AUTHID CURRENT_USER as
/* $Header: hxchanapi.pkh 120.0 2006/06/19 06:54:25 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_app_comp_notification_b >---------------|
-- ----------------------------------------------------------------------------
--
  procedure create_app_comp_notification_b
       (
        p_notification_number_retries  in number,
        p_notification_timeout_value   in number,
        p_notification_action_code     in varchar2,
        p_notification_recipient_code  in varchar2
        );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <create_app_comp_notification_a >--------------|
-- ----------------------------------------------------------------------------
--
  procedure create_app_comp_notification_a
      (
        p_comp_notification_id         in number,
        p_object_version_number        in number,
        p_notification_number_retries  in number,
        p_notification_timeout_value   in number,
        p_notification_action_code     in varchar2,
        p_notification_recipient_code  in varchar2
       );
--
end hxc_app_comp_notifications_bk1;

 

/
