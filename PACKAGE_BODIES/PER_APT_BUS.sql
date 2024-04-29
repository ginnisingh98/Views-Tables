--------------------------------------------------------
--  DDL for Package Body PER_APT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APT_BUS" as
/* $Header: peaptrhi.pkb 120.4.12010000.7 2010/02/09 15:06:58 psugumar ship $ */

-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+

g_package  varchar2(33)	:= '  per_apt_bus.';  -- Global package name

-- The following two global variables are only to be used by the
-- return_legislation_code function.

g_appraisal_template_id number default null;
g_legislation_code varchar2(150) default null;
-- -------------------------------------------------------------------------+
-- |----------------------< chk_non_updateable_args >-----------------------|
-- -------------------------------------------------------------------------+

Procedure chk_non_updateable_args(p_rec in per_apt_shd.g_rec_type) is

  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema

  if not per_apt_shd.api_updating
                (p_appraisal_template_id    => p_rec.appraisal_template_id
                ,p_object_version_number    => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;

  hr_utility.set_location(l_proc, 6);

  if p_rec.business_group_id <> per_apt_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 11);

  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end chk_non_updateable_args;

----------------------------------------------------------------------------+
------------------------------------<chk_name>------------------------------+
----------------------------------------------------------------------------+

--  Description:
--   - Validates that the appraisal template name has been entered as it
--     is a mandatory column
--   - Validates that the name is unique within business group

--  Pre_conditions:
--  Valid business_group_id

--  In Arguments:
--    p_appraisal_template_id
--    p_name
--    p_object_vesrion_number
--    p_business_group_id

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	-- name is not entered
--	-- name is not unique within business group

--  Access Status
--    Internal Table Handler Use Only.


procedure chk_name
(p_appraisal_template_id     in      per_appraisal_templates.appraisal_template_id%TYPE
,p_name			     in	     per_appraisal_templates.name%TYPE
,p_object_version_number     in	     per_appraisal_templates.object_version_number%TYPE
,p_business_group_id	     in	     per_appraisal_templates.business_group_id%TYPE
)
is

	l_exists	     varchar2(1);
    l_business_group_id	       per_appraisal_templates.business_group_id%TYPE;
	l_api_updating	     boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_name';


	-- Cursor to check if name is unique

	Cursor csr_name_unique
          is
	select  business_group_id
	from	per_appraisal_templates apt
	where   (   (p_appraisal_template_id is null)
		  or(p_appraisal_template_id <> apt.appraisal_template_id)
		)
	and	apt.name = p_name and
    ( business_group_id is null or p_business_group_id is null or  business_group_id = p_business_group_id);
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);



  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for name has changed

   l_api_updating := per_apt_shd.api_updating
         (p_appraisal_template_id  => p_appraisal_template_id
         ,p_object_version_number  => p_object_version_number);

  if (  (l_api_updating and (per_apt_shd.g_old_rec.name
		        <> nvl(p_name,hr_api.g_varchar2))
         ) or
        (NOT l_api_updating)
      ) then

  	-- check if the user has entered a name
  	-- It is mandatory column.

	hr_utility.set_location(l_proc, 3);
     	if p_name is null then
      		hr_utility.set_message(801,'HR_51907_APT_NAME_MANDATORY');
       		hr_utility.raise_error;
     	end if;

	hr_utility.set_location(l_proc, 4);
        open csr_name_unique;
        fetch csr_name_unique into l_business_group_id;
	if csr_name_unique%found then
            close csr_name_unique;
            hr_utility.set_message(801,'HR_51908_APT_NAME_NOT_UNIQUE');
            hr_utility.raise_error;
	end if;
        close csr_name_unique;
   end if;

   hr_utility.set_location(l_proc, 5);

  hr_utility.set_location('Leaving: '|| l_proc, 10);

end chk_name;


-- ------------------------------------------------------------------------+
-- |------------------------< chk_template_dates >-------------------------|
-- ------------------------------------------------------------------------+

-- Description :
--    Perform check to make sure that :
--	- Validates that the date_from and date_to are valid if either of
--	  then is not null
--	- Validates that the date_from is less then or equal to date_to
--      - Validates that date_to is later or equal to date_from

--	- if updating then Validates that the template date_from and date_to do not
--	  invalidate the appraisal ie. template date_from has to be less than or equal
--        to appraisal start date and template date_to has to be greater
--	  than or equal to appraisal end date

-- Pre-requisites
--  Valid appraisal_template_id

-- In Prameters
--   p_date_from
--   p_date_to
--   p_appraisal_template_id
--   p_object_version_number

-- Post Success
--   Processing continues.

-- Post Failure
-- An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - date_from and date_to are not set, if either of them is set
--      - date_from is less than or equal to date_to
--	- date_to is greater than or equal to date_from
--      - Template dates do not invalidate the Appraisal

-- Access Status
--  Internal Development Use Only

Procedure chk_template_dates
  (p_date_from			in per_appraisal_templates.date_from%TYPE
  ,p_date_to			in per_appraisal_templates.date_to%TYPE
  ,p_appraisal_template_id 	in per_appraisal_templates.appraisal_template_id%TYPE
  ,p_object_version_number      in per_appraisal_templates.object_version_number%TYPE
  ) is

  l_exists             	varchar2(1);
  l_api_updating	boolean;
  l_proc        	varchar2(72):=g_package||'chk_template_dates';

	Cursor csr_check_dates_in_apr is
    	select 	'Y'
    	from   	per_appraisals apr
    	where	(   apr.appraisal_period_start_date < nvl(p_date_from,hr_api.g_sot)
   		 or apr.appraisal_period_end_date > nvl(p_date_to,hr_api.g_eot)
		)
    	and	apr.appraisal_template_id = p_appraisal_template_id;


begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

   -- Check if date from is set to null when date to exists
   if ( (p_date_from is null) AND (p_date_to is not null) )
   then
       hr_utility.set_message(800, 'HR_52247_APT_DATE_FROM_NULL');
       hr_utility.raise_error;
   end if;
   -- Date From has to be <= date to, else error.
   if (  nvl(p_date_from,hr_api.g_sot) >  nvl(p_date_to,hr_api.g_eot) )
   then
       hr_utility.set_message(801, 'HR_51909_APT_DATE_FROM_BEFORE');
       hr_utility.raise_error;
   end if;
   -- Date To has to be >= date to, else error.
   if (  nvl(p_date_to,hr_api.g_eot) <  nvl(p_date_from,hr_api.g_sot) )
   then
       hr_utility.set_message(801, 'HR_51910_APT_DATE_TO_AFTER');
       hr_utility.raise_error;
   end if;

   l_api_updating := per_apt_shd.api_updating
         (p_appraisal_template_id  => p_appraisal_template_id
         ,p_object_version_number  => p_object_version_number);

  -- Only continue if:
  -- a) The current g_old_rec is current and
  -- b) The value for dates have changed

  if (   ((l_api_updating) and (per_apt_shd.g_old_rec.date_from <> nvl(p_date_from,hr_api.g_date)) )
      or ((l_api_updating) and (per_apt_shd.g_old_rec.date_to   <> nvl(p_date_to,hr_api.g_date))   )
     ) then

     -- only continue if we are updating and the dates have changed from the
     -- previous values

     -- Apart from having the standard date validation check ie.date from <= date_to
     -- and date_to >= date_from, need to make sure that the user cannot change a date
     -- so as to invalidate the dates on the appraisals.
     -- Check dates against appraisals

     open csr_check_dates_in_apr;
     fetch csr_check_dates_in_apr into l_exists;
     if csr_check_dates_in_apr%found then
       hr_utility.set_location(l_proc, 3);
       -- dates out of range
       close csr_check_dates_in_apr ;
       hr_utility.set_message(801,'HR_51911_APT_INVALIDATE_APR');
       hr_utility.raise_error;
     end if;
     close csr_check_dates_in_apr;

  end if;

 hr_utility.set_location('Leaving:'|| l_proc, 10);

end chk_template_dates;

----------------------------------------------------------------------------+
------------------------------<chk_assessment_type>-------------------------+
----------------------------------------------------------------------------+

--  Description:
--   - Validates that the assessment type exists and is within the same business
--     group as that of appraisal template
--   - Validates that the assessment type exists as of the template dates

--  Pre_conditions:


--  In Arguments:
--    p_appraisal_template_id
--    p_object_version_number
--    p_business_group_id
--    p_assessment_type_id

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	-- appraisal_template_id is not set
--	-- assessment type does not exist
--      -- assessment type exists but not with the same business group
--	-- appraisal type exists but not as of the template dates

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_assessment_type
(p_appraisal_template_id     in      per_appraisal_templates.appraisal_template_id%TYPE
,p_object_version_number     in	     per_appraisal_templates.object_version_number%TYPE
,p_assessment_type_id	     in	     per_appraisal_templates.assessment_type_id%TYPE
,p_date_from		     in	     per_appraisal_templates.date_from%TYPE
,p_date_to		     in	     per_appraisal_templates.date_to%TYPE
,p_business_group_id	     in	     per_appraisal_templates.business_group_id%TYPE
)
is

	l_exists	     varchar2(1);
	l_api_updating	     boolean;
    l_proc               varchar2(72)  :=  g_package||'chk_assessment_type';
    l_business_group_id  per_appraisal_templates.business_group_id%TYPE;


	-- Cursor to check if appraisal exists

	Cursor csr_appraisal_type_exists
          is
	select  business_group_id
	from	per_assessment_types
	where   assessment_type_id = p_assessment_type_id
    and type = 'COMPETENCE';

	-- Cursor to check if the assessment type is
	-- valid as of appraisal template dates
-- Bug 3947233 Starts Here
-- Desc: Modified the p_date_from nvl into g_eot from g_sot and
--       p_date_to nvl into g_sot from g_eot.
   	Cursor csr_assessment_type_valid
          is
	select  'Y'
	from	per_assessment_types
	where   assessment_type_id = p_assessment_type_id
	and     nvl(date_from,hr_api.g_sot) <= nvl(p_date_from,hr_api.g_eot)
	and     nvl(date_to,hr_api.g_eot)   >= nvl(p_date_to,hr_api.g_sot) ;
-- Bug 3947233 Ends Here

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Check mandatory parameters have been set


  hr_utility.set_location('Entering:'|| l_proc, 2);

  l_api_updating := per_apt_shd.api_updating
         (p_appraisal_template_id  => p_appraisal_template_id
         ,p_object_version_number  => p_object_version_number);

  -- Only continue if:
  -- a) The current g_old_rec is current and
  -- b) The value for assessment type has changed

   if (  (l_api_updating
          and (nvl(per_apt_shd.g_old_rec.assessment_type_id,hr_api.g_number)
		        <> nvl(p_assessment_type_id,hr_api.g_number))
         ) or
        (NOT l_api_updating)
      ) then

     if p_assessment_type_id is not null then
        open csr_appraisal_type_exists;
        fetch csr_appraisal_type_exists into l_business_group_id;
	if csr_appraisal_type_exists%notfound then
            close csr_appraisal_type_exists;
            hr_utility.set_message(801,'HR_51912_APT_AST_NOT_EXIST');
            hr_utility.raise_error;
	end if;
        close csr_appraisal_type_exists;

	-- check if assessment is in the same business group

        if nvl(l_business_group_id,-1) <> nvl(p_business_group_id,-1) then
	       hr_utility.set_message(800,'HR_51913_APT_AST_DIFF_BUS_GRP');
	       hr_utility.raise_error;
        end if;

	-- check if assessment type exists with the date range of the
	-- appraisal template

	open csr_assessment_type_valid;
	fetch csr_assessment_type_valid into l_exists;
	if csr_assessment_type_valid%notfound then
            close csr_assessment_type_valid;
            hr_utility.set_message(801,'HR_51914_APT_AST_NOT_DATE');
            hr_utility.raise_error;
	end if;
        close csr_assessment_type_valid;
     end if;

   end if;

   hr_utility.set_location(l_proc, 4);

  hr_utility.set_location('Leaving: '|| l_proc, 10);

end chk_assessment_type;

----------------------------------------------------------------------------+
------------------------------<chk_objective_asmnt_type>-------------------------+
----------------------------------------------------------------------------+

--  Description:
--   - Validates that the objective assessment type exists and is within the same business
--     group as that of appraisal template
--   - Validates that the objective assessment type exists as of the template dates

--  Pre_conditions:


--  In Arguments:
--    p_appraisal_template_id
--    p_object_version_number
--    p_business_group_id
--    p_objective_asmnt_type_id

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	-- appraisal_template_id is not set
--	-- objective assessment type does not exist
--      -- objective assessment type exists but not with the same business group
--	-- appraisal type exists but not as of the template dates

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_objective_asmnt_type
(p_appraisal_template_id     in      per_appraisal_templates.appraisal_template_id%TYPE
,p_object_version_number     in	     per_appraisal_templates.object_version_number%TYPE
,p_objective_asmnt_type_id	     in	     per_appraisal_templates.objective_asmnt_type_id%TYPE
,p_date_from		     in	     per_appraisal_templates.date_from%TYPE
,p_date_to		     in	     per_appraisal_templates.date_to%TYPE
,p_business_group_id	     in	     per_appraisal_templates.business_group_id%TYPE
)
is

	l_exists	     varchar2(1);
	l_api_updating	     boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_objective_asmnt_type';
        l_business_group_id  per_appraisal_templates.business_group_id%TYPE;


	-- Cursor to check if appraisal exists

	Cursor csr_appraisal_type_exists
          is
	select  business_group_id
	from	per_assessment_types
	where   assessment_type_id = p_objective_asmnt_type_id
    and type = 'OBJECTIVE';

	-- Cursor to check if the assessment type is
	-- valid as of appraisal template dates
-- Bug 3947233 Starts Here
-- Desc: Modified the p_date_from nvl into g_eot from g_sot and
--       p_date_to nvl into g_sot from g_eot.
   	Cursor csr_assessment_type_valid
          is
	select  'Y'
	from	per_assessment_types
	where   assessment_type_id = p_objective_asmnt_type_id
	and     nvl(date_from,hr_api.g_sot) <= nvl(p_date_from,hr_api.g_eot)
	and     nvl(date_to,hr_api.g_eot)   >= nvl(p_date_to,hr_api.g_sot) ;
-- Bug 3947233 Ends Here

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);



  l_api_updating := per_apt_shd.api_updating
         (p_appraisal_template_id  => p_appraisal_template_id
         ,p_object_version_number  => p_object_version_number);

  -- Only continue if:
  -- a) The current g_old_rec is current and
  -- b) The value for assessment type has changed

   if (  (l_api_updating
          and (nvl(per_apt_shd.g_old_rec.objective_asmnt_type_id,hr_api.g_number)
		        <> nvl(p_objective_asmnt_type_id,hr_api.g_number))
         ) or
        (NOT l_api_updating)
      ) then

     if p_objective_asmnt_type_id is not null then
        open csr_appraisal_type_exists;
        fetch csr_appraisal_type_exists into l_business_group_id;
	if csr_appraisal_type_exists%notfound then
            close csr_appraisal_type_exists;
            hr_utility.set_message(800,'HR_APT_OAST_NOT_EXIST');
            hr_utility.raise_error;
	end if;
        close csr_appraisal_type_exists;

	-- check if assessment is in the same business group

        if nvl(l_business_group_id,-1) <> nvl(p_business_group_id,-1) then
	       hr_utility.set_message(800,'HR_APT_OAST_DIFF_BUS_GRP');
	       hr_utility.raise_error;
        end if;

	-- check if assessment type exists with the date range of the
	-- appraisal template

	open csr_assessment_type_valid;
	fetch csr_assessment_type_valid into l_exists;
	if csr_assessment_type_valid%notfound then
            close csr_assessment_type_valid;
            hr_utility.set_message(800,'HR_APT_OAST_NOT_DATE');
            hr_utility.raise_error;
	end if;
        close csr_assessment_type_valid;
     end if;

   end if;

   hr_utility.set_location(l_proc, 4);

  hr_utility.set_location('Leaving: '|| l_proc, 10);

end chk_objective_asmnt_type;

----------------------------------------------------------------------------+
-----------------------------<chk_question_template>------------------------+
----------------------------------------------------------------------------+

--  Description:
--   - Validates that the questionnaire template exists
--   - Validates that if the questionnaire template, it is in the correct
--     business group
--   - Validates that the questionnaire template cannot be updated if the
--     questuionnaire answer set, or in an appraisal

--  Pre_conditions:

--  In Arguments:
--    p_object_version_number
--    p_questionnaire_template_id
--    p_business_group_id
--    p_appraisal_template_id

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	-- quationnaire_template_id does not exist
--	-- questionnaire template exists but is not of type 'APPRAISAL'
--	-- questionnaire template exists and is used in appraisals which is further
--	-- used in Question and Answers

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_question_template
(p_object_version_number     in	     per_appraisal_templates.object_version_number%TYPE
,p_questionnaire_template_id in	     per_appraisal_templates.questionnaire_template_id%TYPE
,p_business_group_id         in      per_appraisal_templates.business_group_id%TYPE
,p_appraisal_template_id     in      per_appraisal_templates.appraisal_template_id%TYPE
)
is

	l_exists	     varchar2(1);
	l_api_updating	     boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_question_template';
        l_bus_grp_id         hr_questionnaires.business_group_id%TYPE;
	-- l_type		     per_proposal_templates.type%TYPE;

	-- Cursor to check if appraisal exists

	Cursor csr_question_template_exists
          is
	select  business_group_id
	from	hr_questionnaires qsn
	where   qsn.questionnaire_template_id = p_questionnaire_template_id;

	-- Cursor to check if the questionnnaire template
	-- can be updated

   	-- Cursor csr_question_update
        --   is
	-- select  'Y'
	-- from	per_appraisals apr
	--        ,per_assign_proposal_answers apa
	-- where   apr.appraisal_id          = apa.answer_for_key
	-- and     apa.type                  = 'APPRAISAL'
	-- and	apr.appraisal_template_id = p_appraisal_template_id;

        -- Cursor to check if questionnaire template can be updated,
	--  according to hr_quest_answers.
        cursor csr_question_update1 is
          select 'Y'
            from hr_quest_answers hqa
           where hqa.type = 'APPRAISAL'
             and hqa.type_object_id in (select appraisal_id
                                          from per_appraisals apr
                                         where apr.appraisal_template_id
                                               = p_appraisal_template_id);
        -- Cursor to check if questionnaire template can be updated,
        --  according to per_participants.
        cursor csr_question_update2 is
          select 'Y'
            from per_participants par
           where par.participation_in_table = 'PER_APPRAISALS'
             and par.participation_in_id in (select appraisal_id
                                               from per_appraisals apr
                                              where apr.appraisal_template_id
                                               = p_appraisal_template_id);

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  l_api_updating := per_apt_shd.api_updating
         (p_appraisal_template_id  => p_appraisal_template_id
         ,p_object_version_number  => p_object_version_number);

  -- Perfom the following check when inserting only

   if (NOT l_api_updating) then
	-- check if template exists
   if p_questionnaire_template_id is not null then
        hr_utility.set_location(l_proc, 3);
        open csr_question_template_exists;
        fetch csr_question_template_exists into l_bus_grp_id;
        if csr_question_template_exists%notfound then
            close csr_question_template_exists;
            hr_utility.set_message(800,'HR_51915_APT_QST_NOT_EXIST');
            hr_utility.raise_error;
        end if;
        close csr_question_template_exists;

      	-- check if questionnaire template is of type 'APPRAISAL'

	  hr_utility.set_location(l_proc, 6);
--       if l_type <> 'APPRAISAL' then
--	 	    hr_utility.set_message(801,'HR_51916_APT_QST_INV_TYPE');
--	    	hr_utility.raise_error;
--        end if;

        -- Check if business_group_id is correct for the given questionnaire
        -- template id.

        if nvl(l_bus_grp_id,-1) <> nvl(p_business_group_id,-1)  then
           fnd_message.set_name('PER','PER_52470_APT_TEMP_NOT_IN_BG');
           fnd_message.raise_error;
        end if;
     end if;

   end if;

   -- Perform the following check only if updating and the value of
   -- questionnaire_template_id has changed

   -- Added nvl around per_apt_shd.g_old_rec.questionnaire_template_id
   if (  (l_api_updating and ( nvl(per_apt_shd.g_old_rec.questionnaire_template_id, hr_api.g_number)
		        <> nvl(p_questionnaire_template_id,hr_api.g_number)) )
      )
   then

     -- Check if the questionnaire template can be updated first.

     -- hr_utility.set_location(l_proc, 7);
     -- open csr_question_update;
     -- fetch csr_question_update into l_exists;
     -- if csr_question_update%found then
     --    close csr_question_update;
     --    hr_utility.set_message(801,'HR_51917_APT_USED_IN_APR_ANS');
     --    hr_utility.raise_error;
     -- end if;
     -- close csr_question_update;
     open csr_question_update1;
     fetch csr_question_update1 into l_exists;
     if csr_question_update1%found then
        close csr_question_update1;
        fnd_message.set_name('PER','PER_52471_APT_TEMPLATE_IN_USE');
        fnd_message.raise_error;
     end if;
     close csr_question_update1;

     open csr_question_update2;
     fetch csr_question_update2 into l_exists;
     if csr_question_update2%found then
        close csr_question_update2;
        fnd_message.set_name('PER','PER_52471_APT_TEMPLATE_IN_USE');
        fnd_message.raise_error;
     end if;
     close csr_question_update2;



      	-- check if questionnaire template is of type 'APPRAISAL'

	-- hr_utility.set_location(l_proc, 9);
	-- if l_type <> 'APPRAISAL' then
	-- 	hr_utility.set_message(801,'HR_51916_APT_QST_INV_TYPE');
	--        	hr_utility.raise_error;
        -- end if;

        -- check if questionnaire template is of correct business_group

   end if;

   hr_utility.set_location(l_proc, 10);

  hr_utility.set_location('Leaving: '|| l_proc, 11);

end chk_question_template;


----------------------------------------------------------------------------+
-----------------------------<chk_ma_question_template>------------------------+
----------------------------------------------------------------------------+

--  Description:
--   - Validates that the questionnaire template exists
--   - Validates that if the questionnaire template, it is in the correct
--     business group
--   - Validates that the questionnaire template cannot be updated if the
--     questuionnaire answer set, or in an appraisal

--  Pre_conditions:

--  In Arguments:
--    p_object_version_number
--    p_ma_quest_template_id
--    p_business_group_id
--    p_appraisal_template_id

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	-- quationnaire_template_id does not exist
--	-- questionnaire template exists but is not of type 'APPRAISAL'
--	-- questionnaire template exists and is used in appraisals which is further
--	-- used in Question and Answers

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_ma_question_template
(p_object_version_number     in	     per_appraisal_templates.object_version_number%TYPE
,p_ma_quest_template_id in	     per_appraisal_templates.ma_quest_template_id%TYPE
,p_business_group_id         in      per_appraisal_templates.business_group_id%TYPE
,p_appraisal_template_id     in      per_appraisal_templates.appraisal_template_id%TYPE
)
is

	l_exists	     varchar2(1);
	l_api_updating	     boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_ma_question_template';
        l_bus_grp_id         hr_questionnaires.business_group_id%TYPE;
	-- l_type		     per_proposal_templates.type%TYPE;

	-- Cursor to check if appraisal exists

	Cursor csr_question_template_exists
          is
	select  business_group_id
	from	hr_questionnaires qsn
	where   qsn.questionnaire_template_id = p_ma_quest_template_id;

	-- Cursor to check if the questionnnaire template
	-- can be updated

   	-- Cursor csr_question_update
        --   is
	-- select  'Y'
	-- from	per_appraisals apr
	--        ,per_assign_proposal_answers apa
	-- where   apr.appraisal_id          = apa.answer_for_key
	-- and     apa.type                  = 'APPRAISAL'
	-- and	apr.appraisal_template_id = p_appraisal_template_id;

        -- Cursor to check if questionnaire template can be updated,
	--  according to hr_quest_answers.
        cursor csr_question_update1 is
          select 'Y'
            from hr_quest_answers hqa
           where hqa.type = 'APPRAISAL'
             and hqa.type_object_id in (select appraisal_id
                                          from per_appraisals apr
                                         where apr.appraisal_template_id
                                               = p_appraisal_template_id);
        -- Cursor to check if questionnaire template can be updated,
        --  according to per_participants.
        cursor csr_question_update2 is
          select 'Y'
            from per_participants par
           where par.participation_in_table = 'PER_APPRAISALS'
             and par.participation_in_id in (select appraisal_id
                                               from per_appraisals apr
                                              where apr.appraisal_template_id
                                               = p_appraisal_template_id);

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  l_api_updating := per_apt_shd.api_updating
         (p_appraisal_template_id  => p_appraisal_template_id
         ,p_object_version_number  => p_object_version_number);

  -- Perfom the following check when inserting only

   if (NOT l_api_updating) then
	-- check if template exists
     if p_ma_quest_template_id is not null then
        hr_utility.set_location(l_proc, 3);
        open csr_question_template_exists;
        fetch csr_question_template_exists into l_bus_grp_id;
	if csr_question_template_exists%notfound then
            close csr_question_template_exists;
            hr_utility.set_message(800,'HR_APT_MA_QST_NOT_EXIST');
            hr_utility.raise_error;
	end if;
        close csr_question_template_exists;



        -- Check if business_group_id is correct for the given questionnaire
        -- template id.

        if  nvl(l_bus_grp_id,-1) <> nvl(p_business_group_id,-1)  then
           fnd_message.set_name('PER','PER_52470_APT_TEMP_NOT_IN_BG');
           fnd_message.raise_error;
        end if;
     end if;

   end if;


   -- Perform the following check only if updating and the value of
   -- ma_quest_template_id has changed

   -- Added nvl around per_apt_shd.g_old_rec.ma_quest_template_id
   if (  (l_api_updating and ( nvl(per_apt_shd.g_old_rec.ma_quest_template_id, hr_api.g_number)
		        <> nvl(p_ma_quest_template_id,hr_api.g_number)) )
      )
   then

     -- Check if the questionnaire template can be updated first.

     -- hr_utility.set_location(l_proc, 7);
     -- open csr_question_update;
     -- fetch csr_question_update into l_exists;
     -- if csr_question_update%found then
     --    close csr_question_update;
     --    hr_utility.set_message(801,'HR_51917_APT_USED_IN_APR_ANS');
     --    hr_utility.raise_error;
     -- end if;
     -- close csr_question_update;
     open csr_question_update1;
     fetch csr_question_update1 into l_exists;
     if csr_question_update1%found then
        close csr_question_update1;
        fnd_message.set_name('PER','PER_52471_APT_TEMPLATE_IN_USE');
        fnd_message.raise_error;
     end if;
     close csr_question_update1;

     open csr_question_update2;
     fetch csr_question_update2 into l_exists;
     if csr_question_update2%found then
        close csr_question_update2;
        fnd_message.set_name('PER','PER_52471_APT_TEMPLATE_IN_USE');
        fnd_message.raise_error;
     end if;
     close csr_question_update2;




        -- check if questionnaire template is of correct business_group

        if l_bus_grp_id <> p_business_group_id then
           hr_utility.set_message(801,'PER_52470_TEMP_NOT_IN_BG');
           hr_utility.raise_error;
        end if;
   end if;

   hr_utility.set_location(l_proc, 10);

  hr_utility.set_location('Leaving: '|| l_proc, 11);

end chk_ma_question_template;

----------------------------------------------------------------------------+
-------------------------------<chk_rating_scale>---------------------------+
----------------------------------------------------------------------------+

--  Description:
--   - Validates that the rating scale exists and is within the same
--     business group as that of appraisal template
--   - Validates that if the rating scale, it is of type 'PERFORMANCE'
--   - Validates that the rating scale cannot be updated if overall_rating_id
--     is set
--   - Validates that the rating scale cannot be updated if the
--     appraisal template is used in an Appraisal which in turn is used in
--     performace ratings table (per_performance_ratings).

--  Pre_conditions:

--  In Arguments:
--    p_appraisal_template_id
--    p_object_version_number
--    p_business_group_id
--    p_questionnaire_template_id

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	-- rating scale does not exist
--      -- rating scale exists but not with the same business group
--	-- rating scale exists but is not of type 'PERFORMANCE'
--	-- overall_rating of the appraisal is set and the user try's
--	   to update the raring scale
--	-- rating scale  existsand is used in appraisals which is further
--	-- used in performance ratings

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_rating_scale
(p_appraisal_template_id     in      per_appraisal_templates.appraisal_template_id%TYPE
,p_object_version_number     in	     per_appraisal_templates.object_version_number%TYPE
,p_rating_scale_id	     in	     per_appraisal_templates.rating_scale_id%TYPE
,p_business_group_id	     in	     per_appraisal_templates.business_group_id%TYPE default null
)
is

	l_exists	     varchar2(1);
	l_api_updating	     boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_rating_scale';
	l_type		     per_rating_scales.type%TYPE;
     l_business_group_id  per_appraisal_templates.business_group_id%TYPE;
	l_overall_performance_level_id per_appraisals.overall_performance_level_id%TYPE;


	-- Cursor to check if rating scale exists and get
	-- the type

	Cursor csr_rating_scale_exists
          is
	select  business_group_id,type
	from	per_rating_scales
	where   rating_scale_id = p_rating_scale_id;

	-- Cursor to check if the appraisal template
	-- is used in appraisal and the overall_performance_level_id
	-- is set on the appraisal

	Cursor csr_rating_scale_update1
          is
	select  overall_performance_level_id
	from	per_appraisals
	where	appraisal_template_id = p_appraisal_template_id;

	-- Cursor to check if the appraisal template
	-- is used in appraisal which is further used in
	-- performance ratings

   	Cursor csr_rating_scale_update2
          is
	select  'Y'
	from	per_appraisals apr
	       ,per_performance_ratings prt
	where   prt.appraisal_id	  = apr.appraisal_id
	and	apr.appraisal_template_id = p_appraisal_template_id;


begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Check mandatory parameters have been set

  -- ngundura change done for pa requirements
/*    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
*/
  -- ngundura end of changes

  hr_utility.set_location('Entering:'|| l_proc, 2);

  l_api_updating := per_apt_shd.api_updating
         (p_appraisal_template_id  => p_appraisal_template_id
         ,p_object_version_number  => p_object_version_number);

  -- Only continue if:
  -- a) The current g_old_rec is current and
  -- b) The value for rating scale has changed

   if (NOT l_api_updating) then
     if p_rating_scale_id is not null then
        hr_utility.set_location(l_proc, 3);
        open csr_rating_scale_exists;
        fetch csr_rating_scale_exists into l_business_group_id,l_type;
	if csr_rating_scale_exists%notfound then
            close csr_rating_scale_exists;
            hr_utility.set_message(801,'HR_51928_APT_RSC_NOT_EXIST');
            hr_utility.raise_error;
	end if;
        close csr_rating_scale_exists;

	-- check if rating scale is in the same business group

	hr_utility.set_location(l_proc, 5);
        if nvl(l_business_group_id,-1) <> nvl(p_business_group_id,-1)   then
	if(l_business_group_id is not null) then
	       hr_utility.set_message(801,'HR_51929_APT_RSC_DIFF_BUS_GRP');
	       hr_utility.raise_error;
	end if;
        end if;

      	-- check if rating scale template is of type 'PERFORMANCE'

	hr_utility.set_location(l_proc, 6);
	if l_type <> 'PERFORMANCE' then
		hr_utility.set_message(801,'HR_51930_APT_RSC_INV_TYPE');
	       	hr_utility.raise_error;
        end if;
     end if;
   end if;

  -- Perform the below checks only if updating and the value of the
  -- rating_scale_id has changed

   if (  (l_api_updating and (per_apt_shd.g_old_rec.rating_scale_id
		        <> nvl(p_rating_scale_id,hr_api.g_number)) )
      )
   then

     -- Check if the rating scale can be updated

     hr_utility.set_location(l_proc, 7);
     open csr_rating_scale_update1;
     fetch csr_rating_scale_update1 into l_overall_performance_level_id;
     close csr_rating_scale_update1;
     if l_overall_performance_level_id is not null then
       	hr_utility.set_message(801,'HR_51931_APT_APR_LVL_NOTNULL');
       	hr_utility.raise_error;
     end if;

     hr_utility.set_location(l_proc, 8);
     open csr_rating_scale_update2;
     fetch csr_rating_scale_update2 into l_exists;
     if csr_rating_scale_update2%found then
        close csr_rating_scale_update2;
        hr_utility.set_message(801,'HR_51932_APT_EXIST_IN_PRF');
        hr_utility.raise_error;
     end if;
     close csr_rating_scale_update2;

     -- Now check if the rating scale exists and is of the correct type

     if p_rating_scale_id is not null then
        hr_utility.set_location(l_proc, 9);
        open csr_rating_scale_exists;
        fetch csr_rating_scale_exists into l_business_group_id,l_type;
	if csr_rating_scale_exists%notfound then
            close csr_rating_scale_exists;
            hr_utility.set_message(801,'HR_51928_APT_RSC_NOT_EXIST');
            hr_utility.raise_error;
	end if;
        close csr_rating_scale_exists;

        -- check if rating scale is in the same business group

	hr_utility.set_location(l_proc, 10);
        if l_business_group_id <> p_business_group_id  then
	       hr_utility.set_message(801,'HR_51929_APT_RSC_DIFF_BUS_GRP');
	       hr_utility.raise_error;
        end if;

      	-- check if rating scale template is of type 'PERFORMANCE'

	hr_utility.set_location(l_proc, 11);
	if l_type <> 'PERFORMANCE' then
		hr_utility.set_message(801,'HR_52930_APT_RSC_INV_TYPE');
	       	hr_utility.raise_error;
        end if;
     end if;

   end if;

   hr_utility.set_location(l_proc, 12);

  hr_utility.set_location('Leaving: '|| l_proc, 10);

end chk_rating_scale;


--------------------------------------------------------------------------+
-------------------------------<chk_template_delete>----------------------+
--------------------------------------------------------------------------+

--  Description:
--   - Validates that the appraisal template cannot be deleted if it is used
--     in an appraisal

--  Pre_conditions:
--   - Valid p_appraisal_template_id

--  In Arguments:
--    p_appraisal_template_id
--    p_object_version_number

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	- Template is used in an Appraisal

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_template_delete
(p_appraisal_template_id     in      per_appraisal_templates.appraisal_template_id%TYPE
,p_object_version_number     in	     per_appraisal_templates.object_version_number%TYPE
)
is

	l_exists	     varchar2(1);
        l_proc               varchar2(72)  :=  g_package||'chk_template_delete';


	-- Cursor to check if the appraisal template
	-- is used in appraisal

	Cursor csr_template_delete
          is
	select  'Y'
	from	per_appraisals
	where	appraisal_template_id = p_appraisal_template_id;

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Check mandatory parameters have been set

    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'appraisal_template_id'
    ,p_argument_value => p_appraisal_template_id
    );


  hr_utility.set_location('Entering:'|| l_proc, 2);

        open csr_template_delete;
        fetch csr_template_delete into l_exists;
	if csr_template_delete%found then
            close csr_template_delete;
            hr_utility.set_message(801,'HR_51933_APT_EXIST_IN_APR');
            hr_utility.raise_error;
	end if;
        close csr_template_delete;

  hr_utility.set_location('Leaving: '|| l_proc, 10);

end chk_template_delete;

--------------------------------------------------------------------------+
-------------------------------<chk_update_comp_profile>----------------------+
--------------------------------------------------------------------------+

--  Description:
--   - Validates that the update_comp_personal_profile cannot be set to Y if
--     assessment_template_id is null . Also Validate update_comp_profile
--   against the HR_LOOKUP where lookup_type = 'YES_NO'.
--
--

--  Pre_conditions:
--   - Valid p_appraisal_template_id

--  In Arguments:
--    p_update_personal_comp_profile
--    p_assessment_type_id
--    p_effective_date
--    p_object_version_number

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	 Update_comp_Profile value is not null but assessment_type_id is null
--   update_comp_profile  value is not validated against lookup 'YES_NO'.

--  Access Status
--    Internal Table Handler Use Only.


-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure chk_update_comp_profile
 (
  p_update_personal_comp_profile  in    per_appraisal_templates.update_personal_comp_profile%TYPE
 ,p_assessment_type_id		      in     per_appraisal_templates.assessment_type_id%TYPE
 ,p_effective_date		          in 	date
 ,p_object_version_number     in	     per_appraisal_templates.object_version_number%TYPE
 ,p_appraisal_template_id     in      per_appraisal_templates.appraisal_template_id%TYPE
 )
is
--
  l_proc	varchar2(72):=g_package||'chk_update_comp_profile';
  l_api_updating	boolean;
--
begin
  -- Bug#885806
  --  dbms_output.put_line('Inside the chk_display_assessment_comments procedure');
  hr_utility.trace('Inside the chk_update_comp_profile procedure');
  hr_utility.set_location('Entering:'|| l_proc, 1);

  if  ( p_assessment_type_id is null and p_update_personal_comp_profile is not null ) then
      hr_utility.set_location(l_proc, 2);
      hr_utility.set_message(800,'HR_APT_AST_REQUIRED_MSG');
      hr_utility.raise_error;

  end if;
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

  l_api_updating := per_apt_shd.api_updating
         (p_appraisal_template_id  => p_appraisal_template_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and nvl(per_apt_shd.g_old_rec.update_personal_comp_profile,
				 hr_api.g_varchar2)
  		<> nvl(p_update_personal_comp_profile, hr_api.g_varchar2))
  or
    (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Check the value in p_display_assessment_comments exists in hr_lookups
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date	=> p_effective_date
      ,p_lookup_type	=> 'YES_NO'
      ,p_lookup_code	=> p_update_personal_comp_profile
      ) then
      hr_utility.set_location(l_proc, 10);
      hr_utility.set_message(801,'HR_APT_UPD_COMP_PROF_INVAL');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 15);
  end if;
end chk_update_comp_profile;

--------------------------------------------------------------------------+
-------------------------------<chk_comp_profile_source_type>----------------------+
--------------------------------------------------------------------------+
--  Description:
--   - Validates that the comp_profile_source_type cannot be set  if
--     update_personal_comp_profile is null or 'N' . Also Validate update_comp_profile
--   against the HR_LOOKUP where lookup_type = 'YES_NO'.
--
--

--  Pre_conditions:
--   - Valid p_appraisal_template_id

--  In Arguments:
--    p_comp_profile_source_type
--    p_update_personal_comp_profile
--    p_effective_date
--    p_object_version_number

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	 comp_profile_source_type value is not null but update_personal_comp_profile is null or 'N'
--   comp_profile_source_type  value is not validated against lookup 'PROFICIENCY_SOURCE'.

--  Access Status
--    Internal Table Handler Use Only.


-- Access Status:
--   Internal Table Handler Use Only.
--

Procedure chk_comp_profile_source_type
 (
  p_comp_profile_source_type	  in    per_appraisal_templates.comp_profile_source_type%TYPE
 ,p_update_personal_comp_profile  in    per_appraisal_templates.update_personal_comp_profile%TYPE
 ,p_effective_date		          in 	date
 ,p_object_version_number         in	per_appraisal_templates.object_version_number%TYPE
 ,p_appraisal_template_id     in      per_appraisal_templates.appraisal_template_id%TYPE
 )
is
--
  l_proc	varchar2(72):=g_package||'chk_comp_profile_source_type';
  l_api_updating	boolean;
--
begin
  -- Bug#885806
  --  dbms_output.put_line('Inside the chk_display_assessment_comments procedure');
  hr_utility.trace('Inside the chk_comp_profile_source_type procedure');
  hr_utility.set_location('Entering:'|| l_proc, 1);

  if  ( p_comp_profile_source_type is not null and ( p_update_personal_comp_profile is null or  p_update_personal_comp_profile = 'N')  ) then
      hr_utility.set_location(l_proc, 2);
      hr_utility.set_message(800,'HR_APT_UPD_COMP_PROF_REQUIRED');
      hr_utility.raise_error;
  end if;
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

  l_api_updating := per_apt_shd.api_updating
         (p_appraisal_template_id  => p_appraisal_template_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and nvl(per_apt_shd.g_old_rec.comp_profile_source_type,
				 hr_api.g_varchar2)
  		<> nvl(p_comp_profile_source_type, hr_api.g_varchar2))
  or
    (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Check the value in p_display_assessment_comments exists in hr_lookups
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date	=> p_effective_date
      ,p_lookup_type	=> 'PROFICIENCY_SOURCE'
      ,p_lookup_code	=> p_comp_profile_source_type
      ) then
      hr_utility.set_location(l_proc, 10);
      hr_utility.set_message(800,'HR_APT_COMP_PROF_SRC_INVAL');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 15);
  end if;
end chk_comp_profile_source_type;

--------------------------------------------------------------------------+
-------------------------------<chk_link_appr_to_learning_path>----------------------+
--------------------------------------------------------------------------+
--  Description:
--   Validate link_appr_to_learning_path
--   against the HR_LOOKUP where lookup_type = 'YES_NO'.
--

--  Pre_conditions:
--   - Valid p_appraisal_template_id

--  In Arguments:
--    p_link_appr_to_learning_path
--    p_effective_date
--    p_object_version_number

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--   link_appr_to_learning_path  value is not validated against lookup 'PROFICIENCY_SOURCE'.

--  Access Status
--    Internal Table Handler Use Only.


-- Access Status:
--   Internal Table Handler Use Only.
--

Procedure chk_link_appr_to_learning_path
 (
  p_link_appr_to_learning_path	  in    per_appraisal_templates.link_appr_to_learning_path%TYPE
 ,p_effective_date		          in 	date
 ,p_object_version_number         in	per_appraisal_templates.object_version_number%TYPE
 ,p_appraisal_template_id     in      per_appraisal_templates.appraisal_template_id%TYPE
 )
is
--
  l_proc	varchar2(72):=g_package||'chk_link_appr_to_learning_path';
  l_api_updating	boolean;
--
begin
  -- Bug#885806
  --  dbms_output.put_line('Inside the chk_display_assessment_comments procedure');
  hr_utility.trace('Inside the chk_link_appr_to_learning_path procedure');
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

  l_api_updating := per_apt_shd.api_updating
         (p_appraisal_template_id  => p_appraisal_template_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and nvl(per_apt_shd.g_old_rec.link_appr_to_learning_path,
				 hr_api.g_varchar2)
  		<> nvl(p_link_appr_to_learning_path, hr_api.g_varchar2))
  or
    (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Check the value in p_link_appr_to_learning_path exists in hr_lookups
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date	=> p_effective_date
      ,p_lookup_type	=> 'YES_NO'
      ,p_lookup_code	=> p_link_appr_to_learning_path
      ) then
      hr_utility.set_location(l_proc, 10);
      hr_utility.set_message(800,'HR_APT_LINK_TO_LP_INVAL');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 15);
  end if;
end chk_link_appr_to_learning_path;

--------------------------------------------------------------------------+
-------------------------------<chk_available_flag>----------------------+
--------------------------------------------------------------------------+
--  Description:
--   Validate available_flag
--   against the HR_LOOKUP where lookup_type = 'TEMPLATE_AVAILABILITY_FLAG'.
--

--  Pre_conditions:
--   - Valid p_appraisal_template_id

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
  p_available_flag	  in    per_appraisal_templates.available_flag%TYPE
 ,p_effective_date		in 	date
 ,p_object_version_number         in	per_appraisal_templates.object_version_number%TYPE
 ,p_appraisal_template_id     in      per_appraisal_templates.appraisal_template_id%TYPE
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

  l_api_updating := per_apt_shd.api_updating
      (p_appraisal_template_id  => p_appraisal_template_id
       ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and nvl(per_apt_shd.g_old_rec.available_flag,
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
-- ----------------------------------------------------------------------+
-- |------------------------------< chk_df >-----------------------------+
-- ----------------------------------------------------------------------+

-- Description:
--   Validates the all Descriptive Flexfield values.

-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.

-- In Arguments:
--   p_rec

-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.

-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.

-- Access Status:
--   Internal Row Handler Use Only.

procedure chk_df
  (p_rec in per_apt_shd.g_rec_type) is

  l_proc     varchar2(72) := g_package||'chk_df';

begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  if ((p_rec.appraisal_template_id is not null) and (
    nvl(per_apt_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_apt_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.appraisal_template_id is null) then

   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.

   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_APPRAISAL_TEMPLATES'
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

  hr_utility.set_location(' Leaving:'||l_proc, 20);

end chk_df;

-- ---------------------------------------------------------------------------+
-- |---------------------------< insert_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure insert_validate(p_rec in per_apt_shd.g_rec_type
			 ,p_effective_date in date) is

  l_proc  varchar2(72) := g_package||'insert_validate';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Call all supporting business operations
  if   p_rec.business_group_id is not null then
      hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;

  -- Check name is unique

  per_apt_bus.chk_name
  (p_appraisal_template_id    	=>	p_rec.appraisal_template_id
  ,p_name	     		=>	p_rec.name
  ,p_object_version_number	=>	p_rec.object_version_number
  ,p_business_group_id		=>	p_rec.business_group_id
  );

  -- Check template dates

  per_apt_bus.chk_template_dates
  (p_date_from			=>	p_rec.date_from
  ,p_date_to			=>	p_rec.date_to
  ,p_appraisal_template_id	=>	p_rec.appraisal_template_id
  ,p_object_version_number	=>	p_rec.object_version_number
  );

  -- check competence assessment template

  per_apt_bus.chk_assessment_type
  (p_appraisal_template_id    	=>	p_rec.appraisal_template_id
  ,p_object_version_number     	=>	p_rec.object_version_number
  ,p_assessment_type_id	     	=>	p_rec.assessment_type_id
  ,p_date_from			=>	p_rec.date_from
  ,p_date_to			=>	p_rec.date_to
  ,p_business_group_id	     	=>	p_rec.business_group_id
  );

  -- Check Questionnaire template

  per_apt_bus.chk_question_template
  (p_object_version_number     	=>	p_rec.object_version_number
  ,p_questionnaire_template_id 	=>	p_rec.questionnaire_template_id
  ,p_business_group_id          =>      p_rec.business_group_id
  ,p_appraisal_template_id      =>      p_rec.appraisal_template_id
  );

  -- Check rating scale

  per_apt_bus.chk_rating_scale
  (p_appraisal_template_id     =>	p_rec.appraisal_template_id
  ,p_object_version_number     =>	p_rec.object_version_number
  ,p_rating_scale_id	       =>	p_rec.rating_scale_id
  ,p_business_group_id	       =>	p_rec.business_group_id
  );

  -- check objective assessment template

  per_apt_bus.chk_objective_asmnt_type
  (p_appraisal_template_id    	=>	p_rec.appraisal_template_id
  ,p_object_version_number     	=>	p_rec.object_version_number
  ,p_objective_asmnt_type_id	=>	p_rec.objective_asmnt_type_id
  ,p_date_from			=>	p_rec.date_from
  ,p_date_to			=>	p_rec.date_to
  ,p_business_group_id	     	=>	p_rec.business_group_id
  );

  -- Check MA Questionnaire template

  per_apt_bus.chk_ma_question_template
  (p_object_version_number     	=>	p_rec.object_version_number
  ,p_ma_quest_template_id 	=>	p_rec.ma_quest_template_id
  ,p_business_group_id          =>      p_rec.business_group_id
  ,p_appraisal_template_id      =>      p_rec.appraisal_template_id
  );

  -- Check update_comp_profile value
  if p_rec.update_personal_comp_profile is not null then
  per_apt_bus.chk_update_comp_profile
 (
  p_update_personal_comp_profile  =>    p_rec.update_personal_comp_profile
 ,p_assessment_type_id		      =>     p_rec.assessment_type_id
 ,p_effective_date		          => 	p_effective_date
 ,p_object_version_number     =>	     p_rec.object_version_number
 ,p_appraisal_template_id     =>      p_rec.appraisal_template_id
 );
 end if;
 if p_rec.comp_profile_source_type is not null then
  -- Check comp_profile_source_type value
 per_apt_bus.chk_comp_profile_source_type
 (
  p_comp_profile_source_type	  =>    p_rec.comp_profile_source_type
 ,p_update_personal_comp_profile  =>    p_rec.update_personal_comp_profile
 ,p_effective_date		          => 	p_effective_date
 ,p_object_version_number         =>	p_rec.object_version_number
 ,p_appraisal_template_id     =>      p_rec.appraisal_template_id
 );
 end if;
   -- Check link_to_learning_path value
 if p_rec.link_appr_to_learning_path is not null then
 per_apt_bus.chk_link_appr_to_learning_path
 (
  p_link_appr_to_learning_path   =>  p_rec.link_appr_to_learning_path
  ,p_effective_date		          => 	p_effective_date
 ,p_object_version_number         =>	p_rec.object_version_number
 ,p_appraisal_template_id     =>      p_rec.appraisal_template_id
 );
end if;

-- Check available_flag value
 if p_rec.available_flag is not null then
 per_apt_bus.chk_available_flag
 (
  p_available_flag   =>  p_rec.available_flag
  ,p_effective_date		          => 	p_effective_date
 ,p_object_version_number         =>	p_rec.object_version_number
 ,p_appraisal_template_id     =>      p_rec.appraisal_template_id
 );
end if;

  -- Call descriptive flexfield validation routines

  per_apt_bus.chk_df(p_rec => p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 45);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;

-- ---------------------------------------------------------------------------+
-- |---------------------------< update_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure update_validate(p_rec in per_apt_shd.g_rec_type
			 ,p_effective_date in date) is

  l_proc  varchar2(72) := g_package||'update_validate';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Call all supporting business operations

if   p_rec.business_group_id is not null then
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp

end if;

  -- Rule Check non-updateable fields cannot be updated

  chk_non_updateable_args(p_rec	=> p_rec);


  -- Check name is unique

  per_apt_bus.chk_name
  (p_appraisal_template_id    	=>	p_rec.appraisal_template_id
  ,p_name	     		=>	p_rec.name
  ,p_object_version_number	=>	p_rec.object_version_number
  ,p_business_group_id		=>	p_rec.business_group_id
  );

  -- Check template dates

  per_apt_bus.chk_template_dates
  (p_date_from			=>	p_rec.date_from
  ,p_date_to			=>	p_rec.date_to
  ,p_appraisal_template_id	=>	p_rec.appraisal_template_id
  ,p_object_version_number	=>	p_rec.object_version_number
  );

  -- Check assessment type

  per_apt_bus.chk_assessment_type
  (p_appraisal_template_id    	=>	p_rec.appraisal_template_id
  ,p_object_version_number     	=>	p_rec.object_version_number
  ,p_assessment_type_id	     	=>	p_rec.assessment_type_id
  ,p_date_from			=>	p_rec.date_from
  ,p_date_to			=>	p_rec.date_to
  ,p_business_group_id	     	=>	p_rec.business_group_id
  );

  -- Check Questionnaire template

  per_apt_bus.chk_question_template
  (p_object_version_number     	=>	p_rec.object_version_number
  ,p_questionnaire_template_id 	=>	p_rec.questionnaire_template_id
  ,p_business_group_id          =>      p_rec.business_group_id
  ,p_appraisal_template_id      =>      p_rec.appraisal_template_id
  );

  -- Check rating scale update

  per_apt_bus.chk_rating_scale
  (p_appraisal_template_id     =>	p_rec.appraisal_template_id
  ,p_object_version_number     =>	p_rec.object_version_number
  ,p_rating_scale_id	       =>	p_rec.rating_scale_id
  ,p_business_group_id	       =>	p_rec.business_group_id
  );

  -- check objective assessment template

  per_apt_bus.chk_objective_asmnt_type
  (p_appraisal_template_id    	=>	p_rec.appraisal_template_id
  ,p_object_version_number     	=>	p_rec.object_version_number
  ,p_objective_asmnt_type_id	=>	p_rec.objective_asmnt_type_id
  ,p_date_from			=>	p_rec.date_from
  ,p_date_to			=>	p_rec.date_to
  ,p_business_group_id	     	=>	p_rec.business_group_id
  );

  -- Check MA Questionnaire template

  per_apt_bus.chk_ma_question_template
  (p_object_version_number     	=>	p_rec.object_version_number
  ,p_ma_quest_template_id 	=>	p_rec.ma_quest_template_id
  ,p_business_group_id          =>      p_rec.business_group_id
  ,p_appraisal_template_id      =>      p_rec.appraisal_template_id
  );

  -- Check update_comp_profile value
  if p_rec.update_personal_comp_profile is not null then
  per_apt_bus.chk_update_comp_profile
 (
  p_update_personal_comp_profile  =>    p_rec.update_personal_comp_profile
 ,p_assessment_type_id		      =>     p_rec.assessment_type_id
 ,p_effective_date		          => 	p_effective_date
 ,p_object_version_number     =>	     p_rec.object_version_number
 ,p_appraisal_template_id     =>      p_rec.appraisal_template_id
 );
 end if;
 if p_rec.comp_profile_source_type is not null then
  -- Check comp_profile_source_type value
 per_apt_bus.chk_comp_profile_source_type
 (
  p_comp_profile_source_type	  =>    p_rec.comp_profile_source_type
 ,p_update_personal_comp_profile  =>    p_rec.update_personal_comp_profile
 ,p_effective_date		          => 	p_effective_date
 ,p_object_version_number         =>	p_rec.object_version_number
 ,p_appraisal_template_id     =>      p_rec.appraisal_template_id
 );
 end if;
   -- Check link_to_learning_path value
 if p_rec.link_appr_to_learning_path is not null then
 per_apt_bus.chk_link_appr_to_learning_path
 (
  p_link_appr_to_learning_path   =>  p_rec.link_appr_to_learning_path
  ,p_effective_date		          => 	p_effective_date
 ,p_object_version_number         =>	p_rec.object_version_number
 ,p_appraisal_template_id     =>      p_rec.appraisal_template_id
 );
end if;

-- Check available_flag value
 if p_rec.available_flag is not null then
 per_apt_bus.chk_available_flag
 (
  p_available_flag   =>  p_rec.available_flag
  ,p_effective_date		          => 	p_effective_date
 ,p_object_version_number         =>	p_rec.object_version_number
 ,p_appraisal_template_id     =>      p_rec.appraisal_template_id
 );
end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);

  -- Call descriptive flexfield validation routines

  per_apt_bus.chk_df(p_rec => p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 15);
End update_validate;

-- ---------------------------------------------------------------------------+
-- |---------------------------< delete_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure delete_validate(p_rec in per_apt_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'delete_validate';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Call all supporting business operations

  per_apt_bus.chk_template_delete
  (p_appraisal_template_id     =>	p_rec.appraisal_template_id
  ,p_object_version_number     =>	p_rec.object_version_number
  );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;

-- ---------------------------------------------------------------------------+
-- |-----------------------< return_legislation_code >------------------------|
-- ---------------------------------------------------------------------------+
Function return_legislation_code
         (  p_appraisal_template_id     in number )
   return varchar2 is

-- Declare cursor

   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups      pbg,
                 per_appraisal_templates  pat
          where  pat.appraisal_template_id  = p_appraisal_template_id
            and  pbg.business_group_id      = pat.business_group_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Ensure that all the mandatory parameters are not null

  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'appraisal_template_id',
                              p_argument_value => p_appraisal_template_id );

  if nvl(g_appraisal_template_id, hr_api.g_number) = p_appraisal_template_id then

    -- The legislation has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.

    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else

    -- The ID is different to the last call to this function
    -- or this is the first call to this function.


  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;

     -- The primary key is invalid therefore we must error out

     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;

  close csr_leg_code;
   g_appraisal_template_id    := p_appraisal_template_id;
   g_legislation_code         := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  return l_legislation_code;


  End return_legislation_code;


end per_apt_bus;

/
