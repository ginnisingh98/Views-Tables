--------------------------------------------------------
--  DDL for Package Body PER_CPN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CPN_BUS" as
/* $Header: pecpnrhi.pkb 120.0 2005/05/31 07:14:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_cpn_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code         varchar2(150) default null;
g_competence_id          number        default null;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_non_updateable_args(p_rec in per_cpn_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_cpn_shd.api_updating
                (p_competence_id            => p_rec.competence_id
                ,p_object_version_number    => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if p_rec.business_group_id <> per_cpn_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);

  if per_cpn_shd.g_old_rec.competence_cluster = 'UNIT_STANDARD'
     and (p_rec.competence_cluster is NULL
          or p_rec.competence_cluster <> 'UNIT_STANDARD') then
     --
     fnd_message.set_name('PER','HR_449146_QUA_FWK_CHG_CLUSTER');
     fnd_message.raise_error;
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
--
-------------------------------------------------------------------------------
----------------------< chk_definition_id >------------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that a valid competence name is entered
--
--   - Validates that it is unique within the business group
--
--  Pre_conditions:
--    A valid business_group_id
--
--
--  In Arguments:
--    p_business_group_id
--    p_name
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	- name is invalid
--      - The business group is invalid
--	- name is not unique within business group
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
--
procedure chk_definition_id
(p_competence_id	     in	     per_competences.competence_id%TYPE
,p_business_group_id	     in      per_competences.business_group_id%TYPE
,p_competence_definition_id  in      per_competences.competence_definition_id%TYPE
,p_object_version_number     in      per_competences.object_version_number%TYPE
)
is
--
	l_exists             per_competences.business_group_id%TYPE;
	l_api_updating	     boolean;
  	l_proc               varchar2(72)  :=  g_package||'chk_definition_id';
	--
	-- Cursor to check if competence_definition_id is unique within business group
        --
	cursor csr_chk_definition_id is
	  select business_group_id
 	  from per_competences pc
	  where (( p_competence_id is null)
	        or (p_competence_id <> pc.competence_id)
		)
	  and competence_definition_id = p_competence_definition_id
	  and p_business_group_id is null
	  UNION
	  select business_group_id
	  from   per_competences pc
	  where  (   (p_competence_id is null)
		   or(p_competence_id <> pc.competence_id)
		 )
	  and competence_definition_id = p_competence_definition_id
          and   p_business_group_id is not null
	  and   ( business_group_id + 0  = p_business_group_id or
                  business_group_id is null);
	--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for name has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id	   => p_competence_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (  (l_api_updating and (per_cpn_shd.g_old_rec.competence_definition_id
		        <> nvl(p_competence_definition_id,hr_api.g_number))
         ) or
        (NOT l_api_updating)
      ) then
     --
     -- hr_utility.set_loc --
     -- check if the user has entered a name, as name is
     -- is mandatory column.
     --
     if p_competence_definition_id is null then
       hr_utility.set_message(801,'HR_51441_COMP_NAME_MANDATORY');
       hr_utility.raise_error;
     end if;

     --
     -- check if name is unique
     --
     open csr_chk_definition_id;
     fetch csr_chk_definition_id into l_exists;
     if csr_chk_definition_id%found then
       hr_utility.set_location(l_proc, 3);
       -- name is not unique
       close csr_chk_definition_id;
       if l_exists is null then
	  fnd_message.set_name('PER','HR_52698_COMP_NAME_IN_GLOB');
          fnd_message.raise_error;
       else
          fnd_message.set_name('PER','HR_52699_COMP_NAME_IN_BUSGRP');
          fnd_message.raise_error;
       end if;
     end if;
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 10);
end chk_definition_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_competence_dates >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--    Perform check to make sure that :
--	- Validates that the start date of the competence is entered
--      - Validates that end date is later or equal to start date
--      -
--	- if called from update mode then
--	  make sure that the competence start date and end date do not invalidate
--        competence element ie. competence start date has to be less than or equal
--        to competence element start date and competence end date has to be greater
--	  than or equal to competence element end date
--
-- Pre-requisites
--   valid competence name
--   valid business group id
--
-- In Prameters
--   p_date_from
--   p_date_to
--   p_competence_id
--   p_called_from
--
-- Post Success
--   Processing continues.
--
-- Post Failure
-- An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - date_from is not set
--	- date_to is not later than date_from
--
-- Access Status
--  Internal Development Use Only
--
Procedure chk_competence_dates
  (p_date_from		in per_competences.date_from%TYPE
  ,p_date_to		in per_competences.date_to%TYPE
  ,p_competence_id	in per_competences.competence_id%TYPE default null
  ,p_called_from	in varchar2 default null
  ) is
--
  l_exists             	varchar2(1);
  l_proc        	varchar2(72):=g_package||'chk_competence_dates';

  -- bug fix 4132284.
  -- Condition to check the date to of competence elements is relaxed to only
  -- whether the from date of the competence element is later than the new
  -- competence end date.

	Cursor csr_check_dates_in_ele is
    	select 	'Y'
    	from   	per_competence_elements cpe
    	where	(   nvl(cpe.effective_date_from,hr_api.g_sot) <
		    nvl(p_date_from, nvl(cpe.effective_date_from,hr_api.g_sot))
   		 or nvl(cpe.effective_date_from,hr_api.g_sot) >
		    nvl(p_date_to, nvl(cpe.effective_date_from,hr_api.g_sot))
		)
    	and	cpe.competence_id = p_competence_id
--adhunter reinstated the following check for 2533926
        and     cpe.type not in
                ('COMPETENCE_USAGE');
-- ngundura commented the below line for extensible competence requirements
--    	and 	cpe.type in
--		('PREREQUISITE','PERSONAL','DELIVERY','PROPOSAL','ASSESSMENT','REQUIREMENT');
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
--
    if (p_date_from is NULL) then
      --
      hr_utility.set_message(801, 'HR_51598_CPN_DATE_FROM_NULL');
      hr_utility.raise_error;
      --
    end if;
    --
    --  The date from has to be >= the date to, else error.
    --
    if (p_date_from > nvl(p_date_to,hr_api.g_eot)) then
      --
      hr_utility.set_message(801, 'HR_51599_CPN_DATE_TO_LATER');
      hr_utility.raise_error;
      --
    end if;
    --
   -- only continue if called from UPDATE check
   --
   -- Apart from having the standard date validation check ie.date from <= date_to
   -- and date_to >= date_from, need to make sure that the user cannot change a date
   -- so as to invalidate the dates on the competence element.
   -- Check dates againts competence elements (only in Update mode)
   --
   if p_called_from = 'UPDATE'

and (        p_date_from <> per_cpn_shd.g_old_rec.date_from
     or  nvl(p_date_to,hr_api.g_date)<>nvl(per_cpn_shd.g_old_rec.date_to,hr_api.g_date)
    ) then

     open csr_check_dates_in_ele;
     fetch csr_check_dates_in_ele into l_exists;
     if csr_check_dates_in_ele%found then
       hr_utility.set_location(l_proc, 3);
       -- dates out of range
       close csr_check_dates_in_ele ;
       hr_utility.set_message(801,'HR_51809_CPN_INVALIDATE_ELE');
       hr_utility.raise_error;
     end if;
     close csr_check_dates_in_ele;
   end if;
 hr_utility.set_location('Leaving:'|| l_proc, 10);
--
end chk_competence_dates;
-------------------------------------------------------------------------------
--------------------------<chk_certification_required>-------------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that a valid certification required flag is set
--
--   - Validates that it is exists as lookup code for that type
--
--  Pre_conditions:
--    A valid competence name
--    A valid business_group_id
--
--
--  In Arguments:
--    p_competence_id
--    p_certification_required
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - certification flag is not set or is invalid
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
--
procedure chk_certification_required
(p_competence_id             in      per_competences.competence_id%TYPE
,p_object_version_number     in      per_competences.object_version_number%TYPE
,p_certification_required    in      per_competences.certification_required%TYPE
,p_effective_date            in      date
)
is
--
        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_certification_required';

        --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for certification required flag has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.certification_required,
                                hr_api.g_varchar2)
                        <> nvl(p_certification_required,hr_api.g_varchar2)
         ) or
        (NOT l_api_updating)
      ) then
     --
     hr_utility.set_location(l_proc, 2);
     --
     --
     -- If certification required is not null then
     -- check if the value exists in hr_lookups
     -- where the lookup_type = 'YES_NO'
     --
     --
     if p_certification_required is not null then
       if hr_api.not_exists_in_hr_lookups
            (p_effective_date   => p_effective_date
            ,p_lookup_type      => 'YES_NO'
            ,p_lookup_code      => p_certification_required
            ) then
            -- error invalid certification flag
          hr_utility.set_message(801,'HR_51432_COMP_CERTIFY_FLAG');
          hr_utility.raise_error;
       end if;
       hr_utility.set_location(l_proc, 3);
     end if;
  end if;
 hr_utility.set_location('Leaving: '|| l_proc, 10);
end chk_certification_required;
--
-------------------------------------------------------------------------------
--------------------------<chk_evaluation_method>------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that a valid evaluation method is set
--
--   - Validates that it is exists as lookup code for that type
--
--  Pre_conditions:
--    A valid competence name
--    A valid business_group_id
--
--
--  In Arguments:
--    p_competence_id
--    p_evaluation_method
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - evaluation method is invalid
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_evaluation_method
(p_competence_id             in      per_competences.competence_id%TYPE
,p_object_version_number     in      per_competences.object_version_number%TYPE
,p_evaluation_method         in      per_competences.evaluation_method%TYPE
,p_effective_date            in      date
,p_business_group_id         in      per_competences.business_group_id%TYPE default null
)
is
--
        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_evaluation_method';

        --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for evaluation method has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.evaluation_method,
                                hr_api.g_varchar2)
                        <> nvl(p_evaluation_method,hr_api.g_varchar2)
         ) or
        (NOT l_api_updating)
      ) then
     --
     hr_utility.set_location(l_proc, 2);
     --
     --
     -- If evaluation method is not null then
     -- check if the value exists in hr_lookups
     -- where the lookup_type = COMPETENCE_EVAL_TYPE
     --
     -- ngundura changes for pa requirements.
     --
     if p_evaluation_method is not null then
       if p_business_group_id is null then
          if hr_api.not_exists_in_hrstanlookups
	    (p_effective_date   => p_effective_date
            ,p_lookup_type      => 'COMPETENCE_EVAL_TYPE'
            ,p_lookup_code      => p_evaluation_method
            ) then
	    hr_utility.set_message(801,'HR_51433_COMP_EVAL_METHOD');
	    hr_utility.raise_error;
          end if;
       else
          if hr_api.not_exists_in_hr_lookups
            (p_effective_date   => p_effective_date
            ,p_lookup_type      => 'COMPETENCE_EVAL_TYPE'
            ,p_lookup_code      => p_evaluation_method
            ) then
            -- error invalid evaluation method
           hr_utility.set_message(801,'HR_51433_COMP_EVAL_METHOD');
           hr_utility.raise_error;
          end if;
       end if;
     -- ngundura end of the changes.
       hr_utility.set_location(l_proc, 3);
     end if;
  end if;
  hr_utility.set_location('Leaving: '|| l_proc, 10);
end chk_evaluation_method;
--
-------------------------------------------------------------------------------
--------------------------<chk_renewal_period_units>---------------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that a valid renewal period unit is set
--
--   - Validates that it is exists as lookup code for that type
--
--  Pre_conditions:
--    A valid competence name
--    A valid business_group_id
--
--
--  In Arguments:
--    p_competence_id
--    p_renewal_period_units
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - renewal period unit is invalid
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_renewal_period_units
(p_competence_id             in      per_competences.competence_id%TYPE
,p_object_version_number     in      per_competences.object_version_number%TYPE
,p_renewal_period_units      in      per_competences.renewal_period_units%TYPE
,p_effective_date            in      date
)
is
--
        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_renewal_period_units';

        --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for renewal period units has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.renewal_period_units,
                                hr_api.g_varchar2)
                        <> nvl(p_renewal_period_units,hr_api.g_varchar2)
         ) or
        (NOT l_api_updating)
      ) then
     --
     hr_utility.set_location(l_proc, 2);
     --
     --
     -- If renewal_period_units is not null then
     -- check if the value exists in hr_lookups
     -- where the lookup_type = 'UNITS'
     --
     --Modified by PASHUN on 28/08/97
     --If renewal_period_units is not null then
     --check if the value exists in hr_lookups
     --where the lookup_type = 'FREQUENCY'
     --
     --
    if p_renewal_period_units is not null then
      -- if hr_api.not_exists_in_hr_lookups
           -- (p_effective_date   => p_effective_date
           -- ,p_lookup_type      => 'UNITS'
           -- ,p_lookup_code      => p_renewal_period_units
           -- ) then
            -- error invalid period units
       if hr_api.not_exists_in_hr_lookups
            (p_effective_date   => p_effective_date
            ,p_lookup_type      => 'FREQUENCY'
            ,p_lookup_code      => p_renewal_period_units
            ) then
            -- error invalid period frequency units
          hr_utility.set_message(801,'HR_51434_COMP_RENEW_UNIT');
          hr_utility.raise_error;
       end if;
       hr_utility.set_location(l_proc, 3);
     end if;
  end if;
  hr_utility.set_location('Leaving: '|| l_proc, 10);
end chk_renewal_period_units;
--
-------------------------------------------------------------------------------
--------------------------<chk_renewable_unit_frequency>-----------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that either both renewal period frequency and renewable
--     period unit fields are set, otherwise none of them.
--
--
--  Pre_conditions:
--    A valid competence
--
--
--  In Arguments:
--    p_competence_id
--    p_renewal_period_units
--    p_renewal_period_frequency
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - either of the two fields are null and the other not null
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_renewable_unit_frequency
(p_competence_id             in      per_competences.competence_id%TYPE
,p_object_version_number     in      per_competences.object_version_number%TYPE
,p_renewal_period_units      in      per_competences.renewal_period_units%TYPE
,p_renewal_period_frequency  in	     per_competences.renewal_period_frequency%TYPE
)
is
--
        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_renewable_unit_frequency';

        --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for renewal period units or renewal period frquency has
  --    changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if   (l_api_updating
      and
       ((nvl(per_cpn_shd.g_old_rec.renewal_period_units,
                                hr_api.g_varchar2)
                        <> nvl(p_renewal_period_units,hr_api.g_varchar2))
          or
	(nvl(per_cpn_shd.g_old_rec.renewal_period_frequency,
				hr_api.g_number)
			<> nvl(p_renewal_period_frequency,hr_api.g_number))))
      or
       NOT l_api_updating then
     --
     hr_utility.set_location(l_proc, 2);
     --
     -- Only check for a valid combination when either of the fields
     -- are set
     --
     if ((p_renewal_period_units is null and
          p_renewal_period_frequency is not null
         ) or
         (p_renewal_period_units is not null and
         p_renewal_period_frequency is null)
        ) then
        -- raise error
          hr_utility.set_message(801,'HR_51435_COMP_DEPENDENT_FIELDS');
          hr_utility.raise_error;
     end if;
       hr_utility.set_location(l_proc, 3);
  end if;
  hr_utility.set_location('Leaving: '|| l_proc, 10);
end chk_renewable_unit_frequency;
--
-----------------------------------------------------------------------------
------------------------<chk_rat_scale_bus_grp_exist>--------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the rating scale exists and is within the same business
--     group as that of competence
--
--  Pre_conditions:
--
--
--  In Arguments:
--    p_rating_scale_id
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - rating scale does not exist
--      -- rating sacle exists but not with the same business group
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_rat_scale_bus_grp_exist
(p_competence_id             in      per_competences.competence_id%TYPE
,p_object_version_number     in      per_competences.object_version_number%TYPE
,p_rating_scale_id	     in      per_rating_scales.rating_scale_id%TYPE
,p_business_group_id	     in	     per_competences.business_group_id%TYPE default null
)
is
--
	l_exists	     varchar2(1);
        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_rat_scale_bus_grp_exist';
        l_business_group_id  per_rating_scales.business_group_id%TYPE;
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
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for rating scale has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.rating_scale_id,
                                hr_api.g_number)
                        <> nvl(p_rating_scale_id,hr_api.g_number)
         ) or
        (NOT l_api_updating)
      ) then
     --
     hr_utility.set_location(l_proc, 2);
     --
     if p_rating_scale_id is not null then
        open csr_rat_scale_bus_grp_exist;
        fetch csr_rat_scale_bus_grp_exist into l_business_group_id;
	if csr_rat_scale_bus_grp_exist%notfound then
            close csr_rat_scale_bus_grp_exist;
            hr_utility.set_message(801,'HR_51452_COMP_RAT_SC_NOT_EXIST');
            hr_utility.raise_error;
	end if;
        close csr_rat_scale_bus_grp_exist;
	-- check if rating sacel is in the same business group
 -- ngundura changes done for pa requirements.
        if p_business_group_id is null then
	       if l_business_group_id is not null then
                     hr_utility.set_message(801,'HR_51453_COMP_DIFF_BUS_GRP');
		     hr_utility.raise_error;
	       end if;
	else
               if nvl(l_business_group_id,hr_api.g_number) <> p_business_group_id and l_business_group_id is not null then
	            hr_utility.set_message(801,'HR_51453_COMP_DIFF_BUS_GRP');
	            hr_utility.raise_error;
               end if;
	end if;
        --
     end if;
     hr_utility.set_location(l_proc, 3);
  end if;
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
end chk_rat_scale_bus_grp_exist;
-----------------------------------------------------------------------------
------------------------<chk_rating_scale_type>------------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that only rating scale of type 'PROFICIENCY' is allowed
--     to be assigned to a competence
--
--  Pre_conditions:
--    A valid competence name
--    A valid business_group_id
--
--
--  In Arguments:
--    p_competence_id
--    p_rating_scale_id
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - rating scale is not of type 'Proficiency'
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_rating_scale_type
(p_competence_id             in      per_competences.competence_id%TYPE
,p_object_version_number     in      per_competences.object_version_number%TYPE
,p_rating_scale_id	     in      per_rating_scales.rating_scale_id%TYPE
)
is
--
	l_exists	     varchar2(1);
        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_rating_scale_type';
--
	--
	-- Cursor to check if rating scale is of type 'Proficiency'
	--
	Cursor csr_chk_rating_scale_type
          is
	select 'Y'
	from	per_rating_scales
	where   rating_scale_id = p_rating_scale_id
	and	upper(type)		= 'PROFICIENCY';
	--
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for rating scale has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.rating_scale_id,
                                hr_api.g_number)
                        <> nvl(p_rating_scale_id,hr_api.g_number)
         ) or
        (NOT l_api_updating)
      ) then
     --
     hr_utility.set_location(l_proc, 2);
     --
     if p_rating_scale_id is not null then
        open csr_chk_rating_scale_type;
        fetch csr_chk_rating_scale_type into l_exists;
	  if csr_chk_rating_scale_type%notfound then
            close csr_chk_rating_scale_type;
            hr_utility.set_message(801,'HR_51442_COMP_TYPE_NOT_PROF');
            hr_utility.raise_error;
	  end if;
	 close csr_chk_rating_scale_type;
     end if;
     hr_utility.set_location(l_proc, 3);
  end if;
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
end chk_rating_scale_type;
--
-----------------------------------------------------------------------------
------------------------<chk_competence_has_prof>----------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - checks if competence has proficiency levels. If yes than
--     cannot assign a rating scale to this competence
--
--  Pre_conditions:
--    A valid competence
--    A valid business_group_id
--
--
--  In Arguments:
--    p_competence_id
--    p_rating_scale_id
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - competence has proficiency levels
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_competence_has_prof
(p_competence_id             in      per_competences.competence_id%TYPE
,p_object_version_number     in      per_competences.object_version_number%TYPE
,p_rating_scale_id	     in      per_rating_scales.rating_scale_id%TYPE
)
is
--
	l_exists             varchar2(1);
        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_competence_has_prof';
--
     --
     -- Cursor to check if competence has Proficiency levels
     --
     cursor csr_comp_has_prof_levels is
      select    'Y'
      from      per_rating_levels
      where     competence_id     = p_competence_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for rating scale has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.rating_scale_id,
                                hr_api.g_number)
                        <> nvl(p_rating_scale_id,hr_api.g_number)
         ) or
        (NOT l_api_updating)
      ) then
     --
     hr_utility.set_location(l_proc, 2);
     --
     if p_rating_scale_id is not null then
        open csr_comp_has_prof_levels;
        fetch csr_comp_has_prof_levels into l_exists;
	  if csr_comp_has_prof_levels%found then
            close csr_comp_has_prof_levels;
            hr_utility.set_message(801,'HR_51437_COMP_PROF_SCALE');
            hr_utility.raise_error;
	  end if;
	 close csr_comp_has_prof_levels;
     end if;
     hr_utility.set_location(l_proc, 3);
  end if;
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
end chk_competence_has_prof;
-------------------------------------------------------------------------------
--------------------------<chk_competence_rating_update>-----------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that a rating scale on competence can only be updated
--     if the proficeincy rating levels for that rating scale are not used in
--     competence element
--
--  Pre_conditions:
--    A valid competence_id
--    A valid business_group_id
--
--
--  In Arguments:
--    p_competence_id
--    p_rating_scale_id
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - the rating scale has rating levels that are used in competence
--        element
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_competence_rating_update
(p_competence_id             in      per_competences.competence_id%TYPE
,p_object_version_number     in      per_competences.object_version_number%TYPE
,p_rating_scale_id	     in      per_competences.rating_scale_id%TYPE
)
is
--
	l_exists	     varchar2(1);
        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_competence_rating_update';
     --
     --
     -- Cursor to check if rating level is used within a competence element
     --
     -- change made to fix bug 569647 (added competence_id)
     --
    cursor csr_rating_level_in_ele is
      select    'Y'
      from      per_rating_levels rl,
                per_competence_elements ce
      where     ((rl.rating_level_id = ce.proficiency_level_id) or
		 (rl.rating_level_id = ce.high_proficiency_level_id))
      and       rl.rating_scale_id   = nvl(per_cpn_shd.g_old_rec.rating_scale_id,-9999)
      and 	ce.competence_id = p_competence_id;
      --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for rating scale has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.rating_scale_id,
                                hr_api.g_number)
                        <> nvl(p_rating_scale_id,hr_api.g_number)
         ) or
        (NOT l_api_updating)
      ) then
     --
     hr_utility.set_location(l_proc, 2);
     --
     open csr_rating_level_in_ele;
     fetch csr_rating_level_in_ele into l_exists;
     if csr_rating_level_in_ele%found then
       close csr_rating_level_in_ele;
       hr_utility.set_message(801,'HR_51443_COMP_LEVELS_IN_ELE');
       hr_utility.raise_error;
       hr_utility.set_location(l_proc, 2);
     else
      close csr_rating_level_in_ele;
     end if;
     --
       hr_utility.set_location(l_proc, 3);
     --
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 10);
  --
end chk_competence_rating_update;
--
-------------------------------------------------------------------------------
--------------------------<chk_competence_delete>-------------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that a competence cannot be deleted if used in:
--	a) Competence element
--
--      b) Proficiency level      - this should have been deleted by BP
--      c) Competence Type Usages - this should have been deleted by BP
--
--         If the rows from the proficiency level and Competence Type Usages
-- 	   still exists while deleting the competence then it will error.
--
--  Pre_conditions:
--    A valid competence id
--
--
--  In Arguments:
--    p_competence_id
--    p_object_version_number
--
--  Post Success:
--    Process continues if:
--    competnece is not referenced
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - competence id is invalid
--      - competence exists in competence elements and proficiency levels
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_competence_delete
(p_competence_id             in      per_competences.competence_id%TYPE
,p_object_version_number     in      per_competences.object_version_number%TYPE
)
is
--
 	 l_exists  varchar2(1);
         l_proc    varchar2(72)  :=  g_package||'chk_competence_delete';
    --
    -- Cursor to check if competence is used in per_competence_elements
    --
    cursor csr_chk_comp_exists_in_ele is
     select 'Y'
     from   per_competence_elements
     where  competence_id     = p_competence_id;
    --
    -- Cursor to check if competence is used in per_rating_levels
    --
    cursor csr_chk_comp_exists_in_rl is
     select 'Y'
     from   per_rating_levels
     where  competence_id     = p_competence_id;
    --
    -- Cursor to check if competence is used in per_competende_outcomes
    --
    cursor csr_chk_comp_exists_in_co is
     select 'Y'
     from   per_competence_outcomes
     where  competence_id     = p_competence_id;
    --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'competence_id'
    ,p_argument_value => p_competence_id
    );
  --
  open csr_chk_comp_exists_in_ele;
  fetch csr_chk_comp_exists_in_ele into l_exists;
  if csr_chk_comp_exists_in_ele%found then
     close csr_chk_comp_exists_in_ele;
     hr_utility.set_message(801,'HR_51440_COMP_EXIST_IN_ELE');
     hr_utility.raise_error;
     hr_utility.set_location(l_proc, 2);
  else
     close csr_chk_comp_exists_in_ele;
     open csr_chk_comp_exists_in_rl;
     fetch csr_chk_comp_exists_in_rl into l_exists;
     if csr_chk_comp_exists_in_rl%found then
        close csr_chk_comp_exists_in_rl;
        hr_utility.set_message(801,'HR_51439_COMP_PROF_LVL_EXIST');
        hr_utility.raise_error;
        hr_utility.set_location(l_proc, 3);
     end if;
     close csr_chk_comp_exists_in_rl;
     open csr_chk_comp_exists_in_co;
     fetch csr_chk_comp_exists_in_co into l_exists;
     if csr_chk_comp_exists_in_co%found then
       close csr_chk_comp_exists_in_co;
       hr_utility.set_message(800,'HR_449134_QUA_FWK_COMP_TAB_REF');
       hr_utility.raise_error;
       hr_utility.set_location(l_proc, 4);
     end if;
     close csr_chk_comp_exists_in_co;
  end if;
 --
 hr_utility.set_location('Leaving: '|| l_proc, 10);
 --
end chk_competence_delete;
--
-- -----------------------------------------------------------------------------
-- |-------------------------<chk_set_radio_button>---------------------------|
-- -----------------------------------------------------------------------------
-- Description:
--  Checks if the competence has a prficiency rating scale, if yes
--  returns 'PS' (Proficiency Scale exists).
--  Checks if the competence has levels, if yes returns
-- 'CL' (Competence Levels exists)
--  Else it will return 'PS' as default.
--
--  This function is called by the Competence Base View (too) to set the
--  value of a radio group in the form accordingly.
--
--  In Arguments:
--    p_competence_id
--    p_rating_scale_id
--
--  Access Status
--    Internal Table Handler Use Only.
--
Function chk_set_radio_button (p_competence_id	in number,
		     	      p_rating_scale_id	in number)
Return   varchar2 is
--
-- check if the proficiency rating scale has any
-- levels
--
cursor c_competence_levels is
 select	1
 from	per_rating_levels
 where	competence_id = p_competence_id;
--
-- variables
--
l_levels_exists number;
l_proc varchar2(72) := g_package||'chk_comp_levels_func';
--
-- 'PS' - stands for Proficiency Scale
-- 'CL' - stands for Competence Levels
--
Begin
 if p_rating_scale_id is not null then
    Return ('PS');
 end if;
 -- check if levels exist for competence
 open  c_competence_levels;
 fetch c_competence_levels into l_levels_exists;
 close c_competence_levels;
 if l_levels_exists is not null then
   Return ('CL');
 else
   Return ('PS');
 end if;
 --
End chk_set_radio_button;
--
-------------------------------------------------------------------------------
--------------------------<chk_competence_cluster>------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a competence_cluster exists in HR_LOOKUPS
--     for the lookup type 'PER_COMPETENCE_CLUSTER'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_competence_id
--    p_competence_cluster
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_competence_cluster
(p_competence_id             in     per_competences.competence_id%TYPE
,p_competence_cluster        in     per_competences.competence_cluster%TYPE
,p_object_version_number     in     per_competences.object_version_number%TYPE
,p_effective_date	     in     date
)
is
--
        l_proc            varchar2(72)  :=  g_package||'chk_competence_cluster';
        l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for cluster name has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if (p_competence_cluster is not NULL) then
    if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.competence_cluster,
                                hr_api.g_varchar2)
                        <> nvl(p_competence_cluster,hr_api.g_varchar2)
         ) or
        (NOT l_api_updating)
      ) then
      --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_COMPETENCE_CLUSTER'
        ,p_lookup_code           => p_competence_cluster) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449088_COMPETENCE_CLSTR_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_competence_cluster;
--
-------------------------------------------------------------------------------
--------------------------<chk_unit_standard_id>------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a unit_standard_id is unique
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_competence_id
--    p_unit_standard_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_unit_standard_id
(p_competence_id             in     per_competences.competence_id%TYPE
,p_unit_standard_id          in     per_competences.unit_standard_id%TYPE
,p_business_group_id         in     per_competences.business_group_id%TYPE
,p_object_version_number     in     per_competences.object_version_number%TYPE
,p_effective_date	     in     date
)
is
--
  --
  -- declare cursor
  --
   cursor csr_local_unit_standard_id is
      select 1 from per_competences
      where unit_standard_id = p_unit_standard_id
      and   business_group_id = p_business_group_id
      and   p_effective_date between date_from and NVL(date_to, hr_api.g_eot);
   --
   cursor csr_global_unit_standard_id is
      select 1 from per_competences
      where unit_standard_id = p_unit_standard_id
      and   p_effective_date between date_from and NVL(date_to, hr_api.g_eot);

        l_proc            varchar2(72)  :=  g_package||'chk_unit_standard_id';
        l_api_updating    boolean;
        l_exists          varchar2(1);
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for unit_standard_id has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if (p_unit_standard_id is not NULL) then
    if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.unit_standard_id,
                                hr_api.g_varchar2)
                        <> nvl(p_unit_standard_id,hr_api.g_varchar2)
         ) or
        (NOT l_api_updating)
      ) then
      --
       if p_business_group_id is not NULL then
         hr_utility.set_location(l_proc, 20);
         --
         -- Local competence
         --
         open csr_local_unit_standard_id;
         fetch csr_local_unit_standard_id into l_exists;
         if csr_local_unit_standard_id%FOUND then
           close csr_local_unit_standard_id;
           --
           hr_utility.set_location(l_proc, 30);
           --
           hr_utility.set_message(800, 'HR_449089_UNIT_STD_ID_EXISTS');
           hr_utility.raise_error;
           --
         END IF;
         close csr_local_unit_standard_id;
       else
         hr_utility.set_location(l_proc, 40);
         --
         -- Global competence
         --
         open csr_global_unit_standard_id;
         fetch csr_global_unit_standard_id into l_exists;
         if csr_global_unit_standard_id%FOUND then
           close csr_global_unit_standard_id;
           --
           hr_utility.set_location(l_proc, 50);
           --
           hr_utility.set_message(800, 'HR_449089_UNIT_STD_ID_EXISTS');
           hr_utility.raise_error;
           --
         END IF;
         close csr_global_unit_standard_id;
       end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 60);
  --
end chk_unit_standard_id;
--
-------------------------------------------------------------------------------
----------------------------< chk_credit_type >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a credit_type exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_CREDIT_TYPE'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_competence_id
--    p_credit_type
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_credit_type
(p_competence_id             in     per_competences.competence_id%TYPE
,p_credit_type               in     per_competences.credit_type%TYPE
,p_object_version_number     in     per_competences.object_version_number%TYPE
,p_effective_date	     in     date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_credit_type';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for credit type has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_credit_type is not null then
      if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.credit_type,
                                  hr_api.g_varchar2)
                          <> nvl(p_credit_type,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_CREDIT_TYPE'
        ,p_lookup_code           => p_credit_type) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449092_QUA_FWK_CRDT_TYP_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_credit_type;
--
--
-------------------------------------------------------------------------------
----------------------------< chk_level_type >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a level_type exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_LEVEL_TYPE'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_competence_id
--    p_level_type
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_level_type
(p_competence_id             in     per_competences.competence_id%TYPE
,p_level_type                in     per_competences.credit_type%TYPE
,p_object_version_number     in     per_competences.object_version_number%TYPE
,p_effective_date	     in     date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_level_type';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for level type has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_level_type is not null then
    if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.level_type,
                                  hr_api.g_varchar2)
                          <> nvl(p_level_type,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_LEVEL_TYPE'
        ,p_lookup_code           => p_level_type) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449090_QUA_FWK_LVL_TYP_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_level_type;
--
--
-------------------------------------------------------------------------------
----------------------------< chk_level_number >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a level_number exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_LEVEL'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_competence_id
--    p_level_number
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_level_number
(p_competence_id             in     per_competences.competence_id%TYPE
,p_level_number              in     per_competences.level_number%TYPE
,p_object_version_number     in     per_competences.object_version_number%TYPE
,p_effective_date	     in     date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_level_number';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for level has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_level_number is not null then
    if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.level_number,
                                  hr_api.g_number)
                          <> nvl(p_level_number,hr_api.g_number)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_LEVEL'
        ,p_lookup_code           => p_level_number) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449091_QUA_FWK_LEVEL_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_level_number;
--
--
-------------------------------------------------------------------------------
----------------------------------< chk_field >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a field exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_FIELD'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_competence_id
--    p_field
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_field
(p_competence_id             in     per_competences.competence_id%TYPE
,p_field                     in     per_competences.field%TYPE
,p_object_version_number     in     per_competences.object_version_number%TYPE
,p_effective_date	     in     date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_field';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for field has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_field is not null then
    if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.field,
                                  hr_api.g_varchar2)
                          <> nvl(p_field,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_FIELD'
        ,p_lookup_code           => p_field) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449093_QUA_FWK_FIELD_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_field;
--
--
-------------------------------------------------------------------------------
----------------------------< chk_sub_field >----------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a sub_field exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_SUB_FIELD'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_competence_id
--    p_sub_field
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_sub_field
(p_competence_id             in     per_competences.competence_id%TYPE
,p_sub_field                 in     per_competences.sub_field%TYPE
,p_object_version_number     in     per_competences.object_version_number%TYPE
,p_effective_date	     in     date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_sub_field';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for sub field has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_sub_field is not null then
    if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.sub_field,
                                  hr_api.g_varchar2)
                          <> nvl(p_sub_field,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_SUB_FIELD'
        ,p_lookup_code           => p_sub_field) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449094_QUA_FWK_SUB_FLD_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_sub_field;
--
--
-------------------------------------------------------------------------------
-------------------------------< chk_provider >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a provider exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_PROVIDER'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_competence_id
--    p_provider
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_provider
(p_competence_id             in     per_competences.competence_id%TYPE
,p_provider                  in     per_competences.provider%TYPE
,p_object_version_number     in     per_competences.object_version_number%TYPE
,p_effective_date	     in     date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_provider';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for provider has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_provider is not null then
    if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.provider,
                                  hr_api.g_varchar2)
                          <> nvl(p_provider,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_PROVIDER'
        ,p_lookup_code           => p_provider) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449095_QUA_FWK_PROVIDER_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_provider;
--
--
-------------------------------------------------------------------------------
------------------------< chk_qa_organization >--------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--     This procedure checks that a qa_organization exists in HR_LOOKUPS
--     for the lookup type 'PER_QUAL_FWK_QA_ORG'.
--
--  Pre_conditions:
--    None.
--
--  In Arguments:
--    p_competence_id
--    p_qa_organization
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    Error raised.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_qa_organization
(p_competence_id             in     per_competences.competence_id%TYPE
,p_qa_organization           in     per_competences.qa_organization%TYPE
,p_object_version_number     in     per_competences.object_version_number%TYPE
,p_effective_date	     in     date
)
is
--
     l_proc            varchar2(72)  :=  g_package||'chk_qa_organization';
     l_api_updating    boolean;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for qa organization has changed
  --
  l_api_updating := per_cpn_shd.api_updating
         (p_competence_id          => p_competence_id
         ,p_object_version_number  => p_object_version_number);
 --
  if p_qa_organization is not null then
    if (  (l_api_updating and nvl(per_cpn_shd.g_old_rec.qa_organization,
                                  hr_api.g_varchar2)
                          <> nvl(p_qa_organization,hr_api.g_varchar2)
           ) or
          (NOT l_api_updating)
        ) then
       --
       hr_utility.set_location(l_proc, 20);
       --
       -- Check that the category exists in HR_LOOKUPS
       --
       IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'PER_QUAL_FWK_QA_ORG'
        ,p_lookup_code           => p_qa_organization) THEN
        --
         hr_utility.set_location(l_proc, 30);
         --
         hr_utility.set_message(800, 'HR_449096_QUA_FWK_QA_ORG_LKP');
         hr_utility.raise_error;
         --
       END IF;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);
  --
end chk_qa_organization;
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
  (p_rec in per_cpn_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if (((p_rec.competence_id is not null) and (
    nvl(per_cpn_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_cpn_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    p_rec.competence_id is null)
    and hr_competences_api.g_ignore_df <> 'Y' then -- BUG3621261
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_COMPETENCES'
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
      ,p_attribute20_value  => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);

end chk_df;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in per_cpn_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if (((p_rec.competence_id is not null)  and (
    nvl(per_cpn_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_cpn_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) ))
    or (p_rec.competence_id is null))
    and hr_competences_api.g_ignore_df <> 'Y'  then -- BUG3621261
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Competence Developer DF'
      ,p_attribute_category              => p_rec.INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION13'
      ,p_attribute12_value               => p_rec.information13
      ,p_attribute13_name                => 'INFORMATION14'
      ,p_attribute13_value               => p_rec.information14
      ,p_attribute14_name                => 'INFORMATION15'
      ,p_attribute14_value               => p_rec.information15
      ,p_attribute15_name                => 'INFORMATION16'
      ,p_attribute15_value               => p_rec.information16
      ,p_attribute16_name                => 'INFORMATION17'
      ,p_attribute16_value               => p_rec.information17
      ,p_attribute17_name                => 'INFORMATION18'
      ,p_attribute17_value               => p_rec.information18
      ,p_attribute18_name                => 'INFORMATION19'
      ,p_attribute18_value               => p_rec.information19
      ,p_attribute19_name                => 'INFORMATION20'
      ,p_attribute19_value               => p_rec.information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
-- ---------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ---------------------------------------------------------------------------
--
Procedure insert_validate(p_rec in per_cpn_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Rule Check Business group is valid
  -- ngundura changes for pa requirements
  if p_rec.business_group_id is not null then
       hr_api.validate_bus_grp_id(p_rec.business_group_id);
  end if;
  -- ngundura end of changes.
  hr_utility.set_location(l_proc, 10);
  --
  -- Rule Check unique competence name
  --
  per_cpn_bus.chk_definition_id
   (p_competence_id		=>	p_rec.competence_id
   ,p_business_group_id		=>	p_rec.business_group_id
   ,p_competence_definition_id	=>      p_rec.competence_definition_id
   ,p_object_version_number	=>	p_rec.object_version_number
   );
  hr_utility.set_location(l_proc, 15);
  --
  -- Rule Check if rating scale exists and is in same business group as
  -- as that of competence
  --
  per_cpn_bus.chk_rat_scale_bus_grp_exist
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_rating_scale_id		=>      p_rec.rating_scale_id
   ,p_business_group_id		=>      p_rec.business_group_id);
   hr_utility.set_location(l_proc, 16);
  --
  -- Rule Check if rating scale is valid
  --
  per_cpn_bus.chk_rating_scale_type
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_rating_scale_id		=>	p_rec.rating_scale_id
   );
  --
  --
  -- Rule Check Dates
  --
 per_cpn_bus.chk_competence_dates
   (p_date_from			=>	p_rec.date_from
   ,p_date_to			=>	p_rec.date_to );
  --
  -- Rule check Certification required Flag
  --
  per_cpn_bus.chk_certification_required
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_certification_required    =>      p_rec.certification_required
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 25);
  --
  -- Rule check Evaluation Method
  --
  per_cpn_bus.chk_evaluation_method
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_evaluation_method		=>      p_rec.evaluation_method
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 30);
  --
  -- Rule check Renewal period units
  --
  per_cpn_bus.chk_renewal_period_units
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,P_renewal_period_units      =>      p_rec.renewal_period_units
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 35);
  --
  -- Rule check dependency of period units and period frquency
  --
  per_cpn_bus.chk_renewable_unit_frequency
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_renewal_period_units      =>      p_rec.renewal_period_units
   ,p_renewal_period_frequency  =>      p_rec.renewal_period_frequency
   );
   -- added by ngundura as part of global competence changes
   hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'competence_definition_id',
                              p_argument_value => p_rec.competence_definition_id );

  hr_utility.set_location(l_proc, 40);
  --
  -- Rule check competence cluster
  --
  per_cpn_bus.chk_competence_cluster
   (p_competence_id             =>      p_rec.competence_id
   ,p_competence_cluster        =>      p_rec.competence_cluster
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 50);

  --
  -- Rule check unit_standard_id
  --
  per_cpn_bus.chk_unit_standard_id
   (p_competence_id             =>      p_rec.competence_id
   ,p_unit_standard_id          =>      p_rec.unit_standard_id
   ,p_business_group_id         =>      p_rec.business_group_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 60);

  --
  -- Rule check credit type
  --
  per_cpn_bus.chk_credit_type
   (p_competence_id             =>      p_rec.competence_id
   ,p_credit_type               =>      p_rec.credit_type
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 70);
  --
  -- Rule check level type
  --
  per_cpn_bus.chk_level_type
   (p_competence_id             =>      p_rec.competence_id
   ,p_level_type                =>      p_rec.level_type
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 80);
  --
  -- Rule check level
  --
  per_cpn_bus.chk_level_number
   (p_competence_id             =>      p_rec.competence_id
   ,p_level_number              =>      p_rec.level_number
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 90);

  --
  -- Rule check field
  --
  per_cpn_bus.chk_field
   (p_competence_id             =>      p_rec.competence_id
   ,p_field                     =>      p_rec.field
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 100);

  --
  -- Rule check sub field
  --
  per_cpn_bus.chk_sub_field
   (p_competence_id             =>      p_rec.competence_id
   ,p_sub_field                 =>      p_rec.sub_field
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 110);

  --
  -- Rule check provider
  --
  per_cpn_bus.chk_provider
   (p_competence_id             =>      p_rec.competence_id
   ,p_provider                  =>      p_rec.provider
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 120);

  --
  -- Rule check qa organization
  --
  per_cpn_bus.chk_qa_organization
   (p_competence_id             =>      p_rec.competence_id
   ,p_qa_organization           =>      p_rec.qa_organization
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 130);

  --
  --
  -- Call descriptive flexfield validation routines
  --
   per_cpn_bus.chk_ddf(p_rec => p_rec);   -- BUG3356369
  --
   hr_utility.set_location(l_proc, 140);
  --
   per_cpn_bus.chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 150);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_cpn_shd.g_rec_type
			 ,p_effective_date in date ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Rule Check Business group id cannot be updated
  --
  chk_non_updateable_args(p_rec	=> p_rec);
  --
  -- Rule Check unique competence name
  --
  per_cpn_bus.chk_definition_id
   (p_competence_id             =>      p_rec.competence_id
   ,p_business_group_id         =>      p_rec.business_group_id
   ,p_competence_definition_id  =>      p_rec.competence_definition_id
   ,p_object_version_number     =>      p_rec.object_version_number
   );
  hr_utility.set_location(l_proc, 15);
  --
  -- Rule Check Dates
  --
  per_cpn_bus.chk_competence_dates
   (p_date_from			=>	p_rec.date_from
   ,p_date_to			=>	p_rec.date_to
   ,p_competence_id		=> 	p_rec.competence_id
   ,p_called_from		=>	'UPDATE'
   );
  -- Rule check Certification required Flag
  --
   per_cpn_bus.chk_certification_required
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_certification_required    =>      p_rec.certification_required
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 25);
  --
  -- Rule check Evaluation Method
  --
  per_cpn_bus.chk_evaluation_method
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_evaluation_method         =>      p_rec.evaluation_method
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 30);
  --
  -- Rule check Renewal period units
  --
  per_cpn_bus.chk_renewal_period_units
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_renewal_period_units      =>      p_rec.renewal_period_units
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 35);
  --
  -- Rule check dependency of period units and period frquency
  --
  per_cpn_bus.chk_renewable_unit_frequency
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_renewal_period_units      =>      p_rec.renewal_period_units
   ,p_renewal_period_frequency  =>      p_rec.renewal_period_frequency
   );
  hr_utility.set_location(l_proc, 36);
  --
  --
  -- Rule Check if rating scale exists and is in same business group as
  -- as that of competence
  --
  per_cpn_bus.chk_rat_scale_bus_grp_exist
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_rating_scale_id           =>      p_rec.rating_scale_id
   ,p_business_group_id         =>      p_rec.business_group_id);
  hr_utility.set_location(l_proc, 37);
  --
  --
  -- Rule Check if rating scale is valid
  --
  per_cpn_bus.chk_rating_scale_type
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_rating_scale_id           =>      p_rec.rating_scale_id
   );
  --
    hr_utility.set_location(l_proc, 40);
  --
  -- Rule check if competence has any Proficiency levels. If it has
  -- then do not allow any rating scales to be assinged to this competence.
  per_cpn_bus.chk_competence_has_prof
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_rating_scale_id           =>      p_rec.rating_scale_id
   );
  --
    hr_utility.set_location(l_proc, 45);
  --
  -- Rule check competence rating scale cannot be updated if the rating
  -- level for that rating scale is used in competence element
  per_cpn_bus.chk_competence_rating_update
   (p_competence_id             =>      p_rec.competence_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_rating_scale_id           =>      p_rec.rating_scale_id
   );
  --
  hr_utility.set_location(l_proc, 50);
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'competence_definition_id',
                              p_argument_value => p_rec.competence_definition_id );
  hr_utility.set_location(l_proc, 60);
  --
  -- Rule check competence cluster
  --
  per_cpn_bus.chk_competence_cluster
   (p_competence_id             =>      p_rec.competence_id
   ,p_competence_cluster        =>      p_rec.competence_cluster
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 70);

  --
  -- Rule check unit_standard_id
  --
  per_cpn_bus.chk_unit_standard_id
   (p_competence_id             =>      p_rec.competence_id
   ,p_unit_standard_id          =>      p_rec.unit_standard_id
   ,p_business_group_id         =>      p_rec.business_group_id
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 80);

  --
  -- Rule check credit type
  --
  per_cpn_bus.chk_credit_type
   (p_competence_id             =>      p_rec.competence_id
   ,p_credit_type               =>      p_rec.credit_type
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 90);

  --
  -- Rule check level type
  --
  per_cpn_bus.chk_level_type
   (p_competence_id             =>      p_rec.competence_id
   ,p_level_type                =>      p_rec.level_type
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 100);

  --
  -- Rule check level
  --
  per_cpn_bus.chk_level_number
   (p_competence_id             =>      p_rec.competence_id
   ,p_level_number              =>      p_rec.level_number
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 110);

  --
  -- Rule check field
  --
  per_cpn_bus.chk_field
   (p_competence_id             =>      p_rec.competence_id
   ,p_field                     =>      p_rec.field
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 120);

  --
  -- Rule check sub field
  --
  per_cpn_bus.chk_sub_field
   (p_competence_id             =>      p_rec.competence_id
   ,p_sub_field                 =>      p_rec.sub_field
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 130);

  --
  -- Rule check provider
  --
  per_cpn_bus.chk_provider
   (p_competence_id             =>      p_rec.competence_id
   ,p_provider                  =>      p_rec.provider
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );

  hr_utility.set_location(l_proc, 140);
  --
  -- Rule check qa organization
  --
  per_cpn_bus.chk_qa_organization
   (p_competence_id             =>      p_rec.competence_id
   ,p_qa_organization           =>      p_rec.qa_organization
   ,p_object_version_number     =>      p_rec.object_version_number
   ,p_effective_date            =>      p_effective_date
   );
  hr_utility.set_location(l_proc, 150);
  --
  --
  -- Call descriptive flexfield validation routines
  --
  per_cpn_bus.chk_ddf(p_rec => p_rec);   -- BUG3356369
  --
  hr_utility.set_location(l_proc, 160);
  --
  per_cpn_bus.chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 180);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_cpn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Delete of Competence
  --
  -- Business Rule mapping
  --
  per_cpn_bus.chk_competence_delete
    (p_competence_id		=>	p_rec.competence_id
    ,p_object_version_number	=>	p_rec.object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
         (  p_competence_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
-- Bug #2536636 --Modified the cursor with outer join
   cursor csr_leg_code is
          select pbg.legislation_code, pcp.business_group_id
          from   per_business_groups pbg,
                 per_competences     pcp
          where  pcp.competence_id        = p_competence_id
            and  pbg.business_group_id(+) = pcp.business_group_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
-- Bug #2536636
   l_business_group_id per_business_groups.business_group_id%Type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'competence_id',
                              p_argument_value => p_competence_id );
 --
  if nvl(g_competence_id, hr_api.g_number) = p_competence_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 10);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
  --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code, l_business_group_id; --Bug #2536636
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
  -- Bug #2536636
    if l_business_group_id is not null then
       g_competence_id    := p_competence_id;
       g_legislation_code := l_legislation_code;
    else
       return null;
    end if;
  --
  end if;
  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End return_legislation_code;
--
--
end per_cpn_bus;

/
