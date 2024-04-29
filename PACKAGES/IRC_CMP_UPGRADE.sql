--------------------------------------------------------
--  DDL for Package IRC_CMP_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_CMP_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: ircmpupg.pkh 120.0 2007/12/22 14:13:01 gaukumar noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< migrateVacCommProps >---------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure creates default communication properties for
--   older vacancies having no communication properties.
--
procedure migrateVacCommProps(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed OUT    nocopy number);
--
end irc_cmp_upgrade;

/
