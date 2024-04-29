--------------------------------------------------------
--  DDL for Package Body WMS_GET_DEST_LOC_LPN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_GET_DEST_LOC_LPN" as
 /* $Header: WMSDLLWB.pls 115.10 2003/11/03 21:18:13 joabraha noship $ */
--
l_debug                 number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
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
      INV_LOG_UTIL.trace(p_message, 'WMS_GET_DEST_LOC_LPN', p_level);
end trace;
--
-- ---------------------------------------------------------------------------------
-- |-----------------------< wms_dest_loc_w_item >----------------------------------|
-- ---------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns selected Locator or validates Locator passed in with Item restriction.
--
-- Prerequisites:
--
-- In Parameters:
--   Name                    Reqd Type      Description
--   ---------------------   ---- --------  ---------------------------
--   p_mode                  Yes  number    Mode indicating call is
--                                          1. Selection  2. Validation
--   p_task_id               Yes  varchar2  MMTT.transaction_temp_id
--   p_activity_type_id      Yes  varchar2  Activity Type :
--                                          1  Inbound
--                                          2  Outbound
--   p_locator_id            No  number     Location ID passed in for
--                                          validation when called with
--                                          p_mode = 2.
--   p_item_id               Yes  number    Item ID passed in for
--                                          Restriction purposes..
-- Post Success:
--   Returns a selected a Locator ID or validates a Locator ID.
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--

Procedure wms_dest_loc_w_item(
   x_return_status       out nocopy varchar2
,  x_msg_count           out nocopy number
,  x_msg_data            out nocopy varchar2
,  x_locator_id          out nocopy number
,  x_zone_id             out nocopy number
,  x_subinventory_code   out nocopy varchar2
,  x_loc_valid           out nocopy varchar2
,  p_mode                in  number
,  p_task_id             in  number
,  p_activity_type_id    in  number
,  p_locator_id          in  number
,  p_item_id             in  number
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
) is

  l_proc        varchar2(72) := 'WMS_DEST_LOC_W_ITEM :';
  l_prog        float;

begin
   -- ### Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if (l_debug = 1) then
      trace(l_proc ||' Entering "wms_get_dest_loc_lpn.wms_dest_loc_w_item"... '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc ||'   ');
      trace(l_proc ||'   ');
      trace(l_proc ||' Before calling package "wms_atf_dest_loc.get_seed_dest_loc"....', 1);
      trace(l_proc ||' Input parameters...');
      trace(l_proc ||' p_mode => ' || p_mode);
      trace(l_proc ||' p_task_id => ' || p_task_id);
      trace(l_proc ||' p_activity_type_id  => ' || p_activity_type_id);
      trace(l_proc ||' p_locator_id => ' || p_locator_id);
      trace(l_proc ||' p_item_id => ' || p_item_id);
   end if;

   wms_atf_dest_loc.get_seed_dest_loc(
      x_return_status       => x_return_status
   ,  x_msg_count           => x_msg_count
   ,  x_msg_data            => x_msg_data
   ,  x_locator_id          => x_locator_id
   ,  x_zone_id             => x_zone_id
   ,  x_subinventory_code   => x_subinventory_code
   ,  x_loc_valid           => x_loc_valid
   ,  p_mode                => p_mode
   ,  p_task_id             => p_task_id
   ,  p_activity_type_id    => p_activity_type_id
   ,  p_locator_id          => p_locator_id
   ,  p_item_id             => p_item_id
   ,  p_api_version         => p_api_version
   ,  p_init_msg_list       => p_init_msg_list
   ,  p_commit              => p_commit

   );

   if (l_debug =1) then
      trace(l_proc ||' After calling package "wms_atf_dest_loc.get_seed_dest_loc"....', 1);
      trace(l_proc ||' Out parameters...');
      trace(l_proc ||' x_return_status = ' ||  x_return_status);
      trace(l_proc ||' x_locator_id = ' ||  x_locator_id);
      trace(l_proc ||' x_zone_id = ' ||  x_zone_id);
      trace(l_proc ||' x_subinventory_code = ' ||  x_subinventory_code);
      trace(l_proc ||' x_loc_valid = ' ||  x_loc_valid);
      trace(l_proc ||'   ');
      trace(l_proc ||'   ');
      trace(l_proc ||' Exiting procedure "wms_get_dest_loc_lpn.wms_dest_loc_w_item"....', 1);
   end if;

end wms_dest_loc_w_item;
--
--
-- ---------------------------------------------------------------------------------
-- |-----------------------< wms_dest_loc_wo_item >---------------------------------|
-- ---------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns selected Locator or validates Locator passed in without Item restriction.
--
-- Prerequisites:
--
-- In Parameters:
--   Name                    Reqd Type      Description
--   -------------------     ---- --------  ---------------------------
--   p_mode                  Yes  number    Mode indicating call is
--                                          1. Selection  2. Validation
--   p_task_id               Yes  varchar2  MMTT.transaction_temp_id
--   p_activity_type_id      Yes  varchar2  Activity Type :
--                                          1  Inbound
--                                          2  Outbound
--   p_locator_id            No  number     Location ID passed in for
--                                          validation when called with
--                                          p_mode = 2.
--   p_item_id               Yes  number    Item ID passed in for
--                                          Restriction purposes but not
--     					    used. This is to keep the
--                                          signature consistent.
-- Post Success:
--   Returns a selected a Locator ID or validates a Locator ID.
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--

Procedure wms_dest_loc_wo_item(
   x_return_status       out nocopy varchar2
,  x_msg_count           out nocopy number
,  x_msg_data            out nocopy varchar2
,  x_locator_id          out nocopy number
,  x_zone_id             out nocopy number
,  x_subinventory_code   out nocopy varchar2
,  x_loc_valid           out nocopy varchar2
,  p_mode                in  number
,  p_task_id             in  number
,  p_activity_type_id    in  number
,  p_locator_id          in  number
,  p_item_id             in  number
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
) is

  l_proc       varchar2(72) := 'WMS_DEST_LOC_WO_ITEM :';
  l_prog       float;

begin
   -- ### Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if (l_debug = 1) then
      trace(l_proc ||' Entering "wms_get_dest_loc_lpn.wms_dest_loc_wo_item"... '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc ||'   ');
      trace(l_proc ||'   ');
      trace(l_proc ||' Before calling package "wms_atf_dest_loc.get_seed_dest_loc"....', 1);
      trace(l_proc ||' Input parameters...');
      trace(l_proc ||' p_mode => ' || p_mode);
      trace(l_proc ||' p_task_id => ' || p_task_id);
      trace(l_proc ||' p_activity_type_id  => ' || p_activity_type_id);
      trace(l_proc ||' p_locator_id => ' || p_locator_id);
      trace(l_proc ||' p_item_id => ' || p_item_id);
   end if;

   wms_atf_dest_loc.get_seed_dest_loc(
      x_return_status       => x_return_status
   ,  x_msg_count           => x_msg_count
   ,  x_msg_data            => x_msg_data
   ,  x_locator_id          => x_locator_id
   ,  x_zone_id             => x_zone_id
   ,  x_subinventory_code   => x_subinventory_code
   ,  x_loc_valid           => x_loc_valid
   ,  p_mode                => p_mode
   ,  p_task_id             => p_task_id
   ,  p_activity_type_id    => p_activity_type_id
   ,  p_locator_id          => p_locator_id
   ,  p_api_version         => p_api_version
   ,  p_init_msg_list       => p_init_msg_list
   ,  p_commit              => p_commit
   );

   if (l_debug =1) then
      trace(l_proc ||' After calling package "wms_atf_dest_loc.get_seed_dest_loc"....', 1);
      trace(l_proc ||' Out parameters...');
      trace(l_proc ||' x_return_status = ' ||  x_return_status);
      trace(l_proc ||' x_locator_id = ' ||  x_locator_id);
      trace(l_proc ||' x_zone_id = ' ||  x_zone_id);
      trace(l_proc ||' x_subinventory_code = ' ||  x_subinventory_code);
      trace(l_proc ||' x_loc_valid = ' ||  x_loc_valid);
      trace(l_proc ||'   ');
      trace(l_proc ||'   ');
      trace(l_proc ||' Exiting procedure "wms_get_dest_loc_lpn.wms_dest_loc_wo_item"....', 1);
   end if;

end wms_dest_loc_wo_item;
--
--
-- ---------------------------------------------------------------------------------
-- |-----------------------< wms_dest_lpn_w_item >----------------------------------|
-- ---------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns selected LPN or validates LPN passed in, with Item restriction.
--
-- Prerequisites:
--
-- In Parameters:
--   Name                    Reqd Type      Description
--   -------------------     ---- --------  ---------------------------
--   p_mode                  Yes  number    Mode indicating call is
--                                          1. Selection  2. Validation
--   p_task_id               Yes  varchar2  MMTT.transaction_temp_id
--   p_activity_type_id      Yes  varchar2  Activity Type :
--                                          1  Inbound
--                                          2  Outbound
--   p_lpn_id                No  number     LPN ID passed in for
--                                          validation when called with
--                                          p_mode = 2.
--   p_item_id               Yes  number    Item ID passed in for
--                                          Restriction purposes..
--
-- Post Success:
--   Returns a selected a Locator ID or validates a Locator ID.
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--

Procedure wms_dest_lpn_w_item(
   x_return_status       out nocopy varchar2
,  x_msg_count           out nocopy number
,  x_msg_data            out nocopy varchar2
,  x_lpn_id              out nocopy number
,  x_lpn_valid           out nocopy varchar2
,  p_mode                in  number
,  p_task_id             in  number
,  p_activity_type_id    in  number
,  p_lpn_id              in  number
,  p_item_id             in  number
,  p_subinventory_code   in  varchar2
,  p_locator_id          in  number
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
) is

  l_proc        varchar2(72) := 'WMS_DEST_LPN_W_ITEM :';
  l_prog        float;

begin
   -- ### Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if (l_debug = 1) then
      trace(l_proc ||' Entering "wms_get_dest_loc_lpn.wms_dest_lpn_w_item"... '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc ||'   ');
      trace(l_proc ||'   ');
      trace(l_proc ||' Before calling package "wms_atf_dest_loc.get_seed_dest_lpn"....', 1);
      trace(l_proc ||' Input parameters...');
      trace(l_proc ||' p_mode => ' || p_mode);
      trace(l_proc ||' p_task_id => ' || p_task_id);
      trace(l_proc ||' p_activity_type_id  => ' || p_activity_type_id);
      trace(l_proc ||' p_lpn_id => ' || p_lpn_id);
      trace(l_proc ||' p_item_id => ' || p_item_id);
      trace(l_proc ||' p_subinventory_code => ' || p_subinventory_code, 4);
      trace(l_proc ||' p_locator_id => ' || p_locator_id, 4);
   end if;

   wms_atf_destination_lpn.get_seed_dest_lpn(
      x_return_status       => x_return_status
   ,  x_msg_count           => x_msg_count
   ,  x_msg_data            => x_msg_data
   ,  x_lpn_id              => x_lpn_id
   ,  x_lpn_valid           => x_lpn_valid
   ,  p_mode                => p_mode
   ,  p_task_id             => p_task_id
   ,  p_activity_type_id    => p_activity_type_id
   ,  p_lpn_id              => p_lpn_id
   ,  p_item_id             => p_item_id
   ,  p_subinventory_code   => p_subinventory_code
   ,  p_locator_id          => p_locator_id
   ,  p_api_version         => p_api_version
   ,  p_init_msg_list       => p_init_msg_list
   ,  p_commit              => p_commit
   );

   if (l_debug =1) then
      trace(l_proc ||' After calling package "wms_atf_dest_loc.get_seed_dest_loc"....', 1);
      trace(l_proc ||' Out parameters...');
      trace(l_proc ||' x_return_status = ' ||  x_return_status);
      trace(l_proc ||' x_lpn_id = ' ||  x_lpn_id);
      trace(l_proc ||' x_lpn_valid = ' ||  x_lpn_valid);
      trace(l_proc ||'   ');
      trace(l_proc ||'   ');
      trace(l_proc ||' Exiting procedure "wms_get_dest_loc_lpn.wms_dest_lpn_w_item"....', 1);
   end if;

end wms_dest_lpn_w_item;
--
--
-- ---------------------------------------------------------------------------------
-- |-----------------------< wms_dest_lpn_wo_item >---------------------------------|
-- ---------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns selected LPN or validates LPN passed in, with Item restriction.
--
-- Prerequisites:
--
-- In Parameters:
--   Name                    Reqd Type      Description
--   -------------------     ---- --------  ---------------------------
--   p_mode                  Yes  number    Mode indicating call is
--                                          1. Selection  2. Validation
--   p_task_id               Yes  varchar2  MMTT.transaction_temp_id
--   p_activity_type_id      Yes  varchar2  Activity Type :
--                                          1  Inbound
--                                          2  Outbound
--   p_lpn_id                No  number     LPN ID passed in for
--                                          validation when called with
--                                          p_mode = 2.
-- Post Success:
--   Returns a selected a Locator IDor validates a Locator ID.
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--

Procedure wms_dest_lpn_wo_item(
   x_return_status       out nocopy varchar2
,  x_msg_count           out nocopy number
,  x_msg_data            out nocopy varchar2
,  x_lpn_id              out nocopy number
,  x_lpn_valid           out nocopy varchar2
,  p_mode                in  number
,  p_task_id             in  number
,  p_activity_type_id    in  number
,  p_lpn_id              in  number
,  p_item_id             in  number
,  p_subinventory_code   in  varchar2
,  p_locator_id          in  number
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
) is

   l_proc       varchar2(72) := 'WMS_DEST_LPN_WO_ITEM :';
   l_prog       float;

begin
   -- ### Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if (l_debug = 1) then
      trace(l_proc ||' Entering "wms_get_dest_loc_lpn.wms_dest_lpn_wo_item"... '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc ||'   ');
      trace(l_proc ||'   ');
      trace(l_proc ||' Before calling package "wms_atf_dest_loc.get_seed_dest_lpn"....', 1);
      trace(l_proc ||' Input parameters...');
      trace(l_proc ||' p_mode => ' || p_mode);
      trace(l_proc ||' p_task_id => ' || p_task_id);
      trace(l_proc ||' p_activity_type_id  => ' || p_activity_type_id);
      trace(l_proc ||' p_lpn_id => ' || p_lpn_id);
      trace(l_proc ||' p_item_id => ' || p_item_id);
      trace(l_proc ||' p_subinventory_code => ' || p_subinventory_code, 4);
      trace(l_proc ||' p_locator_id => ' || p_locator_id, 4);
   end if;

   wms_atf_destination_lpn.get_seed_dest_lpn(
      x_return_status       => x_return_status
   ,  x_msg_count           => x_msg_count
   ,  x_msg_data            => x_msg_data
   ,  x_lpn_id              => x_lpn_id
   ,  x_lpn_valid           => x_lpn_valid
   ,  p_mode                => p_mode
   ,  p_task_id             => p_task_id
   ,  p_activity_type_id    => p_activity_type_id
   ,  p_lpn_id              => p_lpn_id
   ,  p_subinventory_code   => p_subinventory_code
   ,  p_locator_id          => p_locator_id
   ,  p_api_version         => p_api_version
   ,  p_init_msg_list       => p_init_msg_list
   ,  p_commit              => p_commit
   );

   if (l_debug =1) then
      trace(l_proc ||' After calling package "wms_atf_dest_loc.get_seed_dest_loc"....', 1);
      trace(l_proc ||' Out parameters...');
      trace(l_proc ||' x_return_status = ' ||  x_return_status);
      trace(l_proc ||' x_lpn_id = ' ||  x_lpn_id);
      trace(l_proc ||' x_lpn_valid = ' ||  x_lpn_valid);
      trace(l_proc ||'   ');
      trace(l_proc ||'   ');
      trace(l_proc ||' Exiting procedure "wms_get_dest_loc_lpn.wms_dest_lpn_wo_item"....', 1);
   end if;

end wms_dest_lpn_wo_item;

end wms_get_dest_loc_lpn;

/
