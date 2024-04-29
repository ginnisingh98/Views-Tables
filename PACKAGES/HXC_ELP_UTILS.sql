--------------------------------------------------------
--  DDL for Package HXC_ELP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ELP_UTILS" AUTHID CURRENT_USER as
/* $Header: hxcelputl.pkh 115.2 2003/04/28 13:56:40 ksethi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_elp_utils.';  -- Global package name


-- global PL/SQL records and tables


-- ----------------------------------------------------------------------------
-- |------------------------< set_time_bb_appl_set_id >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--  This will be called from the deposit wrapper,
--  in case Entry Level Processing is being used.
--  This will update the global timecard with the
--  application set id that needs to be populated
--  with each and evey time builiding block.
-- Prerequisites:
--
-- Process time entry and entry level processing data has been setup for the
-- resource.
--
-- In Parameters:
--   Name                           Reqd Type          Description
--
--   p_time_building_blocks         Yes  g_timecard    Global timecard object
--   p_time_attributes		    Yes  g_attributes  Global attributes object
--   p_messages               	    Yes  g_messages    Global messages table
--   p_pte_terg_id		    Yes  number        PTE MME id set at the user pref level
--   p_application_set_id	    Yes  number        Applcaiton set id set at the user pref level
--
-- Post Success:
--
--   g_timecard is populated with the appropriate
--	application set id along with each time building block
--
-- Post Failure:
--
--   an application error is raised
--
-- Access Status:
--   Public.
--
PROCEDURE set_time_bb_appl_set_id
                 (P_TIME_BUILDING_BLOCKS IN OUT NOCOPY	HXC_BLOCK_TABLE_TYPE
     	    	 ,P_TIME_ATTRIBUTES 	 IN OUT NOCOPY	HXC_ATTRIBUTE_TABLE_TYPE
     	    	 ,P_MESSAGES		 IN OUT NOCOPY  hxc_self_service_time_deposit.message_table
     	    	 ,P_PTE_TERG_ID          IN     number
     	    	 ,P_APPLICATION_SET_ID   IN     number
            	 );


-- ----------------------------------------------------------------------------
-- |------------------------< build_elp_objects >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--  This will be called from the deposit wrapper,
--  in case Entry Level Processing is being used.
--  The procedure will return two new filtered timecard and attributes
--  table, based on the current application set validation
--
-- Prerequisites:
--
-- Process time entry and entry level processing data has been setup for the
-- resource and application set id is populated with all time building blocks.
--
-- In Parameters:
--   Name                           Reqd Type          Description
--
--   p_time_building_blocks         Yes  g_timecard    ELP timecard object
--   p_time_attributes		    Yes  g_attributes  ELP attributes object
--   p_time_recipient_id	    Yes  number        Time recipient id
--
-- Post Success:
--
--   A filtered g_time_building_block is populated which
--   is then used for the application set validation.
--
-- Post Failure:
--
--   an application error is raised
--
-- Access Status:
--   Public.
--
FUNCTION build_elp_objects
                 (P_ELP_TIME_BUILDING_BLOCKS  HXC_BLOCK_TABLE_TYPE
     	    	 ,P_ELP_TIME_ATTRIBUTES       HXC_ATTRIBUTE_TABLE_TYPE
     	    	 ,P_TIME_RECIPIENT_ID         number
            	 ) RETURN HXC_BLOCK_TABLE_TYPE;


-- ----------------------------------------------------------------------------
-- |------------------------< set_time_bb_appl_set_tk >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--  This will be called from the TimeKeeper deposit wrapper,
--  irrespective of ELP being used or not,
--  This will update the global timecard with the
--  application set id with the one at the user preference
--  with each and evey time builiding block.
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type          Description
--
--   p_time_building_blocks         Yes  g_timecard    Global timecard object
--   p_application_set_id	    Yes  number        Applcaiton set id set at the user pref level
--
-- Post Success:
--
--   g_timecard is populated with the
--	application set id along with each time building block
--
-- Post Failure:
--
--   an application error is raised
--
-- Access Status:
--   Public.
--
		PROCEDURE set_time_bb_appl_set_tk
                 (P_TIME_BUILDING_BLOCKS IN OUT NOCOPY	hxc_self_service_time_deposit.timecard_info
     	    	 ,P_APPLICATION_SET_ID   IN     number
            	 );

end hxc_elp_utils;

 

/
