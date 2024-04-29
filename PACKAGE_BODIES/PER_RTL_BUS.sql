--------------------------------------------------------
--  DDL for Package Body PER_RTL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RTL_BUS" as
/* $Header: pertlrhi.pkb 120.0 2005/05/31 19:57:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_rtl_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_non_updateable_args >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args(p_rec in per_rtl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'check_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_rtl_shd.api_updating
                (p_rating_level_id          => p_rec.rating_level_id
                ,p_object_version_number    => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  hr_utility.set_location(l_proc, 6);
  --
  if p_rec.business_group_id <> per_rtl_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if p_rec.step_value <> per_rtl_shd.g_old_rec.step_value then
     l_argument := 'step_value';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 8);
  --
  if p_rec.competence_id <> per_rtl_shd.g_old_rec.competence_id then
     l_argument := 'competence_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 9);
  --
  if p_rec.rating_scale_id <> per_rtl_shd.g_old_rec.rating_scale_id then
     l_argument := 'rating_scale_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 8);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end chk_non_updateable_args;
-----------------------------------------------------------------------------
------------------------<chk_rat_comp_bg_exists>------------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the rating scale or competence exists and is within the
--     same business group as that of rating level
--
--  Pre_conditions:
--
--
--  In Arguments:
--    p_rating_level_id
--    p_competence_id
--    p_object_version_number
--    p_rating_scale_id
--    p_business_group_id
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      -- rating scale or competence does not exist
--      -- rating scale or competence exists but not with the same business group
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_rat_comp_bg_exists
(p_rating_level_id	     in	     per_rating_levels.rating_level_id%TYPE
,p_object_version_number     in      per_rating_levels.object_version_number%TYPE
,p_business_group_id	     in	     per_rating_levels.business_group_id%TYPE  default null
,p_competence_id             in      per_rating_levels.competence_id%TYPE
,p_rating_scale_id	     in      per_rating_levels.rating_scale_id%TYPE
)
is
--
	l_exists	     varchar2(1);
        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_rat_comp_bg_exists';
        l_business_group_id  per_rating_levels.business_group_id%TYPE;
--
	--
	-- Cursor to check if rating scale exists
	--
	Cursor csr_rat_scale_bus_grp_exist
          is
	select  business_group_id
	from	per_rating_scales
	where   rating_scale_id = p_rating_scale_id;
	--
	--
	-- Cursor to check if competence exists
	--
	Cursor csr_competence_bus_grp_exist
          is
	select  business_group_id
	from	per_competences
	where   competence_id	= p_competence_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current
  --
  l_api_updating := per_rtl_shd.api_updating
         (p_rating_level_id          => p_rating_level_id
         ,p_object_version_number  => p_object_version_number);

     --
     hr_utility.set_location(l_proc, 2);
     --
     if p_rating_scale_id is not null then
        open csr_rat_scale_bus_grp_exist;
        fetch csr_rat_scale_bus_grp_exist into l_business_group_id;
	if csr_rat_scale_bus_grp_exist%notfound then
            close csr_rat_scale_bus_grp_exist;
            hr_utility.set_message(801,'HR_51471_RTL_RSC_NOT_EXIST');
            hr_utility.raise_error;
	end if;
        close csr_rat_scale_bus_grp_exist;
	-- check if rating scale is in the same business group
        -- ngundura changes done for pa requirements.
	if p_business_group_id is null then
	    if l_business_group_id is not null then
		fnd_message.set_name('PER','HR_52694_ENTER_GLOB_RAT_SCAL');
		fnd_message.raise_error;
	    end if;
	else
            if nvl(l_business_group_id,hr_api.g_number) <> p_business_group_id then
	       hr_utility.set_message(801,'HR_51470_RTL_RSC_DIFF_BUS_GRP');
	       hr_utility.raise_error;
	    end if;
        end if;
        -- ngundura changes done for pa requirements.
     end if;
     --
     hr_utility.set_location(l_proc, 3);
     --
     if p_competence_id is not null then
        open csr_competence_bus_grp_exist;
        fetch csr_competence_bus_grp_exist into l_business_group_id;
	if csr_competence_bus_grp_exist%notfound then
            close csr_competence_bus_grp_exist;
            hr_utility.set_message(801,'HR_51472_RTL_CPN_NOT_EXIST');
            hr_utility.raise_error;
	end if;
        close csr_competence_bus_grp_exist;
	-- check if rating scale is in the same business group
        -- ngundura changes for pa requirements..
	if p_business_group_id is null then
		if l_business_group_id is not null then
		    fnd_message.set_name('PER','HR_52694_ENTER_GLOB_RAT_SCAL');
		    fnd_message.raise_error;
		end if;
	else
        	if nvl(l_business_group_id,hr_api.g_number) <> p_business_group_id then
	            hr_utility.set_message(801,'HR_51473_RTL_CPN_DIFF_BUS_GRP');
	            hr_utility.raise_error;
		end if;
        end if;
        -- ngundura end of changes.
     end if;
     --
     hr_utility.set_location(l_proc, 4);
     --
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
end chk_rat_comp_bg_exists;
--
-------------------------------------------------------------------------------
-------------------------------< not_used_chk_name >------------------------------------
-------------------------------------------------------------------------------
--
--
--  Description:
--   - Validates that a valid rating level name is entered
--     and is unique for a rating scale or a competence
--
--
--  In Arguments:
--    p_rating_level_id
--    p_name
--    p_object_version_number
--    p_rating_scale_id
--    p_competence_id
--
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	- name is invalid
--	- name is not unique
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure not_used_chk_name
(p_rating_level_id	     in	     per_rating_levels.rating_level_id%TYPE
,p_object_version_number     in      per_rating_levels.object_version_number%TYPE
,p_name			     in      per_rating_levels.name%TYPE
,p_rating_scale_id	     in	     per_rating_levels.rating_scale_id%TYPE
,p_competence_id	     in	     per_rating_levels.competence_id%TYPE
)
is
--
	l_exists             varchar2(1);
	l_api_updating	     boolean;
  	l_proc               varchar2(72)  :=  g_package||'not_used_chk_name';
	--
	-- Cursor to check if name is unique for rating scale or competence
        --
	cursor csr_chk_name_unique is
	  select 'Y'
	  from   per_rating_levels
	  where  (   (p_rating_level_id is null)
		   or(p_rating_level_id <> rating_level_id)
		 )
	  and	 name = p_name
	  and    (  (nvl(competence_id,hr_api.g_number)
			= nvl(p_competence_id,hr_api.g_number) )
		  and(nvl(rating_scale_id,hr_api.g_number)
			= nvl(p_rating_scale_id,hr_api.g_number))
		 );
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
   --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for name has changed
  --
  l_api_updating := per_rtl_shd.api_updating
         (p_rating_level_id	   => p_rating_level_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (  (l_api_updating and (per_rtl_shd.g_old_rec.name
		        <> nvl(p_name,hr_api.g_varchar2))
         ) or
        (NOT l_api_updating)
      ) then
     --
     hr_utility.set_location(l_proc, 2);
     --
     -- check if the user has entered a name, as name is
     -- is mandatory column.
     --
     if p_name is null then
       hr_utility.set_message(801,'HR_51475_RTL_NAME_MANDATORY');
       hr_utility.raise_error;
     end if;
     --
     -- check if name is unique
     --
     open csr_chk_name_unique;
     fetch csr_chk_name_unique into l_exists;
     if csr_chk_name_unique%found then
       hr_utility.set_location(l_proc, 3);
       -- name is not unique
       close csr_chk_name_unique;
       hr_utility.set_message(801,'HR_51474_RTL_NOT_UNIQUE');
       hr_utility.raise_error;
     end if;
     close csr_chk_name_unique;
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 10);
end not_used_chk_name;
--
-------------------------------------------------------------------------------
-- |----------------------< chk_step_value>--------------------------------| --
-------------------------------------------------------------------------------
--
-- Description
--   Validates the STEP_VALUE exists
--   Validates that STEP_VALUE is an integer.
--
-- Pre-conditions
--
-- In Arguments
--  p_step_value
--
-- Post Success:
--  Process continues if:
--  Step value is an integer.
--
-- Post Failure:
--  An application error is raised and processing is terminated if any of the
--  following cases are found:
--   - Step Value is not an integer.
--
-- Access Status
--  Internal Table Handler Use Only.
--
procedure chk_step_value
  (p_step_value            in per_rating_levels.step_value%TYPE
  ,p_rating_level_id	   in per_rating_levels.rating_level_id%TYPE
  ,p_rating_scale_id	   in per_rating_levels.rating_scale_id%TYPE
  ,p_competence_id	   in per_rating_levels.competence_id%TYPE
  ) is
--
  l_proc          varchar2(72) := g_package||' chk_step_value';
  l_api_updating  boolean;
  l_intnum        number;
  l_decpoint      varchar2(1);
  l_exists	  varchar2(1);
--
	--
	-- Cursor to check if step value is unique for rating scale or competence
        --
    cursor csr_chk_step_unique is
	  select 'Y'
	  from   per_rating_levels
	  where  (   (p_rating_level_id is null)
		   or(p_rating_level_id <> rating_level_id)
		 )
	  and	 step_value = p_step_value
	  and    (  (competence_id   = p_competence_id)
		  or(rating_scale_id = p_rating_scale_id)
		 );
--
begin
  hr_utility.set_location ('Entering '||l_proc, 1);
     --
     -- check if the user has entered a step value, as it
     -- is a mandatory column.
     --
     if p_step_value is null then
       hr_utility.set_message(801,'HR_51476_RTL_STEP_MANDATORY');
       hr_utility.raise_error;
     end if;
--
-- Check that step value is an integer
--
    l_intnum   := to_char(p_step_value);
    l_decpoint := substr(to_char(1/2),1,1); -- get dec point character.
    if (instr(l_intnum, l_decpoint) <> 0) then
      hr_utility.set_location (l_proc, 2);
      hr_utility.set_message (801, 'HR_51483_RTL_STEP_NOT_INT');
      hr_utility.raise_error;
    end if;
--
-- Check if step value is unique for rating scale or competence
--
     open csr_chk_step_unique;
     fetch csr_chk_step_unique into l_exists;
     if csr_chk_step_unique%found then
       hr_utility.set_location(l_proc, 3);
       -- step value is not unique
       close csr_chk_step_unique;
       hr_utility.set_message(801,'HR_51477_RTL_STEP_NOT_UNIQUE');
       hr_utility.raise_error;
     end if;
     close csr_chk_step_unique;
  hr_utility.set_location ('Leaving '||l_proc, 3);
--
end chk_step_value;
--
-------------------------------------------------------------------------------
-- |-------------------------< chk_rating_level_add_del >------------------|
-------------------------------------------------------------------------------
--
-- Description
-- This function validates that:
--   No new levels can be added to a competence that has a general proficiency
--   scale assigned to it.
--   No new levels can be added or deleted if rating levels is referenced in:
--                           - a Competence that is used in Competence Element
--			     - a Rating Scale that is used in a Competence
--			     - a Rating Scale that is used in an Assessment
--			       Type
--			     - a Performance Rating
--
-- Pre-conditions
--
--
-- In Arguments
--   p_rating_level_id
--   p_object_version_number
--   p_competence_id
--   p_rating_scale_id
--   p_mode (is defaulted)
--
-- Post Success
--   The rating scale is not referenced elsewhere and a level is added
--   The rating scale step is not referenced elsewhere and a level is deleted
--
-- Post Failure
--   An application error is raised and processing is terminated if the rating
--   scale is referenced in any one of the above
--
-- Access Status
--   Internal Table Handler Use Only.
--
procedure chk_rating_level_add_del
  (p_rating_level_id       in per_rating_levels.rating_level_id%TYPE
  ,p_object_version_number in per_rating_levels.object_version_number%TYPE
  ,p_competence_id	   in per_rating_levels.competence_id%TYPE
  ,p_rating_scale_id	   in per_rating_levels.rating_scale_id%TYPE
  ,p_mode		   in varchar2 default null
  ) is
--
  l_proc          varchar2(72) := g_package||'chk_rating_level_add_del';
  l_api_updating  boolean;
  l_exists        varchar2(1);
--
-- Cursor to check that a rating level cannot be added to a competence
-- that has a general proficiency scale assigned to it.
--
 Cursor csr_chk_rating_in_competence is
  select null
  from	 per_competences cpn
  where  cpn.competence_id = p_competence_id
  and    cpn.rating_scale_id is not null;
--
-- Cursor to check if rating level used in a competence that is used
-- in a competence element
--
-- bug fix 4063493
-- condition added to cursor to check the competence element type.
 Cursor csr_chk_competence is
  select null
  from   per_rating_levels rtl, per_competences cp,
	 per_competence_elements ce
  where  rtl.competence_id    = p_competence_id
  and    rtl.competence_id    = cp.competence_id
  and    cp.competence_id     = ce.competence_id
  and    ce.type in ('ASSESSMENT_COMPETENCE','REQUIREMENT',
                     'PERSONAL');
--
-- Cursor to check if rating level used in a rating scale that is used in
-- in a competence
--
 Cursor csr_chk_rat_competence is
  select null
  from   per_rating_levels rtl,
         per_rating_scales rsc,
         per_competences cp
  where  rtl.rating_scale_id 		= p_rating_scale_id
  and    rtl.rating_scale_id 		= rsc.rating_scale_id
  and    rsc.rating_scale_id		= cp.rating_scale_id ;

--
-- Cursor to check if rating level used in an Assessment Type that is
--
 Cursor csr_chk_ass_types is
  select null
  from   per_rating_levels rtl,
         per_rating_scales rsc,
         per_assessment_types aty
  where  rtl.rating_scale_id 		= p_rating_scale_id
  and    rtl.rating_scale_id		= rsc.rating_scale_id
  and    (  (rsc.rating_scale_id	= aty.rating_scale_id)
          or(rsc.rating_scale_id	= aty.weighting_scale_id)
         );
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
--
-- Check if the rating scale is being used as a proficiency scale
-- for a competence
--
   hr_utility.set_location (l_proc, 2);
   if p_competence_id is not null and p_mode = 'ADD' then
    open csr_chk_rating_in_competence;
    fetch csr_chk_rating_in_competence into l_exists;
    if csr_chk_rating_in_competence%found then
      hr_utility.set_message (801,'HR_51438_COMP_PROF_LVL_EXIST');
      hr_utility.raise_error;
    end if;
    close csr_chk_rating_in_competence;
   end if;
--
-- Check if rating level is for competence that is used in competence
-- element.
--
   hr_utility.set_location (l_proc, 3);
   open csr_chk_competence;
   fetch csr_chk_competence into l_exists;
   if csr_chk_competence%found then
      close csr_chk_competence;
      hr_utility.set_message (801,'HR_51479_RTL_CPN_EXIST_IN_ELE');
      hr_utility.raise_error;
   end if;
   close csr_chk_competence;
--
-- Check if rating level is for a Rating Scale that is used in a
-- Competence
--
   hr_utility.set_location (l_proc, 4);
   open csr_chk_rat_competence;
   fetch csr_chk_rat_competence into l_exists;
   if csr_chk_rat_competence%found then
      close csr_chk_rat_competence;
      hr_utility.set_message (801,'HR_51480_RTL_RSC_IN_CPN');
      hr_utility.raise_error;
   end if;
   close csr_chk_rat_competence;
--
-- Check if rating level is for a Rating Scale that is used
-- in an Assessment Type
--
   hr_utility.set_location (l_proc, 5);
   open csr_chk_ass_types;
   fetch csr_chk_ass_types into l_exists;
   if csr_chk_ass_types%found then
      close csr_chk_ass_types;
      hr_utility.set_message (801,'HR_51481_RTL_RSC_IN_AST');
      hr_utility.raise_error;
   end if;
   close csr_chk_ass_types;
--
end chk_rating_level_add_del;
--
-------------------------------------------------------------------------------
-- |-------------------------< chk_rating_level_in_ele >--------------------|
-------------------------------------------------------------------------------
--
-- Description
-- This function validates that:
--  - if rating level is used in competence element, then do not allow delete
--
-- Pre-conditions
-- valid rating_level_id
--
-- In Arguments
--   p_rating_level_id
--   p_object_version_number
--
-- Post Success
--   The rating scale is not referenced in competence element
--
-- Post Failure
--   An application error is raised and processing is terminated if the rating
--   scale is referenced in competence element
--
-- Access Status
--   Internal Table Handler Use Only.
--
-- Bug 3771360 Starts Here
-- Desc: Re written the procedure by using the ref cursor to improve the performance
--
procedure chk_rating_level_in_ele
  (p_rating_level_id       in per_rating_levels.rating_level_id%TYPE
  ,p_object_version_number in per_rating_levels.object_version_number%TYPE
  ) is
--
  l_proc          varchar2(72) := g_package||'chk_rating_level_in_ele';
  l_api_updating  boolean;
  l_exists        varchar2(1);
  l_error         varchar2(1);  -- bug 3771360
--
-- Cursor to check if rating level used in competence element
--
Type cref is Ref Cursor;
cmp_csr cref;
l_sql_stmt varchar2(2000);
l_sql_stmt1 varchar2(2000);
l_sql_stmt2 varchar2(2000);
l_sql_stmt3 varchar2(2000);
l_sql_stmt4 varchar2(2000);

--
begin
   -- check if rating level is used in competence element
   hr_utility.set_location (l_proc, 1);
  l_error := 'N';
  l_sql_stmt := 'select null
               from per_rating_levels rtl,per_competence_elements perce
               where rtl.rating_level_id = '||p_rating_level_id||
               ' and rtl.rating_level_id = ';
  l_sql_stmt1 := l_sql_stmt||'perce.rating_level_id';

   -- check if rating level is used in competence element
   hr_utility.set_location (l_proc, 1);

  open cmp_csr for l_sql_stmt1;
  fetch cmp_csr into l_exists;
  if cmp_csr%notfound then
    close cmp_csr;
    l_sql_stmt2 := l_sql_stmt||'perce.weighting_level_id';
    open cmp_csr for l_sql_stmt2;
    fetch cmp_csr into l_exists;
--
    if cmp_csr%notfound then
      close cmp_csr;
      l_sql_stmt3 := l_sql_stmt||'perce.proficiency_level_id';
      open cmp_csr for l_sql_stmt3;
      fetch cmp_csr into l_exists;
--
        if cmp_csr%notfound then
          close cmp_csr;
          l_sql_stmt4 := l_sql_stmt||'perce.high_proficiency_level_id';
          open cmp_csr for l_sql_stmt4;
          fetch cmp_csr into l_exists;
            if cmp_csr%notfound then
              close cmp_csr;
              l_error := 'N';
--            l_err = 1;
            else
              close cmp_csr;
              l_error := 'Y';
            end if;
        else
          close cmp_csr;
          l_error := 'Y';
        end if;
     else
       close cmp_csr;
       l_error := 'Y';
     end if;
 else
 close cmp_csr;
   l_error := 'Y';
 end if;
--
   if l_error = 'Y' then
      hr_utility.set_message (801,'HR_51479_RTL_CPN_EXIST_IN_ELE');
      hr_utility.raise_error;
   end if;
   --
   --
end chk_rating_level_in_ele;
--
-- Bug 3771360 Ends Here
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_df
  (p_rec in per_rtl_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if (((p_rec.rating_level_id is not null) and (
     nvl(per_rtl_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_rtl_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.rating_level_id is null))
     and hr_rating_levels_api.g_ignore_df <> 'Y' then -- BUG3621261
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_RATING_LEVELS'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_rtl_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- ngundura changes done as per pa requirements.
  hr_utility.set_location('p_rec.business_group_id :'|| to_char(p_rec.business_group_id),99);
  if p_rec.business_group_id is not null then
       hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  -- end of changes
  --
  --
  -- Check mandatory parameters rating_scale_id or competence_id are set.
  -- Only one of them has to be set and not both.
  -- Both cannot be null.
  --
     if (   ( p_rec.rating_scale_id is not null and p_rec.competence_id is not null )
	 or ( p_rec.rating_scale_id is null and p_rec.competence_id is null )
        )
      then
        hr_utility.set_message(801,'HR_51482_RTL_RSC_OR_CPN');
        hr_utility.raise_error;
     end if;
  --
  -- chk rating scale or competence exist within the
  -- same business group
  --
 hr_utility.set_location('Entering per_rtl_bus.chk_rat_comp_bg_exists',9999);
  per_rtl_bus.chk_rat_comp_bg_exists
  (p_rating_level_id		=> p_rec.rating_level_id
  ,p_object_version_number	=> p_rec.object_version_number
  ,p_business_group_id		=> p_rec.business_group_id
  ,p_competence_id		=> p_rec.competence_id
  ,p_rating_scale_id		=> p_rec.rating_scale_id
  );
  --
  -- Rule check step value is not null and is an integer value
  --
  hr_utility.set_location('Entering per_rtl_bus.chk_step_value',99);
  per_rtl_bus.chk_step_value
  (p_step_value			=> p_rec.step_value
  ,p_rating_level_id		=> p_rec.rating_level_id
  ,p_rating_scale_id		=> p_rec.rating_scale_id
  ,p_competence_id		=> p_rec.competence_id
  );

  --
  -- pmfletch Now called from TL row handler
  --
  -- Rule Check unique level name
  --
  --per_rtl_bus.chk_name
  --(p_rating_level_id		=> p_rec.rating_level_id
  --,p_object_version_number	=> p_rec.object_version_number
  --,p_name			=> p_rec.name
  --,p_rating_scale_id		=> p_rec.rating_scale_id
  --,p_competence_id		=> p_rec.competence_id
  --);
  --
  -- Check if a new level can be inserted for a
  -- rating scale or competence
  --
  per_rtl_bus.chk_rating_level_add_del
  (p_rating_level_id		=> p_rec.rating_level_id
  ,p_object_version_number	=> p_rec.object_version_number
  ,p_competence_id		=> p_rec.competence_id
  ,p_rating_scale_id		=> p_rec.rating_scale_id
  );
  --
  -- call descriptive flexfield validation routines
  --
/*
  IF hr_general.get_calling_context <>'FORMS' THEN
    per_rtl_flex.df(p_rec => p_rec);
  END IF;
*/
  --
  per_rtl_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_rtl_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_rec.business_group_id is not null then
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  -- Rule Check Business group id and step value cannot be updated
  --
  chk_non_updateable_args(p_rec	=> p_rec);
  --
  -- pmfletch - Now called from TL row handler
  --
  -- Rule Check unique level name
  --
  --per_rtl_bus.chk_name
  --(p_rating_level_id		=> p_rec.rating_level_id
  --,p_object_version_number	=> p_rec.object_version_number
  --,p_name			=> p_rec.name
  --,p_rating_scale_id		=> p_rec.rating_scale_id
  --,p_competence_id		=> p_rec.competence_id
  --);
  --
  -- call descriptive flexfield validation routines
  --
/*
  IF hr_general.get_calling_context <>'FORMS' THEN
    per_rtl_flex.df(p_rec => p_rec);
  END IF;
*/
  --
  per_rtl_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_rtl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check if rating level exists in competence element
  --
  per_rtl_bus.chk_rating_level_in_ele
  (p_rating_level_id		=> p_rec.rating_level_id
  ,p_object_version_number	=> p_rec.object_version_number
  );
  --
  -- check other tables
  --
  per_rtl_bus.chk_rating_level_add_del
  (p_rating_level_id		=> p_rec.rating_level_id
  ,p_object_version_number	=> p_rec.object_version_number
  ,p_competence_id		=> per_rtl_shd.g_old_rec.competence_id
  ,p_rating_scale_id		=> per_rtl_shd.g_old_rec.rating_scale_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
         (  p_rating_level_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups pbg,
                 per_rating_levels   prl
          where  prl.rating_level_id   = p_rating_level_id
            and  pbg.business_group_id = prl.business_group_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
   l_business_group_flag varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  -- ngundura changes for pa requirement
  select 'Y' into l_business_group_flag
  from per_rating_levels
  where rating_level_id = p_rating_level_id
    and business_group_id is null;

  if l_business_group_flag = 'Y' then
      return null;
  end if;
  -- ngundura end of changes.
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'rating_level_id',
                              p_argument_value => p_rating_level_id );
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;
     --
     -- The primary key is invalid therefore we must error out
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End return_legislation_code;
--
--
end per_rtl_bus;

/
