--------------------------------------------------------
--  DDL for Package PQP_ERT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ERT_DEL" AUTHID CURRENT_USER as
/* $Header: pqertrhi.pkh 120.5 2006/09/15 00:09:22 sshetty noship $ */
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
  (p_exception_report_id                  in number
  );
--
end pqp_ert_del;

 

/
