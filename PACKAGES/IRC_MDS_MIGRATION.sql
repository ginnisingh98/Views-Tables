--------------------------------------------------------
--  DDL for Package IRC_MDS_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_MDS_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: irmdsmig.pkh 120.0 2005/07/26 15:14:52 mbocutt noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< migrateJobSearchData >------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of job search records. For each ID in the
--   range the IRC_SEARCH_CRITERIA table is udpated.
--
--
procedure migrateJobSearchData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);


-- ----------------------------------------------------------------------------
-- |--------------------------< createworkPrefsData >------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure creates work preferences for existing candidates. For each
--   PERSONID in IRC_NOTIFICATION_PREFERENCES , a record is inserted into
--   IRC_SEARCH_CRITERIA.
--
procedure createworkPrefsData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);

end irc_mds_migration;

 

/
