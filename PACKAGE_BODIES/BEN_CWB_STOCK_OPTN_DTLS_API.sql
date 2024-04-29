--------------------------------------------------------
--  DDL for Package Body BEN_CWB_STOCK_OPTN_DTLS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_STOCK_OPTN_DTLS_API" as
/* $Header: becsoapi.pkb 115.0 2003/03/17 13:42:00 csundar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_cwb_stock_optn_dtls_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cwb_stock_optn_dtls >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwb_stock_optn_dtls
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_grant_id                      in     number   default null
  ,p_grant_number                  in     varchar2 default null
  ,p_grant_name                    in     varchar2 default null
  ,p_grant_type			   in     varchar2 default null
  ,p_grant_date                    in     date     default null
  ,p_grant_shares                  in     number   default null
  ,p_grant_price                   in     number   default null
  ,p_value_at_grant                in     number   default null
  ,p_current_share_price	   in     number   default null
  ,p_current_shares_outstanding    in     number   default null
  ,p_vested_shares                 in     number   default null
  ,p_unvested_shares		   in     number   default null
  ,p_exercisable_shares            in     number   default null
  ,p_exercised_shares              in     number   default null
  ,p_cancelled_shares              in     number   default null
  ,p_trading_symbol                in     varchar2 default null
  ,p_expiration_date 		   in     date     default null
  ,p_reason_code 		   in     varchar2 default null
  ,p_class			   in     varchar2 default null
  ,p_misc			   in     varchar2 default null
  ,p_employee_number               in     varchar2 default null
  ,p_person_id			   in     number   default null
  ,p_business_group_id             in     number   default null
  ,p_prtt_rt_val_id                in     number   default null
  ,p_cso_attribute_category        in     varchar2 default null
  ,p_cso_attribute1                in     varchar2 default null
  ,p_cso_attribute2                in     varchar2 default null
  ,p_cso_attribute3                in     varchar2 default null
  ,p_cso_attribute4                in     varchar2 default null
  ,p_cso_attribute5                in     varchar2 default null
  ,p_cso_attribute6                in     varchar2 default null
  ,p_cso_attribute7                in     varchar2 default null
  ,p_cso_attribute8                in     varchar2 default null
  ,p_cso_attribute9                in     varchar2 default null
  ,p_cso_attribute10               in     varchar2 default null
  ,p_cso_attribute11               in     varchar2 default null
  ,p_cso_attribute12               in     varchar2 default null
  ,p_cso_attribute13               in     varchar2 default null
  ,p_cso_attribute14               in     varchar2 default null
  ,p_cso_attribute15               in     varchar2 default null
  ,p_cso_attribute16               in     varchar2 default null
  ,p_cso_attribute17               in     varchar2 default null
  ,p_cso_attribute18               in     varchar2 default null
  ,p_cso_attribute19               in     varchar2 default null
  ,p_cso_attribute20               in     varchar2 default null
  ,p_cso_attribute21               in     varchar2 default null
  ,p_cso_attribute22               in     varchar2 default null
  ,p_cso_attribute23               in     varchar2 default null
  ,p_cso_attribute24               in     varchar2 default null
  ,p_cso_attribute25               in     varchar2 default null
  ,p_cso_attribute26               in     varchar2 default null
  ,p_cso_attribute27               in     varchar2 default null
  ,p_cso_attribute28               in     varchar2 default null
  ,p_cso_attribute29               in     varchar2 default null
  ,p_cso_attribute30               in     varchar2 default null
  ,p_cwb_stock_optn_dtls_id           out nocopy   number
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cwb_stock_optn_dtls_id ben_cwb_stock_optn_dtls.cwb_stock_optn_dtls_id%TYPE;
  l_object_version_number  ben_cwb_stock_optn_dtls.object_version_number%TYPE;
  l_proc                varchar2(72) := g_package||'create_cwb_stock_optn_dtls';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_cwb_stock_optn_dtls;

  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_stock_optn_dtls_bk1.create_cwb_stock_optn_dtls_b
  (p_effective_date                    => p_effective_date
  ,p_grant_id                          => p_grant_id
  ,p_grant_number                      => p_grant_number
  ,p_grant_name                        => p_grant_name
  ,p_grant_type			       => p_grant_type
  ,p_grant_date                        => p_grant_date
  ,p_grant_shares                      => p_grant_shares
  ,p_grant_price                       => p_grant_price
  ,p_value_at_grant                    => p_value_at_grant
  ,p_current_share_price	       => p_current_share_price
  ,p_current_shares_outstanding        => p_current_shares_outstanding
  ,p_vested_shares                     => p_vested_shares
  ,p_unvested_shares		       => p_unvested_shares
  ,p_exercisable_shares                => p_exercisable_shares
  ,p_exercised_shares                  => p_exercised_shares
  ,p_cancelled_shares                  => p_cancelled_shares
  ,p_trading_symbol                    => p_trading_symbol
  ,p_expiration_date 		       => p_expiration_date
  ,p_reason_code 		       => p_reason_code
  ,p_class			       => p_class
  ,p_misc			       => p_misc
  ,p_employee_number                   => p_employee_number
  ,p_person_id			       => p_person_id
  ,p_business_group_id                 => p_business_group_id
  ,p_prtt_rt_val_id                    => p_prtt_rt_val_id
  ,p_cso_attribute_category            => p_cso_attribute_category
  ,p_cso_attribute1                    => p_cso_attribute1
  ,p_cso_attribute2                    => p_cso_attribute2
  ,p_cso_attribute3                    => p_cso_attribute3
  ,p_cso_attribute4                    => p_cso_attribute4
  ,p_cso_attribute5                    => p_cso_attribute5
  ,p_cso_attribute6                    => p_cso_attribute6
  ,p_cso_attribute7                    => p_cso_attribute7
  ,p_cso_attribute8                    => p_cso_attribute8
  ,p_cso_attribute9                    => p_cso_attribute9
  ,p_cso_attribute10                   => p_cso_attribute10
  ,p_cso_attribute11                   => p_cso_attribute11
  ,p_cso_attribute12                   => p_cso_attribute12
  ,p_cso_attribute13                   => p_cso_attribute13
  ,p_cso_attribute14                   => p_cso_attribute14
  ,p_cso_attribute15                   => p_cso_attribute15
  ,p_cso_attribute16                   => p_cso_attribute16
  ,p_cso_attribute17                   => p_cso_attribute17
  ,p_cso_attribute18                   => p_cso_attribute18
  ,p_cso_attribute19                   => p_cso_attribute19
  ,p_cso_attribute20                   => p_cso_attribute20
  ,p_cso_attribute21                   => p_cso_attribute21
  ,p_cso_attribute22                   => p_cso_attribute22
  ,p_cso_attribute23                   => p_cso_attribute23
  ,p_cso_attribute24                   => p_cso_attribute24
  ,p_cso_attribute25                   => p_cso_attribute25
  ,p_cso_attribute26                   => p_cso_attribute26
  ,p_cso_attribute27                   => p_cso_attribute27
  ,p_cso_attribute28                   => p_cso_attribute28
  ,p_cso_attribute29                   => p_cso_attribute9
  ,p_cso_attribute30                   => p_cso_attribute30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_cwb_stock_optn_dtls'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  ben_cso_ins.ins
    (p_effective_date                  => p_effective_date
    ,p_cwb_stock_optn_dtls_id          => l_cwb_stock_optn_dtls_id
    ,p_grant_id                        => p_grant_id
    ,p_grant_number                    => p_grant_number
    ,p_grant_name                      => p_grant_name
    ,p_grant_type                      => p_grant_type
    ,p_grant_date                      => p_grant_date
    ,p_grant_shares                    => p_grant_shares
    ,p_grant_price                     => p_grant_price
    ,p_value_at_grant                  => p_value_at_grant
    ,p_current_share_price             => p_current_share_price
    ,p_current_shares_outstanding      => p_current_shares_outstanding
    ,p_vested_shares                   => p_vested_shares
    ,p_unvested_shares                 => p_unvested_shares
    ,p_exercisable_shares              => p_exercisable_shares
    ,p_exercised_shares                => p_exercised_shares
    ,p_cancelled_shares                => p_cancelled_shares
    ,p_trading_symbol                  => p_trading_symbol
    ,p_expiration_date                 => p_expiration_date
    ,p_reason_code                     => p_reason_code
    ,p_class                           => p_class
    ,p_misc                            => p_misc
    ,p_employee_number                 => p_employee_number
    ,p_person_id                       => p_person_id
    ,p_business_group_id               => p_business_group_id
    ,p_prtt_rt_val_id                  => p_prtt_rt_val_id
    ,p_object_version_number           => l_object_version_number
    ,p_cso_attribute_category          => p_cso_attribute_category
    ,p_cso_attribute1                  => p_cso_attribute1
    ,p_cso_attribute2                  => p_cso_attribute2
    ,p_cso_attribute3                  => p_cso_attribute3
    ,p_cso_attribute4                  => p_cso_attribute4
    ,p_cso_attribute5                  => p_cso_attribute5
    ,p_cso_attribute6                  => p_cso_attribute6
    ,p_cso_attribute7                  => p_cso_attribute7
    ,p_cso_attribute8                  => p_cso_attribute8
    ,p_cso_attribute9                  => p_cso_attribute9
    ,p_cso_attribute10                 => p_cso_attribute10
    ,p_cso_attribute11                 => p_cso_attribute11
    ,p_cso_attribute12                 => p_cso_attribute12
    ,p_cso_attribute13                 => p_cso_attribute13
    ,p_cso_attribute14                 => p_cso_attribute14
    ,p_cso_attribute15                 => p_cso_attribute15
    ,p_cso_attribute16                 => p_cso_attribute16
    ,p_cso_attribute17                 => p_cso_attribute17
    ,p_cso_attribute18                 => p_cso_attribute18
    ,p_cso_attribute19                 => p_cso_attribute19
    ,p_cso_attribute20                 => p_cso_attribute20
    ,p_cso_attribute21                 => p_cso_attribute21
    ,p_cso_attribute22                 => p_cso_attribute22
    ,p_cso_attribute23                 => p_cso_attribute23
    ,p_cso_attribute24                 => p_cso_attribute24
    ,p_cso_attribute25                 => p_cso_attribute25
    ,p_cso_attribute26                 => p_cso_attribute26
    ,p_cso_attribute27                 => p_cso_attribute27
    ,p_cso_attribute28                 => p_cso_attribute28
    ,p_cso_attribute29                 => p_cso_attribute29
    ,p_cso_attribute30                 => p_cso_attribute30
  );


  --
  -- Call After Process User Hook
  --
begin
    ben_cwb_stock_optn_dtls_bk1.create_cwb_stock_optn_dtls_a
    (p_effective_date                    => p_effective_date
    ,p_grant_id                          => p_grant_id
    ,p_grant_number                      => p_grant_number
    ,p_grant_name                        => p_grant_name
    ,p_grant_type			       => p_grant_type
    ,p_grant_date                        => p_grant_date
    ,p_grant_shares                      => p_grant_shares
    ,p_grant_price                       => p_grant_price
    ,p_value_at_grant                    => p_value_at_grant
    ,p_current_share_price	       => p_current_share_price
    ,p_current_shares_outstanding        => p_current_shares_outstanding
    ,p_vested_shares                     => p_vested_shares
    ,p_unvested_shares		       => p_unvested_shares
    ,p_exercisable_shares                => p_exercisable_shares
    ,p_exercised_shares                  => p_exercised_shares
    ,p_cancelled_shares                  => p_cancelled_shares
    ,p_trading_symbol                    => p_trading_symbol
    ,p_expiration_date 		       => p_expiration_date
    ,p_reason_code 		       => p_reason_code
    ,p_class			       => p_class
    ,p_misc			       => p_misc
    ,p_employee_number                   => p_employee_number
    ,p_person_id			       => p_person_id
    ,p_business_group_id                 => p_business_group_id
    ,p_prtt_rt_val_id                    => p_prtt_rt_val_id
    ,p_cso_attribute_category            => p_cso_attribute_category
    ,p_cso_attribute1                    => p_cso_attribute1
    ,p_cso_attribute2                    => p_cso_attribute2
    ,p_cso_attribute3                    => p_cso_attribute3
    ,p_cso_attribute4                    => p_cso_attribute4
    ,p_cso_attribute5                    => p_cso_attribute5
    ,p_cso_attribute6                    => p_cso_attribute6
    ,p_cso_attribute7                    => p_cso_attribute7
    ,p_cso_attribute8                    => p_cso_attribute8
    ,p_cso_attribute9                    => p_cso_attribute9
    ,p_cso_attribute10                   => p_cso_attribute10
    ,p_cso_attribute11                   => p_cso_attribute11
    ,p_cso_attribute12                   => p_cso_attribute12
    ,p_cso_attribute13                   => p_cso_attribute13
    ,p_cso_attribute14                   => p_cso_attribute14
    ,p_cso_attribute15                   => p_cso_attribute15
    ,p_cso_attribute16                   => p_cso_attribute16
    ,p_cso_attribute17                   => p_cso_attribute17
    ,p_cso_attribute18                   => p_cso_attribute18
    ,p_cso_attribute19                   => p_cso_attribute19
    ,p_cso_attribute20                   => p_cso_attribute20
    ,p_cso_attribute21                   => p_cso_attribute21
    ,p_cso_attribute22                   => p_cso_attribute22
    ,p_cso_attribute23                   => p_cso_attribute23
    ,p_cso_attribute24                   => p_cso_attribute24
    ,p_cso_attribute25                   => p_cso_attribute25
    ,p_cso_attribute26                   => p_cso_attribute26
    ,p_cso_attribute27                   => p_cso_attribute27
    ,p_cso_attribute28                   => p_cso_attribute28
    ,p_cso_attribute29                   => p_cso_attribute9
    ,p_cso_attribute30                   => p_cso_attribute30
    ,p_cwb_stock_optn_dtls_id            => p_cwb_stock_optn_dtls_id
    ,p_object_version_number             => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_cwb_stock_optn_dtls'
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
  p_cwb_stock_optn_dtls_id := l_cwb_stock_optn_dtls_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_cwb_stock_optn_dtls;
    --
    -- Only set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_cwb_stock_optn_dtls_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_cwb_stock_optn_dtls;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_cwb_stock_optn_dtls_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_cwb_stock_optn_dtls;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_cwb_stock_optn_dtls >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cwb_stock_optn_dtls
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_cwb_stock_optn_dtls_id        in     number
  ,p_grant_id                      in     number   default hr_api.g_number
  ,p_grant_number                  in     varchar2 default hr_api.g_varchar2
  ,p_grant_name                    in     varchar2 default hr_api.g_varchar2
  ,p_grant_type			   in     varchar2 default hr_api.g_varchar2
  ,p_grant_date                    in     date     default hr_api.g_date
  ,p_grant_shares                  in     number   default hr_api.g_number
  ,p_grant_price                   in     number   default hr_api.g_number
  ,p_value_at_grant                in     number   default hr_api.g_number
  ,p_current_share_price	   in     number   default hr_api.g_number
  ,p_current_shares_outstanding    in     number   default hr_api.g_number
  ,p_vested_shares                 in     number   default hr_api.g_number
  ,p_unvested_shares		   in     number   default hr_api.g_number
  ,p_exercisable_shares            in     number   default hr_api.g_number
  ,p_exercised_shares              in     number   default hr_api.g_number
  ,p_cancelled_shares              in     number   default hr_api.g_number
  ,p_trading_symbol                in     varchar2 default hr_api.g_varchar2
  ,p_expiration_date 		   in     date     default hr_api.g_date
  ,p_reason_code 		   in     varchar2 default hr_api.g_varchar2
  ,p_class			   in     varchar2 default hr_api.g_varchar2
  ,p_misc			   in     varchar2 default hr_api.g_varchar2
  ,p_employee_number               in     varchar2 default hr_api.g_varchar2
  ,p_person_id			   in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_prtt_rt_val_id                in     number   default hr_api.g_number
  ,p_cso_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute21               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute22               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute23               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute24               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute25               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute26               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute27               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute28               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute29               in     varchar2 default hr_api.g_varchar2
  ,p_cso_attribute30               in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in   out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number  ben_cwb_stock_optn_dtls.object_version_number%TYPE;
  l_proc                varchar2(72) := g_package||'update_cwb_stock_optn_dtls';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_cwb_stock_optn_dtls;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_stock_optn_dtls_bk2.update_cwb_stock_optn_dtls_b
    (p_effective_date                    => p_effective_date
    ,p_grant_id                          => p_grant_id
    ,p_grant_number                      => p_grant_number
    ,p_grant_name                        => p_grant_name
    ,p_grant_type			       => p_grant_type
    ,p_grant_date                        => p_grant_date
    ,p_grant_shares                      => p_grant_shares
    ,p_grant_price                       => p_grant_price
    ,p_value_at_grant                    => p_value_at_grant
    ,p_current_share_price	       => p_current_share_price
    ,p_current_shares_outstanding        => p_current_shares_outstanding
    ,p_vested_shares                     => p_vested_shares
    ,p_unvested_shares		       => p_unvested_shares
    ,p_exercisable_shares                => p_exercisable_shares
    ,p_exercised_shares                  => p_exercised_shares
    ,p_cancelled_shares                  => p_cancelled_shares
    ,p_trading_symbol                    => p_trading_symbol
    ,p_expiration_date 		       => p_expiration_date
    ,p_reason_code 		       => p_reason_code
    ,p_class			       => p_class
    ,p_misc			       => p_misc
    ,p_employee_number                   => p_employee_number
    ,p_person_id			       => p_person_id
    ,p_business_group_id                 => p_business_group_id
    ,p_prtt_rt_val_id                    => p_prtt_rt_val_id
    ,p_cso_attribute_category            => p_cso_attribute_category
    ,p_cso_attribute1                    => p_cso_attribute1
    ,p_cso_attribute2                    => p_cso_attribute2
    ,p_cso_attribute3                    => p_cso_attribute3
    ,p_cso_attribute4                    => p_cso_attribute4
    ,p_cso_attribute5                    => p_cso_attribute5
    ,p_cso_attribute6                    => p_cso_attribute6
    ,p_cso_attribute7                    => p_cso_attribute7
    ,p_cso_attribute8                    => p_cso_attribute8
    ,p_cso_attribute9                    => p_cso_attribute9
    ,p_cso_attribute10                   => p_cso_attribute10
    ,p_cso_attribute11                   => p_cso_attribute11
    ,p_cso_attribute12                   => p_cso_attribute12
    ,p_cso_attribute13                   => p_cso_attribute13
    ,p_cso_attribute14                   => p_cso_attribute14
    ,p_cso_attribute15                   => p_cso_attribute15
    ,p_cso_attribute16                   => p_cso_attribute16
    ,p_cso_attribute17                   => p_cso_attribute17
    ,p_cso_attribute18                   => p_cso_attribute18
    ,p_cso_attribute19                   => p_cso_attribute19
    ,p_cso_attribute20                   => p_cso_attribute20
    ,p_cso_attribute21                   => p_cso_attribute21
    ,p_cso_attribute22                   => p_cso_attribute22
    ,p_cso_attribute23                   => p_cso_attribute23
    ,p_cso_attribute24                   => p_cso_attribute24
    ,p_cso_attribute25                   => p_cso_attribute25
    ,p_cso_attribute26                   => p_cso_attribute26
    ,p_cso_attribute27                   => p_cso_attribute27
    ,p_cso_attribute28                   => p_cso_attribute28
    ,p_cso_attribute29                   => p_cso_attribute9
    ,p_cso_attribute30                   => p_cso_attribute30
    ,p_cwb_stock_optn_dtls_id            => p_cwb_stock_optn_dtls_id
    ,p_object_version_number             => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_cwb_stock_optn_dtls'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  ben_cso_upd.upd
    (p_effective_date		       => p_effective_date
    ,p_cwb_stock_optn_dtls_id          => p_cwb_stock_optn_dtls_id
    ,p_grant_id                        => p_grant_id
    ,p_grant_number                    => p_grant_number
    ,p_grant_name                      => p_grant_name
    ,p_grant_type                      => p_grant_type
    ,p_grant_date                      => p_grant_date
    ,p_grant_shares                    => p_grant_shares
    ,p_grant_price                     => p_grant_price
    ,p_value_at_grant                  => p_value_at_grant
    ,p_current_share_price             => p_current_share_price
    ,p_current_shares_outstanding      => p_current_shares_outstanding
    ,p_vested_shares                   => p_vested_shares
    ,p_unvested_shares                 => p_unvested_shares
    ,p_exercisable_shares              => p_exercisable_shares
    ,p_exercised_shares                => p_exercised_shares
    ,p_cancelled_shares                => p_cancelled_shares
    ,p_trading_symbol                  => p_trading_symbol
    ,p_expiration_date                 => p_expiration_date
    ,p_reason_code                     => p_reason_code
    ,p_class                           => p_class
    ,p_misc                            => p_misc
    ,p_employee_number                 => p_employee_number
    ,p_person_id                       => p_person_id
    ,p_business_group_id               => p_business_group_id
    ,p_prtt_rt_val_id                  => p_prtt_rt_val_id
    ,p_object_version_number           => l_object_version_number
    ,p_cso_attribute_category          => p_cso_attribute_category
    ,p_cso_attribute1                  => p_cso_attribute1
    ,p_cso_attribute2                  => p_cso_attribute2
    ,p_cso_attribute3                  => p_cso_attribute3
    ,p_cso_attribute4                  => p_cso_attribute4
    ,p_cso_attribute5                  => p_cso_attribute5
    ,p_cso_attribute6                  => p_cso_attribute6
    ,p_cso_attribute7                  => p_cso_attribute7
    ,p_cso_attribute8                  => p_cso_attribute8
    ,p_cso_attribute9                  => p_cso_attribute9
    ,p_cso_attribute10                 => p_cso_attribute10
    ,p_cso_attribute11                 => p_cso_attribute11
    ,p_cso_attribute12                 => p_cso_attribute12
    ,p_cso_attribute13                 => p_cso_attribute13
    ,p_cso_attribute14                 => p_cso_attribute14
    ,p_cso_attribute15                 => p_cso_attribute15
    ,p_cso_attribute16                 => p_cso_attribute16
    ,p_cso_attribute17                 => p_cso_attribute17
    ,p_cso_attribute18                 => p_cso_attribute18
    ,p_cso_attribute19                 => p_cso_attribute19
    ,p_cso_attribute20                 => p_cso_attribute20
    ,p_cso_attribute21                 => p_cso_attribute21
    ,p_cso_attribute22                 => p_cso_attribute22
    ,p_cso_attribute23                 => p_cso_attribute23
    ,p_cso_attribute24                 => p_cso_attribute24
    ,p_cso_attribute25                 => p_cso_attribute25
    ,p_cso_attribute26                 => p_cso_attribute26
    ,p_cso_attribute27                 => p_cso_attribute27
    ,p_cso_attribute28                 => p_cso_attribute28
    ,p_cso_attribute29                 => p_cso_attribute29
    ,p_cso_attribute30                 => p_cso_attribute30
  );


  --
  -- Call After Process User Hook
  --
begin
    ben_cwb_stock_optn_dtls_bk2.update_cwb_stock_optn_dtls_a
      (p_effective_date                    => p_effective_date
      ,p_grant_id                          => p_grant_id
      ,p_grant_number                      => p_grant_number
      ,p_grant_name                        => p_grant_name
      ,p_grant_type			       => p_grant_type
      ,p_grant_date                        => p_grant_date
      ,p_grant_shares                      => p_grant_shares
      ,p_grant_price                       => p_grant_price
      ,p_value_at_grant                    => p_value_at_grant
      ,p_current_share_price	       => p_current_share_price
      ,p_current_shares_outstanding        => p_current_shares_outstanding
      ,p_vested_shares                     => p_vested_shares
      ,p_unvested_shares		       => p_unvested_shares
      ,p_exercisable_shares                => p_exercisable_shares
      ,p_exercised_shares                  => p_exercised_shares
      ,p_cancelled_shares                  => p_cancelled_shares
      ,p_trading_symbol                    => p_trading_symbol
      ,p_expiration_date 		       => p_expiration_date
      ,p_reason_code 		       => p_reason_code
      ,p_class			       => p_class
      ,p_misc			       => p_misc
      ,p_employee_number                   => p_employee_number
      ,p_person_id			       => p_person_id
      ,p_business_group_id                 => p_business_group_id
      ,p_prtt_rt_val_id                    => p_prtt_rt_val_id
      ,p_cso_attribute_category            => p_cso_attribute_category
      ,p_cso_attribute1                    => p_cso_attribute1
      ,p_cso_attribute2                    => p_cso_attribute2
      ,p_cso_attribute3                    => p_cso_attribute3
      ,p_cso_attribute4                    => p_cso_attribute4
      ,p_cso_attribute5                    => p_cso_attribute5
      ,p_cso_attribute6                    => p_cso_attribute6
      ,p_cso_attribute7                    => p_cso_attribute7
      ,p_cso_attribute8                    => p_cso_attribute8
      ,p_cso_attribute9                    => p_cso_attribute9
      ,p_cso_attribute10                   => p_cso_attribute10
      ,p_cso_attribute11                   => p_cso_attribute11
      ,p_cso_attribute12                   => p_cso_attribute12
      ,p_cso_attribute13                   => p_cso_attribute13
      ,p_cso_attribute14                   => p_cso_attribute14
      ,p_cso_attribute15                   => p_cso_attribute15
      ,p_cso_attribute16                   => p_cso_attribute16
      ,p_cso_attribute17                   => p_cso_attribute17
      ,p_cso_attribute18                   => p_cso_attribute18
      ,p_cso_attribute19                   => p_cso_attribute19
      ,p_cso_attribute20                   => p_cso_attribute20
      ,p_cso_attribute21                   => p_cso_attribute21
      ,p_cso_attribute22                   => p_cso_attribute22
      ,p_cso_attribute23                   => p_cso_attribute23
      ,p_cso_attribute24                   => p_cso_attribute24
      ,p_cso_attribute25                   => p_cso_attribute25
      ,p_cso_attribute26                   => p_cso_attribute26
      ,p_cso_attribute27                   => p_cso_attribute27
      ,p_cso_attribute28                   => p_cso_attribute28
      ,p_cso_attribute29                   => p_cso_attribute9
      ,p_cso_attribute30                   => p_cso_attribute30
      ,p_cwb_stock_optn_dtls_id            => p_cwb_stock_optn_dtls_id
      ,p_object_version_number             => p_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_cwb_stock_optn_dtls'
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
    rollback to update_cwb_stock_optn_dtls;
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
    rollback to update_cwb_stock_optn_dtls;
     p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_cwb_stock_optn_dtls;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_cwb_stock_optn_dtls >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_stock_optn_dtls
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_cwb_stock_optn_dtls_id        in     number
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number  ben_cwb_stock_optn_dtls.object_version_number%TYPE;
  l_proc                varchar2(72) := g_package||'delete_cwb_stock_optn_dtls';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_cwb_stock_optn_dtls;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_stock_optn_dtls_bk3.delete_cwb_stock_optn_dtls_b
  (p_effective_date                    => p_effective_date
  ,p_cwb_stock_optn_dtls_id            => p_cwb_stock_optn_dtls_id
  ,p_object_version_number             => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_cwb_stock_optn_dtls'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  ben_cso_del.del
    (p_cwb_stock_optn_dtls_id          => p_cwb_stock_optn_dtls_id
    ,p_object_version_number           => l_object_version_number
    );


  --
  -- Call After Process User Hook
  --
begin
    ben_cwb_stock_optn_dtls_bk3.delete_cwb_stock_optn_dtls_a
  (p_effective_date                    => p_effective_date
  ,p_cwb_stock_optn_dtls_id            => p_cwb_stock_optn_dtls_id
  ,p_object_version_number             => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_cwb_stock_optn_dtls'
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
    rollback to delete_cwb_stock_optn_dtls;
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
    rollback to delete_cwb_stock_optn_dtls;
     p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_cwb_stock_optn_dtls;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_cwb_stock_optn_dtls_id        in     number
  ,p_object_version_number         in     number
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
  ben_cso_shd.lck
    (p_cwb_stock_optn_dtls_id      =>  p_cwb_stock_optn_dtls_id
    ,p_object_version_number       =>  p_object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end BEN_CWB_STOCK_OPTN_DTLS_API;

/
