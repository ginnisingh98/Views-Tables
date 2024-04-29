--------------------------------------------------------
--  DDL for Package PER_ASG_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASG_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: peasgmig.pkh 115.0 2003/12/05 08:54:59 adhunter noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< migrateAsgProjAsgEnd >------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of Assignment records, populating the column
--   projected_assignment_end from values in per_periods_of_placement.
--
--
procedure migrateAsgProjAsgEnd(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);

end per_asg_migration;

 

/
