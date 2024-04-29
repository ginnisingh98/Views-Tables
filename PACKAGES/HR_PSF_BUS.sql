--------------------------------------------------------
--  DDL for Package HR_PSF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PSF_BUS" AUTHID CURRENT_USER as
/* $Header: hrpsfrhi.pkh 120.1.12010000.3 2008/08/06 12:49:25 sathkris ship $ */
--
--
  g_debug boolean := hr_utility.debug_enabled;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<  set_security_group_id  >------------------------|
--  ---------------------------------------------------------------------------
--
--
  procedure set_security_group_id
   (
    p_position_id                in hr_positions.position_id%TYPE
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
   (p_rec          in hr_psf_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date);
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
   (p_rec          in hr_psf_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date);
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
   (p_rec          in hr_psf_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date);
--
Function First_active_position_row(
  p_position_id          in  number,
  p_effective_start_date in  date) return boolean ;
--
Function all_proposed_only_position(
   p_position_id           number )
 return boolean ;

-- Bug 3199913 Start
procedure chk_ref_int_del(
    p_position_id            in varchar2
   ,p_validation_start_date  in date
   ,p_validation_end_date    in date
   ,p_datetrack_mode         in varchar2 );
-- Bug 3199913 End

-- -----------------------------------------------------------------------------
-- |-------------------------------< chk_ddf >---------------------------------|
-- -----------------------------------------------------------------------------
--
procedure chk_ddf
  (p_rec   in hr_psf_shd.g_rec_type);
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
procedure chk_df
  (p_rec in hr_psf_shd.g_rec_type);
--
Procedure DE_Update_properties(
  p_position_id           in number,
  p_effective_Start_Date  in date,
  p_updateable           out nocopy boolean,
  p_lower_limit          out nocopy date,
  p_upper_limit          out nocopy date);
--
procedure chk_availability_status_id
   (p_position_id            in number
   ,p_validation_start_date  in date
   ,p_availability_status_id in number
   ,p_old_avail_status_id    in number
   ,p_business_group_id      in number
   ,p_date_effective         in date default null
   ,p_effective_date         in date default null
   ,p_object_version_number  in number default 1
   ,p_datetrack_mode         in varchar2);
--
procedure chg_date_effective
     (p_position_id             in number
     ,p_effective_start_date    in date
     ,p_effective_end_date      in date
     ,p_date_effective          in date
     ,p_new_date_effective      out nocopy date
     ,p_chg_date_effective      out nocopy boolean
     ,p_business_group_id       in number
     ,p_old_avail_status_id     in number
     ,p_availability_status_id  in number
     ,p_datetrack_mode          in varchar2
      );
--
Procedure chk_permanent_seasonal_flag
  (p_position_id               in number
  ,p_permanent_temporary_flag   in varchar2
  ,p_seasonal_flag             in varchar2
  ,p_effective_date            in date
  ,p_object_version_number     in number);
--
end hr_psf_bus;

/
