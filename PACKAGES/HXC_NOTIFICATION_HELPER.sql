--------------------------------------------------------
--  DDL for Package HXC_NOTIFICATION_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_NOTIFICATION_HELPER" AUTHID CURRENT_USER as
/* $Header: hxcnothel.pkh 120.0 2006/06/19 09:03:36 gsirigin noship $ */
Type g_rec_notif Is Record
( approval_style_id            hxc_approval_styles.approval_style_id%type
 ,timeouts_enabled             varchar2(1)
 ,number_retries     hxc_app_comp_notifications.notification_number_retries%type
 ,approver_timeout   hxc_app_comp_notifications.notification_timeout_value%type
 ,preparer_timeout   hxc_app_comp_notifications.notification_timeout_value%type
 ,admin_timeout      hxc_app_comp_notifications.notification_timeout_value%type
 ,notify_supervisor            varchar2(1)
 ,notify_worker_on_submit      varchar2(1)
 ,notify_worker_on_aa          varchar2(1)
 ,notify_preparer_approved     varchar2(1)
 ,notify_preparer_rejected     varchar2(1)
 ,notify_preparer_transfer     varchar2(1)
 );

 -- ----------------------------------------------------------------------------
 -- |--------------------------< run_extensions>-------------------------------|
 -- ----------------------------------------------------------------------------
 -- Returns TRUE if the run extensions value is 'Y' or NULL in the
 -- hxc_approval_styles for the approval style
 Function run_extensions(p_approval_comp_id in number)
 Return Boolean;

 -- ----------------------------------------------------------------------------
 -- |--------------------------< has_timeout_notifications>--------------------|
 -- ----------------------------------------------------------------------------
 -- Returns 'Y' if timeout notifications are enabled, N otherwise.

 Function has_timeout_notifications(p_approval_style_id in number)
 Return varchar2;

 -- ----------------------------------------------------------------------------
 -- |--------------------------<number_timeout_retries_any>--------------------|
 -- ----------------------------------------------------------------------------
 -- Returns notification_number_retries column for 'REQUEST-APPROVAL-RESEND'
 -- type action code for any approval component attached to the passed approval
 -- style.

 Function number_timeout_retries_any(p_approval_style_id in number)
 Return number;

 -- ----------------------------------------------------------------------------
 -- |--------------------------< approver_timeout_value>-----------------------|
 -- ----------------------------------------------------------------------------
 -- This function looks up any notification with action code
 -- 'REQUEST-APPROVAL-RESEND' for notification recipient of 'APPROVER' for
 -- the passed approval style id and returns the corresponding timeout value -
 -- returning null if none exist.

 Function approver_timeout_value(p_approval_style_id in number)
 Return number;

 -- ----------------------------------------------------------------------------
 -- |--------------------------< preparer_timeout_value>------------------------|
 -- ----------------------------------------------------------------------------
 -- This function looks up any notification with action code
 -- 'REQUEST-APPROVAL-RESEND' for notification recipient of 'PREPARER' for
 -- the passed approval style id and returns the corresponding timeout value -
 -- returning null if none exist.

 Function preparer_timeout_value(p_approval_style_id in number)
 Return number;

 -- ----------------------------------------------------------------------------
 -- |--------------------------< admin_timeout_value>---------------------------|
 -- ----------------------------------------------------------------------------
 -- This function looks up any notification with action code
 -- 'REQUEST-APPROVAL-RESEND' for notification recipient of 'ADMIN' for
 -- the passed approval style id and returns the corresponding timeout value -
 -- returning null if none exist.

 Function admin_timeout_value(p_approval_style_id in number)
 Return number;


 -- ----------------------------------------------------------------------------
 -- |--------------------------< notify_sup_for_approval>----------------------|
 -- ----------------------------------------------------------------------------
 -- This function checks to see if a notification with action code
 -- 'REQUEST-APPROVAL' exists for a recipient of 'SUPERVISOR' for any approval
 -- component attached to the approval style id. Returns Y if present,
 -- N otherwise.

 Function notify_sup_for_approval(p_approval_style_id in number)
 Return varchar2;

 -- ----------------------------------------------------------------------------
 -- |--------------------------< notify_worker_submission>---------------------|
 -- ----------------------------------------------------------------------------
 -- This function checks to see if a notification with action code
 -- 'SUBMISSION' exists for a recipient of 'WORKER' for any approval
 -- component attached to the approval style id. Returns Y if present, N otherwise.

 Function notify_worker_submission(p_approval_style_id in number)
 Return varchar2;

 -- ----------------------------------------------------------------------------
 -- |--------------------------< notify_worker_auto_approve>--------------------|
 -- ----------------------------------------------------------------------------
 -- This function checks to see if a notification with action code
 -- 'AUTO-APPROVE' exists for a recipient of 'WORKER' for any approval
 -- component attached to the approval style id. Returns Y if present,
 -- N otherwise.

 Function notify_worker_auto_approve(p_approval_style_id in number)
 Return varchar2;

 -- ----------------------------------------------------------------------------
 -- |--------------------------< notify_preparer_approve>----------------------|
 -- ----------------------------------------------------------------------------
 -- This function checks to see if a notification with action code
 -- 'APPROVED' exists for a recipient of 'PREPARER' for any approval
 -- component attached to the approval style id. Returns Y if present,
 -- N otherwise.

 Function notify_preparer_approve(p_approval_style_id in number)
 Return varchar2;

 -- ----------------------------------------------------------------------------
 -- |--------------------------< notify_preparer_reject>-----------------------|
 -- ----------------------------------------------------------------------------
 -- This function checks to see if a notification with action code
 -- 'REJECTED' exists for a recipient of 'PREPARER' for any approval
 -- component attached to the approval style id. Returns Y if present,
 -- N otherwise.

 Function notify_preparer_reject(p_approval_style_id in number)
 Return varchar2;

 -- ----------------------------------------------------------------------------
 -- |--------------------------< notify_preparer_transfer>----------------------|
 -- ----------------------------------------------------------------------------
 -- This function checks to see if a notification with action code
 -- 'TRANSFER' exists for a recipient of 'PREPARER' for any approval
 -- component attached to the approval style id. Returns Y if present,
 -- N otherwise.

 Function notify_preparer_transfer(p_approval_style_id in number)
 Return varchar2;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_notification_records>------------------|
-- ----------------------------------------------------------------------------
--
--

Procedure create_notification_records
 ( p_approval_style_id             in number
  ,p_approval_style_name           in varchar2
  ,p_timeouts_enabled              in varchar2
  ,p_number_retries        	   in number
  ,p_approver_timeout       	   in number
  ,p_preparer_timeout       	   in number
  ,p_admin_timeout          	   in number
  ,p_notify_supervisor             in varchar2
  ,p_notify_worker_on_submit       in varchar2
  ,p_notify_worker_on_aa           in varchar2
  ,p_notify_preparer_approved      in varchar2
  ,p_notify_preparer_rejected      in varchar2
  ,p_notify_preparer_transfer      in varchar2
 );


--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_notification_records>------------------|
-- ----------------------------------------------------------------------------
--
--
Procedure update_notification_records
 ( p_approval_style_id             in number
  ,p_approval_style_name           in varchar2
  ,p_timeouts_enabled              in varchar2
  ,p_number_retries        	   in number
  ,p_approver_timeout       	   in number
  ,p_preparer_timeout       	   in number
  ,p_admin_timeout          	   in number
  ,p_notify_supervisor             in varchar2
  ,p_notify_worker_on_submit       in varchar2
  ,p_notify_worker_on_aa           in varchar2
  ,p_notify_preparer_approved      in varchar2
  ,p_notify_preparer_rejected      in varchar2
  ,p_notify_preparer_transfer      in varchar2
 );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_notification_records>------------------|
-- ----------------------------------------------------------------------------
--
--
Procedure delete_notification_records
(
 p_approval_style_id in hxc_approval_styles.approval_style_id%type
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< approval_comps_usages>-------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure to create or delete entries from usages table when a approval
-- component is either added or deleted from the approval style.

Procedure approval_comps_usages
      ( p_approval_style_id  in number
       ,p_approval_comp_id  in number
       ,p_approval_comp_ovn in number
       ,p_dml_action        in varchar2
      );

end hxc_notification_helper;

 

/
