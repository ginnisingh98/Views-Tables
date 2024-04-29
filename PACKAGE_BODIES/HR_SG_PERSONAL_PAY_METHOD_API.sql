--------------------------------------------------------
--  DDL for Package Body HR_SG_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SG_PERSONAL_PAY_METHOD_API" AS
/* $Header: hrsgwrpm.pkb 115.2 2002/12/03 06:56:18 apunekar ship $ */
/*
 +==========================================================================================
 |              Copyright (c) 1999 Oracle Corporation Ltd
 |                           All rights reserved.
 +==========================================================================================
 |SQL Script File Name : HR SG WR PM . PKB
 |                Name : hr_sg_personal_pay_method_api
 |         Description : Personal Pay method API Wrapper for sg
 |
 |   Name           Date         Version Bug     Text
 |   -------------- ----------   ------- -----   ----
 |   makelly        27-JUL-2000  115.0           Created for sg
     apunekar       01-MAY-2001  115.1  1554453  p_priority made compulsory IN parameter.
     Apunekar       02-DEC-2002  115.2  2689189  Added Nocopy to out and in out parameters
 |
 |NOTES
 +==========================================================================================
*/


--
g_package  VARCHAR2(33) := 'hr_sg_personal_pay_method_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_sg_insert_legislation >------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This private procedure ensures that the legislation rule for the
--   for the personal payment method being inserted is the
--   of the required business process.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_personal_payment_method_id   Yes  number   Id of personal payment
--                                                method being deleted.
--   p_effective_date               Yes  date     The session date.
--
-- Post Success:
--   The procedure returns control back to the calling process.
--
-- Post Failure:
--   The process raises an error and stops execution.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
PROCEDURE check_sg_insert_legislation
  (p_assignment_id          IN     NUMBER
  ,p_effective_date         IN OUT NOCOPY DATE
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) := g_package||'check_sg_insert_egislation';
  l_valid               VARCHAR2(150);
  l_effective_date      DATE;
  c_leg_code            CONSTANT VARCHAR2(2) := 'SG';
  --
  CURSOR legsel IS
    SELECT  pbg.legislation_code
    FROM    per_business_groups pbg,
            per_assignments_f   asg
    WHERE   pbg.business_group_id   = asg.business_group_id
    AND     asg.assignment_id       = p_assignment_id
    AND     p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date;
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check that p_assignment_id and p_effective_date are not null as they
  -- are used by the cursor to validate the business group.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'assignment_id',
     p_argument_value => p_assignment_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Ensure that the legislation rule for the employee assignment
  -- business group is that of sg.
  --
  OPEN  legsel;
  FETCH legsel
  INTO  l_valid;
  --
  IF legsel%notfound THEN
    CLOSE legsel;
    hr_utility.set_message(801, 'HR_7348_ASSIGNMENT_INVALID');
    hr_utility.raise_error;
  END IF;
  IF legsel%found AND l_valid <> c_leg_code THEN
    CLOSE legsel;
    hr_utility.set_message(801, 'HR_7898_PPM_BUS_GRP_INVALID');
    hr_utility.raise_error;
  END IF;
  --
  CLOSE legsel;
  hr_utility.set_location(l_proc, 7);
  --
  -- Assign out parameter after truncating the date by using a local
  -- variable.
  --
  l_effective_date := TRUNC(p_effective_date);
  p_effective_date := l_effective_date;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 8);
  --
END check_sg_insert_legislation;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_sg_update_legislation >------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This private procedure ensures that the legislation rule for the
--   for the personal payment method being updated or deleted is the
--   of the required business process.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type       Description
--   p_personal_payment_method_id   Yes  number     Id of personal payment
--                                                  method being deleted.
--   p_effective_date               Yes  date       The session date.
--
-- Post Success:
--   The procedure returns control back to the calling process.
--
-- Post Failure:
--   The process raises an error and stops execution.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
PROCEDURE check_sg_update_legislation
  ( p_personal_payment_method_id    IN  pay_personal_payment_methods_f.personal_payment_method_id%type
    ,p_effective_date               IN  DATE
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) := g_package||'check_sg_update_legislation';
  l_valid               VARCHAR2(150);
  c_leg_code            CONSTANT VARCHAR2(2) := 'SG';
  --
  CURSOR legsel IS
    SELECT  pbg.legislation_code
    FROM    per_business_groups pbg,
            pay_personal_payment_methods_f ppm
    WHERE   pbg.business_group_id           = ppm.business_group_id
    AND     ppm.personal_payment_method_id  = p_personal_payment_method_id
    AND     p_effective_date BETWEEN ppm.effective_start_date AND ppm.effective_end_date;
--
BEGIN
  --
  -- Ensure that the legislation rule for the employee assignment business
  -- group is that of sg.
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  OPEN  legsel;
  FETCH legsel
  INTO  l_valid;
  --
  IF legsel%notfound THEN
    CLOSE legsel;
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  END IF;
  IF legsel%found AND l_valid <> c_leg_code THEN
    hr_utility.set_message(801, 'HR_7898_PPM_BUS_GRP_INVALID');
    hr_utility.raise_error;
  END IF;
  --
  CLOSE legsel;
  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
END check_sg_update_legislation;
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_sg_personal_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_sg_personal_pay_method
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_assignment_id                 IN     NUMBER
  ,p_org_payment_method_id         IN     NUMBER
  ,p_bank_account_number           IN     VARCHAR2
  ,p_bank_account_name             IN     VARCHAR2
  ,p_bank_account_type             IN     VARCHAR2
  ,p_bank_code                     IN     VARCHAR2
  ,p_bank_name                     IN     VARCHAR2
  ,p_branch_code                   IN     VARCHAR2
  ,p_branch_name                   IN     VARCHAR2 DEFAULT null
  ,p_amount                        IN     NUMBER   DEFAULT null
  ,p_percentage                    IN     NUMBER   DEFAULT null
  ,p_priority                      IN     NUMBER
  ,p_comments                      IN     VARCHAR2 DEFAULT null
  ,p_attribute_category            IN     VARCHAR2 DEFAULT null
  ,p_attribute1                    IN     VARCHAR2 DEFAULT null
  ,p_attribute2                    IN     VARCHAR2 DEFAULT null
  ,p_attribute3                    IN     VARCHAR2 DEFAULT null
  ,p_attribute4                    IN     VARCHAR2 DEFAULT null
  ,p_attribute5                    IN     VARCHAR2 DEFAULT null
  ,p_attribute6                    IN     VARCHAR2 DEFAULT null
  ,p_attribute7                    IN     VARCHAR2 DEFAULT null
  ,p_attribute8                    IN     VARCHAR2 DEFAULT null
  ,p_attribute9                    IN     VARCHAR2 DEFAULT null
  ,p_attribute10                   IN     VARCHAR2 DEFAULT null
  ,p_attribute11                   IN     VARCHAR2 DEFAULT null
  ,p_attribute12                   IN     VARCHAR2 DEFAULT null
  ,p_attribute13                   IN     VARCHAR2 DEFAULT null
  ,p_attribute14                   IN     VARCHAR2 DEFAULT null
  ,p_attribute15                   IN     VARCHAR2 DEFAULT null
  ,p_attribute16                   IN     VARCHAR2 DEFAULT null
  ,p_attribute17                   IN     VARCHAR2 DEFAULT null
  ,p_attribute18                   IN     VARCHAR2 DEFAULT null
  ,p_attribute19                   IN     VARCHAR2 DEFAULT null
  ,p_attribute20                   IN     VARCHAR2 DEFAULT null
  ,p_payee_type                    IN     VARCHAR2 DEFAULT null
  ,p_payee_id                      IN     NUMBER   DEFAULT null
  ,p_personal_payment_method_id    OUT    NOCOPY NUMBER
  ,p_external_account_id           OUT    NOCOPY NUMBER
  ,p_object_version_number         OUT    NOCOPY NUMBER
  ,p_effective_start_date          OUT    NOCOPY DATE
  ,p_effective_end_date            OUT    NOCOPY DATE
  ,p_comment_id                    OUT    NOCOPY NUMBER
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) := g_package||'create_sg_personal_pay_method';
  l_valid               VARCHAR2(150);
  l_effective_date      DATE;
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
  l_effective_date := p_effective_date;
  --
  check_sg_insert_legislation
  (p_assignment_id   => p_assignment_id
  ,p_effective_date  => l_effective_date);
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Call the business process to create the personal payment method
  --
  hr_personal_pay_method_api.create_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => l_effective_date
  ,p_assignment_id                 => p_assignment_id
  ,p_org_payment_method_id         => p_org_payment_method_id
  ,p_amount                        => p_amount
  ,p_percentage                    => p_percentage
  ,p_priority                      => p_priority
  ,p_comments                      => p_comments
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_territory_code                => 'SG'
  ,p_segment1                      => p_bank_account_number
  ,p_segment2                      => p_bank_account_name
  ,p_segment3                      => p_bank_account_type
  ,p_segment4                      => p_bank_code
  ,p_segment5                      => p_bank_name
  ,p_segment6                      => p_branch_code
  ,p_segment7                      => p_branch_name
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_personal_payment_method_id    => p_personal_payment_method_id
  ,p_external_account_id           => p_external_account_id
  ,p_object_version_number         => p_object_version_number
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_comment_id                    => p_comment_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 8);
END create_sg_personal_pay_method;
-- ----------------------------------------------------------------------------
-- |--------------------< update_sg_personal_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_sg_personal_pay_method
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_datetrack_update_mode         IN     VARCHAR2
  ,p_personal_payment_method_id    IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_bank_account_number           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_account_name             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_account_type             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_code                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_name                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_branch_code                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_branch_name                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_amount                        IN     NUMBER   DEFAULT hr_api.g_number
  ,p_comments                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_percentage                    IN     NUMBER   DEFAULT hr_api.g_number
  ,p_priority                      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_attribute_category            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute1                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute2                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute3                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute4                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute5                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute6                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute7                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute8                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute9                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute10                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute11                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute12                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute13                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute14                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute15                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute16                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute17                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute18                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute19                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute20                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_payee_type                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_payee_id                      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_comment_id                    OUT    NOCOPY NUMBER
  ,p_external_account_id           OUT    NOCOPY NUMBER
  ,p_effective_start_date          OUT    NOCOPY DATE
  ,p_effective_end_date            OUT    NOCOPY DATE
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) :=  g_package||'update_sg_personal_pay_method';
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Ensure that the legislation rule for the employee assignment business
  -- group is 'SG'.
  --
  check_sg_update_legislation
  (p_personal_payment_method_id => p_personal_payment_method_id
  ,p_effective_date             => p_effective_date);
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Call the business process to update the personal payment method
  --
hr_personal_pay_method_api.update_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => trunc(p_effective_date)
  ,p_datetrack_update_mode         => p_datetrack_update_mode
  ,p_personal_payment_method_id    => p_personal_payment_method_id
  ,p_object_version_number         => p_object_version_number
  ,p_amount                        => p_amount
  ,p_comments                      => p_comments
  ,p_percentage                    => p_percentage
  ,p_priority                      => p_priority
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_territory_code                => 'SG'
  ,p_segment1                      => p_bank_account_number
  ,p_segment2                      => p_bank_account_name
  ,p_segment3                      => p_bank_account_type
  ,p_segment4                      => p_bank_code
  ,p_segment5                      => p_bank_name
  ,p_segment6                      => p_branch_code
  ,p_segment7                      => p_branch_name
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_comment_id                    => p_comment_id
  ,p_external_account_id           => p_external_account_id
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
END update_sg_personal_pay_method;

END hr_sg_personal_pay_method_api;

/
