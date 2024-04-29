--------------------------------------------------------
--  DDL for Package Body HR_APPLICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPLICATION_API" as
/* $Header: peaplapi.pkb 115.7 2002/12/13 13:12:41 raranjan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_application_api.';
--
-- ---------------------------------------------------------------------------
-- |------------------------< update_apl_details >---------------------------|
-- ---------------------------------------------------------------------------
--
procedure update_apl_details
  (p_validate                     in      boolean  default false
  ,p_application_id               in      number
  ,p_object_version_number        in out nocopy  number
  ,p_effective_date               in      date
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_current_employer             in      varchar2 default hr_api.g_varchar2
  ,p_projected_hire_date          in      date     default hr_api.g_date
  ,p_termination_reason           in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute_category      in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute1              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute2              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute3              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute4              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute5              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute6              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute7              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute8              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute9              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute10             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute11             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute12             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute13             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute14             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute15             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute16             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute17             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute18             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute19             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute20             in      varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_apl_details';
  l_projected_hire_date   per_applications.projected_hire_date%TYPE;
  l_object_version_number per_applications.object_version_number%TYPE;
  l_effective_date        date;
  --
  lv_object_version_number number := p_object_version_number ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_apl_details;
  --
  -- Initialise local variables
  --
  l_object_version_number := p_object_version_number;
  l_projected_hire_date   := trunc(p_projected_hire_date);
  l_effective_date        := trunc(p_effective_date);
  hr_utility.set_location(l_proc, 10);
  --
  begin
    --
    -- Start of the before process hook of update_apl_details
    --
    hr_application_bk1.update_apl_details_b
      (
       p_application_id               => p_application_id
      ,p_object_version_number        => p_object_version_number
      ,p_effective_date               => l_effective_date
      ,p_comments                     => p_comments
      ,p_current_employer             => p_current_employer
      ,p_projected_hire_date          => l_projected_hire_date
      ,p_termination_reason           => p_termination_reason
      ,p_appl_attribute_category      => p_appl_attribute_category
      ,p_appl_attribute1              => p_appl_attribute1
      ,p_appl_attribute2              => p_appl_attribute2
      ,p_appl_attribute3              => p_appl_attribute3
      ,p_appl_attribute4              => p_appl_attribute4
      ,p_appl_attribute5              => p_appl_attribute5
      ,p_appl_attribute6              => p_appl_attribute6
      ,p_appl_attribute7              => p_appl_attribute7
      ,p_appl_attribute8              => p_appl_attribute8
      ,p_appl_attribute9              => p_appl_attribute9
      ,p_appl_attribute10             => p_appl_attribute10
      ,p_appl_attribute11             => p_appl_attribute11
      ,p_appl_attribute12             => p_appl_attribute12
      ,p_appl_attribute13             => p_appl_attribute13
      ,p_appl_attribute14             => p_appl_attribute14
      ,p_appl_attribute15             => p_appl_attribute15
      ,p_appl_attribute16             => p_appl_attribute16
      ,p_appl_attribute17             => p_appl_attribute17
      ,p_appl_attribute18             => p_appl_attribute18
      ,p_appl_attribute19             => p_appl_attribute19
      ,p_appl_attribute20             => p_appl_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_APL_DETAILS'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of of the before process hook for update_apl_details
  --
  end;
  --
  -- Update the applicant record
  --
  per_apl_upd.upd
  (p_application_id                    => p_application_id
  ,p_comments                          => p_comments
  ,p_current_employer                  => p_current_employer
  ,p_projected_hire_date               => l_projected_hire_date
  ,p_termination_reason                => p_termination_reason
  ,p_appl_attribute_category           => p_appl_attribute_category
  ,p_appl_attribute1                   => p_appl_attribute1
  ,p_appl_attribute2                   => p_appl_attribute2
  ,p_appl_attribute3                   => p_appl_attribute3
  ,p_appl_attribute4                   => p_appl_attribute4
  ,p_appl_attribute5                   => p_appl_attribute5
  ,p_appl_attribute6                   => p_appl_attribute6
  ,p_appl_attribute7                   => p_appl_attribute7
  ,p_appl_attribute8                   => p_appl_attribute8
  ,p_appl_attribute9                   => p_appl_attribute9
  ,p_appl_attribute10                  => p_appl_attribute10
  ,p_appl_attribute11                  => p_appl_attribute11
  ,p_appl_attribute12                  => p_appl_attribute12
  ,p_appl_attribute13                  => p_appl_attribute13
  ,p_appl_attribute14                  => p_appl_attribute14
  ,p_appl_attribute15                  => p_appl_attribute15
  ,p_appl_attribute16                  => p_appl_attribute16
  ,p_appl_attribute17                  => p_appl_attribute17
  ,p_appl_attribute18                  => p_appl_attribute18
  ,p_appl_attribute19                  => p_appl_attribute19
  ,p_appl_attribute20                  => p_appl_attribute20
  ,p_object_version_number             => l_object_version_number
  ,p_effective_date                    => l_effective_date
  ,p_validate			       => false
  );
  --
 begin
    --
    -- Start of the after process hook for update_apl_details
    --
    hr_application_bk1.update_apl_details_a
      (
       p_application_id               => p_application_id
      ,p_object_version_number        => l_object_version_number
      ,p_effective_date               => l_effective_date
      ,p_comments                     => p_comments
      ,p_current_employer             => p_current_employer
      ,p_projected_hire_date          => l_projected_hire_date
      ,p_termination_reason           => p_termination_reason
      ,p_appl_attribute_category      => p_appl_attribute_category
      ,p_appl_attribute1              => p_appl_attribute1
      ,p_appl_attribute2              => p_appl_attribute2
      ,p_appl_attribute3              => p_appl_attribute3
      ,p_appl_attribute4              => p_appl_attribute4
      ,p_appl_attribute5              => p_appl_attribute5
      ,p_appl_attribute6              => p_appl_attribute6
      ,p_appl_attribute7              => p_appl_attribute7
      ,p_appl_attribute8              => p_appl_attribute8
      ,p_appl_attribute9              => p_appl_attribute9
      ,p_appl_attribute10             => p_appl_attribute10
      ,p_appl_attribute11             => p_appl_attribute11
      ,p_appl_attribute12             => p_appl_attribute12
      ,p_appl_attribute13             => p_appl_attribute13
      ,p_appl_attribute14             => p_appl_attribute14
      ,p_appl_attribute15             => p_appl_attribute15
      ,p_appl_attribute16             => p_appl_attribute16
      ,p_appl_attribute17             => p_appl_attribute17
      ,p_appl_attribute18             => p_appl_attribute18
      ,p_appl_attribute19             => p_appl_attribute19
      ,p_appl_attribute20             => p_appl_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_APL_DETAILS'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of of the before process hook for update_apl_details
  --
  end;
  --
  hr_utility.set_location(l_proc, 15);
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
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_apl_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 25);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number ;

    ROLLBACK TO update_apl_details;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 30);
    raise;
    --
    -- End of fix.
    --
end update_apl_details;
--
end hr_application_api;

/
