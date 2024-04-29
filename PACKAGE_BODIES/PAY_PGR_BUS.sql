--------------------------------------------------------
--  DDL for Package Body PAY_PGR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PGR_BUS" as
/* $Header: pypgrrhi.pkb 120.5.12010000.2 2008/08/06 08:12:15 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pgr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_grade_rule_id               number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_rate_type >----------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_rate_type
  (p_rate_type             IN pay_grade_rules_f.rate_type%TYPE
  ,p_effective_date        IN DATE
  ,p_grade_rule_id         IN pay_grade_rules_f.grade_rule_id%TYPE
  ,p_object_version_number IN pay_grade_rules_f.object_version_number%TYPE
  ,p_validation_start_date IN DATE
  ,p_validation_end_date   IN DATE) IS
  --
  l_api_updating BOOLEAN;
  l_proc         VARCHAR2(72) := g_package||'chk_rate_type';
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Only proceed with validation if :
  -- a) The rate_type is changing or new
  -- b) The value for rate_type is changing and not null
  --
  IF ( (p_grade_rule_id IS NULL) OR
      ((p_grade_rule_id IS NOT NULL) AND
       (pay_pgr_shd.g_old_rec.rate_type <> p_rate_type))) THEN
     --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the rate type exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_dt_hr_lookups
          (p_effective_date        => p_effective_date
          ,p_validation_start_date => p_validation_start_date
          ,p_validation_end_date   => p_validation_end_date
          ,p_lookup_type           => 'RATE_TYPE'
          ,p_lookup_code           => p_rate_type) THEN
      --
      hr_utility.set_message(800, 'HR_289589_INV_ASG_RATE_TYPE');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving : '||l_proc,999);
  --
  EXCEPTION
    --
	WHEN app_exception.application_exception THEN
	  --
	  IF hr_multi_message.exception_add
	    (p_associated_column1 => 'PAY_GRADE_RULES_F.RATE_TYPE') THEN
		--
		hr_utility.set_location(' Leaving : '||l_proc,998);
		--
		RAISE;
		--
	  END IF;
	  --
	  hr_utility.set_location(' Leaving : '||l_proc,999);
	  --
END chk_rate_type;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_rate_id >-----------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_rate_id
  (p_rate_id                  IN pay_grade_rules_f.rate_id%TYPE
  ,p_rate_type                IN pay_grade_rules_f.rate_type%TYPE
  ,p_business_group_id        IN pay_grade_rules_f.business_group_id%TYPE
  ,p_grade_or_spinal_point_id IN pay_grade_rules_f.grade_or_spinal_point_id%TYPE
  ,p_effective_date           IN DATE
  ,p_grade_rule_id            IN pay_grade_rules_f.grade_rule_id%TYPE
  ,p_object_version_number    IN pay_grade_rules_f.object_version_number%TYPE) IS
  --
  CURSOR csr_chk_rate IS
    SELECT rate_id
	FROM   pay_rates
	WHERE  rate_id = p_rate_id
	AND    business_group_id = p_business_group_id;
  --
  CURSOR csr_duplicate_rate IS
    SELECT rate_id
	FROM  pay_grade_rules_f pgr
	WHERE pgr.rate_id = p_rate_id
	AND   pgr.grade_or_spinal_point_id = p_grade_or_spinal_point_id
	AND   (  (p_grade_rule_id IS NULL
                  AND pgr.effective_end_date > p_effective_date)
               OR (p_grade_rule_id IS NOT NULL
                   AND pgr.grade_rule_id <> p_grade_rule_id));
  --
  CURSOR csr_dupl_asg_rate_type IS
    SELECT pr1.rate_id
	FROM  pay_grade_rules_f pgr
             ,pay_rates pr1
             ,pay_rates pr2
        WHERE pgr.grade_or_spinal_point_id = p_grade_or_spinal_point_id
        AND   (  (p_grade_rule_id IS NULL
                  AND pgr.effective_end_date > p_effective_date)
               OR (p_grade_rule_id IS NOT NULL
                   AND pgr.grade_rule_id <> p_grade_rule_id
                   AND p_effective_date BETWEEN pgr.effective_start_date
                                        AND pgr.effective_end_date))
        AND   pgr.rate_type = 'A'
        AND   pgr.rate_id = pr1.rate_id
        AND   p_rate_type = 'A'
        AND   p_rate_id = pr2.rate_id
        AND   nvl(pr2.asg_rate_type,'X') = nvl(pr1.asg_rate_type,'Y');
  --
  l_proc         VARCHAR2(72) := g_package||'chk_rate_id';
  l_dummy_id     NUMBER(15);
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Only proceed with validation if :
  -- a) The rate_type is changing or new
  -- b) The value for rate_type is changing and not null
  --
  IF ( (p_grade_rule_id IS NULL) OR
      ((p_grade_rule_id IS NOT NULL) AND
       (pay_pgr_shd.g_old_rec.rate_id <> p_rate_id))) THEN
        --
	hr_utility.set_location(l_proc, 30);
	--
	-- Check that the rate exists.
	--
        OPEN csr_chk_rate;
	FETCH csr_chk_rate INTO l_dummy_id;
	--
	IF csr_chk_rate%NOTFOUND THEN
	  --
	  CLOSE csr_chk_rate;
	  --
	  hr_utility.set_message(800, 'HR_289683_INVALID_ASG_RATE');
          hr_utility.raise_error;
          --
        ELSE
	  --
	  CLOSE csr_chk_rate;
	  --
        END IF;
        --
	hr_utility.set_location(l_proc, 40);
        --
	-- Check that the rate type has not been defined
	-- more than once for the grade, scale or assignment
	--
	OPEN csr_duplicate_rate;
	FETCH csr_duplicate_rate INTO l_dummy_id;
	--
	IF csr_duplicate_rate%FOUND THEN
	  --
	  CLOSE csr_duplicate_rate;
	  --
	  IF p_rate_type = 'A' THEN
	    --
            hr_utility.set_message(800, 'HR_289684_ASG_RATE_USED');
            hr_utility.raise_error;
            --
	  ELSIF p_rate_type = 'SP' THEN
	    --
            hr_utility.set_message(800, 'HR_289686_PROG_POINT_ALREADY_U');
            hr_utility.raise_error;
		--
	  ELSIF p_rate_type = 'G' THEN
	    --
            hr_utility.set_message(800, 'HR_289685_GRADE_RATE_ALREADY_U');
            hr_utility.raise_error;
		--
          END IF;
           --
	ELSE
	  --
	  CLOSE csr_duplicate_rate;
	  --
          -- Check if the same assignment already has a row of the same asg_rate_type
          --
          IF p_rate_type='A' THEN
            OPEN csr_dupl_asg_rate_type;
            FETCH csr_dupl_asg_rate_type into l_dummy_id;
            IF csr_dupl_asg_rate_type%found THEN
               CLOSE csr_dupl_asg_rate_type;
                 hr_utility.set_message(800, 'HR_449036_ASGRAT_DUP_ASGRAT');
                 hr_utility.raise_error;
            ELSE
               CLOSE csr_dupl_asg_rate_type;
            END IF;
          END IF;
        END IF;
      --
  END IF;
  --
  hr_utility.set_location(' Leaving : '||l_proc,999);
  --
  EXCEPTION
    --
	WHEN app_exception.application_exception THEN
	  --
	  IF hr_multi_message.exception_add
	    (p_associated_column1 => 'PAY_GRADE_RULES_F.RATE_ID') THEN
		--
		hr_utility.set_location(' Leaving : '||l_proc,998);
		--
		RAISE;
		--
	  END IF;
	  --
	  hr_utility.set_location(' Leaving : '||l_proc,997);
	  --
END chk_rate_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_grade_or_spinal_point_id >----------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_grade_or_spinal_point_id
  (p_grade_rule_id            IN pay_grade_rules_f.grade_rule_id%TYPE
  ,p_business_group_id        IN pay_grade_rules_f.business_group_id%TYPE
  ,p_effective_date           IN DATE
  ,p_grade_or_spinal_point_id IN pay_grade_rules_f.grade_or_spinal_point_id%TYPE
  ,p_rate_type                IN pay_grade_rules_f.rate_type%TYPE
  ,p_object_version_number    IN pay_grade_rules_f.object_version_number%TYPE) IS
  --
  -- Delcare Local Variables
  --
  l_proc            VARCHAR2(72) := g_package || 'chk_grade_or_spinal_point_id';
  --l_eligy_prfl_id   per_cagr_entitlement_lines_f.oipl_id%TYPE;
  l_assignment_id   per_assignments_f.assignment_id%TYPE;
  l_grade_id        per_grades.grade_id%TYPE;
  l_spinal_point_id per_spinal_points.spinal_point_id%TYPE;
  l_dummy_id        NUMBER(15);
  --
  --
  -- Delcare Cursors
  --
  CURSOR csr_chk_assignment_id IS
    SELECT paf.assignment_id
	FROM   per_assignments_f PAF
	WHERE  paf.business_group_id = p_business_group_id
	AND    paf.assignment_id     = l_assignment_id
    AND    paf.assignment_type   = 'C'
	AND    p_effective_date BETWEEN paf.effective_start_date
                                AND paf.effective_end_date;
  --
  CURSOR csr_chk_grade_id IS
    SELECT g.grade_id
	FROM   per_grades g
	WHERE  g.grade_id = l_grade_id
	AND    p_effective_date BETWEEN g.date_from
               AND nvl(g.date_to, p_effective_date + 1)
    AND    g.business_group_id = p_business_group_id; -- Bug 3640364
  --
  CURSOR csr_chk_spinal_point_id IS
    SELECT spinal_point_id psp
	FROM   per_spinal_points psp
	WHERE  psp.business_group_id = p_business_group_id
	AND    psp.spinal_point_id   = l_spinal_point_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'grade_or_spinal_point_id'
    ,p_argument_value => p_grade_or_spinal_point_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The grade_or_spinal_point_id is changing or new
  -- b) The value for grade_or_spinal_point_id is changing and not null
  --
  IF ( (p_grade_rule_id IS NULL) OR
      ((p_grade_rule_id IS NOT NULL) AND
       (pay_pgr_shd.g_old_rec.grade_or_spinal_point_id <>
        p_grade_or_spinal_point_id))) THEN
        --
	hr_utility.set_location(l_proc, 30);
	--
	-- IF the rate type is for Assignment Rates then
	-- check that p_grade_or_spinal_point_id exists in
	-- per_assignments_f and that the assignment is
        -- a CWK assignment.
	--
	IF p_rate_type = 'A' THEN
          hr_utility.set_location(l_proc,40);
	  l_assignment_id := p_grade_or_spinal_point_id;
          --
	  OPEN csr_chk_assignment_id;
	  FETCH csr_chk_assignment_id INTO l_dummy_id;
	  IF csr_chk_assignment_id%NOTFOUND THEN
            CLOSE csr_chk_assignment_id;
            hr_utility.set_message(800, 'HR_289541_PJU_INV_ASG_ID');
            hr_utility.raise_error;
	  ELSE
            CLOSE csr_chk_assignment_id;
	  END IF;
	--
	-- IF the rate type is for Grade Rates then
	-- check that p_grade_or_spinal_point_id exists in
	-- per_grades
	--
    ELSIF p_rate_type = 'G' THEN
	  --
          hr_utility.set_location(l_proc,60);
	  l_grade_id := p_grade_or_spinal_point_id;
	  --
	  OPEN csr_chk_grade_id;
	  FETCH csr_chk_grade_id INTO l_dummy_id;
	  IF csr_chk_grade_id%NOTFOUND THEN
             CLOSE csr_chk_grade_id;
             hr_utility.set_message(800, 'HR_PSF_INVALID_GRADE');
             hr_utility.raise_error;
	  ELSE
             CLOSE csr_chk_grade_id;
	  END IF;
	--
	-- IF the rate type is for Scale Rates then
	-- check that p_grade_or_spinal_point_id exists in
	-- per_spinal_points
	--
    ELSIF p_rate_type = 'SP' THEN
	  --
	  hr_utility.set_location(l_proc,80);
	  l_spinal_point_id := p_grade_or_spinal_point_id;
	  --
	  OPEN csr_chk_spinal_point_id;
	  FETCH csr_chk_spinal_point_id INTO l_dummy_id;
	  IF csr_chk_spinal_point_id%NOTFOUND THEN
            CLOSE csr_chk_spinal_point_id;
            hr_utility.set_message(800, 'HR_289687_SPINAL_POINT_INV');
            hr_utility.raise_error;
	  ELSE
            CLOSE csr_chk_spinal_point_id;
	  END IF;
    END IF;
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,997);
  --
  EXCEPTION
    --
    WHEN app_exception.application_exception THEN
      IF hr_multi_message.exception_add
      (p_associated_column1 => 'PAY_GRADE_RULES_F.GRADE_OR_SPINAL_POINT_ID') THEN
       hr_utility.set_location(' Leaving: '|| l_proc,998);
       --
       RAISE;
       --
       END IF;
       hr_utility.set_location(' Leaving: '||l_proc,999);
       --
END chk_grade_or_spinal_point_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_currency_code >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_currency_code
  (p_rate_type             IN pay_grade_rules_f.rate_type%TYPE
  ,p_currency_code         IN pay_grade_rules_f.currency_code%TYPE
  ,p_grade_rule_id         IN pay_grade_rules_f.grade_rule_id%TYPE
  ,p_rate_id               IN pay_grade_rules_f.rate_id%TYPE
  ,p_effective_date        IN DATE
  ,p_object_version_number IN pay_grade_rules_f.object_version_number%TYPE) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_currency_code';
  l_dummy_code   fnd_currencies.currency_code%TYPE;
  l_rate_uom     pay_rates.rate_uom%TYPE;
  --
  CURSOR csr_chk_currency_code IS
    SELECT fc.currency_code
	FROM   fnd_currencies fc
	WHERE  fc.currency_code = p_currency_code;
  --
  CURSOR csr_get_rate_uom IS
    SELECT pr.rate_uom
    FROM   pay_rates pr
    WHERE  pr.rate_id = p_rate_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Only proceed with validation if :
  -- a) The currency is changing or new
  -- b) The value for currency is changing and not null
  --
  IF ( (p_grade_rule_id IS NULL) OR
      ((p_grade_rule_id IS NOT NULL) AND
       (pay_pgr_shd.g_old_rec.currency_code <> p_currency_code))) THEN
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- If the rate is for assignment rates then check
	-- the currency code is not null and exists.
	--
	IF p_rate_type = 'A' THEN
      --
      hr_utility.set_location(l_proc, 40);
	  --
      -- If the currency code is NULL then raise an error
      -- as the currency code is mandatory when the rate_type is for
      -- assignment rates.
      --
      IF p_currency_code IS NULL THEN
        --
        hr_utility.set_message(800, 'HR_289688_CURRENCY_CODE_NULL');
        hr_utility.raise_error;
        --
        -- If the currency code is not null then check that
        -- the currency code exists.
        --
      ELSE
        --
        hr_utility.set_location(l_proc, 50);
        --
        OPEN csr_chk_currency_code;
	    FETCH csr_chk_currency_code INTO l_dummy_code;
	    --
	    IF csr_chk_currency_code%NOTFOUND THEN
	      --
		  CLOSE csr_chk_currency_code;
		  --
		  hr_utility.set_message(800, 'HR_289705_INVALID_CURRENCY');
          hr_utility.raise_error;
          --
	    ELSE
	      --
          CLOSE csr_chk_currency_code;
		  --
        END IF;
        --
      END IF;
      --
      hr_utility.set_location(l_proc, 60);
      --
	  -- If the rate is a Grade or Scale Rate and
	  -- the currency code has been populated then
	  -- validate it.
	  --
	ELSIF p_rate_type <> 'A' THEN
      --
      hr_utility.set_location(l_proc, 70);
      --
      -- Fetch the rate unit of measure for the pay rate
      --
      OPEN csr_get_rate_uom;
      FETCH csr_get_rate_uom INTO l_rate_uom;
      --
      CLOSE csr_get_rate_uom;
      --
      -- If the unit of measure has not been set to Money and the
      -- currency code has been populated then raise an error.
      --
      IF l_rate_uom <> 'M' AND p_currency_code IS NOT NULL THEN
        --
	    hr_utility.set_message(800, 'HR_289689_CCY_CODE_NOT_NULL');
        hr_utility.raise_error;
        --
        -- If the unit of measure has been set to Money and the
        -- currency code has NOT been populated then raise an error.
        --
      ELSIF l_rate_uom = 'M' AND p_currency_code IS NULL THEN
        --
        -- Fix for bug 3380687 starts here.
        -- for rate type G and SP the currency is optional.
        --
        IF p_rate_type <> 'G' and p_rate_type <> 'SP' then
        --
          hr_utility.set_message(800, 'HR_289688_CURRENCY_CODE_NULL');
          hr_utility.raise_error;
        --
        END IF;
        --
        -- Fix for bug 3380687 ends here.
        --
        -- If the unit of measure has been set to Money and the
        -- cuurency has been populated then check that the currency
        -- code exists.
        --
      ELSIF l_rate_uom = 'M' AND p_currency_code IS NOT NULL THEN
        --
        hr_utility.set_location(l_proc, 80);
        --
        OPEN csr_chk_currency_code;
	    FETCH csr_chk_currency_code INTO l_dummy_code;
	    --
	    IF csr_chk_currency_code%NOTFOUND THEN
	      --
		  CLOSE csr_chk_currency_code;
		  --
		  hr_utility.set_message(800, 'HR_289705_INVALID_CURRENCY');
          hr_utility.raise_error;
          --
	    ELSE
	      --
          CLOSE csr_chk_currency_code;
		  --
        END IF;
        --
      END IF;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving : '||l_proc,999);
  --
  EXCEPTION
    --
	WHEN app_exception.application_exception THEN
	  --
	  IF hr_multi_message.exception_add
	    (p_associated_column1 => 'PAY_GRADE_RULES_F.CURRENCY_CODE') THEN
		--
		hr_utility.set_location(' Leaving : '||l_proc,998);
		--
		RAISE;
		--
	  END IF;
	  --
	  hr_utility.set_location(' Leaving : '||l_proc,999);
	  --
END chk_currency_code;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_values_format >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_values_format(p_rate_id number
                    ,p_rate_type varchar2
                    ,p_value varchar2
                    ,p_minimum varchar2
		    ,p_maximum varchar2
		    ,p_mid_value varchar2
                    ,p_curcode varchar2) IS
  --
  l_output varchar2(255);
  l_rgeflg varchar2(255);
  l_format varchar2(255);
  l_input  varchar2(255);
  l_proc  VARCHAR2(72) := g_package||'chk_values_format';
  l_bg_id  pay_rates.business_group_id%type;               -- added for bug 6016428 (for backward compatibility)
  l_bg_curr_code per_business_groups.currency_code%type;   -- added for bug 6016428 (for backward compatibility)

  --
  CURSOR csr_get_rate_uom IS
  SELECT pr.rate_uom
  FROM   pay_rates pr
  WHERE  pr.rate_id = p_rate_id;
  --

   CURSOR csr_bg_curr_cd(l_bg_id number) IS
   SELECT org_information10
   FROM hr_organization_information hoi
   WHERE hoi.organization_id = l_bg_id
    AND hoi.org_information_context = 'Business Group Information'
    AND hoi.org_information2 IS NOT NULL
    AND EXISTS
       ( SELECT NULL
           FROM hr_org_info_types_by_class oitbc,
                hr_organization_information org_info
          WHERE org_info.organization_id = hoi.organization_id
            AND org_info.org_information_context = 'CLASS'
            AND org_info.org_information2  = 'Y'
            AND oitbc.org_classification   = org_info.org_information1
            AND oitbc.org_information_type = 'Business Group Information'
        );
  --

BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  open csr_get_rate_uom;
  fetch csr_get_rate_uom into l_format;
  close csr_get_rate_uom;
  --
  -- Rate UOM is not null column. Therefore no need to check it again.
  --

  /* changes for bug 6016428 starts */
  hr_utility.set_location('Getting business Group ID ',11);
  select business_group_id
  into l_bg_id
  from pay_rates
  where rate_id = p_rate_id;
  --
  hr_utility.set_location('Getting default Currency code for business Group ID ',12);
  OPEN csr_bg_curr_cd(l_bg_id);
  FETCH csr_bg_curr_cd INTO l_bg_curr_code;
  CLOSE csr_bg_curr_cd;
  /* changes for bug 6016428 ends */

  --
  if p_value is not null then
    --
    hr_utility.set_location(l_proc, 15);
    --for bug 5882341, checkformat require p_value argument in a formated
    -- string not in a canonical string, so we use the changeformat function
    -- which change the canonical string into Formated string..
    -- insted of l_input := p_value; we are using following call

    -- l_input := p_value;
    hr_chkfmt.changeformat( input  =>p_value,
                            output  => l_input,
                            format  => l_format,
                            curcode => nvl(p_curcode, l_bg_curr_code)); -- Bug 6016428
    --for bug 5882341
    hr_chkfmt.checkformat(l_input
                         ,l_format
			 ,l_output
			 ,null
			 ,null
			 ,null
			 ,l_rgeflg
			 ,nvl(p_curcode, l_bg_curr_code)); -- Bug 6016428
    --
  end if;
  --
  if p_maximum is not null then
    --
    hr_utility.set_location(l_proc, 20);
    --start changes for bug 6346419
    --l_input := p_maximum;
    hr_chkfmt.changeformat( input  =>p_maximum,
                            output  => l_input,
                            format  => l_format,
                            curcode => nvl(p_curcode, l_bg_curr_code)); -- Bug 6016428
   --end changes for bug 6346419
    hr_chkfmt.checkformat(l_input
                         ,l_format
			 ,l_output
			 ,null
			 ,null
			 ,null
			 ,l_rgeflg
			 ,nvl(p_curcode, l_bg_curr_code)); -- Bug 6016428
    --
  end if;
  --
  if p_minimum is not null then
    --
    hr_utility.set_location(l_proc, 30);
    --start changes for bug 6346419
    --l_input := p_minimum;
    hr_chkfmt.changeformat( input  =>p_minimum,
                            output  => l_input,
                            format  => l_format,
                            curcode => nvl(p_curcode, l_bg_curr_code)); -- Bug 6016428
   --end changes for bug 6346419
    hr_chkfmt.checkformat(l_input
                         ,l_format
			 ,l_output
			 ,null
			 ,null
			 ,null
			 ,l_rgeflg
			 ,nvl(p_curcode, l_bg_curr_code)); -- Bug 6016428
    --
  end if;
  --
  if p_mid_value is not null then
    --
    hr_utility.set_location(l_proc, 40);
    --start changes for bug 6346419
    --l_input := p_mid_value;
    hr_chkfmt.changeformat( input  =>p_mid_value,
                            output  => l_input,
                            format  => l_format,
                            curcode => nvl(p_curcode, l_bg_curr_code)); -- Bug 6016428
    --end changes for bug 6346419
    hr_chkfmt.checkformat(l_input
                         ,l_format
			 ,l_output
			 ,null
			 ,null
			 ,null
			 ,l_rgeflg
			 ,nvl(p_curcode, l_bg_curr_code)); -- Bug 6016428
    --
  end if;
  --
  hr_utility.set_location('Leaving  : '||l_proc,999);
  --
END chk_values_format;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_assignment_rate_value >----------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_assignment_rate_value
  (p_value IN pay_grade_rules_f.value%TYPE) IS
  --
  l_proc  VARCHAR2(72) := g_package||'chk_assignment_rate_value';
  l_value NUMBER;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Copy the value into a numeric variable.
  -- If p_value contains anything apart from numbers
  -- then a VALUE_ERROR will be raised and
  -- trapped in the exception handler.
  --
  l_value := p_value;
  --
  hr_utility.set_location('Leaving  : '||l_proc,999);
  --
EXCEPTION
  --
  WHEN VALUE_ERROR THEN
	--
	hr_utility.set_message(800, 'HR_289690_ASS_RATE_VAL_NOT_NUM');
        hr_utility.raise_error;
	--
END chk_assignment_rate_value;
--
--  ---------------------------------------------------------------------------
--  |-------------------------------< chk_value >-----------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_value
  (p_rate_type             IN pay_grade_rules_f.rate_type%TYPE
  ,p_value                 IN pay_grade_rules_f.value%TYPE
  ,p_grade_rule_id         IN pay_grade_rules_f.grade_rule_id%TYPE
  ,p_currency_code         IN pay_grade_rules_f.currency_code%TYPE
  ,p_effective_date        IN DATE
  ,p_object_version_number IN pay_grade_rules_f.object_version_number%TYPE) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_value';
  l_value        NUMBER;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for value has changed
  --
  IF ( (p_grade_rule_id IS NULL) OR
      ((p_grade_rule_id IS NOT NULL) AND
       (pay_pgr_shd.g_old_rec.value <> p_value))) THEN
    --
    hr_utility.set_location(l_proc, 30);
        --
        -- If the rate is for assignment rates and the
	-- value field is null then raise an error.
	--
	IF p_rate_type = 'A' THEN
	  --
          hr_utility.set_location(l_proc, 40);
          --
	  IF p_value IS NULL
          OR sign(p_value) = -1 THEN
	  --
	  hr_utility.set_message(800, 'HR_289691_ASS_RATE_VALUE_NULL');
          hr_utility.raise_error;
          --
	  ELSE
          --
          hr_utility.set_location(l_proc, 50);
	  --
          -- Check that the p_value is in numeric format
          --
	  chk_assignment_rate_value(p_value => p_value);
	  --
      END IF;
	  --
      -- IF the rate is for assignment rates then check
      -- the currency and value field combination.
      --
    ELSIF p_rate_type <> 'A' THEN
      --
      hr_utility.set_location(l_proc, 60);
      --
      -- If the currency code has been entered then
      -- check that the value field has also been entered.
      --
      -- Fix for bug 3049789 starts here.
      -- No check needed for the rate type other than A.
      --
        null;
      /*
      IF p_currency_code IS NOT NULL and p_value IS NULL THEN
        --
        hr_utility.set_message(800, 'HR_289706_VALUE_NULL');
        hr_utility.raise_error;
        --
      END IF;
      */
      --
      -- Fix for bug 3049789 ends here.
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving : '||l_proc,997);
  --
  EXCEPTION
    --
	WHEN app_exception.application_exception THEN
	  --
	  IF hr_multi_message.exception_add
	    (p_associated_column1 => 'PAY_GRADE_RULES_F.VALUE') THEN
		--
		hr_utility.set_location(' Leaving : '||l_proc,998);
		--
		RAISE;
		--
	  END IF;
	  --
	  hr_utility.set_location(' Leaving : '||l_proc,999);
	  --
END chk_value;
--
-- Fix for bug 3049789 starts here.
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_value_min_max_comb >-----------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_value_min_max_comb
  (p_rate_type             IN pay_grade_rules_f.rate_type%TYPE
  ,p_grade_rule_id         IN pay_grade_rules_f.grade_rule_id%TYPE
  ,p_value                 IN pay_grade_rules_f.value%TYPE
  ,p_minimum               IN pay_grade_rules_f.minimum%TYPE
  ,p_maximum               IN pay_grade_rules_f.maximum%TYPE) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_value_min_max_comb';
  l_value        NUMBER;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for value has changed
  --
  IF ( (p_grade_rule_id IS NULL) OR
      ((p_grade_rule_id IS NOT NULL) AND
       (nvl(pay_pgr_shd.g_old_rec.value,-1) <> nvl(p_value,-1) OR
        nvl(pay_pgr_shd.g_old_rec.minimum,-1) <> nvl(p_minimum,-1) OR
        nvl(pay_pgr_shd.g_old_rec.maximum,-1) <> nvl(p_maximum,-1) ))) THEN
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- If the rate is for Grade rates, either value OR a minimum and Maximum
    -- should be specified.
	--
	IF p_rate_type = 'G' THEN
	--
           hr_utility.set_location(l_proc, 40);
           IF p_value IS NULL and
             (p_minimum IS NULL or p_maximum IS NULL) THEN
              --
              hr_utility.set_message(800, 'PER_449141_VALUE_OR_MIN_MAX');
              hr_utility.raise_error;
              --
           END IF;
        --
	END IF;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving : '||l_proc,997);
  --
  EXCEPTION
    --
	WHEN app_exception.application_exception THEN
	  --
	  IF hr_multi_message.exception_add
	    (p_associated_column1 => 'PAY_GRADE_RULES_F.VALUE') THEN
		--
		hr_utility.set_location(' Leaving : '||l_proc,998);
		--
		RAISE;
		--
	  END IF;
	  --
	  hr_utility.set_location(' Leaving : '||l_proc,999);
	  --
END chk_value_min_max_comb;
--
-- Fix for bug 3049789 ends here.
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_grade_rule_id                        in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_grade_rules_f pgr
     where pgr.grade_rule_id = p_grade_rule_id
       and pbg.business_group_id = pgr.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'grade_rule_id'
    ,p_argument_value     => p_grade_rule_id
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
     hr_multi_message.add
       (p_associated_column1
         => nvl(p_associated_column1,'GRADE_RULE_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_grade_rule_id                        in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_grade_rules_f pgr
     where pgr.grade_rule_id = p_grade_rule_id
       and pbg.business_group_id = pgr.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'grade_rule_id'
    ,p_argument_value     => p_grade_rule_id
    );
  --
  if ( nvl(pay_pgr_bus.g_grade_rule_id, hr_api.g_number)
       = p_grade_rule_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_pgr_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
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
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pay_pgr_bus.g_grade_rule_id               := p_grade_rule_id;
    pay_pgr_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
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
  (p_effective_date  in date
  ,p_rec             in pay_pgr_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_pgr_shd.api_updating
      (p_grade_rule_id                    => p_rec.grade_rule_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
    --
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_grade_rule_id                    in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  hr_utility.set_location('Entering:'||l_proc, 20);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
	hr_utility.set_location('Entering:'||l_proc, 30);
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
	hr_utility.set_location('Entering:'||l_proc, 40);
	--
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'grade_rule_id'
      ,p_argument_value => p_grade_rule_id
      );
    --
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_pgr_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pay_pgr_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  -- Validate Dependent Attributes
  --
  pay_pgr_bus.chk_rate_type
    (p_rate_type             => p_rec.rate_type
    ,p_effective_date        => p_effective_date
    ,p_grade_rule_id         => p_rec.grade_rule_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(l_proc, 40);
  --
  pay_pgr_bus.chk_grade_or_spinal_point_id
    (p_grade_rule_id            => p_rec.grade_rule_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_effective_date           => p_effective_date
    ,p_grade_or_spinal_point_id => p_rec.grade_or_spinal_point_id
    ,p_rate_type                => p_rec.rate_type
    ,p_object_version_number    => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 50);
  --
  pay_pgr_bus.chk_currency_code
    (p_rate_type                  => p_rec.rate_type
    ,p_currency_code              => p_rec.currency_code
    ,p_grade_rule_id              => p_rec.grade_rule_id
    ,p_rate_id                    => p_rec.rate_id
    ,p_effective_date             => p_effective_date
    ,p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 60);
  --
  pay_pgr_bus.chk_value
    (p_rate_type                  => p_rec.rate_type
    ,p_value                      => p_rec.value
    ,p_grade_rule_id              => p_rec.grade_rule_id
    ,p_currency_code              => p_rec.currency_code
    ,p_effective_date             => p_effective_date
    ,p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Fix for bug 3049789 starts here.
  --
  pay_pgr_bus.chk_value_min_max_comb
  (p_rate_type             => p_rec.rate_type
  ,p_grade_rule_id         => p_rec.grade_rule_id
  ,p_value                 => p_rec.value
  ,p_minimum               => p_rec.minimum
  ,p_maximum               => p_rec.maximum);
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Fix for bug 3049789 ends here.
  --
  pay_pgr_bus.chk_rate_id
    (p_rate_id                    => p_rec.rate_id
    ,p_rate_type                  => p_rec.rate_type
    ,p_business_group_id          => p_rec.business_group_id
    ,p_grade_or_spinal_point_id   => p_rec.grade_or_spinal_point_id
    ,p_effective_date             => p_effective_date
    ,p_grade_rule_id              => p_rec.grade_rule_id
    ,p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 90);
  --
  pay_pgr_bus.chk_values_format
    (p_rate_id => p_rec.rate_id
    ,p_rate_type => p_rec.rate_type
    ,p_value     => p_rec.value
    ,p_minimum  => p_rec.minimum
    ,p_maximum  => p_rec.maximum
    ,p_mid_value => p_rec.mid_value
    ,p_curcode => p_rec.currency_code);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_pgr_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pay_pgr_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Validate Dependent Attributes
  --
  pay_pgr_bus.chk_rate_type
    (p_rate_type             => p_rec.rate_type
    ,p_effective_date        => p_effective_date
    ,p_grade_rule_id         => p_rec.grade_rule_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(l_proc, 60);
  --
  pay_pgr_bus.chk_grade_or_spinal_point_id
    (p_grade_rule_id            => p_rec.grade_rule_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_effective_date           => p_effective_date
    ,p_grade_or_spinal_point_id => p_rec.grade_or_spinal_point_id
    ,p_rate_type                => p_rec.rate_type
    ,p_object_version_number    => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 70);
  --
  pay_pgr_bus.chk_currency_code
  (p_rate_type                  => p_rec.rate_type
  ,p_currency_code              => p_rec.currency_code
  ,p_grade_rule_id              => p_rec.grade_rule_id
  ,p_rate_id                    => p_rec.rate_id
  ,p_effective_date             => p_effective_date
  ,p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 80);
  --
  pay_pgr_bus.chk_value
  (p_rate_type                  => p_rec.rate_type
  ,p_value                      => p_rec.value
  ,p_grade_rule_id              => p_rec.grade_rule_id
  ,p_currency_code              => p_rec.currency_code
  ,p_effective_date             => p_effective_date
  ,p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,90);
  --
  -- Fix for bug 3049789 starts here.
  --
  pay_pgr_bus.chk_value_min_max_comb
  (p_rate_type             => p_rec.rate_type
  ,p_grade_rule_id         => p_rec.grade_rule_id
  ,p_value                 => p_rec.value
  ,p_minimum               => p_rec.minimum
  ,p_maximum               => p_rec.maximum);
  --
  hr_utility.set_location(l_proc, 100);
  --
  -- Fix for bug 3049789 ends here.
  --
  pay_pgr_bus.chk_rate_id
    (p_rate_id                    => p_rec.rate_id
    ,p_rate_type                  => p_rec.rate_type
    ,p_business_group_id          => p_rec.business_group_id
    ,p_grade_or_spinal_point_id   => p_rec.grade_or_spinal_point_id
    ,p_effective_date             => p_effective_date
    ,p_grade_rule_id              => p_rec.grade_rule_id
    ,p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 110);
  --
  pay_pgr_bus.chk_values_format
    (p_rate_id => p_rec.rate_id
    ,p_rate_type => p_rec.rate_type
    ,p_value     => p_rec.value
    ,p_minimum  => p_rec.minimum
    ,p_maximum  => p_rec.maximum
    ,p_mid_value => p_rec.mid_value
    ,p_curcode => p_rec.currency_code);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_pgr_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_grade_rule_id                    => p_rec.grade_rule_id
    );
  --

  hr_utility.set_location(' Leaving:'||l_proc, 20);

End delete_validate;
--
end pay_pgr_bus;

/
