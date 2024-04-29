--------------------------------------------------------
--  DDL for Package Body HR_MX_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MX_PERSONAL_PAY_METHOD_API" AS
/* $Header: hrmxwrpm.pkb 120.0 2005/05/31 01:32 appldev noship $ */
--
-- Package Variables
--
  g_package  varchar2(33);
  g_debug    boolean;
--  ---------------------------------------------------------------------------
-- |--------------------< create_mx_personal_pay_method >----------------------|
--  ---------------------------------------------------------------------------
procedure create_mx_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_run_type_id                   in     number  default null
  ,p_org_payment_method_id         in     number
  ,p_amount                        in     number   default null
  ,p_percentage                    in     number   default null
  ,p_priority                      in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_bank                          in     varchar2
  ,p_branch                        in     varchar2
  ,p_account                       in     varchar2
  ,p_account_type                  in     varchar2
  ,p_clabe                         in     varchar2
  ,p_concat_segments               in     varchar2 default null
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 VARCHAR2(72);
  l_effective_date       DATE;
  l_legislation_code     per_business_groups.legislation_code%type;
  l_business_group_id    per_assignments_f.business_group_id%TYPE;
  --
BEGIN

  l_proc  := g_package||'create_mx_personal_pay_method';

 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Initialise local variables
  --
  l_effective_date    := trunc(p_effective_date);
  l_business_group_id := hr_mx_utility.get_bg_from_assignment(p_assignment_id);

 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;

  --
  -- Check if Business Group of the assignment lies in "MX" legislation
  --
     hr_mx_utility.check_bus_grp(l_business_group_id, 'MX');

 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;

  --
  -- Create the Personal Payment method
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
  ,p_territory_code                => 'MX'
  ,p_segment1                      => p_bank
  ,p_segment2                      => p_branch
  ,p_segment3                      => p_account
  ,p_segment4                      => p_account_type
  ,p_segment5                      => p_clabe
  ,p_concat_segments               => p_concat_segments
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
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;
  --
end create_mx_personal_pay_method;

-- ----------------------------------------------------------------------------
-- |--------------------< update_mx_personal_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_mx_personal_pay_method
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
  ,p_bank                          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_branch                        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_account                       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_account_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_clabe                         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
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
  l_proc                VARCHAR2(72);
  l_effective_date      DATE;
  l_business_group_id   pay_personal_payment_methods_f.business_group_id%TYPE;

    CURSOR csr_get_bg IS
    SELECT business_group_id
    FROM   pay_personal_payment_methods_f
    WHERE  personal_payment_method_id = p_personal_payment_method_id
    AND    rownum < 2;
  --
BEGIN
--
    l_proc  :=  g_package||'update_mx_personal_pay_method';

 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;

  --
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Fetch Business Group ID for the given Personal Payment Method
  --
  OPEN csr_get_bg;
  FETCH csr_get_bg INTO l_business_group_id;

  IF csr_get_bg%NOTFOUND THEN

     if g_debug then
       hr_utility.set_location(l_proc, 20);
     end if;

     CLOSE csr_get_bg;
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  END IF;
  --
  CLOSE csr_get_bg;

  --
  -- Check if the business group lies within 'MX' legislation
  --
  hr_mx_utility.check_bus_grp(l_business_group_id, 'MX');

 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;

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
  ,p_territory_code                => 'MX'
  ,p_segment1                      => p_bank
  ,p_segment2                      => p_branch
  ,p_segment3                      => p_account
  ,p_segment4                      => p_account_type
  ,p_segment5                      => p_clabe
  ,p_concat_segments               => p_concat_segments
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_comment_id                    => p_comment_id
  ,p_external_account_id           => p_external_account_id
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  );
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;

END update_mx_personal_pay_method;

BEGIN
  g_package  := 'hr_mx_personal_pay_method_api.';
  g_debug    := hr_utility.debug_enabled;
END hr_mx_personal_pay_method_api;

/
