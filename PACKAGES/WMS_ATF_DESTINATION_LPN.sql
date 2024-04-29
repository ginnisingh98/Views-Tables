--------------------------------------------------------
--  DDL for Package WMS_ATF_DESTINATION_LPN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ATF_DESTINATION_LPN" AUTHID CURRENT_USER as
 /* $Header: WMSADLPS.pls 115.5 2003/11/03 21:19:08 joabraha noship $ */
--
-- ------------------------------------------------------------------------------------
-- |---------------------< trace >-----------------------------------------------------|
-- ------------------------------------------------------------------------------------
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
--   ----------  ---- -------- ---------------------------------------
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
,  p_level    in number  default 4
);
--
-- --------------------------------------------------------------------------------------
-- |----------------------------< Get_Destination_LPN >----------------------------------|
-- --------------------------------------------------------------------------------------
Procedure get_seed_dest_lpn (
   x_return_status        out nocopy varchar2
,  x_msg_count            out nocopy number
,  x_msg_data             out nocopy varchar2
,  x_lpn_id               out nocopy number
,  x_lpn_valid            out nocopy varchar2
,  p_mode                 in  number default 1
,  p_task_id              in  number
,  p_activity_type_id     in  number default 1
,  p_lpn_id               in  number default null
,  p_item_id              in  number default null
,  p_subinventory_code    in  varchar2
,  p_locator_id           in  number
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
);

end wms_atf_destination_lpn;

 

/
