--------------------------------------------------------
--  DDL for Package Body HR_CAGR_ENTITLEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAGR_ENTITLEMENT_API" AS
/* $Header: pepceapi.pkb 120.1 2006/10/18 09:05:55 grreddy noship $ */
--
-- Package Variables
--
g_package  VARCHAR2(33) := '  hr_cagr_entitlement_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_cagr_entitlement >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_cagr_entitlement
  (p_validate                       IN     BOOLEAN   DEFAULT FALSE
  ,p_effective_date                 IN     DATE
  ,p_cagr_entitlement_item_id       IN     NUMBER
  ,p_collective_agreement_id        IN     NUMBER
  ,p_end_date                       IN     DATE      DEFAULT NULL
  ,p_status                         IN     VARCHAR2
  ,p_formula_criteria               IN     VARCHAR2
  ,p_formula_id                     IN     NUMBER    DEFAULT NULL
  ,p_units_of_measure               IN     VARCHAR2  DEFAULT NULL
  ,p_message_level                  IN     VARCHAR2  DEFAULT NULL
  ,p_object_version_number             OUT NOCOPY NUMBER
  ,p_cagr_entitlement_id               OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_cagr_entitlement';
  l_object_version_number per_cagr_entitlements.object_version_number%TYPE;
  l_cagr_entitlement_id   per_cagr_entitlements.cagr_entitlement_id%TYPE;
  l_effective_date        DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering :'||l_proc||'/'||p_effective_date, 10);
  --
  -- Issue a SAVEPOINT IF operating IN validation only mode
  --
  SAVEPOINT create_cagr_entitlement;
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Process Logic
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of create_cagr_entitlement
    --
    hr_cagr_entitlement_bk1.create_cagr_entitlement_b
      (
       p_cagr_entitlement_id            =>  p_cagr_entitlement_id
      ,p_cagr_entitlement_item_id       =>  p_cagr_entitlement_item_id
      ,p_collective_agreement_id        =>  p_collective_agreement_id
      ,p_start_date                     =>  p_effective_Date
      ,p_end_date                       =>  p_end_date
      ,p_status                         =>  p_status
      ,p_formula_criteria               =>  p_formula_criteria
      ,p_formula_id                     =>  p_formula_id
      ,p_units_of_measure               =>  p_units_of_measure
	  ,p_message_level                  =>  p_message_level
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_cagr_entitlement'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_cagr_entitlement
    --
  END;
  --
  per_pce_ins.ins
    (p_effective_date                => l_effective_date
	,p_cagr_entitlement_item_id      => p_cagr_entitlement_item_id
    ,p_collective_agreement_id       => p_collective_agreement_id
    ,p_end_date                      => p_end_date
    ,p_status                        => p_status
    ,p_formula_criteria              => p_formula_criteria
    ,p_formula_id                    => p_formula_id
    ,p_units_of_measure              => p_units_of_measure
	,p_message_level                 => p_message_level
    ,p_cagr_entitlement_id           => l_cagr_entitlement_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of create_cagr_entitlement
    --
    hr_cagr_entitlement_bk1.create_cagr_entitlement_a
      (
       p_cagr_entitlement_id            =>  p_cagr_entitlement_id
      ,p_cagr_entitlement_item_id       =>  p_cagr_entitlement_item_id
      ,p_collective_agreement_id        =>  p_collective_agreement_id
      ,p_start_date                     =>  p_effective_date
      ,p_end_date                       =>  p_end_date
      ,p_status                         =>  p_status
      ,p_formula_criteria               =>  p_formula_criteria
      ,p_formula_id                     =>  p_formula_id
      ,p_units_of_measure               =>  p_units_of_measure
	  ,p_message_level                  =>  p_message_level
      ,p_object_version_number          =>  l_object_version_number
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cagr_entitlement'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_cagr_entitlement
    --
  END;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When IN validation only mode raise the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    raise hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_cagr_entitlement_id   := l_cagr_entitlement_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been raised
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO create_cagr_entitlement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode IS being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_cagr_entitlement;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number  := null;
    p_cagr_entitlement_id    := null;
    raise;
    --
END create_cagr_entitlement;
-- ----------------------------------------------------------------------------
-- |------------------------< update_cagr_entitlement >--- ------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_cagr_entitlement
  (p_validate                       IN    BOOLEAN   DEFAULT false
  ,p_effective_date                 IN    DATE
  ,p_cagr_entitlement_id            IN    NUMBER    DEFAULT hr_api.g_number
  ,p_cagr_entitlement_item_id       IN    NUMBER    DEFAULT hr_api.g_number
  ,p_collective_agreement_id        IN    NUMBER    DEFAULT hr_api.g_number
  ,p_status                         IN    VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_end_date                       IN    DATE      DEFAULT hr_api.g_date
  ,p_formula_criteria               IN    VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_formula_id                     IN    NUMBER    DEFAULT hr_api.g_number
  ,p_units_of_measure               IN    VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_message_level                  IN    VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_object_version_number          IN OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_cagr_entitlement';
  l_object_version_number per_cagr_entitlements.object_version_number%TYPE;
  l_ovn per_cagr_entitlements.object_version_number%TYPE := p_object_version_number;
  l_effective_date        DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a SAVEPOINT IF operating IN validation only mode
  --
  SAVEPOINT update_cagr_entitlement;
  --
  -- Truncate any DATE parameters
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
    -- Start of API User Hook for the before hook of update_cagr_entitlement
    --
    hr_cagr_entitlement_bk2.update_cagr_entitlement_b
      (
       p_cagr_entitlement_id            =>  p_cagr_entitlement_id
      ,p_cagr_entitlement_item_id       =>  p_cagr_entitlement_item_id
      ,p_collective_agreement_id        =>  p_collective_agreement_id
      ,p_status                         =>  p_status
	  ,p_end_date                       =>  p_end_date
      ,p_formula_criteria               =>  p_formula_criteria
      ,p_formula_id                     =>  p_formula_id
      ,p_units_of_measure               =>  p_units_of_measure
	  ,p_message_level                  =>  p_message_level
      ,p_object_version_number          =>  p_object_version_number
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cagr_entitlement'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_cagr_entitlement
    --
  END;
  --
  per_pce_upd.upd
    (
	 p_effective_date                => l_effective_date
    ,p_cagr_entitlement_id           => p_cagr_entitlement_id
    ,p_cagr_entitlement_item_id      => p_cagr_entitlement_item_id
    ,p_collective_agreement_id       => p_collective_agreement_id
    ,p_status                        => p_status
	,p_end_date                      => p_end_date
    ,p_formula_criteria              => p_formula_criteria
    ,p_formula_id                    => p_formula_id
    ,p_units_of_measure              => p_units_of_measure
	,p_message_level                 => p_message_level
    ,p_object_version_number         => l_object_version_number
    );
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of update_cagr_entitlement
    --
    hr_cagr_entitlement_bk2.update_cagr_entitlement_a
      (
       p_cagr_entitlement_id            =>  p_cagr_entitlement_id
      ,p_cagr_entitlement_item_id       =>  p_cagr_entitlement_item_id
      ,p_collective_agreement_id        =>  p_collective_agreement_id
      ,p_status                         =>  p_status
	  ,p_end_date                       =>  p_end_date
      ,p_formula_criteria               =>  p_formula_criteria
      ,p_formula_id                     =>  p_formula_id
      ,p_units_of_measure               =>  p_units_of_measure
	  ,p_message_level                  =>  p_message_level
      ,p_object_version_number          =>  l_object_version_number
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cagr_entitlement'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_cagr_entitlement
    --
  END;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When IN validation only mode raise the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    --
    hr_utility.set_location(l_proc, 65);
    --
    raise hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been raised
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO update_cagr_entitlement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode IS being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_cagr_entitlement;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    raise;
    --
END update_cagr_entitlement;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_cagr_entitlement >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_cagr_entitlement
  (p_validate              IN     BOOLEAN  DEFAULT false
  ,p_effective_date        IN     DATE
  ,p_cagr_entitlement_id   IN     per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_object_version_number IN OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  CURSOR csr_entitlement_lines IS
    SELECT cagr_entitlement_line_id,
	       object_version_number
	  FROM per_cagr_entitlement_lines_f pcl
	 WHERE pcl.cagr_entitlement_id = p_cagr_entitlement_id;
  --
  l_proc                     VARCHAR2(72) := g_package||'update_cagr_entitlement';
  l_object_version_number    per_cagr_entitlements.object_version_number%TYPE;
  l_ovn per_cagr_entitlements.object_version_number%TYPE := p_object_version_number;
  l_effective_date           DATE;
  l_pcl_ovn                  NUMBER;
  l_pcl_end_date             DATE;
  l_pcl_start_date           DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a SAVEPOINT IF operating IN validation only mode
  --
  SAVEPOINT delete_cagr_entitlement;
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
    -- Start of API User Hook for the before hook of delete_cagr_entitlement
    --
    hr_cagr_entitlement_bk3.delete_cagr_entitlement_b
      (p_effective_date        => l_effective_date
      ,p_cagr_entitlement_id   => p_cagr_entitlement_id
      ,p_object_version_number => p_object_version_number
      );
	--
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cagr_entitlement'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_cagr_entitlement
    --
  END;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Delete the Entitlement Lines that belong to the Entitlement
  --
  FOR c1 IN csr_entitlement_lines LOOP
    --
	hr_utility.set_location(l_proc||'/'||
	                        c1.cagr_entitlement_line_id||'/'||
							c1.object_version_number, 40);
	--
	l_pcl_ovn := c1.object_version_number;
	--
	hr_cagr_ent_lines_api.delete_entitlement_line
	 (p_validate                       => FALSE
     ,p_cagr_entitlement_line_id       => c1.cagr_entitlement_line_id
     ,p_effective_start_date           => l_pcl_start_date
     ,p_effective_END_date             => l_pcl_end_date
     ,p_object_version_number          => l_pcl_ovn
     ,p_effective_date                 => p_effective_date
     ,p_datetrack_mode                 => 'ZAP');
	--
  END LOOP;
  --
  per_pce_del.del
    (p_cagr_entitlement_id   => p_cagr_entitlement_id
    ,p_object_version_number => l_object_version_number
    );
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of delete_cagr_entitlement
    --
    hr_cagr_entitlement_bk3.delete_cagr_entitlement_a
      (p_effective_date        => l_effective_date
      ,p_cagr_entitlement_id   => p_cagr_entitlement_id
      ,p_object_version_number => l_object_version_number
      );
	--
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cagr_entitlement'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_cagr_entitlement
    --
  END;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When IN validation only mode raise the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    raise hr_api.validate_enabled;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been raised
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO delete_cagr_entitlement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode IS being used.)
    --
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_cagr_entitlement;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    raise;
    --
END delete_cagr_entitlement;
--
END hr_cagr_entitlement_api;

/
