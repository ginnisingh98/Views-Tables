--------------------------------------------------------
--  DDL for Package Body HR_CALENDAR_NODE_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CALENDAR_NODE_TYPE_API" as
/* $Header: pepgtapi.pkb 115.4 2003/05/21 15:15:12 cxsimpso noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_CALENDAR_NODE_TYPE_API';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_node_type >---------------------------|
-- ----------------------------------------------------------------------------
--
 procedure create_node_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_hierarchy_type                in     varchar2
  ,p_child_node_name               in     varchar2
  ,p_child_value_set               in     varchar2
  ,p_child_node_type               in     varchar2 default null
  ,p_parent_node_type              in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_hier_node_type_id                out nocopy  number
  ,p_object_version_number            out nocopy  number
  ) IS
  --
  -- Declare cursors and local variables
  --
  CURSOR csr_sequence IS
  select per_gen_hier_node_types_s.nextval
  from sys.dual;

  --
  -- Check if the lookup exists already
  -- for the current language
  --
  CURSOR csr_lookup_unique IS
  select 'x' from HR_LOOKUPS
  where lookup_type = 'HIERARCHY_NODE_TYPE'
  and lookup_code = p_child_node_type;

  l_proc                   varchar2(80) := g_package||'create_node_type';
  l_hier_node_type_id      per_gen_hier_node_types.hier_node_type_id%TYPE;
  l_object_version_number  per_gen_hier_node_types.object_version_number%TYPE;
  l_rowid                  varchar2(255) := null;
  l_dummy                  varchar2(1);
  l_lookup_code            varchar2(30);
  l_effective_date         date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_node_type;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  -- check that node name has been supplied (mandatory)
  if p_child_node_name is null then
    fnd_message.set_name('PER','HR_289891_PGT_NAME_NULL');
    fnd_message.raise_error;
  end if;

  -- First generate a lookup_code from sequence, if none supplied
  if p_child_node_type is null then
    open csr_sequence;
    fetch csr_sequence into l_lookup_code;
    close csr_sequence;
  else
    -- code has been supplied so lets check its unique
    -- within the lookup type before proceeding...
    open csr_lookup_unique;
    fetch csr_lookup_unique into l_dummy;
    if csr_lookup_unique%found then
      close csr_lookup_unique;
      -- raise error as the supplied lookup_code already exists
      -- for the HIERARCHY_NODE_TYPE lookup
      fnd_message.set_name('PER','HR_289892_PGT_LOOKUP_EXISTS');
      fnd_message.set_token('NODE',p_child_node_type);
      fnd_message.raise_error;
    else
      close csr_lookup_unique;
      l_lookup_code := p_child_node_type;
    end if;
  end if;

  -- Now we attempt to create an fnd_lookup_values record for the node using the
  -- (supplied or generated) code and user supplied values for p_child_node_name (meaning)
  -- and p_description (description)

  BEGIN

    fnd_lookup_values_pkg.INSERT_ROW(X_ROWID                => l_rowid,
                                     X_SECURITY_GROUP_ID    => 0,
                                     X_LOOKUP_TYPE          => 'HIERARCHY_NODE_TYPE',
                                     X_VIEW_APPLICATION_ID  => 3,
                                     X_LOOKUP_CODE          => l_lookup_code,
                                     X_TAG                  => null,
                                     X_ATTRIBUTE_CATEGORY   => null,
                                     X_ATTRIBUTE1           => null,
                                     X_ATTRIBUTE2           => null,
                                     X_ATTRIBUTE3           => null,
                                     X_ATTRIBUTE4           => null,
                                     X_ENABLED_FLAG         => 'Y',
                                     X_START_DATE_ACTIVE    => null,
                                     X_END_DATE_ACTIVE      => null,
                                     X_TERRITORY_CODE       => null,
                                     X_ATTRIBUTE5           => null,
                                     X_ATTRIBUTE6           => null,
                                     X_ATTRIBUTE7           => null,
                                     X_ATTRIBUTE8           => null,
                                     X_ATTRIBUTE9           => null,
                                     X_ATTRIBUTE10          => null,
                                     X_ATTRIBUTE11          => null,
                                     X_ATTRIBUTE12          => null,
                                     X_ATTRIBUTE13          => null,
                                     X_ATTRIBUTE14          => null,
                                     X_ATTRIBUTE15          => null,
                                     X_MEANING              => p_child_node_name,
                                     X_DESCRIPTION          => p_description,
                                     X_CREATION_DATE        => SYSDATE ,
                                     X_CREATED_BY           => fnd_global.user_id,
                                     X_LAST_UPDATED_BY      => fnd_global.user_id,
                                     X_LAST_UPDATE_DATE     => SYSDATE,
                                     X_LAST_UPDATE_LOGIN    => fnd_global.login_id);


    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('PER','HR_289893_PGT_LOOKUP_INS_FAIL');
        fnd_message.raise_error;
  END;

  --
  -- Call Before Process User Hook
  --
  begin
    HR_CALENDAR_NODE_TYPE_BK1.create_node_type_b
      (p_effective_date                => l_effective_date
      ,p_child_node_type               => p_child_node_type
      ,p_child_node_name               => p_child_node_name
      ,p_hierarchy_type                => p_hierarchy_type
      ,p_child_value_set               => p_child_value_set
      ,p_parent_node_type              => p_parent_node_type
      ,p_identifier_key                => NULL
      ,p_description                   => p_description);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_node_type_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
   per_pgt_ins.ins
       (p_effective_date                => l_effective_date
       ,p_child_node_type               => p_child_node_type
       ,p_child_value_set               => p_child_value_set
       ,p_hierarchy_type                => p_hierarchy_type
       ,p_business_group_id             => NULL
       ,p_parent_node_type              => p_parent_node_type
       ,p_identifier_key                => NULL
       ,p_hier_node_type_id             => l_hier_node_type_id
       ,p_object_version_number         => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
    HR_CALENDAR_NODE_TYPE_BK1.create_node_type_a
       (p_effective_date                => l_effective_date
       ,p_child_node_type               => p_child_node_type
       ,p_child_node_name               => p_child_node_name
       ,p_hierarchy_type                => p_hierarchy_type
       ,p_child_value_set               => p_child_value_set
       ,p_parent_node_type              => p_parent_node_type
       ,p_identifier_key                => NULL
       ,p_description                   => p_description
       ,p_hier_node_type_id             => l_hier_node_type_id
       ,p_object_version_number         => l_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_node_type_a'
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
  p_hier_node_type_id      := l_hier_node_type_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_node_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_hier_node_type_id      := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_node_type;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_node_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_node_type >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_node_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_hier_node_type_id             in     number
  ,p_object_version_number         in out nocopy  number
  ,p_child_node_name               in     varchar2 default hr_api.g_varchar2
  ,p_child_value_set               in     varchar2 default hr_api.g_varchar2
  ,p_parent_node_type              in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- return the current lookup value for the current lang, etc
  -- for the child node type
  CURSOR csr_lookup IS
  SELECT lookup_code, created_by, meaning, description
  FROM hr_lookups
  WHERE lookup_type = 'HIERARCHY_NODE_TYPE'
  AND lookup_code = (SELECT child_node_type
                     FROM per_gen_hier_node_types
                     WHERE hier_node_type_id = p_hier_node_type_id);
  --
  --
  l_lookup_code            fnd_lookup_values.lookup_code%type := null;
  l_created_by             fnd_lookup_values.created_by%type  := null;
  l_meaning                fnd_lookup_values.meaning%type     := null;
  l_desc                   fnd_lookup_values.description%type := null;
  l_update_attempted       boolean := false;
  l_proc                   varchar2(80) := g_package||'update_node_type';
  l_hier_node_type_id      per_gen_hier_node_types.hier_node_type_id%TYPE;
  l_object_version_number  per_gen_hier_node_types.object_version_number%TYPE;
  l_effective_date         date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error(P_API_NAME  => l_proc
                            ,P_ARGUMENT  => 'p_hier_node_type_id'
                            ,P_ARGUMENT_VALUE => p_hier_node_type_id );
  --
  -- Issue a savepoint
  --
  savepoint update_node_type;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Param p_child_node_name is updateable for a custom lookup code only
  -- (not seeded),  so we process the accociated
  -- lookup value (meaning and desc) for p_child_node_type first i.e.
  -- 1) see if the meaning or description is being updated (for current language)
  -- 2) see if the update is allowed for this lookup
  --

  If p_child_node_name is not null then
    open csr_lookup;
    fetch csr_lookup into l_lookup_code, l_created_by, l_meaning, l_desc;
    close csr_lookup;

    If l_meaning is null then
      -- The lookup code does not exist so error
      fnd_message.set_name('PER','HR_289894_PGT_LOOKUP_NOT_FOUND');
      fnd_message.set_token('ID',to_char(p_hier_node_type_id));
      fnd_message.raise_error;
    End if;

    If l_meaning <>  p_child_node_name or nvl(l_desc,'1') <> nvl(p_description,'1') then
      l_update_attempted := TRUE;
    End if;

    If l_created_by = 1 and l_update_attempted then
      -- cannot update a seeded lookup code (auto-install)
      l_update_attempted := false;
      fnd_message.set_name('PER','HR_289895_PGT_LOOKUP_NO_UPDATE');
      fnd_message.raise_error;
    End if;


    If l_update_attempted then
      BEGIN
       -- lock the fnd_lookup_values record first....

       -- Now try the update of lookup meaning and desc
       -- for the child_node_type

       fnd_lookup_values_pkg.UPDATE_ROW(X_LOOKUP_TYPE          => 'HIERARCHY_NODE_TYPE',
                                        X_SECURITY_GROUP_ID    => 0,
                                        X_VIEW_APPLICATION_ID  => 3,
                                        X_LOOKUP_CODE          => l_lookup_code,
                                        X_TAG                  => null,
                                        X_ATTRIBUTE_CATEGORY   => null,
                                        X_ATTRIBUTE1           => null,
                                        X_ATTRIBUTE2           => null,
                                        X_ATTRIBUTE3           => null,
                                        X_ATTRIBUTE4           => null,
                                        X_ENABLED_FLAG         => 'Y',
                                        X_START_DATE_ACTIVE    => null,
                                        X_END_DATE_ACTIVE      => null,
                                        X_TERRITORY_CODE       => null,
                                        X_ATTRIBUTE5           => null,
                                        X_ATTRIBUTE6           => null,
                                        X_ATTRIBUTE7           => null,
                                        X_ATTRIBUTE8           => null,
                                        X_ATTRIBUTE9           => null,
                                        X_ATTRIBUTE10          => null,
                                        X_ATTRIBUTE11          => null,
                                        X_ATTRIBUTE12          => null,
                                        X_ATTRIBUTE13          => null,
                                        X_ATTRIBUTE14          => null,
                                        X_ATTRIBUTE15          => null,
                                        X_MEANING              => p_child_node_name,
                                        X_DESCRIPTION          => p_description,
                                        X_LAST_UPDATED_BY      => fnd_global.user_id,
                                        X_LAST_UPDATE_DATE     => SYSDATE,
                                        X_LAST_UPDATE_LOGIN    => fnd_global.login_id);

      EXCEPTION
        WHEN OTHERS THEN
         fnd_message.set_name('PER','HR_289896_PGT_LOOKUP_UPD_FAIL');
         fnd_message.raise_error;
      END;
    end if;
  else  -- cannot update p_child_node_name to null
    fnd_message.set_name('PER','HR_289897_PGT_LOOKUP_NULL');
    fnd_message.raise_error;
  end if;

  --
  -- Call Before Process User Hook
  --
  begin
    HR_CALENDAR_NODE_TYPE_BK2.update_node_type_b
      (p_effective_date                 => l_effective_date
       ,p_hier_node_type_id             => p_hier_node_type_id
       ,p_child_node_name               => p_child_node_name
       ,p_object_version_number         => l_object_version_number
       ,p_child_value_set               => p_child_value_set
       ,p_parent_node_type              => p_parent_node_type
       ,p_description                   => p_description
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_node_type_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
   per_pgt_upd.upd
       (p_effective_date               => l_effective_date
       ,p_hier_node_type_id            => p_hier_node_type_id
       ,p_object_version_number        => l_object_version_number
       ,p_child_value_set              => p_child_value_set
       ,p_parent_node_type             => p_parent_node_type
       ,p_identifier_key               => NULL);

  --
  --
  begin
    HR_CALENDAR_NODE_TYPE_BK2.update_node_type_a
       (p_effective_date                => l_effective_date
       ,p_hier_node_type_id             => p_hier_node_type_id
       ,p_child_node_name               => p_child_node_name
       ,p_object_version_number         => l_object_version_number
       ,p_child_value_set               => p_child_value_set
       ,p_parent_node_type              => p_parent_node_type
       ,p_description                   => p_description
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_node_type_a'
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
    rollback to update_node_type;
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
    rollback to update_node_type;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_node_type;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_node_type >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_node_type
  (p_validate                      in     boolean  default false
  ,p_hier_node_type_id             in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Fetch the lookup to be deleted
  CURSOR csr_get_child_code IS
  SELECT child_node_type
  FROM per_gen_hier_node_types
  WHERE hier_node_type_id = p_hier_node_type_id;
  --
  l_proc                  varchar2(72) := g_package||'delete_node_type';
  l_child_node_type       per_gen_hier_node_types.child_node_type%Type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --

  hr_api.mandatory_arg_error(P_API_NAME  => l_proc
                            ,P_ARGUMENT  => 'p_hier_node_type_id'
                            ,P_ARGUMENT_VALUE => p_hier_node_type_id );
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_node_type;
  --
  -- get the lookup code prior to deleting the node type
  -- for use later...
  --
  open csr_get_child_code;
  fetch csr_get_child_code into l_child_node_type;
  If csr_get_child_code%notfound then
    close csr_get_child_code;
    fnd_message.set_name('PER','HR_289894_PGT_LOOKUP_NOT_FOUND');
    fnd_message.set_token('ID',to_char(p_hier_node_type_id));
    fnd_message.raise_error;
  else
    close csr_get_child_code;

     -- lock the fnd_lookup_values record before deleting the node type
  end if;

  --
  -- Call Before Process User Hook
  --
  begin
    HR_CALENDAR_NODE_TYPE_BK3.delete_node_type_b
     (p_hier_node_type_id       => p_hier_node_type_id,
      p_object_version_number   => p_object_version_number
     );
     exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_node_type_b',
           p_hook_type   => 'BP'
          );
  end;
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  per_pgt_del.del
  (p_hier_node_type_id             => p_hier_node_type_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  BEGIN
   -- Delete the lookup code now the node_type has gone
    fnd_lookup_values_pkg.DELETE_ROW
                    (X_LOOKUP_TYPE => 'HIERARCHY_NODE_TYPE'
                    ,X_SECURITY_GROUP_ID    => 0
                    ,X_VIEW_APPLICATION_ID => 3
                    ,X_LOOKUP_CODE => l_child_node_type);

   EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('PER','HR_289898_PGT_LOOKUP_DEL_FAIL');
      fnd_message.raise_error;
   END;
  --
  --
  -- Call After Process User Hook
  begin
    HR_CALENDAR_NODE_TYPE_BK3.delete_node_type_a
     (p_hier_node_type_id       => p_hier_node_type_id,
      p_object_version_number   => p_object_version_number
     );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
           (p_module_name  => 'delete_node_type_a',
            p_hook_type   => 'AP'
           );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_node_type;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  --
  ROLLBACK TO delete_node_type;
  --
  raise;
  --
end delete_node_type;
--
--
--
Function get_node_level (p_hierarchy_type in VARCHAR2
                        ,p_child_node_type IN VARCHAR2) RETURN NUMBER IS

-- tree walk from supplied  child  node to top level
-- to obtain level of child within the hierarchy

CURSOR csr_get_level IS
  select max(level) from per_gen_hier_node_types
  where hierarchy_type = p_hierarchy_type
  connect by child_node_type = prior parent_node_type
  start with child_node_type = p_child_node_type;

  l_level NUMBER := null;

BEGIN

  open csr_get_level;
  fetch csr_get_level into l_level;
  close csr_get_level;

  RETURN nvl(l_level,0);

END get_node_level;
--
--
--
Function child_exists (p_hierarchy_type in VARCHAR2
                        ,p_child_node_type IN VARCHAR2) RETURN VARCHAR2 IS

-- Check if there are any children for the supplied child node
-- within the supplied hierarchy.

CURSOR csr_exist IS
  select 'Y'
  from per_gen_hier_node_types
  where hierarchy_type = p_hierarchy_type
  and parent_node_type = p_child_node_type
  and rownum = 1;

  l_DeleteCode Varchar2(1) := null;

BEGIN

  open csr_exist;
  fetch csr_exist into l_DeleteCode;
  close csr_exist;

  RETURN nvl(l_DeleteCode,'N');

END child_exists;
--
--
Function gen_hier_exists (p_hierarchy_type in VARCHAR2) RETURN VARCHAR2 IS
--
-- Check if there is a generic hierarchy based on the supplied node_type
-- (scope) hierarchy.
--
CURSOR csr_hexist IS
  select 'Y'
  from per_gen_hierarchy
  where type = p_hierarchy_type
  and rownum = 1;

  l_return Varchar2(1) := null;

BEGIN

  open csr_hexist;
  fetch csr_hexist into l_return;
  close csr_hexist;

  RETURN nvl(l_return,'N');
--
END gen_hier_exists;

end HR_CALENDAR_NODE_TYPE_API;

/
