--------------------------------------------------------
--  DDL for Package HXC_SELF_SERVICE_TIMECARD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_SELF_SERVICE_TIMECARD_API" AUTHID CURRENT_USER AS
/* $Header: hxctcmapi.pkh 115.8 2002/11/27 20:05:24 jdupont noship $ */

--
-- ----------------------------------------------------------------------------
-- |------------------------< execute_deposit_process >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Allows the user to enter timecards into the OTL time store
--              The user must have an understanding of the TIMECARD_INFO and
--              ATTRIBUTE_INFO PL/SQL data structures
--
--              It is suggested that the timecard deposit be called once per
--              timecard.
--
--              Timecards can be deposited, deleted or migrated (see P_MODE
--              for further details).
--
--
-- Prerequisites: OTL
--
--
-- In Parameters:
--   Name                Reqd Type     Description
--
--   p_validate          No   boolean  Validation mode switch
--
--   p_app_blocks        Yes  HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO
--                                     PL/SQL Table of time bld blk info
--                                     The time_building_block_id, parent
--                                     building_block_id and object_version
--                                     number columns must be set appropriately
--                                     and the NEW flag set to 'Y'
--
--   p_app_attributes         HXC_SELF_SERVICE_TIME_DEPOSIT.APP_ATTRIBUTES_INFO
--                                     PL/SQL table of time attributes.
--                                     The time_attribute_id and time_building_
--                                     block_id must also be set appropriately.
--
--   p_mode              Yes  varchar2 Controls what happens to the timecards.
--
--                                     'MIGRATION' - timecards are deposited
--                                     as 'Approved' and as though they have
--                                     been retrieved by the retrieval process
--                                     specified in the paramter of the same name.
--
--                                     'DELETE' - deletes the timecard.
--                                     NOTE: the date_to for all bld blks must be
--                                           set to a date other than 31-DEC-4712
--
--                                     'SUBMIT' - fires all validation (time entry
--                                      rules, recipient application, OTL ), creates
--                                      the timecard and initiates approval process.
--                                      In other words the same as submitting the
--                                      timecard through self service.
--
--                                     'WORKING' - creates the timecard with status
--                                      of working.
--                                      In other words the same as saving the
--                                      timecard for later through self service.
--
--   p_deposit_process   Yes  varchar2 The name of the recipient application
--                                     deposit process
--
--   p_retrieval_process Yes  varchar2 The name of the recipient application
--                                     retrieval process
--
-- Post Success:
--   Name                Reqd Type     Description
--
--   p_app_blocks        Yes  HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO
--
--                                     On successful deposit of the timecard
--                                     the actual values of time_building_block_id,
--                                     parent_time_building_block_id and object_
--                                     version_number will be set.
--                                     NOTE: the corresponding attribute table
--                                     values are not available
--
--   p_messages          Yes  HXC_SELF_SERVICE_TIME_DEPOSIT.MESSAGE_TABLE
--
--                                     PL/SQL table containing any application messages
--                                     which were raised during deposit
--
--   p_timecard_id       Yes  HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
--
--                                     The time_building_block_id of the 'TIMECARD'
--                                     scope time building block
--
--   p_timecard_ovn      Yes  HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
--
--                                     The object_version_number of the 'TIMECARD'
--                                     scope time building block
-- Post Failure:
--   Messages will be written to the p_messages table for interogation post
--   failure.
--
-- Access Status:
--   Public.
--

procedure execute_deposit_process                --AI9
   (p_validate       in boolean default FALSE
  ,p_app_blocks in out NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO
  ,p_app_attributes in HXC_SELF_SERVICE_TIME_DEPOSIT.APP_ATTRIBUTES_INFO
  ,p_messages out nocopy Hxc_Self_Service_Time_Deposit.Message_Table
  ,p_mode varchar2
  ,p_deposit_process varchar2
  ,p_retrieval_process varchar2 default null
  ,p_timecard_id out nocopy HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
  ,p_timecard_ovn out nocopy HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
  );

procedure timecard_pump
  (p_validate       in boolean default FALSE
  ,p_app_blocks in out NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.TIMECARD_INFO
  ,p_app_attributes in HXC_SELF_SERVICE_TIME_DEPOSIT.APP_ATTRIBUTES_INFO
  ,p_messages out nocopy Hxc_Self_Service_Time_Deposit.Message_Table
  ,p_mode in varchar2
  ,p_deposit_process varchar2
  ,p_retrieval_process varchar2 default null
  ,p_timecard_id out nocopy HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
  ,p_timecard_ovn out nocopy HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
  );

END hxc_self_service_timecard_api;

 

/
