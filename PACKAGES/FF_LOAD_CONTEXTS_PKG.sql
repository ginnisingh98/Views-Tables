--------------------------------------------------------
--  DDL for Package FF_LOAD_CONTEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_LOAD_CONTEXTS_PKG" AUTHID CURRENT_USER as
/* $Header: ffconapi.pkh 120.1 2005/09/23 10:37 arashid noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< VALIDATE_NAME >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called in the FF_CONTEXTS_BRI triggers to validate
--   that the inserted context is permitted.
--
-- Prerequisites:
--
-- In Parameters:
-- p_context_name
-- p_data_type
--
-- Post Success:
--   If the context is a permitted context then VALIDATE_NAME allows the
--   calling code to continue.
--
-- Post Failure:
--   An exception is raised if the context is not in the list of
--   permitted contexts.
--
-- Developer Implementation Notes:
--   Only to be used by the loader.
--
-- Access Status:
--   This is for Oracle internal use only. The body of VALIDATE_NAME may
--   only be updated by the Core Payroll team.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure validate_name
(p_context_name in varchar2
,p_data_type    in varchar2
);
-- ----------------------------------------------------------------------------
-- |---------------------------< LOAD_ROW >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called by the loader for FF_CONTEXTS table data.
--   It first tries to update the row, and if no data is found it tries to
--   insert the row. This assumes the data was extracted from a database,
--   where the validation was performed.
--
-- Prerequisites:
--
-- In Parameter:
-- p_context_id
-- p_context_level
-- p_context_name
-- p_data_type
--
--
-- Post Success:
--   The row is updated, or inserted.
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
Procedure load_row (
             p_context_name    in ff_contexts.context_name%TYPE
            ,p_context_level   in ff_contexts.context_level%TYPE
            ,p_data_type       in ff_contexts.data_type%TYPE);
--
end FF_LOAD_CONTEXTS_PKG;

 

/
