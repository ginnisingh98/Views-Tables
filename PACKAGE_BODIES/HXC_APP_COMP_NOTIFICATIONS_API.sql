--------------------------------------------------------
--  DDL for Package Body HXC_APP_COMP_NOTIFICATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APP_COMP_NOTIFICATIONS_API" as
/* $Header: hxchanapi.pkb 120.0 2006/06/19 06:58:02 gsirigin noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hxc_app_comp_notifications_api.';
g_debug	boolean	        :=hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <create_app_comp_notification> >--------------|
-- ----------------------------------------------------------------------------
--
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
 ) is

  l_proc                          varchar2(72) := g_package||'create_app_comp_notifications';
  l_comp_notification_id          hxc_app_comp_notifications.comp_notification_id%TYPE;
  l_object_version_number         hxc_app_comp_notifications.object_version_number%TYPE;
  l_approval_comp_id              hxc_approval_comps.approval_comp_id%TYPE;
  l_approval_comp_ovn             hxc_approval_comps.object_version_number%TYPE;
  l_enabled_flag                  hxc_app_comp_notif_usages.enabled_flag%TYPE DEFAULT 'Y';
  l_comp_notification_id_exist    hxc_app_comp_notifications.comp_notification_id%TYPE;
  l_object_version_number_exist   hxc_app_comp_notifications.object_version_number%TYPE;
  l_count                         number(1) :=0;



cursor csr_approval_comp_id
(p_approval_style_name in varchar2)
is
SELECT hac.approval_comp_id, hac.object_version_number
  FROM hxc_approval_styles has, hxc_approval_comps hac
 WHERE has.NAME = p_approval_style_name
   AND has.approval_style_id = hac.approval_style_id
   AND hac.object_version_number = (SELECT MAX (object_version_number)
                                      FROM hxc_approval_comps
                                     WHERE approval_comp_id =hac.approval_comp_id);

cursor csr_chk_app_comp_notifications
   ( p_notification_number_retries in hxc_app_comp_notifications.notification_number_retries%type
    ,p_notification_timeout_value  in hxc_app_comp_notifications.notification_timeout_value%type
    ,p_notification_action_code    in hxc_app_comp_notifications.notification_action_code%type
    ,p_notification_recipient_code in hxc_app_comp_notifications.notification_recipient_code%type
    ) is
   SELECT hacn.comp_notification_id, hacn.object_version_number
     FROM hxc_app_comp_notifications hacn
    WHERE notification_number_retries = p_notification_number_retries
      AND notification_timeout_value = p_notification_timeout_value
      AND notification_action_code = p_notification_action_code
      AND notification_recipient_code = p_notification_recipient_code
      AND object_version_number = (SELECT MAX (object_version_number)
                                     FROM hxc_app_comp_notifications
                                    WHERE comp_notification_id =
                                                     hacn.comp_notification_id);

  cursor csr_comp_from_recipient
     ( p_approval_style_name in varchar2
      ,p_time_recipient_name in varchar2) is
    SELECT hac.approval_comp_id, hac.object_version_number
      FROM hxc_approval_styles has, hxc_approval_comps hac, hxc_time_recipients htr
     WHERE has.NAME = p_approval_style_name
       AND htr.NAME = p_time_recipient_name
       AND has.approval_style_id = hac.approval_style_id
       AND htr.time_recipient_id = hac.time_recipient_id
       AND hac.object_version_number = (SELECT MAX (object_version_number)
                                          FROM hxc_approval_comps
                                         WHERE approval_comp_id =
                                                          hac.approval_comp_id);

 cursor csr_chk_diabled
  ( l_approval_comp_id      in number
   ,l_approval_comp_ovn     in number
   ,l_comp_notification_id  in number
   ,l_comp_notification_ovn in number)
 is
 SELECT COUNT (1)
   FROM hxc_app_comp_notif_usages
  WHERE approval_comp_id = l_approval_comp_id
    AND approval_comp_ovn = l_approval_comp_ovn
    AND comp_notification_id = l_comp_notification_id
    AND comp_notification_ovn = l_comp_notification_ovn
    AND enabled_flag = 'N';

begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'create_app_comp_notifications';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_app_comp_notification;
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Remember IN OUT parameter IN values
  --


  --
  -- Truncate the time portion from all IN date parameters
  --


  --
  -- Call Before Process User Hook
  --

  begin




    hxc_app_comp_notifications_bk1.create_app_comp_notification_b
      (
       p_notification_number_retries   => p_notification_number_retries
      ,p_notification_timeout_value    => p_notification_timeout_value
      ,p_notification_action_code      => p_notification_action_code
      ,p_notification_recipient_code   => p_notification_recipient_code
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_app_comp_notification'
        ,p_hook_type   => 'BP'
        );
  end;

  if g_debug then
  	hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  if g_debug then
      	hr_utility.set_location(l_proc, 40);
  end if;

  --
  -- Call row hadler
  --
  begin

  if(p_time_recipient_name is null and p_approval_component_id is null)
  then
  open csr_chk_app_comp_notifications(p_notification_number_retries, p_notification_timeout_value,
  p_notification_action_code, p_notification_recipient_code);
  fetch csr_chk_app_comp_notifications into l_comp_notification_id_exist,l_object_version_number_exist;

  if csr_chk_app_comp_notifications%notfound
  then

     hxc_han_ins.ins
       (p_notification_number_retries     => p_notification_number_retries
       ,p_notification_timeout_value      => p_notification_timeout_value
       ,p_notification_action_code	  => p_notification_action_code
       ,p_notification_recipient_code     => p_notification_recipient_code
       ,p_comp_notification_id            => l_comp_notification_id
       ,p_object_version_number           => l_object_version_number
        );



      open csr_approval_comp_id(p_approval_style_name);
      LOOP
      fetch csr_approval_comp_id into l_approval_comp_id, l_approval_comp_ovn;
      exit when csr_approval_comp_id%notfound;
	  -- Insert into hxc_app_comp_notif_usages

	  insert into hxc_app_comp_notif_usages
	       (approval_comp_id
	       ,approval_comp_ovn
	       ,comp_notification_id
	       ,comp_notification_ovn
	       ,enabled_flag
	       ) values
	       (l_approval_comp_id
	       ,l_approval_comp_ovn
	       ,l_comp_notification_id
	       ,l_object_version_number
	       ,l_enabled_flag
	       );
       end loop;
       close csr_approval_comp_id;
  else

  open csr_approval_comp_id(p_approval_style_name);
  LOOP
  fetch csr_approval_comp_id into l_approval_comp_id, l_approval_comp_ovn;
  exit when csr_approval_comp_id%notfound;
  -- Insert into hxc_app_comp_notif_usages

   open csr_chk_diabled( l_approval_comp_id
                        ,l_approval_comp_ovn
                        ,l_comp_notification_id_exist
                        ,l_object_version_number_exist
                       );
   fetch csr_chk_diabled into l_count;
   close csr_chk_diabled;
   if (l_count>0)
   then
     update hxc_app_comp_notif_usages
     set
     enabled_flag='Y'
     where
     approval_comp_id=l_approval_comp_id and
     approval_comp_ovn=l_approval_comp_ovn and
     comp_notification_id=l_comp_notification_id_exist and
     comp_notification_ovn=l_object_version_number_exist;

   else
     insert into hxc_app_comp_notif_usages
       (approval_comp_id
       ,approval_comp_ovn
       ,comp_notification_id
       ,comp_notification_ovn
       ,enabled_flag
       ) values
       (l_approval_comp_id
       ,l_approval_comp_ovn
       ,l_comp_notification_id_exist
       ,l_object_version_number_exist
       ,l_enabled_flag
       );

   end if;
  end loop;
  close csr_approval_comp_id;
  end if;
  close csr_chk_app_comp_notifications;



  else ---if p_approval_component_id is used to create notification record
    if(p_approval_component_id is not null)
    then
      select approval_comp_id,object_version_number
         into l_approval_comp_id,l_approval_comp_ovn
         from hxc_approval_comps where
         approval_comp_id=p_approval_component_id;
    else
      open csr_comp_from_recipient(p_approval_style_name,p_time_recipient_name);
      fetch csr_comp_from_recipient into l_approval_comp_id,l_approval_comp_ovn;

    end if;
    open csr_chk_app_comp_notifications(p_notification_number_retries, p_notification_timeout_value,
    p_notification_action_code, p_notification_recipient_code);
    fetch csr_chk_app_comp_notifications into l_comp_notification_id_exist,l_object_version_number_exist;

    if csr_chk_app_comp_notifications%notfound
    then

       hxc_han_ins.ins
         (p_notification_number_retries     => p_notification_number_retries
         ,p_notification_timeout_value      => p_notification_timeout_value
         ,p_notification_action_code	    => p_notification_action_code
         ,p_notification_recipient_code     => p_notification_recipient_code
         ,p_comp_notification_id            => l_comp_notification_id
         ,p_object_version_number           => l_object_version_number
          );

        -- Insert into hxc_app_comp_notif_usages. We need not loop as we are dealing with only one
        -- approval component.

  	  insert into hxc_app_comp_notif_usages
  	       (approval_comp_id
  	       ,approval_comp_ovn
  	       ,comp_notification_id
  	       ,comp_notification_ovn
  	       ,enabled_flag
  	       ) values
  	       (l_approval_comp_id
  	       ,l_approval_comp_ovn
  	       ,l_comp_notification_id
  	       ,l_object_version_number
  	       ,l_enabled_flag
  	       );

    else
      -- Insert into hxc_app_comp_notif_usages

     insert into hxc_app_comp_notif_usages
         (approval_comp_id
         ,approval_comp_ovn
         ,comp_notification_id
         ,comp_notification_ovn
         ,enabled_flag
         ) values
         (l_approval_comp_id
         ,l_approval_comp_ovn
         ,l_comp_notification_id_exist
         ,l_object_version_number_exist
         ,l_enabled_flag
         );

    end if;
    close csr_chk_app_comp_notifications; ---Cursor closed

  end if;
 end; --new end




  if g_debug then
      	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --

 begin
    hxc_app_comp_notifications_bk1.create_app_comp_notification_a
          (p_comp_notification_id          => l_comp_notification_id
          ,p_object_version_number         => l_object_version_number
          ,p_notification_number_retries   => p_notification_number_retries
          ,p_notification_timeout_value    => p_notification_timeout_value
          ,p_notification_action_code      => p_notification_action_code
          ,p_notification_recipient_code   => p_notification_recipient_code
           );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_app_comp_notification'
        ,p_hook_type   => 'AP'
        );
  end;

  if g_debug then
      	hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --

  --
  -- Set all IN OUT and OUT parameters with out values
  --
   p_comp_notification_id := id_type();
   p_comp_notification_id.EXTEND(1);

   p_object_version_number := ovn_type();
   p_object_version_number.EXTEND(1);

   p_comp_notification_id(1)   := l_comp_notification_id;
   p_object_version_number(1)  := l_object_version_number;
  --
  if g_debug then
      	hr_utility.set_location(l_proc, 70);
  end if;
  --commit; --Have to be removed*****
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_app_comp_notification;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_comp_notification_id   := null;
    p_object_version_number  := null;

    if g_debug then
       hr_utility.set_location(l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_app_comp_notification;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_comp_notification_id   := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_app_comp_notification;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <update_app_comp_notification> >--------------|
-- ----------------------------------------------------------------------------
--
procedure update_app_comp_notification
(
 p_comp_notification_id            in                number,
 p_object_version_number           in out nocopy     number,
 p_notification_number_retries     in number default hr_api.g_number,
 p_notification_timeout_value      in number default hr_api.g_number
 ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number hxc_app_comp_notifications.object_version_number%type :=p_object_version_number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_app_comp_notification';
begin
  if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_app_comp_notification;


  --
  -- Call Before Process User Hook
  --
  begin
    hxc_app_comp_notifications_bk2.update_app_comp_notification_b
          (p_comp_notification_id          => p_comp_notification_id
          ,p_object_version_number         => p_object_version_number
          ,p_notification_number_retries   => p_notification_number_retries
          ,p_notification_timeout_value    => p_notification_timeout_value
           );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_app_comp_notification'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --


  --
  -- Call row hadler(parameters should be changed)
  --

      hxc_han_upd.upd
       (p_comp_notification_id         => p_comp_notification_id
       ,p_object_version_number        => l_object_version_number
       ,p_notification_number_retries  => p_notification_number_retries
       ,p_notification_timeout_value   => p_notification_timeout_value
       );


  --Update the hxc_app_comp_notif_usages table

    update hxc_app_comp_notif_usages
    set
    comp_notification_ovn      = l_object_version_number
    where comp_notification_id = p_comp_notification_id;

  --
  -- Call After Process User Hook
  --
  begin
    hxc_app_comp_notifications_bk2.update_app_comp_notification_a
          (p_comp_notification_id          => p_comp_notification_id
          ,p_object_version_number         => p_object_version_number
          ,p_notification_number_retries   => p_notification_number_retries
          ,p_notification_timeout_value    => p_notification_timeout_value
           );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_app_comp_notification'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --

  --
  -- Set all IN OUT and OUT parameters with out values
  --

  p_object_version_number  := l_object_version_number;
  --
  if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_app_comp_notification;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_object_version_number  := null;

    if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_app_comp_notification;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := null;
    if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end update_app_comp_notification;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <delete_app_comp_notification> >--------------|
-- ----------------------------------------------------------------------------
--
procedure delete_app_comp_notification
  (
    p_comp_notification_id     in number
   ,p_object_version_number    in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_app_comp_notification';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_app_comp_notification;


  --
  -- Call Before Process User Hook
  --
  begin
    hxc_app_comp_notifications_bk3.delete_app_comp_notification_b
      (p_comp_notification_id          => p_comp_notification_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_app_comp_notification'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- update hxc_app_comp_notif_usages table
  --
     update hxc_app_comp_notif_usages
     set
     enabled_flag = 'N' where
     comp_notification_id     = p_comp_notification_id and
     comp_notification_ovn    = p_object_version_number;


  --
  -- Call After Process User Hook
  --
  begin
    hxc_app_comp_notifications_bk3.delete_app_comp_notification_a
      (p_comp_notification_id          => p_comp_notification_id
      ,p_object_version_number         => p_object_version_number
      );  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_app_comp_notification'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --


  --
  if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_app_comp_notification;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_app_comp_notification;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_app_comp_notification;

--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <purge_comp_notification> >-------------------|
-- ----------------------------------------------------------------------------
--
procedure purge_comp_notification
  (
    p_comp_notification_id         in number
   ,p_object_version_number        in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'purge_comp_notification';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint purge_comp_notification;




  --
  -- Deleting records from hxc_app_comp_notif_usages
  --
     delete from hxc_app_comp_notif_usages where
      comp_notification_id = p_comp_notification_id and
      comp_notification_ovn= p_object_version_number and
      enabled_flag         = 'N';

  --
  -- Delete from hxc_app_comp_notifications
  --

      hxc_han_del.del
       (p_comp_notification_id        => p_comp_notification_id
       ,p_object_version_number       => p_object_version_number
       );



  --
  -- When in validation only mode raise the Validate_Enabled exception
  --


  --
  if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to purge_comp_notification;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to purge_comp_notification;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end purge_comp_notification;

--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <disable_timeout_notifications> >-------------|
-- ----------------------------------------------------------------------------
--
procedure disable_timeout_notifications
  (
    p_approval_style_name in varchar2
   ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'disable_timeout_notifications';
  l_approval_comp_id    number;
  l_comp_notification_id number;

 CURSOR csr_resend_notifications
 IS
 SELECT hacnu.approval_comp_id, hacnu.comp_notification_id
   FROM hxc_app_comp_notifications hacn,
        hxc_approval_styles has,
        hxc_approval_comps hac,
        hxc_app_comp_notif_usages hacnu
  WHERE has.NAME = p_approval_style_name
    AND has.approval_style_id = hac.approval_style_id
    AND hac.approval_comp_id = hacnu.approval_comp_id
    AND hac.object_version_number = hacnu.approval_comp_ovn
    AND hacnu.comp_notification_id = hacn.comp_notification_id
    AND hacnu.comp_notification_ovn = hacn.object_version_number
    AND hacn.notification_action_code = 'REQUEST-APPROVAL-RESEND';

begin
  if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint disable_timeout_notifications;


  --
  -- Call Before Process User Hook
  --

  --
  -- Deleting records from hxc_app_comp_notif_usages
  --
  open csr_resend_notifications;
  LOOP
    fetch csr_resend_notifications into l_approval_comp_id,l_comp_notification_id;
    exit when csr_resend_notifications%notfound;
    update hxc_app_comp_notif_usages
    set
    enabled_flag = 'N'
    where approval_comp_id = l_approval_comp_id and
    comp_notification_id = l_comp_notification_id;
  end loop;
  close csr_resend_notifications;

  --
  -- Delete from hxc_app_comp_notifications
  --

   /*  hxc_han_del.del
       (p_comp_notification_id        => l_comp_notification_id
       ,p_object_version_number       => p_object_version_number
       );*/


  --
  -- Call After Process User Hook
  --

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --


  --
  if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_timeout_notifications;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to disable_timeout_notifications;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end disable_timeout_notifications;
end hxc_app_comp_notifications_api;

/
