--------------------------------------------------------
--  DDL for Package Body HXC_NOTIFICATION_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_NOTIFICATION_HELPER" as
/* $Header: hxcnothel.pkb 120.1 2006/07/28 13:18:39 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< run_extensions >-----------------------|
-- ----------------------------------------------------------------------------

FUNCTION run_extensions (p_approval_comp_id IN NUMBER)
   RETURN BOOLEAN
IS
   l_extension                  BOOLEAN;
   l_run_recipient_extensions   hxc_approval_styles.run_recipient_extensions%TYPE;

   CURSOR csr_run_extension
   IS
      SELECT has.run_recipient_extensions
        FROM hxc_approval_styles has, hxc_approval_comps hac
       WHERE hac.approval_comp_id = p_approval_comp_id
         AND has.approval_style_id = hac.approval_style_id;
BEGIN
   OPEN csr_run_extension;
   FETCH csr_run_extension INTO l_run_recipient_extensions;

   IF l_run_recipient_extensions = 'Y' OR l_run_recipient_extensions IS NULL
   THEN
      l_extension := TRUE ;
   ELSE
      l_extension := FALSE ;
   END IF;

   CLOSE csr_run_extension;
   RETURN (l_extension);
END run_extensions;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< has_timeout_notifications >--------------------|
-- ----------------------------------------------------------------------------

FUNCTION has_timeout_notifications (p_approval_style_id IN NUMBER)
   RETURN VARCHAR2
IS
   l_timeout_notifs   number (9) := 0;
   l_notifs           VARCHAR2 (9);

   CURSOR csr_timeout_notifs
   IS select count(1)  FROM hxc_approval_styles has,
                       hxc_approval_comps hac,
                       hxc_app_comp_notifications hacn,
                       hxc_app_comp_notif_usages hacnu
                 WHERE has.approval_style_id = p_approval_style_id
                   AND has.approval_style_id = hac.approval_style_id
                   AND hac.approval_comp_id = hacnu.approval_comp_id
                   AND hac.object_version_number = hacnu.approval_comp_ovn
                   AND hacnu.comp_notification_id = hacn.comp_notification_id
                   AND hacn.notification_action_code =
                       hxc_app_comp_notifications_api.
                         c_action_request_appr_resend
                   AND hacnu.enabled_flag = 'Y';
BEGIN
   OPEN csr_timeout_notifs;
   FETCH csr_timeout_notifs INTO l_timeout_notifs;

   IF l_timeout_notifs<>0
   THEN
      l_notifs := 'Y';
   ELSE
      l_notifs := 'N';
   END IF;

   CLOSE csr_timeout_notifs;
   RETURN (l_notifs);
END has_timeout_notifications;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< number_timeout_retries_any >---------------------|
-- ----------------------------------------------------------------------------

FUNCTION number_timeout_retries_any (p_approval_style_id IN NUMBER)
   RETURN NUMBER
IS
   l_retries   hxc_app_comp_notifications.notification_number_retries%TYPE;

   CURSOR csr_timeout_retries
   IS
      SELECT notification_number_retries
        FROM hxc_approval_styles has,
             hxc_approval_comps hac,
             hxc_app_comp_notifications hacn,
             hxc_app_comp_notif_usages hacnu
       WHERE has.approval_style_id = p_approval_style_id
         AND has.approval_style_id = hac.approval_style_id
         AND hac.approval_comp_id = hacnu.approval_comp_id
         AND hac.object_version_number = hacnu.approval_comp_ovn
         AND hacnu.comp_notification_id = hacn.comp_notification_id
         AND hacnu.comp_notification_ovn = hacn.object_version_number
         AND hacn.notification_action_code =
                  hxc_app_comp_notifications_api.c_action_request_appr_resend
         AND hacnu.enabled_flag = 'Y';
BEGIN
   OPEN csr_timeout_retries;
   FETCH csr_timeout_retries INTO l_retries;
   RETURN (l_retries);
   CLOSE csr_timeout_retries;
END number_timeout_retries_any;

--
-- ----------------------------------------------------------------------------
-- |------------------------< approver_timeout_value >-----------------------|
-- ----------------------------------------------------------------------------

FUNCTION approver_timeout_value (p_approval_style_id IN NUMBER)
   RETURN NUMBER
IS
   l_appr_timeout_value   hxc_app_comp_notifications.notification_timeout_value%TYPE;

   CURSOR csr_timeout_value
   IS
      SELECT notification_timeout_value
        FROM hxc_approval_styles has,
             hxc_approval_comps hac,
             hxc_app_comp_notifications hacn,
             hxc_app_comp_notif_usages hacnu
       WHERE has.approval_style_id = p_approval_style_id
         AND has.approval_style_id = hac.approval_style_id
         AND hac.approval_comp_id = hacnu.approval_comp_id
         AND hac.object_version_number = hacnu.approval_comp_ovn
         AND hacnu.comp_notification_id = hacn.comp_notification_id
         AND hacnu.comp_notification_ovn = hacn.object_version_number
         AND hacn.notification_action_code = 'REQUEST-APPROVAL-RESEND'
         AND hacn.notification_recipient_code = 'APPROVER'
         AND hacnu.enabled_flag = 'Y';
BEGIN
   OPEN csr_timeout_value;
   FETCH csr_timeout_value INTO l_appr_timeout_value;
   RETURN (l_appr_timeout_value);
   CLOSE csr_timeout_value;
END approver_timeout_value;


--
-- ----------------------------------------------------------------------------
-- |-------------------------< preparer_timeout_value >-----------------------|
-- ----------------------------------------------------------------------------

FUNCTION preparer_timeout_value (p_approval_style_id IN NUMBER)
   RETURN NUMBER
IS
   l_preparer_timeout_value   hxc_app_comp_notifications.notification_timeout_value%TYPE;

   CURSOR csr_timeout_value
   IS
      SELECT hacn.notification_timeout_value
        FROM hxc_approval_styles has,
             hxc_approval_comps hac,
             hxc_app_comp_notifications hacn,
             hxc_app_comp_notif_usages hacnu
       WHERE has.approval_style_id = p_approval_style_id
         AND has.approval_style_id = hac.approval_style_id
         AND hac.approval_comp_id = hacnu.approval_comp_id
         AND hac.object_version_number = hacnu.approval_comp_ovn
         AND hacnu.comp_notification_id = hacn.comp_notification_id
         AND hacnu.comp_notification_ovn = hacn.object_version_number
         AND hacn.notification_action_code = 'REQUEST-APPROVAL-RESEND'
         AND hacn.notification_recipient_code = 'PREPARER'
         AND hacnu.enabled_flag = 'Y';
BEGIN
   OPEN csr_timeout_value;
   FETCH csr_timeout_value INTO l_preparer_timeout_value;
   RETURN (l_preparer_timeout_value);
   CLOSE csr_timeout_value;
END preparer_timeout_value;


--
-- ----------------------------------------------------------------------------
-- |----------------------------< admin_timeout_value >-----------------------|
-- ----------------------------------------------------------------------------

FUNCTION admin_timeout_value (p_approval_style_id IN NUMBER)
   RETURN NUMBER
IS
   l_admin_timeout_value   hxc_app_comp_notifications.notification_timeout_value%TYPE;

   CURSOR csr_timeout_value
   IS
      SELECT hacn.notification_timeout_value
        FROM hxc_approval_styles has,
             hxc_approval_comps hac,
             hxc_app_comp_notifications hacn,
             hxc_app_comp_notif_usages hacnu
       WHERE has.approval_style_id = p_approval_style_id
         AND has.approval_style_id = hac.approval_style_id
         AND hac.approval_comp_id = hacnu.approval_comp_id
         AND hac.object_version_number = hacnu.approval_comp_ovn
         AND hacnu.comp_notification_id = hacn.comp_notification_id
         AND hacnu.comp_notification_ovn = hacn.object_version_number
         AND hacn.notification_action_code = 'REQUEST-APPROVAL-RESEND'
         AND hacn.notification_recipient_code = 'ADMIN'
         AND hacnu.enabled_flag = 'Y';
BEGIN
   OPEN csr_timeout_value;
   FETCH csr_timeout_value INTO l_admin_timeout_value;
   RETURN (l_admin_timeout_value);
   CLOSE csr_timeout_value;
END admin_timeout_value;

--
-- ----------------------------------------------------------------------------
-- |------------------------< notify_sup_for_approval >-----------------------|
-- ----------------------------------------------------------------------------

FUNCTION notify_sup_for_approval (p_approval_style_id IN NUMBER)
   RETURN VARCHAR2
IS
   l_approval   NUMBER (3)   := 0;
   l_notifs     VARCHAR2 (1);

   CURSOR csr_sup_for_approval
   IS
      SELECT COUNT (1)
        FROM hxc_approval_styles has,
             hxc_approval_comps hac,
             hxc_app_comp_notifications hacn,
             hxc_app_comp_notif_usages hacnu
       WHERE has.approval_style_id = p_approval_style_id
         AND has.approval_style_id = hac.approval_style_id
         AND hac.approval_comp_id = hacnu.approval_comp_id
         AND hac.object_version_number = hacnu.approval_comp_ovn
         AND hacnu.comp_notification_id = hacn.comp_notification_id
         AND hacnu.comp_notification_ovn = hacn.object_version_number
         AND hacn.notification_action_code = 'REQUEST-APPROVAL'
         AND hacn.notification_recipient_code = 'SUPERVISOR'
         AND hacnu.enabled_flag = 'Y';
BEGIN
   OPEN csr_sup_for_approval;
   FETCH csr_sup_for_approval INTO l_approval;

   IF l_approval <> 0
   THEN
      l_notifs := 'Y';
   ELSE
      l_notifs := 'N';
   END IF;

   CLOSE csr_sup_for_approval;
   RETURN (l_notifs);
END notify_sup_for_approval;
--
-- ----------------------------------------------------------------------------
-- |------------------------<notify_worker_submission >-----------------------|
-- ----------------------------------------------------------------------------

FUNCTION notify_worker_submission (p_approval_style_id IN NUMBER)
   RETURN VARCHAR2
IS
   l_approval   NUMBER (3)   := 0;
   l_notifs     VARCHAR2 (1);

   CURSOR csr_worker_sumission
   IS
      SELECT COUNT (1)
        FROM hxc_approval_styles has,
             hxc_approval_comps hac,
             hxc_app_comp_notifications hacn,
             hxc_app_comp_notif_usages hacnu
       WHERE has.approval_style_id = p_approval_style_id
         AND has.approval_style_id = hac.approval_style_id
         AND hac.approval_comp_id = hacnu.approval_comp_id
         AND hac.object_version_number = hacnu.approval_comp_ovn
         AND hacnu.comp_notification_id = hacn.comp_notification_id
         AND hacnu.comp_notification_ovn = hacn.object_version_number
         AND hacn.notification_action_code = 'SUBMISSION'
         AND hacn.notification_recipient_code = 'WORKER'
         AND hacnu.enabled_flag = 'Y';
BEGIN
   OPEN csr_worker_sumission;
   FETCH csr_worker_sumission INTO l_approval;

   IF l_approval <> 0
   THEN
      l_notifs := 'Y';
   ELSE
      l_notifs := 'N';
   END IF;

   CLOSE csr_worker_sumission;
   RETURN (l_notifs);
END notify_worker_submission;


--
-- ----------------------------------------------------------------------------
-- |---------------------< notify_worker_auto_approve >-----------------------|
-- ----------------------------------------------------------------------------

FUNCTION notify_worker_auto_approve (p_approval_style_id IN NUMBER)
   RETURN VARCHAR2
IS
   l_approval   NUMBER (3)   := 0;
   l_notifs     VARCHAR2 (1);

   CURSOR csr_worker_auto_approve
   IS
      SELECT COUNT (1)
        FROM hxc_approval_styles has,
             hxc_approval_comps hac,
             hxc_app_comp_notifications hacn,
             hxc_app_comp_notif_usages hacnu
       WHERE has.approval_style_id = p_approval_style_id
         AND has.approval_style_id = hac.approval_style_id
         AND hac.approval_comp_id = hacnu.approval_comp_id
         AND hac.object_version_number = hacnu.approval_comp_ovn
         AND hacnu.comp_notification_id = hacn.comp_notification_id
         AND hacn.notification_action_code = 'AUTO-APPROVE'
         AND hacn.notification_recipient_code = 'WORKER'
         AND hacnu.enabled_flag = 'Y';
BEGIN
   OPEN csr_worker_auto_approve;
   FETCH csr_worker_auto_approve INTO l_approval;

   IF l_approval <> 0
   THEN
      l_notifs := 'Y';
   ELSE
      l_notifs := 'N';
   END IF;

   CLOSE csr_worker_auto_approve;
   RETURN (l_notifs);
END notify_worker_auto_approve;



--
-- ----------------------------------------------------------------------------
-- |------------------------< notify_preparer_approve >-----------------------|
-- ----------------------------------------------------------------------------

FUNCTION notify_preparer_approve (p_approval_style_id IN NUMBER)
   RETURN VARCHAR2
IS
   l_approval   NUMBER (3)   := 0;
   l_notifs     VARCHAR2 (1);

   CURSOR csr_preparer_approve
   IS
      SELECT COUNT (1)
        FROM hxc_approval_styles has,
             hxc_approval_comps hac,
             hxc_app_comp_notifications hacn,
             hxc_app_comp_notif_usages hacnu
       WHERE has.approval_style_id = p_approval_style_id
         AND has.approval_style_id = hac.approval_style_id
         AND hac.approval_comp_id = hacnu.approval_comp_id
         AND hac.object_version_number = hacnu.approval_comp_ovn
         AND hacnu.comp_notification_id = hacn.comp_notification_id
         AND hacn.notification_action_code = 'APPROVED'
         AND hacn.notification_recipient_code = 'PREPARER'
         AND hacnu.enabled_flag = 'Y';
BEGIN
   OPEN csr_preparer_approve;
   FETCH csr_preparer_approve INTO l_approval;

   IF l_approval <> 0
   THEN
      l_notifs := 'Y';
   ELSE
      l_notifs := 'N';
   END IF;

   CLOSE csr_preparer_approve;
   RETURN (l_notifs);
END notify_preparer_approve;



--
-- ----------------------------------------------------------------------------
-- |-------------------------< notify_preparer_reject >-----------------------|
-- ----------------------------------------------------------------------------

FUNCTION notify_preparer_reject (p_approval_style_id IN NUMBER)
   RETURN VARCHAR2
IS
   l_approval   NUMBER (1)   := 0;
   l_notifs     VARCHAR2 (1);

   CURSOR csr_preparer_reject
   IS
      SELECT COUNT (1)
        FROM hxc_approval_styles has,
             hxc_approval_comps hac,
             hxc_app_comp_notifications hacn,
             hxc_app_comp_notif_usages hacnu
       WHERE has.approval_style_id = p_approval_style_id
         AND has.approval_style_id = hac.approval_style_id
         AND hac.approval_comp_id = hacnu.approval_comp_id
         AND hac.object_version_number = hacnu.approval_comp_ovn
         AND hacnu.comp_notification_id = hacn.comp_notification_id
         AND hacn.notification_action_code = 'REJECTED'
         AND hacn.notification_recipient_code = 'PREPARER'
         AND hacnu.enabled_flag = 'Y';
BEGIN
   OPEN csr_preparer_reject;
   FETCH csr_preparer_reject INTO l_approval;

   IF l_approval <> 0
   THEN
      l_notifs := 'Y';
   ELSE
      l_notifs := 'N';
   END IF;

   CLOSE csr_preparer_reject;
   RETURN (l_notifs);
END notify_preparer_reject;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< notify_preparer_transfer >-----------------------|
-- ----------------------------------------------------------------------------


FUNCTION notify_preparer_transfer (p_approval_style_id IN NUMBER)
   RETURN VARCHAR2
IS
   l_approval   NUMBER (13)  := 0;
   l_notifs     VARCHAR2 (1);

   CURSOR csr_preparer_transfer
   IS
      SELECT COUNT (1)
        FROM hxc_approval_styles has,
             hxc_approval_comps hac,
             hxc_app_comp_notifications hacn,
             hxc_app_comp_notif_usages hacnu
       WHERE has.approval_style_id = p_approval_style_id
         AND has.approval_style_id = hac.approval_style_id
         AND hac.approval_comp_id = hacnu.approval_comp_id
         AND hac.object_version_number = hacnu.approval_comp_ovn
         AND hacnu.comp_notification_id = hacn.comp_notification_id
         AND hacn.notification_action_code = 'TRANSFER'
         AND hacn.notification_recipient_code = 'PREPARER'
         AND hacnu.enabled_flag = 'Y';
BEGIN
   OPEN csr_preparer_transfer;
   FETCH csr_preparer_transfer INTO l_approval;

   IF l_approval <> 0
   THEN
      l_notifs := 'Y';
   ELSE
      l_notifs := 'N';
   END IF;

   CLOSE csr_preparer_transfer;
   RETURN (l_notifs);
END notify_preparer_transfer;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_notification_records>------------------|
-- ----------------------------------------------------------------------------
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
 ) is
 l_comp_notification_id      hxc_app_comp_notifications_api.id_type;
 l_object_version_number     hxc_app_comp_notifications_api.ovn_type;
 begin



 If p_timeouts_enabled ='Y'
 then
 hxc_app_comp_notifications_api.create_app_comp_notification
   (
   p_notification_number_retries  => p_number_retries
  ,p_notification_timeout_value   => p_approver_timeout
  ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
  ,p_notification_recipient_code  => 'APPROVER'
  ,p_approval_style_name          => p_approval_style_name
  ,p_time_recipient_name          => null
  ,p_approval_component_id        => null
  ,p_comp_notification_id         => l_comp_notification_id
  ,p_object_version_number        => l_object_version_number
   );

 hxc_app_comp_notifications_api.create_app_comp_notification
    (
    p_notification_number_retries  => p_number_retries
   ,p_notification_timeout_value   => p_preparer_timeout
   ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
   ,p_notification_recipient_code  => 'PREPARER'
   ,p_approval_style_name          => p_approval_style_name
   ,p_time_recipient_name          => null
   ,p_approval_component_id        => null
   ,p_comp_notification_id         => l_comp_notification_id
   ,p_object_version_number        => l_object_version_number
   ) ;


 hxc_app_comp_notifications_api.create_app_comp_notification
      (
      p_notification_number_retries  => p_number_retries
     ,p_notification_timeout_value   => p_admin_timeout
     ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
     ,p_notification_recipient_code  => 'ADMIN'
     ,p_approval_style_name          => p_approval_style_name
     ,p_time_recipient_name          => null
     ,p_approval_component_id        => null
     ,p_comp_notification_id         => l_comp_notification_id
     ,p_object_version_number        => l_object_version_number
   ) ;

 end if;

If p_notify_supervisor = 'Y'
then
hxc_app_comp_notifications_api.create_app_comp_notification
   (
    p_notification_number_retries  => 0
   ,p_notification_timeout_value   => 0
   ,p_notification_action_code     => 'REQUEST-APPROVAL'
   ,p_notification_recipient_code  => 'SUPERVISOR'
   ,p_approval_style_name          => p_approval_style_name
   ,p_time_recipient_name          => null
   ,p_approval_component_id        => null
   ,p_comp_notification_id         => l_comp_notification_id
   ,p_object_version_number        => l_object_version_number
   );
end if;

If p_notify_worker_on_submit = 'Y'
then
hxc_app_comp_notifications_api.create_app_comp_notification
   (
    p_notification_number_retries  => 0
   ,p_notification_timeout_value   => 0
   ,p_notification_action_code     => 'SUBMISSION'
   ,p_notification_recipient_code  => 'WORKER'
   ,p_approval_style_name          => p_approval_style_name
   ,p_time_recipient_name          => null
   ,p_approval_component_id        => null
   ,p_comp_notification_id         => l_comp_notification_id
   ,p_object_version_number        => l_object_version_number
   );
end if;

If p_notify_worker_on_aa = 'Y'
then
hxc_app_comp_notifications_api.create_app_comp_notification
   (
    p_notification_number_retries  => 0
   ,p_notification_timeout_value   => 0
   ,p_notification_action_code     => 'AUTO-APPROVE'
   ,p_notification_recipient_code  => 'WORKER'
   ,p_approval_style_name          => p_approval_style_name
   ,p_time_recipient_name          => null
   ,p_approval_component_id        => null
   ,p_comp_notification_id         => l_comp_notification_id
   ,p_object_version_number        => l_object_version_number
   ) ;
end if;

If p_notify_preparer_approved = 'Y'
then
hxc_app_comp_notifications_api.create_app_comp_notification
   (
    p_notification_number_retries  => 0
   ,p_notification_timeout_value   => 0
   ,p_notification_action_code     => 'APPROVED'
   ,p_notification_recipient_code  => 'PREPARER'
   ,p_approval_style_name          => p_approval_style_name
   ,p_time_recipient_name          => null
   ,p_approval_component_id        => null
   ,p_comp_notification_id         => l_comp_notification_id
   ,p_object_version_number        => l_object_version_number
   ) ;
end if;

If p_notify_preparer_rejected = 'Y'
then
hxc_app_comp_notifications_api.create_app_comp_notification
   (
    p_notification_number_retries  => 0
   ,p_notification_timeout_value   => 0
   ,p_notification_action_code     => 'REJECTED'
   ,p_notification_recipient_code  => 'PREPARER'
   ,p_approval_style_name          => p_approval_style_name
   ,p_time_recipient_name          => null
   ,p_approval_component_id        => null
   ,p_comp_notification_id         => l_comp_notification_id
   ,p_object_version_number        => l_object_version_number
   ) ;
end if;

If p_notify_preparer_transfer = 'Y' then

hxc_app_comp_notifications_api.create_app_comp_notification
   (
    p_notification_number_retries  => 0
   ,p_notification_timeout_value   => 0
   ,p_notification_action_code     => 'TRANSFER'
   ,p_notification_recipient_code  => 'PREPARER'
   ,p_approval_style_name          => p_approval_style_name
   ,p_time_recipient_name          => null
   ,p_approval_component_id        => null
   ,p_comp_notification_id         => l_comp_notification_id
   ,p_object_version_number        => l_object_version_number
   ) ;
end if;


end create_notification_records;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_notification_records>------------------|
-- ----------------------------------------------------------------------------
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
 ) is
 l_comp_notification_id   hxc_app_comp_notifications.comp_notification_id%type;
 l_object_version_number hxc_app_comp_notifications.object_version_number%type;
 l_comp_notification_id_table      hxc_app_comp_notifications_api.id_type;
 l_object_version_number_table     hxc_app_comp_notifications_api.ovn_type;
 l_count                     number(9) :=0;
 l_comp_notif_id_exist    hxc_app_comp_notifications.comp_notification_id%type;
 l_ovn_exist             hxc_app_comp_notifications.object_version_number%type;
 l_approval_comp_id          hxc_approval_comps.approval_comp_id%type;
 l_approval_comp_ovn         hxc_approval_comps.object_version_number%type;
 l_old_notif_rec             hxc_notification_helper.g_rec_notif;
 l_comp_notification_ovn     number(9);

 --
 --Cursor to get the current status of the notifications
 --

 cursor csr_notif_record(p_approval_style_id number) is
 select
 approval_style_id,
 timeouts_enabled,
 number_retries,
 approver_timeout,
 preparer_timeout,
 admin_timeout,
 notify_supervisor,
 notify_worker_on_submit,
 notify_worker_on_aa,
 notify_preparer_approved,
 notify_preparer_rejected,
 notify_preparer_transfer
 from hxc_approval_styles_v
 where
 approval_style_id=p_approval_style_id;


 --Cursor to find the entry in the notifications table linked to the given approval
 --style having the specified action code and recipient code.

 cursor csr_notif_id
 (p_approval_style_id in number
 ,p_notification_action_code in varchar2
 ,p_notification_recipient_code in varchar2) is
 select hacn.comp_notification_id,hacn.object_version_number
 from
 hxc_approval_styles has,
 hxc_approval_comps hac,
 hxc_app_comp_notifications hacn,
 hxc_app_comp_notif_usages hacnu
 where
 has.approval_style_id = p_approval_style_id and
 has.approval_style_id = hac.approval_style_id and
 hac.approval_comp_id=hacnu.approval_comp_id and
 hac.object_version_number=hacnu.approval_comp_ovn and
 hacnu.comp_notification_id=hacn.comp_notification_id and
 hacnu.comp_notification_ovn=hacn.object_version_number and
 hacn.notification_action_code = p_notification_action_code and
 hacn.notification_recipient_code=p_notification_recipient_code;



 --
 -- Cursor to check if the notification record with the new values already exists
 --

 cursor csr_notif_already_exists
  (p_notification_number_retries in number, p_notification_timeout_value in number, p_notification_recipient_code in varchar2) is
   select  hacn.comp_notification_id, hacn.object_version_number
   from hxc_app_comp_notifications hacn where
   notification_number_retries=p_notification_number_retries and
   notification_timeout_value=p_notification_timeout_value and
   notification_action_code='REQUEST-APPROVAL-RESEND' and
   notification_recipient_code=p_notification_recipient_code and
   object_version_number=(select max(object_version_number)
                          from hxc_app_comp_notifications
                          where comp_notification_id=hacn.comp_notification_id);

 --
 -- Cursor to check if the notification record being updated is being used by other
 -- aproval styles as well.
 --




 cursor csr_chk_notif_used_byothers
   (p_approval_style_id in number
   ,p_comp_notification_id in number
   ,p_object_version_number in number)
   is
 select count(1) from
 hxc_approval_comps hac,
 hxc_app_comp_notifications hacn,
 hxc_app_comp_notif_usages hacnu
 where
 hac.approval_comp_id not in (select hac.approval_comp_id
                        from hxc_approval_comps hac
                        where
                        approval_style_id = p_approval_style_id) and
 hac.approval_comp_id=hacnu.approval_comp_id and
 hacn.comp_notification_id=hacnu.comp_notification_id and
 hacn.object_version_number=hacnu.comp_notification_ovn and
 hacnu.comp_notification_id=p_comp_notification_id and
 hacnu.comp_notification_ovn=p_object_version_number;


cursor csr_approval_comp_id(p_approval_style in varchar2)
is select hac.approval_comp_id,hac.object_version_number
from
hxc_approval_styles has,
hxc_approval_comps hac
where
has.name=p_approval_style and
has.approval_style_id = hac.approval_style_id and
hac.object_version_number = (SELECT MAX (object_version_number)
                                      FROM hxc_approval_comps
                                     WHERE approval_comp_id =hac.approval_comp_id);

 cursor csr_del_disabled_usages(p_approval_style_id in number)
 is select hacnu.approval_comp_id,hacnu.approval_comp_ovn,
 hacnu.comp_notification_id,hacnu.comp_notification_ovn from
 hxc_app_comp_notif_usages hacnu,
 hxc_approval_styles has,
 hxc_approval_comps hac,
 hxc_app_comp_notifications hacn
 where
 has.approval_style_id=p_approval_style_id and
 has.approval_style_id=hac.approval_style_id and
 hac.approval_comp_id=hacnu.approval_comp_id and
 hac.object_version_number=hacnu.approval_comp_ovn and
 hacnu.comp_notification_id=hacn.comp_notification_id and
 hacn.notification_action_code='REQUEST-APPROVAL-RESEND' and
 hacnu.enabled_flag='N';

 begin

 Open csr_notif_record(p_approval_style_id);
 Fetch csr_notif_record Into l_old_notif_rec;



 if p_timeouts_enabled ='N' and l_old_notif_rec.timeouts_enabled='Y'
 then
 hxc_app_comp_notifications_api.disable_timeout_notifications
   (
    p_approval_style_name          => p_approval_style_name
   ) ;

 elsif p_timeouts_enabled ='Y' and l_old_notif_rec.timeouts_enabled='N'
 then
 ---if the notification usages already exists we have to delete those
 open csr_del_disabled_usages(p_approval_style_id);
 loop
   fetch csr_del_disabled_usages into
      l_approval_comp_id,l_approval_comp_ovn,
      l_comp_notification_id,l_comp_notification_ovn;
   exit when csr_del_disabled_usages%notfound;
   delete
   from hxc_app_comp_notif_usages where
   approval_comp_id=l_approval_comp_id and
   approval_comp_ovn=l_approval_comp_ovn and
   comp_notification_id=l_comp_notification_id and
   comp_notification_ovn=l_comp_notification_ovn;
 end loop;
 close csr_del_disabled_usages;

 hxc_app_comp_notifications_api.create_app_comp_notification
     (
     p_notification_number_retries  => p_number_retries
    ,p_notification_timeout_value   => p_approver_timeout
    ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
    ,p_notification_recipient_code  => 'APPROVER'
    ,p_approval_style_name          => p_approval_style_name
    ,p_time_recipient_name          => null
    ,p_approval_component_id        => null
    ,p_comp_notification_id         => l_comp_notification_id_table
    ,p_object_version_number        => l_object_version_number_table
   );
 hxc_app_comp_notifications_api.create_app_comp_notification
    (
    p_notification_number_retries  => p_number_retries
   ,p_notification_timeout_value   => p_preparer_timeout
   ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
   ,p_notification_recipient_code  => 'PREPARER'
   ,p_approval_style_name          => p_approval_style_name
   ,p_time_recipient_name          => null
   ,p_approval_component_id        => null
   ,p_comp_notification_id         => l_comp_notification_id_table
   ,p_object_version_number        => l_object_version_number_table
   ) ;


 hxc_app_comp_notifications_api.create_app_comp_notification
      (
      p_notification_number_retries  => p_number_retries
     ,p_notification_timeout_value   => p_admin_timeout
     ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
     ,p_notification_recipient_code  => 'ADMIN'
     ,p_approval_style_name          => p_approval_style_name
     ,p_time_recipient_name          => null
     ,p_approval_component_id        => null
     ,p_comp_notification_id         => l_comp_notification_id_table
     ,p_object_version_number        => l_object_version_number_table
   ) ;

 elsif p_timeouts_enabled ='Y' and l_old_notif_rec.timeouts_enabled='Y'
 then
   if p_number_retries <> l_old_notif_rec.number_retries
   then
  ---
  --- For APPROVER
  ---

     open csr_notif_id(p_approval_style_id,'REQUEST-APPROVAL-RESEND','APPROVER');
     fetch csr_notif_id into l_comp_notification_id, l_object_version_number;
     close csr_notif_id;

     open csr_chk_notif_used_byothers(p_approval_style_id,
                                        l_comp_notification_id,
                                        l_object_version_number);
     fetch csr_chk_notif_used_byothers into l_count;
     close csr_chk_notif_used_byothers;

     open csr_notif_already_exists(p_number_retries,p_approver_timeout,'APPROVER');
     fetch csr_notif_already_exists into l_comp_notif_id_exist,l_ovn_exist;

     if csr_notif_already_exists%found
     then
       open csr_approval_comp_id(p_approval_style_name);
       loop
       fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
       exit when csr_approval_comp_id%notfound;

       update hxc_app_comp_notif_usages
       set
       comp_notification_id  = l_comp_notif_id_exist,
       comp_notification_ovn = l_ovn_exist
       where
       approval_comp_id = l_approval_comp_id and
       approval_comp_ovn= l_approval_comp_ovn and
       comp_notification_id=l_comp_notification_id and
       comp_notification_ovn=l_object_version_number;
       end loop;
       close csr_approval_comp_id;

     else
      if(l_count=0)  --- enters if not used
      then
         hxc_app_comp_notifications_api.update_app_comp_notification
         (
            p_comp_notification_id         => l_comp_notification_id
           ,p_object_version_number        => l_object_version_number
           ,p_notification_number_retries  => p_number_retries
           ,p_notification_timeout_value   => p_approver_timeout
         );

      else
         hxc_app_comp_notifications_api.create_app_comp_notification
	     (
	     p_notification_number_retries  => p_number_retries
	    ,p_notification_timeout_value   => p_approver_timeout
	    ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
	    ,p_notification_recipient_code  => 'APPROVER'
	    ,p_approval_style_name          => p_approval_style_name
	    ,p_time_recipient_name          => null
	    ,p_approval_component_id        => null
	    ,p_comp_notification_id         => l_comp_notification_id_table
	    ,p_object_version_number        => l_object_version_number_table
	   );
          open csr_approval_comp_id(p_approval_style_name);
          loop
          fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
          exit when csr_approval_comp_id%notfound;
          delete from hxc_app_comp_notif_usages
          where
          approval_comp_id  =l_approval_comp_id and
          approval_comp_ovn =l_approval_comp_ovn and
          comp_notification_id=l_comp_notification_id and
          comp_notification_ovn = l_object_version_number;
          end loop;
          close csr_approval_comp_id;
      end if;
     end if;
     close csr_notif_already_exists;
 --
 -- For Preparer
 --

     open csr_notif_id(p_approval_style_id,'REQUEST-APPROVAL-RESEND','PREPARER');
     fetch csr_notif_id into l_comp_notification_id, l_object_version_number;
     close csr_notif_id;
     open csr_chk_notif_used_byothers(p_approval_style_id,
                                        l_comp_notification_id,
                                        l_object_version_number);
     fetch csr_chk_notif_used_byothers into l_count;
     close csr_chk_notif_used_byothers;

     open csr_notif_already_exists(p_number_retries,p_preparer_timeout,'PREPARER');
     fetch csr_notif_already_exists into l_comp_notif_id_exist,l_ovn_exist;

     if csr_notif_already_exists%found
     then

       open csr_approval_comp_id(p_approval_style_name);
       loop
       fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
       exit when csr_approval_comp_id%notfound;

       update hxc_app_comp_notif_usages
       set
       comp_notification_id  = l_comp_notif_id_exist,
       comp_notification_ovn = l_ovn_exist
       where
       approval_comp_id = l_approval_comp_id and
       approval_comp_ovn= l_approval_comp_ovn and
       comp_notification_id=l_comp_notification_id and
       comp_notification_ovn=l_object_version_number;
       end loop;
       close csr_approval_comp_id;

     else
      if(l_count=0)  --- enters if not used
      then


         hxc_app_comp_notifications_api.update_app_comp_notification
         (
            p_comp_notification_id         => l_comp_notification_id
           ,p_object_version_number        => l_object_version_number
           ,p_notification_number_retries  => p_number_retries
           ,p_notification_timeout_value   => p_preparer_timeout
         );


      else

         hxc_app_comp_notifications_api.create_app_comp_notification
	     (
	     p_notification_number_retries  => p_number_retries
	    ,p_notification_timeout_value   => p_preparer_timeout
	    ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
	    ,p_notification_recipient_code  => 'PREPARER'
	    ,p_approval_style_name          => p_approval_style_name
	    ,p_time_recipient_name          => null
	    ,p_approval_component_id        => null
	    ,p_comp_notification_id         => l_comp_notification_id_table
	    ,p_object_version_number        => l_object_version_number_table
	   );
          open csr_approval_comp_id(p_approval_style_name);
          loop
          fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
          exit when csr_approval_comp_id%notfound;
          delete from hxc_app_comp_notif_usages
          where
          approval_comp_id  =l_approval_comp_id and
          approval_comp_ovn =l_approval_comp_ovn and
          comp_notification_id=l_comp_notification_id and
          comp_notification_ovn = l_object_version_number;
          end loop;
          close csr_approval_comp_id;
      end if;
     end if;
     close csr_notif_already_exists;
---
--- For ADMIN
---

     open csr_notif_id(p_approval_style_id,'REQUEST-APPROVAL-RESEND','ADMIN');
     fetch csr_notif_id into l_comp_notification_id, l_object_version_number;
     close csr_notif_id;
     open csr_chk_notif_used_byothers(p_approval_style_id,
                                        l_comp_notification_id,
                                        l_object_version_number);
     fetch csr_chk_notif_used_byothers into l_count;
     close csr_chk_notif_used_byothers;

     open csr_notif_already_exists(p_number_retries,p_admin_timeout,'ADMIN');
     fetch csr_notif_already_exists into l_comp_notif_id_exist,l_ovn_exist;

     if csr_notif_already_exists%found
     then

       open csr_approval_comp_id(p_approval_style_name);
       loop
       fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
       exit when csr_approval_comp_id%notfound;

       update hxc_app_comp_notif_usages
       set
       comp_notification_id  = l_comp_notif_id_exist,
       comp_notification_ovn = l_ovn_exist
       where
       approval_comp_id = l_approval_comp_id and
       approval_comp_ovn= l_approval_comp_ovn and
       comp_notification_id=l_comp_notification_id and
       comp_notification_ovn=l_object_version_number;
       end loop;
       close csr_approval_comp_id;

     else
      if(l_count=0)  --- enters if not used
      then


         hxc_app_comp_notifications_api.update_app_comp_notification
         (
            p_comp_notification_id         => l_comp_notification_id
           ,p_object_version_number        => l_object_version_number
           ,p_notification_number_retries  => p_number_retries
           ,p_notification_timeout_value   => p_admin_timeout
         );


      else

         hxc_app_comp_notifications_api.create_app_comp_notification
	     (
	     p_notification_number_retries  => p_number_retries
	    ,p_notification_timeout_value   => p_admin_timeout
	    ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
	    ,p_notification_recipient_code  => 'ADMIN'
	    ,p_approval_style_name          => p_approval_style_name
	    ,p_time_recipient_name          => null
	    ,p_approval_component_id        => null
	    ,p_comp_notification_id         => l_comp_notification_id_table
	    ,p_object_version_number        => l_object_version_number_table
	   );
          open csr_approval_comp_id(p_approval_style_name);
          loop
          fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
          exit when csr_approval_comp_id%notfound;
          delete from hxc_app_comp_notif_usages
          where
          approval_comp_id  =l_approval_comp_id and
          approval_comp_ovn =l_approval_comp_ovn and
          comp_notification_id=l_comp_notification_id and
          comp_notification_ovn = l_object_version_number;
          end loop;
          close csr_approval_comp_id;
      end if;
     end if;
     close csr_notif_already_exists;
   else
   --- If there is no change in number of retries
   ---
   --- For Approver
   ---
   if (p_approver_timeout <> l_old_notif_rec.approver_timeout)
   then
     open csr_notif_id(p_approval_style_id,'REQUEST-APPROVAL-RESEND','APPROVER');
     fetch csr_notif_id into l_comp_notification_id, l_object_version_number;
     close csr_notif_id;
     open csr_chk_notif_used_byothers(p_approval_style_id,
                                        l_comp_notification_id,
                                        l_object_version_number);
     fetch csr_chk_notif_used_byothers into l_count;
     close csr_chk_notif_used_byothers;

     open csr_notif_already_exists(p_number_retries,p_approver_timeout,'APPROVER');
     fetch csr_notif_already_exists into l_comp_notif_id_exist,l_ovn_exist;

     if csr_notif_already_exists%found
     then
       open csr_approval_comp_id(p_approval_style_name);
       loop
       fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
       exit when csr_approval_comp_id%notfound;

       update hxc_app_comp_notif_usages
       set
       comp_notification_id  = l_comp_notif_id_exist,
       comp_notification_ovn = l_ovn_exist
       where
       approval_comp_id = l_approval_comp_id and
       approval_comp_ovn= l_approval_comp_ovn and
       comp_notification_id=l_comp_notification_id and
       comp_notification_ovn=l_object_version_number;
       end loop;
       close csr_approval_comp_id;

     else
      if(l_count=0)  --- enters if not used
      then


         hxc_app_comp_notifications_api.update_app_comp_notification
         (
            p_comp_notification_id         => l_comp_notification_id
           ,p_object_version_number        => l_object_version_number
           ,p_notification_timeout_value   => p_approver_timeout
         );


      else

         hxc_app_comp_notifications_api.create_app_comp_notification
	     (
	     p_notification_number_retries  => p_number_retries
	    ,p_notification_timeout_value   => p_approver_timeout
	    ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
	    ,p_notification_recipient_code  => 'APPROVER'
	    ,p_approval_style_name          => p_approval_style_name
	    ,p_time_recipient_name          => null
	    ,p_approval_component_id        => null
	    ,p_comp_notification_id         => l_comp_notification_id_table
	    ,p_object_version_number        => l_object_version_number_table
	   );
          open csr_approval_comp_id(p_approval_style_name);
          loop
          fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
          exit when csr_approval_comp_id%notfound;
          delete from hxc_app_comp_notif_usages
          where
          approval_comp_id  =l_approval_comp_id and
          approval_comp_ovn =l_approval_comp_ovn and
          comp_notification_id=l_comp_notification_id and
          comp_notification_ovn = l_object_version_number;
          end loop;
          close csr_approval_comp_id;
      end if;
     end if;
     close csr_notif_already_exists;

   end if;
   ---
   --- For Preparer
   ---
   if (p_preparer_timeout <> l_old_notif_rec.preparer_timeout)
   then
     open csr_notif_id(p_approval_style_id,'REQUEST-APPROVAL-RESEND','PREPARER');
     fetch csr_notif_id into l_comp_notification_id, l_object_version_number;
     close csr_notif_id;
     open csr_chk_notif_used_byothers(p_approval_style_id,
                                        l_comp_notification_id,
                                        l_object_version_number);
     fetch csr_chk_notif_used_byothers into l_count;
     close csr_chk_notif_used_byothers;

     open csr_notif_already_exists(p_number_retries,p_preparer_timeout,'PREPARER');
     fetch csr_notif_already_exists into l_comp_notif_id_exist,l_ovn_exist;

     if csr_notif_already_exists%found
     then
       open csr_approval_comp_id(p_approval_style_name);
       loop
       fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
       exit when csr_approval_comp_id%notfound;

       update hxc_app_comp_notif_usages
       set
       comp_notification_id  = l_comp_notif_id_exist,
       comp_notification_ovn = l_ovn_exist
       where
       approval_comp_id = l_approval_comp_id and
       approval_comp_ovn= l_approval_comp_ovn and
       comp_notification_id=l_comp_notification_id and
       comp_notification_ovn=l_object_version_number;
       end loop;
       close csr_approval_comp_id;

     else
      if(l_count=0)  --- enters if not used
      then


         hxc_app_comp_notifications_api.update_app_comp_notification
         (
            p_comp_notification_id         => l_comp_notification_id
           ,p_object_version_number        => l_object_version_number
           ,p_notification_timeout_value   => p_preparer_timeout
         );


      else

         hxc_app_comp_notifications_api.create_app_comp_notification
	     (
	     p_notification_number_retries  => p_number_retries
	    ,p_notification_timeout_value   => p_preparer_timeout
	    ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
	    ,p_notification_recipient_code  => 'PREPARER'
	    ,p_approval_style_name          => p_approval_style_name
	    ,p_time_recipient_name          => null
	    ,p_approval_component_id        => null
	    ,p_comp_notification_id         => l_comp_notification_id_table
	    ,p_object_version_number        => l_object_version_number_table
	   );
          open csr_approval_comp_id(p_approval_style_name);
          loop
          fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
          exit when csr_approval_comp_id%notfound;
          delete from hxc_app_comp_notif_usages
          where
          approval_comp_id  =l_approval_comp_id and
          approval_comp_ovn =l_approval_comp_ovn and
          comp_notification_id=l_comp_notification_id and
          comp_notification_ovn = l_object_version_number;
          end loop;
          close csr_approval_comp_id;
      end if;
     end if;
     close csr_notif_already_exists;

   end if;
   ---
   --- For ADMIN
   ---

   if (p_admin_timeout <> l_old_notif_rec.admin_timeout)
   then
     open csr_notif_id(p_approval_style_id,'REQUEST-APPROVAL-RESEND','ADMIN');
     fetch csr_notif_id into l_comp_notification_id, l_object_version_number;
     close csr_notif_id;
     open csr_chk_notif_used_byothers(p_approval_style_id,
                                        l_comp_notification_id,
                                        l_object_version_number);
     fetch csr_chk_notif_used_byothers into l_count;
     close csr_chk_notif_used_byothers;

     open csr_notif_already_exists(p_number_retries,p_admin_timeout,'ADMIN');
     fetch csr_notif_already_exists into l_comp_notif_id_exist,l_ovn_exist;

     if csr_notif_already_exists%found
     then
       open csr_approval_comp_id(p_approval_style_name);
       loop
       fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
       exit when csr_approval_comp_id%notfound;

       update hxc_app_comp_notif_usages
       set
       comp_notification_id  = l_comp_notif_id_exist,
       comp_notification_ovn = l_ovn_exist
       where
       approval_comp_id = l_approval_comp_id and
       approval_comp_ovn= l_approval_comp_ovn and
       comp_notification_id=l_comp_notification_id and
       comp_notification_ovn=l_object_version_number;
       end loop;
       close csr_approval_comp_id;
     else
      if(l_count=0)  --- enters if not used
      then


         hxc_app_comp_notifications_api.update_app_comp_notification
         (
            p_comp_notification_id         => l_comp_notification_id
           ,p_object_version_number        => l_object_version_number
           ,p_notification_timeout_value   => p_admin_timeout
         );


      else

         hxc_app_comp_notifications_api.create_app_comp_notification
	     (
	     p_notification_number_retries  => p_number_retries
	    ,p_notification_timeout_value   => p_admin_timeout
	    ,p_notification_action_code     => 'REQUEST-APPROVAL-RESEND'
	    ,p_notification_recipient_code  => 'ADMIN'
	    ,p_approval_style_name          => p_approval_style_name
	    ,p_time_recipient_name          => null
	    ,p_approval_component_id        => null
	    ,p_comp_notification_id         => l_comp_notification_id_table
	    ,p_object_version_number        => l_object_version_number_table
	   );
          open csr_approval_comp_id(p_approval_style_name);
          loop
          fetch csr_approval_comp_id into l_approval_comp_id,l_approval_comp_ovn;
          exit when csr_approval_comp_id%notfound;
          delete from hxc_app_comp_notif_usages
          where
          approval_comp_id  =l_approval_comp_id and
          approval_comp_ovn =l_approval_comp_ovn and
          comp_notification_id=l_comp_notification_id and
          comp_notification_ovn = l_object_version_number;
          end loop;
          close csr_approval_comp_id;
      end if;
     end if;
     close csr_notif_already_exists;
   end if;
   end if;
 end if;

 -- Non-timeout notifications

-- Checking REQUEST-APPROVAL/SUPERVISOR notification

If (p_notify_supervisor = 'Y' and l_old_notif_rec.notify_supervisor = 'N')
then

  hxc_app_comp_notifications_api.create_app_comp_notification
     (
      p_notification_number_retries  => 0
     ,p_notification_timeout_value   => 0
     ,p_notification_action_code     => 'REQUEST-APPROVAL'
     ,p_notification_recipient_code  => 'SUPERVISOR'
     ,p_approval_style_name          => p_approval_style_name
     ,p_time_recipient_name          => null
     ,p_approval_component_id        => null
     ,p_comp_notification_id         => l_comp_notification_id_table
     ,p_object_version_number        => l_object_version_number_table
   );
elsif(p_notify_supervisor = 'N' and l_old_notif_rec.notify_supervisor = 'Y')
then

  open csr_notif_id(p_approval_style_id,'REQUEST-APPROVAL','SUPERVISOR');

  fetch csr_notif_id into l_comp_notification_id,l_object_version_number;
  update hxc_app_comp_notif_usages
    set
    enabled_flag='N' where
    approval_comp_id in (select approval_comp_id from hxc_approval_comps
                         where approval_style_id=p_approval_style_id) and
    comp_notification_id=l_comp_notification_id and
    comp_notification_ovn=l_object_version_number;
  close csr_notif_id;


end if;

-- Checking SUBMISSION/WORKER notification
If (p_notify_worker_on_submit = 'Y' and l_old_notif_rec.notify_worker_on_submit = 'N')
then
  hxc_app_comp_notifications_api.create_app_comp_notification
     (
      p_notification_number_retries  => 0
     ,p_notification_timeout_value   => 0
     ,p_notification_action_code     => 'SUBMISSION'
     ,p_notification_recipient_code  => 'WORKER'
     ,p_approval_style_name          => p_approval_style_name
     ,p_time_recipient_name          => null
     ,p_approval_component_id        => null
     ,p_comp_notification_id         => l_comp_notification_id_table
     ,p_object_version_number        => l_object_version_number_table
   );
elsif(p_notify_worker_on_submit = 'N' and l_old_notif_rec.notify_worker_on_submit = 'Y')
then
  open csr_notif_id(p_approval_style_id,'SUBMISSION','WORKER');
  fetch csr_notif_id into l_comp_notification_id,l_object_version_number;
   update hxc_app_comp_notif_usages
    set
    enabled_flag='N' where
    approval_comp_id in (select approval_comp_id from hxc_approval_comps
                         where approval_style_id=p_approval_style_id) and
    comp_notification_id=l_comp_notification_id and
    comp_notification_ovn=l_object_version_number;
  close csr_notif_id;
end if;

-- Checking AUTO-APPROVE/WORKER notification
If (p_notify_worker_on_aa = 'Y' and l_old_notif_rec.notify_worker_on_aa = 'N')
then
  hxc_app_comp_notifications_api.create_app_comp_notification
     (
      p_notification_number_retries  => 0
     ,p_notification_timeout_value   => 0
     ,p_notification_action_code     => 'AUTO-APPROVE'
     ,p_notification_recipient_code  => 'WORKER'
     ,p_approval_style_name          => p_approval_style_name
     ,p_time_recipient_name          => null
     ,p_approval_component_id        => null
     ,p_comp_notification_id         => l_comp_notification_id_table
     ,p_object_version_number        => l_object_version_number_table
   );
elsif(p_notify_worker_on_aa = 'N' and l_old_notif_rec.notify_worker_on_aa = 'Y')
then
  open csr_notif_id(p_approval_style_id,'AUTO-APPROVE','WORKER');

  fetch csr_notif_id into l_comp_notification_id,l_object_version_number;
   update hxc_app_comp_notif_usages
    set
    enabled_flag='N' where
    approval_comp_id in (select approval_comp_id from hxc_approval_comps
                         where approval_style_id=p_approval_style_id) and
    comp_notification_id=l_comp_notification_id and
    comp_notification_ovn=l_object_version_number;

  close csr_notif_id;
end if;

-- Checking APPROVED/PREPARER notification
If (p_notify_preparer_approved = 'Y' and l_old_notif_rec.notify_preparer_approved = 'N')
then
  hxc_app_comp_notifications_api.create_app_comp_notification
     (
      p_notification_number_retries  => 0
     ,p_notification_timeout_value   => 0
     ,p_notification_action_code     => 'APPROVED'
     ,p_notification_recipient_code  => 'PREPARER'
     ,p_approval_style_name          => p_approval_style_name
     ,p_time_recipient_name          => null
     ,p_approval_component_id        => null
     ,p_comp_notification_id         => l_comp_notification_id_table
     ,p_object_version_number        => l_object_version_number_table
   );
elsif(p_notify_preparer_approved = 'N' and l_old_notif_rec.notify_preparer_approved = 'Y')
then
  open csr_notif_id(p_approval_style_id,'APPROVED','PREPARER');

  fetch csr_notif_id into l_comp_notification_id,l_object_version_number;
   update hxc_app_comp_notif_usages
    set
    enabled_flag='N' where
    approval_comp_id in (select approval_comp_id from hxc_approval_comps
                         where approval_style_id=p_approval_style_id) and
    comp_notification_id=l_comp_notification_id and
    comp_notification_ovn=l_object_version_number;

  close csr_notif_id;
end if;

-- Checking REJECTED/PREPARER notification
If (p_notify_preparer_rejected = 'Y' and l_old_notif_rec.notify_preparer_rejected = 'N')
then
  hxc_app_comp_notifications_api.create_app_comp_notification
     (
      p_notification_number_retries  => 0
     ,p_notification_timeout_value   => 0
     ,p_notification_action_code     => 'REJECTED'
     ,p_notification_recipient_code  => 'PREPARER'
     ,p_approval_style_name          => p_approval_style_name
     ,p_time_recipient_name          => null
     ,p_approval_component_id        => null
     ,p_comp_notification_id         => l_comp_notification_id_table
     ,p_object_version_number        => l_object_version_number_table
   );
elsif(p_notify_preparer_rejected = 'N' and l_old_notif_rec.notify_preparer_rejected = 'Y')
then
  open csr_notif_id(p_approval_style_id,'REJECTED','PREPARER');
  fetch csr_notif_id into l_comp_notification_id,l_object_version_number;
   update hxc_app_comp_notif_usages
    set
    enabled_flag='N' where
    approval_comp_id in (select approval_comp_id from hxc_approval_comps
                         where approval_style_id=p_approval_style_id) and
    comp_notification_id=l_comp_notification_id and
    comp_notification_ovn=l_object_version_number;
  close csr_notif_id;
end if;


-- Checking TRANSFER/PREPARER notification
If (p_notify_preparer_transfer = 'Y' and l_old_notif_rec.notify_preparer_transfer = 'N')
then
  hxc_app_comp_notifications_api.create_app_comp_notification
     (
      p_notification_number_retries  => 0
     ,p_notification_timeout_value   => 0
     ,p_notification_action_code     => 'TRANSFER'
     ,p_notification_recipient_code  => 'PREPARER'
     ,p_approval_style_name          => p_approval_style_name
     ,p_time_recipient_name          => null
     ,p_approval_component_id        => null
     ,p_comp_notification_id         => l_comp_notification_id_table
     ,p_object_version_number        => l_object_version_number_table
   );
elsif(p_notify_preparer_transfer = 'N' and l_old_notif_rec.notify_preparer_transfer = 'Y')
then
  open csr_notif_id(p_approval_style_id,'TRANSFER','PREPARER');
  fetch csr_notif_id into l_comp_notification_id,l_object_version_number;
   update hxc_app_comp_notif_usages
    set
    enabled_flag='N' where
    approval_comp_id in (select approval_comp_id from hxc_approval_comps
                         where approval_style_id=p_approval_style_id) and
    comp_notification_id=l_comp_notification_id and
    comp_notification_ovn=l_object_version_number;
  close csr_notif_id;
end if;


end update_notification_records;


--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_notification_records>------------------|
-- ----------------------------------------------------------------------------

Procedure delete_notification_records
(
 p_approval_style_id in hxc_approval_styles.approval_style_id%type
) is


--
-- Cursor to fetch all the notifications associated with a approval_style
--
cursor csr_notif_id
(p_approval_style_id in number) is
select distinct hacn.comp_notification_id,hacn.object_version_number
from
hxc_approval_styles has,
hxc_approval_comps hac,
hxc_app_comp_notifications hacn,
hxc_app_comp_notif_usages hacnu
where
has.approval_style_id = p_approval_style_id and
has.approval_style_id = hac.approval_style_id and
hac.approval_comp_id=hacnu.approval_comp_id and
hac.object_version_number=hacnu.approval_comp_ovn and
hacnu.comp_notification_id=hacn.comp_notification_id and
hacnu.comp_notification_ovn=hacn.object_version_number;

   cursor csr_chk_notif_used_byothers
      (p_approval_style_id in number
      ,p_comp_notification_id in number
      ,p_object_version_number in number)
      is
    select count(1) from
    hxc_approval_comps hac,
    hxc_app_comp_notifications hacn,
    hxc_app_comp_notif_usages hacnu
    where
    hac.approval_comp_id not in (select hac.approval_comp_id from hxc_approval_comps hac
    where approval_style_id = p_approval_style_id) and
    hac.approval_comp_id=hacnu.approval_comp_id and
    hacn.comp_notification_id=hacnu.comp_notification_id and
    hacn.object_version_number=hacnu.comp_notification_ovn and
    hacnu.comp_notification_id=p_comp_notification_id and
    hacnu.comp_notification_ovn=p_object_version_number;

l_count        number(9) :=0;
l_comp_notification_id     hxc_app_comp_notifications.comp_notification_id%type;
l_object_version_number    hxc_app_comp_notifications.object_version_number%type;

begin


open csr_notif_id(p_approval_style_id);
loop

  fetch csr_notif_id into l_comp_notification_id,l_object_version_number;
  exit when csr_notif_id%notfound;

  open csr_chk_notif_used_byothers(p_approval_style_id,l_comp_notification_id,l_object_version_number);
  fetch csr_chk_notif_used_byothers into l_count;
  close csr_chk_notif_used_byothers;

  if(l_count =0)
  then

    hxc_app_comp_notifications_api.delete_app_comp_notification
         (
          p_comp_notification_id   =>  l_comp_notification_id
         ,p_object_version_number  =>  l_object_version_number
         );

    hxc_app_comp_notifications_api.purge_comp_notification
         (
          p_comp_notification_id   =>  l_comp_notification_id
         ,p_object_version_number  =>  l_object_version_number
         );
   else

     delete from hxc_app_comp_notif_usages
     where
     approval_comp_id in
     (select approval_comp_id
     from hxc_approval_comps where
     approval_style_id=p_approval_style_id) and
     comp_notification_id = l_comp_notification_id and
     comp_notification_ovn = l_object_version_number;


   end if;
end loop;
close csr_notif_id;



end delete_notification_records;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< approval_comps_usages>------------------------|
-- ----------------------------------------------------------------------------
Procedure approval_comps_usages
      ( p_approval_style_id  in number
       ,p_approval_comp_id  in number
       ,p_approval_comp_ovn in number
       ,p_dml_action        in varchar2
      )
is

l_count number(9):=0;
l_comp_notification_id    number(9);
l_comp_notification_ovn   number(9);
l_enabled_flag              varchar2(1);
l_existing_approval_comp_id number(9);

cursor csr_chk_comps_usages
     (
      p_approval_comp_id  in number
     )
is
select count(1) from
hxc_app_comp_notif_usages hacnu,
hxc_approval_comps hac,
hxc_approval_comps hac1
where
hac.approval_comp_id=p_approval_comp_id and
hac.approval_comp_id<>hac1.approval_comp_id and
hac.approval_style_id=hac1.approval_style_id and
hac1.approval_comp_id=hacnu.approval_comp_id;

cursor csr_approval_comp (p_approval_style_id in number)
is
select hac.approval_comp_id from
hxc_approval_styles has,
hxc_approval_comps hac
where
has.approval_style_id=p_approval_style_id and
has.approval_style_id=hac.approval_style_id and
hac.approval_comp_id in (select approval_comp_id from hxc_app_comp_notif_usages);

cursor csr_comp_notification (p_approval_comp_id in number) is
select hacnu.comp_notification_id,hacnu.comp_notification_ovn,hacnu.enabled_flag
from
hxc_approval_comps hac,
hxc_app_comp_notif_usages hacnu
where
hac.approval_comp_id=p_approval_comp_id and
hacnu.approval_comp_id=hac.approval_comp_id;

begin

if (p_dml_action = 'INSERT')
then
  open csr_chk_comps_usages(p_approval_comp_id);
  fetch csr_chk_comps_usages into l_count;
  close csr_chk_comps_usages;
  if (l_count>0)
  then
      open csr_approval_comp(p_approval_style_id);
      fetch csr_approval_comp into l_existing_approval_comp_id;
      close csr_approval_comp;
      open csr_comp_notification(l_existing_approval_comp_id);
      loop
         fetch csr_comp_notification into l_comp_notification_id,l_comp_notification_ovn,l_enabled_flag;
         exit when csr_comp_notification%notfound;
         insert into
         hxc_app_comp_notif_usages
         (
           approval_comp_id
          ,approval_comp_ovn
          ,comp_notification_id
          ,comp_notification_ovn
          ,enabled_flag
         )
         values
         (
           p_approval_comp_id
          ,p_approval_comp_ovn
          ,l_comp_notification_id
          ,l_comp_notification_ovn
          ,l_enabled_flag
         );
      end loop;
      close csr_comp_notification;
  end if;

elsif (p_dml_action = 'DELETE')
then

  --For deleting rows corresponding to ELA
  delete from
  hxc_app_comp_notif_usages
  where
  approval_comp_id in (select approval_comp_id from
                       hxc_approval_comps where
                       PARENT_COMP_ID=p_approval_comp_id and
                       PARENT_COMP_OVN=p_approval_comp_ovn);

  delete from
  hxc_app_comp_notif_usages
  where
  approval_comp_id  = p_approval_comp_id and
  approval_comp_ovn = p_approval_comp_ovn;
end if;
end approval_comps_usages;

end hxc_notification_helper;

/
