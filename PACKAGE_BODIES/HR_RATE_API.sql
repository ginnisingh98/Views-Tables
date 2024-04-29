--------------------------------------------------------
--  DDL for Package Body HR_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RATE_API" AS
/* $Header: pypyrapi.pkb 115.5 2004/08/09 00:18:52 jpthomas noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_rate_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_rate >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_rate
  (p_validate                      IN            BOOLEAN   DEFAULT FALSE
  ,p_effective_date                IN            DATE
  ,p_business_group_id             IN            NUMBER
  ,p_name                          IN            VARCHAR2
  ,p_rate_type                     IN            VARCHAR2
  ,p_rate_uom                      IN            VARCHAR2
  ,p_parent_spine_id               IN            NUMBER   DEFAULT NULL
  ,p_comments                      IN            VARCHAR2 DEFAULT NULL
  ,p_rate_basis                    IN            VARCHAR2 DEFAULT NULL
  ,p_asg_rate_type                 IN            VARCHAR2 DEFAULT NULL
  ,p_attribute_category            IN            VARCHAR2 DEFAULT NULL
  ,p_attribute1                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute2                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute3                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute4                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute5                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute6                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute7                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute8                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute9                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute10                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute11                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute12                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute13                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute14                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute15                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute16                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute17                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute18                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute19                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute20                   IN            VARCHAR2 DEFAULT NULL
  ,p_object_version_number            OUT NOCOPY NUMBER
  ,p_rate_id                          OUT NOCOPY NUMBER) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_rate';
  l_effective_date        DATE;
  l_object_version_number NUMBER;
  l_rate_id               pay_rates.rate_id%TYPE;
-- Bug 3795968 Starts Here
  CURSOR csr_full_hr_installed IS
  SELECT null
  FROM   fnd_product_installations i
  WHERE  i.status = 'I'
  AND    i.application_id = 800;
--
  l_dummy varchar2(1);
-- Bug 3795968 Ends Here
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  SAVEPOINT create_rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Process Logic
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of create_rate
    --
    hr_rate_api_bk1.create_rate_b
     (p_effective_date                => l_effective_date
     ,p_business_group_id             => p_business_group_id
     ,p_name                          => p_name
     ,p_rate_type                     => p_rate_type
     ,p_rate_uom                      => p_rate_uom
     ,p_parent_spine_id               => p_parent_spine_id
     ,p_comments                      => p_comments
     ,p_rate_basis                    => p_rate_basis
     ,p_asg_rate_type                 => p_asg_rate_type
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
     ,p_attribute10                   => p_attribute11
     ,p_attribute11                   => p_attribute12
     ,p_attribute12                   => p_attribute13
     ,p_attribute13                   => p_attribute14
     ,p_attribute14                   => p_attribute15
     ,p_attribute15                   => p_attribute16
     ,p_attribute16                   => p_attribute17
     ,p_attribute17                   => p_attribute18
     ,p_attribute18                   => p_attribute19
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20);
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rate'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_rate
    --
  END;
  --
  hr_utility.set_location(l_proc, 30);
  --
  pay_pyr_ins.ins
    (p_effective_date                 => l_effective_date
    ,p_business_group_id              => p_business_group_id
    ,p_name                           => p_name
    ,p_rate_type                      => p_rate_type
    ,p_rate_uom                       => p_rate_uom
    ,p_parent_spine_id                => p_parent_spine_id
    ,p_comments                       => p_comments
    ,p_attribute_category             => p_attribute_category
    ,p_attribute1                     => p_attribute1
    ,p_attribute2                     => p_attribute2
    ,p_attribute3                     => p_attribute3
    ,p_attribute4                     => p_attribute4
    ,p_attribute5                     => p_attribute5
    ,p_attribute6                     => p_attribute6
    ,p_attribute7                     => p_attribute7
    ,p_attribute8                     => p_attribute8
    ,p_attribute9                     => p_attribute9
    ,p_attribute10                    => p_attribute10
    ,p_attribute11                    => p_attribute11
    ,p_attribute12                    => p_attribute12
    ,p_attribute13                    => p_attribute13
    ,p_attribute14                    => p_attribute14
    ,p_attribute15                    => p_attribute15
    ,p_attribute16                    => p_attribute16
    ,p_attribute17                    => p_attribute17
    ,p_attribute18                    => p_attribute18
    ,p_attribute19                    => p_attribute19
    ,p_attribute20                    => p_attribute20
    ,p_rate_basis                     => p_rate_basis
    ,p_asg_rate_type                  => p_asg_rate_type
    ,p_rate_id                        => l_rate_id
    ,p_object_version_number          => l_object_version_number);
  --
  hr_utility.set_location(l_proc, 40);
  --
  --
  -- Start of fix 3273216
  -- calling database package to insert database item
-- Bug 3795968 Starts Here
  OPEN  csr_full_hr_installed;
  FETCH csr_full_hr_installed INTO l_dummy;
  IF csr_full_hr_installed%FOUND THEN
     hrdyndbi.create_grade_spine_dict(p_rate_id => l_rate_id);
  END IF;
  CLOSE csr_full_hr_installed;
-- Bug 3795968 Ends Here
  --
  hr_utility.set_location(l_proc, 45);
  --
  -- End of 3273216
  BEGIN
    --
    -- Start of API User Hook for the after hook of create_rate
    --
    hr_rate_api_bk1.create_rate_a
     (p_effective_date                => l_effective_date
	 ,p_rate_id                       => l_rate_id
	 ,p_object_version_number         => l_object_version_number
     ,p_business_group_id             => p_business_group_id
     ,p_name                          => p_name
     ,p_rate_type                     => p_rate_type
     ,p_rate_uom                      => p_rate_uom
     ,p_parent_spine_id               => p_parent_spine_id
     ,p_comments                      => p_comments
     ,p_rate_basis                    => p_rate_basis
     ,p_asg_rate_type                 => p_asg_rate_type
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
     ,p_attribute10                   => p_attribute11
     ,p_attribute11                   => p_attribute12
     ,p_attribute12                   => p_attribute13
     ,p_attribute13                   => p_attribute14
     ,p_attribute14                   => p_attribute15
     ,p_attribute15                   => p_attribute16
     ,p_attribute16                   => p_attribute17
     ,p_attribute17                   => p_attribute18
     ,p_attribute18                   => p_attribute19
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20);
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rate'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_rate
    --
  END;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- When in validation only mode raise the Validate_Enabled exception
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
  p_rate_id               := l_rate_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := NULL;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_rate;
    --
    -- Bugfix 2692195
    -- Reset all OUT/IN OUT parameters
    --
    p_object_version_number := null;
    p_rate_id := null;
    --
    RAISE;
    --
END create_rate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< update_rate >---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_rate
  (p_validate                      IN     BOOLEAN   DEFAULT FALSE
  ,p_rate_id                       IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_effective_date                IN     DATE
  ,p_name                          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_rate_uom                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_parent_spine_id               IN     NUMBER   DEFAULT hr_api.g_number
  ,p_comments                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_rate_basis                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_asg_rate_type                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
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
  ,p_attribute20                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_rate';
  l_object_version_number NUMBER;
  l_effective_date        DATE;
-- Bug 3795968 Starts Here
  CURSOR csr_full_hr_installed IS
  SELECT null
  FROM   fnd_product_installations i
  WHERE  i.status = 'I'
  AND    i.application_id = 800;
--
  l_dummy varchar2(1);
-- Bug 3795968 Ends Here
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  SAVEPOINT update_rate;
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  hr_utility.set_location(l_proc, 20);
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of update_rate
    --
    hr_rate_api_bk2.update_rate_a
     (p_effective_date                => l_effective_date
	 ,p_rate_id                       => p_rate_id
	 ,p_object_version_number         => l_object_version_number
     ,p_name                          => p_name
     ,p_rate_uom                      => p_rate_uom
     ,p_parent_spine_id               => p_parent_spine_id
     ,p_comments                      => p_comments
     ,p_rate_basis                    => p_rate_basis
     ,p_asg_rate_type                 => p_asg_rate_type
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
     ,p_attribute10                   => p_attribute11
     ,p_attribute11                   => p_attribute12
     ,p_attribute12                   => p_attribute13
     ,p_attribute13                   => p_attribute14
     ,p_attribute14                   => p_attribute15
     ,p_attribute15                   => p_attribute16
     ,p_attribute16                   => p_attribute17
     ,p_attribute17                   => p_attribute18
     ,p_attribute18                   => p_attribute19
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20);
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rate'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_rate
    --
  END;
  --
  hr_utility.set_location(l_proc, 30);
  --
  pay_pyr_upd.upd
    (p_effective_date                 => l_effective_date
    ,p_rate_id                        => p_rate_id
    ,p_object_version_number          => l_object_version_number
    ,p_name                           => p_name
    ,p_rate_uom                       => p_rate_uom
    ,p_parent_spine_id                => p_parent_spine_id
    ,p_comments                       => p_comments
    ,p_rate_basis                     => p_rate_basis
    ,p_asg_rate_type                  => p_asg_rate_type
    ,p_attribute_category             => p_attribute_category
    ,p_attribute1                     => p_attribute1
    ,p_attribute2                     => p_attribute2
    ,p_attribute3                     => p_attribute3
    ,p_attribute4                     => p_attribute4
    ,p_attribute5                     => p_attribute5
    ,p_attribute6                     => p_attribute6
    ,p_attribute7                     => p_attribute7
    ,p_attribute8                     => p_attribute8
    ,p_attribute9                     => p_attribute9
    ,p_attribute10                    => p_attribute10
    ,p_attribute11                    => p_attribute11
    ,p_attribute12                    => p_attribute12
    ,p_attribute13                    => p_attribute13
    ,p_attribute14                    => p_attribute14
    ,p_attribute15                    => p_attribute15
    ,p_attribute16                    => p_attribute16
    ,p_attribute17                    => p_attribute17
    ,p_attribute18                    => p_attribute18
    ,p_attribute19                    => p_attribute19
    ,p_attribute20                    => p_attribute20);
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Start of fix 3273216
  -- calling database package to first delete the existing database item
  -- and then call the database package to insert the updated database item
-- Bug 3795968 Starts Here
  OPEN  csr_full_hr_installed;
  FETCH csr_full_hr_installed INTO l_dummy;
  IF csr_full_hr_installed%FOUND THEN
     hrdyndbi.delete_grade_spine_dict(p_rate_id => p_rate_id);
     hrdyndbi.create_grade_spine_dict(p_rate_id => p_rate_id);
  END IF;
  CLOSE csr_full_hr_installed;
-- Bug 3795968 Ends Here
  --
  hr_utility.set_location(l_proc, 45);
  --
  -- End of 3273216
  BEGIN
    --
    -- Start of API User Hook for the after hook of update_rate
    --
	hr_rate_api_bk2.update_rate_a
     (p_effective_date                => l_effective_date
	 ,p_rate_id                       => p_rate_id
	 ,p_object_version_number         => l_object_version_number
     ,p_name                          => p_name
     ,p_rate_uom                      => p_rate_uom
     ,p_parent_spine_id               => p_parent_spine_id
     ,p_comments                      => p_comments
     ,p_rate_basis                    => p_rate_basis
     ,p_asg_rate_type                 => p_asg_rate_type
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
     ,p_attribute10                   => p_attribute11
     ,p_attribute11                   => p_attribute12
     ,p_attribute12                   => p_attribute13
     ,p_attribute13                   => p_attribute14
     ,p_attribute14                   => p_attribute15
     ,p_attribute15                   => p_attribute16
     ,p_attribute16                   => p_attribute17
     ,p_attribute17                   => p_attribute18
     ,p_attribute18                   => p_attribute19
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20);
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rate'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_rate
    --
  END;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- When in validation only mode raise the Validate_Enabled exception
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_rate;
    --
    -- Bugfix 2692195
    -- Reset all OUT/IN OUT parameters
    --
    p_object_version_number := l_object_version_number;
    --
    RAISE;
    --
END update_rate;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_rate >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_rate
  (p_validate                       IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                 IN     DATE
  ,p_rate_id                        IN     NUMBER
  ,p_rate_type                      IN     VARCHAR2
  ,p_object_version_number          IN OUT NOCOPY NUMBER) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'delete_rate';
  l_object_version_number NUMBER;
  l_effective_date        DATE;
-- Bug 3795968 Starts Here
  CURSOR csr_full_hr_installed IS
  SELECT null
  FROM   fnd_product_installations i
  WHERE  i.status = 'I'
  AND    i.application_id = 800;
--
  l_dummy varchar2(1);
-- Bug 3795968 Ends Here
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  SAVEPOINT delete_rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of delete_rate
    --
    hr_rate_api_bk3.delete_rate_b
      (p_rate_id               =>  p_rate_id
	  ,p_rate_type             =>  p_rate_type
      ,p_object_version_number =>  l_object_version_number
      ,p_effective_date        =>  l_effective_date);
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
	  --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_rate'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_rate
    --
  END;
  --
  hr_utility.set_location( l_proc, 30);
  --
  --
  -- Process Logic
  -- =============
  --
  --  Need to lock main table to maintain the locking ladder order
  --
  pay_pyr_shd.lck(p_rate_id               => p_rate_id
                 ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location( l_proc, 40);
  --
  pay_pyr_del.del(p_rate_id               => p_rate_id
                 ,p_rate_type             => p_rate_type
                 ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location( l_proc, 50);
  --
  -- Start of fix 3273216
  -- calling database package to delete database item
-- Bug 3795968 Starts Here
  OPEN  csr_full_hr_installed;
  FETCH csr_full_hr_installed INTO l_dummy;
  IF csr_full_hr_installed%FOUND THEN
     hrdyndbi.delete_grade_spine_dict(p_rate_id => p_rate_id);
  END IF;
  CLOSE csr_full_hr_installed;
-- Bug 3795968 Ends Here
  --
  hr_utility.set_location( l_proc, 55);
  --
  -- End of 3273216
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of delete_rate
    --
    hr_rate_api_bk3.delete_rate_a
      (p_rate_id                =>  p_rate_id
	  ,p_rate_type              =>  p_rate_type
      ,p_effective_date         =>  l_effective_date
      ,p_object_version_number  =>  l_object_version_number);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_rate'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_rate
    --
  END;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_rate;
    --
    -- Bugfix 2692195
    -- Reset all OUT/IN OUT parameters
    --
    p_object_version_number := l_object_version_number;
    --
    RAISE;
    --
END delete_rate;
--
PROCEDURE create_assignment_rate
  (p_validate                      IN            BOOLEAN   DEFAULT FALSE
  ,p_effective_date                IN            DATE
  ,p_business_group_id             IN            NUMBER
  ,p_name                          IN            VARCHAR2
  ,p_rate_basis                    IN            VARCHAR2
  ,p_asg_rate_type                 IN            VARCHAR2 DEFAULT NULL
  ,p_attribute_category            IN            VARCHAR2 DEFAULT NULL
  ,p_attribute1                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute2                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute3                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute4                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute5                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute6                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute7                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute8                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute9                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute10                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute11                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute12                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute13                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute14                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute15                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute16                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute17                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute18                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute19                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute20                   IN            VARCHAR2 DEFAULT NULL
  ,p_object_version_number            OUT NOCOPY NUMBER
  ,p_rate_id                          OUT NOCOPY NUMBER) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_assignment_rate';
  l_effective_date        DATE;
  l_object_version_number NUMBER;
  l_rate_id               pay_rates.rate_id%TYPE;
  l_default_rate_type     pay_rates.rate_type%TYPE;
  l_default_rate_uom      pay_rates.rate_uom%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  SAVEPOINT create_assignment_rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Set the rate type to be Assignment
  --
  l_default_rate_type := 'A';
  --
  -- Set the rate unit of measure to be Money
  --
  l_default_rate_uom  := 'M';
  --
  -- Process Logic
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of create_assignment_rate
    --
    hr_rate_api_bk4.create_assignment_rate_b
     (p_effective_date                => l_effective_date
     ,p_business_group_id             => p_business_group_id
     ,p_name                          => p_name
     ,p_rate_type                     => l_default_rate_type
     ,p_rate_uom                      => l_default_rate_uom
     ,p_rate_basis                    => p_rate_basis
     ,p_asg_rate_type                 => p_asg_rate_type
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
     ,p_attribute10                   => p_attribute11
     ,p_attribute11                   => p_attribute12
     ,p_attribute12                   => p_attribute13
     ,p_attribute13                   => p_attribute14
     ,p_attribute14                   => p_attribute15
     ,p_attribute15                   => p_attribute16
     ,p_attribute16                   => p_attribute17
     ,p_attribute17                   => p_attribute18
     ,p_attribute18                   => p_attribute19
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20);
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_assignment_rate'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_assignment_rate
    --
  END;
  --
  hr_utility.set_location(l_proc, 30);
  --
  hr_rate_api.create_rate
    (p_effective_date                 => l_effective_date
    ,p_business_group_id              => p_business_group_id
    ,p_name                           => p_name
    ,p_rate_type                      => l_default_rate_type
    ,p_rate_uom                       => l_default_rate_uom
    ,p_attribute_category             => p_attribute_category
    ,p_attribute1                     => p_attribute1
    ,p_attribute2                     => p_attribute2
    ,p_attribute3                     => p_attribute3
    ,p_attribute4                     => p_attribute4
    ,p_attribute5                     => p_attribute5
    ,p_attribute6                     => p_attribute6
    ,p_attribute7                     => p_attribute7
    ,p_attribute8                     => p_attribute8
    ,p_attribute9                     => p_attribute9
    ,p_attribute10                    => p_attribute10
    ,p_attribute11                    => p_attribute11
    ,p_attribute12                    => p_attribute12
    ,p_attribute13                    => p_attribute13
    ,p_attribute14                    => p_attribute14
    ,p_attribute15                    => p_attribute15
    ,p_attribute16                    => p_attribute16
    ,p_attribute17                    => p_attribute17
    ,p_attribute18                    => p_attribute18
    ,p_attribute19                    => p_attribute19
    ,p_attribute20                    => p_attribute20
    ,p_rate_basis                     => p_rate_basis
    ,p_asg_rate_type                  => p_asg_rate_type
    ,p_rate_id                        => l_rate_id
    ,p_object_version_number          => l_object_version_number);
  --
  hr_utility.set_location(l_proc, 40);
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of create_assignment_rate
    --
    hr_rate_api_bk4.create_assignment_rate_a
     (p_effective_date                => l_effective_date
	 ,p_rate_id                       => l_rate_id
	 ,p_object_version_number         => l_object_version_number
     ,p_business_group_id             => p_business_group_id
     ,p_name                          => p_name
     ,p_rate_type                     => l_default_rate_type
     ,p_rate_uom                      => l_default_rate_uom
     ,p_rate_basis                    => p_rate_basis
     ,p_asg_rate_type                 => p_asg_rate_type
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
     ,p_attribute10                   => p_attribute11
     ,p_attribute11                   => p_attribute12
     ,p_attribute12                   => p_attribute13
     ,p_attribute13                   => p_attribute14
     ,p_attribute14                   => p_attribute15
     ,p_attribute15                   => p_attribute16
     ,p_attribute16                   => p_attribute17
     ,p_attribute17                   => p_attribute18
     ,p_attribute18                   => p_attribute19
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20);
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_assignment_rate'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_assignment_rate
    --
  END;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- When in validation only mode raise the Validate_Enabled exception
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
  p_rate_id               := l_rate_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_assignment_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := NULL;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_assignment_rate;
    --
    -- Bugfix 2692195
    -- Reset all OUT/IN OUT parameters
    --
    p_object_version_number := null;
    p_rate_id := null;
    --
    RAISE;
    --
END create_assignment_rate;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_assignment_rate >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_assignment_rate
  (p_validate                      IN     BOOLEAN   DEFAULT FALSE
  ,p_rate_id                       IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_effective_date                IN     DATE
  ,p_name                          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_rate_basis                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_asg_rate_type                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
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
  ,p_attribute20                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_assignment_rate';
  l_object_version_number NUMBER;
  l_effective_date        DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  SAVEPOINT update_assignment_rate;
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  hr_utility.set_location(l_proc, 20);
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of update_assignment_rate
    --
    hr_rate_api_bk5.update_assignment_rate_a
     (p_effective_date                => l_effective_date
	 ,p_rate_id                       => p_rate_id
	 ,p_object_version_number         => l_object_version_number
     ,p_name                          => p_name
     ,p_rate_basis                    => p_rate_basis
     ,p_asg_rate_type                 => p_asg_rate_type
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
     ,p_attribute10                   => p_attribute11
     ,p_attribute11                   => p_attribute12
     ,p_attribute12                   => p_attribute13
     ,p_attribute13                   => p_attribute14
     ,p_attribute14                   => p_attribute15
     ,p_attribute15                   => p_attribute16
     ,p_attribute16                   => p_attribute17
     ,p_attribute17                   => p_attribute18
     ,p_attribute18                   => p_attribute19
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20);
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_assignment_rate'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_assignment_rate
    --
  END;
  --
  hr_utility.set_location(l_proc, 30);
  --
  hr_rate_api.update_rate
    (p_effective_date                 => l_effective_date
    ,p_rate_id                        => p_rate_id
    ,p_object_version_number          => l_object_version_number
    ,p_name                           => p_name
    ,p_rate_basis                     => p_rate_basis
    ,p_asg_rate_type                  => p_asg_rate_type
    ,p_attribute_category             => p_attribute_category
    ,p_attribute1                     => p_attribute1
    ,p_attribute2                     => p_attribute2
    ,p_attribute3                     => p_attribute3
    ,p_attribute4                     => p_attribute4
    ,p_attribute5                     => p_attribute5
    ,p_attribute6                     => p_attribute6
    ,p_attribute7                     => p_attribute7
    ,p_attribute8                     => p_attribute8
    ,p_attribute9                     => p_attribute9
    ,p_attribute10                    => p_attribute10
    ,p_attribute11                    => p_attribute11
    ,p_attribute12                    => p_attribute12
    ,p_attribute13                    => p_attribute13
    ,p_attribute14                    => p_attribute14
    ,p_attribute15                    => p_attribute15
    ,p_attribute16                    => p_attribute16
    ,p_attribute17                    => p_attribute17
    ,p_attribute18                    => p_attribute18
    ,p_attribute19                    => p_attribute19
    ,p_attribute20                    => p_attribute20);
  --
  hr_utility.set_location(l_proc, 40);
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of update_assignment_rate
    --
	hr_rate_api_bk5.update_assignment_rate_a
     (p_effective_date                => l_effective_date
	 ,p_rate_id                       => p_rate_id
	 ,p_object_version_number         => l_object_version_number
     ,p_name                          => p_name
     ,p_rate_basis                    => p_rate_basis
     ,p_asg_rate_type                 => p_asg_rate_type
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
     ,p_attribute10                   => p_attribute11
     ,p_attribute11                   => p_attribute12
     ,p_attribute12                   => p_attribute13
     ,p_attribute13                   => p_attribute14
     ,p_attribute14                   => p_attribute15
     ,p_attribute15                   => p_attribute16
     ,p_attribute16                   => p_attribute17
     ,p_attribute17                   => p_attribute18
     ,p_attribute18                   => p_attribute19
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20);
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_assignment_rate'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_assignment_rate
    --
  END;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- When in validation only mode raise the Validate_Enabled exception
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_assignment_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_assignment_rate;
    --
    -- Bugfix 2692195
    -- Reset all OUT/IN OUT parameters
    --
    p_object_version_number := l_object_version_number;
    --
    RAISE;
    --
END update_assignment_rate;
--
END hr_rate_api;

/
