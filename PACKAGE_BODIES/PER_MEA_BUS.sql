--------------------------------------------------------
--  DDL for Package Body PER_MEA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MEA_BUS" as
/* $Header: pemearhi.pkb 115.9 2002/12/06 12:20:50 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_mea_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_medical_assessment_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_consultation_combination >----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the coonsultation_result and consultation_type are
--    valid combinations
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_consultation_type
--    p_consultation_result
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Public Access.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_consultation_combination
  (p_consultation_type   IN per_medical_assessments.consultation_type%TYPE
  ,p_consultation_result IN per_medical_assessments.consultation_result%TYPE) IS
  --
  -- Declare local variables
  --
  l_proc              varchar2(72)  :=  g_package||'chk_combination_id';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check to see that the Conultation_Result and Type combination
  -- Type combination are valid.
  --
  IF p_consultation_type = 'DA' AND
     p_consultation_result = 'DI' THEN
    --
    hr_utility.set_message(800, 'HR_52734_MEA_INV_TYPE_RESULT');
    hr_utility.raise_error;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
END chk_consultation_combination;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_inc_consul_date >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the consultation_date is after the incident date
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_consultation_date
--    p_incident_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Development Use Only
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_inc_consul_date
  (p_consultation_date IN per_medical_assessments.consultation_date%TYPE
  ,p_incident_id       IN per_medical_assessments.incident_id%TYPE) IS
  --
  -- Declare Local variables
  --
  l_proc           VARCHAR2(72)  :=  g_package||'chk_inc_consul_date';
  l_incident_date  DATE := NULL;
  --
  CURSOR get_incident_date IS
    SELECT incident_date
    FROM   per_work_incidents pwi
    WHERE  pwi.incident_id = p_incident_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- check that the consultation date is
  -- after the incident date
  --
  IF p_incident_id is not NULL THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    OPEN  get_incident_date;
    FETCH get_incident_date INTO l_incident_date;
    CLOSE get_incident_date;
    --
    hr_utility.set_location(l_proc,30);
    --
    IF TRUNC(l_incident_date) > p_consultation_date THEN
      --
      hr_utility.set_message(800, 'HR_289014_INC_CON_DATE_INV');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 50);
  --
END chk_inc_consul_date;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_date_combinations >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the consultation_date and next_consultation_date are
--    valid combinations
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_consultation_date
--    p_next_consultation_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Development Use Only
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_date_combinations
  (p_consultation_date      IN per_medical_assessments.consultation_date%TYPE
  ,p_next_consultation_date IN per_medical_assessments.next_consultation_date%TYPE) IS
  --
  -- Declare Local variables
  --
  l_proc VARCHAR2(72)  :=  g_package||'chk_consultation_date_combinations';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- check that the consultation date is
  -- before the next consultation date
  --
  IF p_consultation_date > nvl(p_next_consultation_date,hr_api.g_eot) THEN
    --
    hr_utility.set_message(800, 'HR_52735_MEA_INV_DATE_COMB');
    hr_utility.raise_error;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 50);
  --
END chk_date_combinations;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_person_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert PERSON_ID is not null and that
--    it exists in per_all_people_f on the effective_date.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_medical_assessment_id
--    p_person_id
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
PROCEDURE chk_person_id
  (p_medical_assessment_id IN per_medical_assessments.medical_assessment_id%TYPE
  ,p_person_id             IN per_medical_assessments.person_id%TYPE
  ,p_effective_date        IN date) is
  --
  l_proc  varchar2(72) := g_package||'chk_person_id';
  l_dummy number;
  --
  CURSOR csr_person_id IS
    SELECT null
    FROM   per_people_f per
    WHERE  per.person_id = p_person_id
    AND    p_effective_date BETWEEN per.effective_start_date
                                AND per.effective_end_date;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check mandatory person_id is set
  --
  if p_person_id is null then
    --
    hr_utility.set_message(800, 'HR_52742_MEA_PERSON_ID_NULL');
    hr_utility.raise_error;
    --
  end if;
  --
  hr_utility.set_location(l_proc, 5);
  --
  -- Only proceed with validation if :
  -- a) on insert (non-updateable param)
  --
  if (p_medical_assessment_id is null) then
     --
     hr_utility.set_location(l_proc, 10);
     --
     -- Check that the person_id is in the per_people_f view on the effective_date.
     --
     open  csr_person_id;
     fetch csr_person_id into l_dummy;
     --
     if csr_person_id%notfound then
       --
       close csr_person_id;
       --
       hr_utility.set_message(800, 'HR_52741_MEA_PERSON_ID_INV');
       hr_utility.raise_error;
       --
     end if;
     --
     close csr_person_id;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_person_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_organization_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate organization_id is in same business group as person, and is
--    external type. Ensure organization_id is defined under class of
--    disability_org.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_disability_id
--    p_organization_id
--    p_business_group_id
--    p_validation_start_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
PROCEDURE chk_organization_id
  (p_medical_assessment_id   IN  per_medical_assessments.disability_id%TYPE
  ,p_organization_id         IN  per_medical_assessments.organization_id%TYPE
  ,p_business_group_id       IN  per_all_people_f.business_group_id%TYPE
  ,p_effective_date          IN  date) IS
  --
  cursor csr_org is
    select   business_group_id
    from     hr_all_organization_units hou
    where    hou.organization_id = p_organization_id
    and      p_effective_date between hou.date_from and nvl(hou.date_to, hr_api.g_eot);
  --
  cursor csr_org_inf is
    select   null
    from     hr_organization_information hoi
    where    hoi.organization_id = p_organization_id
    and      hoi.org_information_context = 'CLASS'
    and      hoi.org_information1 = 'MEDICAL_ASSESSMENT_ORG'
    and      hoi.org_information2 = 'Y';
  --
  l_exists               varchar2(1);
  l_proc                 varchar2(72)  :=  g_package||'chk_organization_id';
  l_business_group_id    per_assignments_f.business_group_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date);
  --
  IF  p_organization_id is not null AND
    per_mea_shd.g_old_rec.organization_id <> p_organization_id THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- check org exists in hr_all_organization_units (fk) for the persons bg
    -- within the validation date range.
    --
    OPEN csr_org;
    FETCH csr_org INTO l_business_group_id;
    --
    IF csr_org%notfound THEN
      --
      CLOSE csr_org;
      --
      -- error as org not found
      --
      hr_utility.set_message(800, 'HR_52740_MEA_SERV_PROV_INV');
      hr_utility.raise_error;
      --
    ELSIF l_business_group_id <> p_business_group_id THEN
      --
      CLOSE csr_org;
      --
      -- error as org is in different business group to person
      --
      hr_utility.set_message(800, 'HR_52744_MEA_ORG_BG_INV');
      hr_utility.raise_error;
      --
    END IF;
    --
    CLOSE csr_org;
    --
    hr_utility.set_location(l_proc, 40);
    --
    -- check org exists in hr_organization_information for the relevant
    -- organisation class.
    --
    OPEN  csr_org_inf;
    FETCH csr_org_inf INTO l_exists;
    --
    IF csr_org_inf%notfound THEN
      --
      CLOSE csr_org_inf;
      --
      -- error as org is not in the correct class of disability_org
      --
      hr_utility.set_message(800, 'HR_52743_MEA_SER_ORG_CLASS_INV');
      hr_utility.raise_error;
      --
    END IF;
    --
    CLOSE csr_org_inf;
    --
    -- end if;
    --
  END IF;
  --
  hr_utility.set_location('Entering:'|| l_proc, 50);
  --
END chk_organization_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_consultation_date_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate consultation_date not after the next consultation date
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_consultation_date
--    p_next_consultation_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
PROCEDURE chk_consultation_date
  (p_consultation_date      IN per_medical_assessments.consultation_date%TYPE,
   p_next_consultation_date IN per_medical_assessments.next_consultation_date%TYPE) IS
  --
  -- Declare Local variables
  --
  l_proc VARCHAR2(72)  :=  g_package||'chk_consultation_date';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'consultation_date'
    ,p_argument_value => p_consultation_date);
  --
  -- Check that the next_consultation_date is valid
  -- in relation to the consultation_date
  --
  per_mea_bus.chk_date_combinations
    (p_next_consultation_date => p_next_consultation_date
    ,p_consultation_date      => p_consultation_date);
  --
  hr_utility.set_location('Entering:'|| l_proc, 50);
  --
END chk_consultation_date;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_consultation_type >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that value for mandatory consultation_type has been supplied
--    and that it is unique.
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_medical_assessment_id
--    p_consultation_result
--    p_consultation_type
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Row Handler Use Only
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_consultation_type
  (p_medical_assessment_id IN per_medical_assessments.medical_assessment_id%TYPE
  ,p_consultation_type     IN per_medical_assessments.consultation_type%TYPE
  ,p_consultation_result   IN per_medical_assessments.consultation_result%TYPE
  ,p_effective_date        IN date) IS
  --
  -- Declare Local Variables
  --
  l_proc   varchar2(72) := g_package||'chk_consultation_type';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'consultation_type'
    ,p_argument_value => p_consultation_type);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for consultation type has changed
  --
  IF ( (p_medical_assessment_id is null) OR
       ((p_medical_assessment_id is not null) AND
        (per_mea_shd.g_old_rec.consultation_type <> p_consultation_type))) THEN
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that the consultation type exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'CONSULTATION_TYPE'
      ,p_lookup_code           => p_consultation_type) THEN
      --
      hr_utility.set_location(l_proc, 40);
      --
      hr_utility.set_message(800, 'HR_52736_MEA_CONS_TYPE_INV');
      hr_utility.raise_error;
      --
    END IF;
    --
    -- Check to see that the Conultation_Result and Type combination
    -- Type combination are valid.
    --
    per_mea_bus.chk_consultation_combination
      (p_consultation_type   => p_consultation_type
      ,p_consultation_result => p_consultation_result);
    --
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
END chk_consultation_type;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_consultation_result >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that value for the consultation_result has been supplied
--    and that it is unique.
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_medical_assessment_id
--    p_consultation_result
--    p_consultation_type
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Row Handler Use Only
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_consultation_result
  (p_medical_assessment_id IN per_medical_assessments.medical_assessment_id%TYPE
  ,p_consultation_result   IN per_medical_assessments.consultation_result%TYPE
  ,p_consultation_type     IN per_medical_assessments.consultation_type%TYPE
  ,p_effective_date        IN date) is
  --
  -- Declare Local Variables
  --
  l_proc   varchar2(72) := g_package||'chk_consultation_type';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) Consultation_result is not null
  -- b) The value for consultation result has changed
  --
  IF p_consultation_result IS NOT NULL OR
     per_mea_shd.g_old_rec.consultation_result <> p_consultation_result THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the consultation result exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'CONSULTATION_RESULT'
      ,p_lookup_code           => p_consultation_result) THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      hr_utility.set_message(800, 'HR_52737_MEA_CONS_RES_INV');
      hr_utility.raise_error;
      --
    END IF;
    --
    -- Check to see that the Conultation_Result and Type combination
    -- Type combination are valid.
    --
    per_mea_bus.chk_consultation_combination
      (p_consultation_type   => p_consultation_type
      ,p_consultation_result => p_consultation_result);
    --
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
END chk_consultation_result;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_incident_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that value for incident_id is vlaid
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_incident_od
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Row Handler Use Only
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_incident_id
  (p_incident_id           IN per_medical_assessments.incident_id%TYPE
  ,p_medical_assessment_id IN per_medical_assessments.medical_assessment_id%TYPE) IS
  --
  -- Declare Curors
  --
  CURSOR c_incident_id IS
  SELECT incident_id
  FROM   per_work_incidents pwi
  WHERE  pwi.incident_id = p_incident_id;
  --
  -- Declare local variables
  --
  l_proc     VARCHAR2(72)  :=  g_package||'set_security_group_id';
  l_dummy_id per_medical_assessments.incident_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) Incident ID is not blank
  -- b) The value for incident_id has changed
  --
  IF p_incident_id IS NOT NULL OR
     per_mea_shd.g_old_rec.incident_id <> p_incident_id THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check to see if a work incident record
    -- exists for the incident_id.
    --
    OPEN  c_incident_id;
    FETCH c_incident_id INTO l_dummy_id;
    --
    IF c_incident_id%NOTFOUND THEN
      --
      CLOSE c_incident_id;
      --
      -- Work Incident record not found so id is invalid. Raise Error.
      --
      hr_utility.set_message(800, 'HR_52738_MEA_WORK_INC_INV');
      hr_utility.raise_error;
      --
    END IF;
    --
    CLOSE c_incident_id;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
END chk_incident_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_valid_id_combinations>----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the diability_id and incident_id are not present on
--    another medical assessment record.
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_disability_id
--    p_medical_assessment_id
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Row Handler Use Only
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_valid_id_combinations
  (p_disability_id         IN per_medical_assessments.disability_id%TYPE
  ,p_medical_assessment_id IN per_medical_assessments.medical_assessment_id%TYPE
  ,p_incident_id           IN per_medical_assessments.incident_id%TYPE
  ,p_person_id             IN per_medical_assessments.person_id%TYPE) IS
  --
  -- Declare cursor
  --
  CURSOR   c_valid_id IS
    SELECT medical_assessment_id
    FROM   per_medical_assessments mea
    WHERE  mea.medical_assessment_id <> p_medical_assessment_id
    AND    mea.incident_id           =  p_incident_id
    AND    mea.person_id             =  p_person_id
    AND    mea.disability_id         =  p_disability_id;
  --
  -- Declare local variables
  --
  l_dummy_id per_medical_assessments.medical_assessment_id%TYPE;
  l_proc     VARCHAR2(72)  :=  g_package||'chk_valid_id_combinations';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) Disability ID and Incident ID are not NULL
  -- b) The value for disability_id and Incident ID has changed.
  --
  IF p_disability_id IS NOT NULL AND
     p_incident_id   IS NOT NULL THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Only continue if the disability_id or incident_id have
    -- changed
    --
    IF per_mea_shd.g_old_rec.disability_id <> p_disability_id OR
       per_mea_shd.g_old_rec.incident_id   <> p_incident_id THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      -- Check to see if a medical assessment record exists
      -- with the same disability and incident IDs.
      --
      OPEN  c_valid_id;
      FETCH c_valid_id INTO l_dummy_id;
      --
      hr_utility.set_location(l_proc, 40);
      --
      IF c_valid_id%FOUND THEN
        --
        CLOSE c_valid_id;
        --
        -- Disability record not found so id is invalid. Raise Error.
        --
        hr_utility.set_message(800, 'HR_52745_MEA_INC_DIS_EXISTS');
        hr_utility.raise_error;
        --
      END IF;
      --
     CLOSE c_valid_id;
     --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 50);
  --
END chk_valid_id_combinations;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_inc_against_dis >----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that incident id belongs to the disability record if
--    the disability ID passed in is not null.
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_disability_id
--    p_incident_id
--    p_person_id
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Row Handler Use Only
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--

PROCEDURE chk_inc_against_dis
  (p_disability_id         IN per_medical_assessments.disability_id%TYPE
  ,p_incident_id           IN per_medical_assessments.incident_id%TYPE
  ,p_person_id             IN per_medical_assessments.person_id%TYPE
  ,p_effective_date        IN DATE) IS
  --
  -- Declare cursor
  --
  CURSOR   c_disability_id IS
    SELECT disability_id
    FROM   per_disabilities_f pdf
    WHERE  pdf.disability_id  = p_disability_id
    AND    pdf.person_id      = p_person_id
    AND    pdf.incident_id    = p_incident_id
    AND    p_effective_date BETWEEN pdf.effective_start_date
                            AND     pdf.effective_end_date;
  --
  --
  -- Declare local variables
  --
  l_dummy_id per_medical_assessments.disability_id%TYPE;
  l_proc     VARCHAR2(72)  :=  g_package||'chk_inc_against_dis';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) Disability ID and Incident ID are not NULL
  -- b) The value for disability_id and Incident ID has changed.
  --
  IF p_disability_id IS NOT NULL AND
     p_incident_id   IS NOT NULL THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Only continue if the disability_id or incident_id have
    -- changed
    --
    IF per_mea_shd.g_old_rec.disability_id <> p_disability_id OR
       per_mea_shd.g_old_rec.incident_id   <> p_incident_id THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      -- Check to see if the work incident record has been assigned
      -- to the disability record.
      --
      OPEN  c_disability_id;
      FETCH c_disability_id INTO l_dummy_id;
      --
      hr_utility.set_location(l_proc, 40);
      --
      IF c_disability_id%NOTFOUND THEN
        --
        CLOSE c_disability_id;
        --
        -- Disability record not found so id is invalid. Raise Error.
        --
        hr_utility.set_message(800, 'HR_52764_MEA_INC_DIS_INV');
        hr_utility.raise_error;
        --
      END IF;
      --
     CLOSE c_disability_id;
     --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 50);
  --
END chk_inc_against_dis;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_disability_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that value for disability_id is valid
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_disability_id
--    p_medical_assessment_id
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Row Handler Use Only
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_disability_id
  (p_disability_id         IN per_medical_assessments.disability_id%TYPE
  ,p_medical_assessment_id IN per_medical_assessments.medical_assessment_id%TYPE
  ,p_person_id             IN per_medical_assessments.person_id%TYPE
  ,p_object_version_number IN per_medical_assessments.object_version_number%TYPE
  ,p_effective_date        IN DATE) IS
  --
  -- Declare cursor
  --
  CURSOR   c_disability_id IS
    SELECT disability_id
    FROM   per_disabilities_f pdf
    WHERE  pdf.disability_id = p_disability_id
    AND    pdf.person_id     = p_person_id
    AND    p_effective_date BETWEEN pdf.effective_start_date
                            AND     pdf.effective_end_date;
  --
  -- Declare local variables
  --
  l_dummy_id per_medical_assessments.disability_id%TYPE;
  l_proc     VARCHAR2(72)  :=  g_package||'chk_disability_id';
  --
BEGIN
 --
 hr_utility.set_location('Entering:'|| l_proc, 10);
 --
 -- Only proceed with validation if :
 -- a) Disability ID is not NULL
 -- b) The value for disability_id has changed
 --
 IF p_disability_id is not null then
  --
  IF ((p_medical_assessment_id is null) or
       ((p_medical_assessment_id is not null) and
         (per_dis_shd.g_old_rec.disability_id <> p_disability_id))) then
      --
      hr_utility.set_location(l_proc, 20);
      --
      -- fix #1565679 (point 27) - make disability_id updatable on the medical assessment.
      --
      -- Check to see if a disability record exists for the disability id
      --
      OPEN c_disability_id;
      FETCH c_disability_id INTO l_dummy_id;
      --
      hr_utility.set_location(l_proc, 30);
      --
      IF c_disability_id%NOTFOUND THEN
        --
        CLOSE c_disability_id;
        --
        -- Disability record not found so id is invalid. Raise Error.
        --
        hr_utility.set_message(800, 'HR_52739_MEA_DIS_INV');
        hr_utility.raise_error;
        --
      END IF;
      --
      CLOSE c_disability_id;
      --
  END IF;
 END IF;
 --
 hr_utility.set_location('Leaving:'|| l_proc, 40);
 --
END chk_disability_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_next_consultation_date >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that value for disability_id is valid
--
--  Pre-conditions :
--    Format mask must be supplied.
--
--  In Arguments :
--    p_consultation_date
--    p_next_consultation_date
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Row Handler Use Only
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_next_consultation_date
  (p_next_consultation_date IN per_medical_assessments.next_consultation_date%TYPE
  ,p_consultation_date      IN per_medical_assessments.consultation_date%TYPE) IS
  --
  -- Declare local variables
  --
  l_proc VARCHAR2(72)  :=  g_package||'chk_next_consultation_date';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check that the next_consultation_date is valid
  -- in relation to the consultation_date
  --
  per_mea_bus.chk_date_combinations
    (p_next_consultation_date => p_next_consultation_date
    ,p_consultation_date      => p_consultation_date);
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
END chk_next_consultation_date;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE set_security_group_id
  (p_medical_assessment_id IN NUMBER) is
  --
  -- Declare cursor
  --
  CURSOR csr_sec_grp is
    SELECT pbg.security_group_id
      FROM per_business_groups pbg,
           per_medical_assessments mea,
           per_people_f per
     WHERE mea.medical_assessment_id = p_medical_assessment_id
       AND per.person_id             = mea.person_id
       AND pbg.business_group_id     = per.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'medical_assessment_id'
    ,p_argument_value     => p_medical_assessment_id
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
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_medical_assessment_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_medical_assessments mea,
           per_people_f per,
           per_business_groups pbg
     where mea.medical_assessment_id = p_medical_assessment_id
       and mea.person_id = per.person_id
       and per.business_group_id = pbg.business_group_id;
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
    ,p_argument           => 'medical_assessment_id'
    ,p_argument_value     => p_medical_assessment_id
    );
  --
  if ( nvl(per_mea_bus.g_medical_assessment_id, hr_api.g_number)
       = p_medical_assessment_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_mea_bus.g_legislation_code;
    --
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
    per_mea_bus.g_medical_assessment_id := p_medical_assessment_id;
    per_mea_bus.g_legislation_code      := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
PROCEDURE chk_ddf
  (p_rec in per_mea_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.medical_assessment_id is not null)  and (
    nvl(per_mea_shd.g_old_rec.mea_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information_category, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information1, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information1, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information2, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information2, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information3, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information3, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information4, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information4, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information5, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information5, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information6, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information6, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information7, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information7, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information8, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information8, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information9, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information9, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information10, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information10, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information11, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information11, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information12, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information12, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information13, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information13, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information14, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information14, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information15, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information15, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information16, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information16, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information17, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information17, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information18, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information18, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information19, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information19, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information20, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information20, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information21, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information21, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information22, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information22, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information23, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information23, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information24, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information24, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information25, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information25, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information26, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information26, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information27, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information27, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information28, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information28, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information29, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information29, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.mea_information30, hr_api.g_varchar2) <>
    nvl(p_rec.mea_information30, hr_api.g_varchar2) ))
    or (p_rec.medical_assessment_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Assessment Developer DF'
      ,p_attribute_category              => p_rec.MEA_INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'MEA_INFORMATION1'
      ,p_attribute1_value                => p_rec.mea_information1
      ,p_attribute2_name                 => 'MEA_INFORMATION2'
      ,p_attribute2_value                => p_rec.mea_information2
      ,p_attribute3_name                 => 'MEA_INFORMATION3'
      ,p_attribute3_value                => p_rec.mea_information3
      ,p_attribute4_name                 => 'MEA_INFORMATION4'
      ,p_attribute4_value                => p_rec.mea_information4
      ,p_attribute5_name                 => 'MEA_INFORMATION5'
      ,p_attribute5_value                => p_rec.mea_information5
      ,p_attribute6_name                 => 'MEA_INFORMATION6'
      ,p_attribute6_value                => p_rec.mea_information6
      ,p_attribute7_name                 => 'MEA_INFORMATION7'
      ,p_attribute7_value                => p_rec.mea_information7
      ,p_attribute8_name                 => 'MEA_INFORMATION8'
      ,p_attribute8_value                => p_rec.mea_information8
      ,p_attribute9_name                 => 'MEA_INFORMATION9'
      ,p_attribute9_value                => p_rec.mea_information9
      ,p_attribute10_name                => 'MEA_INFORMATION10'
      ,p_attribute10_value               => p_rec.mea_information10
      ,p_attribute11_name                => 'MEA_INFORMATION11'
      ,p_attribute11_value               => p_rec.mea_information11
      ,p_attribute12_name                => 'MEA_INFORMATION12'
      ,p_attribute12_value               => p_rec.mea_information12
      ,p_attribute13_name                => 'MEA_INFORMATION13'
      ,p_attribute13_value               => p_rec.mea_information13
      ,p_attribute14_name                => 'MEA_INFORMATION14'
      ,p_attribute14_value               => p_rec.mea_information14
      ,p_attribute15_name                => 'MEA_INFORMATION15'
      ,p_attribute15_value               => p_rec.mea_information15
      ,p_attribute16_name                => 'MEA_INFORMATION16'
      ,p_attribute16_value               => p_rec.mea_information16
      ,p_attribute17_name                => 'MEA_INFORMATION17'
      ,p_attribute17_value               => p_rec.mea_information17
      ,p_attribute18_name                => 'MEA_INFORMATION18'
      ,p_attribute18_value               => p_rec.mea_information18
      ,p_attribute19_name                => 'MEA_INFORMATION19'
      ,p_attribute19_value               => p_rec.mea_information19
      ,p_attribute20_name                => 'MEA_INFORMATION20'
      ,p_attribute20_value               => p_rec.mea_information20
      ,p_attribute21_name                => 'MEA_INFORMATION21'
      ,p_attribute21_value               => p_rec.mea_information21
      ,p_attribute22_name                => 'MEA_INFORMATION22'
      ,p_attribute22_value               => p_rec.mea_information22
      ,p_attribute23_name                => 'MEA_INFORMATION23'
      ,p_attribute23_value               => p_rec.mea_information23
      ,p_attribute24_name                => 'MEA_INFORMATION24'
      ,p_attribute24_value               => p_rec.mea_information24
      ,p_attribute25_name                => 'MEA_INFORMATION25'
      ,p_attribute25_value               => p_rec.mea_information25
      ,p_attribute26_name                => 'MEA_INFORMATION26'
      ,p_attribute26_value               => p_rec.mea_information26
      ,p_attribute27_name                => 'MEA_INFORMATION27'
      ,p_attribute27_value               => p_rec.mea_information27
      ,p_attribute28_name                => 'MEA_INFORMATION28'
      ,p_attribute28_value               => p_rec.mea_information28
      ,p_attribute29_name                => 'MEA_INFORMATION29'
      ,p_attribute29_value               => p_rec.mea_information29
      ,p_attribute30_name                => 'MEA_INFORMATION30'
      ,p_attribute30_value               => p_rec.mea_information30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
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
-- ----------------------------------------------------------------------------
PROCEDURE chk_df
  (p_rec in per_mea_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.medical_assessment_id is not null)  and (
    nvl(per_mea_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_mea_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.medical_assessment_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_MEDICAL_ASSESSMENTS'
      ,p_attribute_category              => p_rec.ATTRIBUTE_CATEGORY
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
  --
end chk_df;
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
PROCEDURE chk_non_updateable_args
  (p_effective_date IN DATE
  ,p_rec            IN per_mea_shd.g_rec_type
  ) IS
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument VARCHAR2(30);
  --
BEGIN
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_mea_shd.api_updating
      (p_medical_assessment_id => p_rec.medical_assessment_id
      ,p_object_version_number => p_rec.object_version_number) THEN
    --
    fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE ', l_proc);
    fnd_message.set_token('STEP ', '5');
    fnd_message.raise_error;
    --
  END IF;
  --
  IF nvl(p_rec.person_id, hr_api.g_number) <>
     nvl(per_mea_shd.g_old_rec.person_id,hr_api.g_number) THEN
    --
    l_argument := 'person_id';
    RAISE l_error;
    --
  END IF;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
END chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE insert_validate
  (p_effective_date               IN DATE
  ,p_rec                          IN per_mea_shd.g_rec_type) IS
  --
  -- Declare cursors
  --
  CURSOR   csr_business_group is
    SELECT business_group_id
      FROM per_all_people_f pap
     WHERE pap.person_id = p_rec.person_id
       AND p_effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date;
  --
  -- Declare local variables
  --
  l_proc  VARCHAR2(72) := g_package||'insert_validate';
  l_business_group_id    per_all_people_f.business_group_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  per_per_bus.set_security_group_id(p_person_id => to_number(p_rec.person_id));
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate person id
  --
  per_mea_bus.chk_person_id
    (p_medical_assessment_id => p_rec.medical_assessment_id
    ,p_person_id             => p_rec.person_id
    ,p_effective_date        => p_effective_date);
  --
  hr_utility.set_location(l_proc, 30);
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Get Business Group ID for validating organization_id
  --
  OPEN csr_business_group;
  FETCH csr_business_group INTO l_business_group_id;
  --
  hr_utility.set_location(l_proc, 50);
  --
  IF csr_business_group%NOTFOUND THEN
    --
    CLOSE csr_business_group;
    --
    hr_utility.set_message(800, 'HR_52919_DIS_INV_ORG');
    hr_utility.raise_error;
    --
  END IF;
  --
  CLOSE csr_business_group;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate Organization Id (Occupational Health Service Provider)
  --
  per_mea_bus.chk_organization_id
    (p_medical_assessment_id   =>  p_rec.medical_assessment_id
    ,p_organization_id         =>  p_rec.organization_id
    ,p_business_group_id       =>  l_business_group_id
    ,p_effective_date          =>  p_effective_date);
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Check Consultation Date
  --
  per_mea_bus.chk_consultation_date
    (p_consultation_date      => p_rec.consultation_date
    ,p_next_consultation_date => p_rec.consultation_date);
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Check Consultation Type
  --
  per_mea_bus.chk_consultation_type
    (p_medical_assessment_id => p_rec.medical_assessment_id
    ,p_consultation_type     => p_rec.consultation_type
    ,p_consultation_result   => p_rec.consultation_result
    ,p_effective_date        => p_effective_date);
  --
  hr_utility.set_location(l_proc, 90);
  --
  -- Check Consultation Result
  --
  per_mea_bus.chk_consultation_result
    (p_medical_assessment_id => p_rec.medical_assessment_id
    ,p_consultation_type     => p_rec.consultation_type
    ,p_consultation_result   => p_rec.consultation_result
    ,p_effective_date        => p_effective_date);
  --
  hr_utility.set_location(l_proc, 100);
  --
  -- Check Incident ID
  --
  per_mea_bus.chk_incident_id
    (p_incident_id           => p_rec.incident_id
    ,p_medical_assessment_id => p_rec.medical_assessment_id);
  --
  hr_utility.set_location(l_proc, 105);
  --
  -- Check the incident date is not after the consultation date
  --
  per_mea_bus.chk_inc_consul_date
    (p_consultation_date     => p_rec.consultation_date
    ,p_incident_id           => p_rec.incident_id);
  --
  hr_utility.set_location(l_proc, 110);
  --
  -- Check Disability ID
  --
  per_mea_bus.chk_disability_id
    (p_disability_id         => p_rec.disability_id
    ,p_medical_assessment_id => p_rec.medical_assessment_id
    ,p_person_id             => p_rec.person_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_effective_date        => p_effective_date);
  --
  hr_utility.set_location(l_proc, 120);
  --
  -- Check Next Consultation Date
  --
  per_mea_bus.chk_next_consultation_date
    (p_next_consultation_date => p_rec.next_consultation_date
    ,p_consultation_date      => p_rec.consultation_date );
  --
  hr_utility.set_location(l_proc, 130);
  --
  -- Check that no other medical records exists with
  -- the same disability ID and Incident ID
  --
  per_mea_bus.chk_valid_id_combinations
    (p_medical_assessment_id => p_rec.medical_assessment_id
    ,p_disability_id         => p_rec.disability_id
    ,p_incident_id           => p_rec.incident_id
    ,p_person_id             => p_rec.person_id);
  --
  hr_utility.set_location(l_proc, 140);
  --
  -- Check that the incident id belongs to the disability
  -- record, if the disability id is not null
  --
  per_mea_bus.chk_inc_against_dis
    (p_disability_id         => p_rec.disability_id
    ,p_incident_id           => p_rec.incident_id
    ,p_person_id             => p_rec.person_id
    ,p_effective_date        => p_effective_date);
  --
  -- Check developer flex field
  --
  per_mea_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 150);
  --
  -- Check flex field
  --
  per_mea_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 160);
  --
END insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_validate
  (p_effective_date               IN DATE
  ,p_rec                          IN per_mea_shd.g_rec_type
  ) IS
  --
  -- Declare cursors
  --
  CURSOR   csr_business_group is
    SELECT business_group_id
      FROM per_all_people_f pap
     WHERE pap.person_id = p_rec.person_id
       AND p_effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date;
  --
  -- Declare local variables
  --
  l_proc              VARCHAR2(72) := g_package||'update_validate';
  l_business_group_id per_all_people_f.business_group_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call parent person table's set_security_group_id function
  --
  per_per_bus.set_security_group_id(p_person_id => to_number(p_rec.person_id));
  --
  -- Check that all non updateble arguements have not been changed
  --
  chk_non_updateable_args
    (p_effective_date => p_effective_date
    ,p_rec            => p_rec);
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Get Business Group ID for validating organization_id
  --
  OPEN csr_business_group;
  FETCH csr_business_group INTO l_business_group_id;
  --
  hr_utility.set_location(l_proc, 50);
  --
  IF csr_business_group%NOTFOUND THEN
    --
    CLOSE csr_business_group;
    --
    hr_utility.set_message(800, 'HR_52919_DIS_INV_ORG');
    hr_utility.raise_error;
    --
  END IF;
  --
  CLOSE csr_business_group;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate Organization Id (Occupational Health Service Provider)
  --
  per_mea_bus.chk_organization_id
    (p_medical_assessment_id   =>  p_rec.medical_assessment_id
    ,p_organization_id         =>  p_rec.organization_id
    ,p_business_group_id       =>  l_business_group_id
    ,p_effective_date          =>  p_effective_date);
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Check Consultation Date
  --
  per_mea_bus.chk_consultation_date
    (p_consultation_date      => p_rec.consultation_date
    ,p_next_consultation_date => p_rec.consultation_date);
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Check Consultation Type
  --
  per_mea_bus.chk_consultation_type
    (p_medical_assessment_id => p_rec.medical_assessment_id
    ,p_consultation_type     => p_rec.consultation_type
    ,p_consultation_result   => p_rec.consultation_result
    ,p_effective_date        => p_effective_date);
  --
  hr_utility.set_location(l_proc, 90);
  --
  -- Check Consultation Result
  --
  per_mea_bus.chk_consultation_result
    (p_medical_assessment_id => p_rec.medical_assessment_id
    ,p_consultation_type     => p_rec.consultation_type
    ,p_consultation_result   => p_rec.consultation_result
    ,p_effective_date        => p_effective_date);
  --
  hr_utility.set_location(l_proc, 100);
  --
  -- Check Incident ID
  --
  per_mea_bus.chk_incident_id
    (p_incident_id           => p_rec.incident_id
    ,p_medical_assessment_id => p_rec.medical_assessment_id);
  --
  hr_utility.set_location(l_proc, 105);
  --
  -- Check the incident date is not after the consultation date
  --
  per_mea_bus.chk_inc_consul_date
    (p_consultation_date     => p_rec.consultation_date
    ,p_incident_id           => p_rec.incident_id);
  --
  hr_utility.set_location(l_proc, 110);
  --
  -- Check Disability ID
  --
  per_mea_bus.chk_disability_id
    (p_disability_id         => p_rec.disability_id
    ,p_medical_assessment_id => p_rec.medical_assessment_id
    ,p_person_id             => p_rec.person_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_effective_date        => p_effective_date);
  --
  hr_utility.set_location(l_proc, 120);
  --
  -- Check Next Consultation Date
  --
  per_mea_bus.chk_next_consultation_date
    (p_next_consultation_date => p_rec.next_consultation_date
    ,p_consultation_date      => p_rec.consultation_date );
  --
  hr_utility.set_location(l_proc, 130);
  --
  -- Check that no other medical records exists with
  -- the same disability ID and Incident ID
  --
  per_mea_bus.chk_valid_id_combinations
    (p_medical_assessment_id => p_rec.medical_assessment_id
    ,p_disability_id         => p_rec.disability_id
    ,p_incident_id           => p_rec.incident_id
    ,p_person_id             => p_rec.person_id);
  --
  hr_utility.set_location(l_proc, 140);
  --
  -- Check that the incident id belongs to the disability
  -- record, if the disability id is not null
  --
  per_mea_bus.chk_inc_against_dis
    (p_disability_id         => p_rec.disability_id
    ,p_incident_id           => p_rec.incident_id
    ,p_person_id             => p_rec.person_id
    ,p_effective_date        => p_effective_date);
  --
  hr_utility.set_location(l_proc, 150);
  --
  per_mea_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 160);
  --
  per_mea_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 130);
  --
END update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_validate
  (p_rec IN per_mea_shd.g_rec_type) IS
  --
  l_proc  VARCHAR2(72) := g_package||'delete_validate';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
END delete_validate;
--
END per_mea_bus;

/
