--------------------------------------------------------
--  DDL for Package OTA_MLS_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_MLS_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: otmlsmig.pkh 115.0 2003/04/11 14:23:37 jbharath noship $ */

-- ---------------------------------------------------------------------------------------
-- |--------------------------< migrateActivityDefintionData >---------------------------|
-- ---------------------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of Activitydefintion records. For each ID in the
--   range the OTA_ACTIVITY_DEFINITIONS_TL table is populated for each installed language.
--
--
procedure migrateActivityDefinitionData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);

-- ---------------------------------------------------------------------------------
-- |-----------------------< migrateActivityVersionData >--------------------------|
-- ---------------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of Activity Version records. For each ID in the
--   range the OTA_ACTIVITY_VERSIONS_TL table is populated for each installed
--   language.
--
--
procedure migrateActivityVersionData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);
--
-- -----------------------------------------------------------------------
-- |-----------------------< migrateEventData >--------------------------|
-- -----------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of Event records. For each ID in the
--   range the OTA_EVENTS_TL table is populated for each installed
--   language.
--
procedure migrateEventData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);

-- ----------------------------------------------------------------------------------
-- |-----------------------< migrateBookingStatusTypeData >--------------------------|
-- ----------------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of Booking Status Type records. For each ID in the
--   range the OTA_BOOKING_STATUS_TYPES_TL table is populated for each installed
--   language.
--
procedure migrateBookingStatusTypeData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);
--
-- --------------------------------------------------------------------------
-- |-----------------------< migrateResourceData >--------------------------|
-- --------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of Resource records. For each ID in the
--   range the OTA_SUPPLIABLE_RESOURCESS_TL table is populated for each installed
--   language.
--
procedure migrateResourceData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);


end ota_mls_migration;

 

/
