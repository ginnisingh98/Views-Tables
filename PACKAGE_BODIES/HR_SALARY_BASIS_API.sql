--------------------------------------------------------
--  DDL for Package Body HR_SALARY_BASIS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SALARY_BASIS_API" as
/* $Header: peppbapi.pkb 115.1 2003/02/07 11:23:14 pkakar noship $ */
--
-- Package Variables
--
  g_package  varchar2(33) := '  hr_salary_basis_api.';
--
-- ---------------------------------------------------------------------------
-- |---------------------< create_salary_basis >-----------------------------|
-- ---------------------------------------------------------------------------
procedure create_salary_basis
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_input_value_id		   in     number
  ,p_rate_id			   in 	  number   default null
  ,p_name			   in     varchar2
  ,p_pay_basis			   in     varchar2
  ,p_rate_basis 		   in     varchar2
  ,p_pay_annualization_factor      in 	  number   default null
  ,p_grade_annualization_factor    in 	  number   default null
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
  ,p_last_update_date              in 	  date     default null
  ,p_last_updated_by               in 	  number   default null
  ,p_last_update_login             in 	  number   default null
  ,p_created_by                    in 	  number   default null
  ,p_creation_date                 in 	  date     default null
  ,p_information_category          in     varchar2 default null
  ,p_information1 	           in     varchar2 default null
  ,p_information2 	           in     varchar2 default null
  ,p_information3 	           in     varchar2 default null
  ,p_information4 	           in     varchar2 default null
  ,p_information5 	           in     varchar2 default null
  ,p_information6 	           in     varchar2 default null
  ,p_information7 	           in     varchar2 default null
  ,p_information8 	           in     varchar2 default null
  ,p_information9 	           in     varchar2 default null
  ,p_information10 	           in     varchar2 default null
  ,p_information11 	           in     varchar2 default null
  ,p_information12 	           in     varchar2 default null
  ,p_information13 	           in     varchar2 default null
  ,p_information14 	           in     varchar2 default null
  ,p_information15 	           in     varchar2 default null
  ,p_information16 	           in     varchar2 default null
  ,p_information17 	           in     varchar2 default null
  ,p_information18 	           in     varchar2 default null
  ,p_information19 	           in     varchar2 default null
  ,p_information20 	           in     varchar2 default null
  ,p_pay_basis_id                  out    nocopy number
  ,p_object_version_number         out    nocopy number
   ) is
--
-- Declare cursors and local variables
--
   l_pay_basis_id          per_pay_bases.pay_basis_id%TYPE;
   l_business_group_id     per_pay_bases.business_group_id%TYPE;
   l_name                  per_pay_bases.name%TYPE;
   l_proc                  varchar2(72) := g_package||'create_salary_basis';
   l_object_version_number per_pay_bases.object_version_number%TYPE;
   l_input_value_id	   per_pay_bases.input_value_id%TYPE;
   l_rate_id		   per_pay_bases.rate_id%TYPE;
   l_pay_basis		   per_pay_bases.pay_basis%TYPE;
   l_rate_basis 	   per_pay_bases.rate_basis%TYPE;
   l_pay_annualization_factor per_pay_bases.pay_annualization_factor%TYPE;
   l_grade_annualization_factor per_pay_bases.grade_annualization_factor%TYPE;
   --
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_salary_basis;
  --
  -- check that flex structure is valid
  --
  begin
  --
  -- Call Before Process User hook for create_salary_basis
  --
  hr_salary_basis_bk1.create_salary_basis_b
    (p_business_group_id             => p_business_group_id
    ,p_input_value_id		     =>	p_input_value_id
    ,p_rate_id			     =>	p_rate_id
    ,p_name                          => p_name
    ,p_pay_basis		     => p_pay_basis
    ,p_rate_basis 		     => p_rate_basis
    ,p_pay_annualization_factor      => p_pay_annualization_factor
    ,p_grade_annualization_factor    => p_grade_annualization_factor
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
    ,p_last_update_date              => p_last_update_date
    ,p_last_updated_by               => p_last_updated_by
    ,p_last_update_login             => p_last_update_login
    ,p_created_by                    => p_created_by
    ,p_creation_date                 => p_creation_date
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20 	             => p_information20
    ,p_pay_basis_id                  => l_pay_basis_id
    ,p_object_version_number         => l_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SALARY_BASIS'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (create_salary_basis)
  --
  end;
  --
  -- Process Logic
  --
  --
  -- Insert Salary Basis.
  --
     hr_utility.set_location(l_proc, 30);
     --
     per_ppb_ins.ins
    (p_input_value_id		     =>	p_input_value_id
    ,p_business_group_id             => p_business_group_id
    ,p_name                          => p_name
    ,p_pay_basis		     => p_pay_basis
    ,p_rate_id			     =>	p_rate_id
    ,p_rate_basis 		     => p_rate_basis
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
    ,p_pay_annualization_factor      => p_pay_annualization_factor
    ,p_grade_annualization_factor    => p_grade_annualization_factor
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20 	             => p_information20
    ,p_pay_basis_id                  => l_pay_basis_id
    ,p_object_version_number         => l_object_version_number
       );
     --
     hr_utility.set_location(l_proc, 40);
  --
  --
  --
  -- Call After Process hook for create_salary_basis
  --
  begin
    hr_salary_basis_bk1.create_salary_basis_a
    (p_business_group_id             => l_business_group_id
    ,p_input_value_id		     =>	l_input_value_id
    ,p_rate_id			     =>	l_rate_id
    ,p_name                          => l_name
    ,p_pay_basis		     => l_pay_basis
    ,p_rate_basis 		     => l_rate_basis
    ,p_pay_annualization_factor      => l_pay_annualization_factor
    ,p_grade_annualization_factor    => l_grade_annualization_factor
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
    ,p_last_update_date              => p_last_update_date
    ,p_last_updated_by               => p_last_updated_by
    ,p_last_update_login             => p_last_update_login
    ,p_created_by                    => p_created_by
    ,p_creation_date                 => p_creation_date
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20 	             => p_information20
    ,p_pay_basis_id                  => l_pay_basis_id
    ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SALARY_BASIS'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (create_salary_basis)
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  -- Set OUT parameters
  --
   p_pay_basis_id                := l_pay_basis_id;
   p_object_version_number := l_object_version_number;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 60);
   --
   exception
   --
   when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     ROLLBACK TO create_salary_basis;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     p_pay_basis_id              := null;
     p_object_version_number     := null;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     ROLLBACK TO create_salary_basis;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
     --
     raise;
     --
end create_salary_basis;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_salary_basis >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_salary_basis
  (P_VALIDATE			    IN	  BOOLEAN default false
   ,P_PAY_BASIS_ID                  IN    NUMBER
   ,P_INPUT_VALUE_ID                IN    NUMBER default hr_api.g_number
   ,P_RATE_ID                       IN    NUMBER default hr_api.g_number
   ,P_NAME                          IN    VARCHAR2 default hr_api.g_varchar2
   ,P_PAY_BASIS                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_RATE_BASIS                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_PAY_ANNUALIZATION_FACTOR      IN    NUMBER default hr_api.g_number
   ,P_GRADE_ANNUALIZATION_FACTOR    IN    NUMBER default hr_api.g_number
   ,P_ATTRIBUTE_CATEGORY            IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE1                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE2                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE3                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE4                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE5                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE6                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE7                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE8                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE9                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE10                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE11                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE12                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE13                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE14                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE15                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE16                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE17                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE18                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE19                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE20                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION_CATEGORY          IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION1                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION2                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION3                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION4                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION5                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION6                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION7                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION8                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION9                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION10                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION11                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION12                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION13                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION14                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION15                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION16                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION17                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION18                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION19                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION20                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_LAST_UPDATE_DATE              IN    DATE default hr_api.g_date
   ,P_LAST_UPDATED_BY               IN    NUMBER default hr_api.g_number
   ,P_LAST_UPDATE_LOGIN             IN    NUMBER default hr_api.g_number
   ,P_CREATED_BY                    IN    NUMBER default hr_api.g_number
   ,P_CREATION_DATE                 IN    DATE default hr_api.g_date
   ,P_OBJECT_VERSION_NUMBER	    IN OUT nocopy NUMBER
    ) is
--
-- Declare cursors and local variables
--
    --
  l_object_version_number      per_pay_bases.object_version_number%TYPE;
  l_api_updating               boolean;
   l_pay_basis_id          per_pay_bases.pay_basis_id%TYPE;
   l_business_group_id     per_pay_bases.business_group_id%TYPE;
   l_name                  per_pay_bases.name%TYPE;
   l_proc                  varchar2(72) := g_package||'update_salary_basis';
   l_input_value_id	   per_pay_bases.input_value_id%TYPE;
   l_rate_id		   per_pay_bases.rate_id%TYPE;
   l_pay_basis		   per_pay_bases.pay_basis%TYPE;
   l_rate_basis 	   per_pay_bases.rate_basis%TYPE;
   l_pay_annualization_factor per_pay_bases.pay_annualization_factor%TYPE;
   l_grade_annualization_factor per_pay_bases.grade_annualization_factor%TYPE;
   --
  --
  -- Declare cursors
  --
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 5);
   --
   -- Issue a savepoint
   --
   savepoint update_salary_basis;
   --
   hr_utility.set_location(l_proc, 10);
   --
   -- Validation in addition to Table Handlers
   --
l_object_version_number := p_object_version_number;
   l_api_updating := per_ppb_shd.api_updating
     (p_pay_basis_id	        => p_pay_basis_id
     ,p_object_version_number	=> p_object_version_number);
   --
   hr_utility.set_location(l_proc, 15);
   --
   if not l_api_updating
   then
      hr_utility.set_location(l_proc, 20);
      --
      -- As this an updating API, the salary basis should already exist.
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;

   end if;
   --
   hr_utility.set_location('Entering: call - update_salary_basis_b',35);
   --
   --
   -- Call Before Process User Hook
   --
   begin
   --
     hr_salary_basis_bk2.update_salary_basis_b
      (p_pay_basis_id	               => p_pay_basis_id
      ,p_input_value_id                => p_input_value_id
      ,p_rate_id		       => p_rate_id
      ,p_name			       => p_name
      ,p_pay_basis		       => p_pay_basis
      ,p_rate_basis 		       => p_rate_basis
      ,p_pay_annualization_factor      => p_pay_annualization_factor
      ,p_grade_annualization_factor    => p_grade_annualization_factor
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
      ,p_last_update_date              => p_last_update_date
      ,p_last_updated_by               => p_last_updated_by
      ,p_last_update_login             => p_last_update_login
      ,p_created_by                    => p_created_by
      ,p_creation_date                 => p_creation_date
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_object_version_number	       => l_object_version_number
      );
      --
   exception
     when hr_api.cannot_find_prog_unit
     then
        hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SALARY_BASIS'
        ,p_hook_type   => 'BP'
        );
   end; -- End of API User Hook for the before hook of salary_basis
   --
   hr_utility.set_location('Entering:'|| l_proc, 30);
   --
   hr_utility.set_location('Entering:'|| l_proc, 36);

   --
    select business_group_id
    into l_business_group_id
    from per_pay_bases
    where pay_basis_id = p_pay_basis_id;

   per_ppb_upd.upd
   (p_pay_basis_id                 => p_pay_basis_id
   ,p_object_version_number        => l_object_version_number
   ,p_input_value_id 		   => p_input_value_id
   ,p_business_group_id		   => l_business_group_id
   ,p_name                         => p_name
   ,p_pay_basis			   => p_pay_basis
   ,p_rate_id			   => p_rate_id
   ,p_rate_basis		   => p_rate_basis
   ,p_attribute_category           => p_attribute_category
   ,p_attribute1                   => p_attribute1
   ,p_attribute2                   => p_attribute2
   ,p_attribute3                   => p_attribute3
   ,p_attribute4                   => p_attribute4
   ,p_attribute5                   => p_attribute5
   ,p_attribute6                   => p_attribute6
   ,p_attribute7                   => p_attribute7
   ,p_attribute8                   => p_attribute8
   ,p_attribute9                   => p_attribute9
   ,p_attribute10                  => p_attribute10
   ,p_attribute11                  => p_attribute11
   ,p_attribute12                  => p_attribute12
   ,p_attribute13                  => p_attribute13
   ,p_attribute14                  => p_attribute14
   ,p_attribute15                  => p_attribute15
   ,p_attribute16                  => p_attribute16
   ,p_attribute17                  => p_attribute17
   ,p_attribute18                  => p_attribute18
   ,p_attribute19                  => p_attribute19
   ,p_attribute20                  => p_attribute20
   ,p_pay_annualization_factor     => p_pay_annualization_factor
   ,p_grade_annualization_factor   => p_grade_annualization_factor
   ,p_information_category         => p_information_category
   ,p_information1                 => p_information1
   ,p_information2                 => p_information2
   ,p_information3                 => p_information3
   ,p_information4                 => p_information4
   ,p_information5                 => p_information5
   ,p_information6                 => p_information6
   ,p_information7                 => p_information7
   ,p_information8                 => p_information8
   ,p_information9                 => p_information9
   ,p_information10                => p_information10
   ,p_information11                => p_information11
   ,p_information12                => p_information12
   ,p_information13                => p_information13
   ,p_information14                => p_information14
   ,p_information15                => p_information15
   ,p_information16                => p_information16
   ,p_information17                => p_information17
   ,p_information18                => p_information18
   ,p_information19                => p_information19
   ,p_information20                => p_information20
   );

  --
  hr_utility.set_location('Entering: call - update_salary_basis_a',55);
  --
  begin
  --
  hr_salary_basis_bk2.update_salary_basis_a
     (p_pay_basis_id	               => p_pay_basis_id
      ,p_input_value_id                => p_input_value_id
      ,p_rate_id		       => p_rate_id
      ,p_name			       => p_name
      ,p_pay_basis		       => p_pay_basis
      ,p_rate_basis 		       => p_rate_basis
      ,p_pay_annualization_factor      => p_pay_annualization_factor
      ,p_grade_annualization_factor    => p_grade_annualization_factor
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
      ,p_last_update_date              => p_last_update_date
      ,p_last_updated_by               => p_last_updated_by
      ,p_last_update_login             => p_last_update_login
      ,p_created_by                    => p_created_by
      ,p_creation_date                 => p_creation_date
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_object_version_number	       => l_object_version_number
     );
   --
   exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name => 'UPDATE_SALARY_BASIS'
         ,p_hook_type   => 'AP'
         );
   end; -- End of API User Hook for the after hook of update_salary_basis
   --
   hr_utility.set_location(l_proc, 90);
   --
   -- When in validation only mode raise the Validate_Enabled exception
   --
   if p_validate
   then
      raise hr_api.validate_enabled;
   end if;
   --
   p_object_version_number := l_object_version_number;

   --
   hr_utility.set_location(' Leaving:'||l_proc, 100);
   exception
   when hr_api.validate_enabled then
   --
   -- As the Validate_Enabled exception has been raised
   -- we must rollback to the savepoint
   --
   ROLLBACK TO update_salary_basis;
   --
   -- Only set output warning arguments
   -- (Any key or derived arguments must be set to null
   -- when validation only mode is being used.)
   --
   p_object_version_number := p_object_version_number;

   when others then
   --
   --
   -- A validation or unexpected error has occured
   --
   rollback to update_salary_basis;
   hr_utility.set_location(' Leaving:'||l_proc, 120);
   raise;
end update_salary_basis;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_salary_basis >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_salary_basis
  (p_validate                      in     boolean default false
  ,p_pay_basis_id                  in     number
  ,p_object_version_number         in out nocopy number) IS

  l_object_version_number       number(9);
  l_proc                varchar2(72) := g_package||'delete_salary_basis';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint
  --
  savepoint delete_salary_basis;

  --
  -- Call Before Process User Hook
  --
  begin
  hr_salary_basis_bk3.delete_salary_basis_b
    (p_validate                   =>  p_validate
    ,p_pay_basis_id               =>  p_pay_basis_id
    ,p_object_version_number      =>  p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SALARY_BASIS'
        ,p_hook_type   => 'BP'
        );
  end;
  -- Process Logic
  --
l_object_version_number := p_object_version_number;
--
per_ppb_del.del
  (p_pay_basis_id                      => p_pay_basis_id
  ,p_object_version_number         => l_object_version_number);
  --
  -- Call After Process User Hook
  --
 begin
  hr_salary_basis_bk3.delete_salary_basis_a
    (p_validate                   =>  p_validate
    ,p_pay_basis_id                   =>  p_pay_basis_id
    ,p_object_version_number      =>  l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SALARY_BASIS'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  p_object_version_number := l_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_salary_basis;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_salary_basis;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_salary_basis;
end hr_salary_basis_api;

/
