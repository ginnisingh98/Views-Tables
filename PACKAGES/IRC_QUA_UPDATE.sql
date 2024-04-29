--------------------------------------------------------
--  DDL for Package IRC_QUA_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_QUA_UPDATE" AUTHID CURRENT_USER AS
/* $Header: irquaupg.pkh 120.0 2005/07/26 15:16 mbocutt noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< update_qualification_data >-------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure updates all the qualification records which doesn't have
--   a person_id and bussiness_group_id associated. For each ID in
--   the range the PER_QUALIFICATIONS table is udpated.
--
--
procedure update_qualification_data(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);
--
end irc_qua_update;

 

/
