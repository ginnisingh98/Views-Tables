--------------------------------------------------------
--  DDL for Package IRC_PRIMARY_POSTING_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PRIMARY_POSTING_CHANGE" AUTHID CURRENT_USER AS
/* $Header: irppiupg.pkh 120.0 2005/07/26 15:15 mbocutt noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< update_primary_posting_data >-----------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure updates all the qualification records which doesn't have
--   a person_id and bussiness_group_id associated. For each ID in
--   the range the PER_QUALIFICATIONS table is udpated.
--
--
procedure update_primary_posting_data(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);
--
end irc_primary_posting_change;

 

/
