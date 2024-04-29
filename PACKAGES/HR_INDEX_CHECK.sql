--------------------------------------------------------
--  DDL for Package HR_INDEX_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_INDEX_CHECK" AUTHID CURRENT_USER AS
/*$Header: hrindchk.pkh 120.0 2005/05/31 00:51:36 appldev noship $*/
--
-- Types
  TYPE IndRec IS RECORD
    (index_name   varchar2(30)
    ,table_name   varchar2(30)
    );
  TYPE IndList IS TABLE OF IndRec INDEX BY BINARY_INTEGER;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< build_index_list >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  When called, this procedure will build up a list of indexes that exist
--  in the appropriate database, for the given product.
--
-- In Parameters:
--  p_prod - A 3-letter or 2-letter product code, which determines the
--           indexes added to the list.
--
-- Out Parameters:
--  p_list - A PL/SQL table making up a list of indexes for the particular
--           product.
--
-- ----------------------------------------------------------------------------
PROCEDURE build_index_list (p_prod IN varchar2
				,p_list IN OUT NOCOPY IndList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< find_missing_indexes >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  When called, this procedure will compare the list of indexes in the
--  current database, with the list of indexes built up from the SQL
--  script, and will generate a report identifying:
--    - an index which exists in CASE, but not on the current database
--    - an index which exists in the DB, but not within the CASE
--      definitions
--
-- In Parameters:
--  p_db_list - A list of indexes in the current database.
--  p_case_list - A list of indexes defined by HRMS.
--
-- ----------------------------------------------------------------------------
PROCEDURE find_missing_indexes
  (p_db_list IN hr_index_check.IndList
  ,p_case_list IN hr_index_check.IndList);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< add_case_index >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  When called, this procedure will add a given index to a given list.
--
-- In Parameters:
--  p_case_list - A list of indexes.
--  p_index_name - An index to add to the database.
--  p_table - A table, upon which the index is defined.
--  p_index - The current number of indexes in the list.
--
-- Out Parameters:
--  p_index - The updated number of indexes in the list.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_case_index
  (p_case_list  IN OUT NOCOPY hr_index_check.IndList
  ,p_index_name IN varchar2
  ,p_table      IN varchar2
  ,p_index      IN OUT NOCOPY integer);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< add_case_constraint >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   When called, this procedure will add a given constraint to a given list.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_case_constraint
  (p_cons_list        IN OUT NOCOPY hr_index_check.IndList
  ,p_constraint_name  IN varchar2
  ,p_table            IN varchar2
  ,p_index            IN OUT NOCOPY integer);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< add_header >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Adds a header to the results table, for the benefit of the final report.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_header;
--
-- ----------------------------------------------------------------------------
-- |------------------------< add_fk_header >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_fk_header;
--
-- ----------------------------------------------------------------------------
-- |---------------------< build_fk_index_list >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE build_fk_index_list(p_prod IN varchar2
			     ,p_list IN OUT NOCOPY hr_index_check.IndList );
--
-- ----------------------------------------------------------------------------
-- |--------------------< find_missing_cons_indexes >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE find_missing_cons_indexes
  (p_db_list   IN hr_index_check.IndList
  ,p_case_list IN hr_index_check.IndList);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< add_footer >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Adds a footer to the results table, for the benefit of the final report.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_footer;
--
END hr_index_check;

 

/
