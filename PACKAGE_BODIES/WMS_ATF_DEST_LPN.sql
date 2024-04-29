--------------------------------------------------------
--  DDL for Package Body WMS_ATF_DEST_LPN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ATF_DEST_LPN" as
 /* $Header: WMSDLPNB.pls 115.10 2003/11/03 21:17:12 joabraha noship $ */
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
      INV_LOG_UTIL.trace(p_message, 'SEED_LOC_API', p_level);
end trace;
--
-- -----------------------------------------------------------------------------|
-- |------------------------< get_dest_lpn >------------------------------------|
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
PROCEDURE get_dest_lpn(
   x_return_status       out nocopy varchar2
,  x_msg_count           out nocopy number
,  x_msg_data            out nocopy varchar2
,  x_lpn_id              out nocopy number
,  x_valid_flag          out nocopy varchar2
,  p_mode                in  number -- 1. Selection  2. Validation
,  p_task_id             in  number -- MMTT.transaction_temp_id
,  p_activity_type_id    in  number -- 1. Inbound   2. Outbound
,  p_hook_call_id	 in  number -- Seeded/Custom API call hook id in the wms_api_hook_calls.
,  p_lpn_id              in  number -- LPN ID for Validation purposes.
,  p_item_id             in  number -- Item ID for Validation purposes.
,  p_subinventory_code   in  varchar2 -- Subinventory code passed from WMSATFRB.pls
,  p_locator_id          in  number -- Locator ID passed from WMSATFRB.pls
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
)
is

cursor c_get_hook_call_details is
select wahe.current_package_cntr
from   wms_api_hook_calls wahc, wms_api_hooked_entities wahe
where  wahe.module_hook_id = wahc.module_hook_id
and    wahe.short_name_id = 2                    -- Restricts the output to "LPN Selection/Validation" only
and    wahc.hook_call_id = p_hook_call_id;

l_debug  			number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_proc                          varchar2(72) := 'GET_DEST_LPN :';
l_current_package_cntr		number;

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
      trace(l_proc ||' p_lpn_id => ' || p_lpn_id);
      trace(l_proc ||' p_item_id => ' || p_item_id, 4);
      trace(l_proc ||' p_subinventory_code => ' || p_subinventory_code, 4);
      trace(l_proc ||' p_locator_id => ' || p_locator_id, 4);
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
   into  l_current_package_cntr;

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
         end if;

         -- ### Check if p_mode is 'Validation' and the p_locator_id is null.
         if (p_mode = 2 and p_lpn_id is null)
         then
             if (l_debug =1) then
                trace(l_proc ||' LPN ID cannot be null if "wms_atf_dest_lPN.get_dest_lPN" is called in validation mode');
             end if;
             return;
         end if;
         -- ###
         -- ### This means that the call is to select/validate LPN.
         -- ### Also call the current package based on the counter.
         -- ###
         -- ### Validation mode is not enabled for LPN's in patchset 'J'.
         -- ###
         -- ### Procedure  GET_LPN(
	 -- ### x_return_status                  OUT  VARCHAR2,
	 -- ### x_msg_count                      OUT  NUMBER,
	 -- ### x_msg_data                       OUT  VARCHAR2,
	 -- ### x_lpn_id                         OUT  NUMBER,
	 -- ### x_lpn_valid                      OUT  VARCHAR2,
	 -- ### p_mode                           IN  NUMBER,
	 -- ### p_activity_type_id               IN  NUMBER,
	 -- ### p_task_id                        IN  NUMBER,
	 -- ### p_lpn_id                         IN  NUMBER,
	 -- ### p_item_id                        IN  NUMBER,
	 -- ### p_subinventory_code              IN  VARCHAR2
	 -- ### p_locator_id                     IN  NUMBER
	 -- ### p_hook_call_id                   IN  NUMBER
	 -- ### );

         if l_current_package_cntr = 1
         then
            	wms_api_lpn_package_1.get_lpn(
            	   x_return_status        => x_return_status
            	,  x_msg_count            => x_msg_count
            	,  x_msg_data             => x_msg_data
            	,  x_lpn_id               => x_lpn_id
            	,  x_lpn_valid            => x_valid_flag
            	,  p_mode                 => p_mode
            	,  p_activity_type_id     => p_activity_type_id
            	,  p_task_id              => p_task_id
            	,  p_lpn_id               => p_lpn_id
            	,  p_item_id              => p_item_id
            	,  p_subinventory_code    => p_subinventory_code
            	,  p_locator_id           => p_locator_id
                ,  p_api_version          => p_api_version
                ,  p_init_msg_list        => p_init_msg_list
                ,  p_commit               => p_commit
            	,  p_hook_call_id         => p_hook_call_id
            	);
         elsif l_current_package_cntr = 2
         then
            	wms_api_lpn_package_2.get_lpn(
            	   x_return_status        => x_return_status
            	,  x_msg_count            => x_msg_count
            	,  x_msg_data             => x_msg_data
            	,  x_lpn_id               => x_lpn_id
            	,  x_lpn_valid            => x_valid_flag
            	,  p_mode                 => p_mode
            	,  p_activity_type_id     => p_activity_type_id
            	,  p_task_id              => p_task_id
            	,  p_lpn_id               => p_lpn_id
            	,  p_item_id              => p_item_id
            	,  p_subinventory_code    => p_subinventory_code
            	,  p_locator_id           => p_locator_id
                ,  p_api_version          => p_api_version
                ,  p_init_msg_list        => p_init_msg_list
                ,  p_commit               => p_commit
            	,  p_hook_call_id         => p_hook_call_id
            	);
         end if;
         if (l_debug = 1) then
            trace(l_proc ||' Exiting package wms_atf_dest_loc_lpn_wrap  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
            trace(l_proc ||' Exiting procedure get_dest_loc_lpn_wrap  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
            trace(l_proc ||'   x_lpn_id      => ' || x_lpn_id);
            trace(l_proc ||'   x_valid_flag    => ' || x_valid_flag, 4);
         end if;
      end if;
      close c_get_hook_call_details;
exception
    when others then
         close c_get_hook_call_details;

         if (l_debug = 1) then
            trace(l_proc ||' Error within "When Others" of the Outermost block in the get_dest_loc_lpn_wrap package is ..'|| sqlerrm(sqlcode));
         end if;
end get_dest_lpn;

end wms_atf_dest_lpn;

/
