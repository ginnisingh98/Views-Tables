--------------------------------------------------------
--  DDL for Package Body HR_IN_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IN_PERSONAL_PAY_METHOD_API" AS
/* $Header: peinwrpm.pkb 120.1 2006/04/24 04:01 statkar noship $ */


--
    g_debug BOOLEAN;

    g_package  VARCHAR2(33);

--
-- ----------------------------------------------------------------------------
-- |--------------------< create_in_personal_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_in_personal_pay_method
  (p_validate                      IN     BOOLEAN  DEFAULT false
  ,p_effective_date                IN     DATE
  ,p_assignment_id                 IN     NUMBER
  ,p_org_payment_method_id         IN     NUMBER
  ,p_amount                        IN     NUMBER   DEFAULT null
  ,p_percentage                    IN     NUMBER   DEFAULT null
  ,p_priority                      IN     NUMBER   DEFAULT null
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
  ,p_account_number                IN     VARCHAR2 DEFAULT null
  ,p_account_type                  IN     VARCHAR2 DEFAULT null
  ,p_bank_code                     IN     VARCHAR2 DEFAULT null
  ,p_branch_code                   IN     VARCHAR2 DEFAULT null
  ,p_concat_segments               IN     VARCHAR2 DEFAULT null
  ,p_payee_type                    IN     VARCHAR2 DEFAULT null
  ,p_payee_id                      IN     NUMBER   DEFAULT null
  ,p_personal_payment_method_id    OUT    NOCOPY NUMBER
  ,p_external_account_id           OUT    NOCOPY NUMBER
  ,p_object_version_number         OUT    NOCOPY NUMBER
  ,p_effective_start_date          OUT    NOCOPY DATE
  ,p_effective_end_date            OUT    NOCOPY DATE
  ,p_comment_id                    out    NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) ;

  l_effective_date      DATE;

  CURSOR legsel (p_assignment_id IN NUMBER, p_effective_date IN DATE) IS
    SELECT  pbg.legislation_code
    FROM    per_business_groups pbg,
            per_assignments_f   asg
    WHERE   pbg.business_group_id   = asg.business_group_id
    AND     asg.assignment_id       = p_assignment_id
    AND     p_effective_date BETWEEN asg.effective_start_date AND asg.effective_END_date;

     l_legislation_code per_business_groups.legislation_code%type;
  --
  --
BEGIN
  l_proc  := g_package||'create_in_personal_pay_method';
  g_debug := hr_utility.debug_enabled ;

  pay_in_utils.set_location(g_debug,'Entering:'|| l_proc, 10);
  --
  --
  l_effective_date := trunc(p_effective_date);
  --

 OPEN  legsel(p_assignment_id, trunc(p_effective_date));
  FETCH legsel
  INTO  l_legislation_code;
  --


  IF legsel%notfound THEN
    CLOSE legsel;
    hr_utility.set_message(800, 'HR_7348_PPM_ASSIGNMENT_INVALID');
    hr_utility.raise_error;
  END IF;

  IF legsel%found AND l_legislation_code <>  'IN' THEN
    CLOSE legsel;
    hr_utility.set_message(801, 'PER_IN_BUS_GRP_INVALID');
    hr_utility.raise_error;
  END IF;

  --
  CLOSE legsel;


  --
  pay_in_utils.set_location(g_debug,l_proc, 20);
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
  ,p_territory_code                => 'IN'
  ,p_segment1                      => p_account_number
  ,p_segment2                      => p_account_type
  ,p_segment3                      => p_bank_code
  ,p_segment4                      => p_branch_code
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
  pay_in_utils.set_location(g_debug,'Leaving:'|| l_proc, 30);

END create_in_personal_pay_method;


-- ----------------------------------------------------------------------------
-- |--------------------< update_in_personal_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_in_personal_pay_method
  (p_validate                      IN     BOOLEAN  DEFAULT false
  ,p_effective_date                IN     DATE
  ,p_datetrack_update_mode         IN     VARCHAR2
  ,p_personal_payment_method_id    IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY   NUMBER
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
  ,p_account_number                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_account_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_code                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_branch_code                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_concat_segments               IN     VARCHAR2 DEFAULT null
  ,p_payee_type                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_payee_id                      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_comment_id                    OUT    NOCOPY   NUMBER
  ,p_external_account_id           OUT    NOCOPY   NUMBER
  ,p_effective_start_date          OUT    NOCOPY   DATE
  ,p_effective_end_date            OUT    NOCOPY   DATE
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) ;
  l_effective_date      DATE;

  CURSOR legsel IS
    SELECT  pbg.legislation_code
    FROM    per_business_groups pbg,
            pay_personal_payment_methods_f ppm
    WHERE   pbg.business_group_id           = ppm.business_group_id
    AND     ppm.personal_payment_method_id  = p_personal_payment_method_id
    AND     p_effective_date BETWEEN ppm.effective_start_date AND ppm.effective_END_date;
--
  l_legislation_code per_business_groups.legislation_code%type;
  --
BEGIN
  l_proc :=  g_package||'update_in_personal_pay_method';
  pay_in_utils.set_location(g_debug,'Entering:'|| l_proc, 10);
  --
  --
  l_effective_date := trunc(p_effective_date);
  --

  OPEN  legsel;
  FETCH legsel
  INTO  l_legislation_code;
  --
  IF legsel%notfound THEN
    CLOSE legsel;
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  END IF;

  IF legsel%found AND l_legislation_code <> 'IN' THEN
    CLOSE legsel;
    hr_utility.set_message(801, 'PER_IN_BUS_GRP_INVALID');
    hr_utility.raise_error;
  END IF;
  --
  CLOSE legsel;

  pay_in_utils.set_location(g_debug,l_proc, 20);
  --
  -- Call the business process to update the personal payment method
  --
  hr_personal_pay_method_api.update_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => l_effective_date
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
  ,p_territory_code                => 'IN'
  ,p_segment1                      => p_account_number
  ,p_segment2                      => p_account_type
  ,p_segment3                      => p_bank_code
  ,p_segment4                      => p_branch_code
  ,p_concat_segments               => p_concat_segments
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_comment_id                    => p_comment_id
  ,p_external_account_id           => p_external_account_id
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  );
  --
  pay_in_utils.set_location(g_debug,'Leaving: '||l_proc, 30);

END update_in_personal_pay_method;

BEGIN
  g_package := 'hr_in_personal_pay_method_api.';

END hr_in_personal_pay_method_api;

/
