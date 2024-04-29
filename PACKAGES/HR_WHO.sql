--------------------------------------------------------
--  DDL for Package HR_WHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WHO" AUTHID CURRENT_USER as
/* $Header: hrwhopls.pkh 115.1 2002/12/05 17:06:06 apholt ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< who >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure determines if the AOL who columns on insert have been set
--   (e.g. checks to see if the arguments are null). If the arguments are
--   set then the argument values will be passed back with the original value.
--   If the arguments aren't set then they are set using AOL api calls.
--
-- Pre Conditions:
--   Should only be executed from a trigger when inserting.
--
-- In Arguments:
--   p_new_created_by    - :new.created_by trigger value.
--   p_new_creation_date - :new.creation_date value.
--
-- Post Success:
--   If the arguments are set then the argument values will be passed back
--   with the original values.
--   If the arguments aren't set then they are set using AOL api calls.
--
-- Post Failure:
--   The procedure should NOT error.
--
-- Developer Implementation Notes:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure who(p_new_created_by          in out nocopy  number,
              p_new_creation_date       in out nocopy  date);
-- ----------------------------------------------------------------------------
-- |---------------------------------< who >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure determines if the AOL who columns on update have been set
--   (e.g. checks to see if the arguments are null or if they are the same as
--         the old record on the server). If the arguments are set to new
--   values then the argument values will be passed back with the original
--   value.
--   If the arguments aren't set or are the same as the old record values then
--   they are set using AOL api calls.
--
-- Pre Conditions:
--   Should only be executed from a trigger when updating.
--
-- In Arguments:
--   p_new_last_update_date   - :new.last_update_date trigger value
--   p_new_last_updated_by    - :new.last_updated_by trigger value
--   p_new_last_update_login  - :new.last_update_login trigger value
--   p_old_last_update_date   - :old.last_update_date trigger value
--   p_old_last_updated_by    - :old.last_updated_by trigger value
--   p_old_last_update_login  - :old.last_update_login trigger value
--
-- Post Success:
--   If the arguments are set then the argument values will be passed back
--   with the original values.
--   If the arguments aren't set or are the same as the old record values then
--   they are set using AOL api calls.
--
-- Post Failure:
--   The procedure should NOT error.
--
-- Developer Implementation Notes:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure who(p_new_last_update_date    in out nocopy date,
              p_new_last_updated_by     in out nocopy number,
              p_new_last_update_login   in out nocopy number,
              p_old_last_update_date    in     date,
              p_old_last_updated_by     in     number,
              p_old_last_update_login   in     number);
end hr_who;

 

/
