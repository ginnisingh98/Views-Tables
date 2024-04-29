--------------------------------------------------------
--  DDL for Package FF_LOAD_FTYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_LOAD_FTYPES_PKG" AUTHID CURRENT_USER as
/* $Header: ffftypapi.pkh 115.0 2004/06/25 05:36 sspratur noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< LOAD_ROW >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called by the loader for FF_FORMULA_TYPES table data.
--   It first tries to update the row, and if no data is found it tries to
--   insert the row. This assumes the data was extracted from a database,
--   where the validation was performed.
--
-- Prerequisites:
--
-- In Parameter:
-- P_FORMULA_TYPE_NAME
-- P_TYPE_DESCRIPTION
--
-- Post Success:
--   The row is udtated, or inserted.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--   Only to be used by the loader.
--
-- Access Status:
--   Only to be used by the loader.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure  load_row (
   p_formula_type_name   in ff_formula_types.formula_type_name%TYPE
  ,p_type_description    in ff_formula_types.type_description%TYPE
 ) ;
--
-- ------------------------------------------------------------------------------------------
-- |---------------------------< load_row_context_usages >-----------------------------------|
-- ------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called by the loader for FF_FTYPE_CONTEXT_USAGES table.
--   It first tries to update the row, and if no data is found it tries to
--   insert the row.
--   This assumes the data was extracted from a database
--  , where the validation was performed.
--
-- Prerequisites:
--
-- In Parameter:
-- P_FORMULA_TYPE_NAME
-- P_CONTEXT_NAME
--
-- Post Success:
--   The row is udtated, or inserted.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--   Only to be used by the loader.
--
-- Access Status:
--   Only to be used by the loader.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure load_row_context_usages (
               p_formula_type_name  in FF_FORMULA_TYPES.formula_type_name%TYPE
              ,p_context_name       in FF_CONTEXTS.context_name%TYPE);

--
end ff_load_ftypes_pkg;

 

/
