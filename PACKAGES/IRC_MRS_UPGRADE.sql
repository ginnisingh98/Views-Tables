--------------------------------------------------------
--  DDL for Package IRC_MRS_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_MRS_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: irmrsupg.pkh 120.0 2005/07/26 15:15:03 mbocutt noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< migrateVacancyRecSite >-----------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of recruiting site records. For each ID in
--   the range the IRC_POSTING_CONTENTS table is udpated.
--
--
procedure migrateVacancyRecSite(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< migrateVacancyRecSiteTL >---------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of recruiting site records. For each ID in
--   the range the IRC_POSTING_CONTENTS table is udpated.
--
--
procedure migrateVacancyRecSiteTL(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);
--
end irc_mrs_upgrade;

 

/
