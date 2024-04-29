--------------------------------------------------------
--  DDL for Package Body HR_CAGR_ENT_LINES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAGR_ENT_LINES_API" AS
/* $Header: pepclapi.pkb 120.1 2006/10/18 09:22:14 grreddy noship $ */
--
-- Package Variables
--
g_package  VARCHAR2(33) := '  hr_cagr_ent_lines_api.';
--
PROCEDURE delete_from_engine_tables
  (p_cagr_entitlement_line_id IN NUMBER
  ,p_effective_date           IN DATE) IS
  --
  CURSOR csr_entitlement_results IS
    SELECT cagr_request_id,
	       cagr_entitlement_result_id,
		   assignment_id
	  FROM per_cagr_entitlement_results cer
	 WHERE cer.cagr_entitlement_line_id = p_cagr_entitlement_line_id
	 FOR UPDATE;
  --
  CURSOR csr_chk_for_other_lines
    (p_cagr_entitlement_result_id IN NUMBER
	,p_cagr_request_id            IN NUMBER
	,p_assignment_id              IN NUMBER) IS
    SELECT cagr_entitlement_result_id
	  FROM per_cagr_entitlement_results cer
	 WHERE cer.cagr_entitlement_line_id   <> p_cagr_entitlement_line_id
	   AND cer.cagr_request_id             = p_cagr_request_id
	   AND cer.cagr_entitlement_result_id <> p_cagr_entitlement_result_id
	   AND cer.assignment_id               = p_assignment_id;
  --
  -- Declare Local Variables
  --
  l_proc      VARCHAR2(72) := g_package||'delete_from_engine_tables';
  l_result_id per_cagr_entitlement_results.cagr_entitlement_result_id %TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  FOR c_results IN csr_entitlement_results LOOP
    --
	hr_utility.set_location(l_proc||'/'||c_results.cagr_entitlement_result_id
	                        ||'/'||c_results.assignment_id, 20);
	--
	OPEN csr_chk_for_other_lines
	  (p_cagr_request_id            => c_results.cagr_request_id
	  ,p_assignment_id              => c_results.assignment_id
	  ,p_cagr_entitlement_result_id => c_results.cagr_entitlement_result_id);
    --
	FETCH csr_chk_for_other_lines INTO l_result_id;
	--
	-- IF no other results where found that belong to the same
	-- assignment and request id as the line being deleted then
	-- delete from retained rights, log and requests
	--
	IF csr_chk_for_other_lines%NOTFOUND THEN
	  --
	  hr_utility.set_location(l_proc,30);
	  --
	  DELETE FROM per_cagr_retained_rights
	  WHERE cagr_entitlement_line_id = p_cagr_entitlement_line_id;
	  --
	  hr_utility.set_location(l_proc,40);
	  --
	  DELETE FROM per_cagr_entitlement_results
	  WHERE cagr_entitlement_result_id = c_results.cagr_entitlement_result_id;
	  --
	  hr_utility.set_location(l_proc,50);
	  --
	  DELETE FROM per_cagr_log
	  WHERE cagr_request_id = c_results.cagr_request_id;
	  --
	  hr_utility.set_location(l_proc,60);
	  --
	  DELETE FROM per_cagr_requests
	  WHERE cagr_request_id = c_results.cagr_request_id;
	  --
	  hr_utility.set_location(l_proc,70);
	  --
	  CLOSE csr_chk_for_other_lines;
	  --
	ELSE
	  --
	  hr_utility.set_location(l_proc,80);
	  --
	  DELETE FROM per_cagr_retained_rights
	  WHERE cagr_entitlement_result_id = c_results.cagr_entitlement_result_id;
	  --
	  hr_utility.set_location(l_proc,90);
	  --
	  DELETE FROM per_cagr_entitlement_results
	  WHERE cagr_entitlement_result_id = c_results.cagr_entitlement_result_id;
	  --
	  hr_utility.set_location(l_proc,100);
	  --
	  CLOSE csr_chk_for_other_lines;
	  --
	END IF;
	--
  END LOOP;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 999);
  --
END delete_from_engine_tables;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_entitlement_line >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_entitlement_line
  (p_validate                       IN      BOOLEAN   DEFAULT FALSE
  ,p_cagr_entitlement_line_id          OUT NOCOPY  NUMBER
  ,p_mandatory                      IN      VARCHAR2
  ,p_value                          IN      VARCHAR2  DEFAULT NULL
  ,p_range_from                     IN      VARCHAR2  DEFAULT NULL
  ,p_range_to                       IN      VARCHAR2  DEFAULT NULL
  ,p_effective_start_date              OUT NOCOPY  DATE
  ,p_effective_end_date                OUT NOCOPY  DATE
  ,p_grade_spine_id                 IN      NUMBER    DEFAULT NULL
  ,p_parent_spine_id                IN      NUMBER    DEFAULT NULL
  ,p_cagr_entitlement_id            IN      NUMBER
  ,p_status                         IN      VARCHAR2
  ,p_eligy_prfl_id                  IN      NUMBER
  ,p_step_id                        IN      NUMBER    DEFAULT NULL
  ,p_from_step_id                   IN      NUMBER    DEFAULT NULL
  ,p_to_step_id                     IN      NUMBER    DEFAULT NULL
  ,p_object_version_number             OUT NOCOPY  NUMBER
  ,p_oipl_id                           OUT NOCOPY  NUMBER
  ,p_effective_date                 IN      DATE
  ) IS
  --
  -- Declare cursors and local variables
  --
  CURSOR csr_cagr_information IS
    SELECT pl_id,
	       pca.business_group_id,
           cei.opt_id
    FROM   per_collective_agreements pca,
	       per_cagr_entitlements pce,
           per_cagr_entitlement_items cei
    WHERE  pca.collective_agreement_id = pce.collective_agreement_id
	AND    pce.cagr_entitlement_id = p_cagr_entitlement_id
    and    cei.cagr_entitlement_item_id = pce.cagr_entitlement_item_id;
  --
  l_cagr_entitlement_line_id per_cagr_entitlement_lines_f.cagr_entitlement_line_id%TYPE;
  l_effective_start_date     per_cagr_entitlement_lines_f.effective_start_date%TYPE;
  l_effective_end_date       per_cagr_entitlement_lines_f.effective_end_date%TYPE;
  l_effective_date           DATE;
  l_proc                     VARCHAR2(72) := g_package||'create_entitlement_line';
  l_object_version_number    per_cagr_entitlement_lines_f.object_version_number%TYPE;
  l_business_group_id        NUMBER;
  l_opt_id                   ben_opt_f.opt_id%TYPE;
  l_order_number             ben_oipl_f.ordr_num%TYPE;
  --
  l_pl_typ_opt_typ_id        NUMBER;
  l_pl_typ_opt_typ_ovn       NUMBER;
  l_pl_id                    NUMBER;
  --
  l_oipl_id                  NUMBER;
  l_oipl_ovn                 NUMBER;
  --
  l_prtn_elig_prfl_id        NUMBER;
  l_prtn_ovn                 NUMBER;
  --
  l_prtn_elig_id             NUMBER;
  l_prtn_elig_ovn            NUMBER;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT create_entitlement_line;
  --
  -- Truncate date paramters
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  OPEN csr_cagr_information;
  FETCH csr_cagr_information INTO l_pl_id, l_business_group_id, l_opt_id;
  CLOSE csr_cagr_information;
  --
  -- If the entitlement lines has been created as the DEFAULT
  -- line for the Entitlement then set the option in plan id
  -- to be the default as well.
  --
  IF p_eligy_prfl_id = 0 THEN
    --
	l_oipl_id := 0;
  --
  -- If the entitlement line has NOT been created as the
  -- default line then create the option and link it
  -- to the plan.
  --
  ELSE
    --
    BEGIN
      --
	  hr_utility.set_location(l_proc, 40);
	  --
	  l_order_number := per_cagr_utility_pkg.get_next_order_number(p_pl_id => l_pl_id);
	  --
	  ben_option_in_plan_api.create_option_in_plan
        (p_validate                       => p_validate
        ,p_oipl_id                        => l_oipl_id
        ,p_effective_start_date           => l_effective_start_date
        ,p_effective_end_date             => l_effective_end_date
        ,p_pl_id                          => l_pl_id
        ,p_opt_id                         => l_opt_id
        ,p_business_group_id              => l_business_group_id
        ,p_object_version_number          => l_oipl_ovn
        ,p_effective_date                 => l_effective_date
	    ,p_mndtry_flag                    => 'N' -- Default Value
	    ,p_dflt_flag                      => 'N' -- Default Value
	    ,p_oipl_stat_cd                   => 'A' -- Active
	    ,p_elig_apls_flag                 => 'N' -- Default Value
	    ,p_trk_inelig_per_flag            => 'N' -- Default Value
	    ,p_auto_enrt_flag                 => 'N'
	    ,p_ordr_num                       => l_order_number);
	  --
	  hr_utility.set_location(l_proc||'/'||l_oipl_id, 50);
      --
    END;
    --
	BEGIN
	  --
	  ben_participation_elig_api.create_participation_elig
        (p_prtn_elig_id                   =>l_prtn_elig_id
        ,p_effective_start_date           =>l_effective_start_date
        ,p_effective_end_date             =>l_effective_end_date
        ,p_business_group_id              =>l_business_group_id
		,p_prtn_eff_strt_dt_cd            => 'AED'
        --,p_pgm_id                         =>p_pgm_id
        --,p_pl_id                          =>p_pl_id
        ,p_oipl_id                        =>l_oipl_id
        --,p_ptip_id                        =>p_ptip_id
        --,p_plip_id                        =>p_plip_id
        ,p_object_version_number          =>l_prtn_elig_ovn
        ,p_effective_date                 =>p_effective_date
        ) ;
	  --
	END;
	--
    BEGIN
      --
	  hr_utility.set_location(l_proc, 60);
	  --
      ben_prtn_elig_prfl_api.create_prtn_elig_prfl
	    (p_validate               => p_validate
	    ,p_PRTN_ELIG_PRFL_ID      => l_prtn_elig_prfl_id
	    ,p_EFFECTIVE_START_DATE   => l_effective_start_date
	    ,p_EFFECTIVE_END_DATE     => l_effective_end_date
	    ,p_BUSINESS_GROUP_ID      => l_business_group_id
	    ,p_MNDTRY_FLAG            => 'Y'
	    --,p_PRTN_ELIG_ID           => to_number(name_in('CEP.PRTN_ELIG_ID'))
	    ,p_ELIGY_PRFL_ID          => p_eligy_prfl_id
        ,p_oipl_id                => l_oipl_id
        ,p_object_version_number  => l_prtn_ovn
	    ,p_effective_date         => l_effective_date);
	  --
	  hr_utility.set_location(l_proc||'/'||l_prtn_elig_prfl_id, 70);
      --
    END;
	--
  END IF;
  --
  -- Process Logic
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of create_entitlement_line
    --
	hr_utility.set_location(l_proc, 80);
	--
    hr_cagr_ent_lines_bk1.create_entitlement_line_b
      (
       p_mandatory                      =>  p_mandatory
      ,p_value                          =>  p_value
      ,p_range_from                     =>  p_range_from
      ,p_range_to                       =>  p_range_to
      ,p_grade_spine_id                 =>  p_grade_spine_id
      ,p_parent_spine_id                =>  p_parent_spine_id
      ,p_cagr_entitlement_id            =>  p_cagr_entitlement_id
      ,p_status                         =>  p_status
      ,p_oipl_id                        =>  l_oipl_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_step_id                        =>  p_step_id
      ,p_from_step_id                   =>  p_from_step_id
      ,p_to_step_id                     =>  p_to_step_id
      ,p_effective_date                 =>  TRUNC(p_effective_date)
      );
	--
	hr_utility.set_location(l_proc, 90);
	--
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_entitlement_line'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_entitlement_line
    --
  END;
  --
  hr_utility.set_location(l_proc, 100);
  --
  per_pcl_ins.ins
    (p_cagr_entitlement_line_id      => l_cagr_entitlement_line_id
    ,p_mandatory                     => p_mandatory
    ,p_value                         => p_value
    ,p_range_from                    => p_range_from
    ,p_range_to                      => p_range_to
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_END_date            => l_effective_END_date
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_parent_spine_id               => p_parent_spine_id
    ,p_cagr_entitlement_id           => p_cagr_entitlement_id
    ,p_status                        => p_status
    ,p_oipl_id                       => l_oipl_id
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_step_id                       => p_step_id
    ,p_from_step_id                  => p_from_step_id
    ,p_to_step_id                    => p_to_step_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => TRUNC(p_effective_date)
    );
  --
  hr_utility.set_location(l_proc, 110);
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of create_entitlement_line
    --
	hr_utility.set_location(l_proc, 120);
	--
    hr_cagr_ent_lines_bk1.create_entitlement_line_a
      (
       p_cagr_entitlement_line_id       =>  l_cagr_entitlement_line_id
      ,p_mandatory                      =>  p_mandatory
      ,p_value                          =>  p_value
      ,p_range_from                     =>  p_range_from
      ,p_range_to                       =>  p_range_to
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_END_date             =>  l_effective_END_date
      ,p_grade_spine_id                 =>  p_grade_spine_id
      ,p_parent_spine_id                =>  p_parent_spine_id
      ,p_cagr_entitlement_id            =>  p_cagr_entitlement_id
      ,p_status                         =>  p_status
      ,p_oipl_id                        =>  l_oipl_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_step_id                        =>  p_step_id
      ,p_from_step_id                   =>  p_from_step_id
      ,p_to_step_id                     =>  p_to_step_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  l_effective_date
      );
	--
	hr_utility.set_location(l_proc, 130);
	--
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_entitlement_line'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_entitlement_line
    --
  END;
  --
  hr_utility.set_location(l_proc, 140);
  --
  -- When in validation only mode RAISE the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_cagr_entitlement_line_id := l_cagr_entitlement_line_id;
  p_effective_start_date     := l_effective_start_date;
  p_effective_END_date       := l_effective_END_date;
  p_object_version_number    := l_object_version_number;
  p_oipl_id                  := l_oipl_id;
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
    ROLLBACK TO create_entitlement_line;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
    p_cagr_entitlement_line_id := null;
    p_effective_start_date     := null;
    p_effective_END_date       := null;
    p_object_version_number    := null;
	--
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_entitlement_line;
    --
    -- set in out parameters and set out parameters
    --
    p_cagr_entitlement_line_id := null;
    p_effective_start_date     := null;
    p_effective_END_date       := null;
    p_object_version_number    := null;
    p_oipl_id		       := null;
    RAISE;
    --
END create_entitlement_line;
-- ----------------------------------------------------------------------------
-- |------------------------< update_entitlement_line >--- ------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_entitlement_line
  (p_validate                       in  boolean   default false
  ,p_cagr_entitlement_line_id       in  NUMBER
  ,p_mandatory                      in  VARCHAR2  default hr_api.g_VARCHAR2
  ,p_value                          in  VARCHAR2  default hr_api.g_VARCHAR2
  ,p_range_from                     in  VARCHAR2  default hr_api.g_VARCHAR2
  ,p_range_to                       in  VARCHAR2  default hr_api.g_VARCHAR2
  ,p_effective_start_date           out nocopy DATE
  ,p_effective_END_date             out nocopy DATE
  ,p_grade_spine_id                 in  NUMBER    default hr_api.g_number
  ,p_parent_spine_id                in  NUMBER    default hr_api.g_number
  ,p_cagr_entitlement_id            in  NUMBER    default hr_api.g_number
  ,p_status                         in  VARCHAR2  default hr_api.g_VARCHAR2
  ,p_oipl_id                        in  NUMBER    default hr_api.g_number
  ,p_eligy_prfl_id                  in  NUMBER    default hr_api.g_number
  ,p_step_id                        in  NUMBER    default hr_api.g_number
  ,p_from_step_id                   in  NUMBER    default hr_api.g_number
  ,p_to_step_id                     in  NUMBER    default hr_api.g_number
  ,p_object_version_number          in out nocopy NUMBER
  ,p_effective_date                 in  DATE
  ,p_datetrack_mode                 in  VARCHAR2
  ) is
  --
  CURSOR get_prtn_elig_prfl_id IS
  SELECT b2.prtn_elig_prfl_id,
         b2.object_version_number
  FROM   ben_prtn_elig_prfl_f b2,
         ben_prtn_elig_f b1
  WHERE  p_effective_date BETWEEN b2.effective_start_Date
                              AND b2.effective_end_date
  AND    b2.prtn_elig_id = b1.prtn_elig_id
  AND    b1.oipl_id = p_oipl_id
  AND    p_effective_date BETWEEN b1.effective_start_date
                             AND  b1.effective_end_date;
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_entitlement_line';
  l_object_version_number per_cagr_entitlement_lines_f.object_version_number%TYPE;
 l_ovn per_cagr_entitlement_lines_f.object_version_number%TYPE := p_object_version_number;
  l_effective_start_date  per_cagr_entitlement_lines_f.effective_start_date%TYPE;
  l_effective_end_date    per_cagr_entitlement_lines_f.effective_END_date%TYPE;
  l_effective_date        DATE;
  --
  l_prtn_elig_prfl_id NUMBER;
  l_prtn_eff_st_date  DATE;
  l_prtn_eff_end_date DATE;
  l_prtn_ovn          NUMBER;
  l_oipl_id           NUMBER;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT update_entitlement_line;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of update_entitlement_line
    --
    hr_cagr_ent_lines_bk2.update_entitlement_line_b
      (
       p_cagr_entitlement_line_id       =>  p_cagr_entitlement_line_id
      ,p_mandatory                      =>  p_mandatory
      ,p_value                          =>  p_value
      ,p_range_from                     =>  p_range_from
      ,p_range_to                       =>  p_range_to
      ,p_grade_spine_id                 =>  p_grade_spine_id
      ,p_parent_spine_id                =>  p_parent_spine_id
      ,p_cagr_entitlement_id            =>  p_cagr_entitlement_id
      ,p_status                         =>  p_status
      ,p_oipl_id                        =>  p_oipl_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_step_id                        =>  p_step_id
      ,p_from_step_id                   =>  p_from_step_id
      ,p_to_step_id                     =>  p_to_step_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => l_effective_date
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_entitlement_line'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_entitlement_line
    --
  END;
  --
  /*
  BEGIN
    --
	hr_utility.set_location(l_proc, 60);
	--
    OPEN get_prtn_elig_prfl_id;
	FETCH get_prtn_elig_prfl_id INTO l_prtn_elig_prfl_id,l_prtn_ovn;
	--
	hr_utility.set_location(l_proc||'/'||l_prtn_elig_prfl_id, 65);
	--
	IF get_prtn_elig_prfl_id%NOTFOUND THEN
	  --
	  CLOSE get_prtn_elig_prfl_id;
	  --
	  hr_utility.set_message(800,'HR_289380_CAGR_OPT_ELIG_ERROR');
      hr_utility.raise_error;
	  --
	ELSE
	  --
	  CLOSE get_prtn_elig_prfl_id;
	  --
	END IF;
	--
	ben_prtn_elig_prfl_api.update_prtn_elig_prfl
	    (p_validate               => p_validate
	    ,p_PRTN_ELIG_PRFL_ID      => l_prtn_elig_prfl_id
	    ,p_EFFECTIVE_START_DATE   => l_prtn_eff_st_date
	    ,p_EFFECTIVE_END_DATE     => l_prtn_eff_end_date
	    --,p_BUSINESS_GROUP_ID      => l_business_group_id
	    --,p_MNDTRY_FLAG            => 'Y'
	    --,p_PRTN_ELIG_ID           => to_number(name_in('CEP.PRTN_ELIG_ID'))
	    ,p_ELIGY_PRFL_ID          => p_eligy_prfl_id
        --,p_oipl_id                => l_oipl_id
        ,p_object_version_number  => l_prtn_ovn
	    ,p_effective_date         => l_effective_date
   	    ,p_datetrack_mode         => p_datetrack_mode);
    --
    hr_utility.set_location(l_proc||'/'||l_prtn_elig_prfl_id, 70);
    --
  END;
  */
  --
  per_pcl_upd.upd
    (
     p_cagr_entitlement_line_id      => p_cagr_entitlement_line_id
    ,p_mandatory                     => p_mandatory
    ,p_value                         => p_value
    ,p_range_from                    => p_range_from
    ,p_range_to                      => p_range_to
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_END_date            => l_effective_end_date
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_parent_spine_id               => p_parent_spine_id
    ,p_cagr_entitlement_id           => p_cagr_entitlement_id
    ,p_status                        => p_status
    ,p_oipl_id                       => p_oipl_id
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_step_id                       => p_step_id
    ,p_from_step_id                  => p_from_step_id
    ,p_to_step_id                    => p_to_step_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => TRUNC(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of update_entitlement_line
    --
    hr_cagr_ent_lines_bk2.update_entitlement_line_a
      (
       p_cagr_entitlement_line_id       =>  p_cagr_entitlement_line_id
      ,p_mandatory                      =>  p_mandatory
      ,p_value                          =>  p_value
      ,p_range_from                     =>  p_range_from
      ,p_range_to                       =>  p_range_to
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_END_date             =>  l_effective_END_date
      ,p_grade_spine_id                 =>  p_grade_spine_id
      ,p_parent_spine_id                =>  p_parent_spine_id
      ,p_cagr_entitlement_id            =>  p_cagr_entitlement_id
      ,p_status                         =>  p_status
      ,p_oipl_id                        =>  p_oipl_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_step_id                        =>  p_step_id
      ,p_from_step_id                   =>  p_from_step_id
      ,p_to_step_id                     =>  p_to_step_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => TRUNC(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_entitlement_line'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_entitlement_line
    --
  END;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode RAISE the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date := l_effective_start_date;
  p_effective_END_date := l_effective_END_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been RAISEd
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO update_entitlement_line;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_entitlement_line;
    --
    -- set in out parameters and set out parameters
    --
    p_effective_start_date  := null;
    p_effective_END_date    := null;
    p_object_version_number := l_ovn;
    RAISE;
    --
END update_entitlement_line;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_entitlement_line >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_entitlement_line
  (p_validate                       in  boolean  default false
  ,p_cagr_entitlement_line_id       in  NUMBER
  ,p_effective_start_date           out nocopy DATE
  ,p_effective_END_date             out nocopy DATE
  ,p_object_version_number          in out nocopy NUMBER
  ,p_effective_date                 in  DATE
  ,p_datetrack_mode                 in  VARCHAR2
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR csr_oipl_details IS
    SELECT bof.oipl_id,
	       bof.object_version_number,
		   bpe.prtn_elig_id,
		   bpe.object_version_number,
		   bep.prtn_elig_prfl_id,
		   bep.object_version_number
 	  FROM ben_prtn_elig_prfl_f bep,
	       ben_prtn_elig_f bpe,
	       ben_oipl_f bof,
	       per_cagr_entitlement_lines_f pcl
	 WHERE bep.prtn_elig_id             = bpe.prtn_elig_id
	   AND bpe.oipl_id                  = bof.oipl_id
	   AND bof.oipl_id                  = pcl.oipl_id
	   AND pcl.cagr_entitlement_line_id = p_cagr_entitlement_line_id;
  --


  l_proc                  VARCHAR2(72) := g_package||'update_entitlement_line';
  l_object_version_number per_cagr_entitlement_lines_f.object_version_number%TYPE;
  l_ovn per_cagr_entitlement_lines_f.object_version_number%TYPE := p_object_version_number;
  l_effective_start_date  per_cagr_entitlement_lines_f.effective_start_date%TYPE;
  l_effective_END_date    per_cagr_entitlement_lines_f.effective_END_date%TYPE;
  l_end_date              DATE;
  l_start_date            DATE;
  l_oipl_ovn              NUMBER;
  l_oipl_id               NUMBER;
  l_prtn_elig_id          NUMBER;
  l_prtn_elig_ovn         NUMBER;
  l_prtn_elig_prfl_id     NUMBER;
  l_prtn_elig_prfl_ovn    NUMBER;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT delete_entitlement_line;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of delete_entitlement_line
    --
    hr_cagr_ent_lines_bk3.delete_entitlement_line_b
      (p_cagr_entitlement_line_id  => p_cagr_entitlement_line_id
      ,p_object_version_number     => p_object_version_number
      ,p_effective_date            => TRUNC(p_effective_date)
      ,p_datetrack_mode            => p_datetrack_mode);
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_entitlement_line'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_entitlement_line
    --
  END;
  --
  -- If we are removing the entire record then also
  -- delete the records created in the benefits table
  -- for options in plans.
  --
  IF p_datetrack_mode = 'ZAP' THEN
    --
	-- Delete any results, retained rights, logs
	-- that are linked to the entitlement line
	--
	delete_from_engine_tables
      (p_cagr_entitlement_line_id => p_cagr_entitlement_line_id
      ,p_effective_date           => p_effective_date);
    --
	-- Delete option in plans created
	-- for the entitlement line
	--
	hr_utility.set_location(l_proc, 30);
	--
	OPEN  csr_oipl_details;
	FETCH csr_oipl_details INTO l_oipl_id
	                           ,l_oipl_ovn
							   ,l_prtn_elig_id
							   ,l_prtn_elig_ovn
							   ,l_prtn_elig_prfl_id
							   ,l_prtn_elig_prfl_ovn;
	--
	IF csr_oipl_details%FOUND THEN
	  --
	  CLOSE csr_oipl_details;
	  --
	  hr_utility.set_location(l_proc||'/'||
	                          l_prtn_elig_prfl_id||'/'||
							  l_prtn_elig_prfl_ovn, 40);
      --
	  ben_prtn_elig_prfl_api.delete_prtn_elig_prfl
        (p_validate                       => p_validate
        ,p_prtn_elig_prfl_id              => l_prtn_elig_prfl_id
        ,p_effective_start_date           => l_start_date
        ,p_effective_end_date             => l_end_date
        ,p_object_version_number          => l_prtn_elig_prfl_ovn
        ,p_effective_date                 => p_effective_Date
        ,p_datetrack_mode                 => p_datetrack_mode);
      --
	  hr_utility.set_location(l_proc||'/'||
	                          l_prtn_elig_id||'/'||
							  l_prtn_elig_ovn, 50);
      --
	  ben_participation_elig_api.delete_participation_elig
        (p_validate                      => p_validate
        ,p_prtn_elig_id                  => l_prtn_elig_id
        ,p_effective_start_date          => l_start_date
        ,p_effective_end_date            => l_end_date
        ,p_object_version_number         => l_prtn_elig_ovn
        ,p_effective_date                => p_effective_date
        ,p_datetrack_mode                => p_datetrack_mode);
      --
	  hr_utility.set_location(l_proc||'/'||
	                          l_oipl_id||'/'||
							  l_oipl_ovn, 60);
	  --
      ben_option_in_plan_api.delete_option_in_plan
        (p_validate              => p_validate
        ,p_oipl_id               => l_oipl_id
        ,p_effective_start_date  => l_start_date
        ,p_effective_end_date    => l_end_date
        ,p_object_version_number => l_oipl_ovn
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => p_datetrack_mode);
	  --
	ELSE
	  --
	  CLOSE csr_oipl_details;
	  --
	END IF;
	--
  END IF;
  --
  per_pcl_del.del
    (p_cagr_entitlement_line_id      => p_cagr_entitlement_line_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_END_date            => l_effective_END_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of delete_entitlement_line
    --
    hr_cagr_ent_lines_bk3.delete_entitlement_line_a
      (
       p_cagr_entitlement_line_id       =>  p_cagr_entitlement_line_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_END_date             =>  l_effective_END_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => TRUNC(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_entitlement_line'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_entitlement_line
    --
  END;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode RAISE the Validate_Enabled EXCEPTION
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been RAISEd
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO delete_entitlement_line;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_END_date := null;
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_entitlement_line;
      --
     -- set in out parameters and set out parameters
     --
     p_effective_start_date  := null;
     p_effective_END_date    := null;
     p_object_version_number := l_ovn;
    RAISE;
    --
END delete_entitlement_line;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE lck
  (
   p_cagr_entitlement_line_id                   in     NUMBER
  ,p_object_version_number          in     NUMBER
  ,p_effective_date                 in     DATE
  ,p_datetrack_mode                 in     VARCHAR2
  ,p_validation_start_date          out nocopy    DATE
  ,p_validation_END_date            out nocopy    DATE
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc VARCHAR2(72) := g_package||'lck';
  l_validation_start_date DATE;
  l_validation_END_date DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  per_pcl_shd.lck
    (
      p_cagr_entitlement_line_id   => p_cagr_entitlement_line_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_END_date        => l_validation_END_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
END lck;
--
END hr_cagr_ent_lines_api;

/
