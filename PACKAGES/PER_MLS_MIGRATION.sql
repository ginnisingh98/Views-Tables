--------------------------------------------------------
--  DDL for Package PER_MLS_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MLS_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: pemlsmig.pkh 115.5 2004/04/29 04:34:24 adudekul noship $ */
--
-- Fix for bug 3481355 starts here. Commented the job procdure.
--
-- ----------------------------------------------------------------------------
-- |--------------------------< migrateJobData >----------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of job records. For each ID in the range
--   the PER_JOBS_TL table is populated for each installed language.
--
--
/*
procedure migrateJobData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);
*/
--
-- Fix for bug 3481355 ends here.
--
-- ----------------------------------------------------------------------------
-- |-----------------------< migratePositionData >--------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of position records. For each ID in the
--   range the HR_ALL_POSITIONS_F_TL table is populated for each installed
--   language.
--
--
procedure migratePositionData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);


-- ----------------------------------------------------------------------------
-- |---------------------------< migrateGradeData >---------------------------|
-- ----------------------------------------------------------------------------
procedure migrateGradeData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);

-- ----------------------------------------------------------------------------
-- |---------------------------< migrateRatingScaleData >---------------------|
-- ----------------------------------------------------------------------------
procedure migrateRatingScaleData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);

-- ----------------------------------------------------------------------------
-- |---------------------------< migrateRatingLevelData >---------------------|
-- ----------------------------------------------------------------------------
procedure migrateRatingLevelData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);

-- ----------------------------------------------------------------------------
-- |-------------------------< migrateCompetenceData >------------------------|
-- ----------------------------------------------------------------------------
procedure migrateCompetenceData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);

-- ----------------------------------------------------------------------------
-- |-----------------------< migrateQualificationData >-----------------------|
-- ----------------------------------------------------------------------------
procedure migrateQualificationData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);

-- ----------------------------------------------------------------------------
-- |----------------------< migrateSubjectsTakenData >------------------------|
-- ----------------------------------------------------------------------------
procedure migrateSubjectsTakenData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);

-- ----------------------------------------------------------------------------
-- |---------------------< migrateQualificationTypeData >---------------------|
-- ----------------------------------------------------------------------------
procedure migrateQualificationTypeData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);

end per_mls_migration;

 

/
