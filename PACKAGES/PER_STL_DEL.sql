--------------------------------------------------------
--  DDL for Package PER_STL_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STL_DEL" AUTHID CURRENT_USER as
/* $Header: pestlrhi.pkh 120.1 2006/06/07 23:05:20 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< del_tl >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start of Comments}
--
-- Description:
--   This procedure is the main interface for deleting rows in the
--   translated table.  It will delete all translations which correspond
--   to the specified ID value.
--
-- Pre-requisites:
--   A unique surrogate key ID value is known to exist in the
--   non-translated table.  The row in the non-translated table has been
--   successfully locked.
--
-- In Parameters:
--
-- Post Success:
--   All validation will have passed and the set of translation rows
--   will be deleted from the _TL table.  None of the changes will be
--   committed to the database
--
-- Post Failure:
--   If an error has occurred a pl/sql exception will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure del_tl
  (p_setup_task_code                      in varchar2
  );
--
end per_stl_del;

 

/
