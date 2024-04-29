--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_OBJ_ELIG_PROFL_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_OBJ_ELIG_PROFL_SWI" AS
/* $Header: bebepswi.pkb 120.0 2005/05/28 00:39:39 appldev noship $ */

--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ELIG_OBJ_ELIG_PROFL_swi.';
--

procedure create_ELIG_OBJ_ELIG_PROFL
  (p_validate                       in  number   default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id          in   number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_elig_obj_id                    in  number    default null
  ,p_elig_prfl_id                   in  number    default null
  ,p_mndtry_flag                    in  varchar2  default 'N'
  ,p_bep_attribute_category         in  varchar2  default null
  ,p_bep_attribute1                 in  varchar2  default null
  ,p_bep_attribute2                 in  varchar2  default null
  ,p_bep_attribute3                 in  varchar2  default null
  ,p_bep_attribute4                 in  varchar2  default null
  ,p_bep_attribute5                 in  varchar2  default null
  ,p_bep_attribute6                 in  varchar2  default null
  ,p_bep_attribute7                 in  varchar2  default null
  ,p_bep_attribute8                 in  varchar2  default null
  ,p_bep_attribute9                 in  varchar2  default null
  ,p_bep_attribute10                in  varchar2  default null
  ,p_bep_attribute11                in  varchar2  default null
  ,p_bep_attribute12                in  varchar2  default null
  ,p_bep_attribute13                in  varchar2  default null
  ,p_bep_attribute14                in  varchar2  default null
  ,p_bep_attribute15                in  varchar2  default null
  ,p_bep_attribute16                in  varchar2  default null
  ,p_bep_attribute17                in  varchar2  default null
  ,p_bep_attribute18                in  varchar2  default null
  ,p_bep_attribute19                in  varchar2  default null
  ,p_bep_attribute20                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_return_status                  out nocopy varchar2
  ) is
   --

   --Variables for API Boolean parameters
  l_validate boolean;

  -- Declare local variables
  --
  l_proc varchar2(72) := g_package||'create_ELIG_OBJ_ELIG_PROFL';
  l_elig_obj_elig_prfl_id number;

  --
  begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --Convert Constant values into their corresponding boolean value
  l_validate := hr_api.constant_to_boolean(p_constant_value => p_validate);

  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ELIG_OBJ_ELIG_PROFL;
  --
  --Initialize Multi Message Detection
  hr_multi_message.enable_message_list;

  hr_utility.set_location(l_proc, 20);
  --
   --
  -- Register Surrogate ID or user key values
  --
  ben_bep_ins.set_base_key_value
    (p_elig_obj_elig_prfl_id => p_elig_obj_elig_prfl_id
    );
  --
  -- Call API
  ben_elig_obj_elig_profl_api.create_ELIG_OBJ_ELIG_PROFL(
  p_validate                 => l_validate
  ,p_elig_obj_elig_prfl_id   => l_elig_obj_elig_prfl_id
  ,p_effective_start_date    => p_effective_start_date
  ,p_effective_end_date      => p_effective_end_date
  ,p_business_group_id       => p_business_group_id
  ,p_elig_obj_id             => p_elig_obj_id
  ,p_elig_prfl_id            => p_elig_prfl_id
  ,p_mndtry_flag             => p_mndtry_flag
  ,p_bep_attribute_category  => p_bep_attribute_category
  ,p_bep_attribute1          => p_bep_attribute1
  ,p_bep_attribute2          => p_bep_attribute2
  ,p_bep_attribute3          => p_bep_attribute3
  ,p_bep_attribute4          => p_bep_attribute4
  ,p_bep_attribute5          => p_bep_attribute5
  ,p_bep_attribute6          => p_bep_attribute6
  ,p_bep_attribute7          => p_bep_attribute7
  ,p_bep_attribute8          => p_bep_attribute8
  ,p_bep_attribute9          => p_bep_attribute9
  ,p_bep_attribute10         => p_bep_attribute10
  ,p_bep_attribute11         =>p_bep_attribute11
  ,p_bep_attribute12         =>p_bep_attribute12
  ,p_bep_attribute13         =>p_bep_attribute13
  ,p_bep_attribute14         =>p_bep_attribute14
  ,p_bep_attribute15         =>p_bep_attribute15
  ,p_bep_attribute16         =>p_bep_attribute16
  ,p_bep_attribute17         =>p_bep_attribute17
  ,p_bep_attribute18         =>p_bep_attribute18
  ,p_bep_attribute19         =>p_bep_attribute19
  ,p_bep_attribute20         =>p_bep_attribute20
  ,p_object_version_number   =>p_object_version_number
  ,p_effective_date          =>p_effective_date);



   exception
   when hr_multi_message.error_message_exist then
   --
   -- Catch the Multiple Message List exception which
   -- indicates API processing has been aborted because
   -- at least one message exists in the list.
   --
   rollback to create_ELIG_OBJ_ELIG_PROFL;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location('Leaving :' ||l_proc, 30);

   when others then
   --
   -- When Multiple Message Detection is enabled catch
   -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
     -- error.
     --

   rollback to create_ELIG_OBJ_ELIG_PROFL;
    if hr_multi_message.unexpected_error_add(l_proc) then
     hr_utility.set_location(' Leaving:' || l_proc,40);
     raise;
     end if;
     --RESET In/OUT and OUT parameters
    p_return_status := hr_multi_message.get_return_status_disable;
    p_effective_start_date  := null;
    p_effective_end_date   := null;
    hr_utility.set_location('Leaving :' ||l_proc, 50);
  end create_ELIG_OBJ_ELIG_PROFL;

  -- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_OBJ_ELIG_PROFL >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_OBJ_ELIG_PROFL
  (p_validate                       in  number   default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_elig_obj_id                    in  number    default hr_api.g_number
  ,p_elig_prfl_id                   in  number    default hr_api.g_number
  ,p_mndtry_flag                    in  varchar2  default 'N'
  ,p_bep_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_return_status                  out nocopy varchar2
  ) is
   --

   --Variables for API Boolean parameters
  l_validate boolean;
  --Variables for IN/OUT Parameters
  l_object_version_number number;
   -- Declare local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_OBJ_ELIG_PROFL';

  --
  begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --Convert Constant values into their corresponding boolean value
  l_validate := hr_api.constant_to_boolean(p_constant_value => p_validate);
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ELIG_OBJ_ELIG_PROFL;

  --Remember IN/OUT parameters' IN values
  l_object_version_number := p_object_version_number;
  --
  --Initialize Multi Message Detection
  hr_multi_message.enable_message_list;

  hr_utility.set_location(l_proc, 20);
  ben_elig_obj_elig_profl_api.update_ELIG_OBJ_ELIG_PROFL
  (p_validate                 => l_validate
  ,p_elig_obj_elig_prfl_id    => p_elig_obj_elig_prfl_id
  ,p_effective_start_date     => p_effective_start_date
  ,p_effective_end_date       => p_effective_end_date
  ,p_business_group_id        => p_business_group_id
  ,p_elig_obj_id              => p_elig_obj_id
  ,p_elig_prfl_id             => p_elig_prfl_id
  ,p_mndtry_flag              => p_mndtry_flag
  ,p_bep_attribute_category   => p_bep_attribute_category
  ,p_bep_attribute1           => p_bep_attribute1
  ,p_bep_attribute2           => p_bep_attribute2
  ,p_bep_attribute3           => p_bep_attribute3
  ,p_bep_attribute4           => p_bep_attribute4
  ,p_bep_attribute5           => p_bep_attribute5
  ,p_bep_attribute6           => p_bep_attribute6
  ,p_bep_attribute7           => p_bep_attribute7
  ,p_bep_attribute8           =>p_bep_attribute8
  ,p_bep_attribute9           =>p_bep_attribute9
  ,p_bep_attribute10          =>p_bep_attribute10
  ,p_bep_attribute11          =>p_bep_attribute11
  ,p_bep_attribute12          =>p_bep_attribute12
  ,p_bep_attribute13          =>p_bep_attribute13
  ,p_bep_attribute14          =>p_bep_attribute14
  ,p_bep_attribute15          =>p_bep_attribute15
  ,p_bep_attribute16          =>p_bep_attribute16
  ,p_bep_attribute17          =>p_bep_attribute17
  ,p_bep_attribute18          =>p_bep_attribute18
  ,p_bep_attribute19          =>p_bep_attribute19
  ,p_bep_attribute20          =>p_bep_attribute20
  ,p_object_version_number    => p_object_version_number
  ,p_effective_date           => p_effective_date
  ,p_datetrack_mode           =>p_datetrack_mode);

  exception
  when hr_multi_message.error_message_exist then
   --
   -- Catch the Multiple Message List exception which
   -- indicates API processing has been aborted because
   -- at least one message exists in the list.
   --
   rollback to create_ELIG_OBJ_ELIG_PROFL;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location('Leaving :' ||l_proc, 30);

  when others then
   --
   -- When Multiple Message Detection is enabled catch
   -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
     -- error.
     --
   rollback to create_ELIG_OBJ_ELIG_PROFL;

    if hr_multi_message.unexpected_error_add(l_proc) then
     hr_utility.set_location(' Leaving:' || l_proc,40);
     raise;
    end if;
     --RESET In/OUT and OUT  parameters
    p_return_status := hr_multi_message.get_return_status_disable;
    p_effective_start_date  := null;
    p_effective_end_date   := null;

    hr_utility.set_location('Leaving :' ||l_proc, 50);
  end update_ELIG_OBJ_ELIG_PROFL;

  -- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_OBJ_ELIG_PROFL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_OBJ_ELIG_PROFL
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_return_status                  out nocopy varchar2
  ) is
    --

   --Variables for API Boolean parameters
  l_validate boolean;

  --Variables for IN/OUT Parameters
  l_object_version_number number;
  l_effective_date date;

 -- Declare local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_OBJ_ELIG_PROFL';
  --
  begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --Convert Constant values into their corresponding boolean value
  l_validate := hr_api.constant_to_boolean(p_constant_value => p_validate);
  l_effective_date := trunc(p_effective_date);

  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELIG_OBJ_ELIG_PROFL;

  hr_utility.set_location(l_proc, 20);

  --Remember IN OUT parameter IN values
  l_object_version_number := p_object_version_number;

  --Initialize Multi Message Detection
  hr_multi_message.enable_message_list;

  ben_elig_obj_elig_profl_api.delete_ELIG_OBJ_ELIG_PROFL
  (p_validate                  => l_validate
  ,p_elig_obj_elig_prfl_id     => p_elig_obj_elig_prfl_id
  ,p_effective_start_date      => p_effective_start_date
  ,p_effective_end_date        => p_effective_end_date
  ,p_object_version_number     => p_object_version_number
  ,p_effective_date            => l_effective_date
  ,p_datetrack_mode            => p_datetrack_mode);

 exception
  when hr_multi_message.error_message_exist then
   --
   -- Catch the Multiple Message List exception which
   -- indicates API processing has been aborted because
   -- at least one message exists in the list.
   rollback to delete_ELIG_OBJ_ELIG_PROFL;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location('Leaving :' ||l_proc, 30);

 when others then
     --
     -- When Multiple Message Detection is enabled catch
     -- any Application specific or other unexpected
     -- exceptions.  Adding appropriate details to the
     -- Multiple Message List.  Otherwise re-raise the
     -- error.
     --

   rollback to delete_ELIG_OBJ_ELIG_PROFL;
    if hr_multi_message.unexpected_error_add(l_proc) then
     hr_utility.set_location(' Leaving:' || l_proc,40);
     raise;
    end if;
     --RESET In/OUT and OUT parameters
    p_return_status := hr_multi_message.get_return_status_disable;
    p_effective_start_date  := null;
    p_effective_end_date   := null;

    hr_utility.set_location('Leaving :' ||l_proc, 50);

  end delete_ELIG_OBJ_ELIG_PROFL;

END;

/
