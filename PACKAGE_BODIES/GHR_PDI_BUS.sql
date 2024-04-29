--------------------------------------------------------
--  DDL for Package Body GHR_PDI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDI_BUS" as
/* $Header: ghpdirhi.pkb 120.1 2005/06/13 12:28:25 vravikan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pdi_bus.';  -- Global package name

--
-----------------------------<chk_date_to>-----------------------------
--
Procedure chk_date_to(p_position_description_id IN ghr_position_descriptions.position_description_id%TYPE,
		          p_date_from IN DATE,
                                      p_date_to IN DATE)
is


l_proc	varchar2(72) := g_package||'chk_date_to';


BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

	IF NVL(p_date_to,p_date_from) >= p_date_from THEN

		NULL;
	ELSE
		hr_utility.set_message(8301, 'GHR_DATE_TO_<_DATE_FROM');

		hr_utility.raise_error;
	END IF;

END CHK_DATE_TO;


--
-----------------------------<chk_category>----------------------------------
--
Procedure chk_category(p_position_description_id IN
                                ghr_position_descriptions.position_description_id%TYPE,
		   p_category IN ghr_position_descriptions.category%TYPE,
		   p_effective_date IN DATE,
		   p_object_version_number IN number)
IS

l_proc	varchar2(72) := g_package||'chk_category';
l_api_updating boolean;
l_dummy varchar2(1);

cursor c_pd_category is
select 'X' from
dual
where p_category in ('ACTIVE','INACTIVE','STANDARD','CANCELED');

BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) The category_category value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdi_shd.api_updating(
			  p_position_description_id => p_position_description_id,
			  p_object_version_number  => p_object_version_number);

        IF (l_api_updating
        AND
        ((nvl(ghr_pdi_shd.g_old_rec.category,hr_api.g_varchar2)
                                <> nvl(p_category,hr_api.g_varchar2))))
        OR
        NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--

	IF p_category is NOT NULL THEN
        open c_pd_category;
        fetch c_pd_category into l_dummy;
        IF c_pd_category%notfound then

	-- Error: Invalid category category
		hr_utility.set_message(8301, 'GHR_38635_INVALID_PD_CATEGORY');

	       hr_utility.raise_error;
	   END IF;
	   hr_utility.set_location(l_proc,30);
        close c_pd_category;

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

end chk_category;
--
-----------------------------<chk_flsa>----------------------------------
--
Procedure chk_flsa(p_position_description_id IN
                                ghr_position_descriptions.position_description_id%TYPE,
		   p_flsa IN ghr_position_descriptions.flsa%TYPE,
		   p_effective_date IN DATE,
		   p_object_version_number IN number)

IS

l_proc	varchar2(72) := g_package||'chk_flsa';
l_api_updating boolean;


BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) The flsa_category value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdi_shd.api_updating(
			  p_position_description_id => p_position_description_id,
			  p_object_version_number  => p_object_version_number);

        IF (l_api_updating
        AND
        ((nvl(ghr_pdi_shd.g_old_rec.flsa,hr_api.g_varchar2)
                                <> nvl(p_flsa,hr_api.g_varchar2))))
        OR
        NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--
-- 	If flsa is not null then
--	Check if the flsa value exists in fnd_lookups
--	Where the look up type is 'GHR_US_FLSA_CATEGORY'
--

	IF p_flsa is NOT NULL THEN

	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type		=>      'GHR_US_FLSA_CATEGORY',
			 p_lookup_code		=>	p_flsa
			) THEN
	-- Error: Invalid FLSA category
		hr_utility.set_message(8301, 'GHR_FLSA_CODE_INVALID');

	       hr_utility.raise_error;
	   END IF;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

end chk_flsa;

--
-----------------------------<chk_financial_statement>-------------------------
--

Procedure chk_financial_statement(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_financial_statement IN 										ghr_position_descriptions.financial_statement%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number)

IS

l_proc varchar2(72) := 'chk_financial_statement';
l_api_updating boolean;

BEGIN

hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error

		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) The financial_statement value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdi_shd.api_updating(
					p_position_description_id	=> p_position_description_id,
					p_object_version_number	=> p_object_version_number);

        IF (l_api_updating
        AND
        ((nvl(ghr_pdi_shd.g_old_rec.financial_statement,hr_api.g_varchar2)
                                <> nvl(p_financial_statement,hr_api.g_varchar2))))
        OR
        NOT l_api_updating THEN
--
	hr_utility.set_location(l_proc,20);
--
-- 	If financial statement  is not null then
--	Check if the financial statement value exists in fnd_lookups
--	Where the look up type is 'GHR_US_FINANCIAL_STATEMENT'
--

	IF p_financial_statement is NOT NULL THEN

	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type		=>      'GHR_US_FINANCIAL_STATEMENT',
			 p_lookup_code		=>	p_financial_statement
			) THEN
	-- Error: Invalid FLSA category
		hr_utility.set_message(8301, 'GHR_FINANCIAL_STAT_INVALID');

	       hr_utility.raise_error;

	   END IF;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END chk_financial_statement;


--
-------------------------------< chk_subject_to_ia_action>---------------------
--

Procedure chk_subject_to_ia_action (p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_sub_to_ia_action IN 											ghr_position_descriptions.subject_to_ia_action %TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number)

IS

l_proc	varchar2(72) := g_package||'chk_subject_to_ia_action_action';
l_api_updating boolean;


BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) The flsa_category value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdi_shd.api_updating(
					p_position_description_id	=> p_position_description_id,
					p_object_version_number	=> p_object_version_number);

        IF (l_api_updating
        AND
        ((nvl(ghr_pdi_shd.g_old_rec.subject_to_ia_action,hr_api.g_varchar2)
                                <> nvl(p_sub_to_ia_action,hr_api.g_varchar2))))
        OR
        NOT l_api_updating THEN
--
	hr_utility.set_location(l_proc,20);
--
-- 	If Subject to IA action is not null then
--	Check if the subject to IA action value exists in fnd_lookups
--	Where the look up type is 'subject_to_ia_action_ACTION'
--

	IF p_sub_to_ia_action is NOT NULL THEN

	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type		=>      'YES_NO',
			 p_lookup_code		=>	p_sub_to_ia_action
			) THEN
	-- Error: Invalid Subject to IA Action
		hr_utility.set_message(8301, 'GHR_SUBJECT_TO_IA_INVALID');

	       hr_utility.raise_error;
	   END IF;
        ELSE
		hr_utility.set_message(8301, 'GHR_38637_NULL_SUB_IA_ACTION');
	        hr_utility.raise_error;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END CHK_subject_to_ia_action;


--
---------------------------------<chk_position_status>---------------------------
--

Procedure chk_position_status 	(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_position_status IN 									ghr_position_descriptions.position_status%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number)
IS
l_proc	varchar2(72) := g_package||'chk_position_status';
l_api_updating boolean;


BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) The flsa_category value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdi_shd.api_updating(
					p_position_description_id	=> p_position_description_id,
					p_object_version_number	=> p_object_version_number);

        IF (l_api_updating
        AND
        ((nvl(ghr_pdi_shd.g_old_rec.position_status,hr_api.g_number)
                                <> nvl(p_position_status,hr_api.g_number))))
        OR
        NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--
-- 	If Subject to IA action is not null then
--	Check if the position status value exists in fnd_lookups
--	Where the look up type is 'GHR_US_POSITION_OCCUPIED'
--

	IF p_position_status is NOT NULL THEN

	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type		=>      'GHR_US_POSITION_OCCUPIED',
			 p_lookup_code		=>	p_position_status
			) THEN

	-- Error: Invalid Position Status
		hr_utility.set_message(8301, 'GHR_POSITION_STATUS_INVALID');
             	hr_utility.raise_error;

	   END IF;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END CHK_POSITION_STATUS;


--
-----------------------------------<chk_position_is>---------------------------------
--

Procedure chk_position_is (p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
			  p_position_is IN ghr_position_descriptions.position_is%TYPE,
			  p_effective_date IN date,
			  p_object_version_number IN number)

IS

l_proc	varchar2(72) := g_package||'chk_position_is';
l_api_updating boolean;


BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) The flsa_category value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdi_shd.api_updating(
					p_position_description_id	=> p_position_description_id,
					p_object_version_number	=> p_object_version_number);

        IF (l_api_updating
        AND
        ((nvl(ghr_pdi_shd.g_old_rec.position_is,hr_api.g_varchar2)
                                <> nvl(p_position_is,hr_api.g_varchar2))))
        OR
        NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--
-- 	If Position is is not null then
--	Check if the Position Is value exists in fnd_lookups
--	Where the look up type is 'GHR_US_SUPERVISORY_STATUS'
--

	IF p_position_is is NOT NULL THEN

	   IF hr_api.not_exists_in_hr_lookups
		(p_effective_date	=>	p_effective_date,
		 p_lookup_type		=>      'GHR_US_SUPERVISORY_STATUS',
		 p_lookup_code		=>	p_position_is
		) THEN

	-- Error: Invalid Position Is
		hr_utility.set_message(8301, 'GHR_POSITION_IS_VALUE_INVALID');
	        hr_utility.raise_error;
	   END IF;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END CHK_POSITION_IS;



-----------------------------<chk_position_sensitivity>--------------------


Procedure chk_position_sensitivity(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_position_sensitivity IN 										ghr_position_descriptions.position_sensitivity%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number)

IS

l_proc	varchar2(72) := g_package||'chk_position_sensitivity';
l_api_updating boolean;


BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) The Position Sensitivity value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdi_shd.api_updating(
					p_position_description_id	=> p_position_description_id,
					p_object_version_number	=> p_object_version_number);

        IF (l_api_updating
        AND
        ((nvl(ghr_pdi_shd.g_old_rec.position_sensitivity,hr_api.g_varchar2)
                                <> nvl(p_position_sensitivity,hr_api.g_varchar2))))
        OR
        NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--
-- 	If position sensitivity is not null then
--	Check if the position sensitivity value exists in fnd_lookups
--	Where the look up type is 'GHR_US_POSN_SENSITIVITY'
--

	IF p_position_sensitivity is NOT NULL THEN

	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type		=>      'GHR_US_POSN_SENSITIVITY',
			 p_lookup_code		=>	p_position_sensitivity
			) THEN
	-- Error: Invalid Position Sensitivity
		hr_utility.set_message(8301, 'GHR_POS_SENSITIVITY_INVALID');
	        hr_utility.raise_error;
	   END IF;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END CHK_POSITION_SENSITIVITY;




--
-----------------------------------<chk_competitive_level>----------------------------
--

Procedure chk_competitive_level(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_competitive_level IN ghr_position_descriptions.competitive_level%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number)
IS

l_proc	varchar2(72) := g_package||'chk_competitive_level';
l_api_updating boolean;


BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) Thecomp level value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdi_shd.api_updating(
					p_position_description_id	=> p_position_description_id,
					p_object_version_number	=> p_object_version_number);

        IF (l_api_updating
        AND
        ((nvl(ghr_pdi_shd.g_old_rec.competitive_level,hr_api.g_varchar2)
                                <> nvl(p_competitive_level,hr_api.g_varchar2))))
        OR
        NOT l_api_updating THEN


	hr_utility.set_location(l_proc,20);
-- Commented by vtakru 04/06/98
-- 	If Competitive level is not null then
--	Check if the comp level value exists in fnd_lookups
--	Where the look up type is 'GHR_US_COMP_LEVEL'
--

--	IF p_competitive_level is NOT NULL THEN
--
--	   IF hr_api.not_exists_in_hr_lookups
--			(p_effective_date	=>	p_effective_date,
--			 p_lookup_type		=>      'GHR_US_COMP_LEVEL',
--			 p_lookup_code		=>	p_competitive_level
--			) THEN
--	   Error: Invalid Competitive level
--		hr_utility.set_message(8301, 'GHR_COMPETITIVE_LEVEL_INVALID');
--	        hr_utility.raise_error;
--	   END IF;
--	   hr_utility.set_location(l_proc,30);
--
--	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END CHK_COMPETITIVE_LEVEL;


--
------------------------------------<chk_career_ladder>--------------------------------
--

Procedure chk_career_ladder(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
			     p_career_ladder IN ghr_position_descriptions.career_ladder%TYPE,
			     p_effective_date IN date,
			     p_object_version_number IN number)



IS

l_proc	varchar2(72) := g_package||'chk_career_ladder';
l_api_updating boolean;


BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) The career ladder value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdi_shd.api_updating(
					p_position_description_id	=> p_position_description_id,
					p_object_version_number	=> p_object_version_number);

        IF (l_api_updating
        AND
        ((nvl(ghr_pdi_shd.g_old_rec.career_ladder,hr_api.g_varchar2)
                                <> nvl(p_career_ladder,hr_api.g_varchar2))))
        OR
        NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--
-- 	If career ladder is not null then
--	Check if the career ladder value exists in fnd_lookups
--	Where the look up type is 'YES_NO'
--

	IF p_career_ladder is NOT NULL THEN

	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type		=>      'YES_NO',
			 p_lookup_code		=>	p_career_ladder
			) THEN
	-- Error: Invalid career ladder value
		hr_utility.set_message(8301, 'GHR_CAREER_LADDER_INVALID');
	        hr_utility.raise_error;
	   END IF;
        ELSE
		hr_utility.set_message(8301, 'GHR_38636_NULL_CAREER_LADDER');
	        hr_utility.raise_error;

	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END CHK_CAREER_LADDER;

--
------------------------------------<chk_routing_group_id>---------------------------------
--

Procedure chk_routing_group_id(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_routing_group_id IN 											ghr_position_descriptions.routing_group_id%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number)

IS

l_proc	varchar2(72) := g_package||'chk_routing_group_id';
l_api_updating boolean;


BEGIN

-- Note: Will be implemented as Part of the september release.
NULL;

END CHK_ROUTING_GROUP_ID;



--
-------------------------------------<chk_non_updateable_args>-------------------------------
--


Procedure chk_non_updateable_args(p_rec IN ghr_pdi_shd.g_rec_type)

IS

l_proc 	varchar2(72)	:= g_package || 'chk_non_updateable_args';
l_error	exception;
l_argument	varchar2(30);


BEGIN

--

	hr_utility.set_location('Entering:'|| l_proc,10);

--
--	Only proceed with the validation if the row exists for
--      the current record in the HR schema.
--

	IF not ghr_pdi_shd.api_updating
			(p_position_description_id   => p_rec.position_description_id,
			 p_object_version_number     => p_rec.object_version_number)
	THEN

		hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PROCEDURE',l_proc);
		hr_utility.set_message_token('STEP','20');
	END IF;

--
	hr_utility.set_location (l_proc, 30);
--

/*

-- To be changed in the screens to base it on the user role.

	IF NVL(p_rec.date_to, hr_api.g_date)
		<> NVL(ghr_pdi_shd.g_old_rec.date_to,hr_api.g_date)
	THEN

		l_argument := 'date_to';
		RAISE l_error;
	END IF;

*/

	IF NVL(p_rec.opm_cert_num, hr_api.g_number)
		<> NVL(ghr_pdi_shd.g_old_rec.opm_cert_num,hr_api.g_number)
	THEN

		l_argument := 'opm_cert_num';
		RAISE l_error;
	END IF;


--
	hr_utility.set_location('Leaving :' || l_proc, 40);

	EXCEPTION

		WHEN l_error THEN

			hr_api.argument_changed_error

				(p_api_name   =>  l_proc,
				 p_argument   =>  l_argument);

		WHEN OTHERS THEN

			RAISE;

END CHK_NON_UPDATEABLE_ARGS;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ghr_pdi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Set up the CLIENT_INFO
  --
  ghr_utility.set_client_info;
  --
  -- Call all supporting business operations
  --
  --
  --

  chk_date_to(
              p_position_description_id  => p_rec.position_description_id,
              p_date_from                => p_rec.date_from,
              p_date_to                  => p_rec.date_to);

  chk_flsa(
              p_position_description_id  => p_rec.position_description_id,
              p_flsa                     => p_rec.flsa,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_category(
              p_position_description_id  => p_rec.position_description_id,
              p_category                     => p_rec.category,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_financial_statement(
              p_position_description_id  => p_rec.position_description_id,
              p_financial_statement      => p_rec.financial_statement,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_subject_to_ia_action(
              p_position_description_id  => p_rec.position_description_id,
              p_sub_to_ia_action         => p_rec.subject_to_ia_action,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_position_status(
              p_position_description_id  => p_rec.position_description_id,
              p_position_status         => p_rec.position_status,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_position_is(
              p_position_description_id  => p_rec.position_description_id,
              p_position_is              => p_rec.position_is,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_position_sensitivity(
              p_position_description_id  => p_rec.position_description_id,
              p_position_sensitivity     => p_rec.position_sensitivity,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_competitive_level(
              p_position_description_id  => p_rec.position_description_id,
              p_competitive_level        => p_rec.competitive_level,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_career_ladder(
              p_position_description_id  => p_rec.position_description_id,
              p_career_ladder            => p_rec.career_ladder,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_routing_group_id(
              p_position_description_id  => p_rec.position_description_id,
              p_routing_group_id         => p_rec.routing_group_id,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ghr_pdi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Set up the CLIENT_INFO
  --
  ghr_utility.set_client_info;
  --
  -- Call all supporting business operations
  --
  --
  --

  chk_date_to(
              p_position_description_id  => p_rec.position_description_id,
              p_date_from                => p_rec.date_from,
              p_date_to                  => p_rec.date_to);

  chk_flsa(
              p_position_description_id  => p_rec.position_description_id,
              p_flsa                     => p_rec.flsa,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_financial_statement(
              p_position_description_id  => p_rec.position_description_id,
              p_financial_statement      => p_rec.financial_statement,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_subject_to_ia_action(
              p_position_description_id  => p_rec.position_description_id,
              p_sub_to_ia_action         => p_rec.subject_to_ia_action,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_position_status(
              p_position_description_id  => p_rec.position_description_id,
              p_position_status         => p_rec.position_status,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_position_is(
              p_position_description_id  => p_rec.position_description_id,
              p_position_is              => p_rec.position_is,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_position_sensitivity(
              p_position_description_id  => p_rec.position_description_id,
              p_position_sensitivity     => p_rec.position_sensitivity,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_competitive_level(
              p_position_description_id  => p_rec.position_description_id,
              p_competitive_level        => p_rec.competitive_level,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_career_ladder(
              p_position_description_id  => p_rec.position_description_id,
              p_career_ladder            => p_rec.career_ladder,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);

  chk_routing_group_id(
              p_position_description_id  => p_rec.position_description_id,
              p_routing_group_id         => p_rec.routing_group_id,
              p_effective_date           => p_rec.date_from,
              p_object_version_number    => p_rec.object_version_number);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ghr_pdi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ghr_pdi_bus;

/
