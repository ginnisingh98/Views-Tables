--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_GOODS_SERVICES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_GOODS_SERVICES_API" as
/* $Header: bevgsapi.pkb 120.0 2005/05/28 12:03:53 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Plan_goods_services_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Plan_goods_services >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Plan_goods_services
  (p_validate                       in  boolean   default false
  ,p_pl_gd_or_svc_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_gd_or_svc_typ_id               in  number    default null
  ,p_alw_rcrrg_clms_flag            in  varchar2  default null
  ,p_gd_or_svc_usg_cd               in  varchar2  default null
  ,p_vgs_attribute_category         in  varchar2  default null
  ,p_vgs_attribute1                 in  varchar2  default null
  ,p_vgs_attribute2                 in  varchar2  default null
  ,p_vgs_attribute3                 in  varchar2  default null
  ,p_vgs_attribute4                 in  varchar2  default null
  ,p_vgs_attribute5                 in  varchar2  default null
  ,p_vgs_attribute6                 in  varchar2  default null
  ,p_vgs_attribute7                 in  varchar2  default null
  ,p_vgs_attribute8                 in  varchar2  default null
  ,p_vgs_attribute9                 in  varchar2  default null
  ,p_vgs_attribute10                in  varchar2  default null
  ,p_vgs_attribute11                in  varchar2  default null
  ,p_vgs_attribute12                in  varchar2  default null
  ,p_vgs_attribute13                in  varchar2  default null
  ,p_vgs_attribute14                in  varchar2  default null
  ,p_vgs_attribute15                in  varchar2  default null
  ,p_vgs_attribute16                in  varchar2  default null
  ,p_vgs_attribute17                in  varchar2  default null
  ,p_vgs_attribute18                in  varchar2  default null
  ,p_vgs_attribute19                in  varchar2  default null
  ,p_vgs_attribute20                in  varchar2  default null
  ,p_vgs_attribute21                in  varchar2  default null
  ,p_vgs_attribute22                in  varchar2  default null
  ,p_vgs_attribute23                in  varchar2  default null
  ,p_vgs_attribute24                in  varchar2  default null
  ,p_vgs_attribute25                in  varchar2  default null
  ,p_vgs_attribute26                in  varchar2  default null
  ,p_vgs_attribute27                in  varchar2  default null
  ,p_vgs_attribute28                in  varchar2  default null
  ,p_vgs_attribute29                in  varchar2  default null
  ,p_vgs_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_gd_svc_recd_basis_cd           in varchar2   default null
  ,p_gd_svc_recd_basis_dt           in date       default null
  ,p_gd_svc_recd_basis_mo           in number     default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pl_gd_or_svc_id ben_pl_gd_or_svc_f.pl_gd_or_svc_id%TYPE;
  l_effective_start_date ben_pl_gd_or_svc_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_gd_or_svc_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Plan_goods_services';
  l_object_version_number ben_pl_gd_or_svc_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Plan_goods_services;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Plan_goods_services
    --
    ben_Plan_goods_services_bk1.create_Plan_goods_services_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_alw_rcrrg_clms_flag            =>  p_alw_rcrrg_clms_flag
      ,p_gd_or_svc_usg_cd               =>  p_gd_or_svc_usg_cd
      ,p_vgs_attribute_category         =>  p_vgs_attribute_category
      ,p_vgs_attribute1                 =>  p_vgs_attribute1
      ,p_vgs_attribute2                 =>  p_vgs_attribute2
      ,p_vgs_attribute3                 =>  p_vgs_attribute3
      ,p_vgs_attribute4                 =>  p_vgs_attribute4
      ,p_vgs_attribute5                 =>  p_vgs_attribute5
      ,p_vgs_attribute6                 =>  p_vgs_attribute6
      ,p_vgs_attribute7                 =>  p_vgs_attribute7
      ,p_vgs_attribute8                 =>  p_vgs_attribute8
      ,p_vgs_attribute9                 =>  p_vgs_attribute9
      ,p_vgs_attribute10                =>  p_vgs_attribute10
      ,p_vgs_attribute11                =>  p_vgs_attribute11
      ,p_vgs_attribute12                =>  p_vgs_attribute12
      ,p_vgs_attribute13                =>  p_vgs_attribute13
      ,p_vgs_attribute14                =>  p_vgs_attribute14
      ,p_vgs_attribute15                =>  p_vgs_attribute15
      ,p_vgs_attribute16                =>  p_vgs_attribute16
      ,p_vgs_attribute17                =>  p_vgs_attribute17
      ,p_vgs_attribute18                =>  p_vgs_attribute18
      ,p_vgs_attribute19                =>  p_vgs_attribute19
      ,p_vgs_attribute20                =>  p_vgs_attribute20
      ,p_vgs_attribute21                =>  p_vgs_attribute21
      ,p_vgs_attribute22                =>  p_vgs_attribute22
      ,p_vgs_attribute23                =>  p_vgs_attribute23
      ,p_vgs_attribute24                =>  p_vgs_attribute24
      ,p_vgs_attribute25                =>  p_vgs_attribute25
      ,p_vgs_attribute26                =>  p_vgs_attribute26
      ,p_vgs_attribute27                =>  p_vgs_attribute27
      ,p_vgs_attribute28                =>  p_vgs_attribute28
      ,p_vgs_attribute29                =>  p_vgs_attribute29
      ,p_vgs_attribute30                =>  p_vgs_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_gd_svc_recd_basis_cd           => p_gd_svc_recd_basis_cd
      ,p_gd_svc_recd_basis_dt           => p_gd_svc_recd_basis_dt
      ,p_gd_svc_recd_basis_mo           => p_gd_svc_recd_basis_mo
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Plan_goods_services'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Plan_goods_services
    --
  end;
  --
  ben_vgs_ins.ins
    (
     p_pl_gd_or_svc_id               => l_pl_gd_or_svc_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_gd_or_svc_typ_id              => p_gd_or_svc_typ_id
    ,p_alw_rcrrg_clms_flag           => p_alw_rcrrg_clms_flag
    ,p_gd_or_svc_usg_cd              => p_gd_or_svc_usg_cd
    ,p_vgs_attribute_category        => p_vgs_attribute_category
    ,p_vgs_attribute1                => p_vgs_attribute1
    ,p_vgs_attribute2                => p_vgs_attribute2
    ,p_vgs_attribute3                => p_vgs_attribute3
    ,p_vgs_attribute4                => p_vgs_attribute4
    ,p_vgs_attribute5                => p_vgs_attribute5
    ,p_vgs_attribute6                => p_vgs_attribute6
    ,p_vgs_attribute7                => p_vgs_attribute7
    ,p_vgs_attribute8                => p_vgs_attribute8
    ,p_vgs_attribute9                => p_vgs_attribute9
    ,p_vgs_attribute10               => p_vgs_attribute10
    ,p_vgs_attribute11               => p_vgs_attribute11
    ,p_vgs_attribute12               => p_vgs_attribute12
    ,p_vgs_attribute13               => p_vgs_attribute13
    ,p_vgs_attribute14               => p_vgs_attribute14
    ,p_vgs_attribute15               => p_vgs_attribute15
    ,p_vgs_attribute16               => p_vgs_attribute16
    ,p_vgs_attribute17               => p_vgs_attribute17
    ,p_vgs_attribute18               => p_vgs_attribute18
    ,p_vgs_attribute19               => p_vgs_attribute19
    ,p_vgs_attribute20               => p_vgs_attribute20
    ,p_vgs_attribute21               => p_vgs_attribute21
    ,p_vgs_attribute22               => p_vgs_attribute22
    ,p_vgs_attribute23               => p_vgs_attribute23
    ,p_vgs_attribute24               => p_vgs_attribute24
    ,p_vgs_attribute25               => p_vgs_attribute25
    ,p_vgs_attribute26               => p_vgs_attribute26
    ,p_vgs_attribute27               => p_vgs_attribute27
    ,p_vgs_attribute28               => p_vgs_attribute28
    ,p_vgs_attribute29               => p_vgs_attribute29
    ,p_vgs_attribute30               => p_vgs_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_gd_svc_recd_basis_cd           => p_gd_svc_recd_basis_cd
    ,p_gd_svc_recd_basis_dt           => p_gd_svc_recd_basis_dt
    ,p_gd_svc_recd_basis_mo           => p_gd_svc_recd_basis_mo
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Plan_goods_services
    --
    ben_Plan_goods_services_bk1.create_Plan_goods_services_a
      (
       p_pl_gd_or_svc_id                =>  l_pl_gd_or_svc_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_alw_rcrrg_clms_flag            =>  p_alw_rcrrg_clms_flag
      ,p_gd_or_svc_usg_cd               =>  p_gd_or_svc_usg_cd
      ,p_vgs_attribute_category         =>  p_vgs_attribute_category
      ,p_vgs_attribute1                 =>  p_vgs_attribute1
      ,p_vgs_attribute2                 =>  p_vgs_attribute2
      ,p_vgs_attribute3                 =>  p_vgs_attribute3
      ,p_vgs_attribute4                 =>  p_vgs_attribute4
      ,p_vgs_attribute5                 =>  p_vgs_attribute5
      ,p_vgs_attribute6                 =>  p_vgs_attribute6
      ,p_vgs_attribute7                 =>  p_vgs_attribute7
      ,p_vgs_attribute8                 =>  p_vgs_attribute8
      ,p_vgs_attribute9                 =>  p_vgs_attribute9
      ,p_vgs_attribute10                =>  p_vgs_attribute10
      ,p_vgs_attribute11                =>  p_vgs_attribute11
      ,p_vgs_attribute12                =>  p_vgs_attribute12
      ,p_vgs_attribute13                =>  p_vgs_attribute13
      ,p_vgs_attribute14                =>  p_vgs_attribute14
      ,p_vgs_attribute15                =>  p_vgs_attribute15
      ,p_vgs_attribute16                =>  p_vgs_attribute16
      ,p_vgs_attribute17                =>  p_vgs_attribute17
      ,p_vgs_attribute18                =>  p_vgs_attribute18
      ,p_vgs_attribute19                =>  p_vgs_attribute19
      ,p_vgs_attribute20                =>  p_vgs_attribute20
      ,p_vgs_attribute21                =>  p_vgs_attribute21
      ,p_vgs_attribute22                =>  p_vgs_attribute22
      ,p_vgs_attribute23                =>  p_vgs_attribute23
      ,p_vgs_attribute24                =>  p_vgs_attribute24
      ,p_vgs_attribute25                =>  p_vgs_attribute25
      ,p_vgs_attribute26                =>  p_vgs_attribute26
      ,p_vgs_attribute27                =>  p_vgs_attribute27
      ,p_vgs_attribute28                =>  p_vgs_attribute28
      ,p_vgs_attribute29                =>  p_vgs_attribute29
      ,p_vgs_attribute30                =>  p_vgs_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_gd_svc_recd_basis_cd           => p_gd_svc_recd_basis_cd
      ,p_gd_svc_recd_basis_dt           => p_gd_svc_recd_basis_dt
      ,p_gd_svc_recd_basis_mo           => p_gd_svc_recd_basis_mo
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Plan_goods_services'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Plan_goods_services
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
  p_pl_gd_or_svc_id := l_pl_gd_or_svc_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
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
    ROLLBACK TO create_Plan_goods_services;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_gd_or_svc_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Plan_goods_services;
    -- NOCOPY Changes
    p_pl_gd_or_svc_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := null ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_Plan_goods_services;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Plan_goods_services >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_goods_services
  (p_validate                       in  boolean   default false
  ,p_pl_gd_or_svc_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_gd_or_svc_typ_id               in  number    default hr_api.g_number
  ,p_alw_rcrrg_clms_flag            in  varchar2  default hr_api.g_varchar2
  ,p_gd_or_svc_usg_cd               in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_vgs_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_gd_svc_recd_basis_cd           in  varchar2  default hr_api.g_varchar2
  ,p_gd_svc_recd_basis_dt           in  date      default hr_api.g_date
  ,p_gd_svc_recd_basis_mo           in  number    default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Plan_goods_services';
  l_object_version_number ben_pl_gd_or_svc_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_gd_or_svc_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_gd_or_svc_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Plan_goods_services;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Plan_goods_services
    --
    ben_Plan_goods_services_bk2.update_Plan_goods_services_b
      (
       p_pl_gd_or_svc_id                =>  p_pl_gd_or_svc_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_alw_rcrrg_clms_flag            =>  p_alw_rcrrg_clms_flag
      ,p_gd_or_svc_usg_cd               =>  p_gd_or_svc_usg_cd
      ,p_vgs_attribute_category         =>  p_vgs_attribute_category
      ,p_vgs_attribute1                 =>  p_vgs_attribute1
      ,p_vgs_attribute2                 =>  p_vgs_attribute2
      ,p_vgs_attribute3                 =>  p_vgs_attribute3
      ,p_vgs_attribute4                 =>  p_vgs_attribute4
      ,p_vgs_attribute5                 =>  p_vgs_attribute5
      ,p_vgs_attribute6                 =>  p_vgs_attribute6
      ,p_vgs_attribute7                 =>  p_vgs_attribute7
      ,p_vgs_attribute8                 =>  p_vgs_attribute8
      ,p_vgs_attribute9                 =>  p_vgs_attribute9
      ,p_vgs_attribute10                =>  p_vgs_attribute10
      ,p_vgs_attribute11                =>  p_vgs_attribute11
      ,p_vgs_attribute12                =>  p_vgs_attribute12
      ,p_vgs_attribute13                =>  p_vgs_attribute13
      ,p_vgs_attribute14                =>  p_vgs_attribute14
      ,p_vgs_attribute15                =>  p_vgs_attribute15
      ,p_vgs_attribute16                =>  p_vgs_attribute16
      ,p_vgs_attribute17                =>  p_vgs_attribute17
      ,p_vgs_attribute18                =>  p_vgs_attribute18
      ,p_vgs_attribute19                =>  p_vgs_attribute19
      ,p_vgs_attribute20                =>  p_vgs_attribute20
      ,p_vgs_attribute21                =>  p_vgs_attribute21
      ,p_vgs_attribute22                =>  p_vgs_attribute22
      ,p_vgs_attribute23                =>  p_vgs_attribute23
      ,p_vgs_attribute24                =>  p_vgs_attribute24
      ,p_vgs_attribute25                =>  p_vgs_attribute25
      ,p_vgs_attribute26                =>  p_vgs_attribute26
      ,p_vgs_attribute27                =>  p_vgs_attribute27
      ,p_vgs_attribute28                =>  p_vgs_attribute28
      ,p_vgs_attribute29                =>  p_vgs_attribute29
      ,p_vgs_attribute30                =>  p_vgs_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      ,p_gd_svc_recd_basis_cd           => p_gd_svc_recd_basis_cd
      ,p_gd_svc_recd_basis_dt           => p_gd_svc_recd_basis_dt
      ,p_gd_svc_recd_basis_mo           => p_gd_svc_recd_basis_mo

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan_goods_services'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Plan_goods_services
    --
  end;
  --
  ben_vgs_upd.upd
    (
     p_pl_gd_or_svc_id               => p_pl_gd_or_svc_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_gd_or_svc_typ_id              => p_gd_or_svc_typ_id
    ,p_alw_rcrrg_clms_flag           => p_alw_rcrrg_clms_flag
    ,p_gd_or_svc_usg_cd              => p_gd_or_svc_usg_cd
    ,p_vgs_attribute_category        => p_vgs_attribute_category
    ,p_vgs_attribute1                => p_vgs_attribute1
    ,p_vgs_attribute2                => p_vgs_attribute2
    ,p_vgs_attribute3                => p_vgs_attribute3
    ,p_vgs_attribute4                => p_vgs_attribute4
    ,p_vgs_attribute5                => p_vgs_attribute5
    ,p_vgs_attribute6                => p_vgs_attribute6
    ,p_vgs_attribute7                => p_vgs_attribute7
    ,p_vgs_attribute8                => p_vgs_attribute8
    ,p_vgs_attribute9                => p_vgs_attribute9
    ,p_vgs_attribute10               => p_vgs_attribute10
    ,p_vgs_attribute11               => p_vgs_attribute11
    ,p_vgs_attribute12               => p_vgs_attribute12
    ,p_vgs_attribute13               => p_vgs_attribute13
    ,p_vgs_attribute14               => p_vgs_attribute14
    ,p_vgs_attribute15               => p_vgs_attribute15
    ,p_vgs_attribute16               => p_vgs_attribute16
    ,p_vgs_attribute17               => p_vgs_attribute17
    ,p_vgs_attribute18               => p_vgs_attribute18
    ,p_vgs_attribute19               => p_vgs_attribute19
    ,p_vgs_attribute20               => p_vgs_attribute20
    ,p_vgs_attribute21               => p_vgs_attribute21
    ,p_vgs_attribute22               => p_vgs_attribute22
    ,p_vgs_attribute23               => p_vgs_attribute23
    ,p_vgs_attribute24               => p_vgs_attribute24
    ,p_vgs_attribute25               => p_vgs_attribute25
    ,p_vgs_attribute26               => p_vgs_attribute26
    ,p_vgs_attribute27               => p_vgs_attribute27
    ,p_vgs_attribute28               => p_vgs_attribute28
    ,p_vgs_attribute29               => p_vgs_attribute29
    ,p_vgs_attribute30               => p_vgs_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_gd_svc_recd_basis_cd           => p_gd_svc_recd_basis_cd
    ,p_gd_svc_recd_basis_dt           => p_gd_svc_recd_basis_dt
    ,p_gd_svc_recd_basis_mo           => p_gd_svc_recd_basis_mo
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Plan_goods_services
    --
    ben_Plan_goods_services_bk2.update_Plan_goods_services_a
      (
       p_pl_gd_or_svc_id                =>  p_pl_gd_or_svc_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_alw_rcrrg_clms_flag            =>  p_alw_rcrrg_clms_flag
      ,p_gd_or_svc_usg_cd               =>  p_gd_or_svc_usg_cd
      ,p_vgs_attribute_category         =>  p_vgs_attribute_category
      ,p_vgs_attribute1                 =>  p_vgs_attribute1
      ,p_vgs_attribute2                 =>  p_vgs_attribute2
      ,p_vgs_attribute3                 =>  p_vgs_attribute3
      ,p_vgs_attribute4                 =>  p_vgs_attribute4
      ,p_vgs_attribute5                 =>  p_vgs_attribute5
      ,p_vgs_attribute6                 =>  p_vgs_attribute6
      ,p_vgs_attribute7                 =>  p_vgs_attribute7
      ,p_vgs_attribute8                 =>  p_vgs_attribute8
      ,p_vgs_attribute9                 =>  p_vgs_attribute9
      ,p_vgs_attribute10                =>  p_vgs_attribute10
      ,p_vgs_attribute11                =>  p_vgs_attribute11
      ,p_vgs_attribute12                =>  p_vgs_attribute12
      ,p_vgs_attribute13                =>  p_vgs_attribute13
      ,p_vgs_attribute14                =>  p_vgs_attribute14
      ,p_vgs_attribute15                =>  p_vgs_attribute15
      ,p_vgs_attribute16                =>  p_vgs_attribute16
      ,p_vgs_attribute17                =>  p_vgs_attribute17
      ,p_vgs_attribute18                =>  p_vgs_attribute18
      ,p_vgs_attribute19                =>  p_vgs_attribute19
      ,p_vgs_attribute20                =>  p_vgs_attribute20
      ,p_vgs_attribute21                =>  p_vgs_attribute21
      ,p_vgs_attribute22                =>  p_vgs_attribute22
      ,p_vgs_attribute23                =>  p_vgs_attribute23
      ,p_vgs_attribute24                =>  p_vgs_attribute24
      ,p_vgs_attribute25                =>  p_vgs_attribute25
      ,p_vgs_attribute26                =>  p_vgs_attribute26
      ,p_vgs_attribute27                =>  p_vgs_attribute27
      ,p_vgs_attribute28                =>  p_vgs_attribute28
      ,p_vgs_attribute29                =>  p_vgs_attribute29
      ,p_vgs_attribute30                =>  p_vgs_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      ,p_gd_svc_recd_basis_cd           => p_gd_svc_recd_basis_cd
      ,p_gd_svc_recd_basis_dt           => p_gd_svc_recd_basis_dt
      ,p_gd_svc_recd_basis_mo           => p_gd_svc_recd_basis_mo

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan_goods_services'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Plan_goods_services
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
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
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
    ROLLBACK TO update_Plan_goods_services;
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
    ROLLBACK TO update_Plan_goods_services;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_Plan_goods_services;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Plan_goods_services >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_goods_services
  (p_validate                       in  boolean  default false
  ,p_pl_gd_or_svc_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Plan_goods_services';
  l_object_version_number ben_pl_gd_or_svc_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_gd_or_svc_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_gd_or_svc_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Plan_goods_services;
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
    -- Start of API User Hook for the before hook of delete_Plan_goods_services
    --
    ben_Plan_goods_services_bk3.delete_Plan_goods_services_b
      (
       p_pl_gd_or_svc_id                =>  p_pl_gd_or_svc_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan_goods_services'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Plan_goods_services
    --
  end;
  --
  ben_vgs_del.del
    (
     p_pl_gd_or_svc_id               => p_pl_gd_or_svc_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Plan_goods_services
    --
    ben_Plan_goods_services_bk3.delete_Plan_goods_services_a
      (
       p_pl_gd_or_svc_id                =>  p_pl_gd_or_svc_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan_goods_services'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Plan_goods_services
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
    ROLLBACK TO delete_Plan_goods_services;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_Plan_goods_services;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_Plan_goods_services;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_gd_or_svc_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_vgs_shd.lck
    (
      p_pl_gd_or_svc_id                 => p_pl_gd_or_svc_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Plan_goods_services_api;

/