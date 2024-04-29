--------------------------------------------------------
--  DDL for Package Body PAY_SID_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SID_BUS" as
/* $Header: pysidrhi.pkb 120.1 2005/07/05 06:26:10 vikgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_sid_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_prsi_details_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_prsi_details_id                      in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_ie_prsi_details_f sid
         , per_all_assignments_f paa
     where sid.prsi_details_id = p_prsi_details_id
     and   sid.assignment_id = paa.assignment_id
     and   pbg.business_group_id = paa.business_group_id;
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
    ,p_argument           => 'prsi_details_id'
    ,p_argument_value     => p_prsi_details_id
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
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_prsi_details_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pay_ie_prsi_details_f sid
         , per_all_assignments_f paa
     where sid.prsi_details_id = p_prsi_details_id
     and   sid.assignment_id = paa.assignment_id
     and pbg.business_group_id = paa.business_group_id;
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
    ,p_argument           => 'prsi_details_id'
    ,p_argument_value     => p_prsi_details_id
    );
  --
  if ( nvl(pay_sid_bus.g_prsi_details_id, hr_api.g_number)
       = p_prsi_details_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_sid_bus.g_legislation_code;
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
    pay_sid_bus.g_prsi_details_id   := p_prsi_details_id;
    pay_sid_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec             in pay_sid_shd.g_rec_type
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
  IF NOT pay_sid_shd.api_updating
      (p_prsi_details_id                  => p_rec.prsi_details_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  IF nvl(p_rec.assignment_id, hr_api.g_number) <>
     nvl(pay_ipd_shd.g_old_rec.assignment_id, hr_api.g_number) THEN
     l_argument := 'assignment_id';
  END IF;
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
-- ---------------------------------------------------------------------------
-- |---------------------< chk_assignment_id >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if assignment already exists and valid as of the effectuve date
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_assignment_id
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the assignment does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_assignment_id
  (p_effective_date IN DATE
    , p_assignment_id IN NUMBER
  ) IS
   -- select payroll_id if assignment id exists
   CURSOR csr_assignment IS
   SELECT payroll_id
   FROM   per_all_assignments_f
   WHERE  assignment_id = p_assignment_id
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
   --
   l_payroll_id NUMBER;
BEGIN
   OPEN csr_assignment;
   FETCH csr_assignment INTO l_payroll_id;
   IF csr_assignment%NOTFOUND THEN
      CLOSE csr_assignment;
      fnd_message.set_name('PAY','HR_IE_ASG_NOT_EXISTS');
      fnd_message.raise_error;
   END IF;
   --
   IF l_payroll_id IS NULL THEN
      CLOSE csr_assignment;
      fnd_message.set_name('PAY','HR_IE_ASG_NOT_IN_PAYROLL');
      fnd_message.raise_error;
   END IF;
   CLOSE csr_assignment;
END chk_assignment_id;
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_director_flag >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if director_flag already exists in lookup_type YES_NO
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_director_flag
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the director_flag does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_director_flag
  (p_effective_date IN DATE
     , p_director_flag IN VARCHAR2
  ) IS
   -- select wehre director_flag exists
   CURSOR csr_director_flag IS
   SELECT NULL
   FROM   hr_lookups
   WHERE  lookup_code = p_director_flag
   AND    lookup_type = 'YES_NO'
   AND    enabled_flag = 'Y'
   AND    p_effective_date BETWEEN nvl(start_date_active, p_effective_date) AND nvl(end_date_active, p_effective_Date);
   --
   l_exists VARCHAR2(1);
BEGIN
   OPEN csr_director_flag;
   FETCH csr_director_flag INTO l_exists;
   IF csr_director_flag%NOTFOUND THEN
      CLOSE csr_director_flag;
      fnd_message.set_name('PAY','HR_IE_DIRECTOR_FLAG_INVALID');
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_director_flag;
END chk_director_flag;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_contribution_class >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if contribution_class already exists in lookup_type
--    IE_PRSI_CONT_CLASS
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_contribution_class
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the contribution_class does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_contribution_class
  (p_effective_date IN DATE
     , p_contribution_class IN VARCHAR2
  ) IS
   -- select wehre contribution_class exists
   CURSOR csr_contribution_class IS
   SELECT NULL
   FROM   hr_lookups
   WHERE  lookup_code = p_contribution_class
   AND    lookup_type = 'IE_PRSI_CONT_CLASS'
   AND    enabled_flag = 'Y'
   AND    p_effective_date BETWEEN nvl(start_date_active, p_effective_date) AND nvl(end_date_active, p_effective_Date);
   --
   l_exists VARCHAR2(1);
BEGIN
   OPEN csr_contribution_class;
   FETCH csr_contribution_class INTO l_exists;
   IF csr_contribution_class%NOTFOUND THEN
      CLOSE csr_contribution_class;
      fnd_message.set_name('PAY','HR_IE_CONT_CLASS_INVALID');
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_contribution_class;
END chk_contribution_class;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_overridden_subclass >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if overridden_subclass already exists in lookup_type
--    IE_PRSI_CONT_SUBCLASS
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_overridden_subclass
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the overridden_subclass does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_overridden_subclass
  (p_effective_date IN DATE
     , p_overridden_subclass IN VARCHAR2
  ) IS
   -- select wehre overridden_subclass exists
   CURSOR csr_overridden_subclass IS
   SELECT NULL
   FROM   hr_lookups
   WHERE  lookup_code = p_overridden_subclass
   AND    lookup_type = 'IE_PRSI_CONT_SUBCLASS'
   AND    enabled_flag = 'Y'
   AND    p_effective_date BETWEEN nvl(start_date_active, p_effective_date) AND nvl(end_date_active, p_effective_Date);
   --
   l_exists VARCHAR2(1);
BEGIN
   OPEN csr_overridden_subclass;
   FETCH csr_overridden_subclass INTO l_exists;
   IF p_overridden_subclass IS NOT NULL AND csr_overridden_subclass%NOTFOUND THEN
      CLOSE csr_overridden_subclass;
      fnd_message.set_name('PAY','HR_IE_CONT_SUBCLASS_INVALID');
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_overridden_subclass;
END chk_overridden_subclass;
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_soc_ben_flag >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if soc_ben_flag already exists in lookup_type YES_NO
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_soc_ben_flag
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the soc_ben_flag does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_soc_ben_flag
  (p_effective_date IN DATE
     , p_soc_ben_flag IN VARCHAR2
  ) IS
   -- select wehre soc_ben_flag exists
   CURSOR csr_soc_ben_flag IS
   SELECT NULL
   FROM   hr_lookups
   WHERE  lookup_code = p_soc_ben_flag
   AND    lookup_type = 'YES_NO'
   AND    enabled_flag = 'Y'
   AND    p_effective_date BETWEEN nvl(start_date_active, p_effective_date) AND nvl(end_date_active, p_effective_Date);
   --
   l_exists VARCHAR2(1);
BEGIN
   OPEN csr_soc_ben_flag;
   FETCH csr_soc_ben_flag INTO l_exists;
   IF csr_soc_ben_flag%NOTFOUND THEN
      CLOSE csr_soc_ben_flag;
      fnd_message.set_name('PAY','HR_IE_SOC_BEN_FLAG_INVALID');
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_soc_ben_flag;
END chk_soc_ben_flag;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_overlapping_record >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if PRSI record already exists for the assignment
--
--  Prerequisites:
--
--  In Arguments:
--    p_assignment_id
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if PRSI record already exists for the assignment
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_overlapping_record
  ( p_assignment_id IN NUMBER
  , p_validation_start_date DATE
  , p_validation_end_date DATE
  ) IS
  -- Select existing PRSI details
  CURSOR csr_prsi_details IS
  SELECT min(ipd.effective_start_date) min_start_date
  FROM pay_ie_prsi_details_f ipd
  WHERE ipd.assignment_id = p_assignment_id
  and (ipd.effective_start_date between p_validation_start_date and p_validation_end_date
     	OR ipd.effective_end_date between p_validation_start_date and p_validation_end_date
        OR p_validation_start_date BETWEEN ipd.effective_start_date and ipd.effective_end_date
        OR p_validation_end_date BETWEEN ipd.effective_start_date and ipd.effective_end_date);


  --
  prsi_details_rec csr_prsi_details%ROWTYPE;
BEGIN
  hr_utility.set_location('In Overlapping Record',103);
   OPEN csr_prsi_details;
   FETCH csr_prsi_details INTO prsi_details_rec;
      --
   hr_utility.set_location('prsi_details_rec'||prsi_details_rec.min_start_date,104);
   IF prsi_details_rec.min_start_date is not null  THEN
      CLOSE csr_prsi_details;
      fnd_message.set_name('PAY', 'HR_IE_PRSI_DETAILS_EXIST');
      fnd_message.set_token('START_DATE', to_char(prsi_details_rec.min_start_date, 'DD-MON-YYYY'));
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_prsi_details;
END chk_overlapping_record;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_soc_ben_start_date >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if soc_ben_start_date is not null when soc_ben_flag is 'N'
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_soc_ben_flag
--    p_soc_ben_start_date
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the soc_ben_start_date is not null and
--    soc_ben_flag is 'N'
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_soc_ben_start_date
  (p_effective_date IN DATE
     , p_soc_ben_flag IN VARCHAR2
     , p_soc_ben_start_date IN DATE
  ) IS
   --
BEGIN
   IF p_soc_ben_flag = 'N' and p_soc_ben_start_date IS NOT NULL THEN
      fnd_message.set_name('PAY','HR_IE_SOC_BEN_START_DATE');
      fnd_message.raise_error;
   END IF;
   --
END chk_soc_ben_start_date;
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< get_std_ins_weeks >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Get standard default number of insurable weeks in current pay period
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_assignment_id
--
--
--  Post Success:
--    returns standard default number of insurable weeks in current pay period
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION get_std_ins_weeks
  (p_effective_date IN DATE
   , p_assignment_id IN NUMBER
  ) RETURN NUMBER IS
   --
   CURSOR get_period_info IS
      SELECT ptp.time_period_id, ptp.start_Date, ptp.end_date
      FROM   per_time_periods ptp, pay_all_payrolls_f pap, per_all_assignments_f paa
      WHERE  ptp.payroll_id = pap.payroll_id
      AND    p_effective_date BETWEEN ptp.start_date AND ptp.end_date
      AND    pap.payroll_id = paa.payroll_id
      AND    p_effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date
      AND    paa.assignment_id = p_assignment_id
      AND    p_effective_date BETWEEN paa.effective_start_date AND paa.effective_end_date;
      --
      period_info_rec get_period_info%ROWTYPE;
      --
      l_first_day VARCHAR2(10);
      l_count     NUMBER;
      l_date      DATE;
   BEGIN
      OPEN get_period_info;
      FETCH get_period_info INTO period_info_rec;
      CLOSE get_period_info;
      --
      l_first_day := to_char(to_date('01-01-'||to_char(p_effective_date,'YYYY'),'DD-MM-YYYY'),'DAY');
      --
      l_date := period_info_rec.start_date;
      --
      IF to_char(l_date, 'DAY') = l_first_day THEN
         l_count := 1;
      ELSE
         l_count := 0;
      END IF;
      --
      LOOP
         l_date := next_day(l_date, l_first_day);
         --
         IF l_date <= period_info_rec.end_date THEN
            l_count := l_count + 1;
         ELSE
            EXIT;
         END IF;
      END LOOP;
      --
      RETURN l_count;
END get_std_ins_weeks;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_overridden_ins_weeks >------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check that overridden insurable weeks are not more than standard default
--    number of insurable weeks in current pay period.
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_assignment_id
--    p_overridden_ins_weeks
--
--
--  Post Success:
--    Process continues
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_overridden_ins_weeks
  (p_effective_date IN DATE
   , p_assignment_id IN NUMBER
   , p_overridden_ins_weeks IN NUMBER
  ) IS
   --
   l_std_ins_weeks NUMBER;
   --
BEGIN
   -- Get std default number of insurable weeks
   l_std_ins_weeks := get_std_ins_weeks( p_effective_date => p_effective_date
                                         , p_assignment_id => p_assignment_id);
   -- if overridden number of insurable weeks are more than standard
   -- default number in current pay period then raie error
   IF nvl(p_overridden_ins_weeks, 0) > nvl(l_std_ins_weeks, 0) THEN
      null;
     -- fnd_message.set_name('PAY','HR_IE_OVERRIDDEN_INS_WEEKS');
    --  fnd_message.raise_error;
   END IF;
   --
END chk_overridden_ins_weeks;
--
--
-- ---------------------------------------------------------------------------
-- |--------------------< chk_exemption_start_end_dates >--------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if exemption start date is before or equal to certificate end date
--
--  Prerequisites:
--
--  In Arguments:
--    p_exemption_start_date
--    p_exemption_end_date
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the exemption_start_date is after
--    exemption_end_Date
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_exemption_start_end_dates
  (p_exemption_start_Date IN DATE
     , p_exemption_end_date IN DATE
  ) IS
BEGIN
   IF p_exemption_start_date > nvl(p_exemption_end_date, p_exemption_start_date+1) THEN
      fnd_message.set_name('PAY', 'HR_IE_START_END_DATES');
      fnd_message.set_token('START_DATE', to_char(p_exemption_start_date, 'DD-MON-YYYY'));
      fnd_message.set_token('END_DATE', to_char(p_exemption_end_date, 'DD-MON-YYYY'));
      fnd_message.raise_error;
   END IF;
END chk_exemption_start_end_Dates;
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_community_flag >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if community_flag already exists in lookup_type YES_NO
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_community_flag
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the community_flag does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_community_flag
  (p_effective_date IN DATE
     , p_community_flag IN VARCHAR2
  ) IS
   -- select wehre community_flag exists
   CURSOR csr_community_flag IS
   SELECT NULL
   FROM   hr_lookups
   WHERE  lookup_code = p_community_flag
   AND    lookup_type = 'YES_NO'
   AND    enabled_flag = 'Y'
   AND    p_effective_date BETWEEN nvl(start_date_active, p_effective_date) AND nvl(end_date_active, p_effective_Date);
   --
   l_exists VARCHAR2(1);
BEGIN
   OPEN csr_community_flag;
   FETCH csr_community_flag INTO l_exists;
   IF csr_community_flag%NOTFOUND THEN
      CLOSE csr_community_flag;
      fnd_message.set_name('PAY','HR_IE_COMMUNITY_FLAG_INVALID');
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_community_flag;
END chk_community_flag;
--
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
  (p_assignment_id                 in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
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
  If ((nvl(p_assignment_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_all_assignments_f'
            ,p_base_key_column => 'ASSIGNMENT_ID'
            ,p_base_key_value  => p_assignment_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'all assignments';
     raise l_integrity_error;
  End If;
  --
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
  (p_prsi_details_id                  in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
  l_rows_exist  Exception;
  l_table_name  all_tables.table_name%TYPE;
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
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
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
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'prsi_details_id'
      ,p_argument_value => p_prsi_details_id
      );
    --
  --
    --
  End If;
  --
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
  (p_rec                   in pay_sid_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
 -- hr_utility.trace_on(null,'VIKPRSI');
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_asg_bus1.set_security_group_id(p_rec.assignment_id);
  --
  pay_sid_bus.chk_assignment_id(p_effective_date => p_effective_date
                                , p_assignment_id => p_rec.assignment_id);
  --
  pay_sid_bus.chk_director_flag(p_effective_date => p_effective_date
                                , p_director_flag => p_rec.director_flag);
  --
  pay_sid_bus.chk_contribution_class(p_effective_date => p_effective_date
                                , p_contribution_class => p_rec.contribution_class);
  --
  pay_sid_bus.chk_overridden_subclass(p_effective_date => p_effective_date
                                      , p_overridden_subclass => p_rec.overridden_subclass );
  --
  pay_sid_bus.chk_soc_ben_flag(p_effective_date => p_effective_date
                               , p_soc_ben_flag => p_rec.soc_ben_flag );
  --
  pay_sid_bus.chk_soc_ben_start_date(p_effective_date => p_effective_date
                               , p_soc_ben_flag => p_rec.soc_ben_flag
                               , p_soc_ben_start_date => p_rec.soc_ben_start_date);
  --
  pay_sid_bus.chk_overridden_ins_weeks(p_effective_date => p_effective_date
                                , p_assignment_id => p_rec.assignment_id
                                , p_overridden_ins_weeks => p_rec.overridden_ins_weeks);
  --
  pay_sid_bus.chk_exemption_start_end_dates( p_exemption_start_Date => p_rec.exemption_start_date
                                            , p_exemption_end_date => p_rec.exemption_end_date) ;
  --
  pay_sid_bus.chk_community_flag(p_effective_date => p_effective_date
                                 , p_community_flag => p_rec.community_flag);
  --
hr_utility.set_location('p_assignment_id...'||p_rec.assignment_id,100);
hr_utility.set_location('p_validation_start_date...'||p_validation_start_date,101);
hr_utility.set_location('p_validation_end_date...'||p_validation_end_date,102);

  pay_sid_bus.chk_overlapping_record(p_assignment_id => p_rec.assignment_id
				    ,p_validation_start_date => p_validation_start_date
				    ,p_validation_end_date => p_validation_end_date);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_sid_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_asg_bus1.set_security_group_id(p_rec.assignment_id);
  --
  --
  pay_sid_bus.chk_director_flag(p_effective_date => p_effective_date
                                , p_director_flag => p_rec.director_flag);
  --
  pay_sid_bus.chk_contribution_class(p_effective_date => p_effective_date
                                , p_contribution_class => p_rec.contribution_class);
  --
  pay_sid_bus.chk_overridden_subclass(p_effective_date => p_effective_date
                                      , p_overridden_subclass => p_rec.overridden_subclass );
  --
  pay_sid_bus.chk_soc_ben_flag(p_effective_date => p_effective_date
                               , p_soc_ben_flag => p_rec.soc_ben_flag );
  --
  pay_sid_bus.chk_soc_ben_start_date(p_effective_date => p_effective_date
                               , p_soc_ben_flag => p_rec.soc_ben_flag
                               , p_soc_ben_start_date => p_rec.soc_ben_start_date);
  --
  pay_sid_bus.chk_overridden_ins_weeks(p_effective_date => p_effective_date
                                , p_assignment_id => p_rec.assignment_id
                                , p_overridden_ins_weeks => p_rec.overridden_ins_weeks);
  --
  pay_sid_bus.chk_exemption_start_end_dates( p_exemption_start_Date => p_rec.exemption_start_date
                                            , p_exemption_end_date => p_rec.exemption_end_date) ;
  --
  pay_sid_bus.chk_community_flag(p_effective_date => p_effective_date
                                 , p_community_flag => p_rec.community_flag);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_assignment_id                  => p_rec.assignment_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_sid_shd.g_rec_type
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
    ,p_prsi_details_id                  => p_rec.prsi_details_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_sid_bus;

/
