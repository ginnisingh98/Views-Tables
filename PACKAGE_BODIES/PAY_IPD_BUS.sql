--------------------------------------------------------
--  DDL for Package Body PAY_IPD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IPD_BUS" as
/* $Header: pyipdrhi.pkb 120.2 2005/09/30 06:49:56 vikgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_ipd_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_paye_details_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_paye_details_id                      in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_ie_paye_details_f ipd
         , per_all_assignments_f paa
      where ipd.paye_details_id = p_paye_details_id
      and   ipd.assignment_id = paa.assignment_id
      and   paa.business_group_id = pbg.business_group_id;
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
    ,p_argument           => 'paye_details_id'
    ,p_argument_value     => p_paye_details_id
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
  (p_paye_details_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pay_ie_paye_details_f ipd
          , per_all_assignments_f paa
      where ipd.paye_details_id = p_paye_details_id
      and   ipd.assignment_id = paa.assignment_id
      and   paa.business_group_id = pbg.business_group_id;
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
    ,p_argument           => 'paye_details_id'
    ,p_argument_value     => p_paye_details_id
    );
  --
  if ( nvl(pay_ipd_bus.g_paye_details_id, hr_api.g_number)
       = p_paye_details_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_ipd_bus.g_legislation_code;
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
    pay_ipd_bus.g_paye_details_id   := p_paye_details_id;
    pay_ipd_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec             in pay_ipd_shd.g_rec_type
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
  IF NOT pay_ipd_shd.api_updating
      (p_paye_details_id                  => p_rec.paye_details_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF nvl(p_rec.assignment_id, hr_api.g_number) <>
     nvl(pay_ipd_shd.g_old_rec.assignment_id, hr_api.g_number) THEN
     l_argument := 'assignment_id';
     raise l_error;
  END IF;
  --
  IF nvl(p_rec.comm_period_no, hr_api.g_number) <>
     nvl(pay_ipd_shd.g_old_rec.comm_period_no, hr_api.g_number) THEN
     l_argument := 'comm_period_no';
     raise l_error;
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
-- |---------------------< chk_info_source >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if info_source already exists in lookup_type IE_PAYE_INFO_SOURCE
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_info_source
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the info_source does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_info_source
  (p_effective_date IN DATE
     , p_info_source IN VARCHAR2
  ) IS
   -- select wehre info_source exists
   CURSOR csr_info_source IS
   SELECT NULL
   FROM   hr_lookups
   WHERE  lookup_code = p_info_source
   AND    lookup_type = 'IE_PAYE_INFO_SOURCE'
   AND    enabled_flag = 'Y'
   AND    p_effective_date BETWEEN nvl(start_date_active, p_effective_date) AND nvl(end_date_active, p_effective_Date);
   --
   l_exists VARCHAR2(1);
BEGIN
   OPEN csr_info_source;
   FETCH csr_info_source INTO l_exists;
   IF csr_info_source%NOTFOUND THEN
      CLOSE csr_info_source;
      fnd_message.set_name('PAY','HR_IE_INFO_SOURCE_INVALID');
      fnd_message.set_token('INFO_SOURCE', p_info_source);
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_info_source;
END chk_info_source;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< get_comm_period_no >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Derive value of comm_period_no
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_assignemnt_id
--
--
--  Post Success:
--    returns value of commencement period number.
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION get_comm_period_no
   ( p_effective_date IN DATE
     , p_assignment_id IN NUMBER ) RETURN NUMBER IS
     --
     l_comm_period_no NUMBER;
     -- select original hire date of the employee
     CURSOR csr_orig_hire_date IS
     SELECT pap.original_date_of_hire, paa.payroll_id
     FROM   per_all_people_f pap, per_all_assignments paa
     WHERE  paa.assignment_id = p_assignment_id
     AND    p_effective_date BETWEEN paa.effective_start_date AND paa.effective_end_date
     AND    pap.person_id = paa.person_id
     AND    p_effective_Date BETWEEN pap.effective_start_date AND pap.effective_end_date;
     --
     orig_hire_date_rec csr_orig_hire_date%ROWTYPE;
     --
     CURSOR csr_period_num(l_date IN DATE, l_payroll_id IN NUMBER) IS
     SELECT ptp.period_num , ptp.start_date
     FROM   per_time_periods ptp, pay_all_payrolls_f pap
     WHERE  ptp.payroll_id = l_payroll_id
     AND    l_date BETWEEN ptp.start_date AND ptp.end_Date
     AND    ptp.period_type = pap.period_type
     AND    pap.payroll_id = l_payroll_id
     AND    p_effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date;
     --
     period_num_rec csr_period_num%ROWTYPE;
     --
BEGIN
   -- Get original date of hire
   OPEN csr_orig_hire_date;
   FETCH csr_orig_hire_date INTO orig_hire_date_rec;
   CLOSE csr_orig_hire_date;
   --
   IF to_date('01-JAN-'||to_char(p_effective_date,'YYYY'),'DD/MM/YYYY') < orig_hire_date_rec.original_date_of_hire THEN
               -- Get pay period number in which person was hired originaly
               OPEN csr_period_num(orig_hire_date_rec.original_date_of_hire, orig_hire_date_rec.payroll_id);
               FETCH csr_period_num INTO period_num_rec;
               CLOSE csr_period_num;
               l_comm_period_no := nvl(period_num_rec.period_num,1);
   ELSE
               -- Set commencement pay period number to first pay period
               l_comm_period_no := 1;
   END IF;
   --
   RETURN l_comm_period_no;
END get_comm_period_no;

--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_comm_period_no >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if comm_period_no is valid
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_comm_period_no
--    p_assignment_id
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the comm_period_no is not valid
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_comm_period_no
  (p_effective_date IN DATE
     , p_comm_period_no IN NUMBER
     , p_assignment_id IN NUMBER
  ) IS
  l_comm_period_no NUMBER;
BEGIN
   l_comm_period_no := get_comm_period_no( p_effective_date => p_effective_date,
                                           p_assignment_id => p_assignment_id );
   IF l_comm_period_no <> p_comm_period_no THEN
      fnd_message.set_name('PAY','HR_IE_COMM_PERIOD_NO_INVALID');
      fnd_message.raise_error;
   END IF;
   --
END chk_comm_period_no;
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_tax_basis >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if tax_basis already exists in lookup_type IE_PAYE_TAX_BASIS
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_tax_basis
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the info_source does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_tax_basis
  (p_effective_date IN DATE
     , p_tax_basis IN VARCHAR2
  ) IS
   -- select wehre tax_basis exists
   CURSOR csr_tax_basis IS
   SELECT NULL
   FROM   hr_lookups
   WHERE  lookup_code = p_tax_basis
   AND    lookup_type = 'IE_PAYE_TAX_BASIS'
   AND    enabled_flag = 'Y'
   AND    p_effective_date BETWEEN nvl(start_date_active, p_effective_date) AND nvl(end_date_active, p_effective_Date);
   --
   l_exists VARCHAR2(1);
BEGIN
   OPEN csr_tax_basis;
   FETCH csr_tax_basis INTO l_exists;
   IF csr_tax_basis%NOTFOUND THEN
      CLOSE csr_tax_basis;
      fnd_message.set_name('PAY','HR_IE_TAX_BASIS_INVALID');
      fnd_message.set_token('TAX_BASIS', p_tax_basis);
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_tax_basis;
END chk_tax_basis;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_tax_assess_basis >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if tax_assess_basis already exists in lookup_type IE_PAYE_ASSESS_BASIS
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_tax_assess_basis
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the info_source does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_tax_assess_basis
  (p_effective_date IN DATE
     , p_tax_assess_basis IN VARCHAR2
  ) IS
   -- select wehre tax_assess_basis exists
   CURSOR csr_tax_assess_basis IS
   SELECT NULL
   FROM   hr_lookups
   WHERE  lookup_code = p_tax_assess_basis
   AND    lookup_type = 'IE_PAYE_ASSESS_BASIS'
   AND    enabled_flag = 'Y'
   AND    p_effective_date BETWEEN nvl(start_date_active, p_effective_date) AND nvl(end_date_active, p_effective_Date);
   --
   l_exists VARCHAR2(1);
BEGIN
   OPEN csr_tax_assess_basis;
   FETCH csr_tax_assess_basis INTO l_exists;
   IF csr_tax_assess_basis%NOTFOUND THEN
      CLOSE csr_tax_assess_basis;
      fnd_message.set_name('PAY','HR_IE_TAX_ASSESS_BASIS_INVALID');
      fnd_message.set_token('TAX_ASSESS_BASIS', p_tax_assess_basis);
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_tax_assess_basis;
END chk_tax_assess_basis;

--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_cert_start_end_dates >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if certificate start dates is before or equal to certificate end date
--
--  Prerequisites:
--
--  In Arguments:
--    p_certificate_start_date
--    p_certificate_end_date
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if the certificate_start_date is after
--    certificate_end_Date
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_cert_start_end_dates
  (p_certificate_start_date IN DATE
     , p_certificate_end_date IN DATE
  ) IS
BEGIN
   IF p_certificate_start_date > nvl(p_certificate_end_date, p_certificate_start_date+1) THEN
      fnd_message.set_name('PAY', 'HR_IE_START_END_DATES');
      fnd_message.set_token('START_DATE', to_char(p_certificate_start_date, 'DD-MON-YYYY'));
      fnd_message.set_token('END_DATE', to_char(p_certificate_end_date, 'DD-MON-YYYY'));
      fnd_message.raise_error;
   END IF;
END chk_cert_start_end_Dates;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_duplicate_record >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if PAYE record already exists for the assignment
--
--  Prerequisites:
--
--  In Arguments:
--    p_assignment_id
--
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if PAYE record already exists for the assignment
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_duplicate_record
  ( p_assignment_id IN NUMBER
  , p_validation_start_date DATE
  , p_validation_end_date DATE   --Bug 4154171
  ) IS
  -- Select existing PAYE details
  CURSOR csr_paye_details IS
  SELECT min(ipd.effective_start_date) min_start_date
  FROM   pay_ie_paye_details_f ipd
  WHERE  ipd.assignment_id = p_assignment_id
  and (ipd.effective_start_date between p_validation_start_date and p_validation_end_date
     	OR ipd.effective_end_date between p_validation_start_date and p_validation_end_date
        OR p_validation_start_date BETWEEN ipd.effective_start_date and ipd.effective_end_date
        OR p_validation_end_date BETWEEN ipd.effective_start_date and ipd.effective_end_date) ;


  --
  paye_details_rec csr_paye_details%ROWTYPE;
BEGIN
   OPEN csr_paye_details;
   FETCH csr_paye_details INTO paye_details_rec;
      --
   IF paye_details_rec.min_start_date is not null  THEN
      CLOSE csr_paye_details;
      fnd_message.set_name('PAY', 'HR_IE_PAYE_DETAILS_EXIST');
      fnd_message.set_token('START_DATE', to_char(paye_details_rec.min_start_date, 'DD-MON-YYYY'));
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_paye_details;
END chk_duplicate_record;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_tax_basis_amounts >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    check if amounts are valid for the given tax basis, for 'Emergency'
--    tax basis weekly and monthly tax credits ans std rate cut-off amounts must
--    be null and for other values of tax basis weekly or monthly amounts
--    (depending on payroll frequency) must be not null.
--
--  Prerequisites:
--
--  In Arguments:
--    p_effective_date
--    p_assignment_id
--    p_tax_basis
--    p_weekly_tax_credit
--    p_weekly_std_rate_cut_off
--    p_monthly_tax_credit
--    p_monthly_std_rate_cut_off
--
--
--  Post Success:
--    processing continues as no error is raised.
--
--  Post Failure:
--    An error is raised if amonts are not valid for the given tax basis and payroll
--    frequency
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_tax_basis_amounts
  (p_effective_date IN DATE
    , p_assignment_id IN NUMBER
     , p_tax_basis IN VARCHAR2
     , p_weekly_tax_credit IN NUMBER
     , p_weekly_std_rate_cut_off IN NUMBER
     , p_monthly_tax_credit IN NUMBER
     , p_monthly_std_rate_cut_off IN NUMBER
  ) IS
   -- Select Payroll Frequency
   CURSOR csr_pay_freq IS
   SELECT pp.period_type
   FROM pay_payrolls_f pp, per_assignments_f pa
   WHERE pa.assignment_id = p_assignment_id
   AND   p_effective_date BETWEEN pa.effective_start_date AND pa.effective_end_date
   AND   pp.payroll_id = pa.payroll_id
   AND   p_effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date;
   --
   pay_freq_rec csr_pay_freq%ROWTYPE;
BEGIN
   OPEN csr_pay_freq;
   FETCH csr_pay_freq INTO pay_freq_rec;
   --
   IF csr_pay_freq%NOTFOUND THEN
      CLOSE csr_pay_freq;
      fnd_message.set_name('PAY', 'HR_IE_ASG_NOT_IN_PAYROLL');
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_pay_freq;
   --
   IF p_tax_basis = 'IE_EMERGENCY'
      AND (p_weekly_tax_credit IS NOT NULL OR p_weekly_std_rate_cut_off IS NOT NULL
           OR p_monthly_tax_credit IS NOT NULL OR p_monthly_std_rate_cut_off IS NOT NULL ) THEN
      fnd_message.set_name('PAY', 'HR_IE_TAX_CREDIT_NOT_NULL');
      fnd_message.raise_error;
   ELSIF p_tax_basis IN ('IE_CUMULATIVE', 'IE_WEEK1_MONTH1','IE_EXEMPTION','IE_EXEMPT_WEEK_MONTH') THEN -- Bug no 4618981
      IF pay_freq_rec.period_type IN ('Calendar Month', 'Quarter', 'Bi-Month' ) THEN
         IF (p_monthly_tax_credit IS NULL OR p_monthly_std_rate_cut_off IS NULL) THEN
            fnd_message.set_name('PAY', 'HR_IE_MONTHLY_TAX_CREDIT_NULL');
            fnd_message.raise_error;
         END IF;
      ELSE
         IF (p_weekly_tax_credit IS NULL OR p_weekly_std_rate_cut_off IS NULL) THEN
            fnd_message.set_name('PAY', 'HR_IE_WEEKLY_TAX_CREDIT_NULL');
            fnd_message.raise_error;
         END IF;
      END IF;
   END IF;
   --
END chk_tax_basis_amounts;
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
  (p_paye_details_id                  in number
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
      ,p_argument       => 'paye_details_id'
      ,p_argument_value => p_paye_details_id
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
  (p_rec                   in pay_ipd_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  per_asg_bus1.set_security_group_id(p_rec.assignment_id);
  --
  --
  pay_ipd_bus.chk_assignment_id( p_effective_date => p_effective_date
                                 , p_assignment_id => p_rec.assignment_id );
  --
  pay_ipd_bus.chk_info_source ( p_effective_date => p_effective_date
                                , p_info_source => p_rec.info_source );
  --
  pay_ipd_bus.chk_tax_basis ( p_effective_date => p_effective_date
                              , p_tax_basis => p_rec.tax_basis );
  --
  pay_ipd_bus.chk_tax_assess_basis( p_effective_date => p_effective_date
                                    , p_tax_assess_basis => p_rec.tax_assess_basis );
  --
  pay_ipd_bus.chk_comm_period_no ( p_effective_date => p_effective_date
                                    , p_comm_period_no => p_rec.comm_period_no
                                    , p_assignment_id => p_rec.assignment_id );
  --
  pay_ipd_bus.chk_cert_start_end_dates ( p_certificate_start_date => p_rec.certificate_start_date
                                    , p_certificate_end_date => p_rec.certificate_end_date );
  --
  pay_ipd_bus.chk_duplicate_record ( p_assignment_id => p_rec.assignment_id
				    ,p_validation_start_date => p_validation_start_date
				    ,p_validation_end_date => p_validation_end_date);
  --
  pay_ipd_bus.chk_tax_basis_amounts ( p_effective_date => p_effective_date
                                      , p_assignment_id => p_rec.assignment_id
                                      , p_tax_basis => p_rec.tax_basis
                                      , p_weekly_tax_credit => p_rec.weekly_tax_credit
                                      , p_weekly_std_rate_cut_off => p_rec.weekly_std_rate_cut_off
                                      , p_monthly_tax_credit => p_rec.monthly_tax_credit
                                      , p_monthly_std_rate_cut_off => p_rec.monthly_std_rate_cut_off );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_ipd_shd.g_rec_type
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
  --
  per_asg_bus1.set_security_group_id(p_rec.assignment_id);
  --
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
  pay_ipd_bus.chk_info_source ( p_effective_date => p_effective_date
                                , p_info_source => p_rec.info_source );
  --
  pay_ipd_bus.chk_tax_basis ( p_effective_date => p_effective_date
                              , p_tax_basis => p_rec.tax_basis );
  --
  pay_ipd_bus.chk_tax_assess_basis( p_effective_date => p_effective_date
                                    , p_tax_assess_basis => p_rec.tax_assess_basis );
  --
  pay_ipd_bus.chk_cert_start_end_dates ( p_certificate_start_date => p_rec.certificate_start_date
                                    , p_certificate_end_date => p_rec.certificate_end_date );
  --
  pay_ipd_bus.chk_tax_basis_amounts ( p_effective_date => p_effective_date
                                      , p_assignment_id => p_rec.assignment_id
                                      , p_tax_basis => p_rec.tax_basis
                                      , p_weekly_tax_credit => p_rec.weekly_tax_credit
                                      , p_weekly_std_rate_cut_off => p_rec.weekly_std_rate_cut_off
                                      , p_monthly_tax_credit => p_rec.monthly_tax_credit
                                      , p_monthly_std_rate_cut_off => p_rec.monthly_std_rate_cut_off );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_ipd_shd.g_rec_type
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
    ,p_paye_details_id                  => p_rec.paye_details_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_ipd_bus;

/
