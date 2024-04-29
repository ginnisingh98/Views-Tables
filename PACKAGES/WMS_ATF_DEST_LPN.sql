--------------------------------------------------------
--  DDL for Package WMS_ATF_DEST_LPN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ATF_DEST_LPN" AUTHID CURRENT_USER as
 /* $Header: WMSDLPNS.pls 115.6 2003/11/03 21:16:58 joabraha noship $ */
--
-- -----------------------------------------------------------------------------
-- |------------------------< get_dest_lpn >------------------------------------|
-- -----------------------------------------------------------------------------
-- API name    : get_dest_lpn
-- Type        : Private
-- Function    : Returns Sub/Loc or Locator Validation Status.
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
,  p_mode                in  number default 1    -- 1. Selection  2. Validation
,  p_task_id             in  number              -- MMTT.transaction_temp_id
,  p_activity_type_id    in  number default 1    -- 1. Inbound   2. Outbound
,  p_hook_call_id	 in  number              -- Seeded/Custom API call hook id in the wms_api_hook_calls.
,  p_lpn_id              in  number default null -- LPN ID for Validation pruposes.
,  p_item_id             in  number default null -- Item ID for Validation purposes.
,  p_subinventory_code   in  varchar2            -- Subinventory code passed from WMSATFRB.pls
,  p_locator_id          in  number              -- Locator ID passed from WMSATFRB.pls
,  p_api_version         in  number
,  p_init_msg_list       in  varchar2
,  p_commit              in  varchar2
);
--
--
Procedure trace(
   p_message  in varchar2
,  p_level    in number default 4
);
end wms_atf_dest_lpn;

 

/
