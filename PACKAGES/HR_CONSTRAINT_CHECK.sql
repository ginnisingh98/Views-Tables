--------------------------------------------------------
--  DDL for Package HR_CONSTRAINT_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONSTRAINT_CHECK" AUTHID CURRENT_USER AS
/*$Header: hrconchk.pkh 115.1 2002/12/02 16:56:13 apholt ship $*/
--
-- Types
  TYPE ConsRec IS RECORD
    (constraint_name   varchar2(30)
    ,table_name        varchar2(30)
    );
  TYPE ConsList IS TABLE OF ConsRec INDEX BY BINARY_INTEGER;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< build_constraint_list >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  When called, this procedure will build up a list of constraints that exist
--  in the appropriate database, for the given product.
--
-- In Parameters:
--  p_prod - A 3-letter or 2-letter product code, which determines the
--           constraints added to the list.
--
-- Out Parameters:
--  p_list - A PL/SQL table making up a list of constraints for the particular
--           product.
--
-- ----------------------------------------------------------------------------
PROCEDURE build_constraint_list (p_prod IN varchar2
				,p_list IN OUT NOCOPY ConsList);
--
-- ----------------------------------------------------------------------------
-- |---------------------< find_missing_constraints >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  When called, this procedure will compare the list of constraints in the
--  current database, with the list of constraints built up from the SQL
--  script, and will generate a report identifying:
--    - a constraint which exists in CASE, but not on the current database
--    - a constraint which exists in the DB, but not within the CASE
--      definitions
--
-- In Parameters:
--  p_db_list - A list of constraints in the current database.
--  p_case_list - A list of constraints defined by HRMS.
--
-- ----------------------------------------------------------------------------
PROCEDURE find_missing_constraints
  (p_db_list IN hr_constraint_check.ConsList
  ,p_case_list IN hr_constraint_check.ConsList);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< add_case_constraint >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  When called, this procedure will add a given constraint to a given list.
--
-- In Parameters:
--  p_case_list - A list of constraints.
--  p_constraint - A constraint to add to the database.
--  p_table - A table, upon which the constraint is defined.
--  p_index - The current number of constraints in the list.
--
-- Out Parameters:
--  p_index - The updated number of constraints in the list.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_case_constraint
  (p_case_list  IN OUT NOCOPY hr_constraint_check.ConsList
  ,p_constraint IN varchar2
  ,p_table      IN varchar2
  ,p_index      IN OUT NOCOPY integer);
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
-- |----------------------------< add_footer >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Adds a footer to the results table, for the benefit of the final report.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_footer;
--
END hr_constraint_check;

 

/
