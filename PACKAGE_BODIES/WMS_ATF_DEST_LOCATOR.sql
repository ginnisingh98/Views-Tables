--------------------------------------------------------
--  DDL for Package Body WMS_ATF_DEST_LOCATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ATF_DEST_LOCATOR" as
 /* $Header: WMSADELB.pls 120.1 2005/05/25 17:33:52 appldev  $ */
--
-- ---------------------------------------------------------------------------|
-- |-------------------------------< trace >----------------------------------|
-- ---------------------------------------------------------------------------|
-- {Start Of Comments}
--
-- Description:
-- Wrapper around the tracing utility.
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name        Reqd Type     Description
--   p_message   Yes  varchar2 Message to be displayed in the log file.
--   p_prompt    Yes  varchar2 Prompt.
--   p_level     No   number   Level.
--
-- Post Success:
--   None.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure trace(
   p_message  in varchar2
,  p_level    in number
) is
begin
      INV_LOG_UTIL.trace(p_message, 'WMS_ATF_DEST_LOCATOR', p_level);
end trace;
--
-- -----------------------------------------------------------------------------|
-- |------------------------< get_dest_locator >--------------------------------|
-- -----------------------------------------------------------------------------|
-- API name    : Get_destination_Loc_LPN
-- Type        : Private
-- Function    : Returns Sub/Loc, LPN or Validation Status.
-- Input Parameters  :
--             As shown below.
--
-- Output Parameters:
--             As shown below.
-- Version     :
-- Current version 1.0
--
-- Notes       :
-- Date           Modification       Author
-- ------------   ------------       ------------------
--
PROCEDURE get_dest_locator(
   x_return_status       out nocopy varchar2
,  x_msg_count           out nocopy number
,  x_msg_data            out nocopy varchar2
,  x_locator_id          out nocopy number
,  x_zone_id             out nocopy number
,  x_subinventory_code   out nocopy varchar2
,  x_loc_valid           out nocopy varchar2
,  p_mode                in  number -- 1. Selection  2. Validation
,  p_task_id             in  number -- MMTT.transaction_temp_id
,  p_activity_type_id    in  number -- 1. Inbound   2. Outbound
,  p_hook_call_id	 in  number -- Seeded/Custom API call hook id in the wms_api_hook_calls.
,  p_locator_id          in  number -- Locator_id for Validation pruposes.
,  p_item_id             in  number -- Item ID for Validation purposes.
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
)
is

l_debug  			number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_current_package_cntr		number;
l_proc                          varchar2(72) := 'GET_DEST_LOCATOR :';
l_prog                          float;
l_effective_to_date             date;

-- Added the wahc.effective_to_date to the select on December 24th 2003.
cursor c_get_hook_call_details is
select wahe.current_package_cntr, wahc.effective_to_date
from   wms_api_hook_calls wahc, wms_api_hooked_entities wahe
where  wahe.module_hook_id = wahc.module_hook_id
-- Restricts the output to "Locator Selection/Validation" only
and    wahe.short_name_id = 1
and    wahc.hook_call_id = p_hook_call_id;

begin
   -- ### Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if (l_debug = 1) then
      trace(l_proc ||' Entering package wms_atf_dest_locator  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc ||' Entering procedure get_dest_locator  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc ||' p_mode => ' || p_mode);
      trace(l_proc ||' p_task_id => ' || p_task_id);
      trace(l_proc ||' p_activity_type_id  => ' || p_activity_type_id);
      trace(l_proc ||' p_hook_call_id   => ' || p_hook_call_id);
      trace(l_proc ||' p_locator_id => ' || p_locator_id);
      trace(l_proc ||' p_item_id => ' || p_item_id);
   end if;

   -- ### Derive hook call details to start with.
   if (l_debug = 1) then
      trace(l_proc ||' Opening Cursor c_get_hook_call_details  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   end if;
   -- Opening Cursor...
   open  c_get_hook_call_details;
   if (l_debug = 1) then
      trace(l_proc ||' Fetching Cursor c_get_hook_call_details  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   end if;

   fetch c_get_hook_call_details
   into  l_current_package_cntr, l_effective_to_date;

      if c_get_hook_call_details%NOTFOUND then
         if (l_debug = 1) then
            trace(l_proc ||' c_get_hook_call_details%NOTFOUND...Invalid p_hook_call_id passed in ...Cannot Proceed');
         end if;
         close c_get_hook_call_details;
      else
         -- ### Short Name is maintained as an MFG_LOOKUP.
         -- ### 1. Loc Determination
         -- ### 2. LPN Determination
         if  (l_debug = 1) then
             trace(l_proc ||' Cursor c_get_hook_call_details FOUND...');
             trace(l_proc ||' Values after fetching Cursor c_get_hook_call_details.. ', 4);
             trace(l_proc ||' l_current_package_cntr '|| l_current_package_cntr, 4);
             trace(l_proc ||' l_effective_to_date '|| l_effective_to_date, 4);
         end if;

         -- Added after TOI Session on Dec.23rd 2003.
         -- As per the latest design, a check is being done against the 'p_hook_call_id' passed in to test if its
         -- valid w.r.to 'effective_to_date'. If the effective_to_date is less than the current date, then an error
         -- is passed bask to the calling program and the message stack is also populated accordingly.
         if (trunc(l_effective_to_date) < sysdate) then
             trace(l_proc ||' Effective to date of the relationship is less than the current date...');
             trace(l_proc ||' This renders this relationship ineffective for the current run though this hook call..');
             trace(l_proc ||' may have been valid when the operation plan was set up. ');
             fnd_message.set_name('WMS', 'WMS_EXPIRED_HOOK_CALL_ID');
             fnd_msg_pub.ADD;
             raise fnd_api.g_exc_error;
         end if;


         -- ### Check if p_mode is 'Validation' and the p_locator_id is null.
         if (p_mode = 2 and p_locator_id is null)
         then
             if (l_debug =1) then
                trace(l_proc ||' Locator ID cannot be null if "wms_atf_dest_locator.get_dest_locator" is called in validation mode');
             end if;
             return;
         end if;
         -- ###
         -- ### This means that the call is to Select/Validate Location.
         -- ### Also call the current package based on the counter.
         -- ### Procedure  GET_LOC(
         -- ### x_return_status                  OUT  VARCHAR2,
         -- ### x_msg_count                      OUT  NUMBER,
         -- ### x_msg_data                       OUT  VARCHAR2,
         -- ### x_locator_id                     OUT  NUMBER,
         -- ### x_subinventory_code              OUT  VARCHAR2,
         -- ### x_loc_valid                      OUT  VARCHAR2,
         -- ### p_mode                           IN  NUMBER,
         -- ### p_activity_type_id               IN  NUMBER,
         -- ### p_task_id                        IN  NUMBER,
         -- ### p_locator_id                     IN  NUMBER,
         -- ### p_item_id                        IN  NUMBER,
         -- ### p_hook_call_id                   IN  NUMBER
         -- ### );

         if l_current_package_cntr = 1
         then
                if (l_debug =1) then
                   trace(l_proc ||' Within "l_current_package_cntr = 1" clause...');
                   trace(l_proc ||' Before calling package "wms_api_loc_package_1.get_loc"....', 1);
                   trace(l_proc ||' Input parameters...');
                   trace(l_proc ||' p_mode = ' ||  p_mode);
                   trace(l_proc ||' p_activity_type_id = ' ||  p_activity_type_id);
                   trace(l_proc ||' p_task_id = ' ||  p_task_id);
                   trace(l_proc ||' p_locator_id = ' ||  p_locator_id);
                   trace(l_proc ||' p_item_id = ' ||  p_item_id);
                   trace(l_proc ||' p_hook_call_id = ' ||  p_hook_call_id);
                end if;

                wms_api_loc_package_1.get_loc(
                   x_return_status        => x_return_status
            	,  x_msg_count            => x_msg_count
            	,  x_msg_data             => x_msg_data
            	,  x_locator_id           => x_locator_id
            	,  x_zone_id              => x_zone_id
            	,  x_subinventory_code    => x_subinventory_code
            	,  x_loc_valid            => x_loc_valid
            	,  p_mode                 => p_mode
            	,  p_activity_type_id     => p_activity_type_id
            	,  p_task_id              => p_task_id
            	,  p_locator_id           => p_locator_id
            	,  p_item_id              => p_item_id
            	,  p_hook_call_id         => p_hook_call_id
                ,  p_api_version          => p_api_version
                ,  p_init_msg_list        => p_init_msg_list
                ,  p_commit               => p_commit
            	);

                if (l_debug =1) then
                   trace(l_proc ||' After calling package "wms_api_loc_package_1.get_loc"....', 1);
                   trace(l_proc ||' Out parameters...');
                   trace(l_proc ||' x_return_status = ' ||  x_return_status);
                   trace(l_proc ||' x_locator_id = ' ||  x_locator_id);
                   trace(l_proc ||' x_zone_id = ' ||  x_zone_id);
                   trace(l_proc ||' x_subinventory_code = ' ||  x_subinventory_code);
                   trace(l_proc ||' x_loc_valid = ' ||  x_loc_valid);
                end if;
         elsif l_current_package_cntr = 2
         then
                if (l_debug =1) then
                   trace(l_proc ||' Within "l_current_package_cntr = 2" clause...');
                   trace(l_proc ||' Before calling package "wms_api_loc_package_2.get_loc"....', 1);
                   trace(l_proc ||' Input parameters...');
                   trace(l_proc ||' p_mode = ' ||  p_mode);
                   trace(l_proc ||' p_activity_type_id = ' ||  p_activity_type_id);
                   trace(l_proc ||' p_task_id = ' ||  p_task_id);
                   trace(l_proc ||' p_locator_id = ' ||  p_locator_id);
                   trace(l_proc ||' p_item_id = ' ||  p_item_id);
                   trace(l_proc ||' p_hook_call_id = ' ||  p_hook_call_id);
                end if;

            	wms_api_loc_package_2.get_loc(
            	   x_return_status        => x_return_status
            	,  x_msg_count            => x_msg_count
            	,  x_msg_data             => x_msg_data
            	,  x_locator_id           => x_locator_id
            	,  x_zone_id              => x_zone_id
               	,  x_subinventory_code    => x_subinventory_code
            	,  x_loc_valid            => x_loc_valid
            	,  p_mode                 => p_mode
            	,  p_activity_type_id     => p_activity_type_id
            	,  p_task_id              => p_task_id
            	,  p_locator_id           => p_locator_id
            	,  p_item_id              => p_item_id
            	,  p_hook_call_id         => p_hook_call_id
                ,  p_api_version          => p_api_version
                ,  p_init_msg_list        => p_init_msg_list
                ,  p_commit               => p_commit
            	);

                if (l_debug =1) then
                   trace(l_proc ||' After calling package "wms_api_loc_package_1.get_loc"....', 1);
                   trace(l_proc ||' Out parameters...');
                   trace(l_proc ||' x_return_status = ' ||  x_return_status);
                   trace(l_proc ||' x_locator_id = ' ||  x_locator_id);
                   trace(l_proc ||' x_zone_id = ' ||  x_zone_id);
                   trace(l_proc ||' x_subinventory_code = ' ||  x_subinventory_code);
                   trace(l_proc ||' x_loc_valid = ' ||  x_loc_valid);
                end if;
         end if;
         if (l_debug = 1) then
            trace(' Exiting package wms_atf_dest_loc_lpn_wrap  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
            trace(' Exiting procedure get_dest_loc_lpn_wrap  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
            trace(  '   x_locator_id      => ' || x_locator_id
                  ||'   x_subinventory_code    => ' || x_subinventory_code
                  ||'   x_loc_valid           => ' || x_loc_valid, 4);
         end if;
      end if;
      close c_get_hook_call_details;
      return;
exception
   when fnd_api.g_exc_error then
      x_return_status  := fnd_api.g_ret_sts_error;

      if (l_debug = 1) then
         trace(' Progress at the time of failure is ' || l_prog, 1);
         trace(' Error Code, Error Message...' || sqlerrm(sqlcode), 1);
      end if;

    when others then
         close c_get_hook_call_details;

         if (l_debug = 1) then
            trace('Error within "When Others" of the Outermost block in the get_dest_loc_lpn_wrap package is ..'|| sqlerrm(sqlcode));
         end if;
end get_dest_locator;

end wms_atf_dest_locator;

/
