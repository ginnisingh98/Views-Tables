--------------------------------------------------------
--  DDL for Package Body GHR_PDC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDC_BUS" as
/* $Header: ghpdcrhi.pkb 120.0.12010000.3 2009/05/27 05:40:10 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pdc_bus.';  -- Global package name
--

--
----------------------------<chk_non_updateable_args>----------------------
--

PROCEDURE CHK_NON_UPDATEABLE_ARGS(p_rec IN ghr_pdc_shd.g_rec_type)

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

	IF not ghr_pdc_shd.api_updating
			(p_pd_classification_id  => p_rec.pd_classification_id,
			 p_object_version_number     => p_rec.object_version_number)
	THEN

		hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PROCEDURE',l_proc);
		hr_utility.set_message_token('STEP','20');
	END IF;

--
	hr_utility.set_location (l_proc, 30);
--

	IF NVL(p_rec.position_description_id, hr_api.g_number)
		<> NVL(ghr_pdc_shd.g_old_rec.position_description_id, hr_api.g_number)
	THEN
		l_argument := 'position_description_id';
		RAISE l_error;

	END IF;

-- Check with functionals and verify.




	IF NVL(p_rec.class_grade_by, hr_api.g_varchar2)
		<> NVL(ghr_pdc_shd.g_old_rec.class_grade_by,hr_api.g_varchar2)
	THEN

		l_argument := 'class_grade_by';
		RAISE l_error;
	END IF;

/* The following lines are commented as we have not completely defined the business rules for classification/certification information. This information cannot be changed once the PD has been classified. */


/*	IF NVL(p_rec.official_title, hr_api.g_varchar2)
		<> NVL(ghr_pdc_shd.g_old_rec.official_title,hr_api.g_varchar2)
	THEN

		l_argument := 'official_title';
		RAISE l_error;
	END IF;

	IF NVL(p_rec.pay_plan, hr_api.g_varchar2)
		<> NVL(ghr_pdc_shd.g_old_rec.pay_plan,hr_api.g_varchar2)
	THEN

		l_argument := 'pay_plan';
		RAISE l_error;
	END IF;

	IF NVL(p_rec.occupational_code, hr_api.g_varchar2)
		<> NVL(ghr_pdc_shd.g_old_rec.occupational_code,hr_api.g_varchar2)
	THEN

		l_argument := 'occupational_code';
		RAISE l_error;
	END IF;

	IF NVL(p_rec.grade_level, hr_api.g_varchar2)
		<> NVL(ghr_pdc_shd.g_old_rec.grade_level,hr_api.g_varchar2)
	THEN

		l_argument := 'grade_level';
		RAISE l_error;

	END IF;
*/


--

--
	hr_utility.set_location('Leaving :' || l_proc, 40);

	EXCEPTION

		WHEN l_error THEN

			hr_api.argument_changed_error

				(p_api_name   =>  l_proc,
				 p_argument   =>  l_argument);

		WHEN OTHERS THEN

			RAISE;
end chk_non_updateable_args;

--
-----------------------------<chk_grade_level>------------------------------
--
--

PROCEDURE chk_grade_level(p_pd_classification_id IN
					ghr_pd_classifications.pd_classification_id%TYPE,
				  p_grade_level IN ghr_pd_classifications.grade_level%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number)

IS

l_proc	varchar2(72) := g_package||'chk_grade_level';
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
-- b) The grade_level value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdc_shd.api_updating(
					p_pd_classification_id  => p_pd_classification_id,
					p_object_version_number	=> p_object_version_number);

	IF (l_api_updating
        AND
        ((nvl(ghr_pdc_shd.g_old_rec.grade_level,hr_api.g_varchar2)
				<> nvl(p_grade_level,hr_api.g_varchar2))))
        OR
	NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--
-- 	If grade level is not null then
--	Check if the grade level value exists in fnd_lookups
--	Where the look up type is 'GHR_US_GRADE_OR_LEVEL'
--

	IF p_grade_level is NOT NULL THEN

	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type		=>      'GHR_US_GRADE_OR_LEVEL',
			 p_lookup_code		=>	p_grade_level
			) THEN

	-- Error: Invalid Subject to IA Action

               -- New Message

	       hr_utility.set_message(8301,'GHR_INVALID_GRADE_OR_LEVEL');
	       hr_utility.raise_error;
	   END IF;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END chk_grade_level;

--
----------------------------------------------------------<chk_pay_plan>------------------------------------------------------
--


PROCEDURE chk_pay_plan(p_pd_classification_id IN
					ghr_pd_classifications.pd_classification_id%TYPE,
				  p_pay_plan IN ghr_pd_classifications.pay_plan%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number)

IS

l_proc	varchar2(72) := g_package||'chk_pay_plan';
l_api_updating boolean;
l_pay_plan ghr_pay_plans.pay_plan%TYPE;

CURSOR c_pay_plan
IS
       SELECT pay_plan
       FROM   ghr_pay_plans
       WHERE  pay_plan = p_pay_plan;


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
-- b) The grade_level value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdc_shd.api_updating(
					p_pd_classification_id  => p_pd_classification_id,
					p_object_version_number	=> p_object_version_number);

	IF (l_api_updating
        AND
        ((nvl(ghr_pdc_shd.g_old_rec.pay_plan,hr_api.g_varchar2)
				<> nvl(p_pay_plan,hr_api.g_varchar2))))
        OR
	NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--
-- 	If pay plan is not null then
--      Check if the pay plan is in GHR_PAY_PLANS
--      This is an extra check apart from the foreign key on the table.
--

	IF p_pay_plan is NOT NULL THEN

           OPEN c_pay_plan;
           FETCH c_pay_plan INTO l_pay_plan;
           IF c_pay_plan%NOTFOUND THEN

	       hr_utility.set_message(8301,'GHR_INVALID_PAY_PLAN');
	       hr_utility.raise_error;
	   END IF;
           CLOSE c_pay_plan;

	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END chk_pay_plan;

--
-------------------------------------------------<chk_occupational_code>-----------------------------------------------
--


PROCEDURE chk_occupational_code(p_pd_classification_id IN
					ghr_pd_classifications.pd_classification_id%TYPE,
				  p_occupational_code IN 											ghr_pd_classifications.occupational_code%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number)

IS

l_proc	varchar2(72) := g_package||'chk_occupational_code';
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
-- b) The grade_level value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdc_shd.api_updating(
					p_pd_classification_id  => p_pd_classification_id,
					p_object_version_number	=> p_object_version_number);

	IF (l_api_updating
        AND
        ((nvl(ghr_pdc_shd.g_old_rec.occupational_code,hr_api.g_varchar2)
				<> nvl(p_occupational_code,hr_api.g_varchar2))))
        OR
	NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--
-- 	If occupational code is not null then
--	Check if the occupational code value exists in fnd_lookups
--	Where the look up type is 'GHR_US_OCC_SERIES'
--

	IF p_occupational_code is NOT NULL THEN

	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type		=>      'GHR_US_OCC_SERIES',
			 p_lookup_code		=>	p_occupational_code
			) THEN

	-- Error: Invalid Occupational Code

	       hr_utility.set_message(8301,'GHR_OCCUPATIONAL_CODE_INVALID');
	       hr_utility.raise_error;
	   END IF;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);


END CHK_OCCUPATIONAL_CODE;


PROCEDURE CHK_CLASS_GRADE_BY(p_pd_classification_id IN
					ghr_pd_classifications.pd_classification_id%TYPE,
				  p_class_grade_by IN ghr_pd_classifications.class_grade_by%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number)

IS

l_proc	varchar2(72) := g_package||'chk_class_grade_by';
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
-- b) The class_grade_by value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_pdc_shd.api_updating(
			       p_pd_classification_id  => p_pd_classification_id,
					p_object_version_number	=> p_object_version_number);


	IF (l_api_updating
        AND
        ((nvl(ghr_pdc_shd.g_old_rec.class_grade_by,hr_api.g_varchar2)
				<> nvl(p_class_grade_by,hr_api.g_varchar2))))
        OR
	NOT l_api_updating THEN


	hr_utility.set_location(l_proc,20);
--
-- 	If class_grade_by is not null then
--	Check if the grade level value exists in fnd_lookups
--	Where the look up type is 'GHR_CLASS_GRADE_BY'
--

	IF p_class_grade_by is NOT NULL THEN


	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type		=>      'GHR_US_CLASS_GRADE_BY',
			 p_lookup_code		=>	p_class_grade_by
			) THEN


               hr_utility.set_message(8301,'GHR_CLASS_GRADE_BY_INVALID');
               hr_utility.raise_error;

	   END IF;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);


END CHK_CLASS_GRADE_BY;


-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ghr_pdc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_effective_date date ;
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
  -- PLEASE VERIFY: Inserted by Dinkar. Karumuri

    SELECT sysdate
    INTO   l_effective_date
    FROM   dual;


  -- p_effective_date is currently date_from. Verify it.

  chk_class_grade_by(p_pd_classification_id => p_rec.pd_classification_id,
                     p_class_grade_by       => p_rec.class_grade_by,
                     p_effective_date       => l_effective_date,
                     p_object_version_number => p_rec.object_version_number);

  chk_occupational_code(p_pd_classification_id => p_rec.pd_classification_id,
                     p_occupational_code       => p_rec.occupational_code,
                     p_effective_date       => l_effective_date,
                     p_object_version_number => p_rec.object_version_number);

  chk_pay_plan(p_pd_classification_id => p_rec.pd_classification_id,
                     p_pay_plan       => p_rec.pay_plan,
                     p_effective_date       => l_effective_date,
                     p_object_version_number => p_rec.object_version_number);

  chk_grade_level(p_pd_classification_id => p_rec.pd_classification_id,
                     p_grade_level       => p_rec.grade_level,
                     p_effective_date       => l_effective_date,
                     p_object_version_number => p_rec.object_version_number);


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ghr_pdc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_effective_date date;
--
Begin

  select sysdate
  into   l_effective_date
  from dual;

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

  chk_non_updateable_args(p_rec);

  -- Please VERIFY Inserted by Dinkar. Karumuri

  chk_class_grade_by(p_pd_classification_id => p_rec.pd_classification_id,
                     p_class_grade_by       => p_rec.class_grade_by,
                     p_effective_date       => l_effective_date,
                     p_object_version_number => p_rec.object_version_number);

  chk_occupational_code(p_pd_classification_id => p_rec.pd_classification_id,
                     p_occupational_code       => p_rec.occupational_code,
                     p_effective_date       => l_effective_date,
                     p_object_version_number => p_rec.object_version_number);

  chk_pay_plan(p_pd_classification_id => p_rec.pd_classification_id,
                     p_pay_plan       => p_rec.pay_plan,
                     p_effective_date       => l_effective_date,
                     p_object_version_number => p_rec.object_version_number);

  chk_grade_level(p_pd_classification_id => p_rec.pd_classification_id,
                     p_grade_level       => p_rec.grade_level,
                     p_effective_date       => l_effective_date,
                     p_object_version_number => p_rec.object_version_number);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ghr_pdc_shd.g_rec_type) is
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
end ghr_pdc_bus;

/
