--------------------------------------------------------
--  DDL for Package OTA_CTU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CTU_BUS" AUTHID CURRENT_USER as
/* $Header: otcturhi.pkh 120.0.12010000.2 2009/07/24 10:53:23 shwnayak ship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--
--  Prerequisites:
--    The primary key identified by p_category_usage_id
--     already exists.
--
--  In Arguments:
--    p_category_usage_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure set_security_group_id
  (p_category_usage_id                    in number
  ,p_associated_column1                   in varchar2 default null
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_category_usage_id
--     already exists.
--
--  In Arguments:
--    p_category_usage_id
--
--
--  Post Success:
--    The business group's legislation code will be returned.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION return_legislation_code
  (p_category_usage_id                    in     number
  ) RETURN varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_ctu_shd.g_rec_type
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_ctu_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from del procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in ota_ctu_shd.g_rec_type
  );
-- ----------------------------------------------------------------------------
-- |---------------------< Chk_valid_parent_category >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  This business process validates the parent category while creating or updating a Category.
--
-- {End Of Comments}
--
Procedure Chk_valid_parent_category
  (p_parent_cat_usage_id           in     number
  ,p_category_usage_id             in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< Chk_child_category >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--
--
-- Pre-requisites
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure Chk_child_category
  (p_category_usage_id            in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< Chk_act_association >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--
--
-- Pre-requisites
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure Chk_act_association
  (p_category_usage_id            in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< Chk_offering_association >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--
--
-- Pre-requisites
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure Chk_offering_association
  (p_category_usage_id            in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Chk_online_flag >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--
--
-- Pre-requisites
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure Chk_online_flag
  (p_online_flag                  in     varchar2
  ,p_type                         in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< Chk_synchronous_flag >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--
--
-- Pre-requisites
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure Chk_synchronous_flag
  (p_synchronous_flag             in     varchar2
  ,p_type                         in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Chk_start_end_dates >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--
--
-- Pre-requisites
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure Chk_start_end_dates
  (p_start_date                         in date
  ,p_end_date                           in date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< Chk_lp_association >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--
--
-- Pre-requisites
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure Chk_lp_association
  (p_category_usage_id            in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_act_def_for_org_tp>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--
--
-- Pre-requisites
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure Chk_act_def_for_org_tp
  (p_category_usage_id            in     number
  );
--
end ota_ctu_bus;

/
