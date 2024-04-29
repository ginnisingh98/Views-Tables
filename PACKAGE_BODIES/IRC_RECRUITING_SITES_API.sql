--------------------------------------------------------
--  DDL for Package Body IRC_RECRUITING_SITES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_RECRUITING_SITES_API" as
/* $Header: irrseapi.pkb 120.1.12010000.2 2010/01/18 14:33:48 mkjayara ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'IRC_RECRUITING_SITES_API.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< CREATE_RECRUITING_SITE >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_RECRUITING_SITE
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2   default hr_api.userenv_lang
  ,p_effective_date                in     date
  ,p_site_name                     in     varchar2
  ,p_date_from                     in date default null
  ,p_date_to                       in date default null
  ,p_posting_username              in varchar2 default null
  ,p_posting_password              in varchar2 default null
  ,p_internal                      in     varchar2  default 'N'
  ,p_external                      in     varchar2  default 'N'
  ,p_third_party                   in     varchar2  default 'Y'
  ,p_redirection_url               in     varchar2 default null
  ,p_posting_url                   in     varchar2 default null
  ,p_posting_cost                  in     number   default null
  ,p_posting_cost_period           in     varchar2 default null
  ,p_posting_cost_currency         in     varchar2 default null
  ,p_stylesheet           in     varchar2 default null
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
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_recruiting_site_id               out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_posting_impl_class            in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package||'CREATE_RECRUITING_SITE';
  l_object_version_number number;
  l_recruiting_site_id    number;
  l_effective_date        date;
  l_language_code          varchar2(30);

begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_RECRUITING_SITE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- Call Before Process User Hook
  --
  begin
  hr_utility.set_location(l_proc, 20);
    IRC_RECRUITING_SITES_BK1.CREATE_RECRUITING_SITE_B
      (p_effective_date                => p_effective_date
      ,p_language_code                 => l_language_code
      ,p_site_name                     => p_site_name
      ,p_date_from                     => p_date_from
      ,p_date_to                       => p_date_to
      ,p_posting_username              => p_posting_username
      ,p_posting_password              => p_posting_password
      ,p_internal                      => p_internal
      ,p_external                      => p_external
      ,p_third_party                   => p_third_party
      ,p_redirection_url               => p_redirection_url
      ,p_posting_url                   => p_posting_url
      ,p_posting_cost                  => p_posting_cost
      ,p_posting_cost_period           => p_posting_cost_period
      ,p_posting_cost_currency         => p_posting_cost_currency
      ,p_stylesheet           => p_stylesheet
      ,p_attribute_category => p_attribute_category
      ,p_attribute1         => p_attribute1
      ,p_attribute2         => p_attribute2
      ,p_attribute3         => p_attribute3
      ,p_attribute4         => p_attribute4
      ,p_attribute5         => p_attribute5
      ,p_attribute6         => p_attribute6
      ,p_attribute7         => p_attribute7
      ,p_attribute8         => p_attribute8
      ,p_attribute9         => p_attribute9
      ,p_attribute10        => p_attribute10
      ,p_attribute11        => p_attribute11
      ,p_attribute12        => p_attribute12
      ,p_attribute13        => p_attribute13
      ,p_attribute14        => p_attribute14
      ,p_attribute15        => p_attribute15
      ,p_attribute16        => p_attribute16
      ,p_attribute17        => p_attribute17
      ,p_attribute18        => p_attribute18
      ,p_attribute19        => p_attribute19
      ,p_attribute20        => p_attribute20
      ,p_attribute21        => p_attribute21
      ,p_attribute22        => p_attribute22
      ,p_attribute23        => p_attribute23
      ,p_attribute24        => p_attribute24
      ,p_attribute25        => p_attribute25
      ,p_attribute26        => p_attribute26
      ,p_attribute27        => p_attribute27
      ,p_attribute28        => p_attribute28
      ,p_attribute29        => p_attribute29
      ,p_attribute30        => p_attribute30
      ,p_posting_impl_class => p_posting_impl_class
      );
  hr_utility.set_location(l_proc, 30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_RECRUITING_SITE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  hr_utility.set_location(l_proc, 40);
  irc_rse_ins.ins
  (p_effective_date                => l_effective_date
  ,p_date_from                     => p_date_from
  ,p_date_to                       => p_date_to
  ,p_posting_username              => p_posting_username
  ,p_internal                      => p_internal
  ,p_external                      => p_external
  ,p_third_party                   => p_third_party
  ,p_posting_cost                  => p_posting_cost
  ,p_posting_cost_period           => p_posting_cost_period
  ,p_posting_cost_currency         => p_posting_cost_currency
  ,p_stylesheet                    => p_stylesheet
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
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_recruiting_site_id            => l_recruiting_site_id
  ,p_object_version_number         => l_object_version_number
  ,p_internal_name                 => p_site_name
  ,p_posting_impl_class            => p_posting_impl_class
  );
  --
  irc_irt_ins.ins_tl
  (p_recruiting_site_id       => l_recruiting_site_id
  ,p_language_code            => l_language_code
  ,p_site_name                => p_site_name
  ,p_redirection_url          => p_redirection_url
  ,p_posting_url              => p_posting_url
  );
  --
  --save the password to the encrypted store
  if (p_posting_password is not null) then
    fnd_vault.put('IRC_SITE',l_recruiting_site_id,p_posting_password);
  end if;

  hr_utility.set_location(l_proc, 50);
  -- Call After Process User Hook
  --
  begin
    IRC_RECRUITING_SITES_BK1.CREATE_RECRUITING_SITE_A
      (p_effective_date       => l_effective_date
      ,p_language_code        => l_language_code
      ,p_site_name            => p_site_name
      ,p_date_from            => p_date_from
      ,p_date_to              => p_date_to
      ,p_posting_username     => p_posting_username
      ,p_posting_password     => p_posting_password
      ,p_internal             => p_internal
      ,p_external             => p_external
      ,p_third_party          => p_third_party
      ,p_redirection_url      => p_redirection_url
      ,p_posting_url          => p_posting_url
      ,p_posting_cost         => p_posting_cost
      ,p_posting_cost_period  => p_posting_cost_period
      ,p_posting_cost_currency=> p_posting_cost_currency
      ,p_stylesheet  => p_stylesheet
      ,p_object_version_number=> l_object_version_number
      ,p_attribute_category   => p_attribute_category
      ,p_attribute1           => p_attribute1
      ,p_attribute2           => p_attribute2
      ,p_attribute3           => p_attribute3
      ,p_attribute4           => p_attribute4
      ,p_attribute5           => p_attribute5
      ,p_attribute6           => p_attribute6
      ,p_attribute7           => p_attribute7
      ,p_attribute8           => p_attribute8
      ,p_attribute9           => p_attribute9
      ,p_attribute10          => p_attribute10
      ,p_attribute11          => p_attribute11
      ,p_attribute12          => p_attribute12
      ,p_attribute13          => p_attribute13
      ,p_attribute14          => p_attribute14
      ,p_attribute15          => p_attribute15
      ,p_attribute16          => p_attribute16
      ,p_attribute17          => p_attribute17
      ,p_attribute18          => p_attribute18
      ,p_attribute19          => p_attribute19
      ,p_attribute20          => p_attribute20
      ,p_attribute21          => p_attribute21
      ,p_attribute22          => p_attribute22
      ,p_attribute23          => p_attribute23
      ,p_attribute24          => p_attribute24
      ,p_attribute25          => p_attribute25
      ,p_attribute26          => p_attribute26
      ,p_attribute27          => p_attribute27
      ,p_attribute28          => p_attribute28
      ,p_attribute29          => p_attribute29
      ,p_attribute30          => p_attribute30
      ,p_recruiting_site_id   => l_recruiting_site_id
      ,p_posting_impl_class   => p_posting_impl_class
      );
  hr_utility.set_location(l_proc, 60);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_RECRUITING_SITE'
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
  p_object_version_number  := l_object_version_number;
  p_recruiting_site_id  := l_recruiting_site_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_RECRUITING_SITE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_recruiting_site_id    := null;
    p_object_version_number := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  := null;
    rollback to CREATE_RECRUITING_SITE;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_recruiting_site_id    := null;
    p_object_version_number := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_RECRUITING_SITE;
--
-- ----------------------------------------------------------------------------
-- |---------------------< UPDATE_RECRUITING_SITE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_RECRUITING_SITE
  (p_recruiting_site_id            in     number
  ,p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_effective_date                in     date
  ,p_site_name                     in     varchar2 default hr_api.g_varchar2
  ,p_date_from                     in     date  default hr_api.g_date
  ,p_date_to                       in     date  default hr_api.g_date
  ,p_posting_username              in     varchar2  default hr_api.g_varchar2
  ,p_posting_password              in     varchar2  default hr_api.g_varchar2
  ,p_internal                      in     varchar2 default hr_api.g_varchar2
  ,p_external                      in     varchar2 default hr_api.g_varchar2
  ,p_third_party                   in     varchar2 default hr_api.g_varchar2
  ,p_redirection_url               in     varchar2 default hr_api.g_varchar2
  ,p_posting_url                   in     varchar2 default hr_api.g_varchar2
  ,p_posting_cost                  in     number   default hr_api.g_number
  ,p_posting_cost_period           in     varchar2 default hr_api.g_varchar2
  ,p_posting_cost_currency         in     varchar2 default hr_api.g_varchar2
  ,p_stylesheet           in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_posting_impl_class            in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package||'UPDATE_RECRUITING_SITE';
  --
  l_effective_date          date;
  l_language_code           varchar2(30);
  l_object_version_number number := p_object_version_number;
BEGIN
 --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_RECRUITING_SITE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  l_language_code:=p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- Call Before Process User Hook
  --
    begin
    IRC_RECRUITING_SITES_BK2.UPDATE_RECRUITING_SITE_B
      (p_recruiting_site_id => p_recruiting_site_id
      ,p_effective_date     => l_effective_date
      ,p_language_code      => l_language_code
      ,p_site_name            => p_site_name
      ,p_date_from            => p_date_from
      ,p_date_to              => p_date_to
      ,p_posting_username     => p_posting_username
      ,p_posting_password     => p_posting_password
      ,p_internal             => p_internal
      ,p_external             => p_external
      ,p_third_party          => p_third_party
      ,p_redirection_url      => p_redirection_url
      ,p_posting_url          => p_posting_url
      ,p_posting_cost         => p_posting_cost
      ,p_posting_cost_period  => p_posting_cost_period
      ,p_posting_cost_currency=> p_posting_cost_currency
      ,p_stylesheet  => p_stylesheet
      ,p_object_version_number=> l_object_version_number
      ,p_attribute_category => p_attribute_category
      ,p_attribute1         => p_attribute1
      ,p_attribute2         => p_attribute2
      ,p_attribute3         => p_attribute3
      ,p_attribute4         => p_attribute4
      ,p_attribute5         => p_attribute5
      ,p_attribute6         => p_attribute6
      ,p_attribute7         => p_attribute7
      ,p_attribute8         => p_attribute8
      ,p_attribute9         => p_attribute9
      ,p_attribute10        => p_attribute10
      ,p_attribute11        => p_attribute11
      ,p_attribute12        => p_attribute12
      ,p_attribute13        => p_attribute13
      ,p_attribute14        => p_attribute14
      ,p_attribute15        => p_attribute15
      ,p_attribute16        => p_attribute16
      ,p_attribute17        => p_attribute17
      ,p_attribute18        => p_attribute18
      ,p_attribute19        => p_attribute19
      ,p_attribute20        => p_attribute20
      ,p_attribute21        => p_attribute21
      ,p_attribute22        => p_attribute22
      ,p_attribute23        => p_attribute23
      ,p_attribute24        => p_attribute24
      ,p_attribute25        => p_attribute25
      ,p_attribute26        => p_attribute26
      ,p_attribute27        => p_attribute27
      ,p_attribute28        => p_attribute28
      ,p_attribute29        => p_attribute29
      ,p_attribute30        => p_attribute30
      ,p_posting_impl_class => p_posting_impl_class
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_RECRUITING_SITE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  --
  -- Process Logic
  --
    --
  irc_rse_upd.upd
  (p_effective_date               => l_effective_date
  ,p_recruiting_site_id           => p_recruiting_site_id
  ,p_object_version_number        => l_object_version_number
  ,p_date_from                    => p_date_from
  ,p_date_to                      => p_date_to
  ,p_posting_username             => p_posting_username
  ,p_internal                     => p_internal
  ,p_external                     => p_external
  ,p_third_party                  => p_third_party
  ,p_posting_cost                 => p_posting_cost
  ,p_posting_cost_period          => p_posting_cost_period
  ,p_posting_cost_currency        => p_posting_cost_currency
  ,p_stylesheet                   => p_stylesheet
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
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_internal_name                 => p_site_name
  ,p_posting_impl_class            => p_posting_impl_class
  );
 --
 --
  -- Process Translation Logic
  --

  irc_irt_upd.upd_tl
  (p_recruiting_site_id       => p_recruiting_site_id
  ,p_language_code            => l_language_code
  ,p_site_name                => p_site_name
  ,p_redirection_url          => p_redirection_url
  ,p_posting_url              => p_posting_url
  );
  --
  --save the password to the encrypted store
  if (p_posting_password <>hr_api.g_varchar2) then
    fnd_vault.put('IRC_SITE',p_recruiting_site_id,p_posting_password);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    IRC_RECRUITING_SITES_BK2.UPDATE_RECRUITING_SITE_A
      (p_recruiting_site_id => p_recruiting_site_id
      ,p_effective_date     => l_effective_date
      ,p_language_code      => l_language_code
      ,p_site_name            => p_site_name
      ,p_date_from            => p_date_from
      ,p_date_to              => p_date_to
      ,p_posting_username     => p_posting_username
      ,p_posting_password     => p_posting_password
      ,p_internal             => p_internal
      ,p_external             => p_external
      ,p_third_party          => p_third_party
      ,p_redirection_url      => p_redirection_url
      ,p_posting_url          => p_posting_url
      ,p_posting_cost         => p_posting_cost
      ,p_posting_cost_period  => p_posting_cost_period
      ,p_posting_cost_currency=> p_posting_cost_currency
      ,p_stylesheet           => p_stylesheet
      ,p_object_version_number=> l_object_version_number
      ,p_attribute_category   => p_attribute_category
      ,p_attribute1           => p_attribute1
      ,p_attribute2           => p_attribute2
      ,p_attribute3           => p_attribute3
      ,p_attribute4           => p_attribute4
      ,p_attribute5           => p_attribute5
      ,p_attribute6           => p_attribute6
      ,p_attribute7           => p_attribute7
      ,p_attribute8           => p_attribute8
      ,p_attribute9           => p_attribute9
      ,p_attribute10          => p_attribute10
      ,p_attribute11          => p_attribute11
      ,p_attribute12          => p_attribute12
      ,p_attribute13          => p_attribute13
      ,p_attribute14          => p_attribute14
      ,p_attribute15          => p_attribute15
      ,p_attribute16          => p_attribute16
      ,p_attribute17          => p_attribute17
      ,p_attribute18          => p_attribute18
      ,p_attribute19          => p_attribute19
      ,p_attribute20          => p_attribute20
      ,p_attribute21          => p_attribute21
      ,p_attribute22          => p_attribute22
      ,p_attribute23          => p_attribute23
      ,p_attribute24          => p_attribute24
      ,p_attribute25          => p_attribute25
      ,p_attribute26          => p_attribute26
      ,p_attribute27          => p_attribute27
      ,p_attribute28          => p_attribute28
      ,p_attribute29          => p_attribute29
      ,p_attribute30          => p_attribute30
      ,p_posting_impl_class   => p_posting_impl_class
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_RECRUITING_SITE'
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
    rollback to UPDATE_RECRUITING_SITE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_RECRUITING_SITE;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_RECRUITING_SITE;
--
-- ----------------------------------------------------------------------------
-- |---------------------< DELETE_RECRUITING_SITE >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_RECRUITING_SITE
  (p_validate                      in     boolean  default false
  ,p_recruiting_site_id            in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package||'DELETE_RECRUITING_SITE';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_RECRUITING_SITE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_RECRUITING_SITES_BK3.DELETE_RECRUITING_SITE_B
      (p_recruiting_site_id           => p_recruiting_site_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_RECRUITING_SITE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  --
  -- Process Translation Logic
  --
  irc_rse_shd.lck
  (p_recruiting_site_id      => p_recruiting_site_id
  ,p_object_version_number   => p_object_version_number
  );
  --
  irc_irt_del.del_tl
  (p_recruiting_site_id      => p_recruiting_site_id
  );

  irc_rse_del.del
  (p_recruiting_site_id            => p_recruiting_site_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  -- delete the password
  --
  if (fnd_vault.tst('IRC_SITE',p_recruiting_site_id)=true) then
    fnd_vault.del('IRC_SITE',p_recruiting_site_id);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    IRC_RECRUITING_SITES_BK3.DELETE_RECRUITING_SITE_A
      (p_recruiting_site_id            => p_recruiting_site_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_RECRUITING_SITE'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_RECRUITING_SITE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_RECRUITING_SITE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_RECRUITING_SITE;
--
end IRC_RECRUITING_SITES_API;

/
