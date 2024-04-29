--------------------------------------------------------
--  DDL for Package Body OTA_CATEGORY_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CATEGORY_USAGE_API" as
/* $Header: otctuapi.pkb 120.0.12010000.2 2009/07/24 10:52:06 shwnayak ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_category_usage_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_act_def_name_with_cat_id >-----------------|
-- ----------------------------------------------------------------------------
function get_act_def_name_with_cat_id
  (p_act_def_name      in     varchar2
  ,p_cat_usg_id        in     number
  ) return varchar2 is

  MAX_ACT_DEF_NAME_LEN constant number := 240;

  l_new_act_def_len number;
  l_cat_id_len number;
  l_act_def_name ota_activity_definitions_tl.name%type := p_act_def_name;
  l_old_act_def_len number := length(l_act_def_name);

begin
  --
  l_new_act_def_len := length(l_act_def_name||'-'||p_cat_usg_id);
  --
  If l_new_act_def_len > MAX_ACT_DEF_NAME_LEN then
    --
    l_cat_id_len := l_new_act_def_len - MAX_ACT_DEF_NAME_LEN;
    l_act_def_name := substr(l_act_def_name,1,l_old_act_def_len - l_cat_id_len)||'-'||to_char(p_cat_usg_id);
    --
  Else
   --
   l_act_def_name := l_act_def_name||'-'||p_cat_usg_id;
   --
  End if;
  --
  return l_act_def_name;
end get_act_def_name_with_cat_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_CATEGORY >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure Create_category
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_category			   in	  varchar2
  ,p_type			   in	  varchar2
  ,p_description		   in	  varchar2
  ,p_parent_cat_usage_id	   in	  number
  ,p_synchronous_flag		   in	  varchar2
  ,p_online_flag                   in	  varchar2 default null
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
  ,p_data_source                   in     varchar2 default null
  ,p_start_date_active             in     date
  ,p_end_date_active               in     date default null
  ,p_category_usage_id             out nocopy number
  ,p_object_version_number         out nocopy number
  ,p_comments                      in     varchar2 default null
  ,p_user_group_id                 in     number default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'Create_Category';
  l_category_usage_id       number;
  l_object_version_number   number;
  l_act_object_version_number  ota_activity_definitions.object_version_number%TYPE;
  l_activity_id ota_activity_definitions.activity_id%TYPE;
  l_effective_date          date;
  l_category                varchar2(240);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_CATEGORY;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_category := rtrim(p_category);
  --
  -- Call Before Process User Hook
  --
  begin
    ota_category_usage_bk1.create_category_b
  (p_effective_date                   => l_effective_date
  ,p_business_group_id                => p_business_group_id
  ,p_category			      => l_category
  ,p_type			      => p_type
  ,p_parent_cat_usage_id	      => p_parent_cat_usage_id
  ,p_synchronous_flag		      => p_synchronous_flag
  ,p_online_flag                      => p_online_flag
  ,p_attribute_category               => p_attribute_category
  ,p_attribute1                       => p_attribute1
  ,p_attribute2                       => p_attribute2
  ,p_attribute3                       => p_attribute3
  ,p_attribute4                       => p_attribute4
  ,p_attribute5                       => p_attribute5
  ,p_attribute6                       => p_attribute6
  ,p_attribute7                       => p_attribute7
  ,p_attribute8                       => p_attribute8
  ,p_attribute9                       => p_attribute9
  ,p_attribute10                      => p_attribute10
  ,p_attribute11                      => p_attribute11
  ,p_attribute12                      => p_attribute12
  ,p_attribute13                      => p_attribute13
  ,p_attribute14                      => p_attribute14
  ,p_attribute15                      => p_attribute15
  ,p_attribute16                      => p_attribute16
  ,p_attribute17                      => p_attribute17
  ,p_attribute18                      => p_attribute18
  ,p_attribute19                      => p_attribute19
  ,p_attribute20                      => p_attribute20
  ,p_data_source                      => p_data_source
  ,p_start_date_active                => p_start_date_active
  ,p_end_date_active                  => p_end_date_active
  ,p_comments                         => p_comments
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CATEGORY'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic (Base table)
  --
  ota_ctu_ins.ins
  (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_category		         => l_category
  ,p_type		         => p_type
  ,p_parent_cat_usage_id         => p_parent_cat_usage_id
  ,p_synchronous_flag	         => p_synchronous_flag
  ,p_online_flag                 => p_online_flag
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_data_source                 => p_data_source
  ,p_start_date_active           => p_start_date_active
  ,p_end_date_active             => p_end_date_active
  ,p_category_usage_id           => l_category_usage_id
  ,p_object_version_number       => l_object_version_number
  ,p_comments                    => p_comments
  ,p_user_group_id               => p_user_group_id

  );
  --
  -- Process Logic (MLS table)
  --
  ota_ctt_ins.ins_tl
  (p_effective_date              => p_effective_date
  ,p_language_code               => USERENV('LANG')
  ,p_category_usage_id           => l_category_usage_id
  ,p_category		         => l_category
  ,p_description                 => p_description
  );
  --
  --Call activity type API to create corresponding activity type
  IF p_type = 'C' THEN
    --
    ota_tad_api.ins(p_activity_id             => l_activity_id
                    ,p_business_group_id      => p_business_group_id
                    ,p_name                   => get_act_def_name_with_cat_id( l_category,l_category_usage_id)
                    ,p_description            => p_description
                    ,p_object_version_number  => l_act_object_version_number
                    ,p_category_usage_id      => l_category_usage_id
                    ,p_multiple_con_versions_flag => 'Y' );

    ota_adt_ins.ins_tl(p_effective_date       => p_effective_date
                       ,p_language_code       => USERENV('LANG')
                       ,p_activity_id         => l_activity_id
                       ,p_name                => get_act_def_name_with_cat_id( l_category,l_category_usage_id)
                       ,p_description         => p_description);
    --end call activity type APIs to create activity type for the category
    -- Call After Process User Hook
  END IF;
  --

  begin
  ota_category_usage_bk1.create_category_a
  (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_category		         => l_category
  ,p_type		         => p_type
  ,p_parent_cat_usage_id         => p_parent_cat_usage_id
  ,p_synchronous_flag	         => p_synchronous_flag
  ,p_online_flag                 => p_online_flag
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_data_source                 => p_data_source
  ,p_start_date_active           => p_start_date_active
  ,p_end_date_active             => p_end_date_active
  ,p_category_usage_id           => l_category_usage_id
  ,p_object_version_number       => l_object_version_number
  ,p_comments                    => p_comments

  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CATEGORY'
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
  p_category_usage_id        := l_category_usage_id;
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_CATEGORY;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_category_usage_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_CATEGORY;
    p_category_usage_id        := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_category;
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_CATEGORY >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_category
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_category_usage_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_category                      in     varchar2
  ,p_type                          in	  varchar2
  ,p_description                   in     varchar2
  ,p_parent_cat_usage_id           in	  number
  ,p_synchronous_flag              in	  varchar2
  ,p_online_flag                   in	  varchar2 default null
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
  ,p_data_source                   in     varchar2 default null
  ,p_start_date_active             in     date
  ,p_end_date_active               in     date default null
  ,p_comments                      in     varchar2 default null

  ) is
  --
  -- Declare cursors and local variables
  -- get the activity id for the category_usage_id
  CURSOR get_activity_id
      IS
  SELECT activity_id,
         object_version_number
    FROM ota_activity_definitions
   WHERE category_usage_id = p_category_usage_id;

  --
  l_proc                    varchar2(72) := g_package||'Update_category';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
  l_act_object_version_number ota_activity_definitions.object_version_number%TYPE;
  l_activity_id             ota_activity_definitions.activity_id%TYPE;
  l_category                varchar2(240);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_CATEGORY;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  l_category := rtrim(p_category);
  --
  -- Call Before Process User Hook
  --
  begin
    ota_category_usage_bk2.update_category_b
  (p_effective_date                 => l_effective_date
  ,p_category_usage_id              => p_category_usage_id
  ,p_object_version_number          => p_object_version_number
  ,p_category                       => l_category
  ,p_type                           => p_type
  ,p_parent_cat_usage_id            => p_parent_cat_usage_id
  ,p_synchronous_flag	            => p_synchronous_flag
  ,p_online_flag                    => p_online_flag
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  ,p_data_source                    => p_data_source
  ,p_start_date_active              => p_start_date_active
  ,p_end_date_active                => p_end_date_active
  ,p_comments                       => p_comments
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CATEGORY'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
/*
  ota_ctu_bus.Chk_valid_parent_category
  (p_parent_cat_usage_id	    => p_parent_cat_usage_id
  ,p_category_usage_id              => p_category_usage_id
  );
*/
  --
  -- Process Logic (Base table)
  --
  ota_ctu_upd.upd
  (p_effective_date                 => l_effective_date
  ,p_category_usage_id              => p_category_usage_id
  ,p_object_version_number          => p_object_version_number
  ,p_category                       => l_category
  ,p_type                           => p_type
  ,p_parent_cat_usage_id            => p_parent_cat_usage_id
  ,p_synchronous_flag               => p_synchronous_flag
  ,p_online_flag                    => p_online_flag
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  ,p_data_source                    => p_data_source
  ,p_start_date_active              => p_start_date_active
  ,p_end_date_active                => p_end_date_active
  ,p_comments                       => p_comments

  );
  --
  -- Process Logic (MLS table)
  --
  ota_ctt_upd.upd_tl
  (p_effective_date              => p_effective_date
  ,p_language_code               => USERENV('LANG')
  ,p_category_usage_id           => p_category_usage_id
  ,p_category		         => l_category
  ,p_description                 => p_description
  );
  --
  IF p_type = 'C' THEN-- if category type is Classification
  --Call activity type API to update corresponding activity type
     OPEN get_activity_id;
    FETCH get_activity_id INTO l_activity_id, l_act_object_version_number;
    CLOSE get_activity_id;

       IF l_activity_id IS NOT NULL THEN

          ota_tad_api.upd(p_activity_id             => l_activity_id
                          ,p_name                   => get_act_def_name_with_cat_id( l_category,p_category_usage_id)
                          ,p_description            => p_description
                          ,p_object_version_number  => l_act_object_version_number
                          ,p_category_usage_id      => p_category_usage_id
                          ,p_multiple_con_versions_flag => 'Y');

          ota_adt_upd.upd_tl(p_effective_date       => p_effective_date
                             ,p_language_code       => USERENV('LANG')
                             ,p_activity_id         => l_activity_id
                             ,p_name                => get_act_def_name_with_cat_id( l_category,p_category_usage_id)
                             ,p_description         => p_description);
      END IF;
  --end call activity type APIs to update activity type for the category
 END IF; -- if category type is Classification
  -- Call After Process User Hook
  --
  begin
  ota_category_usage_bk2.update_category_a
  (p_effective_date                 => l_effective_date
  ,p_category_usage_id              => p_category_usage_id
  ,p_object_version_number          => p_object_version_number
  ,p_category                       => l_category
  ,p_type                           => p_type
  ,p_parent_cat_usage_id            => p_parent_cat_usage_id
  ,p_synchronous_flag	            => p_synchronous_flag
  ,p_online_flag                    => p_online_flag
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  ,p_data_source                    => p_data_source
  ,p_start_date_active              => p_start_date_active
  ,p_end_date_active                => p_end_date_active
  ,p_comments                       => p_comments

    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CATEGORY'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_CATEGORY;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_CATEGORY;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_category;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_CATEGORY >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_category
  (p_validate                      in     boolean  default false
  ,p_category_usage_id             in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
   -- get the activity id for the category_usage_id
  CURSOR get_activity_id
      IS
  SELECT activity_id,
         object_version_number
    FROM ota_activity_definitions
   WHERE category_usage_id = p_category_usage_id;

  --
  l_proc                    varchar2(72) := g_package||'Delete_category';
  l_budget_version_id       number;
  l_act_object_version_number ota_activity_definitions.object_version_number%TYPE;
  l_activity_id             ota_activity_definitions.activity_id%TYPE;



  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_CATEGORY;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ota_category_usage_bk3.delete_category_b
  (p_category_usage_id           => p_category_usage_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CATEGORY'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic (MLS table
  --
  ota_ctt_del.del_tl
  (p_category_usage_id           => p_category_usage_id
  );
  --
  -- Process Logic (Base table)
  --
  ota_ctu_del.del
  (p_category_usage_id       => p_category_usage_id
  ,p_object_version_number   => p_object_version_number
  );
  --
    --Call activity type API to delete corresponding activity type
    OPEN get_activity_id;
    FETCH get_activity_id INTO l_activity_id, l_act_object_version_number;
    CLOSE get_activity_id;

    IF l_activity_id IS NOT NULL THEN

       ota_tad_api.del(p_activity_id             => l_activity_id,
                       p_object_version_number   => l_act_object_version_number);

       ota_adt_del.del_tl(p_activity_id       => l_activity_id );
    END IF;
    --end call activity type APIs to delete activity type for the category
  --
  -- Call After Process User Hook
  --
  begin
  ota_category_usage_bk3.delete_category_a
  (p_category_usage_id           => p_category_usage_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CATEGORY'
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
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_CATEGORY;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_CATEGORY;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_category;
--
end OTA_CATEGORY_USAGE_API;

/
