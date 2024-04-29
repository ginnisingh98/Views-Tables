--------------------------------------------------------
--  DDL for Package Body PAY_PWO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PWO_BUS" as
/* $Header: pypworhi.pkb 115.3 2002/12/05 15:11:25 swinton noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pwo_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_occupation_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   occupation_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_occupation_id(p_occupation_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_occupation_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_pwo_shd.api_updating
    (p_occupation_id                => p_occupation_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_occupation_id,hr_api.g_number)
     <>  pay_pwo_shd.g_old_rec.occupation_id) then
    --
    -- raise error as PK has changed
    --
    pay_pwo_shd.constraint_error('PAY_WCI_OCCUPATIONS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_occupation_id is not null then
      --
      -- raise error as PK is not null
      --
      pay_pwo_shd.constraint_error('PAY_WCI_OCCUPATIONS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_occupation_id;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_job_group >----------------------------|
-- ----------------------------------------------------------------------------
-- Description : This function is used to validate the job being inserted. It
--               must be a valid HR Job Group job.
-- Validation  : The job must exist in new view per_jobs_v
-- On Failure  : Raise message 'The job you have entered is not for a valid HR
--               Job Group.'
-- ----------------------------------------------------------------------------
FUNCTION chk_job_group (p_job_id           in number
                       ,p_business_group_id in number)
RETURN BOOLEAN IS
--
CURSOR get_job_group_job(p_job_id number
                        ,p_bg_id  number)
IS
SELECT job_id
FROM   per_jobs_v
WHERE  business_group_id = p_bg_id
AND    job_id = p_job_id;
--
l_proc          varchar2(72) := g_package||'chk_job_group';
l_exists        number;
v_return_value  boolean;
--
BEGIN
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
OPEN  get_job_group_job (p_job_id, p_business_group_id);
FETCH get_job_group_job INTO l_exists;
--
  IF get_job_group_job%NOTFOUND THEN
  --
    hr_utility.set_location('Returnig FALSE: '||l_proc, 10);
    v_return_value := FALSE;
    --
    --
  ELSE
    hr_utility.set_location('Returning TRUE: '||l_proc, 15);
    v_return_value := TRUE;
    --
  END IF;
  --
CLOSE get_job_group_job;
--
RETURN v_return_value;
--
hr_utility.set_location('Leaving: '||l_proc, 20);
--
END chk_job_group;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_pwo_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_occupation_id
  (p_occupation_id          => p_rec.occupation_id,
   p_object_version_number => p_rec.object_version_number);
  --
  IF NOT chk_job_group (p_job_id            => p_rec.job_id
                       ,p_business_group_id => p_rec.business_group_id)
  THEN
  --
    hr_utility.set_message(801,'PAY_74036_INVALID_JOB');
    hr_utility.raise_error;
    --
  ELSE
  --
    hr_utility.trace('Valid job group job');
    --
  END IF;
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_pwo_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_occupation_id
  (p_occupation_id          => p_rec.occupation_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_pwo_shd.g_rec_type) is
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
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_occupation_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pay_wci_occupations b
    where b.occupation_id      = p_occupation_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'occupation_id',
                             p_argument_value => p_occupation_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end pay_pwo_bus;

/
