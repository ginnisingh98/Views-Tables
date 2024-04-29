--------------------------------------------------------
--  DDL for Package Body HR_COLLECTIVE_AGREEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COLLECTIVE_AGREEMENT_API" as
/* $Header: hrcagapi.pkb 120.2.12010000.2 2008/08/06 08:34:55 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_collective_agreement_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_plan_years >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   This procedure will check that there are 10 years of plan years on the
--   system, from the effective date. If there are not then this procedure
--   will create plans years by using the Benefits Plan Years API.
--
-- Prerequisites:
--   This is a private function and can only be called from the api.
--
-- In Parameters:
--
--   effective date
--   business group id
--   start of year date (01-JAN-XX)
--   end of year date (31-DEC-XX)
--   ten year date (Effective Date + 10 Years)
--
-- Post Success:
--   10 years worth of PLan Years exist on system.
--
-- Post Failure:
--   If the process fails a error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
--
PROCEDURE check_plan_years
  (p_effective_date    IN DATE
  ,p_business_group_id IN NUMBER
  ,p_start_of_year     IN DATE
  ,p_end_of_year       IN DATE
  ,p_ten_year_date     IN DATE) IS
  --
  -- Delcare Local Variables
  --
  l_proc              VARCHAR2(72) := g_package||'check_plan_years';
  l_start_of_year     DATE;
  l_end_of_year       DATE;
  l_pln_yr_start_date DATE;
  l_pln_yr_end_date   DATE;
  l_effective_date    DATE;
  l_yr_perd_id       NUMBER;
  l_yr_perd_ovn       NUMBER;
  --
  CURSOR csr_get_plan_years IS
    SELECT start_date,
	       end_date
	  FROM ben_yr_perd
	 WHERE start_date = l_start_of_year
	   AND end_date   = l_end_of_year
	   AND business_group_id  = p_business_group_id;  --Bug fix:3648527
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc, 10);
  --
  l_effective_date := TRUNC(p_effective_Date);
  l_start_of_year  := p_start_of_year;
  l_end_of_year    := p_end_of_year;
  --
  WHILE l_end_of_year <= p_ten_year_date LOOP
    --
   	hr_utility.set_location(l_proc,20);
	   --
	   OPEN  csr_get_plan_years;
	   FETCH csr_get_plan_years INTO l_pln_yr_start_date,l_pln_yr_end_date;
	   --
	   IF csr_get_plan_years%NOTFOUND THEN
	     --
	     CLOSE csr_get_plan_years;
	     --
	     hr_utility.set_location(l_proc,30);
	     --
	     BEN_pgm_or_pl_yr_perd_API.create_pgm_or_pl_yr_perd
        (p_validate              => FALSE
        ,p_yr_perd_id            => l_yr_perd_id
        ,p_perd_typ_cd           => 'CLNDR'
        ,p_end_date              => l_end_of_year
        ,p_start_date            => l_start_of_year
        ,p_business_group_id     => p_business_group_id
        ,p_object_version_number => l_yr_perd_ovn
        ,p_effective_date        => l_effective_Date);
      --
   	ELSE
	     --
   	  CLOSE csr_get_plan_years;
	     --
	   END IF;
	   --
	   -- Add 1 year to the start and end dates
	   --
	   l_start_of_year := ADD_MONTHS(l_start_of_year,12);
	   l_end_of_year   := ADD_MONTHS(l_end_of_year,12);
	   --
  END LOOP;
  --
  hr_utility.set_location('Leaving :'|| l_proc, 999);
  --
END check_plan_years;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< attach_plan_years >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   This procedure will attach plan years to the plan created for the
--   collective agreement.
--
-- Prerequisites:
--   This is a private function and can only be called from the api.
--
-- In Parameters:
--
--   effective date
--   business group id
--   plan id
--
-- Post Success:
--   Plan Years attached to plan.
--
-- Post Failure:
--   If the process fails a error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ----------------------------------------------------------------------------
--
PROCEDURE attach_plan_years
  (p_effective_date    IN DATE
  ,p_business_group_id IN NUMBER
  ,p_pl_id             IN NUMBER) IS
  --
  -- Delcare Local Variables
  --
  l_proc              VARCHAR2(72) := g_package||'attach_plan_years';
  l_start_of_year     DATE;
  l_end_of_year       DATE;
  l_ten_year_date     DATE;
  l_effective_date    DATE;
  l_order_number      NUMBER;
  l_popl_yr_perd_id   NUMBER;
  l_pln_yr_ovn        NUMBER;
  --
  -- Declare Cursors
  --
  CURSOR csr_get_plan_years IS
    SELECT yr_perd_id,
	   TRUNC(start_date) start_date,
	   TRUNC(end_date) end_date
      FROM ben_yr_perd
     WHERE business_group_id  = p_business_group_id  --Bug fix:3648527
       AND end_date            <= l_ten_year_date
     ORDER BY start_date ASC;
  --
BEGIN
 --
	hr_utility.set_location(l_proc, 40);
 --
	l_order_number := 10;
	--
	l_effective_date := TRUNC(p_effective_date);
	--
 l_start_of_year := trunc(l_effective_date,'YEAR');
 l_end_of_year   := LAST_DAY(ADD_MONTHS(trunc(l_effective_date,'YEAR'),11));
 l_ten_year_date := LAST_DAY(ADD_MONTHS(trunc(l_effective_date,'YEAR'),1190));
 --
	-- Check to see if plan years exist for the next 100 years.
	-- If they do not then this procedure will create them.
	--
	check_plan_years(p_effective_date    => l_effective_date
	                ,p_business_group_id => p_business_group_id
				            	,p_start_of_year     => l_start_of_year
					            ,p_end_of_year       => l_end_of_year
					            ,p_ten_year_date     => l_ten_year_date);
	--
 hr_utility.set_location(l_proc||'/'||l_start_of_year,50);
	hr_utility.set_location(l_proc||'/'||l_end_of_year,51);
	hr_utility.set_location(l_proc||'/'||l_ten_year_date,52);
	--
	-- Loop round all the plan years for the next 100 years
	--
	FOR csr_rec IN csr_get_plan_years LOOP
	  --
	  hr_utility.set_location(l_proc||'/'||csr_rec.yr_perd_id, 60);
	  hr_utility.set_location(l_proc||'/'||csr_rec.start_date,61);
	  hr_utility.set_location(l_proc||'/'||csr_rec.end_date,62);
	  --
	  -- If the plan year start and end dates match
	  -- the beginning and end of the year then attach them
	  -- to the plan.
	  --
	  IF csr_rec.start_date = l_start_of_year AND
	     csr_rec.end_date = l_end_of_year THEN
	    --
		   ben_popl_yr_perd_api.create_popl_yr_perd
	      (p_validate                    => FALSE
	      ,p_popl_yr_perd_id             => l_popl_yr_perd_id
	      ,p_yr_perd_id                  => csr_rec.yr_perd_id
       ,p_business_group_id           => p_business_group_id
	      ,p_pl_id                       => p_pl_id
	      ,p_ordr_num                    => l_order_number
  	    ,p_object_version_number       => l_pln_yr_ovn);
	    --
	    l_order_number := l_order_number + 10;
	   	--
	    -- Add 1 year to the start and end dates
	    --
	    l_start_of_year := ADD_MONTHS(l_start_of_year,12);
	    l_end_of_year   := ADD_MONTHS(l_end_of_year,12);
	    --
   END IF;
   --
 END LOOP;
 --
END attach_plan_years;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_collective_agreement >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_collective_agreement
  (p_validate                       in  boolean   default false
  ,p_collective_agreement_id        out nocopy number
  ,p_effective_date                 in  date
  ,p_business_group_id              in  number
  ,p_object_version_number          out nocopy number
  ,p_name                           in  varchar2
  ,p_status                         in  varchar2
  ,p_cag_number                     in  number    default null
  ,p_description                    in  varchar2  default null
  ,p_end_date                       in  date      default null
  ,p_employer_organization_id       in  number    default null
  ,p_employer_signatory             in  varchar2  default null
  ,p_bargaining_organization_id     in  number    default null
  ,p_bargaining_unit_signatory      in  varchar2  default null
  ,p_jurisdiction                   in  varchar2  default null
  ,p_authorizing_body               in  varchar2  default null
  ,p_authorized_date                in  date      default null
  ,p_cag_information_category       in  varchar2  default null
  ,p_cag_information1               in  varchar2  default null
  ,p_cag_information2               in  varchar2  default null
  ,p_cag_information3               in  varchar2  default null
  ,p_cag_information4               in  varchar2  default null
  ,p_cag_information5               in  varchar2  default null
  ,p_cag_information6               in  varchar2  default null
  ,p_cag_information7               in  varchar2  default null
  ,p_cag_information8               in  varchar2  default null
  ,p_cag_information9               in  varchar2  default null
  ,p_cag_information10              in  varchar2  default null
  ,p_cag_information11              in  varchar2  default null
  ,p_cag_information12              in  varchar2  default null
  ,p_cag_information13              in  varchar2  default null
  ,p_cag_information14              in  varchar2  default null
  ,p_cag_information15              in  varchar2  default null
  ,p_cag_information16              in  varchar2  default null
  ,p_cag_information17              in  varchar2  default null
  ,p_cag_information18              in  varchar2  default null
  ,p_cag_information19              in  varchar2  default null
  ,p_cag_information20              in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_collective_agreement_id per_collective_agreements.collective_agreement_id%TYPE;
  l_proc varchar2(72) := g_package||'create_collective_agreement';
  l_object_version_number per_collective_agreements.object_version_number%TYPE;
  --
  l_pl_id                NUMBER;
  l_pl_ovn               NUMBER;
  l_effective_date       DATE;
  l_start_date           DATE;
  l_effective_start_date DATE;
  l_effective_end_date   DATE;
  l_pl_typ_id            NUMBER;
  l_pl_typ_ovn           NUMBER;
  --
  CURSOR csr_get_plan_type IS
    SELECT pl_typ_id
      FROM ben_pl_typ_f
     WHERE name = 'Collective Agreement Plan Type'
	   AND business_group_id = p_business_group_id
       AND l_effective_date BETWEEN effective_start_date
                                AND effective_end_date;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_collective_agreement;
  --
  hr_utility.set_location(l_proc, 20);
  --
  --Truncate Date Parameters
  --
  l_effective_date := TRUNC(p_effective_date);
  l_start_Date     := l_effective_Date;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_collective_agreement
    --
    hr_collective_agreement_bk1.create_collective_agreement_b
      (p_business_group_id              =>  p_business_group_id
      ,p_name                           =>  p_name
	  ,p_status                         =>  p_status
      ,p_cag_number                     =>  p_cag_number
      ,p_description                    =>  p_description
      ,p_start_date                     =>  l_start_date
      ,p_end_date                       =>  p_end_date
      ,p_employer_organization_id       =>  p_employer_organization_id
      ,p_employer_signatory             =>  p_employer_signatory
      ,p_bargaining_organization_id     =>  p_bargaining_organization_id
      ,p_bargaining_unit_signatory      =>  p_bargaining_unit_signatory
      ,p_jurisdiction                   =>  p_jurisdiction
      ,p_authorizing_body               =>  p_authorizing_body
      ,p_authorized_date                =>  p_authorized_date
      ,p_cag_information_category       =>  p_cag_information_category
      ,p_cag_information1               =>  p_cag_information1
      ,p_cag_information2               =>  p_cag_information2
      ,p_cag_information3               =>  p_cag_information3
      ,p_cag_information4               =>  p_cag_information4
      ,p_cag_information5               =>  p_cag_information5
      ,p_cag_information6               =>  p_cag_information6
      ,p_cag_information7               =>  p_cag_information7
      ,p_cag_information8               =>  p_cag_information8
      ,p_cag_information9               =>  p_cag_information9
      ,p_cag_information10              =>  p_cag_information10
      ,p_cag_information11              =>  p_cag_information11
      ,p_cag_information12              =>  p_cag_information12
      ,p_cag_information13              =>  p_cag_information13
      ,p_cag_information14              =>  p_cag_information14
      ,p_cag_information15              =>  p_cag_information15
      ,p_cag_information16              =>  p_cag_information16
      ,p_cag_information17              =>  p_cag_information17
      ,p_cag_information18              =>  p_cag_information18
      ,p_cag_information19              =>  p_cag_information19
      ,p_cag_information20              =>  p_cag_information20
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_collective_agreement'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_collective_agreement
    --
  end;
  --
  -- Create a Plan for the Collective Agreement.
  --
  BEGIN
    --
	hr_utility.set_location(l_proc, 30);
	--
    OPEN  csr_get_plan_type;
	FETCH csr_get_plan_type INTO l_pl_typ_id;
	--
	-- Check to see if the Collective Agreement Plan Type exists
	-- if it does not then call the BEN Api's that will create
	-- a plan type.
	--
	IF csr_get_plan_type%NOTFOUND THEN
	  --
	  CLOSE csr_get_plan_type;
	  --
	  -- Create the plan type uses 01-JAN-1951 as the effective date.
	  -- This has been done so that we can create a plan that starts as early
	  -- as possible. The start_of_time was not used as the BEN lookups all
	  -- start from the 01-JAN-1951 so the create would fail if we used the
	  -- start of time.
	  --
	  ben_plan_type_api.create_plan_type
        (p_validate                       => p_validate
        ,p_pl_typ_id                      => l_pl_typ_id
        ,p_effective_start_date           => l_effective_start_date
        ,p_effective_end_date             => l_effective_end_date
        ,p_name                           => 'Collective Agreement Plan Type'
        ,p_opt_typ_cd                     => 'CAGR'
		,p_business_group_id              => p_business_group_id
		,p_no_mx_enrl_num_dfnd_flag       => 'N'
        ,p_no_mn_enrl_num_dfnd_flag       => 'N'
        ,p_object_version_number          => l_pl_typ_ovn
        ,p_effective_date                 => TO_DATE('01-01-1951','DD-MM-YYYY'));
	  --
	  /*
	  hr_utility.set_message(800,'HR_289379_CAGR_PLAN_TYPE_INV');
      hr_utility.raise_error; */
	--
	-- If a plan type already exists then just close the cursor
	--
	ELSE
	  --
	  CLOSE csr_get_plan_type;
	  --
	  hr_utility.set_location(l_proc, 35);
	  --
	END IF;
   	--
	-- Create a Plan for the Collective Agreement
	--
	ben_plan_api.create_plan
      (p_validate                     => p_validate
      ,p_pl_id                        => l_pl_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_name                         => per_cagr_utility_pkg.plan_name
      ,p_object_version_number        => l_pl_ovn
      ,p_business_group_id            => p_business_group_id
      ,p_effective_date               => l_effective_date
	  ,p_pl_typ_id                    => l_pl_typ_id
	  ,p_pl_cd                        => 'MYNTBPGM' -- May not be in a program,
	  ,p_pl_stat_cd                   => 'A');      -- Active);
	--
    hr_utility.set_location(l_proc||'/'||l_pl_id, 40);
	--
	-- Once the plan has been created we need to attach the plan
	-- years to the plan. This procedure will firstly check that
	-- there are plan years available for the next 10 years. If
	-- there are not then plan years will be created. They then will
	-- be attached to the plan using the Benefit API.
	--
	attach_plan_years
	  (p_effective_date    => l_effective_date
      ,p_business_group_id => p_business_group_id
      ,p_pl_id             => l_pl_id);
	--
  END;
  --
  per_cag_ins.ins
    (p_collective_agreement_id       => l_collective_agreement_id
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_name                          => p_name
	,p_pl_id                         => l_pl_id
	,p_status                        => p_status
    ,p_cag_number                    => p_cag_number
    ,p_description                   => p_description
    ,p_start_date                    => l_start_date
    ,p_end_date                      => p_end_date
    ,p_employer_organization_id      => p_employer_organization_id
    ,p_employer_signatory            => p_employer_signatory
    ,p_bargaining_organization_id    => p_bargaining_organization_id
    ,p_bargaining_unit_signatory     => p_bargaining_unit_signatory
    ,p_jurisdiction                  => p_jurisdiction
    ,p_authorizing_body              => p_authorizing_body
    ,p_authorized_date               => p_authorized_date
    ,p_cag_information_category      => p_cag_information_category
    ,p_cag_information1              => p_cag_information1
    ,p_cag_information2              => p_cag_information2
    ,p_cag_information3              => p_cag_information3
    ,p_cag_information4              => p_cag_information4
    ,p_cag_information5              => p_cag_information5
    ,p_cag_information6              => p_cag_information6
    ,p_cag_information7              => p_cag_information7
    ,p_cag_information8              => p_cag_information8
    ,p_cag_information9              => p_cag_information9
    ,p_cag_information10             => p_cag_information10
    ,p_cag_information11             => p_cag_information11
    ,p_cag_information12             => p_cag_information12
    ,p_cag_information13             => p_cag_information13
    ,p_cag_information14             => p_cag_information14
    ,p_cag_information15             => p_cag_information15
    ,p_cag_information16             => p_cag_information16
    ,p_cag_information17             => p_cag_information17
    ,p_cag_information18             => p_cag_information18
    ,p_cag_information19             => p_cag_information19
    ,p_cag_information20             => p_cag_information20
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
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_collective_agreement
    --
    hr_collective_agreement_bk1.create_collective_agreement_a
      (p_collective_agreement_id        =>  l_collective_agreement_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_name                           =>  p_name
	  ,p_status                         =>  p_status
      ,p_cag_number                     =>  p_cag_number
      ,p_description                    =>  p_description
      ,p_start_date                     =>  l_start_date
      ,p_end_date                       =>  p_end_date
      ,p_employer_organization_id       =>  p_employer_organization_id
      ,p_employer_signatory             =>  p_employer_signatory
      ,p_bargaining_organization_id     =>  p_bargaining_organization_id
      ,p_bargaining_unit_signatory      =>  p_bargaining_unit_signatory
      ,p_jurisdiction                   =>  p_jurisdiction
      ,p_authorizing_body               =>  p_authorizing_body
      ,p_authorized_date                =>  p_authorized_date
      ,p_cag_information_category       =>  p_cag_information_category
      ,p_cag_information1               =>  p_cag_information1
      ,p_cag_information2               =>  p_cag_information2
      ,p_cag_information3               =>  p_cag_information3
      ,p_cag_information4               =>  p_cag_information4
      ,p_cag_information5               =>  p_cag_information5
      ,p_cag_information6               =>  p_cag_information6
      ,p_cag_information7               =>  p_cag_information7
      ,p_cag_information8               =>  p_cag_information8
      ,p_cag_information9               =>  p_cag_information9
      ,p_cag_information10              =>  p_cag_information10
      ,p_cag_information11              =>  p_cag_information11
      ,p_cag_information12              =>  p_cag_information12
      ,p_cag_information13              =>  p_cag_information13
      ,p_cag_information14              =>  p_cag_information14
      ,p_cag_information15              =>  p_cag_information15
      ,p_cag_information16              =>  p_cag_information16
      ,p_cag_information17              =>  p_cag_information17
      ,p_cag_information18              =>  p_cag_information18
      ,p_cag_information19              =>  p_cag_information19
      ,p_cag_information20              =>  p_cag_information20
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_collective_agreement'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_collective_agreement
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_collective_agreement_id := l_collective_agreement_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_collective_agreement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_collective_agreement_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    -- Reset out params.Nocopy changes
    p_collective_agreement_id := null;
    p_object_version_number  := null;
    ROLLBACK TO create_collective_agreement;
    raise;
    --
end create_collective_agreement;
-- ----------------------------------------------------------------------------
-- |------------------------< update_collective_agreement >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_collective_agreement
  (p_validate                       in  boolean   default false
  ,p_collective_agreement_id        in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_cag_number                     in  number    default hr_api.g_number
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_start_date                     in  date      default hr_api.g_date
  ,p_end_date                       in  date      default hr_api.g_date
  ,p_employer_organization_id       in  number    default hr_api.g_number
  ,p_employer_signatory             in  varchar2  default hr_api.g_varchar2
  ,p_bargaining_organization_id     in  number    default hr_api.g_number
  ,p_bargaining_unit_signatory      in  varchar2  default hr_api.g_varchar2
  ,p_jurisdiction                   in  varchar2  default hr_api.g_varchar2
  ,p_authorizing_body               in  varchar2  default hr_api.g_varchar2
  ,p_authorized_date                in  date      default hr_api.g_date
  ,p_cag_information_category       in  varchar2  default hr_api.g_varchar2
  ,p_cag_information1               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information2               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information3               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information4               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information5               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information6               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information7               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information8               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information9               in  varchar2  default hr_api.g_varchar2
  ,p_cag_information10              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information11              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information12              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information13              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information14              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information15              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information16              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information17              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information18              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information19              in  varchar2  default hr_api.g_varchar2
  ,p_cag_information20              in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_collective_agreement';
  l_object_version_number per_collective_agreements.object_version_number%TYPE;
  l_temp_ovn    number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_collective_agreement;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  l_temp_ovn              := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_collective_agreement
    --
    hr_collective_agreement_bk2.update_collective_agreement_b
      (
       p_collective_agreement_id        =>  p_collective_agreement_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_name                           =>  p_name
	  ,p_status                         =>  p_status
      ,p_cag_number                     =>  p_cag_number
      ,p_description                    =>  p_description
      ,p_start_date                     =>  p_start_date
      ,p_end_date                       =>  p_end_date
      ,p_employer_organization_id       =>  p_employer_organization_id
      ,p_employer_signatory             =>  p_employer_signatory
      ,p_bargaining_organization_id     =>  p_bargaining_organization_id
      ,p_bargaining_unit_signatory      =>  p_bargaining_unit_signatory
      ,p_jurisdiction                   =>  p_jurisdiction
      ,p_authorizing_body               =>  p_authorizing_body
      ,p_authorized_date                =>  p_authorized_date
      ,p_cag_information_category       =>  p_cag_information_category
      ,p_cag_information1               =>  p_cag_information1
      ,p_cag_information2               =>  p_cag_information2
      ,p_cag_information3               =>  p_cag_information3
      ,p_cag_information4               =>  p_cag_information4
      ,p_cag_information5               =>  p_cag_information5
      ,p_cag_information6               =>  p_cag_information6
      ,p_cag_information7               =>  p_cag_information7
      ,p_cag_information8               =>  p_cag_information8
      ,p_cag_information9               =>  p_cag_information9
      ,p_cag_information10              =>  p_cag_information10
      ,p_cag_information11              =>  p_cag_information11
      ,p_cag_information12              =>  p_cag_information12
      ,p_cag_information13              =>  p_cag_information13
      ,p_cag_information14              =>  p_cag_information14
      ,p_cag_information15              =>  p_cag_information15
      ,p_cag_information16              =>  p_cag_information16
      ,p_cag_information17              =>  p_cag_information17
      ,p_cag_information18              =>  p_cag_information18
      ,p_cag_information19              =>  p_cag_information19
      ,p_cag_information20              =>  p_cag_information20
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      p_object_version_number := l_temp_ovn;
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_collective_agreement'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_collective_agreement
    --
  end;
  --
  per_cag_upd.upd
    (
     p_collective_agreement_id       => p_collective_agreement_id
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_name                          => p_name
	,p_status                    => p_status
    ,p_cag_number                    => p_cag_number
    ,p_description                   => p_description
    ,p_start_date                    => p_start_date
    ,p_end_date                      => p_end_date
    ,p_employer_organization_id      => p_employer_organization_id
    ,p_employer_signatory            => p_employer_signatory
    ,p_bargaining_organization_id    => p_bargaining_organization_id
    ,p_bargaining_unit_signatory     => p_bargaining_unit_signatory
    ,p_jurisdiction                  => p_jurisdiction
    ,p_authorizing_body              => p_authorizing_body
    ,p_authorized_date               => p_authorized_date
    ,p_cag_information_category      => p_cag_information_category
    ,p_cag_information1              => p_cag_information1
    ,p_cag_information2              => p_cag_information2
    ,p_cag_information3              => p_cag_information3
    ,p_cag_information4              => p_cag_information4
    ,p_cag_information5              => p_cag_information5
    ,p_cag_information6              => p_cag_information6
    ,p_cag_information7              => p_cag_information7
    ,p_cag_information8              => p_cag_information8
    ,p_cag_information9              => p_cag_information9
    ,p_cag_information10             => p_cag_information10
    ,p_cag_information11             => p_cag_information11
    ,p_cag_information12             => p_cag_information12
    ,p_cag_information13             => p_cag_information13
    ,p_cag_information14             => p_cag_information14
    ,p_cag_information15             => p_cag_information15
    ,p_cag_information16             => p_cag_information16
    ,p_cag_information17             => p_cag_information17
    ,p_cag_information18             => p_cag_information18
    ,p_cag_information19             => p_cag_information19
    ,p_cag_information20             => p_cag_information20
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
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_collective_agreement
    --
    hr_collective_agreement_bk2.update_collective_agreement_a
      (
       p_collective_agreement_id        =>  p_collective_agreement_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_name                           =>  p_name
	  ,p_status                         =>  p_status
      ,p_cag_number                     =>  p_cag_number
      ,p_description                    =>  p_description
      ,p_start_date                     =>  p_start_date
      ,p_end_date                       =>  p_end_date
      ,p_employer_organization_id       =>  p_employer_organization_id
      ,p_employer_signatory             =>  p_employer_signatory
      ,p_bargaining_organization_id     =>  p_bargaining_organization_id
      ,p_bargaining_unit_signatory      =>  p_bargaining_unit_signatory
      ,p_jurisdiction                   =>  p_jurisdiction
      ,p_authorizing_body               =>  p_authorizing_body
      ,p_authorized_date                =>  p_authorized_date
      ,p_cag_information_category       =>  p_cag_information_category
      ,p_cag_information1               =>  p_cag_information1
      ,p_cag_information2               =>  p_cag_information2
      ,p_cag_information3               =>  p_cag_information3
      ,p_cag_information4               =>  p_cag_information4
      ,p_cag_information5               =>  p_cag_information5
      ,p_cag_information6               =>  p_cag_information6
      ,p_cag_information7               =>  p_cag_information7
      ,p_cag_information8               =>  p_cag_information8
      ,p_cag_information9               =>  p_cag_information9
      ,p_cag_information10              =>  p_cag_information10
      ,p_cag_information11              =>  p_cag_information11
      ,p_cag_information12              =>  p_cag_information12
      ,p_cag_information13              =>  p_cag_information13
      ,p_cag_information14              =>  p_cag_information14
      ,p_cag_information15              =>  p_cag_information15
      ,p_cag_information16              =>  p_cag_information16
      ,p_cag_information17              =>  p_cag_information17
      ,p_cag_information18              =>  p_cag_information18
      ,p_cag_information19              =>  p_cag_information19
      ,p_cag_information20              =>  p_cag_information20
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      p_object_version_number := l_temp_ovn;
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_collective_agreement'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_collective_agreement
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_collective_agreement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    -- Reset in out params. Nocopy changes.
    p_object_version_number := l_temp_ovn;
    ROLLBACK TO update_collective_agreement;
    raise;
    --
end update_collective_agreement;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_collective_agreement >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_collective_agreement
  (p_validate                       in  boolean  default false
  ,p_collective_agreement_id        in  number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'delete_collective_agreement';
  l_object_version_number per_collective_agreements.object_version_number%TYPE;
  l_pl_ovn                NUMBER;
  l_pl_id                 NUMBER;
  l_popl_ovn              NUMBER;
  l_dummy                 VARCHAR2(1);
  l_effective_date        DATE;
  l_start_date            DATE;
  l_end_date              DATE;
  --
  CURSOR csr_chk_for_entitlements IS
    SELECT 'x'
	  FROM per_cagr_entitlements pce
	 WHERE pce.collective_agreement_id = p_collective_agreement_id;
  --
  CURSOR csr_pln IS
    SELECT b.pl_id,
	       b.object_version_number,
		   cag.start_date
	  FROM ben_pl_f b,
	       per_collective_agreements cag
	 WHERE b.pl_id = cag.pl_Id
	   AND cag.collective_agreement_id = p_collective_agreement_id;
  --
  CURSOR csr_popl_yr IS
    SELECT pop.popl_yr_perd_id,
		   pop.object_version_number
	  FROM ben_popl_yr_perd pop
	 WHERE pop.pl_id = l_pl_id;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_collective_agreement;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_collective_agreement
    --
    hr_collective_agreement_bk3.delete_collective_agreement_b
      (p_collective_agreement_id        =>  p_collective_agreement_id
      ,p_object_version_number          =>  p_object_version_number);
	--
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_collective_agreement'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_collective_agreement
    --
  end;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Check that no entitlements exist before trying to
  -- delete the collective agreement.
  -- This check has been added in order to display a
  -- meaningful cagr error message. If this check was not
  -- performed and we tried to delete we would get a BEN error
  -- message (Options exist) which is meaningless in the context
  -- of a CAGR.
  --
  OPEN csr_chk_for_entitlements;
  FETCH csr_chk_for_entitlements INTO l_dummy;
  --
  IF csr_chk_for_entitlements%FOUND THEN
    --
    CLOSE csr_chk_for_entitlements;
    --
    hr_utility.set_message(800, 'HR_289398_ENTITLEMENTS_EXIST');
    hr_utility.raise_error;
    --
  ELSE
    --
	CLOSE csr_chk_for_entitlements;
    --
  END IF;
  --
  -- Fetch the Plan and Plan Year information
  --
  OPEN csr_pln;
  FETCH csr_pln INTO l_pl_id,
                     l_pl_ovn,
					 l_effective_date;
  --
  -- If A Plan exists then delete it and
  -- the link between plan years
  --
  IF csr_pln%FOUND THEN
    --
	hr_utility.set_location(l_proc, 40);
	savepoint validate_popl_yr;                                 -- Bug # 5405435
	--
	-- Loop Through all the plan years associated
	-- to the the plan and delete them
	--
    FOR c1 IN csr_popl_yr LOOP
	  --
	  hr_utility.set_location(l_proc||'/'||c1.popl_yr_perd_id, 50);
	  --
	  l_popl_ovn := c1.object_version_number;
	  --
	  -- Delete plan years link
	  --
	  ben_popl_yr_perd_api.delete_popl_yr_perd
        (p_validate                       => false		     -- Bug # 5405435
        ,p_popl_yr_perd_id                => c1.popl_yr_perd_id
        ,p_object_version_number          => l_popl_ovn);
	 --
	 -- when P_validate is called with value as 'True',
	 -- the changes made by this API (because of it being
	 -- called with p_validate => false), will be rolled
	 -- back.
	 --
    END LOOP;
	--
	-- Delete Plan
	--
    ben_plan_api.delete_plan
      (p_validate                       => p_validate
      ,p_pl_id                          => l_pl_id
      ,p_effective_start_date           => l_start_date
      ,p_effective_end_date             => l_end_date
      ,p_object_version_number          => l_pl_ovn
      ,p_effective_date                 => l_effective_date
      ,p_datetrack_mode                 => 'ZAP');
    --
    IF p_validate then                                         -- Bug # 5405435
       ROLLBACK TO validate_popl_yr;
    END IF;
    --
  END IF;
  --
  CLOSE csr_pln;
  --
  per_cag_del.del
    (p_collective_agreement_id       => p_collective_agreement_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_collective_agreement
    --
    hr_collective_agreement_bk3.delete_collective_agreement_a
      (
       p_collective_agreement_id        =>  p_collective_agreement_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_collective_agreement'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_collective_agreement
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_collective_agreement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset in out params.
    p_object_version_number := l_object_version_number;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    -- Reset in out params.
    p_object_version_number := l_object_version_number;
    ROLLBACK TO delete_collective_agreement;
    raise;
    --
end delete_collective_agreement;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_collective_agreement_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  per_cag_shd.lck
    (
      p_collective_agreement_id                 => p_collective_agreement_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end hr_collective_agreement_api;

/
