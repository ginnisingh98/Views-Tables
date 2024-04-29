--------------------------------------------------------
--  DDL for Package HR_LOT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOT_INS" AUTHID CURRENT_USER as
  /* $Header: hrlotrhi.pkh 120.0 2005/05/31 01:22:20 appldev noship $ */
--
-- ------------------------------------------------------------------------
-- |-----------------------------< ins_tl >-------------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the main interface for inserting rows into the
--   translated table. It will insert a row into the translated (_TL)
--   table for the base language and every installed language.
--
-- Prerequisites:
--   A unique surrogate key ID value has been assigned and a valid row
--   has been successfully inserted into the non-translated table.
--
--   p_business_group_id is included even though the column appears
--   on the base table HR_LOCATIONS_ALL.  This is stored in an
--   efficiency global for use when updating.  The parameter is
--   required to test the validity of p_location_code
--
-- In Parameters:
--   p_language must be set to the base or any installed language.
--
-- Post Success:
--   A fully validated row will be inserted to the _TL table for the
--   base language and every installed language. None of the rows will
--   be committed to the database.
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
-- {End Of Comments}
-- ------------------------------------------------------------------------
Procedure ins_tl
 (p_language_code                in varchar2,
  p_location_id                  in number,
  p_location_code                in varchar2,
  p_description                  in varchar2,
  p_business_group_id            in number
  );
--
end hr_lot_ins;

 

/
