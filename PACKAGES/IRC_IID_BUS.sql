--------------------------------------------------------
--  DDL for Package IRC_IID_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IID_BUS" AUTHID CURRENT_USER as
/* $Header: iriidrhi.pkh 120.1.12010000.1 2008/07/28 12:42:53 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_status >---------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_status
  (p_rec                   in   irc_iid_shd.g_rec_type
  ,p_effective_date        in   date
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_result >---------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_result
  (p_rec                   in irc_iid_shd.g_rec_type
  ,p_effective_date        in   date
  );
--
---- ----------------------------------------------------------------------------
-- |---------------------------< chk_completed >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_completed
  (p_rec                   in irc_iid_shd.g_rec_type
  ,p_effective_date        in date
  );
---
----------------------------------------------------------------------------
-- |---------------------------< chk_updated_status >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_updated_status
  (p_old_status           in varchar2
  ,p_new_status           in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_event_id >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_event_id
  (p_rec                   in irc_iid_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in irc_iid_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in irc_iid_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  );
--
end irc_iid_bus;

/
