--------------------------------------------------------
--  DDL for Package Body GHR_PRH_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PRH_API" as
/* $Header: ghprhapi.pkb 120.0.12010000.2 2009/05/26 10:44:10 vmididho noship $ */
--
-- Package Variables
g_package  varchar2(33)	:= '  ghr_prh_api.';


-- ----------------------------------------------------------------------------
-- |--------------------------< upd_date_notif_sent>--------------------------|
-- ----------------------------------------------------------------------------

  procedure upd_date_notif_sent
  (p_validate                        in      boolean   default false,
   p_pa_request_id                   in      number,
   p_date_notification_sent          in      date      default trunc(sysdate)
   )is

  l_proc                         varchar2(72) := g_package|| 'upd_date_notif_sent' ;
  l_prh_object_version_number    ghr_pa_routing_history.object_version_number%TYPE;
  l_prh_pa_routing_history_id    ghr_pa_routing_history.pa_routing_history_id%TYPE;
  l_action_taken                 ghr_pa_routing_history.action_taken%type;


  cursor     C_routing_history_id is
    select   prh.pa_routing_history_id,
             prh.object_version_number,
             prh.action_taken
    from     ghr_pa_routing_history prh
    where    prh.pa_request_id = p_pa_request_id
    order by prh.pa_routing_history_id desc;

begin
    hr_utility.set_location('Entering:'|| l_proc, 5);
  --

      savepoint upd_date_notif_sent;
    hr_utility.set_location(l_proc, 6);


   for cur_routing_history in C_routing_history_id loop
        l_prh_pa_routing_history_id     :=  cur_routing_history.pa_routing_history_id;
        l_prh_object_version_number     :=  cur_routing_history.object_version_number;
        l_action_taken                  :=  cur_routing_history.action_taken;
        exit;
   end loop;

--  if  nvl(l_action_taken,hr_api.g_varchar2) = hr_api.g_varchar2 then
     ghr_prh_upd.upd
       (p_pa_routing_history_id      => l_prh_pa_routing_history_id
       ,p_date_notification_sent     => p_date_notification_sent
       ,p_object_version_number      => l_prh_object_version_number
       ,p_validate                   => p_validate
       );
--   else
--     hr_utility.set_message(8301,'GHR_38112_INVALID_API');
--     hr_utility.raise_error;
--   end if;

   if p_validate then
     raise hr_api.validate_enabled;
   end if;

 -- Set all output arguments
 --
   hr_utility.set_location(' Leaving:'||l_proc, 11);
  exception
    when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_date_notif_sent;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    when others then
      ROLLBACK TO upd_date_notif_sent;
      raise;

    hr_utility.set_location(' Leaving:'||l_proc, 12);

  end upd_date_notif_sent;
 end ghr_prh_api;

/
