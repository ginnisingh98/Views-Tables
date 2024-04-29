--------------------------------------------------------
--  DDL for Package OTA_CLASSIC_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CLASSIC_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: otclassicupg.pkh 120.2.12000000.2 2007/02/13 13:59:51 vkkolla noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< Upgrade_Category >----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure does the following :
-- 1. Updates ota_booking_deals.category with category_usage_id
-- 2. Updates ota_category_usages.Category with Meaning from
--    lookup table (earlier it stores lookup code)
-- 3. Populates the category translation table ota_category_usages_tl

procedure Upgrade_Category(
   p_process_control IN		varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1);

-- ----------------------------------------------------------------------------
-- |-------------------< Create_Activity_for_Category >-----------------------|
-- ----------------------------------------------------------------------------
-- This procedure creates the Activity typ for each category exists in
-- Ota_category_usages table.
procedure Create_Activity_for_Category(
   p_process_control IN		varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1 );


-- ----------------------------------------------------------------------------
-- |-------------------< Create_Category_for_Activity >-----------------------|
-- ----------------------------------------------------------------------------
-- This procedure does the following
-- 1. Creates a Category for each BG in ota_activity_definitions
--    and ota_category_usages. And this new category will be the
--    parent category for other categories(belongs to that BG).
-- 2. Creates Category for each Activity types, which are not
--    as part of step 3. Attaches the newly created category to
--    Activity versions exist under the equivalent Activity type.
--    If NO primary category specified for that Activity version,
--    then newly created category will be the primary.

procedure Create_Category_for_Activity(
    p_process_control IN	varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1 );

-- ----------------------------------------------------------------------------
-- |------------------------< Create_Offerings >----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure creates the Offering based on the records exists in ota_events
-- and ota_activity_versions table.
Procedure Create_Offering(
 p_process_control 	IN varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1 );


   Procedure add_log_entry(p_upgrade_id in number
                        ,p_table_name in varchar2
                        ,p_business_group_id in number default null
                        ,p_source_primary_key in varchar2
                        ,p_object_value  in varchar2 default null
                        ,p_message_text  in varchar2 default null
                        ,p_process_date in date
			,p_log_type in varchar2 default null
			,p_upgrade_name in varchar2 default null);

Procedure create_ctg_dm_for_act_bg(p_update_id in number default 1 );

Procedure  Migrate_Lookup (p_update_id in number default 1 );

function get_process_date (p_upgrade_id in number
                           ,p_upgrade_name in varchar2)
                            return date;


  function get_apps_timezone(ila_tzone in varchar2) return varchar2;
  -- Required to be able to use get_apps_timezone in update statement in Upgrade_Events
  pragma restrict_references (get_apps_timezone , WNDS);

    Procedure Upgrade_Events(   p_process_control IN  varchar2,
                            p_start_pkid      IN  number,
                            p_end_pkid        IN  number,
                            p_rows_processed  OUT nocopy number,
                            p_update_id in number default 1 ) ;


  Procedure Upgrade_Event_Associations(
                            p_process_control IN  varchar2,
                            p_start_pkid      IN  number,
                            p_end_pkid        IN  number,
                            p_rows_processed  OUT nocopy number,
                            p_update_id in number default 1 ) ;


   function get_offering_name_with_lang(p_off_name      in varchar2,
                                     p_language_id in number,
                                     p_language      in varchar2 )
  return varchar2;
  pragma restrict_references (get_offering_name_with_lang , WNDS);


     procedure submit_upgrade_report;

      procedure validate_proc_for_hr_upg(do_upg out nocopy varchar2) ;


      -- To be called as the last procedure in ottadupg.sql
      procedure upgrade_root_category_dates;

        procedure upgrade_online_delivery_modes (p_upgrade_id in number default 1);

	procedure upgrade_act_cat_inclusions;

	 procedure create_root_ctg_and_dms;

	procedure migrate_tad_dff_contexts (p_upgrade_id in number default 1);


-- ----------------------------------------------------------------------------
-- |---------------------< upgrade_lp_history_flag >--------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will update ota_lp_enrollments table record is_history_flag to 'Y'
-- where learning path enrollment status is 'Completed'

PROCEDURE upgrade_lp_history_flag(
   p_process_control IN		varchar2,
   p_start_rowid     IN         rowid,
   p_end_rowid       IN         rowid,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1    ) ;



--enh 2733966 --
-- ----------------------------------------------------------------------------
-- |--------------------------< Upgrade_Language_Code >------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will check if LANUGAGE_CODE is null in OTA_OFFERINGS ---------
-- OTA_LEARNING_OBJECTS, OTA_COMPETENCE_LANGUAGES and populate the corresponding-
-- fnd_natural_languages.Language_Code from fnd_languages.Language_Id

Procedure Upgrade_Language_Code;


-- ----------------------------------------------------------------------------
-- |---------------------< upg_tdb_history_att_flags>-------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will update ota_delegate_bookings table records
--  a. successful_attendance_flag to 'Y' where it is NULL and enrollment status
--         is 'Attended'
--  b. is_history_flag to 'Y' where enrollment status is 'Attended'

PROCEDURE upg_tdb_history_att_flags(
   p_process_control IN		varchar2,
   p_start_rowid     IN           rowid,
   p_end_rowid       IN           rowid,
   p_rows_processed    OUT nocopy number,
   p_update_id in number default 1    ) ;

End Ota_classic_upgrade ;

 

/
