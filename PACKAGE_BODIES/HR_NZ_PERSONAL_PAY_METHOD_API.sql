--------------------------------------------------------
--  DDL for Package Body HR_NZ_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NZ_PERSONAL_PAY_METHOD_API" AS
/* $Header: hrnzwrpp.pkb 120.2 2005/10/06 04:59:38 rpalli noship $ */
  --
  -- Package Variables
  --
  g_package  VARCHAR2(33) := 'hr_nz_personal_pay_method_api.';

  ------------------------------------------------------------
  -- Private Procedures
  ------------------------------------------------------------

  PROCEDURE check_insert_legislation
  	(p_assignment_id          IN     NUMBER
  	,p_effective_date         IN OUT NOCOPY DATE
  	,p_leg_code               IN     VARCHAR2
  	) IS
  	--
  	-- Declare cursors and local variables
  	--
  	l_proc                VARCHAR2(72) := g_package||'chk_insert_legislation';
  	l_valid               VARCHAR2(150);
  	l_effective_date      DATE;
  	--
  	CURSOR csr_legcode IS
  		SELECT pbg.legislation_code
  		FROM   per_business_groups pbg,
	       per_assignments_f   asg
    	WHERE  pbg.business_group_id = asg.business_group_id
    	AND    asg.assignment_id     = p_assignment_id
    	AND    p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date;

  BEGIN
  	hr_utility.set_location('Entering:'|| l_proc, 5);
  	--
  	-- Check that p_assignment_id and p_effective_date are not null as they
  	-- are used by the cursor to validate the business group.
  	--
  	hr_api.mandatory_arg_error
    	(p_api_name       => l_proc
    	,p_argument       => 'assignment_id'
    	,p_argument_value => p_assignment_id);
 	--
  	hr_api.mandatory_arg_error
    	(p_api_name       => l_proc
    	,p_argument       => 'effective_date'
  	  	,p_argument_value => p_effective_date);
  	--
  	hr_utility.set_location(l_proc, 6);
  	--
  	-- Ensure that the legislation rule for the employee assignment
  	-- business group is that of p_leg_code.
  	--
  	OPEN csr_legcode;
  	FETCH csr_legcode INTO l_valid;
  	--
	IF (csr_legcode%NOTFOUND)
	THEN
    	CLOSE csr_legcode;
    	hr_utility.set_message(801, 'HR_7348_ASSIGNMENT_INVALID');
    	hr_utility.raise_error;
  	END IF;
  	IF (csr_legcode%FOUND AND l_valid <> p_leg_code)
	THEN
    	CLOSE csr_legcode;
    	hr_utility.set_message(801, 'HR_7898_PPM_BUS_GRP_INVALID');
  		hr_utility.raise_error;
  	END IF;
  	--
  	CLOSE csr_legcode;
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
  END check_insert_legislation;


  PROCEDURE check_update_legislation
	(p_personal_payment_method_id    IN  pay_personal_payment_methods_f.personal_payment_method_id%TYPE
  	,p_effective_date                IN  DATE
  	,p_leg_code                      IN  VARCHAR2
  	) is
  	--
  	-- Declare cursors and local variables
  	--
  	l_proc                VARCHAR2(72) := g_package||'check_update_legislation';
  	l_valid               VARCHAR2(150);
  	--
  	CURSOR csr_legcode is
    	SELECT pbg.legislation_code
    	FROM   per_business_groups pbg,
		       pay_personal_payment_methods_f ppm
    	WHERE  pbg.business_group_id = ppm.business_group_id
    	AND    ppm.personal_payment_method_id = p_personal_payment_method_id
    	AND    p_effective_date BETWEEN ppm.effective_start_date AND ppm.effective_end_date;
	--
  BEGIN
  	--
  	-- Ensure that the legislation rule for the employee assignment business
  	-- group is that of p_leg_code.
  	--
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  	OPEN csr_legcode;
  	FETCH csr_legcode INTO l_valid;
  	--
  	IF (csr_legcode%NOTFOUND)
	THEN
    	CLOSE csr_legcode;
    	hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    	hr_utility.raise_error;
  	END IF;
  	IF (csr_legcode%FOUND AND l_valid <> p_leg_code)
	THEN
    	hr_utility.set_message(801, 'HR_7898_PPM_BUS_GRP_INVALID');
    	hr_utility.raise_error;
  	END IF;
   	CLOSE csr_legcode;
  	hr_utility.set_location('Leaving:'|| l_proc, 20);

  END check_update_legislation;

  ------------------------------------------------------------
  --  Private Functions
  ------------------------------------------------------------

  ------------------------------------------------------------
  -- Public Procedures
  ------------------------------------------------------------

 -------------------------------------------------------------
 -- create_nz_personal_pay_method
 -------------------------------------------------------------

PROCEDURE create_nz_personal_pay_method
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_assignment_id                 IN     NUMBER
  ,p_run_type_id                   IN     NUMBER  DEFAULT NULL
  ,p_org_payment_method_id         IN     NUMBER
  ,p_bank_branch_number            IN     VARCHAR2
  ,p_account_number                IN     VARCHAR2
  ,p_account_suffix                IN     VARCHAR2
  ,p_reference					   IN	  VARCHAR2 DEFAULT NULL
  ,p_code						   IN	  VARCHAR2 DEFAULT NULL
  ,p_third_party_particulars	   IN	  VARCHAR2 DEFAULT NULL
  ,p_amount                        IN     NUMBER   DEFAULT NULL
  ,p_percentage                    IN     NUMBER   DEFAULT NULL
  ,p_priority                      IN     NUMBER
  ,p_comments                      IN     VARCHAR2 DEFAULT NULL
  ,p_attribute_category            IN     VARCHAR2 DEFAULT NULL
  ,p_attribute1                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute2                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute3                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute4                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute5                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute6                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute7                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute8                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute9                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute10                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute11                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute12                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute13                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute14                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute15                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute16                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute17                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute18                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute19                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute20                   IN     VARCHAR2 DEFAULT NULL
  ,p_concat_segments               IN     VARCHAR2 DEFAULT NULL
  ,p_payee_type                    IN     VARCHAR2 DEFAULT NULL
  ,p_payee_id                      IN     NUMBER   DEFAULT NULL
  ,p_ppm_information1              IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information2              IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information3              IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information4              IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information5              IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information6              IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information7              IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information8              IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information9              IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information10             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information11             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information12             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information13             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information14             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information15             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information16             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information17             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information18             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information19             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information20             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information21             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information22             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information23             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information24             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information25             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information26             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information27             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information28             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information29             IN     VARCHAR2 DEFAULT NULL
  ,p_ppm_information30             IN     VARCHAR2 DEFAULT NULL
  ,p_personal_payment_method_id    OUT NOCOPY   NUMBER
  ,p_external_account_id           OUT NOCOPY   NUMBER
  ,p_object_version_number         OUT NOCOPY   NUMBER
  ,p_effective_start_date          OUT NOCOPY   DATE
  ,p_effective_end_date            OUT NOCOPY   DATE
  ,p_comment_id                    OUT NOCOPY   NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) :=
			  g_package||'create_nz_personal_pay_method';
 -- l_valid               VARCHAR2(150);
  l_effective_date      DATE;
  l_check_bank_acct		VARCHAR2(5);
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  hr_nz_personal_pay_method_api.check_insert_legislation
  (p_assignment_id   => p_assignment_id
  ,p_effective_date  => l_effective_date
  ,p_leg_code        => 'NZ');
  --
  hr_utility.set_location(l_proc, 7);

  --
  -- Call the business process to create the personal payment method
  --
  -- NOTE: p_segment6 is set to TRUE for the KFF cross-validation to work
  --       A BEFORE API hook will fire the account validation and if it is OK the TRUE value is correct
  --       otherwise if the validation fails the record will not be stored.
  --	   Reason :- p_segment6 is an IN parameter and cannot be changed after the validation

  hr_personal_pay_method_api.create_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => l_effective_date
  ,p_assignment_id                 => p_assignment_id
  ,p_run_type_id                   => p_run_type_id
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
  ,p_territory_code                => 'NZ'
  ,p_segment1                      => p_bank_branch_number
  ,p_segment2                      => p_account_number
  ,p_segment3                      => p_account_suffix
  ,p_segment4                      => p_reference
  ,p_segment5                      => p_code
  ,p_segment6					   => 'TRUE'
  ,p_segment7			   => p_third_party_particulars
  ,p_concat_segments               => p_concat_segments
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_ppm_information1              => p_ppm_information1
  ,p_ppm_information2              => p_ppm_information2
  ,p_ppm_information3              => p_ppm_information3
  ,p_ppm_information4              => p_ppm_information4
  ,p_ppm_information5              => p_ppm_information5
  ,p_ppm_information6              => p_ppm_information6
  ,p_ppm_information7              => p_ppm_information7
  ,p_ppm_information8              => p_ppm_information8
  ,p_ppm_information9              => p_ppm_information9
  ,p_ppm_information10             => p_ppm_information10
  ,p_ppm_information11             => p_ppm_information11
  ,p_ppm_information12             => p_ppm_information12
  ,p_ppm_information13             => p_ppm_information13
  ,p_ppm_information14             => p_ppm_information14
  ,p_ppm_information15             => p_ppm_information15
  ,p_ppm_information16             => p_ppm_information16
  ,p_ppm_information17             => p_ppm_information17
  ,p_ppm_information18             => p_ppm_information18
  ,p_ppm_information19             => p_ppm_information19
  ,p_ppm_information20             => p_ppm_information20
  ,p_ppm_information21             => p_ppm_information21
  ,p_ppm_information22             => p_ppm_information22
  ,p_ppm_information23             => p_ppm_information23
  ,p_ppm_information24             => p_ppm_information24
  ,p_ppm_information25             => p_ppm_information25
  ,p_ppm_information26             => p_ppm_information26
  ,p_ppm_information27             => p_ppm_information27
  ,p_ppm_information28             => p_ppm_information28
  ,p_ppm_information29             => p_ppm_information29
  ,p_ppm_information30             => p_ppm_information30
  ,p_personal_payment_method_id    => p_personal_payment_method_id
  ,p_external_account_id           => p_external_account_id
  ,p_object_version_number         => p_object_version_number
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_comment_id                    => p_comment_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 9);
END create_nz_personal_pay_method;


  ------------------------------------------------------------------------------
  -- update_nz_personal_pay_method
  ------------------------------------------------------------------------------

PROCEDURE update_nz_personal_pay_method
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_datetrack_update_mode         IN     VARCHAR2
  ,p_personal_payment_method_id    IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_bank_branch_number            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_account_number                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_account_suffix                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_reference                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_code                          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_third_party_particulars	   IN	  VARCHAR2 DEFAULT hr_api.g_varchar2
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
  ,p_concat_segments               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_payee_type                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_payee_id                      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_ppm_information1              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information2              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information3              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information4              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information5              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information6              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information7              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information8              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information9              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information10             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information11             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information12             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information13             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information14             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information15             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information16             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information17             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information18             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information19             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information20             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information21             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information22             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information23             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information24             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information25             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information26             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information27             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information28             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information29             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ppm_information30             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_comment_id                    OUT NOCOPY   NUMBER
  ,p_external_account_id           OUT NOCOPY   NUMBER
  ,p_effective_start_date          OUT NOCOPY   DATE
  ,p_effective_end_date            OUT NOCOPY   DATE
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc VARCHAR2(72) := g_package||'update_nz_personal_pay_method';
  l_check_bank_acct		VARCHAR2(5);
  l_effective_date		DATE;
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Ensure that the legislation rule for the employee assignment business
  -- group is 'NZ'.
  --

  hr_nz_personal_pay_method_api.check_update_legislation
  (p_personal_payment_method_id => p_personal_payment_method_id
  ,p_effective_date             => l_effective_date
  ,p_leg_code                   => 'NZ');
  --
  hr_utility.set_location(l_proc, 6);

  --
  -- Call the business process to update the personal payment method
  --
  -- NOTE: p_segment6 is set to TRUE for the KFF cross-validation to work
  --       A BEFORE API hook will fire the account validation and if it is OK the TRUE value is correct
  --       otherwise if the validation fails the record will not be stored.
  --	   Reason :- p_segment6 is an IN parameter and cannot be changed after the validation

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
  ,p_territory_code                => 'NZ'
  ,p_segment1                      => p_bank_branch_number
  ,p_segment2                      => p_account_number
  ,p_segment3                      => p_account_suffix
  ,p_segment4					   => p_reference
  ,p_segment5					   => p_code
  ,p_segment6					   => 'TRUE'
  ,p_segment7			   => p_third_party_particulars
  ,p_concat_segments               => p_concat_segments
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_ppm_information1              => p_ppm_information1
  ,p_ppm_information2              => p_ppm_information2
  ,p_ppm_information3              => p_ppm_information3
  ,p_ppm_information4              => p_ppm_information4
  ,p_ppm_information5              => p_ppm_information5
  ,p_ppm_information6              => p_ppm_information6
  ,p_ppm_information7              => p_ppm_information7
  ,p_ppm_information8              => p_ppm_information8
  ,p_ppm_information9              => p_ppm_information9
  ,p_ppm_information10             => p_ppm_information10
  ,p_ppm_information11             => p_ppm_information11
  ,p_ppm_information12             => p_ppm_information12
  ,p_ppm_information13             => p_ppm_information13
  ,p_ppm_information14             => p_ppm_information14
  ,p_ppm_information15             => p_ppm_information15
  ,p_ppm_information16             => p_ppm_information16
  ,p_ppm_information17             => p_ppm_information17
  ,p_ppm_information18             => p_ppm_information18
  ,p_ppm_information19             => p_ppm_information19
  ,p_ppm_information20             => p_ppm_information20
  ,p_ppm_information21             => p_ppm_information21
  ,p_ppm_information22             => p_ppm_information22
  ,p_ppm_information23             => p_ppm_information23
  ,p_ppm_information24             => p_ppm_information24
  ,p_ppm_information25             => p_ppm_information25
  ,p_ppm_information26             => p_ppm_information26
  ,p_ppm_information27             => p_ppm_information27
  ,p_ppm_information28             => p_ppm_information28
  ,p_ppm_information29             => p_ppm_information29
  ,p_ppm_information30             => p_ppm_information30
  ,p_comment_id                    => p_comment_id
  ,p_external_account_id           => p_external_account_id
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
  END update_nz_personal_pay_method;

END hr_nz_personal_pay_method_api;

/
