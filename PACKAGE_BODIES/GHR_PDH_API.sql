--------------------------------------------------------
--  DDL for Package Body GHR_PDH_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDH_API" as
/* $Header: ghpdhapi.pkb 120.0.12010000.2 2009/05/26 10:46:17 utokachi noship $ */
--
-- Package Variables
g_package  varchar2(33)	:= 'ghr_pdh_api.';


-- ----------------------------------------------------------------------------
-- |--------------------------< upd_date_notif_sent>--------------------------|
-- ----------------------------------------------------------------------------

  procedure upd_date_notif_sent
  (p_validate                        in      boolean   default false,
   p_position_description_id                   in      number,
   p_date_notification_sent          in      date      default trunc(sysdate)
   )is

  l_proc                         varchar2(72) := g_package|| 'upd_date_notif_sent' ;
  l_pdh_object_version_number    ghr_pd_routing_history.object_version_number%TYPE;
  l_pdh_pd_routing_history_id    ghr_pd_routing_history.pd_routing_history_id%TYPE;
  l_action_taken                 ghr_pd_routing_history.action_taken%type;


  cursor     C_routing_history_id is
    select   pdh.pd_routing_history_id,
             pdh.object_version_number,
             pdh.action_taken
    from     ghr_pd_routing_history pdh
    where    pdh.position_description_id = p_position_description_id
    order by pdh.pd_routing_history_id desc;

begin
    hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --

--    if p_validate then
      savepoint upd_date_notif_sent;
--    end if;
    hr_utility.set_location(l_proc, 6);


   for cur_routing_history in C_routing_history_id loop
        l_pdh_pd_routing_history_id     :=  cur_routing_history.pd_routing_history_id;
        l_pdh_object_version_number     :=  cur_routing_history.object_version_number;
        l_action_taken                  :=  cur_routing_history.action_taken;
        exit;
   end loop;

--  if  nvl(l_action_taken,hr_api.g_varchar2) = hr_api.g_varchar2 then
     ghr_pdh_upd.upd
       (p_pd_routing_history_id      => l_pdh_pd_routing_history_id
       ,p_date_notification_sent     => p_date_notification_sent
       ,p_object_version_number      => l_pdh_object_version_number
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
    --
	when others then
           rollback to upd_date_notif_sent;
           raise;

    hr_utility.set_location(' Leaving:'||l_proc, 12);

  end upd_date_notif_sent;
 end ghr_pdh_api;

/
