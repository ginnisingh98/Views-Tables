--------------------------------------------------------
--  DDL for Package WMS_ATF_DEST_LOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ATF_DEST_LOC" AUTHID CURRENT_USER as
 /* $Header: WMSADLOS.pls 115.4 2003/11/03 21:18:37 joabraha noship $ */
--
-- --------------------------------------------------------------------------------------
-- |----------------------------< get_seed_dest_loc >------------------------------------|
-- --------------------------------------------------------------------------------------
-- Note about the Input parameters:
-- The p_mode is the input parameters which takes in the call mode for the API.
-- Valid call modes are as follows:
-- 1 =  Selection Mode.
-- 2 =  Verification Mode.
-- When called with mode of 'Selection', the API returns a locator ID while in the
-- 'Verification' mode, the API send out a status verifying if the locator ID passed
-- is valid or otherwise.
Procedure get_seed_dest_loc (
   x_return_status        out nocopy varchar2
,  x_msg_count            out nocopy number
,  x_msg_data             out nocopy varchar2
,  x_locator_id           out nocopy number
,  x_zone_id              out nocopy number
,  x_subinventory_code    out nocopy varchar2
,  x_loc_valid            out nocopy varchar2
,  p_mode                 in  number default 1
,  p_task_id              in  number
,  p_activity_type_id     in  number default 1
,  p_locator_id           in  number default null
,  p_item_id              in  number default null
,  p_api_version          in  number
,  p_init_msg_list        in  varchar2
,  p_commit               in  varchar2
);
--
--
Procedure trace(
   p_message  in varchar2
,  p_level    in number default 4
);
--
--

end wms_atf_dest_loc;

 

/
