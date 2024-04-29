--------------------------------------------------------
--  DDL for Package Body HR_AE_CONTRACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AE_CONTRACT_API" AS
/* $Header: pectcaei.pkb 120.0.12000000.1 2007/01/21 21:38:53 appldev ship $ */
--
-- Package Variables
--
g_package  VARCHAR2(33) := 'hr_ae_contract_api.';
--
-- ----------------------------------------------------------------------
-- |------------------------< create_ae_contract >----------------------|
-- ----------------------------------------------------------------------
--
PROCEDURE create_ae_contract
  (p_validate                       IN BOOLEAN    DEFAULT FALSE
  ,p_contract_id                    OUT NOCOPY NUMBER
  ,p_effective_start_date           OUT NOCOPY DATE
  ,p_effective_end_date             OUT NOCOPY DATE
  ,p_object_version_number          OUT NOCOPY NUMBER
  ,p_person_id                      IN  NUMBER
  ,p_reference                      IN  VARCHAR2
  ,p_type                           IN  VARCHAR2
  ,p_status                         IN  VARCHAR2
  ,p_status_reason                  IN  VARCHAR2  DEFAULT NULL
  ,p_doc_status                     IN  VARCHAR2  DEFAULT NULL
  ,p_doc_status_change_date         IN  DATE      DEFAULT NULL
  ,p_description                    IN  VARCHAR2  DEFAULT NULL
  ,p_duration                       IN  NUMBER    DEFAULT NULL
  ,p_duration_units                 IN  VARCHAR2  DEFAULT NULL
  ,p_contractual_job_title          IN  VARCHAR2  DEFAULT NULL
  ,p_parties                        IN  VARCHAR2  DEFAULT NULL
  ,p_start_reason                   IN  VARCHAR2  DEFAULT NULL
  ,p_end_reason                     IN  VARCHAR2  DEFAULT NULL
  ,p_number_of_extensions           IN  NUMBER    DEFAULT NULL
  ,p_extension_reason               IN  VARCHAR2  DEFAULT NULL
  ,p_extension_period               IN  NUMBER    DEFAULT NULL
  ,p_extension_period_units         IN  VARCHAR2  DEFAULT NULL
  ,p_employment_status              IN  VARCHAR2  DEFAULT NULL
  ,p_expiry_date                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute_category             IN  VARCHAR2  DEFAULT NULL
  ,p_attribute1                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute2                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute3                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute4                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute5                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute6                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute7                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute8                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute9                     IN  VARCHAR2  DEFAULT NULL
  ,p_attribute10                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute11                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute12                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute13                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute14                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute15                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute16                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute17                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute18                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute19                    IN  VARCHAR2  DEFAULT NULL
  ,p_attribute20                    IN  VARCHAR2  DEFAULT NULL
  ,p_effective_date                 IN  DATE
 ) IS
  --
  -- Declare cursors and local variables
  --
  l_business_group_id per_contracts_f.business_group_id%TYPE;
  l_proc              VARCHAR2(72) := g_package||'create_ae_contract';
  l_legislation_code  VARCHAR2(2);
  --
  CURSOR csr_get_business_group_id IS
    SELECT per.business_group_id
    FROM per_all_people_f per
    WHERE per.person_id = p_person_id
    and   p_effective_DATE between per.effective_start_DATE
                               and per.effective_END_DATE;
  --
  CURSOR csr_bg IS
    SELECT legislation_code
    FROM per_business_groups pbg
    WHERE pbg.business_group_id = l_business_group_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  SAVEPOINT create_ae_contract;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Get person details.
  --
  OPEN  csr_get_business_group_id;
  FETCH csr_get_business_group_id
  INTO l_business_group_id;
  --
  IF csr_get_business_group_id%NOTFOUND THEN
    --
    CLOSE csr_get_business_group_id;
	--
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_get_business_group_id;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Check that the specified business group IS valid.
  --
  OPEN  csr_bg;
  FETCH csr_bg INTO l_legislation_code;
  --
  IF csr_bg%NOTFOUND THEN
    --
    CLOSE csr_bg;
	--
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_bg;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Check that the legislation of the specified business group is 'AE'.
  --
  IF l_legislation_code <> 'AE' THEN
    --
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','AE');
    hr_utility.raise_error;
	--
  END IF;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Call the contract business process
  --
  hr_contract_api.create_contract
    (p_validate			             => p_validate
    ,p_contract_id                   => p_contract_id
    ,p_effective_start_date          => p_effective_start_date
    ,p_effective_end_date            => p_effective_end_date
    ,p_object_version_number         => p_object_version_number
    ,p_person_id                     => p_person_id
    ,p_reference                     => p_reference
    ,p_type                          => p_type
    ,p_status                        => p_status
    ,p_status_reason                 => p_status_reason
    ,p_doc_status                    => p_doc_status
    ,p_doc_status_change_date        => p_doc_status_change_date
    ,p_description                   => p_description
    ,p_duration                      => p_duration
    ,p_duration_units                => p_duration_units
    ,p_contractual_job_title         => p_contractual_job_title
    ,p_parties                       => p_parties
    ,p_start_reason                  => p_start_reason
    ,p_end_reason                    => p_end_reason
    ,p_number_of_extensions          => p_number_of_extensions
    ,p_extension_reason              => p_extension_reason
    ,p_extension_period              => p_extension_period
    ,p_extension_period_units        => p_extension_period_units
    ,p_ctr_information_category      => 'AE'
    ,p_ctr_information1	             => p_employment_status
    ,p_ctr_information2              => p_expiry_date
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
    ,p_effective_date                => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
END create_ae_contract;
--
-- ----------------------------------------------------------------------
-- |------------------------< update_ae_contract >----------------------|
-- ----------------------------------------------------------------------
--
PROCEDURE update_ae_contract
  (p_validate                       IN BOOLEAN    DEFAULT FALSE
  ,p_contract_id                    IN  NUMBER
  ,p_effective_start_date           OUT NOCOPY DATE
  ,p_effective_end_date             OUT NOCOPY DATE
  ,p_object_version_number          IN OUT NOCOPY NUMBER
  ,p_person_id                      IN  NUMBER
  ,p_reference                      IN  VARCHAR2
  ,p_type                           IN  VARCHAR2
  ,p_status                         IN  VARCHAR2
  ,p_status_reason                  IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_doc_status                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_doc_status_change_date         IN  DATE      DEFAULT hr_api.g_DATE
  ,p_description                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_duration                       IN  NUMBER    DEFAULT hr_api.g_NUMBER
  ,p_duration_units                 IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_contractual_job_title          IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_parties                        IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_start_reason                   IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_end_reason                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_number_of_extensions           IN  NUMBER    DEFAULT hr_api.g_NUMBER
  ,p_extension_reason               IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_extension_period               IN  NUMBER    DEFAULT hr_api.g_NUMBER
  ,p_extension_period_units         IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_employment_status              IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_expiry_date                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute_category             IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute1                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute2                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute3                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute4                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute5                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute6                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute7                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute8                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute9                     IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute10                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute11                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute12                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute13                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute14                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute15                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute16                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute17                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute18                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute20                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_effective_date                 IN  DATE
  ,p_datetrack_mode                 IN  VARCHAR2) IS
  --
  -- Declare cursors and local variables
  --
  l_business_group_id    per_contracts_f.business_group_id%TYPE;
  l_proc                 VARCHAR2(72) := g_package||'create_ae_contract';
  l_legislation_code     VARCHAR2(2);
  --
  CURSOR csr_get_business_group_id IS
    SELECT per.business_group_id
    FROM per_all_people_f per
    WHERE per.person_id = p_person_id
    AND   p_effective_DATE BETWEEN per.effective_start_DATE
                               AND per.effective_END_DATE;
  --
  CURSOR csr_bg IS
    SELECT legislation_code
    FROM per_business_groups pbg
    WHERE pbg.business_group_id = l_business_group_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  SAVEPOINT update_ae_contract;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Get person details.
  --
  OPEN  csr_get_business_group_id;
  FETCH csr_get_business_group_id
  INTO l_business_group_id;
  --
  IF csr_get_business_group_id%NOTFOUND THEN
  	--
    CLOSE csr_get_business_group_id;
	--
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_get_business_group_id;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Check that the specified business group is valid.
  --
  OPEN csr_bg;
  FETCH csr_bg INTO l_legislation_code;
  --
  IF csr_bg%NOTFOUND THEN
    --
    CLOSE csr_bg;
	--
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_bg;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Check that the legislation of the specified business group IS 'AE'.
  --
  IF l_legislation_code  <>  'AE' THEN
    --
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','AE');
    hr_utility.raise_error;
	--
  END IF;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Call the contract business process
  --
  hr_contract_api.update_contract
    (p_validate			     	 	 => p_validate
    ,p_contract_id                   => p_contract_id
    ,p_effective_start_date          => p_effective_start_date
    ,p_effective_end_date            => p_effective_end_date
    ,p_object_version_number         => p_object_version_number
    ,p_person_id                     => p_person_id
    ,p_reference                     => p_reference
    ,p_type                          => p_type
    ,p_status                        => p_status
    ,p_status_reason                 => p_status_reason
    ,p_doc_status                    => p_doc_status
    ,p_doc_status_change_date        => p_doc_status_change_date
    ,p_description                   => p_description
    ,p_duration                      => p_duration
    ,p_duration_units                => p_duration_units
    ,p_contractual_job_title         => p_contractual_job_title
    ,p_parties                       => p_parties
    ,p_start_reason                  => p_start_reason
    ,p_end_reason                    => p_end_reason
    ,p_number_of_extensions          => p_number_of_extensions
    ,p_extension_reason              => p_extension_reason
    ,p_extension_period              => p_extension_period
    ,p_extension_period_units        => p_extension_period_units
    ,p_ctr_information_category      => 'AE'
    ,p_ctr_information1	             => p_employment_status
    ,p_ctr_information2	             => p_expiry_date
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
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
END update_ae_contract;
--
END hr_ae_contract_api;

/
