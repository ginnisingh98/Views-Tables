--------------------------------------------------------
--  DDL for Package PER_PTU_DFF_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PTU_DFF_MIG" AUTHID CURRENT_USER AS
/* $Header: peptumig.pkh 120.0 2005/05/31 15:57:15 appldev noship $ */
--
-- Globals to hold concurrent request WHO column information.
--
  g_request_id  		     number(15);
  g_program_application_id	 number(15);
  g_program_id  		     number(15);
  g_update_date              date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< initialization >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   This process is called for each slave process to perform standard
--   initialization.
--
-- Notes :
--
procedure initialization(p_payroll_action_id in number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< submit_migration >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Descripton :
--
--   The procedure is a main procedure called by the concurent
--   program Migrate PTU Specific Person DFF Data to PTU DFF.
--
PROCEDURE submit_migration(errbuf              out NOCOPY varchar2,
                           retcode             out NOCOPY number,
                           p_business_group_id number
                           --p_report_mode       varchar2
                           );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< range_cursor >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Descripton :
--
--   The procedure contains the cursor definition required to populate the
--   PAY_POPULATION_RANGES table.
--   This routine is called from PYUGEN. It returns a SQL select used
--   to identify the people who need to be processed.
--
PROCEDURE range_cursor (pactid in  number,
                        sqlstr out NOCOPY varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< action_creation >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Descripton :
--
--  This routine is called to create assignment actions in
--  PAY_ASSIGNMENT_ACTIONS table for each person to be processed by PYUGEN.
--
PROCEDURE action_creation(pactid    in number,
                          stperson  in number,
                          endperson in number,
                          chunk     in number);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< archive_data >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Descripton :
--
--   This procedure contains the code required to process each record within
--   the PAY_ASSIGNMENT_ACTIONS table.
--   The procedure will perform the actual migration.
--
PROCEDURE archive_data (p_assactid      in number,
                        p_effective_date in date);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< deinitialization >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Descripton :
--
--   This procedure is used to update the migration status in
--   user table PER_PTU_DFF_MAPPING_HEADERS and then remove the assignment
--   actions for this run by calling pay_archive.standard_deinit.
--
PROCEDURE deinitialization(pactid in number);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< submit_perDFFpurge >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Descripton :
--
--   Procedure to purge the migrated Person DFF data. This procedure is called
--   by the concurrent program Purge Migrated Person DFF Data.
--
PROCEDURE submit_perDFFpurge(errbuf              out NOCOPY varchar2,
                             retcode             out NOCOPY number,
                             p_purge_scope       VARCHAR2,
                             p_context           VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |----------------------< populate_mapping_tables >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--
--    This procedure is used to populate the mapping tables for the first time.
--    This procedure is called from the mapping form.
--
procedure populate_mapping_tables;
--
END;

 

/
