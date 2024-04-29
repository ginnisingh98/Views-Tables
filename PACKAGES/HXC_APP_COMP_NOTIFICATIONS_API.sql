--------------------------------------------------------
--  DDL for Package HXC_APP_COMP_NOTIFICATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APP_COMP_NOTIFICATIONS_API" AUTHID CURRENT_USER as
/* $Header: hxchanapi.pkh 120.0 2006/06/19 06:54:25 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_app_comp_notification>----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Approval Component Notifications.
--
-- Prerequisites:
--
-- None.
--
-- In Parameters:
--   Name                            Reqd     Type               Description
--  p_comp_notification_id           Yes   table of number    Primary key of the new
--                                                            notification
--  p_object_version_number          No    number of number   Object version number for the
--                                                            new notification
--  p_notification_number_retries    Yes    number            Number of retries
--  p_notification_timeout_value     Yes    number            Timeout value
--  p_notification_action_code       Yes    varchar2          Action Code
--  p_notification_recipient_code    Yes    varchar2          Recipient Code
--  p_approval_style_name            No     varchar2          Approval style name
--  p_time_recipient_name            No     varchar2          Time recipient name
--  p_approval_component_id          No     number            Approval component id
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the notification record has been created
-- successfully,are:
--
--   Name                                  Type             Description
--
--   p_comp_notification_id            table of number   Primary key of the new
--                                                       notification
--   p_object_version_number           number of number  Object version number for the
--                                                       new notification
--
-- Post Failure:
--
-- The notification record will not be created and an application error will be
-- raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}

TYPE id_type IS TABLE OF number(15);
TYPE ovn_type IS TABLE OF number(9);

C_ACTION_APPROVED                  CONSTANT VARCHAR2(30) := 'APPROVED';
C_ACTION_AUTO_APPROVE              CONSTANT VARCHAR2(30) := 'AUTO-APPROVE';
C_ACTION_ERROR                     CONSTANT VARCHAR2(30) := 'ERROR';
C_ACTION_REJECTED                  CONSTANT VARCHAR2(30) := 'REJECTED';
C_ACTION_REQUEST_APPROVAL          CONSTANT VARCHAR2(30) := 'REQUEST-APPROVAL';
C_ACTION_REQUEST_APPR_RESEND       CONSTANT VARCHAR2(30) := 'REQUEST-APPROVAL-RESEND';
C_ACTION_SUBMISSION                CONSTANT VARCHAR2(30) := 'SUBMISSION';
C_ACTION_TRANSFER                  CONSTANT VARCHAR2(30) := 'TRANSFER';
C_RECIPIENT_ADMIN                  CONSTANT VARCHAR2(30) := 'ADMIN';
C_RECIPIENT_APPROVER               CONSTANT VARCHAR2(30) := 'APPROVER';
C_RECIPIENT_ERROR_ADMIN            CONSTANT VARCHAR2(30) := 'ERROR-ADMIN';
C_RECIPIENT_PREPARER               CONSTANT VARCHAR2(30) := 'PREPARER';
C_RECIPIENT_SUPERVISOR             CONSTANT VARCHAR2(30) := 'SUPERVISOR';
C_RECIPIENT_WORKER                 CONSTANT VARCHAR2(30) := 'WORKER';


procedure create_app_comp_notification
  (
 p_notification_number_retries  in number,
 p_notification_timeout_value   in number,
 p_notification_action_code     in varchar2,
 p_notification_recipient_code  in varchar2,
 p_approval_style_name          in varchar2,
 p_time_recipient_name          in varchar2,
 p_approval_component_id        in number,
 p_comp_notification_id         in out nocopy id_type,
 p_object_version_number        in out nocopy ovn_type
 );


--
-- ----------------------------------------------------------------------------
-- |------------------------<update_app_comp_notification>--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Component Notifications.
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                       Reqd   Type     Description
--
--  p_comp_notification_id      Yes   number    Primary key of the new
--                                              notification
--  p_object_version_number           number    Object version number for the
--                                              new notification
--  p_notification_number_retries No  number    Number of retries
--  p_notification_timeout_value No   number    Timeout value
--
-- Post Success:
--
-- when the approval style has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated approval style
--
-- Post Failure:
--
-- The notification record will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

procedure update_app_comp_notification
(
 p_comp_notification_id in number,
 p_object_version_number in out nocopy number,
 p_notification_number_retries in number default hr_api.g_number,
 p_notification_timeout_value in number default hr_api.g_number
 );

--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_app_comp_notification >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deactivates the usage record for all the approval component notifications.
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_comp_notification_id         Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the notification record has been deactivated successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The notification record will not be deactivated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

procedure delete_app_comp_notification
  (
    p_comp_notification_id     in number
   ,p_object_version_number    in number
  );

--
-- ----------------------------------------------------------------------------
-- |------------------------< purge_comp_notification >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes the usage records of the notification followed by the
-- notification itself.
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_comp_notification_id         Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
-- Usages records and notification records will be deleted
--
--
-- Post Failure:
-- Usages records and notification records will be not deleted
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

procedure purge_comp_notification
  (
  p_comp_notification_id         in number
 ,p_object_version_number        in number
 );


--
-- ----------------------------------------------------------------------------
-- |------------------------< disable_timeout_notifications >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deselcts the usage records for the REQUEST-APPROVAL-RESEND action type
-- notifications
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd   Type       Description
--
--  p_approval_style_name           Yes   varchar2    Approval Style Name
--
-- Post Success:
-- This API deselcts the usage records for the REQUEST-APPROVAL-RESEND action type
-- notifications
--
-- Post Failure:
--
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure disable_timeout_notifications
  (
    p_approval_style_name in varchar2
   );

end hxc_app_comp_notifications_api;

 

/
