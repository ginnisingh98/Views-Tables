--------------------------------------------------------
--  DDL for Package Body IRC_DEFAULT_POSTING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_DEFAULT_POSTING_API" as
/* $Header: iridpapi.pkb 120.0 2005/07/26 15:06:35 mbocutt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := ' irc_default_posting_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_default_posting >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_default_posting
(P_VALIDATE                   IN     BOOLEAN    default FALSE
,P_LANGUAGE_CODE              IN     VARCHAR2   default hr_api.userenv_lang
,P_POSITION_ID                IN     NUMBER     default NULL
,P_JOB_ID                     IN     NUMBER     default NULL
,P_ORGANIZATION_ID            IN     NUMBER     default NULL
,P_ORG_NAME                   IN     VARCHAR2   default NULL
,P_ORG_DESCRIPTION            IN     VARCHAR2   default NULL
,P_JOB_TITLE                  IN     VARCHAR2   default NULL
,P_BRIEF_DESCRIPTION          IN     VARCHAR2   default NULL
,P_DETAILED_DESCRIPTION       IN     VARCHAR2   default NULL
,P_JOB_REQUIREMENTS           IN     VARCHAR2   default NULL
,P_ADDITIONAL_DETAILS         IN     VARCHAR2   default NULL
,P_HOW_TO_APPLY               IN     VARCHAR2   default NULL
,P_IMAGE_URL                  IN     VARCHAR2   default NULL
,P_IMAGE_URL_ALT              IN     VARCHAR2   default NULL
,P_ATTRIBUTE_CATEGORY         IN     VARCHAR2   default NULL
,P_ATTRIBUTE1                 IN     VARCHAR2   default NULL
,P_ATTRIBUTE2                 IN     VARCHAR2   default NULL
,P_ATTRIBUTE3                 IN     VARCHAR2   default NULL
,P_ATTRIBUTE4                 IN     VARCHAR2   default NULL
,P_ATTRIBUTE5                 IN     VARCHAR2   default NULL
,P_ATTRIBUTE6                 IN     VARCHAR2   default NULL
,P_ATTRIBUTE7                 IN     VARCHAR2   default NULL
,P_ATTRIBUTE8                 IN     VARCHAR2   default NULL
,P_ATTRIBUTE9                 IN     VARCHAR2   default NULL
,P_ATTRIBUTE10                IN     VARCHAR2   default NULL
,P_ATTRIBUTE11                IN     VARCHAR2   default NULL
,P_ATTRIBUTE12                IN     VARCHAR2   default NULL
,P_ATTRIBUTE13                IN     VARCHAR2   default NULL
,P_ATTRIBUTE14                IN     VARCHAR2   default NULL
,P_ATTRIBUTE15                IN     VARCHAR2   default NULL
,P_ATTRIBUTE16                IN     VARCHAR2   default NULL
,P_ATTRIBUTE17                IN     VARCHAR2   default NULL
,P_ATTRIBUTE18                IN     VARCHAR2   default NULL
,P_ATTRIBUTE19                IN     VARCHAR2   default NULL
,P_ATTRIBUTE20                IN     VARCHAR2   default NULL
,P_ATTRIBUTE21                IN     VARCHAR2   default NULL
,P_ATTRIBUTE22                IN     VARCHAR2   default NULL
,P_ATTRIBUTE23                IN     VARCHAR2   default NULL
,P_ATTRIBUTE24                IN     VARCHAR2   default NULL
,P_ATTRIBUTE25                IN     VARCHAR2   default NULL
,P_ATTRIBUTE26                IN     VARCHAR2   default NULL
,P_ATTRIBUTE27                IN     VARCHAR2   default NULL
,P_ATTRIBUTE28                IN     VARCHAR2   default NULL
,P_ATTRIBUTE29                IN     VARCHAR2   default NULL
,P_ATTRIBUTE30                IN     VARCHAR2   default NULL
,P_DEFAULT_POSTING_ID            OUT NOCOPY NUMBER
,P_OBJECT_VERSION_NUMBER         OUT NOCOPY NUMBER
) is

  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'create_default_posting';
  l_object_version_number  number;
  l_language_code          varchar2(30);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_default_posting;
  --
  l_language_code:=p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_default_posting_bk1.create_default_posting_b
    (P_POSITION_ID                => P_POSITION_ID
    ,P_JOB_ID                     => P_JOB_ID
    ,P_ORGANIZATION_ID            => P_ORGANIZATION_ID
    ,P_LANGUAGE_CODE              => L_LANGUAGE_CODE
    ,P_ORG_NAME                   => P_ORG_NAME
    ,P_ORG_DESCRIPTION            => P_ORG_DESCRIPTION
    ,P_JOB_TITLE                  => P_JOB_TITLE
    ,P_BRIEF_DESCRIPTION          => P_BRIEF_DESCRIPTION
    ,P_DETAILED_DESCRIPTION       => P_DETAILED_DESCRIPTION
    ,P_JOB_REQUIREMENTS           => P_JOB_REQUIREMENTS
    ,P_ADDITIONAL_DETAILS         => P_ADDITIONAL_DETAILS
    ,P_HOW_TO_APPLY               => P_HOW_TO_APPLY
    ,P_IMAGE_URL                  => P_IMAGE_URL
    ,P_IMAGE_URL_ALT              => P_IMAGE_URL_ALT
    ,P_ATTRIBUTE_CATEGORY         => P_ATTRIBUTE_CATEGORY
    ,P_ATTRIBUTE1                 => P_ATTRIBUTE1
    ,P_ATTRIBUTE2                 => P_ATTRIBUTE2
    ,P_ATTRIBUTE3                 => P_ATTRIBUTE3
    ,P_ATTRIBUTE4                 => P_ATTRIBUTE4
    ,P_ATTRIBUTE5                 => P_ATTRIBUTE5
    ,P_ATTRIBUTE6                 => P_ATTRIBUTE6
    ,P_ATTRIBUTE7                 => P_ATTRIBUTE7
    ,P_ATTRIBUTE8                 => P_ATTRIBUTE8
    ,P_ATTRIBUTE9                 => P_ATTRIBUTE9
    ,P_ATTRIBUTE10                => P_ATTRIBUTE10
    ,P_ATTRIBUTE11                => P_ATTRIBUTE11
    ,P_ATTRIBUTE12                => P_ATTRIBUTE12
    ,P_ATTRIBUTE13                => P_ATTRIBUTE13
    ,P_ATTRIBUTE14                => P_ATTRIBUTE14
    ,P_ATTRIBUTE15                => P_ATTRIBUTE15
    ,P_ATTRIBUTE16                => P_ATTRIBUTE16
    ,P_ATTRIBUTE17                => P_ATTRIBUTE17
    ,P_ATTRIBUTE18                => P_ATTRIBUTE18
    ,P_ATTRIBUTE19                => P_ATTRIBUTE19
    ,P_ATTRIBUTE20                => P_ATTRIBUTE20
    ,P_ATTRIBUTE21                => P_ATTRIBUTE21
    ,P_ATTRIBUTE22                => P_ATTRIBUTE22
    ,P_ATTRIBUTE23                => P_ATTRIBUTE23
    ,P_ATTRIBUTE24                => P_ATTRIBUTE24
    ,P_ATTRIBUTE25                => P_ATTRIBUTE25
    ,P_ATTRIBUTE26                => P_ATTRIBUTE26
    ,P_ATTRIBUTE27                => P_ATTRIBUTE27
    ,P_ATTRIBUTE28                => P_ATTRIBUTE28
    ,P_ATTRIBUTE29                => P_ATTRIBUTE29
    ,P_ATTRIBUTE30                => P_ATTRIBUTE30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_default_posting'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  irc_idp_ins.ins
  (P_POSITION_ID              =>  P_POSITION_ID
  ,P_JOB_ID                   =>  P_JOB_ID
  ,P_ORGANIZATION_ID          =>  P_ORGANIZATION_ID
  ,P_ATTRIBUTE_CATEGORY       =>  P_ATTRIBUTE_CATEGORY
  ,P_ATTRIBUTE1               =>  P_ATTRIBUTE1
  ,P_ATTRIBUTE2               =>  P_ATTRIBUTE2
  ,P_ATTRIBUTE3               =>  P_ATTRIBUTE3
  ,P_ATTRIBUTE4               =>  P_ATTRIBUTE4
  ,P_ATTRIBUTE5               =>  P_ATTRIBUTE5
  ,P_ATTRIBUTE6               =>  P_ATTRIBUTE6
  ,P_ATTRIBUTE7               =>  P_ATTRIBUTE7
  ,P_ATTRIBUTE8               =>  P_ATTRIBUTE8
  ,P_ATTRIBUTE9               =>  P_ATTRIBUTE9
  ,P_ATTRIBUTE10              =>  P_ATTRIBUTE10
  ,P_ATTRIBUTE11              =>  P_ATTRIBUTE11
  ,P_ATTRIBUTE12              =>  P_ATTRIBUTE12
  ,P_ATTRIBUTE13              =>  P_ATTRIBUTE13
  ,P_ATTRIBUTE14              =>  P_ATTRIBUTE14
  ,P_ATTRIBUTE15              =>  P_ATTRIBUTE15
  ,P_ATTRIBUTE16              =>  P_ATTRIBUTE16
  ,P_ATTRIBUTE17              =>  P_ATTRIBUTE17
  ,P_ATTRIBUTE18              =>  P_ATTRIBUTE18
  ,P_ATTRIBUTE19              =>  P_ATTRIBUTE19
  ,P_ATTRIBUTE20              =>  P_ATTRIBUTE20
  ,P_ATTRIBUTE21              =>  P_ATTRIBUTE21
  ,P_ATTRIBUTE22              =>  P_ATTRIBUTE22
  ,P_ATTRIBUTE23              =>  P_ATTRIBUTE23
  ,P_ATTRIBUTE24              =>  P_ATTRIBUTE24
  ,P_ATTRIBUTE25              =>  P_ATTRIBUTE25
  ,P_ATTRIBUTE26              =>  P_ATTRIBUTE26
  ,P_ATTRIBUTE27              =>  P_ATTRIBUTE27
  ,P_ATTRIBUTE28              =>  P_ATTRIBUTE28
  ,P_ATTRIBUTE29              =>  P_ATTRIBUTE29
  ,P_ATTRIBUTE30              =>  P_ATTRIBUTE30
  ,P_DEFAULT_POSTING_ID       =>  P_DEFAULT_POSTING_ID
  ,P_OBJECT_VERSION_NUMBER    =>  L_OBJECT_VERSION_NUMBER);

  --
  -- Process Translation Logic
  --

  irc_idt_ins.ins_tl
  (P_DEFAULT_POSTING_ID       =>  P_DEFAULT_POSTING_ID
  ,P_LANGUAGE_CODE            =>  L_LANGUAGE_CODE
  ,P_ORG_NAME                 =>  P_ORG_NAME
  ,P_ORG_DESCRIPTION          =>  P_ORG_DESCRIPTION
  ,P_JOB_TITLE                =>  P_JOB_TITLE
  ,P_BRIEF_DESCRIPTION        =>  P_BRIEF_DESCRIPTION
  ,P_DETAILED_DESCRIPTION     =>  P_DETAILED_DESCRIPTION
  ,P_JOB_REQUIREMENTS         =>  P_JOB_REQUIREMENTS
  ,P_ADDITIONAL_DETAILS       =>  P_ADDITIONAL_DETAILS
  ,P_HOW_TO_APPLY             =>  P_HOW_TO_APPLY
  ,P_IMAGE_URL                =>  P_IMAGE_URL
  ,P_IMAGE_URL_ALT            =>  P_IMAGE_URL_ALT);
  --
  -- Call After Process User Hook
  --
  begin
    irc_default_posting_bk1.create_default_posting_a
    (P_POSITION_ID                => P_POSITION_ID
    ,P_JOB_ID                     => P_JOB_ID
    ,P_ORGANIZATION_ID            => P_ORGANIZATION_ID
    ,P_LANGUAGE_CODE              => L_LANGUAGE_CODE
    ,P_ORG_NAME                   => P_ORG_NAME
    ,P_ORG_DESCRIPTION            => P_ORG_DESCRIPTION
    ,P_JOB_TITLE                  => P_JOB_TITLE
    ,P_BRIEF_DESCRIPTION          => P_BRIEF_DESCRIPTION
    ,P_DETAILED_DESCRIPTION       => P_DETAILED_DESCRIPTION
    ,P_JOB_REQUIREMENTS           => P_JOB_REQUIREMENTS
    ,P_ADDITIONAL_DETAILS         => P_ADDITIONAL_DETAILS
    ,P_HOW_TO_APPLY               => P_HOW_TO_APPLY
    ,P_IMAGE_URL                  => P_IMAGE_URL
    ,P_IMAGE_URL_ALT              => P_IMAGE_URL_ALT
    ,P_ATTRIBUTE_CATEGORY         => P_ATTRIBUTE_CATEGORY
    ,P_ATTRIBUTE1                 => P_ATTRIBUTE1
    ,P_ATTRIBUTE2                 => P_ATTRIBUTE2
    ,P_ATTRIBUTE3                 => P_ATTRIBUTE3
    ,P_ATTRIBUTE4                 => P_ATTRIBUTE4
    ,P_ATTRIBUTE5                 => P_ATTRIBUTE5
    ,P_ATTRIBUTE6                 => P_ATTRIBUTE6
    ,P_ATTRIBUTE7                 => P_ATTRIBUTE7
    ,P_ATTRIBUTE8                 => P_ATTRIBUTE8
    ,P_ATTRIBUTE9                 => P_ATTRIBUTE9
    ,P_ATTRIBUTE10                => P_ATTRIBUTE10
    ,P_ATTRIBUTE11                => P_ATTRIBUTE11
    ,P_ATTRIBUTE12                => P_ATTRIBUTE12
    ,P_ATTRIBUTE13                => P_ATTRIBUTE13
    ,P_ATTRIBUTE14                => P_ATTRIBUTE14
    ,P_ATTRIBUTE15                => P_ATTRIBUTE15
    ,P_ATTRIBUTE16                => P_ATTRIBUTE16
    ,P_ATTRIBUTE17                => P_ATTRIBUTE17
    ,P_ATTRIBUTE18                => P_ATTRIBUTE18
    ,P_ATTRIBUTE19                => P_ATTRIBUTE19
    ,P_ATTRIBUTE20                => P_ATTRIBUTE20
    ,P_ATTRIBUTE21                => P_ATTRIBUTE21
    ,P_ATTRIBUTE22                => P_ATTRIBUTE22
    ,P_ATTRIBUTE23                => P_ATTRIBUTE23
    ,P_ATTRIBUTE24                => P_ATTRIBUTE24
    ,P_ATTRIBUTE25                => P_ATTRIBUTE25
    ,P_ATTRIBUTE26                => P_ATTRIBUTE26
    ,P_ATTRIBUTE27                => P_ATTRIBUTE27
    ,P_ATTRIBUTE28                => P_ATTRIBUTE28
    ,P_ATTRIBUTE29                => P_ATTRIBUTE29
    ,P_ATTRIBUTE30                => P_ATTRIBUTE30
    ,P_DEFAULT_POSTING_ID         => P_DEFAULT_POSTING_ID
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_default_posting'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_default_posting;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    P_DEFAULT_POSTING_ID     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_default_posting;
    --
    -- Reset IN OUT parameters and set OUT parameters
    p_object_version_number  := null;
    P_DEFAULT_POSTING_ID     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_default_posting;

--
-- ----------------------------------------------------------------------------
-- |----------------------< update_default_posting >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_default_posting
(P_VALIDATE                   IN  BOOLEAN    default FALSE
,P_LANGUAGE_CODE              IN  VARCHAR2   default hr_api.userenv_lang
,P_DEFAULT_POSTING_ID         IN  NUMBER
,P_POSITION_ID                IN  NUMBER     default hr_api.g_number
,P_JOB_ID                     IN  NUMBER     default hr_api.g_number
,P_ORGANIZATION_ID            IN  NUMBER     default hr_api.g_number
,P_ORG_NAME                   IN  VARCHAR2   default hr_api.g_varchar2
,P_ORG_DESCRIPTION            IN  VARCHAR2   default hr_api.g_varchar2
,P_JOB_TITLE                  IN  VARCHAR2   default hr_api.g_varchar2
,P_BRIEF_DESCRIPTION          IN  VARCHAR2   default hr_api.g_varchar2
,P_DETAILED_DESCRIPTION       IN  VARCHAR2   default hr_api.g_varchar2
,P_JOB_REQUIREMENTS           IN  VARCHAR2   default hr_api.g_varchar2
,P_ADDITIONAL_DETAILS         IN  VARCHAR2   default hr_api.g_varchar2
,P_HOW_TO_APPLY               IN  VARCHAR2   default hr_api.g_varchar2
,P_IMAGE_URL                  IN  VARCHAR2   default hr_api.g_varchar2
,P_IMAGE_URL_ALT              IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE_CATEGORY         IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE1                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE2                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE3                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE4                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE5                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE6                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE7                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE8                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE9                 IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE10                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE11                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE12                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE13                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE14                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE15                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE16                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE17                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE18                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE19                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE20                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE21                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE22                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE23                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE24                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE25                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE26                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE27                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE28                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE29                IN  VARCHAR2   default hr_api.g_varchar2
,P_ATTRIBUTE30                IN  VARCHAR2   default hr_api.g_varchar2
,P_OBJECT_VERSION_NUMBER      IN OUT NOCOPY NUMBER
) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_default_posting';
  l_object_version_number  number;
  l_language_code          varchar2(30);

begin
  hr_utility.set_location('Entering:'|| l_proc||p_object_version_number, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_default_posting;
  --
  l_language_code:=p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_default_posting_bk2.update_default_posting_b
    (P_DEFAULT_POSTING_ID         => P_DEFAULT_POSTING_ID
    ,P_POSITION_ID                => P_POSITION_ID
    ,P_JOB_ID                     => P_JOB_ID
    ,P_ORGANIZATION_ID            => P_ORGANIZATION_ID
    ,P_LANGUAGE_CODE              => L_LANGUAGE_CODE
    ,P_ORG_NAME                   => P_ORG_NAME
    ,P_ORG_DESCRIPTION            => P_ORG_DESCRIPTION
    ,P_JOB_TITLE                  => P_JOB_TITLE
    ,P_BRIEF_DESCRIPTION          => P_BRIEF_DESCRIPTION
    ,P_DETAILED_DESCRIPTION       => P_DETAILED_DESCRIPTION
    ,P_JOB_REQUIREMENTS           => P_JOB_REQUIREMENTS
    ,P_ADDITIONAL_DETAILS         => P_ADDITIONAL_DETAILS
    ,P_HOW_TO_APPLY               => P_HOW_TO_APPLY
    ,P_IMAGE_URL                  => P_IMAGE_URL
    ,P_IMAGE_URL_ALT              => P_IMAGE_URL_ALT
    ,P_ATTRIBUTE_CATEGORY         => P_ATTRIBUTE_CATEGORY
    ,P_ATTRIBUTE1                 => P_ATTRIBUTE1
    ,P_ATTRIBUTE2                 => P_ATTRIBUTE2
    ,P_ATTRIBUTE3                 => P_ATTRIBUTE3
    ,P_ATTRIBUTE4                 => P_ATTRIBUTE4
    ,P_ATTRIBUTE5                 => P_ATTRIBUTE5
    ,P_ATTRIBUTE6                 => P_ATTRIBUTE6
    ,P_ATTRIBUTE7                 => P_ATTRIBUTE7
    ,P_ATTRIBUTE8                 => P_ATTRIBUTE8
    ,P_ATTRIBUTE9                 => P_ATTRIBUTE9
    ,P_ATTRIBUTE10                => P_ATTRIBUTE10
    ,P_ATTRIBUTE11                => P_ATTRIBUTE11
    ,P_ATTRIBUTE12                => P_ATTRIBUTE12
    ,P_ATTRIBUTE13                => P_ATTRIBUTE13
    ,P_ATTRIBUTE14                => P_ATTRIBUTE14
    ,P_ATTRIBUTE15                => P_ATTRIBUTE15
    ,P_ATTRIBUTE16                => P_ATTRIBUTE16
    ,P_ATTRIBUTE17                => P_ATTRIBUTE17
    ,P_ATTRIBUTE18                => P_ATTRIBUTE18
    ,P_ATTRIBUTE19                => P_ATTRIBUTE19
    ,P_ATTRIBUTE20                => P_ATTRIBUTE20
    ,P_ATTRIBUTE21                => P_ATTRIBUTE21
    ,P_ATTRIBUTE22                => P_ATTRIBUTE22
    ,P_ATTRIBUTE23                => P_ATTRIBUTE23
    ,P_ATTRIBUTE24                => P_ATTRIBUTE24
    ,P_ATTRIBUTE25                => P_ATTRIBUTE25
    ,P_ATTRIBUTE26                => P_ATTRIBUTE26
    ,P_ATTRIBUTE27                => P_ATTRIBUTE27
    ,P_ATTRIBUTE28                => P_ATTRIBUTE28
    ,P_ATTRIBUTE29                => P_ATTRIBUTE29
    ,P_ATTRIBUTE30                => P_ATTRIBUTE30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_default_posting'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  -- None

  --
  -- Process Logic
  --
     l_object_version_number  := p_object_version_number;

  irc_idp_upd.upd
  (P_DEFAULT_POSTING_ID       =>  P_DEFAULT_POSTING_ID
  ,P_OBJECT_VERSION_NUMBER    =>  l_OBJECT_VERSION_NUMBER
  ,P_POSITION_ID              =>  P_POSITION_ID
  ,P_JOB_ID                   =>  P_JOB_ID
  ,P_ORGANIZATION_ID          =>  P_ORGANIZATION_ID
  ,P_ATTRIBUTE_CATEGORY       =>  P_ATTRIBUTE_CATEGORY
  ,P_ATTRIBUTE1               =>  P_ATTRIBUTE1
  ,P_ATTRIBUTE2               =>  P_ATTRIBUTE2
  ,P_ATTRIBUTE3               =>  P_ATTRIBUTE3
  ,P_ATTRIBUTE4               =>  P_ATTRIBUTE4
  ,P_ATTRIBUTE5               =>  P_ATTRIBUTE5
  ,P_ATTRIBUTE6               =>  P_ATTRIBUTE6
  ,P_ATTRIBUTE7               =>  P_ATTRIBUTE7
  ,P_ATTRIBUTE8               =>  P_ATTRIBUTE8
  ,P_ATTRIBUTE9               =>  P_ATTRIBUTE9
  ,P_ATTRIBUTE10              =>  P_ATTRIBUTE10
  ,P_ATTRIBUTE11              =>  P_ATTRIBUTE11
  ,P_ATTRIBUTE12              =>  P_ATTRIBUTE12
  ,P_ATTRIBUTE13              =>  P_ATTRIBUTE13
  ,P_ATTRIBUTE14              =>  P_ATTRIBUTE14
  ,P_ATTRIBUTE15              =>  P_ATTRIBUTE15
  ,P_ATTRIBUTE16              =>  P_ATTRIBUTE16
  ,P_ATTRIBUTE17              =>  P_ATTRIBUTE17
  ,P_ATTRIBUTE18              =>  P_ATTRIBUTE18
  ,P_ATTRIBUTE19              =>  P_ATTRIBUTE19
  ,P_ATTRIBUTE20              =>  P_ATTRIBUTE20
  ,P_ATTRIBUTE21              =>  P_ATTRIBUTE21
  ,P_ATTRIBUTE22              =>  P_ATTRIBUTE22
  ,P_ATTRIBUTE23              =>  P_ATTRIBUTE23
  ,P_ATTRIBUTE24              =>  P_ATTRIBUTE24
  ,P_ATTRIBUTE25              =>  P_ATTRIBUTE25
  ,P_ATTRIBUTE26              =>  P_ATTRIBUTE26
  ,P_ATTRIBUTE27              =>  P_ATTRIBUTE27
  ,P_ATTRIBUTE28              =>  P_ATTRIBUTE28
  ,P_ATTRIBUTE29              =>  P_ATTRIBUTE29
  ,P_ATTRIBUTE30              =>  P_ATTRIBUTE30
  );

  --
  -- Process Translation Logic
  --

  irc_idt_upd.upd_tl
  (P_DEFAULT_POSTING_ID       =>  P_DEFAULT_POSTING_ID
  ,P_LANGUAGE_CODE            =>  L_LANGUAGE_CODE
  ,P_ORG_NAME                 =>  P_ORG_NAME
  ,P_ORG_DESCRIPTION          =>  P_ORG_DESCRIPTION
  ,P_JOB_TITLE                =>  P_JOB_TITLE
  ,P_BRIEF_DESCRIPTION        =>  P_BRIEF_DESCRIPTION
  ,P_DETAILED_DESCRIPTION     =>  P_DETAILED_DESCRIPTION
  ,P_JOB_REQUIREMENTS         =>  P_JOB_REQUIREMENTS
  ,P_ADDITIONAL_DETAILS       =>  P_ADDITIONAL_DETAILS
  ,P_HOW_TO_APPLY             =>  P_HOW_TO_APPLY
  ,P_IMAGE_URL                =>  P_IMAGE_URL
  ,P_IMAGE_URL_ALT            =>  P_IMAGE_URL_ALT
  );

  --
  -- Call After Process User Hook
  --
  begin
     irc_default_posting_bk2.update_default_posting_a
    (P_POSITION_ID                => P_POSITION_ID
    ,P_JOB_ID                     => P_JOB_ID
    ,P_ORGANIZATION_ID            => P_ORGANIZATION_ID
    ,P_LANGUAGE_CODE              => L_LANGUAGE_CODE
    ,P_ORG_NAME                   => P_ORG_NAME
    ,P_ORG_DESCRIPTION            => P_ORG_DESCRIPTION
    ,P_JOB_TITLE                  => P_JOB_TITLE
    ,P_BRIEF_DESCRIPTION          => P_BRIEF_DESCRIPTION
    ,P_DETAILED_DESCRIPTION       => P_DETAILED_DESCRIPTION
    ,P_JOB_REQUIREMENTS           => P_JOB_REQUIREMENTS
    ,P_ADDITIONAL_DETAILS         => P_ADDITIONAL_DETAILS
    ,P_HOW_TO_APPLY               => P_HOW_TO_APPLY
    ,P_IMAGE_URL                  => P_IMAGE_URL
    ,P_IMAGE_URL_ALT              => P_IMAGE_URL_ALT
    ,P_ATTRIBUTE_CATEGORY         => P_ATTRIBUTE_CATEGORY
    ,P_ATTRIBUTE1                 => P_ATTRIBUTE1
    ,P_ATTRIBUTE2                 => P_ATTRIBUTE2
    ,P_ATTRIBUTE3                 => P_ATTRIBUTE3
    ,P_ATTRIBUTE4                 => P_ATTRIBUTE4
    ,P_ATTRIBUTE5                 => P_ATTRIBUTE5
    ,P_ATTRIBUTE6                 => P_ATTRIBUTE6
    ,P_ATTRIBUTE7                 => P_ATTRIBUTE7
    ,P_ATTRIBUTE8                 => P_ATTRIBUTE8
    ,P_ATTRIBUTE9                 => P_ATTRIBUTE9
    ,P_ATTRIBUTE10                => P_ATTRIBUTE10
    ,P_ATTRIBUTE11                => P_ATTRIBUTE11
    ,P_ATTRIBUTE12                => P_ATTRIBUTE12
    ,P_ATTRIBUTE13                => P_ATTRIBUTE13
    ,P_ATTRIBUTE14                => P_ATTRIBUTE14
    ,P_ATTRIBUTE15                => P_ATTRIBUTE15
    ,P_ATTRIBUTE16                => P_ATTRIBUTE16
    ,P_ATTRIBUTE17                => P_ATTRIBUTE17
    ,P_ATTRIBUTE18                => P_ATTRIBUTE18
    ,P_ATTRIBUTE19                => P_ATTRIBUTE19
    ,P_ATTRIBUTE20                => P_ATTRIBUTE20
    ,P_ATTRIBUTE21                => P_ATTRIBUTE21
    ,P_ATTRIBUTE22                => P_ATTRIBUTE22
    ,P_ATTRIBUTE23                => P_ATTRIBUTE23
    ,P_ATTRIBUTE24                => P_ATTRIBUTE24
    ,P_ATTRIBUTE25                => P_ATTRIBUTE25
    ,P_ATTRIBUTE26                => P_ATTRIBUTE26
    ,P_ATTRIBUTE27                => P_ATTRIBUTE27
    ,P_ATTRIBUTE28                => P_ATTRIBUTE28
    ,P_ATTRIBUTE29                => P_ATTRIBUTE29
    ,P_ATTRIBUTE30                => P_ATTRIBUTE30
    ,P_DEFAULT_POSTING_ID         => P_DEFAULT_POSTING_ID
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_default_posting'
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
    p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc||p_object_version_number, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_default_posting;
    --
    --
    p_object_version_number  := l_object_version_number;
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
    rollback to update_default_posting;
    --
    p_object_version_number  := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_default_posting;

--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_default_posting >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_default_posting
  (P_VALIDATE                  in       BOOLEAN  default false
  ,P_DEFAULT_POSTING_ID        in       NUMBER
  ,P_OBJECT_VERSION_NUMBER     in       NUMBER
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'delete_default_posting';
  l_object_version_number  number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_default_posting;

  --
  -- Call Before Process User Hook
  --
  begin
    irc_default_posting_bk3.delete_default_posting_b
    (P_DEFAULT_POSTING_ID      => P_DEFAULT_POSTING_ID
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_default_posting'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Validation in addition to Row Handlers
  --

  -- NONE

  --
  -- Process Logic
  --
     irc_idp_shd.lck
    (P_DEFAULT_POSTING_ID      => P_DEFAULT_POSTING_ID
    ,P_OBJECT_VERSION_NUMBER   =>  P_OBJECT_VERSION_NUMBER
    );
  --
  -- Process Translation Logic
  --
    irc_idt_del.del_tl
    (P_DEFAULT_POSTING_ID      => P_DEFAULT_POSTING_ID
    );
    irc_idp_del.del
    (P_DEFAULT_POSTING_ID      => P_DEFAULT_POSTING_ID
    ,P_OBJECT_VERSION_NUMBER   =>  P_OBJECT_VERSION_NUMBER
    );

  --
  -- Call After Process User Hook
  --
begin
    irc_default_posting_bk3.delete_default_posting_a
    (P_DEFAULT_POSTING_ID      => P_DEFAULT_POSTING_ID
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_default_posting'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_default_posting;
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
    rollback to delete_default_posting;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_default_posting;

--
end irc_default_posting_api;

/
