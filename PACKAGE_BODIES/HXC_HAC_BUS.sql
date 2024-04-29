--------------------------------------------------------
--  DDL for Package Body HXC_HAC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAC_BUS" as
/* $Header: hxchacrhi.pkb 120.4 2006/06/13 08:42:23 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_hac_bus.';  -- Global package name
g_debug    boolean		:= hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_approval_comp_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_approval_comp_id                     in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_approval_comps and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , hxc_approval_comps hac
      --   , EDIT_HERE table_name(s) 333
     where hac.approval_comp_id = p_approval_comp_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72);
  --
begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc  :=  g_package||'set_security_group_id';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'approval_comp_id'
    ,p_argument_value     => p_approval_comp_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'|| l_proc, 20);
  end if;
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_approval_comp_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_approval_comps and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , hxc_approval_comps hac
      --   , EDIT_HERE table_name(s) 333
     where hac.approval_comp_id = p_approval_comp_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72);
  --
Begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc  :=  g_package||'return_legislation_code';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'approval_comp_id'
    ,p_argument_value     => p_approval_comp_id
    );
  --
  if ( nvl(hxc_hac_bus.g_approval_comp_id, hr_api.g_number)
       = p_approval_comp_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hxc_hac_bus.g_legislation_code;
    if g_debug then
	hr_utility.set_location(l_proc, 20);
    end if;
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    if g_debug then
	hr_utility.set_location(l_proc,30);
    end if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    hxc_hac_bus.g_approval_comp_id  := p_approval_comp_id;
    hxc_hac_bus.g_legislation_code  := l_legislation_code;
  end if;
  if g_debug then
	hr_utility.set_location(' Leaving:'|| l_proc, 40);
  end if;
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in hxc_hac_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hxc_hac_shd.api_updating
      (p_approval_comp_id                     => p_rec.approval_comp_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-< chk_approval_comp_dates >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
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
   )
IS
--
CURSOR c_get_approval_comp_dates
IS
SELECT start_date
      ,end_date
  FROM hxc_approval_comps
 WHERE approval_comp_id = p_approval_comp_id;
--
BEGIN
   --
   -- check that the start date is not null
   --
  -- IF p_start_date IS NULL THEN
  --
   --   hr_utility.set_message
    --     (809
     --    ,'HXC_0054_HAC_COMP_ST_DT_NULL'
      --   );
     -- hr_utility.raise_error;
      --
 --  END IF;
   --
   -- check that the start date is not equal to or more than the end date
   --
   IF p_start_date > NVL(p_end_date, hr_general.END_OF_TIME) THEN
      --
      hr_utility.set_message
         (809
         ,'HXC_0055_HAC_COMP_DT_ERR'
         );
      hr_utility.raise_error;
      --
   END IF;
   --
END chk_approval_comp_dates;
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
   )
IS
--
CURSOR c_chk_invalid_dates_create
IS
SELECT 'Y'
  FROM hxc_approval_comps s
 WHERE s.approval_style_id = p_approval_style_id
   AND s.time_recipient_id = p_time_recipient_id
   AND s.start_date >= p_start_date
   AND NVL(s.end_date, hr_general.END_OF_TIME)
                       <= NVL(p_end_date,hr_general.END_OF_TIME)
   AND p_time_recipient_id <> -1 ;
--
l_result  VARCHAR2 (1);
--
BEGIN
   --
   OPEN c_chk_invalid_dates_create;
   --
   FETCH c_chk_invalid_dates_create INTO l_result;
   --
   IF c_chk_invalid_dates_create%FOUND THEN
      --
      CLOSE c_chk_invalid_dates_create;
      --
      -- record found - raise an exception
      --
      hr_utility.set_message
         (809
         ,'HXC_0067_HAC_COMP_INVCR_DT_ERR'
         );
      hr_utility.raise_error;
   END IF;
   --
   CLOSE c_chk_invalid_dates_create;
   --
END chk_invalid_dates_create;
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
   )
IS
--
CURSOR c_chk_invalid_dates_update
IS
SELECT 'Y'
  FROM hxc_approval_comps s
 WHERE s.approval_comp_id <> p_approval_comp_id
   AND s.approval_style_id = p_approval_style_id
   AND s.time_recipient_id = p_time_recipient_id
   AND s.start_date >= p_start_date
   AND NVL(s.end_date, hr_general.END_OF_TIME)
                       <= NVL(p_end_date,hr_general.END_OF_TIME)
   AND p_time_recipient_id <> -1	     ;
--
l_result  VARCHAR2 (1);
--
BEGIN
   --
   OPEN c_chk_invalid_dates_update;
   --
   FETCH c_chk_invalid_dates_update INTO l_result;
   --
   IF c_chk_invalid_dates_update%FOUND THEN
      --
      CLOSE c_chk_invalid_dates_update;
      --
      -- record found - raise an exception
      --
      hr_utility.set_message
         (809
         ,'HXC_0070_HAC_COMP_INVUP_DT_ERR'
         );
      hr_utility.raise_error;
   END IF;
   --
   CLOSE c_chk_invalid_dates_update;
   --
END chk_invalid_dates_update;
--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates_create >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
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
--   p_start_date
--   p_end_date
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
PROCEDURE chk_overlapping_dates_create
   (p_approval_style_id
                  IN hxc_approval_comps.approval_style_id%TYPE
   ,p_time_recipient_id
                  IN hxc_approval_comps.time_recipient_id%TYPE
   ,p_start_date
                  IN hxc_approval_comps.start_date%TYPE
   ,p_end_date
                  IN hxc_approval_comps.end_date%TYPE
   )
IS
--
l_id          hxc_approval_comps.approval_style_id%TYPE DEFAULT NULL;
l_ovn         hxc_approval_comps.object_version_number%TYPE DEFAULT NULL;
l_start_date  hxc_approval_comps.start_date%TYPE DEFAULT NULL;
l_end_date    hxc_approval_comps.end_date%TYPE DEFAULT NULL;
--
BEGIN
   --
   -- call the other chk_overlapping_dates_create procedure and
   -- raise the relavent exception
   -- if it returns anything
   --

   chk_overlapping_dates_create
      (p_approval_style_id   => p_approval_style_id
      ,p_time_recipient_id  => p_time_recipient_id
      ,p_start_date         => p_start_date
      ,p_end_date           => p_end_date
      ,p_clashing_id        => l_id
      ,p_clashing_ovn       => l_ovn
      ,p_clashing_start_date => l_start_date
      ,p_clashing_end_date   => l_end_date
      );
   --

   IF l_id IS NOT NULL THEN
      -- we need to work out which exception to raise....
      IF p_start_date >= l_start_date AND p_start_date <= l_end_date THEN
         --
         -- The start date of the inserted record is in error
         --
         hr_utility.set_message
            (809
            ,'HXC_0071_HAC_COMP_ST_DTCR_ERR'
            );
         hr_utility.raise_error;
      --
      ELSIF p_end_date >= l_start_date AND p_end_date <= l_end_date THEN
         --
         -- The end date of the inserted record is in error
         --
         hr_utility.set_message
            (809
            ,'HXC_0072_HAC_COMP_END_DTCR_ERR'
            );
         hr_utility.raise_error;
         --

      END IF;
   END IF;
   --

END chk_overlapping_dates_create;
--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates_create >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
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
   )
IS
--
CURSOR c_chk_overlapping_dates_create
IS
SELECT s.approval_style_id
      ,s.object_version_number
      ,s.start_date
      ,s.end_date
 FROM hxc_approval_comps s
 WHERE s.approval_style_id = p_approval_style_id
  AND  s.time_recipient_id = p_time_recipient_id
   AND NOT (   (s.start_date < p_start_date
                AND NVL(s.end_date, hr_general.END_OF_TIME) < p_start_date)
           OR  (s.start_date > p_end_date
               AND NVL(s.end_date, hr_general.END_OF_TIME)
                            > NVL(p_end_date, hr_general.END_OF_TIME))
           )
   AND p_time_recipient_id <> -1;
--
BEGIN
   --
   OPEN c_chk_overlapping_dates_create;
   --
   FETCH c_chk_overlapping_dates_create INTO p_clashing_id
                                             ,p_clashing_ovn
                                             ,p_clashing_start_date
                                             ,p_clashing_end_date;
   --
   IF c_chk_overlapping_dates_create%NOTFOUND THEN
      p_clashing_id := NULL;
   END IF;
   --
   CLOSE c_chk_overlapping_dates_create;
   --
END chk_overlapping_dates_create;
--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates_update >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
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
--   p_start_date
--   p_end_date
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
   )
IS
--
l_id          hxc_approval_comps.approval_style_id%TYPE DEFAULT NULL;
l_ovn         hxc_approval_comps.object_version_number%TYPE DEFAULT NULL;
l_start_date  hxc_approval_comps.start_date%TYPE DEFAULT NULL;
l_end_date    hxc_approval_comps.end_date%TYPE DEFAULT NULL;
--
BEGIN
   --
   -- call the other chk_overlapping_dates_update procedure and
   -- raise the relavent exception
   -- if it returns anything
   --

   chk_overlapping_dates_update
      (p_approval_comp_id   => p_approval_comp_id
      ,p_approval_style_id  => p_approval_style_id
      ,p_time_recipient_id  => p_time_recipient_id
      ,p_start_date         => p_start_date
      ,p_end_date           => p_end_date
      ,p_clashing_id        => l_id
      ,p_clashing_ovn       => l_ovn
      ,p_clashing_start_date => l_start_date
      ,p_clashing_end_date   => l_end_date
      );
   --

   IF l_id IS NOT NULL THEN
      -- we need to work out which exception to raise....
      IF p_start_date >= l_start_date AND p_start_date <= l_end_date THEN
         --
         -- The start date of the updated record is in error
         --
         hr_utility.set_message
            (809
             ,'HXC_0073_HAC_COMP_ST_DTUP_ERR'
            );
         hr_utility.raise_error;
      --
      ELSIF p_end_date >= l_start_date AND p_end_date <= l_end_date THEN
         --
         -- The end date of the updated record is in error
         --
         hr_utility.set_message
            (809
            ,'HXC_0074_HAC_COMP_END_DTUP_ERR'
            );
         hr_utility.raise_error;
         --

      END IF;
   END IF;
   --

END chk_overlapping_dates_update;
--
-- ----------------------------------------------------------------------------
-- |-< chk_overlapping_dates_update >-----------------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
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
   )
IS
--
CURSOR c_chk_overlapping_dates_update
IS
SELECT s.approval_style_id
      ,s.object_version_number
      ,s.start_date
      ,s.end_date
 FROM hxc_approval_comps s
 WHERE s.approval_comp_id <> p_approval_comp_id
  AND  s.approval_style_id = p_approval_style_id
  AND  s.time_recipient_id = p_time_recipient_id
   AND NOT (   (s.start_date < p_start_date
                AND NVL(s.end_date, hr_general.END_OF_TIME) < p_start_date)
           OR  (s.start_date > p_end_date
               AND NVL(s.end_date, hr_general.END_OF_TIME)
                            > NVL(p_end_date, hr_general.END_OF_TIME))
           )
    AND p_time_recipient_id <> -1   ;
--
BEGIN
   --
   OPEN c_chk_overlapping_dates_update;
   --
   FETCH c_chk_overlapping_dates_update INTO p_clashing_id
                                             ,p_clashing_ovn
                                             ,p_clashing_start_date
                                             ,p_clashing_end_date;
   --
   IF c_chk_overlapping_dates_update%NOTFOUND THEN
      p_clashing_id := NULL;
   END IF;
   --
   CLOSE c_chk_overlapping_dates_update;

  --
END chk_overlapping_dates_update;
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
   	,p_parent_comp_ovn  IN hxc_approval_comps.parent_comp_ovn%TYPE   )


IS
--
l_approval_comp_id hxc_approval_comps.approval_comp_id%TYPE;
l_object_version_number hxc_approval_comps.object_version_number%TYPE;

CURSOR c_chk_master_record_exists
IS
SELECT s.approval_comp_id
      ,s.object_version_number
 FROM hxc_approval_comps s
 WHERE s.approval_comp_id = p_parent_comp_id
  AND  s.object_version_number = p_parent_comp_ovn
  AND  s.approval_mechanism = 'ENTRY_LEVEL_APPROVAL';
--
BEGIN
   --
   IF p_parent_comp_id is not null and p_parent_comp_ovn is not null then

      OPEN c_chk_master_record_exists;
      FETCH c_chk_master_record_exists into l_approval_comp_id,l_object_version_number;

      IF c_chk_master_record_exists%NOTFOUND then

       CLOSE c_chk_master_record_exists;
       hr_utility.set_message
	             (809
	             ,'HXC_0402_HAC_COMP_PAR_REC_NF'
	             );
       hr_utility.raise_error;

      END IF;

      CLOSE c_chk_master_record_exists;

   END IF;

  --
END chk_master_detail_rel;
--

--
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
   	,p_parent_comp_ovn  IN hxc_approval_comps.parent_comp_ovn%TYPE   )

IS
--
--
BEGIN
   --
   IF (p_parent_comp_id is not null and p_parent_comp_ovn is null) or
      (p_parent_comp_id is null and p_parent_comp_ovn is not null) then

       hr_utility.set_message
	             (809
	             ,'HXC_0403_HAC_ELA_PAR_INV'
	             );
       hr_utility.raise_error;


   END IF;

  --
END chk_parent_fields;


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
   	,p_time_category_id IN hxc_approval_comps.time_category_id%TYPE )

IS
--

CURSOR c_time_category_exists
IS
SELECT 'Y'
 FROM hxc_time_categories htc
 WHERE htc.time_category_id = p_time_category_id;

l_dummy VARCHAR2(1);
--
BEGIN
   --
   IF p_parent_comp_id is null and p_parent_comp_ovn is null and
      p_time_category_id is not null then
	          hr_utility.set_message
	 		 	             (809
	 		 	             ,'HXC_0404_HAC_ELA_TIM_CAT_NN');
   	          hr_utility.raise_error;
   END IF;


   IF p_parent_comp_id is not null and p_parent_comp_ovn is not null then

      IF p_time_category_id is null then
         hr_utility.set_message
		 	             (809
		 	             ,'HXC_0405_HAC_ELA_TIM_CAT_NULL'
	             );
    	   hr_utility.raise_error;
     ELSE

        IF p_time_category_id <> 0 then

		  OPEN c_time_category_exists;
		  FETCH c_time_category_exists into l_dummy;

		  IF c_time_category_exists%NOTFOUND then
           CLOSE c_time_category_exists;
		   hr_utility.set_message
					 (809
					 ,'HXC_0406_HAC_ELA_TIM_CAT_NF'
					 );
		   hr_utility.raise_error;

          END IF;
      CLOSE c_time_category_exists;
       END IF;
   END IF;
END IF;
  --
END chk_tim_cat;

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
   	,p_parent_comp_ovn  IN hxc_approval_comps.parent_comp_ovn%TYPE   )


IS
--
l_approval_comp_id hxc_approval_comps.approval_comp_id%TYPE;
l_object_version_number hxc_approval_comps.object_version_number%TYPE;

CURSOR c_def_ela_rec_exists
IS
SELECT s.approval_comp_id
      ,s.object_version_number
 FROM hxc_approval_comps s
 WHERE s.approval_comp_id <> nvl(p_approval_comp_id,-99)
  AND  s.parent_comp_id = p_parent_comp_id
  AND  s.parent_comp_ovn = p_parent_comp_ovn
  AND  s.time_category_id = p_time_category_id;
--
BEGIN
   --
    IF p_parent_comp_id is not null and p_parent_comp_ovn is not null and p_time_category_id = 0
    then
      OPEN c_def_ela_rec_exists;
      FETCH c_def_ela_rec_exists into l_approval_comp_id,l_object_version_number;

      IF c_def_ela_rec_exists%FOUND then
       CLOSE c_def_ela_rec_exists;
       hr_utility.set_message
	             (809
	             ,'HXC_0407_HAC_ELA_DEF_EXISTS'
	             );
       hr_utility.raise_error;

      END IF;
    CLOSE c_def_ela_rec_exists;
    END IF;
  --
END chk_def_ela_rec_exists;
--

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
   	,p_time_recipient_id IN hxc_approval_comps.time_recipient_id%TYPE )

IS
--

CURSOR c_time_recipient_exists
IS
SELECT 'Y'
 FROM hxc_time_recipients htr
 WHERE htr.time_recipient_id = p_time_recipient_id;

l_dummy VARCHAR2(1);
--
BEGIN
   --
   IF p_parent_comp_id is null and p_parent_comp_ovn is null then

		  OPEN c_time_recipient_exists;
		  FETCH c_time_recipient_exists into l_dummy;

		  IF c_time_recipient_exists%NOTFOUND then
           CLOSE c_time_recipient_exists;
		   hr_utility.set_message
					 (809
					 ,'HXC_0408_HAC_COMP_TRP_NF'
					 );
		   hr_utility.raise_error;

          END IF;
          CLOSE c_time_recipient_exists;
   END IF;


   IF p_parent_comp_id is not null and p_parent_comp_ovn is not null then

      IF p_time_recipient_id <> -1 THEN
         hr_utility.set_message
		 	             (809
		 	             ,'HXC_0409_HAC_ELA_TRP'
	             );

	     hr_utility.raise_error;

      END IF;

   END IF;

  --
END chk_tim_rcp;
--
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
   	,p_wf_item_type IN hxc_approval_comps.wf_item_type%TYPE)

IS
--
l_dummy varchar2(1);

CURSOR c_tim_cat_exists
IS
SELECT 'Y'
 FROM hxc_approval_comps s
 WHERE s.approval_comp_id <> nvl(p_approval_comp_id,-99)
  AND  s.parent_comp_id = p_parent_comp_id
  AND  s.parent_comp_ovn = p_parent_comp_ovn
  AND  s.time_category_id = p_time_category_id
  AND  p_time_category_id <> 0
  AND  ((s.approval_order = p_approval_order) or
        (s.approval_order is null) or
        (p_approval_order is null)
       );

CURSOR c_tim_cat_dup
IS
SELECT 'Y'
 FROM hxc_approval_comps s
 WHERE s.approval_comp_id <> nvl(p_approval_comp_id,-99)
  AND  s.parent_comp_id = p_parent_comp_id
  AND  s.parent_comp_ovn = p_parent_comp_ovn
  AND  s.time_category_id = p_time_category_id
  AND  p_time_category_id <> 0
  AND  s.approval_mechanism = p_approval_mechanism
  AND  nvl(s.approval_mechanism_id,-99) = nvl(p_approval_mechanism_id,-99)
  AND  nvl(s.wf_name,'0') = nvl (p_wf_name,'0')
  AND  nvl(s.wf_item_type,'0') = nvl (p_wf_item_type,'0');

--
BEGIN
   --
 IF p_parent_comp_id is not null and
    p_parent_comp_ovn  is not null then

      OPEN c_tim_cat_exists;
      FETCH c_tim_cat_exists into l_dummy;

      IF c_tim_cat_exists%FOUND then
       CLOSE c_tim_cat_exists;
       hr_utility.set_message
	             (809
	             ,'HXC_0410_HAC_ELA_TIMCAT_EXISTS'
	             );
       hr_utility.raise_error;

      END IF;
      CLOSE c_tim_cat_exists;


      OPEN c_tim_cat_dup;
      FETCH c_tim_cat_dup into l_dummy;

      IF c_tim_cat_dup%FOUND then
      CLOSE c_tim_cat_dup;

       hr_utility.set_message
	             (809
	             ,'HXC_0411_HAC_ELA_DUP_TIMCAT'
	             );
       hr_utility.raise_error;

      END IF;
      CLOSE c_tim_cat_dup;


 END IF;
  --
END chk_tim_cat_dup;
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
   )

IS
--
BEGIN
   --
 IF p_parent_comp_id is not null and
    p_parent_comp_ovn  is not null then

   IF p_time_category_id = 0 then
      IF (p_approval_mechanism = 'PROJECT_MANAGER' or
          p_approval_mechanism = 'ENTRY_LEVEL_APPROVAL') then

          hr_utility.set_message
	             (809
	             ,'HXC_0412_HAC_DEF_APP_MECH'
	             );
          hr_utility.raise_error;

      END IF;

   ELSE
       IF (p_approval_mechanism = 'ENTRY_LEVEL_APPROVAL') then

        hr_utility.set_message
   	             (809
   	             ,'HXC_0413_HAC_ELA_APP_MECH'
   	             );
        hr_utility.raise_error;

        END IF;

   END IF;

 END IF;
  --
END chk_app_mech_for_child;

--
-- ----------------------------------------------------------------------------
-- |---------< chk_allowable_extensions >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
-- Description:
--   Procedure to check run_recipient_extensions.
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
   p_run_recipient_extensions in hxc_approval_comps.run_recipient_extensions%type
  ,p_approval_style_id in hxc_approval_comps.approval_style_id%type
  ) is

cursor crs_approval_extensions is select
run_recipient_extensions from
hxc_approval_styles
where
approval_style_id=p_approval_style_id;
approval_style_extensions hxc_approval_styles.run_recipient_extensions%type;
Begin
if not(p_run_recipient_extensions is null or p_run_recipient_extensions in ('Y','N'))
then
   hr_utility.set_message(809,'HXC_VALUE_RECIPIENT_EXTENSIONS');
     hr_utility.raise_error;
else
 open crs_approval_extensions;
 fetch crs_approval_extensions into approval_style_extensions;
 close crs_approval_extensions;
 if (approval_style_extensions is null or approval_style_extensions in ('N'))
 then
   if not(p_run_recipient_extensions is null or p_run_recipient_extensions ='N')
   then
      hr_utility.set_message(809,'HXC_VALUE_RECIPIENT_EXTENSIONS');
     hr_utility.raise_error;
   end if;
 end if;
end if;
end chk_allowable_extensions;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_hac_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'insert_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  --
  -- Do some checks on the date of the approval components
  --
   chk_approval_comp_dates
      (p_approval_comp_id => p_rec.approval_comp_id
      ,p_start_date       => p_rec.start_date
      ,p_end_date         => p_rec.end_date
      );
  --
   chk_invalid_dates_create
      (p_approval_style_id => p_rec.approval_style_id
      ,p_time_recipient_id => p_rec.time_recipient_id
      ,p_start_date        => p_rec.start_date
      ,p_end_date          => p_rec.end_date
      );
  --
   chk_overlapping_dates_create
      (p_approval_style_id  => p_rec.approval_style_id
      ,p_time_recipient_id => p_rec.time_recipient_id
      ,p_start_date        => p_rec.start_date
      ,p_end_date          => p_rec.end_date
      );
   --
  --
  chk_parent_fields
      (p_parent_comp_id    => p_rec.parent_comp_id
      ,p_parent_comp_ovn   => p_rec.parent_comp_ovn);

  chk_tim_cat
     (p_parent_comp_id    => p_rec.parent_comp_id
     ,p_parent_comp_ovn   => p_rec.parent_comp_ovn
     ,p_time_category_id  => p_rec.time_category_id);

  chk_tim_rcp
     (p_parent_comp_id    => p_rec.parent_comp_id
     ,p_parent_comp_ovn   => p_rec.parent_comp_ovn
     ,p_time_recipient_id => p_rec.time_recipient_id);

  chk_def_ela_rec_exists
     (p_approval_comp_id => p_rec.approval_comp_id
     ,p_time_category_id  => p_rec.time_category_id
     ,p_parent_comp_id    => p_rec.parent_comp_id
     ,p_parent_comp_ovn   => p_rec.parent_comp_ovn );


  chk_tim_cat_dup
     ( p_approval_comp_id => p_rec.approval_comp_id
      ,p_time_category_id => p_rec.time_category_id
      ,p_approval_order => p_rec.approval_order
      ,p_parent_comp_id => p_rec.parent_comp_id
   	  ,p_parent_comp_ovn  => p_rec.parent_comp_ovn
   	  ,p_approval_mechanism => p_rec.approval_mechanism
   	  ,p_approval_mechanism_id => p_rec.approval_mechanism_id
   	  ,p_wf_name => p_rec.wf_name
   	  ,p_wf_item_type => p_rec.wf_item_type);

   chk_app_mech_for_child
     ( p_time_category_id => p_rec.time_category_id
      ,p_approval_mechanism => p_rec.approval_mechanism
      ,p_parent_comp_id => p_rec.parent_comp_id
      ,p_parent_comp_ovn  => p_rec.parent_comp_ovn
     );


  --do some checks on the master detail relationship

  chk_master_detail_rel
      (p_parent_comp_id    => p_rec.parent_comp_id
      ,p_parent_comp_ovn   => p_rec.parent_comp_ovn);

  chk_allowable_extensions
    (
     p_run_recipient_extensions => p_rec.run_recipient_extensions
    ,p_approval_style_id        => p_rec.approval_style_id
    );

  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_hac_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'update_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  -- Do some checks on the date of the approval components
  --
   chk_approval_comp_dates
      (p_approval_comp_id => p_rec.approval_comp_id
      ,p_start_date       => p_rec.start_date
      ,p_end_date         => p_rec.end_date
      );
  --
   chk_invalid_dates_update
      (p_approval_comp_id => p_rec.approval_comp_id
      ,p_approval_style_id => p_rec.approval_style_id
      ,p_time_recipient_id => p_rec.time_recipient_id
      ,p_start_date        => p_rec.start_date
      ,p_end_date          => p_rec.end_date
      );
  --
   chk_overlapping_dates_update
      (p_approval_comp_id  => p_rec.approval_comp_id
      ,p_approval_style_id => p_rec.approval_style_id
      ,p_time_recipient_id => p_rec.time_recipient_id
      ,p_start_date        => p_rec.start_date
      ,p_end_date          => p_rec.end_date
      );

  chk_parent_fields
      (p_parent_comp_id    => p_rec.parent_comp_id
      ,p_parent_comp_ovn   => p_rec.parent_comp_ovn);

  chk_tim_cat
     (p_parent_comp_id    => p_rec.parent_comp_id
     ,p_parent_comp_ovn   => p_rec.parent_comp_ovn
     ,p_time_category_id  => p_rec.time_category_id);

  chk_tim_rcp
     (p_parent_comp_id    => p_rec.parent_comp_id
     ,p_parent_comp_ovn   => p_rec.parent_comp_ovn
     ,p_time_recipient_id => p_rec.time_recipient_id);

  chk_def_ela_rec_exists
     (p_approval_comp_id => p_rec.approval_comp_id
     ,p_time_category_id  => p_rec.time_category_id
     ,p_parent_comp_id    => p_rec.parent_comp_id
     ,p_parent_comp_ovn   => p_rec.parent_comp_ovn );

  chk_tim_cat_dup
     ( p_approval_comp_id => p_rec.approval_comp_id
      ,p_time_category_id => p_rec.time_category_id
      ,p_approval_order => p_rec.approval_order
      ,p_parent_comp_id => p_rec.parent_comp_id
   	  ,p_parent_comp_ovn  => p_rec.parent_comp_ovn
   	  ,p_approval_mechanism => p_rec.approval_mechanism
   	  ,p_approval_mechanism_id => p_rec.approval_mechanism_id
   	  ,p_wf_name => p_rec.wf_name
   	  ,p_wf_item_type => p_rec.wf_item_type);

  chk_app_mech_for_child
     ( p_time_category_id => p_rec.time_category_id
      ,p_approval_mechanism => p_rec.approval_mechanism
      ,p_parent_comp_id => p_rec.parent_comp_id
      ,p_parent_comp_ovn  => p_rec.parent_comp_ovn
     );
   chk_allowable_extensions
      (
       p_run_recipient_extensions => p_rec.run_recipient_extensions
      ,p_approval_style_id        => p_rec.approval_style_id
      );
--do some checks on the master detail relationship

  chk_master_detail_rel
      (p_parent_comp_id    => p_rec.parent_comp_id
      ,p_parent_comp_ovn   => p_rec.parent_comp_ovn);
   --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hxc_hac_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'delete_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_hac_bus;

/
