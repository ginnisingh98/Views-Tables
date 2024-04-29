--------------------------------------------------------
--  DDL for Package Body HR_RATE_VALUES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RATE_VALUES_API" AS
/* $Header: pypgrapi.pkb 115.7 2003/10/27 03:09:25 lsilveir noship $ */
--
-- Package Variables
--
g_package  VARCHAR2(33) := '  hr_rate_values_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_rate_value >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_rate_value
  (p_validate                 IN     BOOLEAN       DEFAULT FALSE
  ,p_effective_date           IN     DATE
  ,p_business_group_id        IN     NUMBER
  ,p_rate_id                  IN     NUMBER
  ,p_grade_or_spinal_point_id IN     NUMBER
  ,p_rate_type                IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2      DEFAULT NULL
  ,p_maximum                  IN     VARCHAR2      DEFAULT NULL
  ,p_mid_value                IN     VARCHAR2      DEFAULT NULL
  ,p_minimum                  IN     VARCHAR2      DEFAULT NULL
  ,p_sequence                 IN     NUMBER        DEFAULT NULL
  ,p_value                    IN     VARCHAR2      DEFAULT NULL
  ,p_grade_rule_id               OUT NOCOPY NUMBER
  ,p_object_version_number       OUT NOCOPY NUMBER
  ,p_effective_start_date        OUT NOCOPY DATE
  ,p_effective_end_date          OUT NOCOPY DATE) IS
  --
  -- Declare cursors and local variables
  --
  l_grade_rule_id            pay_grade_rules_f.grade_rule_id%TYPE;
  l_effective_start_date     pay_grade_rules_f.effective_start_date%TYPE;
  l_effective_end_date       pay_grade_rules_f.effective_end_date%TYPE;
  l_object_version_number    pay_grade_rules_f.object_version_number%TYPE;
  l_effective_date           DATE;
  l_proc                     VARCHAR2(72) := g_package||'create_rate_value';
  --
  l_rate_uom                 pay_rates.rate_uom%TYPE;
  l_currency_code            pay_grade_rules_f.currency_code%TYPE;
  --
  cursor csr_get_rate_uom is
  select rate_uom
  from   pay_rates
  where  rate_id = p_rate_id;
  --
  cursor csr_get_curr_code is
  select currency_code
  from   per_business_groups_perf
  where  business_group_id = p_business_group_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT create_rate_value;
  --
  -- Truncate date paramters
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Default the currency code if required.
  --
  IF p_currency_code IS NULL THEN
    --
    hr_utility.set_location(l_proc, 12);
    --
    -- Fetch the Rate Unit Of Measure
    --
    OPEN csr_get_rate_uom;
    --
    FETCH csr_get_rate_uom INTO l_rate_uom;
    IF csr_get_rate_uom%NOTFOUND THEN
      CLOSE csr_get_rate_uom;
      --
      hr_utility.set_location(l_proc, 13);
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    END IF;
    --
    CLOSE csr_get_rate_uom;
    --
    hr_utility.set_location(l_proc, 14);
    --
    IF l_rate_uom = 'M' THEN
      --
      -- Get default currency code from business group.
      --
      hr_utility.set_location(l_proc, 15);
      --
      OPEN csr_get_curr_code;
      --
      FETCH csr_get_curr_code INTO l_currency_code;
      IF csr_get_curr_code%NOTFOUND THEN
        CLOSE csr_get_curr_code;
        --
        hr_utility.set_location(l_proc, 16);
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      END IF;
      --
      CLOSE csr_get_curr_code;
      --
    ELSE
      l_currency_code := p_currency_code;
    END IF;
  ELSE
    l_currency_code := p_currency_code;
  END IF;
  --
  -- Process Logic
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of create_rate_value
    --
	hr_utility.set_location(l_proc, 20);
	--
	hr_rate_value_bk1.create_rate_value_b
      (p_effective_date           =>  l_effective_date
      ,p_business_group_id        =>  p_business_group_Id
      ,p_rate_id                  =>  p_rate_id
      ,p_grade_or_spinal_point_id =>  p_grade_or_spinal_point_id
      ,p_rate_type                =>  p_rate_type
      ,p_currency_code            =>  l_currency_code
      ,p_maximum                  =>  p_maximum
      ,p_mid_value                =>  p_mid_value
      ,p_minimum                  =>  p_minimum
      ,p_sequence                 =>  p_sequence
      ,p_value                    =>  p_value);
	--
	hr_utility.set_location(l_proc, 30);
	--
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
	  --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rate_value'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_rate_value
    --
  END;
  --
  hr_utility.set_location(l_proc, 40);
  --
  pay_pgr_ins.ins
    (p_effective_date                 => l_effective_date
    ,p_business_group_id              => p_business_group_id
    ,p_rate_id                        => p_rate_id
    ,p_grade_or_spinal_point_id       => p_grade_or_spinal_point_id
    ,p_rate_type                      => p_rate_type
    ,p_maximum                        => p_maximum
    ,p_mid_value                      => p_mid_value
    ,p_minimum                        => p_minimum
    ,p_sequence                       => p_sequence
    ,p_value                          => p_value
    ,p_currency_code                  => l_currency_code
    ,p_grade_rule_id                  => l_grade_rule_id
    ,p_object_version_number          => l_object_version_number
    ,p_effective_start_date           => l_effective_start_date
    ,p_effective_end_date             => l_effective_end_Date);
  --
  hr_utility.set_location(l_proc, 50);
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of create_rate_value
    --
	hr_utility.set_location(l_proc, 60);
	--
    hr_rate_value_bk1.create_rate_value_a
      (p_effective_date           => l_effective_date
      ,p_grade_rule_Id            => l_grade_rule_id
      ,p_object_version_number    => l_object_version_number
      ,p_effective_start_date     => l_effective_start_date
      ,p_effective_end_date       => l_effective_end_date
      ,p_business_group_id        => p_business_group_id
      ,p_rate_id                  => p_rate_id
      ,p_grade_or_spinal_point_id => p_grade_or_spinal_point_id
      ,p_rate_type                => p_rate_type
      ,p_currency_code            => l_currency_code
      ,p_maximum                  => p_maximum
      ,p_mid_value                => p_mid_value
      ,p_minimum                  => p_minimum
      ,p_sequence                 => p_sequence
      ,p_value                    => p_value);
	--
	hr_utility.set_location(l_proc, 70);
	--
  EXCEPTION
    ---
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rate_value'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_rate_value
    --
  END;
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- When in validation only mode RAISE the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
    --
  END IF;
  --
  -- Set all output arguments
  --
  p_grade_rule_id            := l_grade_rule_id;
  p_effective_start_date     := l_effective_start_date;
  p_effective_end_date       := l_effective_end_date;
  p_object_version_number    := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been RAISEd
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO create_rate_value;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
    p_grade_rule_id            := null;
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_object_version_number    := null;
	--
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_rate_value;
    p_grade_rule_id            := null;
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_object_version_number    := null;
    RAISE;
    --
END create_rate_value;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_rate_value >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_rate_value
  (p_validate                 IN     BOOLEAN       DEFAULT FALSE
  ,p_grade_rule_id            IN     NUMBER
  ,p_effective_date           IN     DATE
  ,p_datetrack_mode           IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_maximum                  IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_mid_value                IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_minimum                  IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_sequence                 IN     NUMBER        DEFAULT hr_api.g_number
  ,p_value                    IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_object_version_number    IN OUT NOCOPY NUMBER
  ,p_effective_start_date        OUT NOCOPY DATE
  ,p_effective_end_date          OUT NOCOPY DATE) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_rate_value';
  l_object_version_number pay_grade_rules_f.object_version_number%TYPE;
  l_effective_start_date  pay_grade_rules_f.effective_start_date%TYPE;
  l_effective_end_date    pay_grade_rules_f.effective_END_date%TYPE;
  l_effective_date        DATE;
  l_temp_ovn              number := p_object_version_number;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT update_rate_value;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of update_rate_value
    --
	hr_rate_value_bk2.update_rate_value_b
      (p_grade_rule_id            => p_grade_rule_id
      ,p_effective_date           => p_effective_date
      ,p_currency_code            => p_currency_code
      ,p_maximum                  => p_maximum
      ,p_mid_value                => p_mid_value
      ,p_minimum                  => p_minimum
      ,p_sequence                 => p_sequence
      ,p_value                    => p_value
      ,p_object_version_number    => l_object_version_number);
  --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
	  --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rate_value'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_rate_value
    --
  END;
  --
  hr_utility.set_location(l_proc, 30);
  --
  pay_pgr_upd.upd
    (p_effective_date               => l_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_grade_rule_id                => p_grade_rule_id
    ,p_object_version_number        => l_object_version_number
    ,p_maximum                      => p_maximum
    ,p_mid_value                    => p_mid_value
    ,p_minimum                      => p_minimum
    ,p_sequence                     => p_sequence
    ,p_value                        => p_value
    ,p_currency_code                => p_currency_code
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date);
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of update_rate_value
    --
	hr_rate_value_bk2.update_rate_value_a
      (p_grade_rule_id            => p_grade_rule_id
      ,p_effective_date           => p_effective_date
      ,p_currency_code            => p_currency_code
      ,p_maximum                  => p_maximum
      ,p_mid_value                => p_mid_value
      ,p_minimum                  => p_minimum
      ,p_sequence                 => p_sequence
      ,p_value                    => p_value
      ,p_object_version_number    => l_object_version_number
      ,p_effective_start_date     => l_effective_start_date
      ,p_effective_end_date       => l_effective_end_date);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rate_value'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_rate_value
    --
  END;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- When in validation only mode RAISE the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
    --
  END IF;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been raised
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO update_rate_value;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
    p_effective_start_date  := l_effective_start_date;
    p_effective_end_date    := l_effective_end_date;

    p_object_version_number := l_temp_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_rate_value;
    -- Reset IN OUT parameters and set OUT parameters.
    p_object_version_number    := l_temp_ovn;
    p_effective_start_date     := null;
    p_effective_end_date       := null;

    RAISE;
    --
END update_rate_value;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_rate_value >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_rate_value
  (p_validate                       IN     BOOLEAN  DEFAULT FALSE
  ,p_grade_rule_id                  IN     NUMBER
  ,p_datetrack_mode                 IN     VARCHAR2
  ,p_effective_date                 IN     DATE
  ,p_object_version_number          IN OUT NOCOPY NUMBER
  ,p_effective_start_date              OUT NOCOPY DATE
  ,p_effective_end_date                OUT NOCOPY DATE) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'delete_rate_value';
  l_object_version_number pay_grade_rules_f.object_version_number%TYPE;
  l_effective_start_date  pay_grade_rules_f.effective_start_date%TYPE;
  l_effective_end_date    pay_grade_rules_f.effective_end_date%TYPE;
  l_effective_date        DATE;
  l_temp_ovn              number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT delete_rate_value;
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of delete_rate_value
    --
	hr_rate_value_bk3.delete_rate_value_b
      (p_grade_rule_id                  => p_grade_rule_id
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => l_effective_date);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_rate_value'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_rate_value
    --
  END;
  --
  hr_utility.set_location(l_proc, 30);
  --
  pay_pgr_del.del
    (p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_grade_rule_id                 => p_grade_rule_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_END_date);
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of delete_rate_value
    --
	hr_rate_value_bk3.delete_rate_value_a
      (p_grade_rule_id                  => p_grade_rule_id
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => l_effective_date);
  --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_rate_value'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_entitlement_line
    --
  END;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- When in validation only mode RAISE the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
    --
  END IF;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been RAISEd
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO delete_rate_value;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date   := null;

    p_object_version_number := l_temp_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_rate_value;
    -- Reset IN OUT parameters and set OUT parameters.
    p_object_version_number    := l_temp_ovn;
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    RAISE;
    --
END delete_rate_value;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_assignment_rate_value >--------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_assignment_rate_value
  (p_validate                 IN     BOOLEAN       DEFAULT FALSE
  ,p_effective_date           IN     DATE
  ,p_business_group_id        IN     NUMBER
  ,p_rate_id                  IN     NUMBER
  ,p_assignment_id            IN     NUMBER
  ,p_rate_type                IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2      DEFAULT NULL
  ,p_value                    IN     VARCHAR2
  ,p_grade_rule_id               OUT NOCOPY NUMBER
  ,p_object_version_number       OUT NOCOPY NUMBER
  ,p_effective_start_date        OUT NOCOPY DATE
  ,p_effective_end_date          OUT NOCOPY DATE) IS
  --
  -- Declare cursors and local variables
  --
  l_grade_rule_id            pay_grade_rules_f.grade_rule_id%TYPE;
  l_effective_start_date     pay_grade_rules_f.effective_start_date%TYPE;
  l_effective_end_date       pay_grade_rules_f.effective_end_date%TYPE;
  l_object_version_number    pay_grade_rules_f.object_version_number%TYPE;
  l_effective_date           DATE;
  l_default_rate_type        pay_grade_rules_f.rate_type%TYPE;
  l_proc                     VARCHAR2(72) := g_package||'create_assignment_rate_value';
  --
  l_rate_uom                 pay_rates.rate_uom%TYPE;
  l_currency_code            pay_grade_rules_f.currency_code%TYPE;
  --
  cursor csr_get_rate_uom is
  select rate_uom
  from   pay_rates
  where  rate_id = p_rate_id;
  --
  cursor csr_get_curr_code is
  select currency_code
  from   per_business_groups_perf
  where  business_group_id = p_business_group_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT create_assignment_rate_value;
  --
  -- Truncate date paramters
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Default the currency code if required.
  --
  IF p_currency_code IS NULL THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Fetch the Rate Unit Of Measure
    --
    OPEN csr_get_rate_uom;
    --
    FETCH csr_get_rate_uom INTO l_rate_uom;
    IF csr_get_rate_uom%NOTFOUND THEN
      CLOSE csr_get_rate_uom;
      --
      hr_utility.set_location(l_proc, 21);
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    END IF;
    --
    CLOSE csr_get_rate_uom;
    --
    hr_utility.set_location(l_proc, 22);
    --
    IF l_rate_uom = 'M' THEN
      --
      -- Get default currency code from business group.
      --
      hr_utility.set_location(l_proc, 23);
      --
      OPEN csr_get_curr_code;
      --
      FETCH csr_get_curr_code INTO l_currency_code;
      IF csr_get_curr_code%NOTFOUND THEN
        CLOSE csr_get_curr_code;
        --
        hr_utility.set_location(l_proc, 24);
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      END IF;
      --
      CLOSE csr_get_curr_code;
      --
    ELSE
      l_currency_code := p_currency_code;
    END IF;
  ELSE
    l_currency_code := p_currency_code;
  END IF;
  --
  -- Process Logic
  --
  --
  -- Set the default rate type to be Assignment Rate
  --
  l_default_rate_type := 'A';
  --
  hr_utility.set_location(l_proc, 40);
  --
  hr_rate_values_api.create_rate_value
    (p_validate                 => p_validate
    ,p_effective_date           => l_effective_date
    ,p_business_group_id        => p_business_group_id
    ,p_rate_id                  => p_rate_id
    ,p_grade_or_spinal_point_id => p_assignment_id
    ,p_rate_type                => l_default_rate_type
    ,p_currency_code            => l_currency_code
    ,p_value                    => p_value
    ,p_grade_rule_id            => l_grade_rule_id
    ,p_object_version_number    => l_object_version_number
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date);

  --
  hr_utility.set_location(l_proc, 50);
  --
  -- When in validation only mode RAISE the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
    --
  END IF;
  --
  -- Set all output arguments
  --
  p_grade_rule_id            := l_grade_rule_id;
  p_effective_start_date     := l_effective_start_date;
  p_effective_end_date       := l_effective_END_date;
  p_object_version_number    := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been RAISEd
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO create_assignment_rate_value;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
    p_grade_rule_id            := null;
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_object_version_number    := null;
	--
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_assignment_rate_value;
    -- set OUT parameters.
    p_grade_rule_id               := null;
    p_object_version_number       := null;
    p_effective_start_date        := null;
    p_effective_end_date          := null;

    RAISE;
    --
END create_assignment_rate_value;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_assignment_rate_value >--------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_assignment_rate_value
  (p_validate                 IN     BOOLEAN       DEFAULT FALSE
  ,p_grade_rule_id            IN     NUMBER
  ,p_effective_date           IN     DATE
  ,p_datetrack_mode           IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_value                    IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_object_version_number    IN OUT NOCOPY NUMBER
  ,p_effective_start_date        OUT NOCOPY DATE
  ,p_effective_end_date          OUT NOCOPY DATE) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_assignment_rate_value';
  l_object_version_number pay_grade_rules_f.object_version_number%TYPE;
  l_effective_start_date  pay_grade_rules_f.effective_start_date%TYPE;
  l_effective_end_date    pay_grade_rules_f.effective_END_date%TYPE;
  l_effective_date        DATE;
  l_temp_ovn              number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT update_assignment_rate_value;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  hr_utility.set_location(l_proc, 30);
  --
  hr_rate_values_api.update_rate_value
    (p_validate                 => p_validate
    ,p_grade_rule_id            => p_grade_rule_id
    ,p_effective_date           => l_effective_date
    ,p_datetrack_mode           => p_datetrack_mode
    ,p_currency_code            => p_currency_code
    ,p_value                    => p_value
    ,p_object_version_number    => l_object_version_number
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date);
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- When in validation only mode RAISE the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
    --
  END IF;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been raised
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO update_assignment_rate_value;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
	p_effective_start_date  := l_effective_start_date;
    p_effective_end_date    := l_effective_end_date;

    p_object_version_number    := l_temp_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_assignment_rate_value;
    p_object_version_number    := l_temp_ovn;
    p_effective_start_date     := null;
    p_effective_end_date       := null;

    RAISE;
    --
END update_assignment_rate_value;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE lck
  (p_grade_rule_id               IN     NUMBER
  ,p_object_version_number       IN     NUMBER
  ,p_effective_date              IN     DATE
  ,p_datetrack_mode              IN     VARCHAR2
  ,p_validation_start_date          OUT NOCOPY DATE
  ,p_validation_end_date            OUT NOCOPY DATE ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'lck';
  l_validation_start_date DATE;
  l_validation_end_date   DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  /*
  per_dar_shd.lck
    (p_grade_rule_id              => p_grade_rule_id
    ,p_datetrack_mode             => p_datetrack_mode
    ,p_object_version_number      => p_object_version_number
    ,p_effective_date             => p_effective_date
    ,p_validation_start_date      => l_validation_start_date
    ,p_validation_end_date        => l_validation_end_date);
  --
  */
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  exception
  when others then
  p_validation_start_date  := null;
  p_validation_end_date    := null;
  raise;

END lck;
--
END hr_rate_values_api;

/
