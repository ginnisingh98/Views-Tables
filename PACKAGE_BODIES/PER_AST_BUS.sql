--------------------------------------------------------
--  DDL for Package Body PER_AST_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_AST_BUS" as
/* $Header: peastrhi.pkb 120.7.12010000.2 2008/10/20 14:11:39 kgowripe ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ast_bus.';  -- Global package name
--
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_assessment_type_id      number default null;
g_legislation_code        varchar2(150) default null;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
--
-- Aside from the primary key, the only non updatable argument is the business
-- group.  Certain other arguments : rating_scale_id, weighting_scale_id and
-- assessment_classification can only be updated if they are not being used
-- by an assessment.
--
Procedure chk_non_updateable_args(p_rec in per_ast_shd.g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'chk_non_updateable_args';
  l_error	exception;
  l_argument    varchar2(30);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema.
  --
  if not per_ast_shd.api_updating
    (p_assessment_type_id	=> p_rec.assessment_type_id
    ,p_object_version_number	=> p_rec.object_version_number
    ) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location (l_proc, 6);
  --
  if p_rec.business_group_id <> per_ast_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 7);
  --
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving : '|| l_proc, 9);
end chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_name >-------------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   A check to make sure that the name entered is unique within the business
--   group and that the field isn't NULL.
-- Pre-Conditions :
--   None
-- In Arguments :
--    name
--    business_group_id
-- Post success :
--    Processing continues if the name entered is unique within BG.
-- Post failure :
--    An application error is raised and processing is terminated if the
--    name is not unique within BG.
--
Procedure chk_name
 (p_name		in 	per_assessment_types.name%TYPE,
  p_assessment_type_id  in 	per_assessment_types.assessment_type_id%TYPE,
  p_type  in 	per_assessment_types.type%TYPE,
  p_business_group_id   in	per_assessment_types.business_group_id%TYPE,
  p_object_version_number in    per_assessment_types.object_version_number%TYPE
 )
is
--
   l_proc	        varchar2(72) := g_package||'chk_name';
   l_name	 	    per_assessment_types.name%TYPE;
   l_exists         per_assessment_types.business_group_id%TYPE;
   l_api_updating       boolean;
--
-- Cursor to get rows which have duplicate names
--
  cursor csr_name is
    select business_group_id from per_assessment_types
    where ((p_assessment_type_id is NULL)
      or   (p_assessment_type_id <> assessment_type_id))
      and name = p_name -- there is a duplicate name.
      and  nvl(type , 'COMPETENCE') = nvl(p_type , 'COMPETENCE')
      and p_business_group_id is  null
    union
    select business_group_id from per_assessment_types
    where ((p_assessment_type_id is NULL)
      or   (p_assessment_type_id <> assessment_type_id))
      and name = p_name -- there is a duplicate name.
      and  nvl(type , 'COMPETENCE') = nvl(p_type , 'COMPETENCE')
      and (business_group_id = p_business_group_id or business_group_id is null)
      and p_business_group_id is not null;

begin
  -- Bug#885806
  -- dbms_output.put_line('chk_name := '||p_name);
  hr_utility.trace('chk_name := '||p_name);
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check that the business_group_id is not null.
  --

  -- Only proceed with validation if:
  --   a) The current g_old_rec is current and
  --   b) The value for name has changed.
  --   c) The value is being inserted.
  --
  l_api_updating := per_ast_shd.api_updating
        (p_assessment_type_id        => p_assessment_type_id
        ,p_object_version_number  => p_object_version_number
        );
  --
  hr_utility.set_location (l_proc, 2);
  --
  if (l_api_updating AND
     nvl(per_ast_shd.g_old_rec.name, hr_api.g_varchar2)
     <> nvl(p_name, hr_api.g_varchar2)
     or not l_api_updating)
  then
  --
    hr_utility.set_location (l_proc, 3);
    --
    -- Check that the name isn't NULL
    --
    if p_name is NULL then
      hr_utility.set_message(801,'HR_51498_AST_NAME_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- Check that the name is unique within the business group.
    --
    open csr_name;
    fetch csr_name into l_exists;
    if csr_name%found then
      -- The name already exists in the business group
      close csr_name;
      if l_exists is null then
          if nvl(p_type,'COMPETENCE')='COMPETENCE' then
            hr_utility.set_message(800,'HR_AST_NAME_IN_GLOB');
            hr_utility.raise_error;
        else
            hr_utility.set_message(800,'HR_OBJ_NAME_IN_GLOB');
            hr_utility.raise_error;
        end if;
      else
       if nvl(p_type,'COMPETENCE')='COMPETENCE' then
            hr_utility.set_message(800,'HR_51499_AST_NAME_NOT_UNIQ');
            hr_utility.raise_error;
        else
            hr_utility.set_message(800,'HR_51499_OBJ_NAME_NOT_UNIQ');
            hr_utility.raise_error;
        end if;
      end if;
    end if;
    --
    hr_utility.set_location(' Leaving:' || l_proc,2);
    --
    close csr_name;
    --
  end if;
end chk_name;
-- ----------------------------------------------------------------------------
-- |------------------< chk_disp_assess_comments >---------------------|
-- ----------------------------------------------------------------------------
-- Description
--  Validate display_assessment_comments against the HR_LOOKUP where
--  lookup_type = 'YES_NO'.
--
-- Pre-conditions
--   None
--
-- In Arguments:
--   p_display_assessment_comments
--   p_assessment_type_id
--   p_effective_date
--   p_object_version_number
--
-- Post Success:
--   If display_assessment_comments is valid, processing continues.
-- Post Failure:
--   If the valid for comments displayed isn't in lookup 'YES_NO'.
-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure chk_disp_assess_comments
 (p_display_assessment_comments in per_assessment_types.display_assessment_comments%TYPE

 ,p_assessment_type_id		in per_assessment_types.assessment_type_id%TYPE
 ,p_effective_date		in 	date
 ,p_object_version_number 	in per_assessment_types.object_version_number%TYPE
 )
is
--
  l_proc	varchar2(72):=g_package||'chk_display_assessment_comments';
  l_api_updating	boolean;
--
begin
  -- Bug#885806
  --  dbms_output.put_line('Inside the chk_display_assessment_comments procedure');
  hr_utility.trace('Inside the chk_display_assessment_comments procedure');
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	 	=> l_proc
    ,p_argument		=> 'effective_date'
    ,p_argument_value	=> p_effective_date
    );
  --
  -- Only proceed with the validation if :
  --  a) The current g_old_rec is current
  --  b) The value has changed.
  --  c) A record is being inserted
  --
  l_api_updating := per_ast_shd.api_updating
    (p_assessment_type_id	=> p_assessment_type_id
    ,p_object_version_number	=> p_object_version_number
    );
  --
  if ((l_api_updating and nvl(per_ast_shd.g_old_rec.display_assessment_comments,
				 hr_api.g_varchar2)
  		<> nvl(p_display_assessment_comments, hr_api.g_varchar2))
  or
    (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check the value in p_display_assessment_comments exists in hr_lookups
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date	=> p_effective_date
      ,p_lookup_type	=> 'YES_NO'
      ,p_lookup_code	=> p_display_assessment_comments
      ) then
      hr_utility.set_location(l_proc, 10);
      hr_utility.set_message(801,'HR_51500_AST_COMS_DISP_INVAL');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 15);
  end if;
end chk_disp_assess_comments;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_date_from_to>-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--  Validate the date_from and date_to fields to make sure
--  	1) The date_to in on or after the date_from date
--      2) Any assessments already created using the assessment_type are not
--	   invalidated  by changing the dates.
--   The date_from and the date_to can both (or either) be null.
--
-- Pre-conditions
--   None
--
-- In Arguments:
--   p_date_from
--   p_date_to
--   p_assessment_type_id
--   p_effective_date
--   p_object_version_number
--
-- Post Success:
--   If all test pass, processing continues.
-- Post Failure:
--   If the date_from is after the date_to, processing halts.
--   If a current assessment is invalidated, processing halts.
-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure chk_date_from_to
 (p_date_from		  in  	per_assessment_types.date_from%TYPE
 ,p_date_to 		  in 	per_assessment_types.date_to%TYPE
 ,p_assessment_type_id    in 	per_assessment_types.assessment_type_id%TYPE
 ,p_business_group_id     in    per_assessment_types.business_group_id%TYPE
 ,p_object_version_number in	per_assessment_types.object_version_number%TYPE
 )
is
--
  l_proc		varchar2(72):=g_package||'chk_date_from_to';
  l_api_updating	boolean;
--
--  Set up a cursor to get the minimum and maximum dates of assessments using
-- the assessment_type being checked
--
  cursor csr_assessment_dates is
    select min(assessment_date) , max(assessment_date)
    from per_assessments ass
    where p_assessment_type_id = ass.assessment_type_id
    and (p_business_group_id = business_group_id or  p_business_group_id is null) ;

--
  l_min_assessment_date		per_assessments.assessment_date%TYPE;
  l_max_assessment_date         per_assessments.assessment_date%TYPE;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  -- Only proceed with the validation if :
  --  a) The current g_old_rec is current.
  --  b) The date_from has changed.
  --  c) The date_to has changed.
  --  d) a record is being inserted.
  --
  l_api_updating := per_ast_shd.api_updating
    (p_assessment_type_id 	=> p_assessment_type_id
    ,p_object_version_number	=> p_object_version_number
    );
  --
  if (((l_api_updating and nvl(per_ast_shd.g_old_rec.date_from,
				hr_api.g_date)
                        <> nvl(p_date_from, hr_api.g_date))
      or
        (l_api_updating and nvl(per_ast_shd.g_old_rec.date_to,
			         hr_api.g_date)
			<> nvl(p_date_to, hr_api.g_date))
       )
  or
    (NOT l_api_updating)) then
    --
    -- If the date_from is greater then the date_to, raise an error
    --
    if ((p_date_from is not null) and (p_date_to is not null)
	and (p_date_from > p_date_to)) then
      --
      hr_utility.set_message(801,'HR_51859_AST_DATE_FROM_DATE_TO');
      hr_utility.raise_error;
      --
    end if;
    --
    -- Make sure that any assessments using this assesment_type aren't
    -- invalidated by changing the date.
    --
    open csr_assessment_dates;
    fetch csr_assessment_dates into l_min_assessment_date, l_max_assessment_date;
    close csr_assessment_dates;
    --
    if ((p_date_to is not null) and (l_max_assessment_date is not null)
       and ( l_max_assessment_date > p_date_to)) then
      --
      -- Assessment exists which were created later than the type, so error
      --
       hr_utility.set_message(801,'HR_51860_AST_DATE_OUT_RANGE1');
       hr_utility.raise_error;
       --
    end if;
    --
    if ((p_date_from is not null) and (l_min_assessment_date is not null)
        and (l_min_assessment_date < p_date_from)) then
      --
      -- Assessment(s) exists which were created before the type, so error
      --
       hr_utility.set_message(801,'HR_51861_AST_DATE_OUT_RANGE2');
       hr_utility.raise_error;
       --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 15);
  --
end chk_date_from_to;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_assessment_classification >-------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--  Validate assessment_classification against lookup_type of
--  'ASSESSMENT_CLASSIFICATION'.  Valid values can be one of three :
--		PERFORMANCE
--		PROFICIENCY
-- 		BOTH
--  The assessment_classification can only be updated if the assessment
--  type isn't being used by an assessment.
--
-- Pre-conditions
--   None
--
-- In Arguments:
--   p_assessment_classification
--   p_effective_date
--
-- Post Success:
--   If assessment_classification is valid, processing continues.
-- Post Failure:
--   Processing fails
-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure chk_assessment_classification
 (p_assessment_classification in per_assessment_types.assessment_classification%TYPE
 ,p_business_group_id 	in per_assessment_types.business_group_id%TYPE
 ,p_effective_date	in 	date
 ,p_assessment_type_id  in per_assessment_types.assessment_type_id%TYPE
 ,p_object_version_number in per_assessment_types.object_version_number%TYPE
 )
is
--
-- Define the cursor to check if the assessment_type is used in an assessment
--
  cursor csr_assessment_type_usage is
    select null
    from per_assessments
    where assessment_type_id = p_assessment_type_id
    and (p_business_group_id = business_group_id or  p_business_group_id is null) ;

--
  l_proc	varchar2(72):=g_package||'chk_assessment_classification';
  l_exists	varchar2(1);
  l_api_updating	boolean;
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	 	=> l_proc
    ,p_argument		=> 'effective_date'
    ,p_argument_value	=> p_effective_date
    );
  --
  -- Bug#885806
  -- dbms_output.put_line('About to check the assessment_classification');
  hr_utility.trace('About to check the assessment_classification');
  --
  -- If record is being updated, and the assessment_classification is being
  -- changed check to see whether the assessment_type is being used or not by an
  -- assessment.  If it is, then the assessment_classification cannot be
  -- updated.
  --
  l_api_updating := per_ast_shd.api_updating
    (p_assessment_type_id 	=> p_assessment_type_id
    ,p_object_version_number	=> p_object_version_number
    );
  --
  --
  --
  if (l_api_updating and nvl(per_ast_shd.g_old_rec.assessment_classification,
				hr_api.g_varchar2)
		<> nvl(p_assessment_classification, hr_api.g_varchar2)) then
    --
    -- Assessment Classification is being updated
    -- Bug#885806
    -- dbms_output.put_line('The assessment_classification is being updated');
    hr_utility.trace('The assessment_classification is being updated');
    --
    open csr_assessment_type_usage;
    fetch csr_assessment_type_usage into l_exists;
    if csr_assessment_type_usage%found then
      --
      -- The assessment_type is being used so the asssessment_classification
      -- can't be updated
      --
      hr_utility.set_message(801,'HR_51578_AST_USED_NO_UP_AS_CL');
      hr_utility.raise_error;
    end if;
  end if;
  --
  --
  -- Check that the value in p_assessment_classifications exist in hr_lookups.
  --
  if(p_assessment_classification <> 'FASTFORMULA') then
  if hr_api.not_exists_in_hr_lookups
    (p_effective_date	=> p_effective_date
    ,p_lookup_type	=> 'ASSESSMENT_CLASSIFICATION'
    ,p_lookup_code	=> p_assessment_classification
    ) then
    hr_utility.set_location(l_proc, 10);
    hr_utility.set_message(801,'HR_51502_AST_ASS_CLASS_INVAL');
    hr_utility.raise_error;
  end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 15);
end chk_assessment_classification;
--
--
-- |---------------------------------------------------------------------------
-- |-------------------------< chk_weighting_scale_id >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--  WEIGHTING_SCALE_ID is a foreign key to PER_RATING_SCALES(RATING_SCALE_ID),
--  therefore values entered for this column must exist in the referenced table
--  where PER_RATING_SCALES(TYPE) = 'WEIGHTING' and the business group is the
--  same.
--
-- The weighting_scale_id can only be updated if it the assessment_type is
-- not being used by an assessment.
-- Pre-conditions
--   business_group_id is valid
--   assessment_classification is valid
-- In Arguments:
--   p_weighting_scale
--   p_business_group_id
--   p_assessment_classification
-- Post Success:
--   Processing continues.
-- Post Failure:
--   Processing terminates
-- Access Status:
--   Internal table handler use only.
--
Procedure chk_weighting_scale_id
 (p_weighting_scale_id	in per_assessment_types.weighting_scale_id%TYPE
 ,p_business_group_id	in per_assessment_types.business_group_id%TYPE
 ,p_assessment_type_id  in per_assessment_types.assessment_type_id%TYPE
 ,p_assessment_classification	in per_assessment_types.assessment_classification%TYPE
 ,p_object_version_number in per_assessment_types.object_version_number%TYPE
 )
is
--
-- Define the cursor the get the type and bg from per_rating_scales
-- ngundura changes for pa requirements.
  cursor csr_weighting_scale_id is
    select type,business_group_id
    from per_rating_scales
    where p_weighting_scale_id = rating_scale_id
    and  (nvl(p_business_group_id,-1) = nvl(business_group_id,-1) or business_group_id is null);


-- ngundura end of changes
-- Define the cursor to check if the assessment_type is used in an assessment
--
  cursor csr_assessment_type_usage is
    select null
    from per_assessments
    where assessment_type_id = p_assessment_type_id
    and ( business_group_id = p_business_group_id or p_business_group_id is null) ;
--
-- Define the local variables for the cursor to go
--
  l_exists	varchar2(1);
  l_api_updating	boolean;
--
-- Define the local variables for the cursor to use
--
  l_type		per_rating_scales.type%TYPE;
  l_business_group_id		per_rating_scales.business_group_id%TYPE;
  l_proc		varchar2(72):=g_package||'chk_weighting_scale_id';
  l_csr_not_found       boolean := FALSE;
--
begin
  hr_utility.set_location('Entering:'||l_proc,1);

  -- Check that the assessment_classification is not NULL
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'assessment_classification'
    ,p_argument_value	=> p_assessment_classification
    );
  --
  --
  -- If record is being updated, and the weighting_scale_id is being changed
  -- check to see whether the assessment_type is being used or not by an
  -- assessment.  If it is, then the weighting_scale_id cannot be updated.
  -- Even if the value hasn't changed for the weighting_scale_id, the validation
  -- still takes place as compatibility with other columns is checked
  --
  l_api_updating := per_ast_shd.api_updating
    (p_assessment_type_id 	=> p_assessment_type_id
    ,p_object_version_number	=> p_object_version_number
    );
  --
  if (l_api_updating and nvl(per_ast_shd.g_old_rec.weighting_scale_id,
				hr_api.g_number)
		<> nvl(p_weighting_scale_id, hr_api.g_number)) then
    --
    -- Weighting scale id is being updated, so check if it is being used
    --
    open csr_assessment_type_usage;
    fetch csr_assessment_type_usage into l_exists;
    if csr_assessment_type_usage%found then
      --
      -- The assessment_type being used so the weighting_scale can't be updated
      --
      hr_utility.set_message(801,'HR_51577_AST_USED_NO_UP_WE');
      hr_utility.raise_error;
    end if;
  end if;
  --
  -- Check if a value for weighting_scale_id exists(as it can be NULL)
  -- Bug#885806
  -- dbms_output.put_line('About to check if the weighting_scale_id exists');
  hr_utility.trace('About to check if the weighting_scale_id exists');
  --
  if p_weighting_scale_id is not null then
    --
  -- Bug#885806
  -- dbms_output.put_line('It exists');
  hr_utility.trace('It exists');
    hr_utility.set_location (l_proc,10);
    open csr_weighting_scale_id;
    fetch csr_weighting_scale_id into l_type,l_business_group_id;
    --
    --
    -- Check that the weighting_scale_id exists.
    --
    if csr_weighting_scale_id%notfound then
      l_csr_not_found := TRUE;
    end if;
    --
    close csr_weighting_scale_id;
    --
    if l_csr_not_found = TRUE then
      -- Bug#885806
      --  dbms_output.put_line('and weighting_scale_id doesnt exist in other tab');
      hr_utility.trace('and weighting_scale_id doesnt exist in other tab');
      hr_utility.set_location(l_proc,20);
      per_ast_shd.constraint_error
        (p_constraint_name => 'PER_ASSESSMENT_TYPES_FK3');
    --
    --
    -- Check if the weighting_scale_id is of the wrong type
    -- ie. if the type of the weighing_scale in per_rating_scales is not equal
    --     to 'WEIGHTING' then error.
    --
    elsif l_type <> 'WEIGHTING' then
      hr_utility.set_location(l_proc,30);
      --
      -- The same error that is displayed when the value doesn't exist in the
      -- table per_rating_scales can be used again, because as far as the api
      -- is concerned the value doesn't exist even if it does but is of a
      -- different type.
      --
      per_ast_shd.constraint_error
        (p_constraint_name => 'PER_ASSESSMENT_TYPES_FK3');
      --
    end if;
    --
  end if;
end chk_weighting_scale_id;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_weighting_scale_comment >-------------------|
-- ----------------------------------------------------------------------------
-- Description
--   Check that weighting_scale_comment is null if weighting_scale_id is null.
-- Pre-condition
--   weighing_scale_id is valid
--   business_group_id is valid
-- In Arguments
--   p_weighting_scale_comment
--   p_weighting_scale_id
-- Post Success
--   If weighting_scale_comment is valid, processing continues.
-- Post Failure:
--   Processing terminates
-- Access Status:
--   Internal table handler use only
--
Procedure chk_weighting_scale_comment
 (p_weighting_scale_comment	in per_assessment_types.weighting_scale_comment%TYPE

 ,p_weighting_scale_id		in per_assessment_types.weighting_scale_id%TYPE
 )
is
  l_proc		varchar2(72):=g_package||'chk_weighting_scale_comment';
begin
  -- Bug#885806
  -- dbms_output.put_line('AST_weighting_scale_comment = '||p_weighting_scale_comment);
  hr_utility.trace('AST_weighting_scale_comment = '||p_weighting_scale_comment);

  hr_utility.set_location(l_proc, 1);
  --
  -- If p_weighting_scale_id is NULL but p_weighting_scale_comment isn't, error.
  --
  if ((p_weighting_scale_id is NULL) and
     (p_weighting_scale_comment is not NULL)) then
    --
    -- comments exists without a weighting scale.
    --
    hr_utility.set_location(l_proc, 10);
    hr_utility.set_message(801,'HR_51505_AST_W_ID_COMS_NOTNUL');
    hr_utility.raise_error;
  end if;
end chk_weighting_scale_comment;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_rating_scale_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--  RATING_SCALE_ID is a foreign key to PER_RATING_SCALES(RATING_SCALE_ID),
--  therefore values entered for this column must exist in the referenced
--  table where PER_RATING_SCALES(TYPE)= 'PERFORMANCE'.
--  Also if rating_scale_id exists, assessment_classification must be of type
--  'PERFORMANCE' or 'BOTH' and not of type 'PROFICIENCY'.
-- Pre-conditions
--   business_group_id is valid
--   assessment_classification is valid
-- In Arguments:
--   p_rating_scale_id
--   p_business_group_id
--   p_assessment_type_id
--   p_assessment_classification
--   p_object_version_number
--
-- Post Success:
-- Post Failure:
--   Processing fails
-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure chk_rating_scale_id
 (p_rating_scale_id	in per_assessment_types.rating_scale_id%TYPE
 ,p_business_group_id	in per_assessment_types.business_group_id%TYPE
 ,p_assessment_type_id  in per_assessment_types.assessment_type_id%TYPE
 ,p_assessment_classification	in per_assessment_types.assessment_classification%TYPE
 ,p_object_version_number in per_assessment_types.object_version_number%TYPE
 ,p_weighting_classification   in  per_assessment_types.weighting_classification%TYPE
 )
is
-- Define the cursor to get the info. from per_rating_scales
-- ngundura changes done for pa requirements
  cursor csr_rating_scale_id is
    select type
    from per_rating_scales
    where p_rating_scale_id = rating_scale_id
    and  (nvl(p_business_group_id,-1) = nvl(business_group_id,-1) or business_group_id is null) ;

-- ngundura  end of changes
-- Define the cursor to check if the assessment_type is used in an assessment
--
  cursor csr_assessment_type_usage is
    select null
    from per_assessments
    where assessment_type_id = p_assessment_type_id
    and business_group_id = p_business_group_id;
--
-- Define the local variables for the cursor to go
--
  l_type	per_rating_scales.type%TYPE;
  l_proc		varchar2(72):=g_package||'chk_rating_scale_id';
  l_csr_not_found	boolean := FALSE;
  l_exists	varchar2(1);
  l_api_updating	boolean;
--
--
begin
  -- Bug#885806
  -- dbms_output.put_line('AST_rating_scale_id = '||p_rating_scale_id);
  hr_utility.trace('AST_rating_scale_id = '||p_rating_scale_id);
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --

  -- Check that assessment_classification is not null.
  --

  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'assessment_classification'
    ,p_argument_value   => p_assessment_classification
    );
  --
  -- If record is being updated, and the rating_scale_id is being changed
  -- check to see whether the assessment_type is being used or not by an
  -- assessment.  If it is, then the rating_scale_id cannot be updated.
  -- Even if the value hasn't changed for the rating_scale_id, the validation
  -- still takes place as compatibility with other columns is checked
  --
  l_api_updating := per_ast_shd.api_updating
    (p_assessment_type_id 	=> p_assessment_type_id
    ,p_object_version_number	=> p_object_version_number
    );
  --
  if (l_api_updating and nvl(per_ast_shd.g_old_rec.rating_scale_id,
				hr_api.g_number)
		<> nvl(p_rating_scale_id, hr_api.g_number)) then
    --
    -- Rating scale id is being updated, so check if it is being used
    --
    open csr_assessment_type_usage;
    fetch csr_assessment_type_usage into l_exists;
    if csr_assessment_type_usage%found then
      --
      -- The assessment_type is being used so the rating_scale can't be updated
      --
      hr_utility.set_message(801,'HR_51576_AST_USED_NO_UP_RA');
      hr_utility.raise_error;
    end if;
  end if;

  --

  if (p_rating_scale_id IS NOT NULL) then
    -- Bug#885806
    --dbms_output.put_line('chk_rating_scale_id:Rating scale ID isnt NULL');
    hr_utility.trace('chk_rating_scale_id:Rating scale ID isnt NULL');
    hr_utility.set_location(l_proc,5);
    --
    -- If rating_scale_id is NOT NULL, assessment_classification must be
    -- either PERFORMANCE or BOTH, otherwise raise an error.
    --
    if p_assessment_classification not in ('PERFORMANCE','BOTH','FASTFORMULA') then
      -- Bug#885806
      -- dbms_output.put_line('chk_rating_scale_id:AssessClass not in Per or Bo');
      hr_utility.trace('chk_rating_scale_id:AssessClass not in Per or Bo or FF');
      hr_utility.set_location(l_proc,10);
      per_ast_shd.constraint_error
        (p_constraint_name => 'PER_ASS_TYPES_RATE_NOTNULL_CHK');
      --
    end if;
    --
    hr_utility.set_location(l_proc, 15);
    open csr_rating_scale_id ;
    fetch csr_rating_scale_id into l_type;
    --
    -- Check if the rating_scale_id exists.
    --
    if csr_rating_scale_id%notfound then
      l_csr_not_found := TRUE;
    end if;
    --
    -- Close the cursor as it isn't needed anymore
    --
    close csr_rating_scale_id;
    --
    if l_csr_not_found = TRUE then
    -- Bug#885806
    -- dbms_output.put_line('chk_rating_scale_id:Rating scale not found');
    hr_utility.trace('chk_rating_scale_id:Rating scale not found');
      hr_utility.set_location(l_proc,20);
      per_ast_shd.constraint_error
        (p_constraint_name => 'PER_ASSESSMENT_TYPES_FK2');
    --
    -- Check if the rating_scale_id is of the wrong type.
    -- ie if the type of the rating_scale in per_rating_scales
    -- is not equal to PERFORMANCE, then error.
    --
    elsif l_type <> 'PERFORMANCE' then
      -- Bug#885806
      --dbms_output.put_line('chk_rating_scale_id:Rating scale found, type diff');
      hr_utility.trace('chk_rating_scale_id:Rating scale found, type diff');
      -- dbms_output.put_line('AST_rating_scale_type = '||l_type);
      hr_utility.trace('AST_rating_scale_type = '||l_type);
      --
      hr_utility.set_location(l_proc,30);
      --
      -- The same error message that gets used when the value can be found
      -- in the table per_rating_scales can be used here as even thought the
      -- value entered exists it is of the wrong type therefore it may as well
      -- not exist.
      --

      per_ast_shd.constraint_error
        (p_constraint_name => 'PER_ASSESSMENT_TYPES_FK2');

      --
    end if;
    --
    -- RATING_SCALE_ID must be NULL so check that assessment_classification
    -- is 'PROFICIENCY'
    --
  elsif (p_assessment_classification <> 'PROFICIENCY') then
    -- Bug#885806
     --dbms_output.put_line('chk_rating_scale_id:Rating scale NULL, type not Pro');
     hr_utility.trace('chk_rating_scale_id:Rating scale ID is NULL. assessment classif is '||p_assessment_classification);
    if((p_assessment_classification <> 'FASTFORMULA')) then
    hr_utility.trace('chk_rating_scale_id:Rating scale NULL, type not FastFormula');


    per_ast_shd.constraint_error
      (p_constraint_name => 'PER_ASS_TYPES_RATE_NULL_CHK');
  end if;
end if;
  --
end chk_rating_scale_id;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_rating_scale_comment >-------------------|
-- ----------------------------------------------------------------------------
-- Description
--   Check that rating_scale_comment is null if rating_scale_id is null.
-- Pre-condition
--   rating_scale_id is valid
--   business_group_id is valid
-- In Arguments
--   p_rating_scale_comment
--   p_rating_scale_id
-- Post Success
--   If rating_scale_comment is valid, processing continues.
-- Post Failure:
--   Processing terminates
-- Access Status:
--   Internal table handler use only
--
Procedure chk_rating_scale_comment
 (p_rating_scale_comment	in per_assessment_types.rating_scale_comment%TYPE
 ,p_rating_scale_id		in per_assessment_types.rating_scale_id%TYPE
 )
is
  l_proc		varchar2(72):=g_package||'chk_rating_scale_comment';
begin
  hr_utility.set_location(l_proc, 1);
  --
  -- If p_rating_scale_id is NULL but p_rating_scale_comment isn't, error.
  --
  if ((p_rating_scale_id is NULL) and
     (p_rating_scale_comment is not NULL)) then
    --
    -- comments exists without a rating scale.
    --
    hr_utility.set_location(l_proc, 10);
    hr_utility.set_message(801,'HR_51509_AST_R_ID_COMS_NOTNUL');
  end if;
end chk_rating_scale_comment;
-- ----------------------------------------------------------------------------
-- |--------------------< chk_weighting_classification >----------------------|
-- ----------------------------------------------------------------------------
-- Description
--   WEIGHTING_CLASSIFICATION can be one of two values :
--		PERFORMANCE
-- 		PROFICIENCY
--   The values are based on the lookup_type of 'ASSESSMENT_CLASSIFICATION'.
--   It should only be NOT NULL if weighting_scale_id is NOT NULL
--
-- Preconditions
--   assessment_classification is not null
-- In Arguments
--   p_weighting_classification
--   p_weighting_scale_id
--   p_assessment_classification
-- Post Success:
--   If weighting_classification is valid, processing continues
-- Post Failure:
--  Processing halts.
-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure chk_weighting_classification
 (p_weighting_classification   in  per_assessment_types.weighting_classification%TYPE

 ,p_weighting_scale_id	       in per_assessment_types.weighting_scale_id%TYPE
 ,p_assessment_classification  in per_assessment_types.assessment_classification%TYPE

 )
is
  --
  l_proc	varchar2(72) := g_package||'chk_weighting_classification';
  --
begin
  -- Bug#885806
  -- dbms_output.put_line('AST_weighting_classification = '||p_weighting_classification);
  hr_utility.trace('AST_weighting_classification = '||p_weighting_classification);

  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Check assessment_classification is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name		=>	l_proc
    ,p_argument	 	=>	'assessment_classification'
    ,p_argument_value	=>	p_assessment_classification
    );
  --
  -- Weighting_classification is MANDATORY if weighting_scale_id is NOT NULL.
  --
  if ((p_weighting_scale_id IS NOT NULL) and
      (p_weighting_classification IS NULL and p_weighting_classification <> 'FASTFORMULA')) then
    hr_utility.set_location(l_proc,10);
    hr_utility.set_message(801,'HR_51510_AST_WEIG_CLAS_NULL');
    hr_utility.raise_error;
  end if;
  --
  -- The weighting_classification should be NULL if weighting_scale_id is NULL.
  --
  if ((p_weighting_scale_id IS NULL) and
      (p_weighting_classification IS NOT NULL and p_weighting_classification <> 'FASTFORMULA' )) then
    hr_utility.set_location(l_proc,20);
    hr_utility.set_message(801,'HR_51512_AST_WEIG_ID_NULL');
    hr_utility.raise_error;
  end if;
  --
  -- If this far, necessary values exist.
  -- Further checks only need to be performed if weighting_class. exists
  --
  if (p_weighting_classification IS NOT NULL) then
    --
    if (p_weighting_classification not in ('PERFORMANCE','PROFICIENCY','FASTFORMULA')) then
      hr_utility.set_location(l_proc,30);
      hr_utility.set_message(801,'HR_51513_AST_WEIG_CLAS_INVAL');
      hr_utility.raise_error;
    elsif ((p_assessment_classification <> 'BOTH') and
           (p_assessment_classification <> p_weighting_classification)) then
      --
      --  At this stage, we know that the assessment_classification is valid
      --  ie BOTH, PERFORMANCE or PROFICIENCY, so if assessment_classification
      --  is not = both, and the weighting classification isn't the same as
      --  the assessment_classification, then it must be valid but the wrong
      --  one.  (ie. it's performance and should be proficiency or visa versa)
      --
      hr_utility.set_location(l_proc,30);
      hr_utility.set_message(801,'HR_51514_AST_WEIG_CLAS_INCOMP');
      hr_utility.raise_error;
    end if;
  end if;
end chk_weighting_classification;
-- ----------------------------------------------------------------------------
-- |-------------------< chk_line_score_formula >----------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   LINE_SCORE_FORMULA should be validated against the lookup type of
--   'ASSESSMENT_LINE_FORMULA'.
--   This lookup will be user updatable
-- Preconditions
--   none
-- In Arguments
--   p_line_score_formula
--   p_assessment_type_id
--   p_effective_date
--   p_object_version_number
-- Post Success:
--   If line_score_formula is valid, processing continues
-- Post Failure
--   Processing halts.
--
Procedure chk_line_score_formula
 (p_line_score_formula 	in per_assessment_types.line_score_formula%TYPE
 ,p_assessment_type_id  in per_assessment_types.assessment_type_id%TYPE
 ,p_effective_date	in 	date
 ,p_object_version_number in per_assessment_types.object_version_number%TYPE
 )
is
  --
  l_proc	varchar2(72) := g_package||'chk_line_score_formula';
  --
begin
  hr_utility.set_location('Entering:'||l_proc,1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	 	=> l_proc
    ,p_argument		=> 'effective_date'
    ,p_argument_value	=> p_effective_date
    );
  -- Check that value exists in hr_lookups
  --
  if (p_line_score_formula IS NOT NULL) then
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date => p_effective_date
      ,p_lookup_type    => 'ASSESSMENT_LINE_FORMULA'
      ,p_lookup_code    => p_line_score_formula
      ) then
      hr_utility.set_location(l_proc,10);
      hr_utility.set_message(801,'HR_51515_AST_LINE_FORMU_INVAL');
      hr_utility.raise_error;
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc,20);
end chk_line_score_formula;
-- ----------------------------------------------------------------------------
-- |-------------------< chk_total_score_formula >----------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   TOTAL_SCORE_FORMULA should be validated against the lookup type of
--   'ASSESSMENT_TOTAL_FORMULA'.
--   This lookup will be user updatable
-- Preconditions
--   none
-- In Arguments
--   p_total_score_formula
--   p_assessment_type_id
--   p_effective_date
--   p_object_version_number
-- Post Success:
--   If total_score_formula is valid, processing continues
-- Post Failure
--   Processing halts.
--
Procedure chk_total_score_formula
 (p_total_score_formula 	in per_assessment_types.total_score_formula%TYPE
 ,p_assessment_type_id 	in per_assessment_types.assessment_type_id%TYPE
 ,p_effective_date	in 	date
 ,p_object_version_number in per_assessment_types.object_version_number%TYPE
 )
is
  --
  l_proc	varchar2(72) := g_package||'chk_total_score_formula';
  l_api_updating	boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc,1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	 	=> l_proc
    ,p_argument		=> 'effective_date'
    ,p_argument_value	=> p_effective_date
    );
  --
  --  Only proceed with the validation if:
  --   a) The current g_old_rec is current.
  --   b) The total_score_formula has changed.
  --   c) A record is being inserted.
  --
  l_api_updating := per_ast_shd.api_updating
    (p_assessment_type_id 	=> p_assessment_type_id
    ,p_object_version_number	=> p_object_version_number
    );
  --
  if ((l_api_updating and nvl(per_ast_shd.g_old_rec.total_score_formula,
				hr_api.g_varchar2)
		<> nvl(p_total_score_formula, hr_api.g_varchar2))
  or
    (NOT l_api_updating)) then
  --
    -- Check that value exists in hr_lookups
    --
    if (p_total_score_formula IS NOT NULL) then
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date => p_effective_date
        ,p_lookup_type    => 'ASSESSMENT_TOTAL_FORMULA'
        ,p_lookup_code    => p_total_score_formula
        ) then
        hr_utility.set_location(l_proc,10);
        hr_utility.set_message(801,'HR_51516_AST_TOTA_FORMU_INVAL');
        hr_utility.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
  --
  -- Bug#885806
  -- dbms_output.put_line('AST_total score formula ');
  hr_utility.trace('AST_total score formula ');
end chk_total_score_formula;

-- ----------------------------------------------------------------------------
-- |-------------------< chk_type >----------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   TYPE should be validated against the lookup type of
--   'ASSESSMENT_TYPE'.
--   This lookup will be system lookup
-- Preconditions
--   none
-- In Arguments
--   p_type
--   p_assessment_type_id
--   p_effective_date
--   p_object_version_number
-- Post Success:
--   If type is valid, processing continues
-- Post Failure
--   Processing halts.
--
Procedure chk_type
 (p_type 	in per_assessment_types.type%TYPE
 ,p_assessment_type_id 	in per_assessment_types.assessment_type_id%TYPE
 ,p_effective_date	in 	date
 ,p_object_version_number in per_assessment_types.object_version_number%TYPE
  )
is
  --
  l_proc	varchar2(72) := g_package||'chk_type';
  l_api_updating	boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc,1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	 	=> l_proc
    ,p_argument		=> 'effective_date'
    ,p_argument_value	=> p_effective_date
    );
  --
  --  Only proceed with the validation if:
  --   a) The current g_old_rec is current.
  --   b) The type has changed.
  --   c) A record is being inserted.
  --
  l_api_updating := per_ast_shd.api_updating
    (p_assessment_type_id 	=> p_assessment_type_id
    ,p_object_version_number	=> p_object_version_number
    );
  --
  if ((l_api_updating and nvl(per_ast_shd.g_old_rec.type,
				hr_api.g_varchar2)
		<> nvl(p_type, hr_api.g_varchar2))
  or
    (NOT l_api_updating)) then
  --
    -- Check that value exists in hr_lookups
    --
    if (p_type IS NOT NULL) then
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date => p_effective_date
        ,p_lookup_type    => 'ASSESSMENT_TYPE'
        ,p_lookup_code    => p_type
        ) then
        hr_utility.set_location(l_proc,10);
        hr_utility.set_message(801,'HR_AST_INVALID_TYPE');
        hr_utility.raise_error;
      end if;
    end if;
   end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,20);
  --
  -- Bug#885806
  -- dbms_output.put_line('AST_total score formula ');
  hr_utility.trace('AST_type ');
end chk_type;
-- ----------------------------------------------------------------------------
-- |---------------------< chk_assessment_type_used >-------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   A check to see if there are any assessments which use this assessment_type
--   .  The table which holds the competence elements isn't checked as there
--  will be rows in here when the assessment_type is set up.
--  This procedure is used before the row can be deleted.
-- Preconditions
--   none
-- In Arguments
--   p_assessment_type_id
--   p_object_version_number
-- Post Success:
--   If the assessment_type isn't being used by a assessment, then it can be
--   removed until the assessment is first removed.
-- Post Failure
--   Processing halts.
-- Access Status
--   Internal processing only
--
Procedure chk_assessment_type_used
 (p_assessment_type_id	in per_assessment_types.assessment_type_id%TYPE
 ,p_object_version_number	in per_assessment_types.object_version_number%TYPE
  ) is
--
  l_proc	varchar2(72) := g_package || 'chk_assessment_type_used';
  l_exists	varchar2(1);
--
-- Define a cursor to get an assessment which uses this assessment_type.
--
  cursor csr_assessment_type_usage is
    select null
    from per_assessments
    where assessment_type_id = p_assessment_type_id;
--
Begin
  hr_utility.set_location('Entering '||l_proc,1);
  --
  -- Check that assessment_type is not referenced by an assessment
  --
  open csr_assessment_type_usage;
  fetch csr_assessment_type_usage into l_exists;
  if csr_assessment_type_usage%found then
    close csr_assessment_type_usage;
    hr_utility.set_location (l_proc, 5);
    hr_utility.set_message (801, 'HR_51579_AST_REF_BY_ASSESS');
    hr_utility.raise_error;
  end if;
  close csr_assessment_type_usage;
  --
end chk_assessment_type_used;

-------------------------------<chk_available_flag>----------------------+
--------------------------------------------------------------------------+
--  Description:
--   Validate available_flag
--   against the HR_LOOKUP where lookup_type = 'TEMPLATE_AVAILABILITY_FLAG'.
--

--  Pre_conditions:
--   - Valid p_assessment_type_id

--  In Arguments:
--    p_available_flag
--    p_effective_date
--    p_object_version_number

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--   available_flag  value is not validated against lookup 'PROFICIENCY_SOURCE'.

--  Access Status
--    Internal Table Handler Use Only.


-- Access Status:
--   Internal Table Handler Use Only.
--

Procedure chk_available_flag
 (
  p_available_flag	  in    per_assessment_types.available_flag%TYPE
 ,p_effective_date		in 	date
 ,p_object_version_number         in	per_assessment_types.object_version_number%TYPE
 ,p_assessment_type_id     in      per_assessment_types.assessment_type_id%TYPE
 )
is
--
  l_proc	varchar2(72):=g_package||'chk_available_flag';
  l_api_updating	boolean;
--
begin
  -- Bug#885806
  --  dbms_output.put_line('Inside the chk_display_assessment_comments procedure');
  hr_utility.trace('Inside the chk_available_flag procedure');
  hr_utility.set_location('Entering:'|| l_proc, 1);


  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	 	=> l_proc
    ,p_argument		=> 'effective_date'
    ,p_argument_value	=> p_effective_date
    );
  --
  -- Only proceed with the validation if :
  --  a) The current g_old_rec is current
  --  b) The value has changed.
  --  c) A record is being inserted
  --

  l_api_updating := per_ast_shd.api_updating
      (p_assessment_type_id  => p_assessment_type_id
       ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and nvl(per_ast_shd.g_old_rec.available_flag,
				 hr_api.g_varchar2)
  		<> nvl(p_available_flag, hr_api.g_varchar2))
  or
    (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Check the value in p_available_flag exists in hr_lookups
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date	=> p_effective_date
      ,p_lookup_type	=> 'TEMPLATE_AVAILABILITY_FLAG'
      ,p_lookup_code	=> p_available_flag
      ) then
      hr_utility.set_location(l_proc, 10);
      hr_utility.set_message(800,'HR_AVAIL_FLAG_INVAL');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 15);
  end if;
end chk_available_flag;
--
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
  (p_rec in per_ast_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.assessment_type_id is not null) and (
    nvl(per_ast_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_ast_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.assessment_type_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_ASSESSMENT_TYPES'
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
 (p_rec 		in per_ast_shd.g_rec_type
 ,p_effective_date	in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   --
  -- Call all supporting business operations.  Mapping to the appropiate
  -- Business Rules in perast.bru is provided.
  --
  -- VALIDATE BUSINESS_GROUP_ID
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_BUSINESS_GROUP_ID a
  --
  -- Bug#885806
  -- dbms_output.put_line('AST_bus grp id = '||p_rec.business_group_id);
  hr_utility.trace('AST_bus grp id = '||p_rec.business_group_id);
  --
 if p_rec.business_group_id is not null then

      hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  hr_utility.set_location(' Location:'||l_proc, 10);

  --Validate available_flag
  -- rule Chk_Available_flag
  --
  PER_AST_BUS.chk_available_flag
  (
  p_available_flag        => p_rec.available_flag
 ,p_effective_date        => p_effective_date
 ,p_object_version_number => p_rec.object_version_number
 ,p_assessment_type_id    => p_rec.assessment_type_id
 );
  --
  --
  -- VALIDATE TYPE
  --    Rule CHK_TYPE
  --
 per_ast_bus.chk_type
 (p_type 	=>  p_rec.type
,p_assessment_type_id	=> p_rec.assessment_type_id
,p_effective_date			=> p_effective_date
,p_object_version_number	=> p_rec.object_version_number
 );
  --
  --
  -- VALIDATE NAME
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_NAME a
  --
  per_ast_bus.chk_name
    (p_name 			=> p_rec.name
    ,p_assessment_type_id	=> p_rec.assessment_type_id
    ,p_type                 => p_rec.type
    ,p_business_group_id	=> p_rec.business_group_id
    ,p_object_version_number	=> p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 15);
  --
  --
  -- VALIDATE DISPLAY_ASSESSMENT_COMMENTS
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK DISPLAY_ASSESSMENT_COMMENTS a
  --
  per_ast_bus.chk_disp_assess_comments
    (p_display_assessment_comments	=> p_rec.display_assessment_comments
    ,p_assessment_type_id		=> p_rec.assessment_type_id
    ,p_effective_date			=> p_effective_date
    ,p_object_version_number		=> p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc,20);
  --
  --
  -- VALIDATE ACTIVE
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_DATE_FROM_TO
  --
  per_ast_bus.chk_date_from_to
   (p_date_from             =>    p_rec.date_from
   ,p_date_to               =>    p_rec.date_to
   ,p_assessment_type_id    =>    p_rec.assessment_type_id
   ,p_business_group_id     =>    p_rec.business_group_id
   ,p_object_version_number =>    p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location (l_proc, 25);
  --
  -- Bug#885806
  -- dbms_output.put_line('About to validate assessment_classification');
  hr_utility.trace('About to validate assessment_classification');
  --
  -- VALIDATE ASSESSMENT_CLASSIFICATION
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_ASSESSMENT_CLASSIFICATION a
  --
  per_ast_bus.chk_assessment_classification
    (p_assessment_classification	=> p_rec.assessment_classification
    ,p_business_group_id 	        => p_rec.business_group_id
    ,p_effective_date			=> p_effective_date
    ,p_assessment_type_id 		=> p_rec.assessment_type_id
    ,p_object_version_number		=> p_rec.object_version_number
    );
  --
  hr_utility.set_location (l_proc, 30);
  --
  --
  -- Bug#885806
  -- dbms_output.put_line('About to validate rating_scale_id');
  hr_utility.trace('About to validate rating_scale_id');
  --
  -- VALIDATE RATING_SCALE_ID
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_RATING_SCALE_ID
  --
  per_ast_bus.chk_rating_scale_id
    (p_rating_scale_id		=> p_rec.rating_scale_id
    ,p_business_group_id	=> p_rec.business_group_id
    ,p_assessment_type_id       => p_rec.assessment_type_id
    ,p_assessment_classification=> p_rec.assessment_classification
    ,p_object_version_number    => p_rec.object_version_number
    ,p_weighting_classification => p_rec.weighting_classification
    );
  --
  hr_utility.set_location (l_proc, 35);
  --
  --
  -- VALIDATE WEIGHTING_SCALE_ID
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_WEIGHTING_SCALE_ID a, c
  --
  per_ast_bus.chk_weighting_scale_id
    (p_weighting_scale_id	 => p_rec.weighting_scale_id
    ,p_business_group_id	 => p_rec.business_group_id
    ,p_assessment_type_id        => p_rec.assessment_type_id
    ,p_assessment_classification => p_rec.assessment_classification
    ,p_object_version_number     => p_rec.object_version_number
    );
  --
  hr_utility.set_location (l_proc, 40);
  --
  --
  -- VALIDATE WEIGHTING_SCALE_COMMENT
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_WEIGHTING_SCALE_COMMENT a
  --
  per_ast_bus.chk_weighting_scale_comment
    (p_weighting_scale_comment	=> p_rec.weighting_scale_comment
    ,p_weighting_scale_id	=> p_rec.weighting_scale_id
    );
  --
  hr_utility.set_location (l_proc, 45);
  --
  --
  -- VALIDATE RATING_SCALE_COMMENT
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_RATING_SCALE_COMMENT a
  --
  per_ast_bus.chk_rating_scale_comment
    (p_rating_scale_comment	=> p_rec.rating_scale_comment
    ,p_rating_scale_id		=> p_rec.rating_scale_id
    );
  --
  hr_utility.set_location (l_proc, 50);
  --
  --
  -- VALIDATE WEIGHTING_CLASSIFICATION
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_WEIGHTING_CLASSIFICATION a, b, c
  --
  per_ast_bus.chk_weighting_classification
    (p_weighting_classification	=> p_rec.weighting_classification
    ,p_weighting_scale_id	=> p_rec.weighting_scale_id
    ,p_assessment_classification=> p_rec.assessment_classification
    );
  --
  hr_utility.set_location (l_proc, 55);
  --
  -- Bug#885806
  -- dbms_output.put_line('About to validate line_score_formula');
  hr_utility.trace('About to validate line_score_formula');
  --
  -- VALIDATE LINE_SCORE_FORMULA
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_LINE_SCORE_FORMULA a
  --
  per_ast_bus.chk_line_score_formula
    (p_line_score_formula	=> p_rec.line_score_formula
    ,p_assessment_type_id	=> p_rec.assessment_type_id
    ,p_effective_date		=> p_effective_date
    ,p_object_version_number	=> p_rec.object_version_number
    );
  --
  hr_utility.set_location (l_proc, 60);
  --
  -- Bug#885806
  -- dbms_output.put_line('About to validate TOTAL_score_formula');
  hr_utility.trace('About to validate TOTAL_score_formula');
  --
  -- VALIDATE TOTAL_SCORE_FORMULA
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_TOTAL_SCORE_FORMULA a
  --
  per_ast_bus.chk_total_score_formula
    (p_total_score_formula	=> p_rec.total_score_formula
    ,p_assessment_type_id       => p_rec.assessment_type_id
    ,p_effective_date		=> p_effective_date
    ,p_object_version_number	=> p_rec.object_version_number
    );
  --
  hr_utility.set_location (l_proc, 65);
  --
  --
  -- Bug#885806
  -- dbms_output.put_line('About to validate flex');
  hr_utility.trace('About to validate flex');
  --
  -- Call Descriptive Flexfield Validation routines
  --
  per_ast_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location (l_proc, 75);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 85);
  -- Bug#885806
  -- dbms_output.put_line('finished insert_validate');
  hr_utility.trace('finished insert_validate');
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec in per_ast_shd.g_rec_type
  ,p_effective_date in date
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations.  Mapping to the appropiate
  -- Business Rules in perast.bru is provided.
  --
  --
 if p_rec.business_group_id is not null then
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  --Validate available_flag
  -- rule Chk_Available_flag
  --
  PER_AST_BUS.chk_available_flag
  (
  p_available_flag        => p_rec.available_flag
 ,p_effective_date        => p_effective_date
 ,p_object_version_number => p_rec.object_version_number
 ,p_assessment_type_id    => p_rec.assessment_type_id
 );
  --
  -- VALIDATE TYPE
  --    Rule CHK_TYPE
  --
 per_ast_bus.chk_type
 (p_type 	=>  p_rec.type
,p_assessment_type_id	=> p_rec.assessment_type_id
,p_effective_date			=> p_effective_date
,p_object_version_number	=> p_rec.object_version_number
 );
 --

  -- VALIDATE CHK_NON_UPDATABLE_ARGS
  --     Check those columns which cannot be updated have not changed.
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_BUSINESS_GROUP_ID a
  --
  per_ast_bus.chk_non_updateable_args
    (p_rec	=>  p_rec);
  --
  --
  -- VALIDATE NAME
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_NAME a
  --
  per_ast_bus.chk_name
    (p_name                     => p_rec.name
    ,p_assessment_type_id       => p_rec.assessment_type_id
    ,p_type                     => p_rec.type
    ,p_business_group_id        => p_rec.business_group_id
    ,p_object_version_number	=> p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 15);
  --
  --
  -- VALIDATE DISPLAY_ASSESSMENT_COMMENTS
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK DISPLAY_ASSESSMENT_COMMENTS a
  --
  per_ast_bus.chk_disp_assess_comments
    (p_display_assessment_comments      => p_rec.display_assessment_comments
    ,p_assessment_type_id		=> p_rec.assessment_type_id
    ,p_effective_date                   => p_effective_date
    ,p_object_version_number		=> p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc,20);
  --
  --
  -- VALIDATE ACTIVE
  --    Business Rule Mapping
  --    =====================
  --    Rule CHK_DATE_FROM_TO
  --
  per_ast_bus.chk_date_from_to
   (p_date_from             =>    p_rec.date_from
   ,p_date_to               =>    p_rec.date_to
   ,p_assessment_type_id    =>    p_rec.assessment_type_id
   ,p_business_group_id     =>    p_rec.business_group_id
   ,p_object_version_number =>    p_rec.object_version_number
  );
  --
  -- VALIDATE ASSESSMENT_CLASSIFICATION
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_ASSESSMENT_CLASSIFICATION
  --
  per_ast_bus.chk_assessment_classification
    (p_assessment_classification	=> p_rec.assessment_classification
    ,p_business_group_id 	        => p_rec.business_group_id
    ,p_effective_date			=> p_effective_date
    ,p_assessment_type_id 		=> p_rec.assessment_type_id
    ,p_object_version_number		=> p_rec.object_version_number
    );
  --
  hr_utility.set_location (l_proc, 30);
  -- VALIDATE RATING_SCALE_ID
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_RATING_SCALE_ID
  --
  per_ast_bus.chk_rating_scale_id
    (p_rating_scale_id		=> p_rec.rating_scale_id
    ,p_business_group_id	=> p_rec.business_group_id
    ,p_assessment_type_id	=> p_rec.assessment_type_id
    ,p_assessment_classification=> p_rec.assessment_classification
    ,p_object_version_number	=> p_rec.object_version_number
    ,p_weighting_classification => p_rec.weighting_classification
    );
  --
  hr_utility.set_location (l_proc, 15);
  --
  --
  -- VALIDATE WEIGHTING_SCALE_ID
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_WEIGHTING_SCALE_ID a, c
  --
  per_ast_bus.chk_weighting_scale_id
    (p_weighting_scale_id	 => p_rec.weighting_scale_id
    ,p_business_group_id	 => p_rec.business_group_id
    ,p_assessment_type_id        => p_rec.assessment_type_id
    ,p_assessment_classification => p_rec.assessment_classification
    ,p_object_version_number     => p_rec.object_version_number
    );
  --
  hr_utility.set_location (l_proc, 25);
  --
  --
  -- VALIDATE WEIGHTING_SCALE_COMMENT
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_WEIGHTING_SCALE_COMMENT a
  --
  per_ast_bus.chk_weighting_scale_comment
    (p_weighting_scale_comment  => p_rec.weighting_scale_comment
    ,p_weighting_scale_id       => p_rec.weighting_scale_id
    );
  --
  hr_utility.set_location (l_proc, 30);
  --
  --
  -- VALIDATE RATING_SCALE_COMMENT
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_RATING_SCALE_COMMENT a
  --
  per_ast_bus.chk_rating_scale_comment
    (p_rating_scale_comment     => p_rec.rating_scale_comment
    ,p_rating_scale_id          => p_rec.rating_scale_id
    );
  --
  hr_utility.set_location (l_proc, 35);
  --
  --
  -- VALIDATE WEIGHTING_CLASSIFICATION
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_WEIGHTING_CLASSIFICATION a, b, c
  --
  per_ast_bus.chk_weighting_classification
    (p_weighting_classification => p_rec.weighting_classification
    ,p_weighting_scale_id       => p_rec.weighting_scale_id
    ,p_assessment_classification=> p_rec.assessment_classification
    );
  --
  hr_utility.set_location (l_proc, 40);
  --
  --
  -- VALIDATE LINE_SCORE_FORMULA
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_LINE_SCORE_FORMULA a
  --
  per_ast_bus.chk_line_score_formula
    (p_line_score_formula       => p_rec.line_score_formula
    ,p_assessment_type_id	=> p_rec.assessment_type_id
    ,p_effective_date           => p_effective_date
    ,p_object_version_number  	=> p_rec.object_version_number
    );
  --
  hr_utility.set_location (l_proc, 45);
  --
  --
  -- VALIDATE TOTAL_SCORE_FORMULA
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_TOTAL_SCORE_FORMULA a
  --
  per_ast_bus.chk_total_score_formula
    (p_total_score_formula      => p_rec.total_score_formula
    ,p_assessment_type_id	=> p_rec.assessment_type_id
    ,p_effective_date           => p_effective_date
    ,p_object_version_number 	=> p_rec.object_version_number
    );
  --
  hr_utility.set_location (l_proc, 50);
  --
  --
  -- Call Discriptive Flexfield Validation routines.
  --
  per_ast_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location (l_proc, 55);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_ast_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations and show business rule mapping.
  --
  -- VALIDATE ASSESSMENT_TYPE_USED
  --   Business Rule Mapping
  --   =====================
  --   CHK_ASSESSMENT_TYPE_USED a
  --
  per_ast_bus.chk_assessment_type_used
    (p_assessment_type_id 	=> p_rec.assessment_type_id
    ,p_object_version_number	=> p_rec.object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
         (  p_assessment_type_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups  pbg,
                 per_assessment_types pat
          where  pat.assessment_type_id = p_assessment_type_id
            and  pbg.business_group_id  = pat.business_group_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'assessment_type_id',
                              p_argument_value => p_assessment_type_id );
--
   if nvl(g_assessment_type_id, hr_api.g_number) = p_assessment_type_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
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
    g_assessment_type_id:= p_assessment_type_id;
    g_legislation_code := l_legislation_code;
  end if;
  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End return_legislation_code;
--
end per_ast_bus;


/
