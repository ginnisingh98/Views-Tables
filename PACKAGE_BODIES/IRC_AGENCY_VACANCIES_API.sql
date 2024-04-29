--------------------------------------------------------
--  DDL for Package Body IRC_AGENCY_VACANCIES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_AGENCY_VACANCIES_API" as
/* $Header: iriavapi.pkb 120.0 2005/07/26 15:04:40 mbocutt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'IRC_AGENCY_VACANCIES_API';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_AGENCY_VACANCY >- -------------------|
-- ----------------------------------------------------------------------------
--
procedure create_agency_vacancy
  (p_validate                       in boolean  default false
  ,p_agency_id                      in number
  ,p_vacancy_id                     in number
  ,p_start_date                     in date     default null
  ,p_end_date                       in date     default null
  ,p_max_allowed_applicants         in number   default null
  ,p_manage_applicants_allowed      in varchar2 default 'N'
  ,p_attribute_category             in varchar2 default null
  ,p_attribute1                     in varchar2 default null
  ,p_attribute2                     in varchar2 default null
  ,p_attribute3                     in varchar2 default null
  ,p_attribute4                     in varchar2 default null
  ,p_attribute5                     in varchar2 default null
  ,p_attribute6                     in varchar2 default null
  ,p_attribute7                     in varchar2 default null
  ,p_attribute8                     in varchar2 default null
  ,p_attribute9                     in varchar2 default null
  ,p_attribute10                    in varchar2 default null
  ,p_attribute11                    in varchar2 default null
  ,p_attribute12                    in varchar2 default null
  ,p_attribute13                    in varchar2 default null
  ,p_attribute14                    in varchar2 default null
  ,p_attribute15                    in varchar2 default null
  ,p_attribute16                    in varchar2 default null
  ,p_attribute17                    in varchar2 default null
  ,p_attribute18                    in varchar2 default null
  ,p_attribute19                    in varchar2 default null
  ,p_attribute20                    in varchar2 default null
  ,p_attribute21                    in varchar2 default null
  ,p_attribute22                    in varchar2 default null
  ,p_attribute23                    in varchar2 default null
  ,p_attribute24                    in varchar2 default null
  ,p_attribute25                    in varchar2 default null
  ,p_attribute26                    in varchar2 default null
  ,p_attribute27                    in varchar2 default null
  ,p_attribute28                    in varchar2 default null
  ,p_attribute29                    in varchar2 default null
  ,p_attribute30                    in varchar2 default null
  ,p_object_version_number          out nocopy  number
  ,p_agency_vacancy_id              out nocopy  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_agency_vacancy_id      irc_agency_vacancies.agency_vacancy_id%type;
  l_object_version_number  irc_agency_vacancies.object_version_number%type;
  l_start_date             irc_agency_vacancies.start_date%type;
  l_end_date               irc_agency_vacancies.end_date%type;
  l_proc                   varchar2(72) := g_package||'.CREATE_AGENCY_VACANCY';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_AGENCY_VACANCY;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date := trunc(p_start_date);
  l_end_date   := trunc(p_end_date);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_AGENCY_VACANCIES_BK1.CREATE_AGENCY_VACANCY_b
      (p_agency_vacancy_id          =>  p_agency_vacancy_id
      ,p_agency_id                  =>  p_agency_id
      ,p_vacancy_id                 =>  p_vacancy_id
      ,p_start_date                 =>  l_start_date
      ,p_end_date                   =>  l_end_date
      ,p_max_allowed_applicants     =>  p_max_allowed_applicants
      ,p_manage_applicants_allowed  =>  p_manage_applicants_allowed
      ,p_attribute_category         =>  p_attribute_category
      ,p_attribute1                 =>  p_attribute1
      ,p_attribute2                 =>  p_attribute2
      ,p_attribute3                 =>  p_attribute3
      ,p_attribute4                 =>  p_attribute4
      ,p_attribute5                 =>  p_attribute5
      ,p_attribute6                 =>  p_attribute6
      ,p_attribute7                 =>  p_attribute7
      ,p_attribute8                 =>  p_attribute8
      ,p_attribute9                 =>  p_attribute9
      ,p_attribute10                =>  p_attribute10
      ,p_attribute11                =>  p_attribute11
      ,p_attribute12                =>  p_attribute12
      ,p_attribute13                =>  p_attribute13
      ,p_attribute14                =>  p_attribute14
      ,p_attribute15                =>  p_attribute15
      ,p_attribute16                =>  p_attribute16
      ,p_attribute17                =>  p_attribute17
      ,p_attribute18                =>  p_attribute18
      ,p_attribute19                =>  p_attribute19
      ,p_attribute20                =>  p_attribute20
      ,p_attribute21                =>  p_attribute21
      ,p_attribute22                =>  p_attribute22
      ,p_attribute23                =>  p_attribute23
      ,p_attribute24                =>  p_attribute24
      ,p_attribute25                =>  p_attribute25
      ,p_attribute26                =>  p_attribute26
      ,p_attribute27                =>  p_attribute27
      ,p_attribute28                =>  p_attribute28
      ,p_attribute29                =>  p_attribute29
      ,p_attribute30                =>  p_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_AGENCY_VACANCY'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_iav_ins.ins
      (p_agency_id                  =>  p_agency_id
      ,p_vacancy_id                 =>  p_vacancy_id
      ,p_start_date                 =>  l_start_date
      ,p_end_date                   =>  l_end_date
      ,p_max_allowed_applicants     =>  p_max_allowed_applicants
      ,p_manage_applicants_allowed  =>  p_manage_applicants_allowed
      ,p_attribute_category         =>  p_attribute_category
      ,p_attribute1                 =>  p_attribute1
      ,p_attribute2                 =>  p_attribute2
      ,p_attribute3                 =>  p_attribute3
      ,p_attribute4                 =>  p_attribute4
      ,p_attribute5                 =>  p_attribute5
      ,p_attribute6                 =>  p_attribute6
      ,p_attribute7                 =>  p_attribute7
      ,p_attribute8                 =>  p_attribute8
      ,p_attribute9                 =>  p_attribute9
      ,p_attribute10                =>  p_attribute10
      ,p_attribute11                =>  p_attribute11
      ,p_attribute12                =>  p_attribute12
      ,p_attribute13                =>  p_attribute13
      ,p_attribute14                =>  p_attribute14
      ,p_attribute15                =>  p_attribute15
      ,p_attribute16                =>  p_attribute16
      ,p_attribute17                =>  p_attribute17
      ,p_attribute18                =>  p_attribute18
      ,p_attribute19                =>  p_attribute19
      ,p_attribute20                =>  p_attribute20
      ,p_attribute21                =>  p_attribute21
      ,p_attribute22                =>  p_attribute22
      ,p_attribute23                =>  p_attribute23
      ,p_attribute24                =>  p_attribute24
      ,p_attribute25                =>  p_attribute25
      ,p_attribute26                =>  p_attribute26
      ,p_attribute27                =>  p_attribute27
      ,p_attribute28                =>  p_attribute28
      ,p_attribute29                =>  p_attribute29
      ,p_attribute30                =>  p_attribute30
      ,p_object_version_number      =>  l_object_version_number
      ,p_agency_vacancy_id          =>  l_agency_vacancy_id
      );

  --
  -- Call After Process User Hook
  --
  begin
    IRC_AGENCY_VACANCIES_BK1.CREATE_AGENCY_VACANCY_a
      (p_agency_vacancy_id          =>  l_agency_vacancy_id
      ,p_agency_id                  =>  p_agency_id
      ,p_vacancy_id                 =>  p_vacancy_id
      ,p_start_date                 =>  l_start_date
      ,p_end_date                   =>  l_end_date
      ,p_max_allowed_applicants     =>  p_max_allowed_applicants
      ,p_manage_applicants_allowed  =>  p_manage_applicants_allowed
      ,p_attribute_category         =>  p_attribute_category
      ,p_attribute1                 =>  p_attribute1
      ,p_attribute2                 =>  p_attribute2
      ,p_attribute3                 =>  p_attribute3
      ,p_attribute4                 =>  p_attribute4
      ,p_attribute5                 =>  p_attribute5
      ,p_attribute6                 =>  p_attribute6
      ,p_attribute7                 =>  p_attribute7
      ,p_attribute8                 =>  p_attribute8
      ,p_attribute9                 =>  p_attribute9
      ,p_attribute10                =>  p_attribute10
      ,p_attribute11                =>  p_attribute11
      ,p_attribute12                =>  p_attribute12
      ,p_attribute13                =>  p_attribute13
      ,p_attribute14                =>  p_attribute14
      ,p_attribute15                =>  p_attribute15
      ,p_attribute16                =>  p_attribute16
      ,p_attribute17                =>  p_attribute17
      ,p_attribute18                =>  p_attribute18
      ,p_attribute19                =>  p_attribute19
      ,p_attribute20                =>  p_attribute20
      ,p_attribute21                =>  p_attribute21
      ,p_attribute22                =>  p_attribute22
      ,p_attribute23                =>  p_attribute23
      ,p_attribute24                =>  p_attribute24
      ,p_attribute25                =>  p_attribute25
      ,p_attribute26                =>  p_attribute26
      ,p_attribute27                =>  p_attribute27
      ,p_attribute28                =>  p_attribute28
      ,p_attribute29                =>  p_attribute29
      ,p_attribute30                =>  p_attribute30
      ,p_object_version_number      => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_AGENCY_VACANCY'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  p_agency_vacancy_id      := l_agency_vacancy_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_AGENCY_VACANCY;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_agency_vacancy_id      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_AGENCY_VACANCY;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    p_agency_vacancy_id      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_agency_vacancy;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_AGENCY_VACANCY >- -------------------|
-- ----------------------------------------------------------------------------
--
procedure update_agency_vacancy
  (p_validate                       in boolean  default false
  ,p_agency_vacancy_id              in number
  ,p_agency_id                      in number
  ,p_vacancy_id                     in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_max_allowed_applicants         in number   default hr_api.g_number
  ,p_manage_applicants_allowed      in varchar2 default 'N'
  ,p_attribute_category             in varchar2 default hr_api.g_varchar2
  ,p_attribute1                     in varchar2 default hr_api.g_varchar2
  ,p_attribute2                     in varchar2 default hr_api.g_varchar2
  ,p_attribute3                     in varchar2 default hr_api.g_varchar2
  ,p_attribute4                     in varchar2 default hr_api.g_varchar2
  ,p_attribute5                     in varchar2 default hr_api.g_varchar2
  ,p_attribute6                     in varchar2 default hr_api.g_varchar2
  ,p_attribute7                     in varchar2 default hr_api.g_varchar2
  ,p_attribute8                     in varchar2 default hr_api.g_varchar2
  ,p_attribute9                     in varchar2 default hr_api.g_varchar2
  ,p_attribute10                    in varchar2 default hr_api.g_varchar2
  ,p_attribute11                    in varchar2 default hr_api.g_varchar2
  ,p_attribute12                    in varchar2 default hr_api.g_varchar2
  ,p_attribute13                    in varchar2 default hr_api.g_varchar2
  ,p_attribute14                    in varchar2 default hr_api.g_varchar2
  ,p_attribute15                    in varchar2 default hr_api.g_varchar2
  ,p_attribute16                    in varchar2 default hr_api.g_varchar2
  ,p_attribute17                    in varchar2 default hr_api.g_varchar2
  ,p_attribute18                    in varchar2 default hr_api.g_varchar2
  ,p_attribute19                    in varchar2 default hr_api.g_varchar2
  ,p_attribute20                    in varchar2 default hr_api.g_varchar2
  ,p_attribute21                    in varchar2 default hr_api.g_varchar2
  ,p_attribute22                    in varchar2 default hr_api.g_varchar2
  ,p_attribute23                    in varchar2 default hr_api.g_varchar2
  ,p_attribute24                    in varchar2 default hr_api.g_varchar2
  ,p_attribute25                    in varchar2 default hr_api.g_varchar2
  ,p_attribute26                    in varchar2 default hr_api.g_varchar2
  ,p_attribute27                    in varchar2 default hr_api.g_varchar2
  ,p_attribute28                    in varchar2 default hr_api.g_varchar2
  ,p_attribute29                    in varchar2 default hr_api.g_varchar2
  ,p_attribute30                    in varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number  irc_agency_vacancies.object_version_number%type
                              := p_object_version_number;
  l_start_date             irc_agency_vacancies.start_date%type;
  l_end_date               irc_agency_vacancies.end_date%type;
  l_proc                varchar2(72) := g_package||'UPDATE_AGENCY_VACANCY';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_AGENCY_VACANCY;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date := trunc(p_start_date);
  l_end_date   := trunc(p_end_date);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_AGENCY_VACANCIES_BK2.UPDATE_AGENCY_VACANCY_b
      (p_agency_vacancy_id          =>  p_agency_vacancy_id
      ,p_agency_id                  =>  p_agency_id
      ,p_vacancy_id                 =>  p_vacancy_id
      ,p_start_date                 =>  l_start_date
      ,p_end_date                   =>  l_end_date
      ,p_max_allowed_applicants     =>  p_max_allowed_applicants
      ,p_manage_applicants_allowed  =>  p_manage_applicants_allowed
      ,p_attribute_category         =>  p_attribute_category
      ,p_attribute1                 =>  p_attribute1
      ,p_attribute2                 =>  p_attribute2
      ,p_attribute3                 =>  p_attribute3
      ,p_attribute4                 =>  p_attribute4
      ,p_attribute5                 =>  p_attribute5
      ,p_attribute6                 =>  p_attribute6
      ,p_attribute7                 =>  p_attribute7
      ,p_attribute8                 =>  p_attribute8
      ,p_attribute9                 =>  p_attribute9
      ,p_attribute10                =>  p_attribute10
      ,p_attribute11                =>  p_attribute11
      ,p_attribute12                =>  p_attribute12
      ,p_attribute13                =>  p_attribute13
      ,p_attribute14                =>  p_attribute14
      ,p_attribute15                =>  p_attribute15
      ,p_attribute16                =>  p_attribute16
      ,p_attribute17                =>  p_attribute17
      ,p_attribute18                =>  p_attribute18
      ,p_attribute19                =>  p_attribute19
      ,p_attribute20                =>  p_attribute20
      ,p_attribute21                =>  p_attribute21
      ,p_attribute22                =>  p_attribute22
      ,p_attribute23                =>  p_attribute23
      ,p_attribute24                =>  p_attribute24
      ,p_attribute25                =>  p_attribute25
      ,p_attribute26                =>  p_attribute26
      ,p_attribute27                =>  p_attribute27
      ,p_attribute28                =>  p_attribute28
      ,p_attribute29                =>  p_attribute29
      ,p_attribute30                =>  p_attribute30
      ,p_object_version_number      =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_AGENCY_VACANCY'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  irc_iav_upd.upd
      (p_agency_vacancy_id          =>  p_agency_vacancy_id
      ,p_agency_id                  =>  p_agency_id
      ,p_vacancy_id                 =>  p_vacancy_id
      ,p_start_date                 =>  l_start_date
      ,p_end_date                   =>  l_end_date
      ,p_max_allowed_applicants     =>  p_max_allowed_applicants
      ,p_manage_applicants_allowed  =>  p_manage_applicants_allowed
      ,p_attribute_category         =>  p_attribute_category
      ,p_attribute1                 =>  p_attribute1
      ,p_attribute2                 =>  p_attribute2
      ,p_attribute3                 =>  p_attribute3
      ,p_attribute4                 =>  p_attribute4
      ,p_attribute5                 =>  p_attribute5
      ,p_attribute6                 =>  p_attribute6
      ,p_attribute7                 =>  p_attribute7
      ,p_attribute8                 =>  p_attribute8
      ,p_attribute9                 =>  p_attribute9
      ,p_attribute10                =>  p_attribute10
      ,p_attribute11                =>  p_attribute11
      ,p_attribute12                =>  p_attribute12
      ,p_attribute13                =>  p_attribute13
      ,p_attribute14                =>  p_attribute14
      ,p_attribute15                =>  p_attribute15
      ,p_attribute16                =>  p_attribute16
      ,p_attribute17                =>  p_attribute17
      ,p_attribute18                =>  p_attribute18
      ,p_attribute19                =>  p_attribute19
      ,p_attribute20                =>  p_attribute20
      ,p_attribute21                =>  p_attribute21
      ,p_attribute22                =>  p_attribute22
      ,p_attribute23                =>  p_attribute23
      ,p_attribute24                =>  p_attribute24
      ,p_attribute25                =>  p_attribute25
      ,p_attribute26                =>  p_attribute26
      ,p_attribute27                =>  p_attribute27
      ,p_attribute28                =>  p_attribute28
      ,p_attribute29                =>  p_attribute29
      ,p_attribute30                =>  p_attribute30
      ,p_object_version_number      =>  l_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    IRC_AGENCY_VACANCIES_BK2.UPDATE_AGENCY_VACANCY_a
      (p_agency_vacancy_id          =>  p_agency_vacancy_id
      ,p_agency_id                  =>  p_agency_id
      ,p_vacancy_id                 =>  p_vacancy_id
      ,p_start_date                 =>  l_start_date
      ,p_end_date                   =>  l_end_date
      ,p_max_allowed_applicants     =>  p_max_allowed_applicants
      ,p_manage_applicants_allowed  =>  p_manage_applicants_allowed
      ,p_attribute_category         =>  p_attribute_category
      ,p_attribute1                 =>  p_attribute1
      ,p_attribute2                 =>  p_attribute2
      ,p_attribute3                 =>  p_attribute3
      ,p_attribute4                 =>  p_attribute4
      ,p_attribute5                 =>  p_attribute5
      ,p_attribute6                 =>  p_attribute6
      ,p_attribute7                 =>  p_attribute7
      ,p_attribute8                 =>  p_attribute8
      ,p_attribute9                 =>  p_attribute9
      ,p_attribute10                =>  p_attribute10
      ,p_attribute11                =>  p_attribute11
      ,p_attribute12                =>  p_attribute12
      ,p_attribute13                =>  p_attribute13
      ,p_attribute14                =>  p_attribute14
      ,p_attribute15                =>  p_attribute15
      ,p_attribute16                =>  p_attribute16
      ,p_attribute17                =>  p_attribute17
      ,p_attribute18                =>  p_attribute18
      ,p_attribute19                =>  p_attribute19
      ,p_attribute20                =>  p_attribute20
      ,p_attribute21                =>  p_attribute21
      ,p_attribute22                =>  p_attribute22
      ,p_attribute23                =>  p_attribute23
      ,p_attribute24                =>  p_attribute24
      ,p_attribute25                =>  p_attribute25
      ,p_attribute26                =>  p_attribute26
      ,p_attribute27                =>  p_attribute27
      ,p_attribute28                =>  p_attribute28
      ,p_attribute29                =>  p_attribute29
      ,p_attribute30                =>  p_attribute30
      ,p_object_version_number      => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_AGENCY_VACANCY'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_AGENCY_VACANCY;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_AGENCY_VACANCY;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_agency_vacancy;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_AGENCY_VACANCY >- -------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_agency_vacancy
  (p_validate                       in boolean  default false
  ,p_agency_vacancy_id              in number
  ,p_object_version_number          in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'DELETE_AGENCY_VACANCY';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_AGENCY_VACANCY;
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_AGENCY_VACANCIES_BK3.DELETE_AGENCY_VACANCY_b
      (p_agency_vacancy_id     =>  p_agency_vacancy_id
      ,p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_AGENCY_VACANCY'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_iav_del.del
      (p_agency_vacancy_id     =>  p_agency_vacancy_id
      ,p_object_version_number => p_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    IRC_AGENCY_VACANCIES_BK3.DELETE_AGENCY_VACANCY_a
      (p_agency_vacancy_id          =>  p_agency_vacancy_id
      ,p_object_version_number      =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_AGENCY_VACANCY'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_AGENCY_VACANCY;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_AGENCY_VACANCY;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_agency_vacancy;
--
end IRC_AGENCY_VACANCIES_API;

/
