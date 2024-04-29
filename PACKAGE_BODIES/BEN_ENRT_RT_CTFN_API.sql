--------------------------------------------------------
--  DDL for Package Body BEN_ENRT_RT_CTFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENRT_RT_CTFN_API" as
/* $Header: beercapi.pkb 115.2 2002/12/16 09:36:44 hnarayan noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_enrt_rt_ctfn_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_enrt_rt_ctfn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_enrt_rt_ctfn
  (p_validate                       in  boolean   default false
  ,p_enrt_rt_ctfn_id             out nocopy number
  ,p_enrt_ctfn_typ_cd               in  varchar2  default null
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_enrt_rt_id         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_erc_attribute_category         in  varchar2  default null
  ,p_erc_attribute1                 in  varchar2  default null
  ,p_erc_attribute2                 in  varchar2  default null
  ,p_erc_attribute3                 in  varchar2  default null
  ,p_erc_attribute4                 in  varchar2  default null
  ,p_erc_attribute5                 in  varchar2  default null
  ,p_erc_attribute6                 in  varchar2  default null
  ,p_erc_attribute7                 in  varchar2  default null
  ,p_erc_attribute8                 in  varchar2  default null
  ,p_erc_attribute9                 in  varchar2  default null
  ,p_erc_attribute10                in  varchar2  default null
  ,p_erc_attribute11                in  varchar2  default null
  ,p_erc_attribute12                in  varchar2  default null
  ,p_erc_attribute13                in  varchar2  default null
  ,p_erc_attribute14                in  varchar2  default null
  ,p_erc_attribute15                in  varchar2  default null
  ,p_erc_attribute16                in  varchar2  default null
  ,p_erc_attribute17                in  varchar2  default null
  ,p_erc_attribute18                in  varchar2  default null
  ,p_erc_attribute19                in  varchar2  default null
  ,p_erc_attribute20                in  varchar2  default null
  ,p_erc_attribute21                in  varchar2  default null
  ,p_erc_attribute22                in  varchar2  default null
  ,p_erc_attribute23                in  varchar2  default null
  ,p_erc_attribute24                in  varchar2  default null
  ,p_erc_attribute25                in  varchar2  default null
  ,p_erc_attribute26                in  varchar2  default null
  ,p_erc_attribute27                in  varchar2  default null
  ,p_erc_attribute28                in  varchar2  default null
  ,p_erc_attribute29                in  varchar2  default null
  ,p_erc_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_enrt_rt_ctfn_id ben_enrt_rt_ctfn.enrt_rt_ctfn_id%TYPE;
  l_proc varchar2(72) := g_package||'create_enrt_rt_ctfn';
  l_object_version_number ben_enrt_rt_ctfn.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_enrt_rt_ctfn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_enrt_rt_ctfn
    --
    ben_enrt_rt_ctfn_bk1.create_enrt_rt_ctfn_b
      (
       p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_rt_id         =>  p_enrt_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_erc_attribute_category         =>  p_erc_attribute_category
      ,p_erc_attribute1                 =>  p_erc_attribute1
      ,p_erc_attribute2                 =>  p_erc_attribute2
      ,p_erc_attribute3                 =>  p_erc_attribute3
      ,p_erc_attribute4                 =>  p_erc_attribute4
      ,p_erc_attribute5                 =>  p_erc_attribute5
      ,p_erc_attribute6                 =>  p_erc_attribute6
      ,p_erc_attribute7                 =>  p_erc_attribute7
      ,p_erc_attribute8                 =>  p_erc_attribute8
      ,p_erc_attribute9                 =>  p_erc_attribute9
      ,p_erc_attribute10                =>  p_erc_attribute10
      ,p_erc_attribute11                =>  p_erc_attribute11
      ,p_erc_attribute12                =>  p_erc_attribute12
      ,p_erc_attribute13                =>  p_erc_attribute13
      ,p_erc_attribute14                =>  p_erc_attribute14
      ,p_erc_attribute15                =>  p_erc_attribute15
      ,p_erc_attribute16                =>  p_erc_attribute16
      ,p_erc_attribute17                =>  p_erc_attribute17
      ,p_erc_attribute18                =>  p_erc_attribute18
      ,p_erc_attribute19                =>  p_erc_attribute19
      ,p_erc_attribute20                =>  p_erc_attribute20
      ,p_erc_attribute21                =>  p_erc_attribute21
      ,p_erc_attribute22                =>  p_erc_attribute22
      ,p_erc_attribute23                =>  p_erc_attribute23
      ,p_erc_attribute24                =>  p_erc_attribute24
      ,p_erc_attribute25                =>  p_erc_attribute25
      ,p_erc_attribute26                =>  p_erc_attribute26
      ,p_erc_attribute27                =>  p_erc_attribute27
      ,p_erc_attribute28                =>  p_erc_attribute28
      ,p_erc_attribute29                =>  p_erc_attribute29
      ,p_erc_attribute30                =>  p_erc_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_enrt_rt_ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_enrt_rt_ctfn
    --
  end;
  --
  ben_erc_ins.ins
    (
     p_enrt_rt_ctfn_id            => l_enrt_rt_ctfn_id
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_rqd_flag                      => p_rqd_flag
    ,p_enrt_rt_id        => p_enrt_rt_id
    ,p_business_group_id             => p_business_group_id
    ,p_erc_attribute_category        => p_erc_attribute_category
    ,p_erc_attribute1                => p_erc_attribute1
    ,p_erc_attribute2                => p_erc_attribute2
    ,p_erc_attribute3                => p_erc_attribute3
    ,p_erc_attribute4                => p_erc_attribute4
    ,p_erc_attribute5                => p_erc_attribute5
    ,p_erc_attribute6                => p_erc_attribute6
    ,p_erc_attribute7                => p_erc_attribute7
    ,p_erc_attribute8                => p_erc_attribute8
    ,p_erc_attribute9                => p_erc_attribute9
    ,p_erc_attribute10               => p_erc_attribute10
    ,p_erc_attribute11               => p_erc_attribute11
    ,p_erc_attribute12               => p_erc_attribute12
    ,p_erc_attribute13               => p_erc_attribute13
    ,p_erc_attribute14               => p_erc_attribute14
    ,p_erc_attribute15               => p_erc_attribute15
    ,p_erc_attribute16               => p_erc_attribute16
    ,p_erc_attribute17               => p_erc_attribute17
    ,p_erc_attribute18               => p_erc_attribute18
    ,p_erc_attribute19               => p_erc_attribute19
    ,p_erc_attribute20               => p_erc_attribute20
    ,p_erc_attribute21               => p_erc_attribute21
    ,p_erc_attribute22               => p_erc_attribute22
    ,p_erc_attribute23               => p_erc_attribute23
    ,p_erc_attribute24               => p_erc_attribute24
    ,p_erc_attribute25               => p_erc_attribute25
    ,p_erc_attribute26               => p_erc_attribute26
    ,p_erc_attribute27               => p_erc_attribute27
    ,p_erc_attribute28               => p_erc_attribute28
    ,p_erc_attribute29               => p_erc_attribute29
    ,p_erc_attribute30               => p_erc_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_enrt_rt_ctfn
    --
    ben_enrt_rt_ctfn_bk1.create_enrt_rt_ctfn_a
      (
       p_enrt_rt_ctfn_id             =>  l_enrt_rt_ctfn_id
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_rt_id         =>  p_enrt_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_erc_attribute_category         =>  p_erc_attribute_category
      ,p_erc_attribute1                 =>  p_erc_attribute1
      ,p_erc_attribute2                 =>  p_erc_attribute2
      ,p_erc_attribute3                 =>  p_erc_attribute3
      ,p_erc_attribute4                 =>  p_erc_attribute4
      ,p_erc_attribute5                 =>  p_erc_attribute5
      ,p_erc_attribute6                 =>  p_erc_attribute6
      ,p_erc_attribute7                 =>  p_erc_attribute7
      ,p_erc_attribute8                 =>  p_erc_attribute8
      ,p_erc_attribute9                 =>  p_erc_attribute9
      ,p_erc_attribute10                =>  p_erc_attribute10
      ,p_erc_attribute11                =>  p_erc_attribute11
      ,p_erc_attribute12                =>  p_erc_attribute12
      ,p_erc_attribute13                =>  p_erc_attribute13
      ,p_erc_attribute14                =>  p_erc_attribute14
      ,p_erc_attribute15                =>  p_erc_attribute15
      ,p_erc_attribute16                =>  p_erc_attribute16
      ,p_erc_attribute17                =>  p_erc_attribute17
      ,p_erc_attribute18                =>  p_erc_attribute18
      ,p_erc_attribute19                =>  p_erc_attribute19
      ,p_erc_attribute20                =>  p_erc_attribute20
      ,p_erc_attribute21                =>  p_erc_attribute21
      ,p_erc_attribute22                =>  p_erc_attribute22
      ,p_erc_attribute23                =>  p_erc_attribute23
      ,p_erc_attribute24                =>  p_erc_attribute24
      ,p_erc_attribute25                =>  p_erc_attribute25
      ,p_erc_attribute26                =>  p_erc_attribute26
      ,p_erc_attribute27                =>  p_erc_attribute27
      ,p_erc_attribute28                =>  p_erc_attribute28
      ,p_erc_attribute29                =>  p_erc_attribute29
      ,p_erc_attribute30                =>  p_erc_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_enrt_rt_ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_enrt_rt_ctfn
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
  p_enrt_rt_ctfn_id := l_enrt_rt_ctfn_id;
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
    ROLLBACK TO create_enrt_rt_ctfn;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_enrt_rt_ctfn_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_enrt_rt_ctfn;
    p_enrt_rt_ctfn_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_enrt_rt_ctfn;
-- ----------------------------------------------------------------------------
-- |------------------------< update_enrt_rt_ctfn >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_enrt_rt_ctfn
  (p_validate                       in  boolean   default false
  ,p_enrt_rt_ctfn_id             in  number
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_enrt_rt_id         in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_erc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_erc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_enrt_rt_ctfn';
  l_object_version_number ben_enrt_rt_ctfn.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_enrt_rt_ctfn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_enrt_rt_ctfn
    --
    ben_enrt_rt_ctfn_bk2.update_enrt_rt_ctfn_b
      (
       p_enrt_rt_ctfn_id             =>  p_enrt_rt_ctfn_id
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_rt_id         =>  p_enrt_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_erc_attribute_category         =>  p_erc_attribute_category
      ,p_erc_attribute1                 =>  p_erc_attribute1
      ,p_erc_attribute2                 =>  p_erc_attribute2
      ,p_erc_attribute3                 =>  p_erc_attribute3
      ,p_erc_attribute4                 =>  p_erc_attribute4
      ,p_erc_attribute5                 =>  p_erc_attribute5
      ,p_erc_attribute6                 =>  p_erc_attribute6
      ,p_erc_attribute7                 =>  p_erc_attribute7
      ,p_erc_attribute8                 =>  p_erc_attribute8
      ,p_erc_attribute9                 =>  p_erc_attribute9
      ,p_erc_attribute10                =>  p_erc_attribute10
      ,p_erc_attribute11                =>  p_erc_attribute11
      ,p_erc_attribute12                =>  p_erc_attribute12
      ,p_erc_attribute13                =>  p_erc_attribute13
      ,p_erc_attribute14                =>  p_erc_attribute14
      ,p_erc_attribute15                =>  p_erc_attribute15
      ,p_erc_attribute16                =>  p_erc_attribute16
      ,p_erc_attribute17                =>  p_erc_attribute17
      ,p_erc_attribute18                =>  p_erc_attribute18
      ,p_erc_attribute19                =>  p_erc_attribute19
      ,p_erc_attribute20                =>  p_erc_attribute20
      ,p_erc_attribute21                =>  p_erc_attribute21
      ,p_erc_attribute22                =>  p_erc_attribute22
      ,p_erc_attribute23                =>  p_erc_attribute23
      ,p_erc_attribute24                =>  p_erc_attribute24
      ,p_erc_attribute25                =>  p_erc_attribute25
      ,p_erc_attribute26                =>  p_erc_attribute26
      ,p_erc_attribute27                =>  p_erc_attribute27
      ,p_erc_attribute28                =>  p_erc_attribute28
      ,p_erc_attribute29                =>  p_erc_attribute29
      ,p_erc_attribute30                =>  p_erc_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_enrt_rt_ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_enrt_rt_ctfn
    --
  end;
  --
  ben_erc_upd.upd
    (
     p_enrt_rt_ctfn_id            => p_enrt_rt_ctfn_id
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_rqd_flag                      => p_rqd_flag
    ,p_enrt_rt_id        => p_enrt_rt_id
    ,p_business_group_id             => p_business_group_id
    ,p_erc_attribute_category        => p_erc_attribute_category
    ,p_erc_attribute1                => p_erc_attribute1
    ,p_erc_attribute2                => p_erc_attribute2
    ,p_erc_attribute3                => p_erc_attribute3
    ,p_erc_attribute4                => p_erc_attribute4
    ,p_erc_attribute5                => p_erc_attribute5
    ,p_erc_attribute6                => p_erc_attribute6
    ,p_erc_attribute7                => p_erc_attribute7
    ,p_erc_attribute8                => p_erc_attribute8
    ,p_erc_attribute9                => p_erc_attribute9
    ,p_erc_attribute10               => p_erc_attribute10
    ,p_erc_attribute11               => p_erc_attribute11
    ,p_erc_attribute12               => p_erc_attribute12
    ,p_erc_attribute13               => p_erc_attribute13
    ,p_erc_attribute14               => p_erc_attribute14
    ,p_erc_attribute15               => p_erc_attribute15
    ,p_erc_attribute16               => p_erc_attribute16
    ,p_erc_attribute17               => p_erc_attribute17
    ,p_erc_attribute18               => p_erc_attribute18
    ,p_erc_attribute19               => p_erc_attribute19
    ,p_erc_attribute20               => p_erc_attribute20
    ,p_erc_attribute21               => p_erc_attribute21
    ,p_erc_attribute22               => p_erc_attribute22
    ,p_erc_attribute23               => p_erc_attribute23
    ,p_erc_attribute24               => p_erc_attribute24
    ,p_erc_attribute25               => p_erc_attribute25
    ,p_erc_attribute26               => p_erc_attribute26
    ,p_erc_attribute27               => p_erc_attribute27
    ,p_erc_attribute28               => p_erc_attribute28
    ,p_erc_attribute29               => p_erc_attribute29
    ,p_erc_attribute30               => p_erc_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_enrt_rt_ctfn
    --
    ben_enrt_rt_ctfn_bk2.update_enrt_rt_ctfn_a
      (
       p_enrt_rt_ctfn_id             =>  p_enrt_rt_ctfn_id
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_enrt_rt_id         =>  p_enrt_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_erc_attribute_category         =>  p_erc_attribute_category
      ,p_erc_attribute1                 =>  p_erc_attribute1
      ,p_erc_attribute2                 =>  p_erc_attribute2
      ,p_erc_attribute3                 =>  p_erc_attribute3
      ,p_erc_attribute4                 =>  p_erc_attribute4
      ,p_erc_attribute5                 =>  p_erc_attribute5
      ,p_erc_attribute6                 =>  p_erc_attribute6
      ,p_erc_attribute7                 =>  p_erc_attribute7
      ,p_erc_attribute8                 =>  p_erc_attribute8
      ,p_erc_attribute9                 =>  p_erc_attribute9
      ,p_erc_attribute10                =>  p_erc_attribute10
      ,p_erc_attribute11                =>  p_erc_attribute11
      ,p_erc_attribute12                =>  p_erc_attribute12
      ,p_erc_attribute13                =>  p_erc_attribute13
      ,p_erc_attribute14                =>  p_erc_attribute14
      ,p_erc_attribute15                =>  p_erc_attribute15
      ,p_erc_attribute16                =>  p_erc_attribute16
      ,p_erc_attribute17                =>  p_erc_attribute17
      ,p_erc_attribute18                =>  p_erc_attribute18
      ,p_erc_attribute19                =>  p_erc_attribute19
      ,p_erc_attribute20                =>  p_erc_attribute20
      ,p_erc_attribute21                =>  p_erc_attribute21
      ,p_erc_attribute22                =>  p_erc_attribute22
      ,p_erc_attribute23                =>  p_erc_attribute23
      ,p_erc_attribute24                =>  p_erc_attribute24
      ,p_erc_attribute25                =>  p_erc_attribute25
      ,p_erc_attribute26                =>  p_erc_attribute26
      ,p_erc_attribute27                =>  p_erc_attribute27
      ,p_erc_attribute28                =>  p_erc_attribute28
      ,p_erc_attribute29                =>  p_erc_attribute29
      ,p_erc_attribute30                =>  p_erc_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_enrt_rt_ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_enrt_rt_ctfn
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
    ROLLBACK TO update_enrt_rt_ctfn;
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
    ROLLBACK TO update_enrt_rt_ctfn;
    raise;
    --
end update_enrt_rt_ctfn;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrt_rt_ctfn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_rt_ctfn
  (p_validate                       in  boolean  default false
  ,p_enrt_rt_ctfn_id             in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_enrt_rt_ctfn';
  l_object_version_number ben_enrt_rt_ctfn.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_enrt_rt_ctfn;
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
    -- Start of API User Hook for the before hook of delete_enrt_rt_ctfn
    --
    ben_enrt_rt_ctfn_bk3.delete_enrt_rt_ctfn_b
      (
       p_enrt_rt_ctfn_id             =>  p_enrt_rt_ctfn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_enrt_rt_ctfn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_enrt_rt_ctfn
    --
  end;
  --
  ben_erc_del.del
    (
     p_enrt_rt_ctfn_id            => p_enrt_rt_ctfn_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_enrt_rt_ctfn
    --
    ben_enrt_rt_ctfn_bk3.delete_enrt_rt_ctfn_a
      (
       p_enrt_rt_ctfn_id             =>  p_enrt_rt_ctfn_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_enrt_rt_ctfn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_enrt_rt_ctfn
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
    ROLLBACK TO delete_enrt_rt_ctfn;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_enrt_rt_ctfn;
    raise;
    --
end delete_enrt_rt_ctfn;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_enrt_rt_ctfn_id                   in     number
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
  ben_erc_shd.lck
    (
      p_enrt_rt_ctfn_id                 => p_enrt_rt_ctfn_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_enrt_rt_ctfn_api;

/
