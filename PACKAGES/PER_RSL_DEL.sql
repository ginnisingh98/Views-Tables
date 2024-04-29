--------------------------------------------------------
--  DDL for Package PER_RSL_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RSL_DEL" AUTHID CURRENT_USER as
/* $Header: perslrhi.pkh 120.0 2005/05/31 19:50:37 appldev noship $ */
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
  (p_rating_scale_id                      in number
  ,p_associated_column1                   in varchar2 default null
  );
--
end per_rsl_del;

 

/
