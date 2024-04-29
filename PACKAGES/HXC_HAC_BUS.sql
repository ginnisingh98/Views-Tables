--------------------------------------------------------
--  DDL for Package HXC_HAC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAC_BUS" AUTHID CURRENT_USER as
/* $Header: hxchacrhi.pkh 120.1 2006/06/08 15:17:53 gsirigin noship $ */
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
--    The primary key identified by p_approval_comp_id
--     already exists.
--
--  In Arguments:
--    p_approval_comp_id
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
  (p_approval_comp_id                     in number
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
--    The primary key identified by p_approval_comp_id
--     already exists.
--
--  In Arguments:
--    p_approval_comp_id
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
  (p_approval_comp_id                     in     number
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
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_hac_shd.g_rec_type
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
  (p_effective_date               in date
  ,p_rec                          in hxc_hac_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |-< chk_approval_comp_dates >----------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs basic checks on the assignment dates to ensure
--   that they conform with the business rules.
--   At the moment the only business rule enforced in this procedure is that
--   the end date must be >= the start date and that the start date is not
--   null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_approval_comp_id
--   p_start_date
--   p_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_approval_comp_dates
   (p_approval_comp_id
                  IN hxc_approval_comps.approval_comp_id%TYPE
   ,p_start_date
                  IN hxc_approval_comps.start_date%TYPE
   ,p_end_date
                  IN hxc_approval_comps.end_date%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_invalid_dates_create >---------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to enforce the business rule that the start/end
--   dates of new records cannot overlap both the start and the end
--   dates of existing records.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_approval_style_id
--   p_time_recipient_id
--   p_start_date
--   p_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_invalid_dates_create
  ( p_approval_style_id
                  IN hxc_approval_comps.approval_style_id%TYPE
   ,p_time_recipient_id
                  IN hxc_approval_comps.time_recipient_id%TYPE
   ,p_start_date
                  IN hxc_approval_comps.start_date%TYPE
   ,p_end_date
                  IN hxc_approval_comps.end_date%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_invalid_dates_update >---------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to enforce the business rule that the start/end
--   dates of updated records cannot overlap both the start and the end
--   dates of existing records.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_approval_comp_id
--   p_approval_style_id
--   p_time_recipient_id
--   p_start_date
--   p_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_invalid_dates_update
  ( p_approval_comp_id
                  IN hxc_approval_comps.approval_comp_id%TYPE
   ,p_approval_style_id
                  IN hxc_approval_comps.approval_style_id%TYPE
   ,p_time_recipient_id
                  IN hxc_approval_comps.time_recipient_id%TYPE
   ,p_start_date
                  IN hxc_approval_comps.start_date%TYPE
   ,p_end_date
                  IN hxc_approval_comps.end_date%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates_create >-----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to enforce the business rule that dates of
--   records cannot overlap.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_approval_style_id
--   p_time_recipient_id
--   p_start_date
--   p_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_overlapping_dates_create
   (p_approval_style_id
                  IN hxc_approval_comps.approval_style_id%TYPE
   ,p_time_recipient_id
                  IN hxc_approval_comps.time_recipient_id%TYPE
   ,p_start_date
                  IN hxc_approval_comps.start_date%TYPE
   ,p_end_date
                  IN hxc_approval_comps.end_date%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates_create >-----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to enforce the business rule that dates of
--   records cannot overlap.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_approval_style_id
--   p_time_recipient_id
--   p_start_date
--   p_end_date
--   p_clashing_id
--   p_clashing_ovn
--   p_clashing_start_date
--   p_clashing_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   The id of the record which overlaps is returned.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_overlapping_dates_create
   (p_approval_style_id
                  IN hxc_approval_comps.approval_style_id%TYPE
   ,p_time_recipient_id
                  IN hxc_approval_comps.time_recipient_id%TYPE
   ,p_start_date
                  IN hxc_approval_comps.start_date%TYPE
   ,p_end_date
                  IN hxc_approval_comps.end_date%TYPE
   ,p_clashing_id
                 OUT NOCOPY hxc_approval_comps.approval_style_id%TYPE
   ,p_clashing_ovn
                 OUT NOCOPY hxc_approval_comps.object_version_number%TYPE
   ,p_clashing_start_date
                OUT NOCOPY hxc_approval_comps.start_date%TYPE
   ,p_clashing_end_date
                 OUT NOCOPY hxc_approval_comps.end_date%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates_update >-----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to enforce the business rule that dates of
--   records cannot overlap.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_approval_comp_id
--   p_approval_style_id
--   p_time_recipient_id
--   p_start_date
--   p_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_overlapping_dates_update
   (p_approval_comp_id
                  IN hxc_approval_comps.approval_comp_id%TYPE
   ,p_approval_style_id
                  IN hxc_approval_comps.approval_style_id%TYPE
   ,p_time_recipient_id
                  IN hxc_approval_comps.time_recipient_id%TYPE
   ,p_start_date
                  IN hxc_approval_comps.start_date%TYPE
   ,p_end_date
                  IN hxc_approval_comps.end_date%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates_update >-----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to enforce the business rule that dates of
--   records cannot overlap.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_approval_comp_id
--   p_approval_style_id
--   p_time_recipient_id
--   p_start_date
--   p_end_date
--   p_clashing_id
--   p_clashing_ovn
--   p_clashing_start_date
--   p_clashing_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   The id of the record which overlaps is returned.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_overlapping_dates_update
   (p_approval_comp_id
                  IN hxc_approval_comps.approval_comp_id%TYPE
   ,p_approval_style_id
                  IN hxc_approval_comps.approval_style_id%TYPE
   ,p_time_recipient_id
                  IN hxc_approval_comps.time_recipient_id%TYPE
   ,p_start_date
                  IN hxc_approval_comps.start_date%TYPE
   ,p_end_date
                  IN hxc_approval_comps.end_date%TYPE
   ,p_clashing_id
                 OUT NOCOPY hxc_approval_comps.approval_style_id%TYPE
   ,p_clashing_ovn
                 OUT NOCOPY hxc_approval_comps.object_version_number%TYPE
   ,p_clashing_start_date
                OUT NOCOPY hxc_approval_comps.start_date%TYPE
   ,p_clashing_end_date
                 OUT NOCOPY hxc_approval_comps.end_date%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_master_detail_rel >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
-- Description:
--   This procedure is used to enforce the business rule that if the
--   parent_comp_id and parent_comp_ovn are not null then a master record
--   must exist in the database.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_parent_comp_id
--   p_parent_comp_ovn
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_master_detail_rel
   (
   	 p_parent_comp_id IN hxc_approval_comps.parent_comp_id%TYPE
   	,p_parent_comp_ovn  IN hxc_approval_comps.parent_comp_ovn%TYPE
   );
--
-- ----------------------------------------------------------------------------
-- |-< chk_parent_fields >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
-- Description:
--   This procedure is used to enforce the business rule that if the
--   parent_comp_id is not null then parent comp ovn must also be
--   not null and vice versa.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_parent_comp_id
--   p_parent_comp_ovn
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_parent_fields
   (
   	 p_parent_comp_id IN hxc_approval_comps.parent_comp_id%TYPE
   	,p_parent_comp_ovn  IN hxc_approval_comps.parent_comp_ovn%TYPE);


--
-- ----------------------------------------------------------------------------
-- |-< chk_tim_cat >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
-- Description:
--   This procedure is used to enforce the business rule that if the
--   parent_comp_id and parent_comp_ovn are not null then the
--   time category must be either 0 or belong to the list of
--   time categories in hxc_time_categories table.
--   The time_category_id field must be null if the parent_comp_id and
--   parent_comp_ovn are null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_parent_comp_id
--   p_parent_comp_ovn
--   p_time_category_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_tim_cat
   ( p_parent_comp_id IN hxc_approval_comps.parent_comp_id%TYPE
   	,p_parent_comp_ovn  IN hxc_approval_comps.parent_comp_ovn%TYPE
   	,p_time_category_id IN hxc_approval_comps.time_category_id%TYPE );


-- ----------------------------------------------------------------------------
-- |-< chk_def_ela_rec_exists >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
-- Description:
--   This procedure is used to enforce the business rule that
--   only one default ELA child record can exist for a parent.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_approval_comp_id
--   p_time_category_id
--   p_parent_comp_id
--   p_parent_comp_ovn
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_def_ela_rec_exists
   (
     p_approval_comp_id IN hxc_approval_comps.approval_comp_id%TYPE
   	,p_time_category_id IN hxc_approval_comps.time_category_id%TYPE
   	,p_parent_comp_id IN hxc_approval_comps.parent_comp_id%TYPE
   	,p_parent_comp_ovn  IN hxc_approval_comps.parent_comp_ovn%TYPE   );

--
-- ----------------------------------------------------------------------------
-- |-< chk_tim_rcp >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
-- Description:
--   This procedure is used to enforce the business rule that if the
--   parent_comp_id and parent_comp_ovn are not null then the
--   time recipient must be -1
--   The time_category_id field must belong to the list of time recipients
--   in the hxc_time_recipients table if the parent_comp_id and
--   parent_comp_ovn are not null
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_parent_comp_id
--   p_parent_comp_ovn
--   p_time_recipient_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_tim_rcp
   ( p_parent_comp_id IN hxc_approval_comps.parent_comp_id%TYPE
   	,p_parent_comp_ovn  IN hxc_approval_comps.parent_comp_ovn%TYPE
   	,p_time_recipient_id IN hxc_approval_comps.time_recipient_id%TYPE );

--
-- ----------------------------------------------------------------------------
-- |-< chk_tim_cat_dup >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
-- Description:
--   This procedure is used to enforce the business rule that
--   for a time category and a sequence only 1 row can exist.
--   Also for a time category the approval mechanisms must be
--   different but if they are same then the mechanism ids must be
--   different.
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_approval_comp_id
--   p_time_category_id
--   p_parent_comp_id
--   p_parent_comp_ovn
--   p_approval_mechanism
--   p_approval_mechanism_id
--   p_wf_name
--   p_wf_item_type
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_tim_cat_dup
   (
     p_approval_comp_id IN hxc_approval_comps.approval_comp_id%TYPE
    ,p_time_category_id IN hxc_approval_comps.time_category_id%TYPE
    ,p_approval_order IN hxc_approval_comps.approval_order%TYPE
   	,p_parent_comp_id IN hxc_approval_comps.parent_comp_id%TYPE
   	,p_parent_comp_ovn  IN hxc_approval_comps.parent_comp_ovn%TYPE
   	,p_approval_mechanism IN hxc_approval_comps.approval_mechanism%TYPE
   	,p_approval_mechanism_id IN hxc_approval_comps.approval_mechanism_id%TYPE
   	,p_wf_name IN hxc_approval_comps.wf_name%TYPE
	,p_wf_item_type IN hxc_approval_comps.wf_item_type%TYPE);

--
--
-- ----------------------------------------------------------------------------
-- |-< chk_app_mech_for_child >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
-- Description:
--   This procedure is used to enforce the business rule that
--   a child row cannot have the approval mechanism as
--   ENTRY_LEVEL_APPROVAL. Also if the child row is the default
--   row, then the approval mechanism cant be PROJECT_MANAGER.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_time_category_id
--   p_approval_mechanism
--   p_parent_comp_id
--   p_parent_comp_ovn
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_app_mech_for_child
   (
     p_time_category_id IN hxc_approval_comps.time_category_id%TYPE
    ,p_approval_mechanism IN hxc_approval_comps.approval_mechanism%TYPE
   	,p_parent_comp_id IN hxc_approval_comps.parent_comp_id%TYPE
   	,p_parent_comp_ovn  IN hxc_approval_comps.parent_comp_ovn%TYPE
   );

--
-- ----------------------------------------------------------------------------
-- |---------< chk_allowable_extensions >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
-- Description:
--   Procedure to check allowable values for run_recipient_extensions.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_run_recipient_extensions
--   p_approval_style_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--

Procedure chk_allowable_extensions
  (
   p_run_recipient_extensions in    hxc_approval_comps.run_recipient_extensions%type
  ,p_approval_style_id        in    hxc_approval_comps.approval_style_id%type
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
--
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in hxc_hac_shd.g_rec_type
  );
--
end hxc_hac_bus;

 

/
