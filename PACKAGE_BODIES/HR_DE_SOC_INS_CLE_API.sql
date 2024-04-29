--------------------------------------------------------
--  DDL for Package Body HR_DE_SOC_INS_CLE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_SOC_INS_CLE_API" AS
/* $Header: hrcleapi.pkb 115.3 2002/12/16 08:30:18 hjonnala noship $ */
--
-- Package Variables
--
g_package  VARCHAR2(33) := '  hr_soc_ins_contr_lvls_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_soc_ins_contributions >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_soc_ins_contributions
  (p_validate                       IN      boolean    default false
   , p_organization_id              IN      number     default null
   , p_normal_percentage            IN      number     default null
   , p_normal_amount                IN      number     default null
   , p_increased_percentage         IN      number     default null
   , p_increased_amount             IN      number     default null
   , p_reduced_percentage           IN      number     default null
   , p_reduced_amount               IN      number     default null
   , p_effective_start_date         IN OUT NOCOPY  date
   , p_effective_end_date           IN OUT NOCOPY  date
   , p_attribute_category           IN      varchar2   default null
   , p_attribute1 		    IN      varchar2   default null
   , p_attribute2		    IN      varchar2   default null
   , p_attribute3 		    IN      varchar2   default null
   , p_attribute4		    IN      varchar2   default null
   , p_attribute5		    IN      varchar2   default null
   , p_attribute6 		    IN      varchar2   default null
   , p_attribute7 		    IN      varchar2   default null
   , p_attribute8 		    IN      varchar2   default null
   , p_attribute9 		    IN      varchar2   default null
   , p_attribute10 		    IN      varchar2   default null
   , p_attribute11 		    IN      varchar2   default null
   , p_attribute12 		    IN      varchar2   default null
   , p_attribute13 		    IN      varchar2   default null
   , p_attribute14 		    IN      varchar2   default null
   , p_attribute15 		    IN      varchar2   default null
   , p_attribute16 		    IN      varchar2   default null
   , p_attribute17 		    IN      varchar2   default null
   , p_attribute18 		    IN      varchar2   default null
   , p_attribute19 		    IN      varchar2   default null
   , p_attribute20 		    IN      varchar2   default null
   , p_attribute21 		    IN      varchar2   default null
   , p_attribute22 		    IN      varchar2   default null
   , p_attribute23 		    IN      varchar2   default null
   , p_attribute24 		    IN      varchar2   default null
   , p_attribute25 		    IN      varchar2   default null
   , p_attribute26 		    IN      varchar2   default null
   , p_attribute27 		    IN      varchar2   default null
   , p_attribute28 		    IN      varchar2   default null
   , p_attribute29 		    IN      varchar2   default null
   , p_attribute30 		    IN      varchar2   default null
   , p_effective_date               IN      date
   , p_object_version_number            OUT NOCOPY     number
   , p_soc_ins_contr_lvls_id            OUT NOCOPY     number
   , p_flat_tax_limit_per_month	    IN      number     default null
   , p_flat_tax_limit_per_year	    IN      number     default null
   , p_min_increased_contribution   IN      number     default null
   , p_max_increased_contribution   IN      number     default null
   , p_month1			    IN      varchar2   default null
   , p_month1_min_contribution      IN      number     default null
   , p_month1_max_contribution  IN      number     default null
   , p_month2			    IN      varchar2   default null
   , p_month2_min_contribution  IN      number     default null
   , p_month2_max_contribution  IN      number     default null
   , p_employee_contribution	    IN      number     default null
   , p_contribution_level_type  		    IN      varchar2   default null
  ) IS
  --
  -- Declare cursors and local variables
  --
  CURSOR csr_bg_information IS
    SELECT business_group_id
    FROM   hr_organization_units hou
    WHERE  hou.organization_id = p_organization_id;
  --
  l_soc_ins_contr_lvls_id    hr_de_soc_ins_contr_lvls_f.soc_ins_contr_lvls_id%TYPE;
  l_effective_start_date     hr_de_soc_ins_contr_lvls_f.effective_start_date%TYPE;
  l_effective_end_date       hr_de_soc_ins_contr_lvls_f.effective_end_date%TYPE;
  l_effective_date           DATE;
  l_proc                     VARCHAR2(72) := g_package||'create_soc_ins_contributions';
  l_object_version_number    hr_de_soc_ins_contr_lvls_f.object_version_number%TYPE;
  l_business_group_id        NUMBER;

  l_temp_effective_start_date  date;
  l_temp_effective_end_date    date;

  --
  -- Declare variables for Option API Call
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT create_soc_ins_contributions;
  --
  -- Truncate date paramters
  --
  l_temp_effective_start_date  := p_effective_start_date;
  l_temp_effective_end_date    := p_effective_end_date;

  l_effective_date := TRUNC(p_effective_date);
  --
  OPEN csr_bg_information;
  FETCH csr_bg_information INTO l_business_group_id;
  CLOSE csr_bg_information;
  --
  BEGIN
    --
	hr_utility.set_location(l_proc, 20);
    --
    --
    -- Start of API User Hook for the before hook of create_soc_ins_contributions
    --
	hr_utility.set_location(l_proc, 80);
	--
    hr_de_soc_ins_cle_bk1.create_soc_ins_contributions_b
      (
          p_organization_id         =>		p_organization_id
         ,p_normal_percentage       =>		p_normal_percentage
   	 ,p_normal_amount           =>		p_normal_amount
         ,p_increased_percentage    =>		p_increased_percentage
         ,p_increased_amount        =>		p_increased_amount
         ,p_reduced_percentage      =>		p_reduced_percentage
         ,p_reduced_amount          =>		p_reduced_amount
         ,p_attribute_category      =>		p_attribute_category
   	 ,p_attribute1 		    =>		p_attribute1
	 ,p_attribute2		    =>		p_attribute2
   	 ,p_attribute3 		    =>		p_attribute3
	 ,p_attribute4		    =>		p_attribute4
	 ,p_attribute5		    =>		p_attribute5
	 ,p_attribute6 		    =>		p_attribute6
	 ,p_attribute7 		    =>		p_attribute7
	 ,p_attribute8 		    =>		p_attribute8
	 ,p_attribute9 		    =>		p_attribute9
	 ,p_attribute10 	    =>		p_attribute10
	 ,p_attribute11 	    =>		p_attribute11
	 ,p_attribute12 	    =>		p_attribute12
	 ,p_attribute13 	    =>		p_attribute13
	 ,p_attribute14 	    =>		p_attribute14
	 ,p_attribute15 	    =>		p_attribute15
	 ,p_attribute16 	    =>		p_attribute16
	 ,p_attribute17 	    =>		p_attribute17
	 ,p_attribute18 	    =>		p_attribute18
	 ,p_attribute19             =>		p_attribute19
	 ,p_attribute20             =>		p_attribute20
	 ,p_attribute21 	    =>		p_attribute21
	 ,p_attribute22 	    =>		p_attribute22
	 ,p_attribute23 	    =>		p_attribute23
	 ,p_attribute24 	    =>		p_attribute24
	 ,p_attribute25 	    =>		p_attribute25
	 ,p_attribute26 	    =>		p_attribute26
	 ,p_attribute27 	    =>		p_attribute27
	 ,p_attribute28 	    =>		p_attribute28
	 ,p_attribute29 	    =>		p_attribute29
	 ,p_attribute30 	    =>		p_attribute30
	 ,p_effective_date          =>		p_effective_date
         ,p_flat_tax_limit_per_month	=> p_flat_tax_limit_per_month
         ,p_flat_tax_limit_per_year	=> p_flat_tax_limit_per_year
         ,p_min_increased_contribution  => p_min_increased_contribution
         ,p_max_increased_contribution  => p_max_increased_contribution
         ,p_month1			=> p_month1
         ,p_month1_min_contribution     => p_month1_min_contribution
         ,p_month1_max_contribution     => p_month1_max_contribution
         ,p_month2		        => p_month2
         ,p_month2_min_contribution     => p_month2_min_contribution
         ,p_month2_max_contribution     => p_month2_max_contribution
         ,p_employee_contribution       => p_employee_contribution
         ,p_contribution_level_type               => p_contribution_level_type
      );
	--
	 hr_utility.set_location(l_proc, 90);
	--
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_soc_ins_contributions'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_soc_ins_contributions
    --
  END;
  --
  hr_utility.set_location(l_proc, 100);
  --
  hr_cle_ins.ins
    (p_effective_date                => TRUNC(p_effective_date)
    ,p_organization_id               => p_organization_id
    ,p_normal_percentage             => p_normal_percentage
    ,p_increased_percentage          => p_increased_percentage
    ,p_reduced_percentage            => p_reduced_percentage
    ,p_normal_amount                 => p_normal_amount
    ,p_increased_amount              => p_increased_amount
    ,p_reduced_amount                => p_reduced_amount
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
    ,p_attribute10                   =>	p_attribute10
    ,p_attribute11                   =>	p_attribute11
    ,p_attribute12                   =>	p_attribute12
    ,p_attribute13                   =>	p_attribute13
    ,p_attribute14                   =>	p_attribute14
    ,p_attribute15                   =>	p_attribute15
    ,p_attribute16                   =>	p_attribute16
    ,p_attribute17                   =>	p_attribute17
    ,p_attribute18                   =>	p_attribute18
    ,p_attribute19                   =>	p_attribute19
    ,p_attribute20                   =>	p_attribute20
    ,p_attribute21                   =>	p_attribute21
    ,p_attribute22                   =>	p_attribute22
    ,p_attribute23                   =>	p_attribute23
    ,p_attribute24                   =>	p_attribute24
    ,p_attribute25                   =>	p_attribute25
    ,p_attribute26                   =>	p_attribute26
    ,p_attribute27                   =>	p_attribute27
    ,p_attribute28                   =>	p_attribute28
    ,p_attribute29                   =>	p_attribute29
    ,p_attribute30                   =>	p_attribute30
    ,p_soc_ins_contr_lvls_id         =>	l_soc_ins_contr_lvls_id
    ,p_object_version_number         =>	l_object_version_number
    ,p_effective_start_date          =>	l_effective_start_date
    ,p_effective_end_date            =>	l_effective_end_date
    ,p_flat_tax_limit_per_month	     => p_flat_tax_limit_per_month
    ,p_flat_tax_limit_per_year	     => p_flat_tax_limit_per_year
    ,p_min_increased_contribution    => p_min_increased_contribution
    ,p_max_increased_contribution    => p_max_increased_contribution
    ,p_month1			     => p_month1
    ,p_month1_min_contribution       => p_month1_min_contribution
    ,p_month1_max_contribution       => p_month1_max_contribution
    ,p_month2			     => p_month2
    ,p_month2_min_contribution	     => p_month2_min_contribution
    ,p_month2_max_contribution	     => p_month2_max_contribution
    ,p_employee_contribution	     => p_employee_contribution
    ,p_contribution_level_type                 => p_contribution_level_type
    );



  --
  hr_utility.set_location(l_proc, 110);
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of create_soc_ins_contributions
    --
	hr_utility.set_location(l_proc, 120);
	--
    hr_de_soc_ins_cle_bk1.create_soc_ins_contributions_a
      (
        p_soc_ins_contr_lvls_id            => 	l_soc_ins_contr_lvls_id
      , p_organization_id                  => 	p_organization_id
      , p_normal_percentage                => 	p_normal_percentage
      , p_normal_amount                    => 	p_normal_amount
      , p_increased_percentage             => 	p_increased_percentage
      , p_increased_amount                 => 	p_increased_amount
      , p_reduced_percentage               => 	p_reduced_percentage
      , p_reduced_amount                   => 	p_reduced_amount
      , p_attribute_category               => 	p_attribute_category
      , p_attribute1 		     	   => 	p_attribute1
      , p_attribute2		     	   => 	p_attribute2
      , p_attribute3 		     	   => 	p_attribute3
      , p_attribute4		     	   => 	p_attribute4
      , p_attribute5		     	   => 	p_attribute5
      , p_attribute6 		     	   => 	p_attribute6
      , p_attribute7 		     	   => 	p_attribute7
      , p_attribute8 		      	   => 	p_attribute8
      , p_attribute9 		      	   => 	p_attribute9
      , p_attribute10 			   => 	p_attribute10
      , p_attribute11 			   => 	p_attribute11
      , p_attribute12 			   => 	p_attribute12
      , p_attribute13 			   => 	p_attribute13
      , p_attribute14 			   => 	p_attribute14
      , p_attribute15 			   => 	p_attribute15
      , p_attribute16 			   => 	p_attribute16
      , p_attribute17 			   => 	p_attribute17
      , p_attribute18 			   => 	p_attribute18
      , p_attribute19 			   => 	p_attribute19
      , p_attribute20 			   => 	p_attribute20
      , p_attribute21 			   => 	p_attribute21
      , p_attribute22 			   => 	p_attribute22
      , p_attribute23 			   => 	p_attribute23
      , p_attribute24 			   => 	p_attribute24
      , p_attribute25 			   => 	p_attribute25
      , p_attribute26 			   => 	p_attribute26
      , p_attribute27 			   =>	p_attribute27
      , p_attribute28 			   =>	p_attribute28
      , p_attribute29 			   =>	p_attribute29
      , p_attribute30 			   =>	p_attribute30
      , p_effective_start_date      	   =>   l_effective_start_date
      , p_effective_end_date        	   =>   l_effective_END_date
      , p_object_version_number     	   =>   l_object_version_number
      , p_effective_date            	   =>   l_effective_date
      , p_flat_tax_limit_per_month	   =>   p_flat_tax_limit_per_month
      , p_flat_tax_limit_per_year	   =>   p_flat_tax_limit_per_year
      , p_min_increased_contribution       =>   p_min_increased_contribution
      , p_max_increased_contribution       =>   p_max_increased_contribution
      , p_month1			   =>   p_month1
      , p_month1_min_contribution          =>   p_month1_min_contribution
      , p_month1_max_contribution          =>   p_month1_max_contribution
      , p_month2			   =>   p_month2
      , p_month2_min_contribution	   =>   p_month2_min_contribution
      , p_month2_max_contribution	   =>   p_month2_max_contribution
      , p_employee_contribution	           =>   p_employee_contribution
      , p_contribution_level_type                    =>   p_contribution_level_type
	);


	--
	hr_utility.set_location(l_proc, 130);
	--

  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_soc_ins_contributions'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_soc_ins_contributions
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
  p_soc_ins_contr_lvls_id    := l_soc_ins_contr_lvls_id;
  p_effective_start_date     := l_effective_start_date;
  p_effective_END_date       := l_effective_END_date;
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
    ROLLBACK TO create_soc_ins_contributions;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
    p_soc_ins_contr_lvls_id := null;
    p_effective_start_date  := l_temp_effective_start_date;
    p_effective_end_date    := l_temp_effective_end_date;
    p_object_version_number := null;
	--
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_soc_ins_contributions;
    -- Reset IN OUT and set OUT parameters.
   p_effective_start_date   := l_effective_start_date;
   p_effective_END_date     := l_effective_END_date;
   p_object_version_number  := null;
   p_soc_ins_contr_lvls_id  := null;

    RAISE;
    --
END create_soc_ins_contributions;

-- ----------------------------------------------------------------------------
-- |---------------------< update_soc_ins_contributions >-------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_soc_ins_contributions
  (

    p_validate                    IN      boolean      default  false
   ,p_organization_id             IN      number       default  hr_api.g_number
   ,p_normal_percentage           IN      number       default  hr_api.g_number
   ,p_normal_amount               IN      number       default  hr_api.g_number
   ,p_increased_percentage        IN      number       default  hr_api.g_number
   ,p_increased_amount            IN      number       default  hr_api.g_number
   ,p_reduced_percentage          IN      number       default  hr_api.g_number
   ,p_reduced_amount              IN      number       default  hr_api.g_number
   ,p_effective_start_date        IN OUT NOCOPY  date
   ,p_effective_end_date          IN OUT NOCOPY  date
   ,p_attribute_category          IN      varchar2     default hr_api.g_varchar2
   ,p_attribute1 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute2		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute3 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute4		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute5		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute6 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute7 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute8 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute9 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute10 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute11 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute12 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute13 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute14 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute15 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute16 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute17 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute18 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute19 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute20 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute21 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute22 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute23 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute24 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute25 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute26 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute27 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute28 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute29 		  IN      varchar2     default hr_api.g_varchar2
   ,p_attribute30 		  IN      varchar2     default hr_api.g_varchar2
   ,p_effective_date              IN      date
   ,p_object_version_number       IN OUT NOCOPY     number
   ,p_soc_ins_contr_lvls_id       IN     number
   ,p_datetrack_mode              in      varchar2
   ,p_flat_tax_limit_per_month	   IN     number    default hr_api.g_number
   ,p_flat_tax_limit_per_year	   IN     number    default hr_api.g_number
   ,p_min_increased_contribution   IN     number    default hr_api.g_number
   ,p_max_increased_contribution   IN     number    default hr_api.g_number
   ,p_month1			   IN     varchar2  default hr_api.g_varchar2
   ,p_month1_min_contribution      IN     number    default hr_api.g_number
   ,p_month1_max_contribution      IN     number    default hr_api.g_number
   ,p_month2			   IN     varchar2  default hr_api.g_varchar2
   ,p_month2_min_contribution      IN     number    default hr_api.g_number
   ,p_month2_max_contribution      IN     number    default hr_api.g_number
   ,p_employee_contribution	   IN     number    default hr_api.g_number
   ,p_contribution_level_type  		   IN     varchar2  default hr_api.g_varchar2
     ) is


  --
  -- Declare cursors and local variables

  --
  l_proc                  VARCHAR2(72) := g_package||'update_soc_ins_contributions';
  l_object_version_number hr_de_soc_ins_contr_lvls_f.object_version_number%TYPE;
  l_effective_start_date  hr_de_soc_ins_contr_lvls_f.effective_start_date%TYPE;
  l_effective_end_date    hr_de_soc_ins_contr_lvls_f.effective_end_date%TYPE;
  l_effective_date        DATE;

  l_temp_effective_start_date  date;
  l_temp_effective_end_date    date;
  l_temp_ovn      number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT update_soc_ins_contributions;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --

  l_temp_effective_start_date     :=  p_effective_start_date;
  l_temp_effective_end_date  	  :=  p_effective_end_date;
  l_temp_ovn           	          :=  p_object_version_number;
  l_object_version_number         :=  p_object_version_number;
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of update_soc_ins_contributions
    --
    hr_de_soc_ins_cle_bk2.update_soc_ins_contributions_b
      (
        p_soc_ins_contr_lvls_id        	=> p_soc_ins_contr_lvls_id
      , p_organization_id             	=> p_organization_id
      , p_normal_percentage           	=> p_normal_percentage
      , p_normal_amount               	=> p_normal_amount
      , p_increased_percentage        	=> p_increased_percentage
      , p_increased_amount            	=> p_increased_amount
      , p_reduced_percentage          	=> p_reduced_percentage
      , p_reduced_amount              	=> p_reduced_amount
      , p_attribute_category          	=> p_attribute_category
      , p_attribute1 		   	=> p_attribute1
      , p_attribute2		   	=> p_attribute2
      , p_attribute3 		   	=> p_attribute3
      , p_attribute4		   	=> p_attribute4
      , p_attribute5		   	=> p_attribute5
      , p_attribute6 		  	=> p_attribute6
      , p_attribute7 		  	=> p_attribute7
      , p_attribute8 		 	=> p_attribute8
      , p_attribute9 			=> p_attribute9
      , p_attribute10 			=> p_attribute10
      , p_attribute11 			=> p_attribute11
      , p_attribute12 			=> p_attribute12
      , p_attribute13 			=> p_attribute13
      , p_attribute14 			=> p_attribute14
      , p_attribute15 			=> p_attribute15
      , p_attribute16 			=> p_attribute16
      , p_attribute17 			=> p_attribute17
      , p_attribute18 			=> p_attribute18
      , p_attribute19 			=> p_attribute19
      , p_attribute20 			=> p_attribute20
      , p_attribute21 			=> p_attribute21
      , p_attribute22 			=> p_attribute22
      , p_attribute23 			=> p_attribute23
      , p_attribute24 			=> p_attribute24
      , p_attribute25 			=> p_attribute25
      , p_attribute26 			=> p_attribute26
      , p_attribute27 			=> p_attribute27
      , p_attribute28 			=> p_attribute28
      , p_attribute29 			=> p_attribute29
      , p_attribute30 			=> p_attribute30
      , p_object_version_number      	=> p_object_version_number
      , p_effective_date             	=> l_effective_date
      , p_datetrack_mode             	=> p_datetrack_mode
      , p_flat_tax_limit_per_month	=> p_flat_tax_limit_per_month
      , p_flat_tax_limit_per_year	=> p_flat_tax_limit_per_year
      , p_min_increased_contribution    => p_min_increased_contribution
      , p_max_increased_contribution    => p_max_increased_contribution
      , p_month1			=> p_month1
      , p_month1_min_contribution       => p_month1_min_contribution
      , p_month1_max_contribution       => p_month1_max_contribution
      , p_month2			=> p_month2
      , p_month2_min_contribution	=> p_month2_min_contribution
      , p_month2_max_contribution	=> p_month2_max_contribution
      , p_employee_contribution	        => p_employee_contribution
      , p_contribution_level_type                 => p_contribution_level_type
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_soc_ins_contributions'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_soc_ins_contributions
    --
  END;
  --
  hr_cle_upd.upd
    (p_effective_date                 => TRUNC(p_effective_date)
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_soc_ins_contr_lvls_id          => p_soc_ins_contr_lvls_id
    ,p_object_version_number          => l_object_version_number
    ,p_organization_id                => p_organization_id
    ,p_normal_percentage              => p_normal_percentage
    ,p_increased_percentage           => p_increased_percentage
    ,p_reduced_percentage             => p_reduced_percentage
    ,p_normal_amount                  => p_normal_amount
    ,p_increased_amount               => p_increased_amount
    ,p_reduced_amount                 => p_reduced_amount
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
    ,p_attribute21                    => p_attribute21
    ,p_attribute22                    => p_attribute22
    ,p_attribute23                    => p_attribute23
    ,p_attribute24                    => p_attribute24
    ,p_attribute25                    => p_attribute25
    ,p_attribute26                    => p_attribute26
    ,p_attribute27                    => p_attribute27
    ,p_attribute28                    => p_attribute28
    ,p_attribute29                    => p_attribute29
    ,p_attribute30                    => p_attribute30
    ,p_flat_tax_limit_per_month	      => p_flat_tax_limit_per_month
    ,p_flat_tax_limit_per_year	      => p_flat_tax_limit_per_year
    ,p_min_increased_contribution     => p_min_increased_contribution
    ,p_max_increased_contribution     => p_max_increased_contribution
    ,p_month1			      => p_month1
    ,p_month1_min_contribution        => p_month1_min_contribution
    ,p_month1_max_contribution        => p_month1_max_contribution
    ,p_month2			      => p_month2
    ,p_month2_min_contribution	      => p_month2_min_contribution
    ,p_month2_max_contribution	      => p_month2_max_contribution
    ,p_employee_contribution	      => p_employee_contribution
    ,p_contribution_level_type                  => p_contribution_level_type
    ,p_effective_start_date           => l_effective_start_date
    ,p_effective_end_date             => l_effective_end_date
     );
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of update_soc_ins_contributions
    --
    hr_de_soc_ins_cle_bk2.update_soc_ins_contributions_a
      (
         p_soc_ins_contr_lvls_id       =>   p_soc_ins_contr_lvls_id
       , p_organization_id             =>   p_organization_id
       , p_normal_percentage           =>   p_normal_percentage
       , p_normal_amount               =>   p_normal_amount
       , p_increased_percentage        =>   p_increased_percentage
       , p_increased_amount            =>   p_increased_amount
       , p_reduced_percentage          =>   p_reduced_percentage
       , p_reduced_amount              =>   p_reduced_amount
       , p_attribute_category          =>   p_attribute_category
       , p_attribute1 		       =>   p_attribute1
       , p_attribute2		       =>   p_attribute2
       , p_attribute3 		       =>   p_attribute3
       , p_attribute4		       =>   p_attribute4
       , p_attribute5		       =>   p_attribute5
       , p_attribute6 		       =>   p_attribute6
       , p_attribute7 		       =>   p_attribute7
       , p_attribute8 		       =>   p_attribute8
       , p_attribute9 		       =>   p_attribute9
       , p_attribute10 		       =>   p_attribute10
       , p_attribute11 		       =>   p_attribute11
       , p_attribute12 		       =>   p_attribute12
       , p_attribute13 		       =>   p_attribute13
       , p_attribute14 		       =>   p_attribute14
       , p_attribute15 		       =>   p_attribute15
       , p_attribute16 		       =>   p_attribute16
       , p_attribute17 		       =>   p_attribute17
       , p_attribute18 		       =>   p_attribute18
       , p_attribute19 		       =>   p_attribute19
       , p_attribute20 		       =>   p_attribute20
       , p_attribute21 		       =>   p_attribute21
       , p_attribute22 		       =>   p_attribute22
       , p_attribute23 		       =>   p_attribute23
       , p_attribute24 		       =>   p_attribute24
       , p_attribute25 		       =>   p_attribute25
       , p_attribute26 		       =>   p_attribute26
       , p_attribute27 		       =>   p_attribute27
       , p_attribute28 		       =>   p_attribute28
       , p_attribute29 		       =>   p_attribute29
       , p_attribute30 		       =>   p_attribute30
       , p_effective_start_date        =>   l_effective_start_date
       , p_effective_end_date          =>   l_effective_END_date
       , p_object_version_number       =>   l_object_version_number
       , p_effective_date              =>   TRUNC(p_effective_date)
       , p_datetrack_mode              =>   p_datetrack_mode
       , p_flat_tax_limit_per_month    =>   p_flat_tax_limit_per_month
       , p_flat_tax_limit_per_year     =>   p_flat_tax_limit_per_year
       , p_min_increased_contribution  =>   p_min_increased_contribution
       , p_max_increased_contribution  =>   p_max_increased_contribution
       , p_month1		       =>   p_month1
       , p_month1_min_contribution     =>   p_month1_min_contribution
       , p_month1_max_contribution     =>   p_month1_max_contribution
       , p_month2		       =>   p_month2
       , p_month2_min_contribution     =>   p_month2_min_contribution
       , p_month2_max_contribution     =>   p_month2_max_contribution
       , p_employee_contribution       =>   p_employee_contribution
       , p_contribution_level_type               =>   p_contribution_level_type
       );

  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_soc_ins_contributions'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_soc_ins_contributions
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
    ROLLBACK TO update_soc_ins_contributions;
    --
    -- Reset IN OUT parameters.
        p_object_version_number := l_temp_ovn;
        p_effective_start_date := l_temp_effective_start_date;
        p_effective_END_date := l_temp_effective_END_date;
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
    ROLLBACK TO update_soc_ins_contributions;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    p_effective_start_date := l_temp_effective_start_date;
    p_effective_END_date := l_temp_effective_END_date;
    RAISE;
    --
END update_soc_ins_contributions;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_soc_ins_contributions >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_soc_ins_contributions
  (p_validate                       in  boolean  default false
  ,p_soc_ins_contr_lvls_id          in  NUMBER
  ,p_effective_start_date           out nocopy DATE
  ,p_effective_END_date             out nocopy DATE
  ,p_object_version_number          in out nocopy NUMBER
  ,p_effective_date                 in  DATE
  ,p_datetrack_mode                 in  VARCHAR2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'delete_soc_ins_contributions';
  l_object_version_number hr_de_soc_ins_contr_lvls_f.object_version_number%TYPE;
  l_effective_start_date  hr_de_soc_ins_contr_lvls_f.effective_start_date%TYPE;
  l_effective_END_date    hr_de_soc_ins_contr_lvls_f.effective_END_date%TYPE;

  l_temp_ovn   number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a SAVEPOINT IF operating in validation only mode
  --
  SAVEPOINT delete_soc_ins_contributions;
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_temp_ovn  :=  p_object_version_number;
  -- Process Logic
  --
  hr_utility.trace('deleteapiobject' ||p_object_version_number);
  l_object_version_number := p_object_version_number;
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of delete_soc_ins_contributions
    --
    hr_de_soc_ins_cle_bk3.delete_soc_ins_contributions_b
      (p_soc_ins_contr_lvls_id  => p_soc_ins_contr_lvls_id
      ,p_object_version_number     => p_object_version_number
      ,p_effective_date            => TRUNC(p_effective_date)
      ,p_datetrack_mode            => p_datetrack_mode);
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_soc_ins_contributions'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_soc_ins_contributions
    --
  END;

   hr_utility.trace('deleteapilobject' ||l_object_version_number);
    --
  hr_cle_del.del
    (p_soc_ins_contr_lvls_id         => p_soc_ins_contr_lvls_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_END_date            => l_effective_END_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of delete_soc_ins_contributions
    --
    hr_de_soc_ins_cle_bk3.delete_soc_ins_contributions_a
      (
       p_soc_ins_contr_lvls_id          =>  p_soc_ins_contr_lvls_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_END_date             =>  l_effective_END_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  TRUNC(p_effective_date)
      ,p_datetrack_mode                 =>   p_datetrack_mode
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_soc_ins_contributions'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_soc_ins_contributions
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
  p_object_version_number   := l_object_version_number;
  p_effective_start_date    := l_effective_start_date;
  p_effective_end_date      := l_effective_end_date;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled EXCEPTION has been RAISEd
    -- we must rollback to the SAVEPOINT
    --
    ROLLBACK TO delete_soc_ins_contributions;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- WHEN validation only mode is being used.)
    --
    p_object_version_number := null;
    p_effective_start_date := null;
    p_effective_END_date := null;
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_soc_ins_contributions;
    -- Reset IN OUT and set OUT parameters.
    p_effective_start_date   := null;
    p_effective_END_date     := null;
    p_object_version_number  := l_temp_ovn;
    RAISE;
    --
END delete_soc_ins_contributions;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE lck
  (
   p_soc_ins_contr_lvls_id          in     NUMBER
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
  hr_cle_shd.lck
    (
      p_soc_ins_contr_lvls_id      => p_soc_ins_contr_lvls_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_END_date        => l_validation_END_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --

p_validation_start_date  := l_validation_start_date;
p_validation_end_date  := l_validation_end_date;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
END lck;
--
END hr_de_soc_ins_cle_api;


/
