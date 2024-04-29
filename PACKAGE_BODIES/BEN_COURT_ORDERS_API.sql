--------------------------------------------------------
--  DDL for Package Body BEN_COURT_ORDERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COURT_ORDERS_API" as
/* $Header: becrtapi.pkb 115.6 2003/01/16 14:34:04 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_court_orders_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_court_orders >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_court_orders
  (p_validate                       in  boolean   default false
  ,p_crt_ordr_id                    out nocopy number
  ,p_crt_ordr_typ_cd                in  varchar2  default null
  ,p_apls_perd_endg_dt              in  date      default null
  ,p_apls_perd_strtg_dt             in  date      default null
  ,p_crt_ident                      in  varchar2  default null
  ,p_description                    in  varchar2  default null
  ,p_detd_qlfd_ordr_dt              in  date      default null
  ,p_issue_dt                       in  date      default null
  ,p_qdro_amt                       in  number    default null
  ,p_qdro_dstr_mthd_cd              in  varchar2  default null
  ,p_qdro_pct                       in  number    default null
  ,p_rcvd_dt                        in  date      default null
  ,p_uom                            in  varchar2  default null
  ,p_crt_issng                      in  varchar2  default null
  ,p_pl_id                          in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_crt_attribute_category         in  varchar2  default null
  ,p_crt_attribute1                 in  varchar2  default null
  ,p_crt_attribute2                 in  varchar2  default null
  ,p_crt_attribute3                 in  varchar2  default null
  ,p_crt_attribute4                 in  varchar2  default null
  ,p_crt_attribute5                 in  varchar2  default null
  ,p_crt_attribute6                 in  varchar2  default null
  ,p_crt_attribute7                 in  varchar2  default null
  ,p_crt_attribute8                 in  varchar2  default null
  ,p_crt_attribute9                 in  varchar2  default null
  ,p_crt_attribute10                in  varchar2  default null
  ,p_crt_attribute11                in  varchar2  default null
  ,p_crt_attribute12                in  varchar2  default null
  ,p_crt_attribute13                in  varchar2  default null
  ,p_crt_attribute14                in  varchar2  default null
  ,p_crt_attribute15                in  varchar2  default null
  ,p_crt_attribute16                in  varchar2  default null
  ,p_crt_attribute17                in  varchar2  default null
  ,p_crt_attribute18                in  varchar2  default null
  ,p_crt_attribute19                in  varchar2  default null
  ,p_crt_attribute20                in  varchar2  default null
  ,p_crt_attribute21                in  varchar2  default null
  ,p_crt_attribute22                in  varchar2  default null
  ,p_crt_attribute23                in  varchar2  default null
  ,p_crt_attribute24                in  varchar2  default null
  ,p_crt_attribute25                in  varchar2  default null
  ,p_crt_attribute26                in  varchar2  default null
  ,p_crt_attribute27                in  varchar2  default null
  ,p_crt_attribute28                in  varchar2  default null
  ,p_crt_attribute29                in  varchar2  default null
  ,p_crt_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_qdro_num_pymt_val              in  number    default null
  ,p_qdro_per_perd_cd               in  varchar2  default null
  ,p_pl_typ_id                      in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_crt_ordr_id ben_crt_ordr.crt_ordr_id%TYPE;
  l_proc varchar2(72) := g_package||'create_court_orders';
  l_object_version_number ben_crt_ordr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_court_orders;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_court_orders
    --
    ben_court_orders_bk1.create_court_orders_b
      (
       p_crt_ordr_typ_cd                =>  p_crt_ordr_typ_cd
      ,p_apls_perd_endg_dt              =>  p_apls_perd_endg_dt
      ,p_apls_perd_strtg_dt             =>  p_apls_perd_strtg_dt
      ,p_crt_ident                      =>  p_crt_ident
      ,p_description                    =>  p_description
      ,p_detd_qlfd_ordr_dt              =>  p_detd_qlfd_ordr_dt
      ,p_issue_dt                       =>  p_issue_dt
      ,p_qdro_amt                       =>  p_qdro_amt
      ,p_qdro_dstr_mthd_cd              =>  p_qdro_dstr_mthd_cd
      ,p_qdro_pct                       =>  p_qdro_pct
      ,p_rcvd_dt                        =>  p_rcvd_dt
      ,p_uom                            =>  p_uom
      ,p_crt_issng                      =>  p_crt_issng
      ,p_pl_id                          =>  p_pl_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_crt_attribute_category         =>  p_crt_attribute_category
      ,p_crt_attribute1                 =>  p_crt_attribute1
      ,p_crt_attribute2                 =>  p_crt_attribute2
      ,p_crt_attribute3                 =>  p_crt_attribute3
      ,p_crt_attribute4                 =>  p_crt_attribute4
      ,p_crt_attribute5                 =>  p_crt_attribute5
      ,p_crt_attribute6                 =>  p_crt_attribute6
      ,p_crt_attribute7                 =>  p_crt_attribute7
      ,p_crt_attribute8                 =>  p_crt_attribute8
      ,p_crt_attribute9                 =>  p_crt_attribute9
      ,p_crt_attribute10                =>  p_crt_attribute10
      ,p_crt_attribute11                =>  p_crt_attribute11
      ,p_crt_attribute12                =>  p_crt_attribute12
      ,p_crt_attribute13                =>  p_crt_attribute13
      ,p_crt_attribute14                =>  p_crt_attribute14
      ,p_crt_attribute15                =>  p_crt_attribute15
      ,p_crt_attribute16                =>  p_crt_attribute16
      ,p_crt_attribute17                =>  p_crt_attribute17
      ,p_crt_attribute18                =>  p_crt_attribute18
      ,p_crt_attribute19                =>  p_crt_attribute19
      ,p_crt_attribute20                =>  p_crt_attribute20
      ,p_crt_attribute21                =>  p_crt_attribute21
      ,p_crt_attribute22                =>  p_crt_attribute22
      ,p_crt_attribute23                =>  p_crt_attribute23
      ,p_crt_attribute24                =>  p_crt_attribute24
      ,p_crt_attribute25                =>  p_crt_attribute25
      ,p_crt_attribute26                =>  p_crt_attribute26
      ,p_crt_attribute27                =>  p_crt_attribute27
      ,p_crt_attribute28                =>  p_crt_attribute28
      ,p_crt_attribute29                =>  p_crt_attribute29
      ,p_crt_attribute30                =>  p_crt_attribute30
      ,p_qdro_num_pymt_val              =>  p_qdro_num_pymt_val
      ,p_qdro_per_perd_cd               =>  p_qdro_per_perd_cd
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_court_orders'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_court_orders
    --
  end;
  --
  ben_crt_ins.ins
    (
     p_crt_ordr_id                   => l_crt_ordr_id
    ,p_crt_ordr_typ_cd               => p_crt_ordr_typ_cd
    ,p_apls_perd_endg_dt             => p_apls_perd_endg_dt
    ,p_apls_perd_strtg_dt            => p_apls_perd_strtg_dt
    ,p_crt_ident                     => p_crt_ident
    ,p_description                   => p_description
    ,p_detd_qlfd_ordr_dt             => p_detd_qlfd_ordr_dt
    ,p_issue_dt                      => p_issue_dt
    ,p_qdro_amt                      => p_qdro_amt
    ,p_qdro_dstr_mthd_cd             => p_qdro_dstr_mthd_cd
    ,p_qdro_pct                      => p_qdro_pct
    ,p_rcvd_dt                       => p_rcvd_dt
    ,p_uom                           => p_uom
    ,p_crt_issng                     => p_crt_issng
    ,p_pl_id                         => p_pl_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_crt_attribute_category        => p_crt_attribute_category
    ,p_crt_attribute1                => p_crt_attribute1
    ,p_crt_attribute2                => p_crt_attribute2
    ,p_crt_attribute3                => p_crt_attribute3
    ,p_crt_attribute4                => p_crt_attribute4
    ,p_crt_attribute5                => p_crt_attribute5
    ,p_crt_attribute6                => p_crt_attribute6
    ,p_crt_attribute7                => p_crt_attribute7
    ,p_crt_attribute8                => p_crt_attribute8
    ,p_crt_attribute9                => p_crt_attribute9
    ,p_crt_attribute10               => p_crt_attribute10
    ,p_crt_attribute11               => p_crt_attribute11
    ,p_crt_attribute12               => p_crt_attribute12
    ,p_crt_attribute13               => p_crt_attribute13
    ,p_crt_attribute14               => p_crt_attribute14
    ,p_crt_attribute15               => p_crt_attribute15
    ,p_crt_attribute16               => p_crt_attribute16
    ,p_crt_attribute17               => p_crt_attribute17
    ,p_crt_attribute18               => p_crt_attribute18
    ,p_crt_attribute19               => p_crt_attribute19
    ,p_crt_attribute20               => p_crt_attribute20
    ,p_crt_attribute21               => p_crt_attribute21
    ,p_crt_attribute22               => p_crt_attribute22
    ,p_crt_attribute23               => p_crt_attribute23
    ,p_crt_attribute24               => p_crt_attribute24
    ,p_crt_attribute25               => p_crt_attribute25
    ,p_crt_attribute26               => p_crt_attribute26
    ,p_crt_attribute27               => p_crt_attribute27
    ,p_crt_attribute28               => p_crt_attribute28
    ,p_crt_attribute29               => p_crt_attribute29
    ,p_crt_attribute30               => p_crt_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_qdro_num_pymt_val             => p_qdro_num_pymt_val
    ,p_qdro_per_perd_cd              => p_qdro_per_perd_cd
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_court_orders
    --
    ben_court_orders_bk1.create_court_orders_a
      (
       p_crt_ordr_id                    =>  l_crt_ordr_id
      ,p_crt_ordr_typ_cd                =>  p_crt_ordr_typ_cd
      ,p_apls_perd_endg_dt              =>  p_apls_perd_endg_dt
      ,p_apls_perd_strtg_dt             =>  p_apls_perd_strtg_dt
      ,p_crt_ident                      =>  p_crt_ident
      ,p_description                    =>  p_description
      ,p_detd_qlfd_ordr_dt              =>  p_detd_qlfd_ordr_dt
      ,p_issue_dt                       =>  p_issue_dt
      ,p_qdro_amt                       =>  p_qdro_amt
      ,p_qdro_dstr_mthd_cd              =>  p_qdro_dstr_mthd_cd
      ,p_qdro_pct                       =>  p_qdro_pct
      ,p_rcvd_dt                        =>  p_rcvd_dt
      ,p_uom                            =>  p_uom
      ,p_crt_issng                      =>  p_crt_issng
      ,p_pl_id                          =>  p_pl_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_crt_attribute_category         =>  p_crt_attribute_category
      ,p_crt_attribute1                 =>  p_crt_attribute1
      ,p_crt_attribute2                 =>  p_crt_attribute2
      ,p_crt_attribute3                 =>  p_crt_attribute3
      ,p_crt_attribute4                 =>  p_crt_attribute4
      ,p_crt_attribute5                 =>  p_crt_attribute5
      ,p_crt_attribute6                 =>  p_crt_attribute6
      ,p_crt_attribute7                 =>  p_crt_attribute7
      ,p_crt_attribute8                 =>  p_crt_attribute8
      ,p_crt_attribute9                 =>  p_crt_attribute9
      ,p_crt_attribute10                =>  p_crt_attribute10
      ,p_crt_attribute11                =>  p_crt_attribute11
      ,p_crt_attribute12                =>  p_crt_attribute12
      ,p_crt_attribute13                =>  p_crt_attribute13
      ,p_crt_attribute14                =>  p_crt_attribute14
      ,p_crt_attribute15                =>  p_crt_attribute15
      ,p_crt_attribute16                =>  p_crt_attribute16
      ,p_crt_attribute17                =>  p_crt_attribute17
      ,p_crt_attribute18                =>  p_crt_attribute18
      ,p_crt_attribute19                =>  p_crt_attribute19
      ,p_crt_attribute20                =>  p_crt_attribute20
      ,p_crt_attribute21                =>  p_crt_attribute21
      ,p_crt_attribute22                =>  p_crt_attribute22
      ,p_crt_attribute23                =>  p_crt_attribute23
      ,p_crt_attribute24                =>  p_crt_attribute24
      ,p_crt_attribute25                =>  p_crt_attribute25
      ,p_crt_attribute26                =>  p_crt_attribute26
      ,p_crt_attribute27                =>  p_crt_attribute27
      ,p_crt_attribute28                =>  p_crt_attribute28
      ,p_crt_attribute29                =>  p_crt_attribute29
      ,p_crt_attribute30                =>  p_crt_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_qdro_num_pymt_val              =>  p_qdro_num_pymt_val
      ,p_qdro_per_perd_cd               =>  p_qdro_per_perd_cd
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_court_orders'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_court_orders
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
  p_crt_ordr_id := l_crt_ordr_id;
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
    ROLLBACK TO create_court_orders;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_crt_ordr_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_court_orders;
    p_crt_ordr_id := null; --nocopy change
    p_object_version_number  := null; --nocopy change
    raise;
    --
end create_court_orders;
-- ----------------------------------------------------------------------------
-- |------------------------< update_court_orders >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_court_orders
  (p_validate                       in  boolean   default false
  ,p_crt_ordr_id                    in  number
  ,p_crt_ordr_typ_cd                in  varchar2  default hr_api.g_varchar2
  ,p_apls_perd_endg_dt              in  date      default hr_api.g_date
  ,p_apls_perd_strtg_dt             in  date      default hr_api.g_date
  ,p_crt_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_detd_qlfd_ordr_dt              in  date      default hr_api.g_date
  ,p_issue_dt                       in  date      default hr_api.g_date
  ,p_qdro_amt                       in  number    default hr_api.g_number
  ,p_qdro_dstr_mthd_cd              in  varchar2  default hr_api.g_varchar2
  ,p_qdro_pct                       in  number    default hr_api.g_number
  ,p_rcvd_dt                        in  date      default hr_api.g_date
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_crt_issng                      in  varchar2  default hr_api.g_varchar2
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_crt_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_crt_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_qdro_num_pymt_val              in  number    default hr_api.g_number
  ,p_qdro_per_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_court_orders';
  l_object_version_number ben_crt_ordr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_court_orders;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_court_orders
    --
    ben_court_orders_bk2.update_court_orders_b
      (
       p_crt_ordr_id                    =>  p_crt_ordr_id
      ,p_crt_ordr_typ_cd                =>  p_crt_ordr_typ_cd
      ,p_apls_perd_endg_dt              =>  p_apls_perd_endg_dt
      ,p_apls_perd_strtg_dt             =>  p_apls_perd_strtg_dt
      ,p_crt_ident                      =>  p_crt_ident
      ,p_description                    =>  p_description
      ,p_detd_qlfd_ordr_dt              =>  p_detd_qlfd_ordr_dt
      ,p_issue_dt                       =>  p_issue_dt
      ,p_qdro_amt                       =>  p_qdro_amt
      ,p_qdro_dstr_mthd_cd              =>  p_qdro_dstr_mthd_cd
      ,p_qdro_pct                       =>  p_qdro_pct
      ,p_rcvd_dt                        =>  p_rcvd_dt
      ,p_uom                            =>  p_uom
      ,p_crt_issng                      =>  p_crt_issng
      ,p_pl_id                          =>  p_pl_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_crt_attribute_category         =>  p_crt_attribute_category
      ,p_crt_attribute1                 =>  p_crt_attribute1
      ,p_crt_attribute2                 =>  p_crt_attribute2
      ,p_crt_attribute3                 =>  p_crt_attribute3
      ,p_crt_attribute4                 =>  p_crt_attribute4
      ,p_crt_attribute5                 =>  p_crt_attribute5
      ,p_crt_attribute6                 =>  p_crt_attribute6
      ,p_crt_attribute7                 =>  p_crt_attribute7
      ,p_crt_attribute8                 =>  p_crt_attribute8
      ,p_crt_attribute9                 =>  p_crt_attribute9
      ,p_crt_attribute10                =>  p_crt_attribute10
      ,p_crt_attribute11                =>  p_crt_attribute11
      ,p_crt_attribute12                =>  p_crt_attribute12
      ,p_crt_attribute13                =>  p_crt_attribute13
      ,p_crt_attribute14                =>  p_crt_attribute14
      ,p_crt_attribute15                =>  p_crt_attribute15
      ,p_crt_attribute16                =>  p_crt_attribute16
      ,p_crt_attribute17                =>  p_crt_attribute17
      ,p_crt_attribute18                =>  p_crt_attribute18
      ,p_crt_attribute19                =>  p_crt_attribute19
      ,p_crt_attribute20                =>  p_crt_attribute20
      ,p_crt_attribute21                =>  p_crt_attribute21
      ,p_crt_attribute22                =>  p_crt_attribute22
      ,p_crt_attribute23                =>  p_crt_attribute23
      ,p_crt_attribute24                =>  p_crt_attribute24
      ,p_crt_attribute25                =>  p_crt_attribute25
      ,p_crt_attribute26                =>  p_crt_attribute26
      ,p_crt_attribute27                =>  p_crt_attribute27
      ,p_crt_attribute28                =>  p_crt_attribute28
      ,p_crt_attribute29                =>  p_crt_attribute29
      ,p_crt_attribute30                =>  p_crt_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_qdro_num_pymt_val              =>  p_qdro_num_pymt_val
      ,p_qdro_per_perd_cd               =>  p_qdro_per_perd_cd
      ,p_pl_typ_id                      =>  p_pl_typ_id
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_court_orders'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_court_orders
    --
  end;
  --
  ben_crt_upd.upd
    (
     p_crt_ordr_id                   => p_crt_ordr_id
    ,p_crt_ordr_typ_cd               => p_crt_ordr_typ_cd
    ,p_apls_perd_endg_dt             => p_apls_perd_endg_dt
    ,p_apls_perd_strtg_dt            => p_apls_perd_strtg_dt
    ,p_crt_ident                     => p_crt_ident
    ,p_description                   => p_description
    ,p_detd_qlfd_ordr_dt             => p_detd_qlfd_ordr_dt
    ,p_issue_dt                      => p_issue_dt
    ,p_qdro_amt                      => p_qdro_amt
    ,p_qdro_dstr_mthd_cd             => p_qdro_dstr_mthd_cd
    ,p_qdro_pct                      => p_qdro_pct
    ,p_rcvd_dt                       => p_rcvd_dt
    ,p_uom                           => p_uom
    ,p_crt_issng                     => p_crt_issng
    ,p_pl_id                         => p_pl_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_crt_attribute_category        => p_crt_attribute_category
    ,p_crt_attribute1                => p_crt_attribute1
    ,p_crt_attribute2                => p_crt_attribute2
    ,p_crt_attribute3                => p_crt_attribute3
    ,p_crt_attribute4                => p_crt_attribute4
    ,p_crt_attribute5                => p_crt_attribute5
    ,p_crt_attribute6                => p_crt_attribute6
    ,p_crt_attribute7                => p_crt_attribute7
    ,p_crt_attribute8                => p_crt_attribute8
    ,p_crt_attribute9                => p_crt_attribute9
    ,p_crt_attribute10               => p_crt_attribute10
    ,p_crt_attribute11               => p_crt_attribute11
    ,p_crt_attribute12               => p_crt_attribute12
    ,p_crt_attribute13               => p_crt_attribute13
    ,p_crt_attribute14               => p_crt_attribute14
    ,p_crt_attribute15               => p_crt_attribute15
    ,p_crt_attribute16               => p_crt_attribute16
    ,p_crt_attribute17               => p_crt_attribute17
    ,p_crt_attribute18               => p_crt_attribute18
    ,p_crt_attribute19               => p_crt_attribute19
    ,p_crt_attribute20               => p_crt_attribute20
    ,p_crt_attribute21               => p_crt_attribute21
    ,p_crt_attribute22               => p_crt_attribute22
    ,p_crt_attribute23               => p_crt_attribute23
    ,p_crt_attribute24               => p_crt_attribute24
    ,p_crt_attribute25               => p_crt_attribute25
    ,p_crt_attribute26               => p_crt_attribute26
    ,p_crt_attribute27               => p_crt_attribute27
    ,p_crt_attribute28               => p_crt_attribute28
    ,p_crt_attribute29               => p_crt_attribute29
    ,p_crt_attribute30               => p_crt_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_qdro_num_pymt_val             => p_qdro_num_pymt_val
    ,p_qdro_per_perd_cd              => p_qdro_per_perd_cd
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_court_orders
    --
    ben_court_orders_bk2.update_court_orders_a
      (
       p_crt_ordr_id                    =>  p_crt_ordr_id
      ,p_crt_ordr_typ_cd                =>  p_crt_ordr_typ_cd
      ,p_apls_perd_endg_dt              =>  p_apls_perd_endg_dt
      ,p_apls_perd_strtg_dt             =>  p_apls_perd_strtg_dt
      ,p_crt_ident                      =>  p_crt_ident
      ,p_description                    =>  p_description
      ,p_detd_qlfd_ordr_dt              =>  p_detd_qlfd_ordr_dt
      ,p_issue_dt                       =>  p_issue_dt
      ,p_qdro_amt                       =>  p_qdro_amt
      ,p_qdro_dstr_mthd_cd              =>  p_qdro_dstr_mthd_cd
      ,p_qdro_pct                       =>  p_qdro_pct
      ,p_rcvd_dt                        =>  p_rcvd_dt
      ,p_uom                            =>  p_uom
      ,p_crt_issng                      =>  p_crt_issng
      ,p_pl_id                          =>  p_pl_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_crt_attribute_category         =>  p_crt_attribute_category
      ,p_crt_attribute1                 =>  p_crt_attribute1
      ,p_crt_attribute2                 =>  p_crt_attribute2
      ,p_crt_attribute3                 =>  p_crt_attribute3
      ,p_crt_attribute4                 =>  p_crt_attribute4
      ,p_crt_attribute5                 =>  p_crt_attribute5
      ,p_crt_attribute6                 =>  p_crt_attribute6
      ,p_crt_attribute7                 =>  p_crt_attribute7
      ,p_crt_attribute8                 =>  p_crt_attribute8
      ,p_crt_attribute9                 =>  p_crt_attribute9
      ,p_crt_attribute10                =>  p_crt_attribute10
      ,p_crt_attribute11                =>  p_crt_attribute11
      ,p_crt_attribute12                =>  p_crt_attribute12
      ,p_crt_attribute13                =>  p_crt_attribute13
      ,p_crt_attribute14                =>  p_crt_attribute14
      ,p_crt_attribute15                =>  p_crt_attribute15
      ,p_crt_attribute16                =>  p_crt_attribute16
      ,p_crt_attribute17                =>  p_crt_attribute17
      ,p_crt_attribute18                =>  p_crt_attribute18
      ,p_crt_attribute19                =>  p_crt_attribute19
      ,p_crt_attribute20                =>  p_crt_attribute20
      ,p_crt_attribute21                =>  p_crt_attribute21
      ,p_crt_attribute22                =>  p_crt_attribute22
      ,p_crt_attribute23                =>  p_crt_attribute23
      ,p_crt_attribute24                =>  p_crt_attribute24
      ,p_crt_attribute25                =>  p_crt_attribute25
      ,p_crt_attribute26                =>  p_crt_attribute26
      ,p_crt_attribute27                =>  p_crt_attribute27
      ,p_crt_attribute28                =>  p_crt_attribute28
      ,p_crt_attribute29                =>  p_crt_attribute29
      ,p_crt_attribute30                =>  p_crt_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_qdro_num_pymt_val              =>  p_qdro_num_pymt_val
      ,p_qdro_per_perd_cd               =>  p_qdro_per_perd_cd
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_court_orders'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_court_orders
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
    ROLLBACK TO update_court_orders;
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
    ROLLBACK TO update_court_orders;

    raise;
    --
end update_court_orders;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_court_orders >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_court_orders
  (p_validate                       in  boolean  default false
  ,p_crt_ordr_id                    in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_court_orders';
  l_object_version_number ben_crt_ordr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_court_orders;
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
    -- Start of API User Hook for the before hook of delete_court_orders
    --
    ben_court_orders_bk3.delete_court_orders_b
      (
       p_crt_ordr_id                    =>  p_crt_ordr_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_court_orders'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_court_orders
    --
  end;
  --
  ben_crt_del.del
    (
     p_crt_ordr_id                   => p_crt_ordr_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_court_orders
    --
    ben_court_orders_bk3.delete_court_orders_a
      (
       p_crt_ordr_id                    =>  p_crt_ordr_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_court_orders'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_court_orders
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
    ROLLBACK TO delete_court_orders;
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
    ROLLBACK TO delete_court_orders;

    raise;
    --
end delete_court_orders;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_crt_ordr_id                   in     number
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
  ben_crt_shd.lck
    (
      p_crt_ordr_id                 => p_crt_ordr_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_court_orders_api;

/
