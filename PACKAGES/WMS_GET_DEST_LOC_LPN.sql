--------------------------------------------------------
--  DDL for Package WMS_GET_DEST_LOC_LPN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_GET_DEST_LOC_LPN" AUTHID CURRENT_USER as
 /* $Header: WMSDLLWS.pls 115.9 2003/11/03 21:18:00 joabraha noship $ */
--
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
,  p_level    in number default 4
);
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
--   p_call_hook_id          Yes  number    Seeded/Custom API call hook
--                                          id in the wms_api_hook_calls
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
,  p_mode                in  number default 1
,  p_task_id             in  number
,  p_activity_type_id    in  number default 1
,  p_locator_id          in  number default null
,  p_item_id             in  number default null
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
);
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
--   p_call_hook_id          Yes  number    Seeded/Custom API call hook
--                                          id in the wms_api_hook_calls
--   p_locator_id            No  number     Location ID passed in for
--                                          validation when called with
--                                          p_mode = 2.
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
Procedure wms_dest_loc_wo_item(
   x_return_status       out nocopy varchar2
,  x_msg_count           out nocopy number
,  x_msg_data            out nocopy varchar2
,  x_locator_id          out nocopy number
,  x_zone_id             out nocopy number
,  x_subinventory_code   out nocopy varchar2
,  x_loc_valid           out nocopy varchar2
,  p_mode                in  number default 1
,  p_task_id             in  number
,  p_activity_type_id    in  number default 1
,  p_locator_id          in  number default null
,  p_item_id             in  number default null
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
);

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
--   p_call_hook_id          Yes  number    Seeded/Custom API call hook
--                                          id in the wms_api_hook_calls
--   p_lpn_id                No  number     LPN ID passed in for
--                                          validation when called with
--                                          p_mode = 2.
--   p_item_id               Yes  number    Item ID passed in for
--                                          Restriction purposes..
--
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
,  p_mode                in  number default 1
,  p_task_id             in  number
,  p_activity_type_id    in  number default 1
,  p_lpn_id              in  number default null
,  p_item_id             in  number default null
,  p_subinventory_code   in  varchar2
,  p_locator_id          in  number
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
);
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
--   p_call_hook_id          Yes  number    Seeded/Custom API call hook
--                                          id in the wms_api_hook_calls
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
,  p_mode                in  number default 1
,  p_task_id             in  number
,  p_activity_type_id    in  number default 1
,  p_lpn_id              in  number default null
,  p_item_id             in  number default null
,  p_subinventory_code   in  varchar2
,  p_locator_id          in  number
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
);
--
--
end wms_get_dest_loc_lpn;

 

/
