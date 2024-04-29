--------------------------------------------------------
--  DDL for Package HXC_BLOCK_COLLECTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_BLOCK_COLLECTION_UTILS" AUTHID CURRENT_USER AS
/* $Header: hxcbkcout.pkh 120.1 2005/11/15 16:03:47 arundell noship $ */

--
-- ----------------------------------------------------------------------------
-- |-------------------<     get_application_period     >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the application period  block and attribute table
--   structures based on the passed application period id.  This procedure is
--   the same as get_timecard, with the exception that the timecard scope
--   block is replaced with an application period.  All days within the
--   application period are returned as its children, as are the details
--   associted with the application period from HXC_AP_DETAIL_LINKS.  The
--   security attributes are not returned with this structure, for middle-tier
--   performance reasons.  This procedure connects a dummy APPROVAL attribute
--   to the application period scope record, which contains information
--   about the time recipient associated with this approval period, who
--   actioned the approval notification, if available, and the actual
--   approval status.
--
-- Prerequisites:
--   A valid application period id must be passed.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_app_period_id                   Y number   App Period Id to fetch
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_blocks                          Y BLOCKS   Timecard blocks.
--   p_attributes                      Y ATTRIBUTETimecard attributes.
--
-- Post Success:
--   The block and attribute structures are populated as expected.  Note:
--   if the application period  id does not exist, then the returned
--   structures are not initialized, i.e. (p_blocks=null) is true.
--
-- Post Failure:
--   This function does not fail.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
   PROCEDURE get_application_period
     (p_app_period_id  in            hxc_time_building_blocks.time_building_block_id%type,
      p_blocks            out NOCOPY hxc_block_table_type,
      p_attributes        out NOCOPY hxc_attribute_table_type
     );
--
-- ----------------------------------------------------------------------------
-- |-------------------<     get_application_period     >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the application period  block and attribute table
--   structures based on the passed application period id.  This procedure is
--   the same as get_timecard, with the exception that the timecard scope
--   block is replaced with an application period.  All days within the
--   application period are returned as its children, as are the details
--   associted with the application period from HXC_AP_DETAIL_LINKS.  The
--   security attributes are not returned with this structure, for middle-tier
--   performance reasons.  This procedure connects a dummy APPROVAL attribute
--   to the application period scope record, which contains information
--   about the time recipient associated with this approval period, who
--   actioned the approval notification, if available, and the actual
--   approval status.
--
--   This overloaded version of the get_application_period procedure
--   obtains data associated with an application period that falls
--   between two dates.  This is useful, if for example, the application
--   period is longer than the timecard period.  The approval comments
--   page uses this version of the code rather than the other version to
--   account for longer or shorter application periods.
--
-- Prerequisites:
--   A valid application period id must be passed.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_app_period_id                   Y number   App Period Id to fetch
--   p_start_time                      N date     Start time of dates to fetch
--   p_stop_time                       N date     Stop time of dates to fetch
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_blocks                          Y BLOCKS   Timecard blocks.
--   p_attributes                      Y ATTRIBUTETimecard attributes.
--
-- Post Success:
--   The block and attribute structures are populated as expected.  Note:
--   if the application period  id does not exist, then the returned
--   structures are not initialized, i.e. (p_blocks=null) is true.
--
-- Post Failure:
--   This function does not fail.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
   PROCEDURE get_application_period
     (p_app_period_id  in            hxc_time_building_blocks.time_building_block_id%type,
      p_start_time     in            date,
      p_stop_time      in            date,
      p_blocks            out NOCOPY hxc_block_table_type,
      p_attributes        out NOCOPY hxc_attribute_table_type
     );
--
-- ----------------------------------------------------------------------------
-- |------------------------<     get_timecard     >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the timecard block and attribute table structures
--   based on the passed timecard id.  The structures are ordered, such that
--   the first block, with index 1, is the timecard, then the days appear
--   and finally the details.  This order is guaranteed.  The timecard
--   structures returned correspond to the timecard object for the latest
--   (active) timecard object version number.  Historical timecards can not
--   be obtained with this method.
--
-- Prerequisites:
--   A valid timecard id must be passed.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_timecard_id                     Y number   Timecard id to fetch
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_blocks                          Y BLOCKS   Timecard blocks.
--   p_attributes                      Y ATTRIBUTETimecard attributes.
--
-- Post Success:
--   The block and attribute structures are populated as expected.  Note:
--   if the timecard id does not exist, then the returned structures are
--   not initialized, i.e. (p_blocks=null) is true.
--
-- Post Failure:
--   This function does not fail.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
   PROCEDURE get_timecard
     (p_timecard_id    in            hxc_time_building_blocks.time_building_block_id%type,
      p_blocks            out NOCOPY hxc_block_table_type,
      p_attributes        out NOCOPY hxc_attribute_table_type
     );
--
-- ----------------------------------------------------------------------------
-- |------------------------<     get_timecard     >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the timecard block and attribute table structures
--   based on the passed timecard id.  The structures are ordered, such that
--   the first block, with index 1, is the timecard, then the days appear
--   and finally the details.  This order is guaranteed.  The timecard
--   structures returned correspond to the timecard object for the latest
--   (active) timecard object version number.  Historical timecards can not
--   be obtained with this method.  This overloaded version also returns
--   information about the translation display key of the timecard for use
--   in the self service timecard entry page.
--
-- Prerequisites:
--   A valid timecard id must be passed.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_timecard_id                     Y number   Timecard id to fetch
--   p_missing_rows                    Y Boolean  If true, display key info
--                                                is also returned.  No
--                                                display key info returned
--                                                otherwise.
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_blocks                          Y BLOCKS   Timecard blocks.
--   p_attributes                      Y ATTRIBUTETimecard attributes.
--   p_row_data                        Y Row Used Index of rows used
--   p_missing_rows                    Y Boolean  True if missing rows
--                                                False otherwise.
--
-- Post Success:
--   The block and attribute structures are populated as expected.  Note:
--   if the timecard id does not exist, then the returned structures are
--   not initialized, i.e. (p_blocks=null) is true.
--   If p_missing_rows was passed as true, the p_row_data structure will
--   be populated for the rows used by the timecard as per the translation
--   display keys of the timecard detail building blocks.
--   If this parameter was initially true, it will remain true if the
--   translation rows are not contiguous starting at 1 for the details.
--   If all rows are used, then this parameter will be returned as false,
--   if it was passed as true to begin with.
--   If p_missing_rows was false on entry to the call, no translation row
--   information is returned, and the value remains false.
--
-- Post Failure:
--   This function does not fail.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
   PROCEDURE get_timecard
     (p_timecard_id    in            hxc_time_building_blocks.time_building_block_id%type,
      p_blocks            out NOCOPY hxc_block_table_type,
      p_attributes        out NOCOPY hxc_attribute_table_type,
      p_row_data          out NOCOPY hxc_trans_display_key_utils.translation_row_used,
      p_missing_rows   in out NOCOPY boolean
     );
--
-- ----------------------------------------------------------------------------
-- |------------------------<     get_template     >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the template block and attribute table structures
--   based on the passed template id.  The structures are ordered, such that
--   the first block, with index 1, is the template, then the days appear
--   and finally the details.  This order is guaranteed.  The template
--   structures returned correspond to the template object for the latest
--   (active) template object version number.  Historical timecards can not
--   be obtained with this method.  This also returns the start and stop time
--   stamped on the dummy start and stop time of the template days, so that
--   the timecard/template retrieval code has easy access to this information
--   to reset the parent building blocks of the details (append) or to
--   reset the dates of the day building blocks based on the timecard period
--   (overwrrite).
--
-- Prerequisites:
--   A valid template id must be passed.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_template_id                     Y number   Timecard id to fetch
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_blocks                          Y BLOCKS   Template blocks.
--   p_attributes                      Y ATTRIBUTETemplate attributes.
--   p_template_start_time             Y date     Start date of the template
--   p_template_stop_time              Y date     Stop date of the template
--
-- Post Success:
--   The block and attribute structures are populated as expected.  Note:
--   if the template id does not exist, then the returned structures are
--   not initialized, i.e. (p_blocks=null) is true.
--   p_template_stat_time is set to the start time on the timecard-template
--   scope building block, and the p_template_stop_time is set to the
--   stop_time of the timecard-template scope building block.
--
-- Post Failure:
--   This function does not fail.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
   PROCEDURE get_template
     (p_template_id         in            hxc_time_building_blocks.time_building_block_id%type,
      p_blocks                out NOCOPY hxc_block_table_type,
      p_attributes            out NOCOPY hxc_attribute_table_type,
      p_template_start_time   out NOCOPY date,
      p_template_stop_time    out NOCOPY date
     );

END hxc_block_collection_utils;

 

/
