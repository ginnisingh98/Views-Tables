--------------------------------------------------------
--  DDL for Package HXC_APP_COMP_NOTIFICATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APP_COMP_NOTIFICATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: hxchanapi.pkh 120.0 2006/06/19 06:54:25 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_app_comp_notification_b >---------------|
-- ----------------------------------------------------------------------------
--
   procedure delete_app_comp_notification_b
          (
            p_comp_notification_id         in number,
            p_object_version_number        in number
          );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <delete_app_comp_notification_a >--------------|
-- ----------------------------------------------------------------------------
--
   procedure delete_app_comp_notification_a
          (
            p_comp_notification_id         in number,
            p_object_version_number        in number
          );

end hxc_app_comp_notifications_bk3;

 

/
