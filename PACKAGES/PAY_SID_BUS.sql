--------------------------------------------------------
--  DDL for Package PAY_SID_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SID_BUS" AUTHID CURRENT_USER as
/* $Header: pysidrhi.pkh 120.1 2005/07/05 06:25:39 vikgupta noship $ */
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
--    The primary key identified by p_prsi_details_id
--     already exists.
--
--  In Arguments:
--    p_prsi_details_id
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
  (p_prsi_details_id                      in number
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
--    The primary key identified by p_prsi_details_id
--     already exists.
--
--  In Arguments:
--    p_prsi_details_id
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
  (p_prsi_details_id                      in     number
  ) RETURN varchar2;
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_assignment_id >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if assignment already exists and valid as of the effectuve date
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_assignment_id
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the assignment does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_assignment_id
  (p_effective_date IN DATE
    , p_assignment_id IN NUMBER
  );
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_director_flag >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if director_flag already exists in lookup_type YES_NO
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_director_flag
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the director_flag does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_director_flag
  (p_effective_date IN DATE
     , p_director_flag IN VARCHAR2
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_contribution_class >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if contribution_class already exists in lookup_type
--    IE_PRSI_CONT_CLASS
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_contribution_class
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the contribution_class does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_contribution_class
  (p_effective_date IN DATE
     , p_contribution_class IN VARCHAR2
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_overridden_subclass >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if overridden_subclass already exists in lookup_type
--    IE_PRSI_CONT_SUBCLASS
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_overridden_subclass
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the overridden_subclass does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_overridden_subclass
  (p_effective_date IN DATE
     , p_overridden_subclass IN VARCHAR2
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_overlapping_record >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if PRSI record already exists for the assignment
--
--  Prerequisites:
--
--  In Arguments:
--    p_assignment_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if PRSI record already exists for the assignment
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_overlapping_record
  ( p_assignment_id		IN NUMBER
  , p_validation_start_date	DATE
  , p_validation_end_date	DATE
  );
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_soc_ben_flag >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if soc_ben_flag already exists in lookup_type YES_NO
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_soc_ben_flag
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the soc_ben_flag does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_soc_ben_flag
  (p_effective_date IN DATE
     , p_soc_ben_flag IN VARCHAR2
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_soc_ben_start_date >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if soc_ben_start_date is not null when soc_ben_flag is 'N'
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_soc_ben_flag
--    p_soc_ben_start_date
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the soc_ben_start_date is not null and
--    soc_ben_flag is 'N'
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_soc_ben_start_date
  (p_effective_date IN DATE
     , p_soc_ben_flag IN VARCHAR2
     , p_soc_ben_start_date IN DATE
  );
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< get_std_ins_weeks >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Get standard default number of insurable weeks in current pay period
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_assignment_id
--
--
--  Post Success:
--    returns standard default number of insurable weeks in current pay period
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION get_std_ins_weeks
  (p_effective_date IN DATE
   , p_assignment_id IN NUMBER
  ) RETURN NUMBER ;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_overridden_ins_weeks >------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check that overridden insurable weeks are not more than standard default
--    number of insurable weeks in current pay period.
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_assignment_id
--    p_overridden_ins_weeks
--
--
--  Post Success:
--    Process continues
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_overridden_ins_weeks
  (p_effective_date IN DATE
   , p_assignment_id IN NUMBER
   , p_overridden_ins_weeks IN NUMBER
  );
--
--
-- ---------------------------------------------------------------------------
-- |--------------------< chk_exemption_start_end_dates >--------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if exemption start date is before or equal to certificate end date
--
--  Prerequisites:
--
--  In Arguments:
--    p_exemption_start_date
--    p_exemption_end_date
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the exemption_start_date is after
--    exemption_end_Date
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_exemption_start_end_dates
  (p_exemption_start_Date IN DATE
     , p_exemption_end_date IN DATE
  ) ;
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_community_flag >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if community_flag already exists in lookup_type YES_NO
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_community_flag
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the community_flag does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_community_flag
  (p_effective_date IN DATE
     , p_community_flag IN VARCHAR2
  ) ;
--
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
  (p_rec                   in pay_sid_shd.g_rec_type
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
  (p_rec                     in pay_sid_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
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
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                   in pay_sid_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
--
end pay_sid_bus;

 

/
