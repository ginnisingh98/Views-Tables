--------------------------------------------------------
--  DDL for Package Body PQH_GENERIC_HIERARCHY_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GENERIC_HIERARCHY_PACKAGE" 
/* $Header: pqghrpkg.pkb 120.2 2006/02/13 15:49:17 nsanghal noship $ */
as
--
g_debug   boolean      :=  hr_utility.debug_enabled;
g_package varchar2(72) := 'pqh_generic_hierarchy_package';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_type_context >----------------------------|
-- ----------------------------------------------------------------------------
function chk_type_context(p_type            in varchar2,
                          p_flexfield_name  in varchar2)
return varchar2
is
l_count number;
l_proc   varchar2(72) ;

Cursor csr_type_context
is
Select '1'
from   FND_DESCR_FLEX_CONTEXTS_VL
where  GLOBAL_FLAG = 'N'
AND    APPLICATION_ID = 800
AND    DESCRIPTIVE_FLEXFIELD_NAME = p_flexfield_name
AND    DESCRIPTIVE_FLEX_CONTEXT_CODE = p_type
AND    ENABLED_FLAG = 'Y';

--
l_return varchar2(10);
--
BEGIN
g_debug := hr_utility.debug_enabled;
if g_debug then
l_proc := g_package||'chk_type_context';
 hr_utility.set_location('Entering '||l_proc,10);
end if;

Open csr_type_context;
--
Fetch csr_type_context into l_count;
--
If csr_type_context%NOTFOUND  Then
  l_return := 'N';
Else
  l_return := 'Y';
End If;
--
Close csr_type_context;
--
if g_debug then
hr_utility.set_location('Leaving '||l_proc,20);
end if;
--
 return l_return;
--
EXCEPTION
  WHEN OTHERS THEN
     return 'N';
End chk_type_context;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_if_parent_node_type >-------------------------|
-- ----------------------------------------------------------------------------
function chk_if_parent_node_type (p_node_type      in varchar2,
                                  p_hierarchy_type in varchar2)
return varchar2
is
l_count number;
l_proc   varchar2(72);
--
Cursor csr_child_node_types
is
Select '1'
from
per_gen_hier_node_types
Where
    ( parent_node_type = p_node_type
      Or
      parent_node_type is null and p_node_type is null)
and hierarchy_type   = p_hierarchy_type;
--
 l_return varchar2(10);
--
BEGIN
g_debug := hr_utility.debug_enabled;
if g_debug then
l_proc := g_package||'chk_child_node_type_exists';
hr_utility.set_location('Entering '||l_proc,10);
end if;

Open csr_child_node_types;
--
Fetch csr_child_node_types into l_count;
--
If csr_child_node_types%NOTFOUND  Then
   l_return := 'N';
Else
   l_return := 'Y';
End If;
--
Close csr_child_node_types;
--
if g_debug then
hr_utility.set_location('Leaving '||l_proc,20);
end if;
--
return l_return;
--
EXCEPTION
  WHEN OTHERS THEN
     return 'N';
End chk_if_parent_node_type;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< node_value_set_dyn_query >------------------------|
-- ----------------------------------------------------------------------------
Function Node_Value_Set_Dyn_Query(p_child_node_type   IN Varchar2,
                                  p_parent_node_id    IN Number,
                                  p_hierarchy_type    IN Varchar2
                                  )
Return Varchar2
Is
--
l_value_set_id Number(10);
l_dyn_query varchar2(2000);
l_proc      varchar2(72);
l_valid     varchar2(1);
--
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
l_proc := g_package||'node_value_set_dyn_query';
hr_utility.set_location('Entering:'||l_proc, 10);
end if;
l_value_set_id := Get_Value_Set_Id(p_child_node_type, p_parent_node_id, p_hierarchy_type);
--
if l_value_set_id = -2 then
 l_dyn_query    := 'INVALID';
 if g_debug then
   hr_utility.set_location('Value Set is Invalid', 20);
 end if;
elsif l_value_set_id = -1 then
 l_dyn_query    := 'NULL';
 if g_debug then
   hr_utility.set_location('No Validation', 30);
 end if;
else
 l_dyn_query    := get_sql_from_vset_id(l_value_set_id);
 if g_debug then
   hr_utility.set_location('Value Set Query Available, Checking Validity', 40);
 end if;
 l_valid        := is_valid_sql(l_dyn_query);
 if (l_valid = 'N') then
  l_dyn_query    := 'INVALID';
  if g_debug then
   hr_utility.set_location('Value Set Query is Invalid', 50);
  end if;
 end if;
end if;
--
 if g_debug then
   hr_utility.set_location('Leaving:'||l_proc, 50);
 end if;
--
Return l_dyn_query;
End Node_Value_Set_Dyn_Query;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_node_value >-----------------------------|
-- ----------------------------------------------------------------------------
Function Get_Node_Value (p_entity_id       IN varchar2,
                         p_parent_node_id  IN Number,
                         p_child_node_id   IN Number)
Return varchar2
Is
--
cursor csr_node_type_id (p_child_node_type IN varchar2,
                         p_parent_node_type IN varchar2,
                         p_hierarchy_type IN varchar2)
is
Select hier_node_type_id
From   per_gen_hier_node_types
Where  hierarchy_type   = p_hierarchy_type
And    ( parent_node_type = p_parent_node_type
         Or
        (parent_node_type is null and p_parent_node_type is null)
        )
And    child_node_type  = p_child_node_type;
--
l_child_node_type   varchar2(30);
l_parent_node_type  varchar2(30);
l_hierarchy_type    varchar2(30);
l_Node_Value        varchar2(2000);
l_Hier_Node_Type_Id number(15);
l_proc              varchar2(72);
--
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc := g_package||'get_node_value';
  hr_utility.set_location('Entering:'||l_proc, 10);
end if;
--
if p_parent_node_id is not null then
l_hierarchy_type   := Get_Hierarchy_Type(p_parent_node_id);
elsif p_child_node_id is not null then
l_hierarchy_type   := Get_Hierarchy_Type(p_child_node_id);
else
 if g_debug then
  hr_utility.set_location('Both parent and child node ids are null',20);
 end if;
End if;

l_parent_node_type := Get_Node_Type(p_parent_node_id);
l_child_node_type  := Get_Node_Type(p_child_node_id);
--
--Determine the key in the per_gen_hier_node_types table
--
Open  csr_node_type_id(l_child_node_type,l_parent_node_type,l_hierarchy_type);
Fetch csr_node_type_id into l_hier_node_type_id;
close csr_node_type_id;
--
--Calling the calendar hierarchy api to get the display value of the node
--
l_Node_Value := get_display_value
                 (p_entity_id         => p_entity_id,
                  p_node_type_id      => l_hier_node_type_id);
if (l_Node_Value = 'NULL') then
l_Node_Value := p_entity_id;
 if g_debug then
  hr_utility.set_location('No validation, Value same as entity id', 30);
 end if;
end if;
--
 if g_debug then
  hr_utility.set_location('Leaving:'||l_proc,40);
 end if;
--
Return l_Node_Value;
--
Exception
When others then
if g_debug then
hr_utility.set_location('Unexpected Error', 50);
end if;
raise;
End Get_Node_Value;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_node_type >-----------------------------|
-- ----------------------------------------------------------------------------
Function Get_Node_Type(p_hierarchy_node_id IN Number)
Return Varchar2
Is
--
Cursor csr_node_type
Is
Select Node_Type
From   per_gen_hierarchy_nodes
Where  hierarchy_node_id = p_hierarchy_node_id;
--
l_node_type Varchar2(30);
l_proc      Varchar2(72);
--
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc := g_package||'get_node_type';
  hr_utility.set_location('Entering:'||l_proc, 10);
end if;
--
Open csr_node_type;
Fetch csr_node_type into l_node_type;
Close csr_node_type;
--
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 20);
end if;
Return l_node_type;
End Get_Node_Type;
--
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_hierarchy_type >-----------------------|
-- ----------------------------------------------------------------------------

Function Get_Hierarchy_Type(p_hierarchy_node_id IN Number)
Return Varchar2
Is

Cursor csr_hierarchy_type
Is
Select ghr.type
from
per_gen_hierarchy ghr,
per_gen_hierarchy_versions gvr,
per_gen_hierarchy_nodes gnd
where
    gnd.hierarchy_node_id    = p_hierarchy_node_id
and gnd.hierarchy_version_id = gvr.hierarchy_version_id
and gvr.hierarchy_id         = ghr.hierarchy_id;
--
l_hierarchy_type Varchar2(30);
l_proc           Varchar2(72);
--
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc := g_package||'get_hierarchy_type';
  hr_utility.set_location('Entering:'||l_proc, 10);
end if;
--
Open csr_hierarchy_type;
Fetch csr_hierarchy_type into l_hierarchy_type;
Close csr_hierarchy_type;
--
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 20);
end if;

Return l_hierarchy_type;
--
End Get_Hierarchy_Type;
--
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_value_set_id >--------------------------|
-- ----------------------------------------------------------------------------

Function Get_Value_Set_Id (p_child_node_type IN Varchar2,
                           p_parent_node_id  IN Number,
                           p_hierarchy_type  IN Varchar2 )
Return Number
Is
--
Cursor csr_value_set_id (p_value_set_name   IN Varchar2)
Is
Select FLEX_VALUE_SET_ID
From   FND_FLEX_VALUE_SETS
Where  validation_type         = 'F'
And
FLEX_VALUE_SET_NAME    = p_value_set_name;

Cursor csr_value_set_name(p_parent_node_type IN Varchar2)
IS
Select CHILD_VALUE_SET
from   per_gen_hier_node_types
where  CHILD_NODE_TYPE           = p_child_node_type
and    ( (PARENT_NODE_TYPE  = p_parent_node_type)
        Or
         (PARENT_NODE_TYPE is null And p_parent_node_type is null) )
and    HIERARCHY_TYPE            = p_hierarchy_type;

l_value_set_id Number(10);
l_value_set_name   Varchar2(30);
l_parent_node_type Varchar2(30);
l_proc         Varchar2(72);
--
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc := g_package||'get_value_set_id';
  hr_utility.set_location('Entering:'||l_proc, 10);
end if;
l_parent_node_type := Get_Node_Type (p_parent_node_id);
--
Open csr_value_set_name(l_parent_node_type);
Fetch csr_value_set_name into l_value_set_name;
Close csr_value_set_name;

if (upper(l_value_set_name) = 'NULL') then
 if g_debug then
  hr_utility.set_location('No Validation', 20);
 end if;
 return -1;
end if;

Open csr_value_set_id(l_value_set_name);
Fetch csr_value_set_id into l_value_set_id;
If csr_value_set_id%NotFound then
 If g_debug then
  hr_utility.set_location('Invalid Value Set', 30);
 end if;
 l_value_set_id := -2;
End if;

Close csr_value_set_id;
--
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 40);
end if;
Return l_value_set_id;

End Get_Value_Set_Id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_sql_from_vset_id >------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_sql_from_vset_id(p_vset_id IN NUMBER) RETURN VARCHAR2 IS
  --
  l_v_r  fnd_vset.valueset_r;
  l_v_dr fnd_vset.valueset_dr;
  l_str  varchar2(4000);
  l_whr  varchar2(4000);
  l_proc varchar2(72);
  --
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
   l_proc := g_package||'get_sql_from_vset_id';
   hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  fnd_vset.get_valueset(valueset_id => p_vset_id ,
                        valueset    => l_v_r,
                        format      => l_v_dr);
  --
  if g_debug then
   hr_utility.set_location('Got Valueset', 15);
  end if;
  --
  l_whr := l_v_r.table_info.where_clause ;
  l_str := rtrim('select '||l_v_r.table_info.id_column_name    ||' Entityid, '
                          ||l_v_r.table_info.value_column_name ||' Nodename from '
                          ||l_v_r.table_info.table_name        ||' '||l_whr);

  -- substitute the BG if required.
  l_str := REPLACE(l_str,':$PROFILES$.PER_BUSINESS_GROUP_ID',fnd_profile.value('
PER_BUSINESS_GROUP_ID'));
  --
  if g_debug then
   hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
  --
  RETURN (l_str);
  --
END get_sql_from_vset_id;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_if_structure_exists >----------------------|
-- ----------------------------------------------------------------------------
Function chk_if_structure_exists(p_hierarchy_type IN varchar2)
Return Varchar2
Is

l_exists Varchar2(1);
l_proc   Varchar2(72);

Cursor csr_chk_structure_exists
Is
Select 'x'
From Per_Gen_Hier_Node_Types
Where Hierarchy_Type = p_hierarchy_type;

Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc := g_package||'chk_if_structure_exists';
  hr_utility.set_location('Entering:'||l_proc, 10);
end if;
Open csr_chk_structure_exists;
Fetch csr_chk_structure_exists into l_exists;
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 20);
end if;
If csr_chk_structure_exists%NotFound then
Close csr_chk_structure_exists;
Return('N');
Else
Close csr_chk_structure_exists;
Return('Y');
End if;

End chk_if_structure_exists;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_version_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_version_exists(p_hierarchy_id   in Number,
                             p_effective_date in Date)
Is
--

Cursor csr_version_exists
is
select '1'
from
per_gen_hierarchy_versions
Where
hierarchy_id = p_hierarchy_id
and p_effective_date between date_from and nvl(date_to,p_effective_date);

--
l_exists varchar2(1);
l_proc   varchar2(72);
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc := g_package||'chk_version_exists';
  hr_utility.set_location('Entering:'||l_proc, 10);
end if;
--
-- Initialize message pub
--
 fnd_msg_pub.initialize;
--
-- check for version existance
--
 Open csr_version_exists;
 Fetch csr_version_exists into l_exists;
 if(csr_version_exists%NotFound) then
  -- Raise Error as we need atleast one version for the copy to happen.
     close csr_version_exists;
     if g_debug then
      hr_utility.set_location('Error: No version found', 20);
     end if;
     fnd_message.set_name('PQH', 'PQH_GHR_EFF_DATE_NO_VERSION');
     fnd_message.raise_error;
 else
     close csr_version_exists;
 end if;
--
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 30);
end if;

--
Exception
when others
then
 fnd_msg_pub.add;
End chk_version_exists;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_lookup_and_shared_type>--------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_lookup_and_shared_type
  ( p_lookup_code                   in     varchar2
   ,p_meaning                       in     varchar2
   ,p_description                   in     varchar2
  ) IS
--
-- Local Variable Declaration
--
l_proc 			varchar2(80) ;
l_return_status         varchar2(1) := 'N';
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc := g_package||'create_lookup_and_shared_type';
  hr_utility.set_location('Entering:'||l_proc, 10);
end if;

--
-- Issue a Savepoint
--
   Savepoint lookup_and_shared_type;
--
-- Create the HIERARCHY_TYPE lookup value
--
   create_lookup_value(p_lookup_type   => 'HIERARCHY_TYPE',
                       p_lookup_code   => p_lookup_code,
                       p_meaning       => p_meaning,
                       p_description   => p_description,
                       p_return_status => l_return_status);
--
-- Do not proceed if there are errors
--
   if (l_return_status = 'Y') then
   --
    if g_debug then
      hr_utility.set_location('Lookup Created', 20);
    end if;
   --
   -- Create the shared type entry
   --
    create_shared_type(p_lookup_code    => p_lookup_code,
                       p_meaning        => p_meaning);
   --
   if g_debug then
     hr_utility.set_location('Shared Type Created', 30);
   end if;
  end if;
--
  if g_debug then
   hr_utility.set_location('Leaving:'||l_proc, 40);
  end if;
--
Exception
When others
then
--
 Rollback to lookup_and_shared_type;
 if g_debug then
  hr_utility.set_location('An Error has occurred:'||l_proc, 50);
 end if;
--
--
End create_lookup_and_shared_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_lookup_value >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_lookup_value
  ( p_lookup_type                   in     varchar2
   ,p_lookup_code                   in     varchar2
   ,p_meaning                       in     varchar2
   ,p_description                   in     varchar2
   ,p_return_status                 out    NOCOPY varchar2
  ) IS
--
-- Declare Cursors and local variables
--
--
-- Check if the lookup code exists already
-- for the lookup_type
--
  CURSOR csr_lookup_code_unique IS
  select 'x' from HR_LOOKUPS
  where lookup_type = p_lookup_type
  and lookup_code = p_lookup_code;
--
-- Check if the lookup meaning exists already
-- for the lookup_type
--
  CURSOR csr_lookup_meaning_unique IS
  select 'x' from HR_LOOKUPS
  where lookup_type = p_lookup_type
  and meaning = p_meaning;

--
  l_proc                   varchar2(80);
  l_rowid                  varchar2(255) := null;
  l_lookup_code            varchar2(30);
  l_dummy 		   varchar2(1);
--
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc := g_package||'create_lookup_value';
 hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Issue a savepoint
  --
  savepoint create_lookup_value;
  --
  -- Enable multi messaging
  --
  if not hr_multi_message.is_message_list_enabled then
  hr_multi_message.enable_message_list;
  end if;
  --
  -- check that lookup type about to be created is either of type
  -- HIERARCHY_TYPE or HIERARCHY_NODE_TYPE only
  --
  if p_lookup_type not in ('HIERARCHY_TYPE','HIERARCHY_NODE_TYPE') then
    if g_debug then
     hr_utility.set_location('Error: Invalid lookup Type', 20);
    end if;
    fnd_message.set_name('PQH','PQH_GHR_INVALID_LOOKUP_TYPE');
    hr_multi_message.add;
  else
  --
  -- Code has been supplied so lets check its unique
  -- within the lookup type before proceeding...
    open csr_lookup_code_unique;
    fetch csr_lookup_code_unique into l_dummy;
    if csr_lookup_code_unique%found then
      close csr_lookup_code_unique;
      if g_debug then
       hr_utility.set_location('Error: Lookup code already exists', 30);
      end if;
      -- raise error as the supplied lookup_code already exists
      fnd_message.set_name('PQH','PQH_GHR_LOOKUP_CODE_EXISTS');
      fnd_message.set_token('TYPE',p_lookup_type);
      fnd_message.set_token('CODE',p_lookup_code);
      hr_multi_message.add;
    else
      close csr_lookup_code_unique;
      l_lookup_code := p_lookup_code;
    end if;
  --
  -- Check that the meaning for the lookup is unique
  -- within the lookup type before proceeding...
    open csr_lookup_meaning_unique;
    fetch csr_lookup_meaning_unique into l_dummy;
    if csr_lookup_meaning_unique%found then
      close csr_lookup_meaning_unique;
      if g_debug then
       hr_utility.set_location('Error: Meaning Already Exists', 40);
      end if;
      -- raise error as the supplied meaning already exists
      fnd_message.set_name('PQH','PQH_GHR_LOOKUP_MEANING_EXISTS');
      fnd_message.set_token('TYPE',p_lookup_type);
      fnd_message.set_token('MEANING',p_meaning);
      hr_multi_message.add;
    else
      close csr_lookup_meaning_unique;
      l_lookup_code := p_lookup_code;
    end if;
  end if;
  --
  -- Stop processing if errors encountered
  --
    hr_multi_message.end_validation_set;
  --
    if g_debug then
      hr_utility.set_location('No Validation Failures so far', 50);
    end if;
  -- Now we attempt to create an fnd_lookup_values record for the node using the
  -- supplied code and user supplied values for p_node_name (meaning)
  -- and p_description (description) for p_lookup_type (lookup type)

    fnd_lookup_values_pkg.INSERT_ROW(X_ROWID                => l_rowid,
                                     X_SECURITY_GROUP_ID    => 0,
                                     X_LOOKUP_TYPE          => p_lookup_type,
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
                                     X_MEANING              => p_meaning,
                                     X_DESCRIPTION          => p_description,
                                     X_CREATION_DATE        => SYSDATE ,
                                     X_CREATED_BY           => fnd_global.user_id,
                                     X_LAST_UPDATED_BY      => fnd_global.user_id,
                                     X_LAST_UPDATE_DATE     => SYSDATE,
                                     X_LAST_UPDATE_LOGIN    => fnd_global.login_id);

--
-- Set return value to 'Y'
--
  p_return_status := 'Y';
--
  hr_multi_message.disable_message_list;
  if g_debug then
   hr_utility.set_location('Leaving:'||l_proc, 60);
  end if;
exception
  when hr_multi_message.error_message_exist then
    --
    -- Error message(s) exist
    --
    rollback to create_lookup_value;
    p_return_status := 'N';
    hr_multi_message.disable_message_list;
    if g_debug then
     hr_utility.set_location('Errors Exist:'||l_proc, 70);
    end if;
  when others then
    --
    -- An unexpected error has occured
    --
    rollback to create_lookup_value;
    p_return_status := 'N';
    hr_multi_message.disable_message_list;
    if g_debug then
     hr_utility.set_location('Unexpected Error:'||l_proc, 80);
    end if;
    fnd_message.set_name('PQH','PQH_GHR_LOOKUP_INS_FAIL');
    fnd_message.set_token('TYPE',p_lookup_type);
    fnd_message.set_token('CODE',p_lookup_code);
    fnd_msg_pub.add;
end create_lookup_value;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_lookup_value >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_lookup_value
  ( p_lookup_type                   in     varchar2
   ,p_lookup_code                   in     varchar2
   ,p_meaning                       in     varchar2
   ,p_description                   in     varchar2
  ) IS
--
-- Declare Cursors and local variables
--
  l_proc                   varchar2(80);
  l_dummy 		         varchar2(1);
--
Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'update_lookup_value';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  fnd_lookup_values_pkg.UPDATE_ROW(X_LOOKUP_TYPE          => p_lookup_type,
                                   X_SECURITY_GROUP_ID    => 0,
                                   X_VIEW_APPLICATION_ID  => 3,
                                   X_LOOKUP_CODE          => p_lookup_code,
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
                                   X_MEANING              => p_meaning,
                                   X_DESCRIPTION          => p_description,
                                   X_LAST_UPDATE_DATE     => SYSDATE,
                                   X_LAST_UPDATED_BY      => fnd_global.user_id,
                                   X_LAST_UPDATE_LOGIN    => fnd_global.login_id);

exception
  when others then
     if g_debug then
        hr_utility.set_location('Leaving:'|| l_proc, 20);
      end if;
end update_lookup_value;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_shared_type >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_shared_type
   (p_lookup_code                   in     varchar2,
    p_meaning			    in 	   varchar2
  ) IS
--
-- Declare Cursors and local variables
--
--
-- Check if the lookup exists already
-- for the current language
--
  CURSOR csr_shared_type_entry_unique IS
  select 'x' from PER_SHARED_TYPES
  where lookup_type = 'HIERARCHY_TYPE'
  and system_type_cd   = p_lookup_code
  and shared_type_code = p_lookup_code;
--
l_proc                        varchar2(72) ;
l_object_version_number       per_shared_types.object_version_number%TYPE;
l_shared_type_id              per_shared_types.shared_type_id%TYPE;
l_dummy		 	      varchar2(1);

--
Begin
  --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      l_proc := g_package||'create_shared_type';
      hr_utility.set_location('Entering:'|| l_proc, 10);
    end if;
  --
  -- Issue a savepoint
  --
    savepoint create_shared_type;
  --
  --
  -- Enable multi messaging
  --
  if not hr_multi_message.is_message_list_enabled then
  hr_multi_message.enable_message_list;
  end if;
  --
  -- Check for duplicate shared type entry
  --
    open csr_shared_type_entry_unique;
    fetch csr_shared_type_entry_unique into l_dummy;
    if csr_shared_type_entry_unique%found then
      close csr_shared_type_entry_unique;
      if g_debug then
        hr_utility.set_location('Error: Duplicate shared type', 20);
      end if;
      -- raise error as the supplied lookup_code already exists
      fnd_message.set_name('PQH','PQH_GHR_SHARED_TYPE_DUP');
      hr_multi_message.add;
    else
      close csr_shared_type_entry_unique;
    end if;
  --
  -- Do not proceed if there are errors
  --
     hr_multi_message.end_validation_set;
  --
     if g_debug then
       hr_utility.set_location('No Validation Errors So Far', 30);
     end if;
  -- Now we attempt to create a shared types entry using the
  -- supplied code for the lookup_type 'HIERARCHY_TYPE'

       per_shared_types_api.create_shared_type
       ( p_shared_type_id        =>  l_shared_type_id
        ,p_shared_type_name      =>  p_meaning
        ,p_system_type_cd        =>  p_lookup_code
        ,p_shared_type_code      =>  p_lookup_code
        ,p_language_code         =>  userenv('LANG')
        ,p_information1		 =>  'N'
        ,p_information2		 =>  'N'
        ,p_information3		 =>  'N'
        ,p_information_category  =>  'HIERARCHY_TYPE'
        ,p_object_version_number =>  l_object_version_number
        ,p_lookup_type           =>  'HIERARCHY_TYPE'
        ,p_effective_date        =>   sysdate
        );

    hr_multi_message.disable_message_list;
    if g_debug then
      hr_utility.set_location('Leaving:'||l_proc, 40);
    end if;
Exception
when hr_multi_message.error_message_exist then
--
-- Error message exists
--
rollback to create_shared_type;
hr_multi_message.disable_message_list;
if g_debug then
 hr_utility.set_location('Error messages exist:'||l_proc, 50);
end if;
--
when others then
--
-- An unexpected error has occured
--
rollback to create_shared_type;
if g_debug then
 hr_utility.set_location('Unexpected Error'||l_proc, 60);
end if;
hr_multi_message.disable_message_list;
fnd_message.set_name('PQH','PQH_GHR_SHARED_TYPE_INS_FAIL');
fnd_msg_pub.add;
end create_shared_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_shared_type >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_shared_type
   (p_lookup_code                   in     varchar2,
    p_information2		    in	   varchar2,
    p_information3		    in	   varchar2
  ) IS
--
-- Declare Cursors and local variables
--
--
-- Check if the lookup exists already
--
  CURSOR csr_shared_type_entry IS
  select shared_type_id, object_version_number
  from PER_SHARED_TYPES
  where lookup_type = 'HIERARCHY_TYPE'
  and system_type_cd   = p_lookup_code
  and shared_type_code = p_lookup_code;
--
l_proc                        varchar2(72) ;
l_object_version_number       per_shared_types.object_version_number%TYPE;
l_shared_type_id              per_shared_types.shared_type_id%TYPE;

--
Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
   l_proc := g_package||'update_shared_type';
   hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_shared_type;
  --
  -- Initialize message pub
     fnd_msg_pub.initialize;
  --
  -- Check for duplicate shared type entry
    open csr_shared_type_entry;
    fetch csr_shared_type_entry into l_shared_type_id,l_object_version_number;
    if csr_shared_type_entry%notfound then
      close csr_shared_type_entry;
      if g_debug then
       hr_utility.set_location('Error: Lookup Code does not exist', 20);
      end if;
      -- raise error as the supplied lookup_code does not exist
      fnd_message.set_name('PQH','PQH_GHR_SHARED_TYPE_INV');
      fnd_message.raise_error;
    else
      close csr_shared_type_entry;
    end if;
  --
  -- Check that the information values are either 'Y' or 'N' only
     If ( (upper(p_information2) not in ('Y','N')) or (upper(p_information3) not in ('Y','N')) ) then
       if g_debug then
        hr_utility.set_location('Error: Info. Value is not y or n', 30);
       end if;
       --Raise error for invalid information value
       fnd_message.set_name('PQH','PQH_GHR_SHARED_TYPE_INV_INFO');
       fnd_message.raise_error;
    Else
  -- Now we attempt to update the shared types entry

       per_shared_types_api.update_shared_type
       ( p_shared_type_id        =>  l_shared_type_id
        ,p_language_code         =>  userenv('LANG')
        ,p_information2		 =>  p_information2
        ,p_information3		 =>  p_information3
        ,p_object_version_number =>  l_object_version_number
        ,p_effective_date        =>   sysdate
        );
    End if;
--
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 40);
  end if;
exception
  when others then
    --
    -- An error has occured
    --
    rollback to update_shared_type;
    if g_debug then
     hr_utility.set_location('An Error has occured:', 50);
    end if;
    fnd_msg_pub.add;
end update_shared_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_node_type >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_node_type (p_hierarchy_type   in varchar2,
			    p_child_value_set  in varchar2,
			    p_child_node_type  in varchar2,
			    p_parent_node_type in varchar2 )
is

Cursor csr_chk_duplicate
is
Select '1'
from per_gen_hier_node_types
where
hierarchy_type = p_hierarchy_type
and ( (parent_node_type = p_parent_node_type)
     or
      (parent_node_type is null and p_parent_node_type is null))
and child_node_type = p_child_node_type;
--

Cursor Csr_chk_recursion
is
Select Parent_node_type
From per_gen_hier_node_types
Start with child_node_type = p_parent_node_type
And hierarchy_type = p_hierarchy_type
Connect by child_node_type = prior parent_node_type
And hierarchy_type = p_hierarchy_type;

--
Cursor csr_next_val
is
select per_gen_hier_node_types_s.nextval
from sys.dual;

Cursor csr_chk_id_duplicate(p_next_id_val in number)
is
select '1'
from per_gen_hier_node_types
     where hier_node_type_id = p_next_id_val;

--
 l_proc   varchar2(72) ;
 l_exists varchar2(1)  ;
 l_sql    varchar2(4000);
--
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc := g_package||'create_node_type';
 hr_utility.set_location('Entering:'||l_proc, 10);
end if;
--
-- Issue a savepoint
--
  Savepoint create_node_type;
--
-- Initialize message pub
   fnd_msg_pub.initialize;
--
-- Insert Validate
--
   Open csr_chk_duplicate;
   Fetch csr_chk_duplicate into l_exists;
   If csr_chk_duplicate%found then
     if g_debug then
      hr_utility.set_location('Error:Duplicate Node Type', 20);
     end if;
     -- This is a duplicate entry..so raise error.
     Close csr_chk_duplicate;
     fnd_message.set_name('PQH','PQH_GHR_DUPLICATE_NODE_TYPE');
     fnd_message.raise_error;
   End if;
     Close csr_chk_duplicate;

   For c_rec in csr_chk_recursion
   loop
   if c_rec.parent_node_type = p_child_node_type
   then
      if g_debug then
       hr_utility.set_location('Error:Recursive Structure', 30);
      end if;
      -- This will cause recursion
      fnd_message.set_name('PQH','PQH_GHR_RECURSIVE_NODE_TYPE');
      fnd_message.raise_error;
   end if;
   End loop;

   if(p_parent_node_type = p_child_node_type)
   then
     if g_debug then
       hr_utility.set_location('Error:Recursive Structure', 40);
     end if;
     --  Again a recursive case
      fnd_message.set_name('PQH','PQH_GHR_RECURSIVE_NODE_TYPE');
      fnd_message.raise_error;
   end if;
--
--
-- All validations are passed. Insert values into the table
--
 l_sql := 'Insert into per_gen_hier_node_types
                 (hierarchy_type,
                  parent_node_type,
                  child_node_type,
                  child_value_set,
                  hier_node_type_id,
                  object_version_number)
          Values (
                  :p_hierarchy_type    ,
                  :p_parent_node_type  ,
                  :p_child_node_type   ,
                  :p_child_value_set   ,
                  per_gen_hier_node_types_s.nextval ,
                  1 )';
--
if g_debug then
 hr_utility.set_location('Sql Formed', 50);
end if;
Execute Immediate l_sql Using p_hierarchy_type, p_parent_node_type,
                              p_child_node_type, p_child_value_set;
if g_debug then
 hr_utility.set_location('Leaving:'||l_proc, 60);
end if;
Exception
when others
then
if g_debug then
 hr_utility.set_location('An Error has occured', 70);
end if;
fnd_msg_pub.add;
rollback to create_node_type;
end create_node_type;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_node_type >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_node_type (p_hierarchy_type   in varchar2,
                            p_child_value_set  in varchar2,
                            p_child_node_type  in varchar2,
                            p_parent_node_type in varchar2 ,
                            p_object_version_number in out NOCOPY number)
is
--

Cursor csr_node_type_entry
is
Select object_version_number
From
per_gen_hier_node_types
Where
hierarchy_type = p_hierarchy_type
And ( (parent_node_type = p_parent_node_type)
      Or
      (parent_node_type is null and p_parent_node_type is null))
And child_node_type = p_child_node_type
For update nowait;

--
l_object_version_number Number(15);
l_sql  varchar2(4000);
l_proc varchar2(72);
--
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc := g_package||'update_node_type';
 hr_utility.set_location('Entering:'||l_proc, 10);
end if;
--
--Issue a Savepoint
--
  Savepoint update_node_type;
--
--Initialize message pub
--
 fnd_msg_pub.initialize;
--
--Check that the node type entry exists
--
  Open csr_node_type_entry;
  Fetch csr_node_type_entry into l_object_version_number;
  If csr_node_type_entry%notfound
  then
   --
   if g_debug then
    hr_utility.set_location('Error: No Matching Node Type Entry', 20);
   end if;
   --
   Close csr_node_type_entry;
   fnd_message.set_name('PQH','PQH_GHR_NO_NODE_TYPE_ENTRY');
   fnd_message.raise_error;
  End if;
  Close csr_node_type_entry;
--
If (p_object_version_number
      <> l_object_version_number) Then
        --
        if g_debug then
	 hr_utility.set_location('Error:Invalid Object Version', 30);
        end if;
        --
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
End If;
--
-- Increment object_version_number
--
  p_object_version_number := p_object_version_number + 1;
--
-- Update the value set info
--
  l_sql := 'Update per_gen_hier_node_types
            Set child_value_set = :p_child_value_set,
                object_version_number = :p_object_version_number
            Where hierarchy_type = :p_hierarchy_type
            and   ( (parent_node_type = :p_parent_node_type)
                     Or
                    (parent_node_type is null and :p_parent_node_type is null))
            and child_node_type = :p_child_node_type';
--
  if g_debug then
   hr_utility.set_location('Sql Formed', 40);
  end if;
--
  Execute immediate l_sql using p_child_value_set, p_object_version_number,
                                p_hierarchy_type, p_parent_node_type,
                                p_parent_node_type,p_child_node_type;
--
 if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 50);
 end if;
--
Exception
 When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    if g_debug then
     hr_utility.set_location('Error: Object Locked', 60);
    end if;
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'per_gen_hier_node_types');
    fnd_msg_pub.add;
When others
then
 if g_debug then
  hr_utility.set_location('An Error has occured', 70);
 end if;
 rollback to update_node_type;
 fnd_msg_pub.add;
end update_node_type;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_node_type >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_node_type (p_hierarchy_type   in varchar2,
                            p_child_node_type  in varchar2,
                            p_parent_node_type in varchar2)
is
--
Cursor csr_node_type_entry
is
Select object_version_number
From
per_gen_hier_node_types
Where
hierarchy_type = p_hierarchy_type
And ( (parent_node_type = p_parent_node_type)
      Or
      (parent_node_type is null and p_parent_node_type is null))
And child_node_type = p_child_node_type
For update nowait;
--
Cursor csr_node_type_hierarchy
is
Select child_node_type,parent_node_type
from per_gen_hier_node_types
start with hierarchy_type = p_hierarchy_type
and ( (parent_node_type = p_parent_node_type)
      Or
	  (parent_node_type is null And p_parent_node_type is null))
and child_node_type = p_child_node_type
Connect by
prior child_node_type = parent_node_type
and ((prior child_node_type <> prior parent_node_type) or(prior child_node_type is not null and prior parent_node_type is null))
and hierarchy_type  = p_hierarchy_type
order by level desc;
--

l_object_version_number Number(15);
l_sql  varchar2(4000);
l_proc varchar2(72);
--
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc := g_package||'delete_node_type';
 hr_utility.set_location('Entering:'||l_proc, 10);
end if;
--
--Issue a Savepoint
--
  Savepoint delete_node_type;

--Initialize message pub
--
 fnd_msg_pub.initialize;
--
--
--Check that the node type entry exists
--
  Open csr_node_type_entry;
  Fetch csr_node_type_entry into l_object_version_number;
  If csr_node_type_entry%notfound
  then
   --
   if g_debug then
    hr_utility.set_location('Error: No Matching Node Type Entry', 20);
   end if;
   --
   Close csr_node_type_entry;
   fnd_message.set_name('PQH','PQH_GHR_NO_NODE_TYPE_ENTRY');
   fnd_message.raise_error;
  End if;
  Close csr_node_type_entry;
--
-- Loop through to delete node and children
--
--
--Form the delete sql
--
  l_sql := 'Delete from per_gen_hier_node_types
            Where
            hierarchy_type = :p_hierarchy_type
            And ( (parent_node_type = :p_parent_node_type)
                  Or
                  (parent_node_type is null and :p_parent_node_type is null))
            And child_node_type = :p_child_node_type';
  if g_debug then
   hr_utility.set_location('Sql Formed', 30);
  end if;

  For c_rec in csr_node_type_hierarchy
  loop
   -- Delete the row
   Execute immediate l_sql using  p_hierarchy_type,
                                 c_rec.parent_node_type,c_rec.parent_node_type,
                                 c_rec.child_node_type;
   if g_debug then
    hr_utility.set_location('Deleted a Row, Trying another...', 40);
   end if;
  End loop;

Exception
When HR_Api.Object_Locked then
--
-- The object is locked therefore we need to supply a meaningful
-- error message.
--
   if g_debug then
    hr_utility.set_location('Error: Object Locked', 50);
   end if;
   fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
   fnd_message.set_token('TABLE_NAME', 'per_gen_hier_node_types');
   fnd_msg_pub.add;
When others
then
 if g_debug then
   hr_utility.set_location('An Error has Occured', 60);
 end if;
 rollback to delete_node_type;
 fnd_msg_pub.add;
End delete_node_type;
--
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_type_structure >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_type_structure (p_hierarchy_type   in varchar2)
Is
--
Cursor csr_top_node_types
is
Select child_node_type
From
per_gen_hier_node_types
where
hierarchy_type = p_hierarchy_type
and parent_node_type is null;
--
l_proc varchar2(72);
--
Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc := g_package||'delete_type_structure';
 hr_utility.set_location('Entering:'||l_proc, 10);
end if;
--
-- Initialize message pub
--
 fnd_msg_pub.initialize;
--
-- Issue a savepoint
--
 Savepoint delete_type_structure;
--
--
-- Loop through the top node types and delete their children.
--
 For c_rec in csr_top_node_types
 Loop
 --
 -- Call the procedure to delete the node type structure.
 --
    delete_node_type(p_hierarchy_type   => p_hierarchy_type,
                     p_parent_node_type => null,
                     p_child_node_type  => c_rec.child_node_type);
    if g_debug then
     hr_utility.set_location('Deleted a row.Trying another..', 20);
    end if;
 End loop;
--
if g_debug then
 hr_utility.set_location('Leaving:'||l_proc, 30);
end if;
--
Exception
When others
then
 if g_debug then
  hr_utility.set_location('An Error has occured', 40);
 end if;
 Rollback to delete_type_structure;
 fnd_msg_pub.add;
End delete_type_structure;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_hierarchy_version >----------------------|
-- ----------------------------------------------------------------------------
--
Procedure copy_hierarchy_version ( p_type              in varchar2
     				  ,p_name              in varchar2
                                  ,p_hierarchy_id      in Number
			          ,p_hierarchy_version_id in Number
                                  ,p_version_number    in Number
                                  ,p_date_from 	       in Date
                                  ,p_date_to           in Date
				  ,p_business_group_id in Number
				  ,p_effective_date    in Date
				  ,p_new_hierarchy_id  out NoCopy Number
                                  ,p_new_hierarchy_version_id out NoCopy Number)
Is
/* l_new_hierarchy_id Number(15);
l_new_hierarchy_version_id Number(15); */
l_proc varchar2(72);
/* pqh_de_opr_grp.copy_hierarchy_version( p_type              => p_type
                                       ,p_name              => p_name
                                       ,p_hierarchy_id      => p_hierarchy_id
                                       ,p_hierarchy_version_id => p_hierarchy_version_id
                                       ,p_version_number    => p_version_number
                                       ,p_date_from         => p_date_from
                                       ,p_date_to           => p_date_to
                                       ,p_business_group_id => p_business_group_id
                                       ,p_effective_date    => p_effective_date
                                       ,p_new_hierarchy_id  => l_new_hierarchy_id
                                       ,p_new_hierarchy_version_id => l_new_hierarchy_version_id); */

 Cursor Hierarchy is
 Select Type,     ATTRIBUTE_CATEGORY, ATTRIBUTE1   , ATTRIBUTE2   , ATTRIBUTE3   , ATTRIBUTE4   ,
ATTRIBUTE5   , ATTRIBUTE6   , ATTRIBUTE7   , ATTRIBUTE8   ,
        ATTRIBUTE9   , ATTRIBUTE10  , ATTRIBUTE11  , ATTRIBUTE12  , ATTRIBUTE13  , ATTRIBUTE14  ,
ATTRIBUTE15  , ATTRIBUTE16  , ATTRIBUTE17  , ATTRIBUTE18  ,
        ATTRIBUTE19  , ATTRIBUTE20  , ATTRIBUTE21  , ATTRIBUTE22  , ATTRIBUTE23  , ATTRIBUTE24  ,
ATTRIBUTE25  , ATTRIBUTE26  , ATTRIBUTE27  , ATTRIBUTE28  ,
        ATTRIBUTE29  , ATTRIBUTE30  , INFORMATION1 , INFORMATION2 , INFORMATION3 , INFORMATION4 ,
INFORMATION5 , INFORMATION6 , INFORMATION7 , INFORMATION8 ,
        INFORMATION9 , INFORMATION10, INFORMATION11, INFORMATION12, INFORMATION13, INFORMATION14,
INFORMATION15, INFORMATION16, INFORMATION17, INFORMATION18,
        INFORMATION19, INFORMATION20, INFORMATION21, INFORMATION22, INFORMATION23, INFORMATION24,
INFORMATION25, INFORMATION26, INFORMATION27, INFORMATION28,
        INFORMATION29, INFORMATION30, INFORMATION_CATEGORY
   From Per_Gen_Hierarchy
  Where Hierarchy_id = P_Hierarchy_Id;

 Cursor Hierarchy_version is
 Select Hierarchy_Version_id, VERSION_NUMBER, HIERARCHY_ID , DATE_FROM    , DATE_TO      , STATUS
      , VALIDATE_FLAG, ATTRIBUTE_CATEGORY,
        ATTRIBUTE1    , ATTRIBUTE2   , ATTRIBUTE3   , ATTRIBUTE4   , ATTRIBUTE5   , ATTRIBUTE6   , ATTRIBUTE7   , ATTRIBUTE8   ,
        ATTRIBUTE9    , ATTRIBUTE10  , ATTRIBUTE11  , ATTRIBUTE12  , ATTRIBUTE13  , ATTRIBUTE14  , ATTRIBUTE15  , ATTRIBUTE16  , ATTRIBUTE17  , ATTRIBUTE18  ,
        ATTRIBUTE19   , ATTRIBUTE20  , ATTRIBUTE21  , ATTRIBUTE22  , ATTRIBUTE23  , ATTRIBUTE24  , ATTRIBUTE25  , ATTRIBUTE26  , ATTRIBUTE27  , ATTRIBUTE28  ,
        ATTRIBUTE29   , ATTRIBUTE30  , INFORMATION1 , INFORMATION2 , INFORMATION3 , INFORMATION4 , INFORMATION5 , INFORMATION6 , INFORMATION7 , INFORMATION8 ,
        INFORMATION9  , INFORMATION10, INFORMATION11, INFORMATION12, INFORMATION13, INFORMATION14, INFORMATION15, INFORMATION16, INFORMATION17, INFORMATION18,
        INFORMATION19 , INFORMATION20, INFORMATION21, INFORMATION22, INFORMATION23, INFORMATION24, INFORMATION25, INFORMATION26, INFORMATION27, INFORMATION28,
        INFORMATION29 , INFORMATION30, INFORMATION_CATEGORY
   From Per_Gen_Hierarchy_Versions
  Where ((P_Hierarchy_Version_Id is not NULL and Hierarchy_Version_Id = p_Hierarchy_Version_Id)
   or (Hierarchy_Id = P_Hierarchy_Id and  P_Effective_Date between Date_From and Nvl(Date_To,p_Effective_Date)));

  Cursor Nodes(C_Hierarchy_Version_id In NUMBER) is
  Select Hierarchy_Node_id
    From Per_Gen_Hierarchy_Nodes
   Where Hierarchy_Version_id = C_Hierarchy_version_id
     and Parent_Hierarchy_Node_Id is NULL;

  l_hierarchy_id               Per_Gen_Hierarchy.Hierarchy_id%TYPE;
  l_Hierarchy_version_id       Per_Gen_Hierarchy_Versions.Hierarchy_Version_Id%TYPE;
  l_Object_version_Number      Per_Gen_hierarchy.Object_Version_Number%TYPE;

Begin
--
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc := g_package||'copy_hierarchy_version';
 hr_utility.set_location('Entering:'||l_proc, 10);
end if;
--
-- Initialize message pub
--
 fnd_msg_pub.initialize;
--
 if g_debug then
  hr_utility.set_location('Calling copy proc. with p_type='||p_type, 20);
 end if;
--
PER_HIERARCHY_NODES_API.G_MODE := 'COPY' ;
--
  If P_Type = 'H' Then

     For Hierarchy_Rec in Hierarchy
     Loop
        Per_hierarchy_api.CREATE_HIERARCHY
       (P_HIERARCHY_ID               => l_Hierarchy_id     ,
        P_BUSINESS_GROUP_ID          => p_Business_group_Id,
        P_NAME                       => P_Name             ,
        P_TYPE                       => Hierarchy_rec.Type ,
        P_OBJECT_VERSION_NUMBER      => l_Object_version_Number,
        P_ATTRIBUTE_CATEGORY         => Hierarchy_rec.Attribute_Category,
        P_ATTRIBUTE1                 => Hierarchy_rec.Attribute1,
        P_ATTRIBUTE2                 => Hierarchy_rec.Attribute2,
        P_ATTRIBUTE3                 => Hierarchy_rec.Attribute3,
        P_ATTRIBUTE4                 => Hierarchy_rec.Attribute4,
        P_ATTRIBUTE5                 => Hierarchy_rec.Attribute5,
        P_ATTRIBUTE6                 => Hierarchy_rec.Attribute6,
        P_ATTRIBUTE7                 => Hierarchy_rec.Attribute7,
        P_ATTRIBUTE8                 => Hierarchy_rec.Attribute8,
        P_ATTRIBUTE9                 => Hierarchy_rec.Attribute9,
        P_ATTRIBUTE10                => Hierarchy_rec.Attribute10,
        P_ATTRIBUTE11                => Hierarchy_rec.Attribute11,
        P_ATTRIBUTE12                => Hierarchy_rec.Attribute12,
        P_ATTRIBUTE13                => Hierarchy_rec.Attribute13,
        P_ATTRIBUTE14                => Hierarchy_rec.Attribute14,
        P_ATTRIBUTE15                => Hierarchy_rec.Attribute15,
        P_ATTRIBUTE16                => Hierarchy_rec.Attribute16,
        P_ATTRIBUTE17                => Hierarchy_rec.Attribute17,
        P_ATTRIBUTE18                => Hierarchy_rec.Attribute18,
        P_ATTRIBUTE19                => Hierarchy_rec.Attribute19,
        P_ATTRIBUTE20                => Hierarchy_rec.Attribute20,
        P_ATTRIBUTE21                => Hierarchy_rec.Attribute21,
        P_ATTRIBUTE22                => Hierarchy_rec.Attribute22,
        P_ATTRIBUTE23                => Hierarchy_rec.Attribute23,
        P_ATTRIBUTE24                => Hierarchy_rec.Attribute24,
        P_ATTRIBUTE25                => Hierarchy_rec.Attribute25,
        P_ATTRIBUTE26                => Hierarchy_rec.Attribute26,
        P_ATTRIBUTE27                => Hierarchy_rec.Attribute27,
        P_ATTRIBUTE28                => Hierarchy_rec.Attribute28,
        P_ATTRIBUTE29                => Hierarchy_rec.Attribute29,
        P_ATTRIBUTE30                => Hierarchy_rec.Attribute30,
        P_INFORMATION_CATEGORY       => Hierarchy_rec.Information_Category,
        P_INFORMATION1               => Hierarchy_rec.Information1,
        P_INFORMATION2               => Hierarchy_rec.Information2,
        P_INFORMATION3               => Hierarchy_rec.Information3,
        P_INFORMATION4               => Hierarchy_rec.Information4,
        P_INFORMATION5               => Hierarchy_rec.Information5,
        P_INFORMATION6               => Hierarchy_rec.Information6,
        P_INFORMATION7               => Hierarchy_rec.Information7,
        P_INFORMATION8               => Hierarchy_rec.Information8,
        P_INFORMATION9               => Hierarchy_rec.Information9,
        P_INFORMATION10              => Hierarchy_rec.Information10,
        P_INFORMATION11              => Hierarchy_rec.Information11,
        P_INFORMATION12              => Hierarchy_rec.Information12,
        P_INFORMATION13              => Hierarchy_rec.Information13,
        P_INFORMATION14              => Hierarchy_rec.Information14,
        P_INFORMATION15              => Hierarchy_rec.Information15,
        P_INFORMATION16              => Hierarchy_rec.Information16,
        P_INFORMATION17              => Hierarchy_rec.Information17,
        P_INFORMATION18              => Hierarchy_rec.Information18,
        P_INFORMATION19              => Hierarchy_rec.Information19,
        P_INFORMATION20              => Hierarchy_rec.Information20,
        P_INFORMATION21              => Hierarchy_rec.Information21,
        P_INFORMATION22              => Hierarchy_rec.Information22,
        P_INFORMATION23              => Hierarchy_rec.Information23,
        P_INFORMATION24              => Hierarchy_rec.Information24,
        P_INFORMATION25              => Hierarchy_rec.Information25,
        P_INFORMATION26              => Hierarchy_rec.Information26,
        P_INFORMATION27              => Hierarchy_rec.Information27,
        P_INFORMATION28              => Hierarchy_rec.Information28,
        P_INFORMATION29              => Hierarchy_rec.Information29,
        P_INFORMATION30              => Hierarchy_rec.Information30,
        P_EFFECTIVE_DATE             => p_Effective_Date);
        l_Object_version_Number := NULL;
     End Loop;
     P_New_Hierarchy_Id := l_Hierarchy_id;
   End If;

   If  P_Type in ('H','V') then


     For Hierarchy_Ver_rec in Hierarchy_version Loop
        Per_hierarchy_versions_api.create_hierarchy_versions
       (P_HIERARCHY_VERSION_ID       => l_Hierarchy_Version_id,
        P_BUSINESS_GROUP_ID          => p_Business_group_Id,
        P_VERSION_NUMBER             => Nvl(P_Version_Number,1),
        P_HIERARCHY_ID               => Nvl(l_Hierarchy_id,Hierarchy_Ver_Rec.Hierarchy_Id),
        P_DATE_FROM                  => Nvl(P_Date_From,P_EFFECTIVE_DATE),
        P_DATE_TO                    => P_Date_To,
        P_OBJECT_VERSION_NUMBER      => l_Object_version_Number ,
        P_STATUS                     => 'A',
        P_VALIDATE_FLAG              => 'Y',
        P_ATTRIBUTE_CATEGORY         => Hierarchy_Ver_rec.Attribute_Category,
        P_ATTRIBUTE1                 => Hierarchy_Ver_rec.Attribute1,
        P_ATTRIBUTE2                 => Hierarchy_Ver_rec.Attribute2,
        P_ATTRIBUTE3                 => Hierarchy_Ver_rec.Attribute3,
        P_ATTRIBUTE4                 => Hierarchy_Ver_rec.Attribute4,
        P_ATTRIBUTE5                 => Hierarchy_Ver_rec.Attribute5,
        P_ATTRIBUTE6                 => Hierarchy_Ver_rec.Attribute6,
        P_ATTRIBUTE7                 => Hierarchy_Ver_rec.Attribute7,
        P_ATTRIBUTE8                 => Hierarchy_Ver_rec.Attribute8,
        P_ATTRIBUTE9                 => Hierarchy_Ver_rec.Attribute9,
        P_ATTRIBUTE10                => Hierarchy_Ver_rec.Attribute10,
        P_ATTRIBUTE11                => Hierarchy_Ver_rec.Attribute11,
        P_ATTRIBUTE12                => Hierarchy_Ver_rec.Attribute12,
        P_ATTRIBUTE13                => Hierarchy_Ver_rec.Attribute13,
        P_ATTRIBUTE14                => Hierarchy_Ver_rec.Attribute14,
        P_ATTRIBUTE15                => Hierarchy_Ver_rec.Attribute15,
        P_ATTRIBUTE16                => Hierarchy_Ver_rec.Attribute16,
        P_ATTRIBUTE17                => Hierarchy_Ver_rec.Attribute17,
        P_ATTRIBUTE18                => Hierarchy_Ver_rec.Attribute18,
        P_ATTRIBUTE19                => Hierarchy_Ver_rec.Attribute19,
        P_ATTRIBUTE20                => Hierarchy_Ver_rec.Attribute20,
        P_ATTRIBUTE21                => Hierarchy_Ver_rec.Attribute21,
        P_ATTRIBUTE22                => Hierarchy_Ver_rec.Attribute22,
        P_ATTRIBUTE23                => Hierarchy_Ver_rec.Attribute23,
        P_ATTRIBUTE24                => Hierarchy_Ver_rec.Attribute24,
        P_ATTRIBUTE25                => Hierarchy_Ver_rec.Attribute25,
        P_ATTRIBUTE26                => Hierarchy_Ver_rec.Attribute26,
        P_ATTRIBUTE27                => Hierarchy_Ver_rec.Attribute27,
        P_ATTRIBUTE28                => Hierarchy_Ver_rec.Attribute28,
        P_ATTRIBUTE29                => Hierarchy_Ver_rec.Attribute29,
        P_ATTRIBUTE30                => Hierarchy_Ver_rec.Attribute30,
        P_INFORMATION_CATEGORY       => Hierarchy_Ver_rec.Information_Category,
        P_INFORMATION1               => Hierarchy_Ver_rec.Information1,
        P_INFORMATION2               => Hierarchy_Ver_rec.Information2,
        P_INFORMATION3               => Hierarchy_Ver_rec.Information3,
        P_INFORMATION4               => Hierarchy_Ver_rec.Information4,
        P_INFORMATION5               => Hierarchy_Ver_Rec.Information5,
        P_INFORMATION6               => Hierarchy_Ver_Rec.Information6,
        P_INFORMATION7               => Hierarchy_Ver_Rec.Information7,
        P_INFORMATION8               => Hierarchy_Ver_Rec.Information8,
        P_INFORMATION9               => Hierarchy_Ver_Rec.Information9,
        P_INFORMATION10              => Hierarchy_Ver_Rec.Information10,
        P_INFORMATION11              => Hierarchy_Ver_Rec.Information11,
        P_INFORMATION12              => Hierarchy_Ver_Rec.Information12,
        P_INFORMATION13              => Hierarchy_Ver_Rec.Information13,
        P_INFORMATION14              => Hierarchy_Ver_Rec.Information14,
        P_INFORMATION15              => Hierarchy_Ver_Rec.Information15,
        P_INFORMATION16              => Hierarchy_Ver_Rec.Information16,
        P_INFORMATION17              => Hierarchy_Ver_Rec.Information17,
        P_INFORMATION18              => Hierarchy_Ver_Rec.Information18,
        P_INFORMATION19              => Hierarchy_Ver_Rec.Information19,
        P_INFORMATION20              => Hierarchy_Ver_Rec.Information20,
        P_INFORMATION21              => Hierarchy_Ver_Rec.Information21,
        P_INFORMATION22              => Hierarchy_Ver_Rec.Information22,
        P_INFORMATION23              => Hierarchy_Ver_Rec.Information23,
        P_INFORMATION24              => Hierarchy_Ver_Rec.Information24,
        P_INFORMATION25              => Hierarchy_Ver_Rec.Information25,
        P_INFORMATION26              => Hierarchy_Ver_Rec.Information26,
        P_INFORMATION27              => Hierarchy_Ver_Rec.Information27,
        P_INFORMATION28              => Hierarchy_Ver_Rec.Information28,
        P_INFORMATION29              => Hierarchy_Ver_Rec.Information29,
        P_INFORMATION30              => Hierarchy_Ver_Rec.Information30,
        P_EFFECTIVE_DATE             => p_Effective_Date);
        P_New_Hierarchy_Version_Id := l_Hierarchy_Version_id;
        For Node_Rec in Nodes(Hierarchy_Ver_Rec.Hierarchy_Version_id)
        Loop
          copy_Hierarchy
          (P_Hierarchy_version_id             => l_Hierarchy_Version_Id,
           P_Parent_Hierarchy_id              => NULL,
           P_Hierarchy_Id                     => Node_rec.Hierarchy_Node_id,
           p_Business_group_Id                => P_Business_group_id,
           p_Effective_Date                   => P_Effective_Date);
        End Loop;

     End Loop;

  End If;
--
 if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 30);
 end if;
--
PER_HIERARCHY_NODES_API.G_MODE := null ;
--
Exception
When others then
 p_new_hierarchy_id := null;
 p_new_hierarchy_version_id := null;
 --
 PER_HIERARCHY_NODES_API.G_MODE := null ;
 --
 if g_debug then
  hr_utility.set_location('An Error has occured', 40);
 end if;
 fnd_msg_pub.add();
End copy_hierarchy_version;
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< is_valid_sql >---------------------------|
-- ----------------------------------------------------------------------------
--
Function is_valid_sql(p_sql in varchar2)
Return Varchar2
Is
l_sql   Varchar2(4000);
l_valid Varchar2(1) := 'Y';
l_proc  Varchar2(72);
Begin
  if g_debug then
   l_proc := g_package||'l_valid_sql';
   hr_utility.set_location('Entering:'||l_proc, 10);
  end if;

  l_sql := 'select ''Y'' from ('||p_sql||') where rownum < 1';
--
  Begin
    Execute immediate l_sql into l_valid;
  Exception
  When no_data_found then
  l_valid := 'Y';
  When others then
  l_valid := 'N';
  End;
--
  if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 10);
  end if;
--
  Return l_valid;
--
End is_valid_sql;
--
--
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------<validate_vets_hierarchy>------------------------|
-- ----------------------------------------------------------------------------
--
Function validate_vets_hierarchy(p_hierarchy_version_id in Number)
Return Varchar2
is
--
Cursor csr_node_level is
Select level, node_type
From   Per_Gen_Hierarchy_Nodes
Where  hierarchy_version_id = p_hierarchy_version_id
Start   With parent_hierarchy_node_id is null
Connect By   prior hierarchy_node_id = parent_hierarchy_node_id;
--
l_proc      Varchar2(72);
l_max_level Number(15) := 0;
--
Begin
--
 if g_debug then
   l_proc := g_package||'validate_vets_hierarchy';
   hr_utility.set_location('Entering:'||l_proc, 10);
 end if;
--
 for l_rec in csr_node_level loop
   --
   if l_rec.level > 3 then
     return 'N';
   end if;
   --
   if ( (l_rec.level = 1 and l_rec.node_type <> 'PAR') or
        (l_rec.level = 2 and l_rec.node_type <> 'EST') or
        (l_rec.level = 3 and l_rec.node_type <> 'LOC')
      )
   then
     return 'N';
   end if;
   --
   if (l_max_level < l_rec.level) then
     l_max_level := l_rec.level;
   end if;
   --
 end loop;
--
 if l_max_level < 2 then
  return 'N';
 else
  return 'Y';
 end if;
--
End validate_vets_hierarchy;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------<get_display_value>---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_display_value(p_entity_id    IN VARCHAR2,
                           p_node_type_id IN NUMBER)
RETURN VARCHAR2 IS
--
-- get Value Set Id
 CURSOR csr_value_set IS
   SELECT flex_value_set_id
   FROM   fnd_flex_value_sets
   WHERE  validation_type      = 'F'
   AND    flex_value_set_name  = (SELECT pgt.child_value_set
                                  FROM per_gen_hier_node_types pgt
                                  WHERE pgt.hier_node_type_id = p_node_type_id);

  l_value_set_id            NUMBER(15) := NULL;
  l_id_column               VARCHAR2(200);
  l_sql_statement           VARCHAR2(2000);
  l_UPPER_SQL_statement     VARCHAR2(2000);
  l_value_id                VARCHAR2(255);
  l_name                    VARCHAR2(2000):= 'NULL';
  l_proc                    VARCHAR2(30)  := 'get_display_value';
--
--
  FUNCTION get_sql_from_vset_id(p_vset_id IN NUMBER) RETURN VARCHAR2 IS
    --
    l_v_r  fnd_vset.valueset_r;
    l_v_dr fnd_vset.valueset_dr;
    l_str  varchar2(4000);
    l_whr  varchar2(4000);
    --
  BEGIN
    --
    fnd_vset.get_valueset(valueset_id => p_vset_id ,
                          valueset    => l_v_r,
                          format      => l_v_dr);
    --
    l_whr := l_v_r.table_info.where_clause ;
    l_str := 'select '||substr(l_v_r.table_info.id_column_name,1,instr(l_v_r.table_info.id_column_name||' ',' '))||','
                      ||substr(l_v_r.table_info.value_column_name,1,instr(l_v_r.table_info.value_column_name||' ',' '))
                      ||' from '
                      ||l_v_r.table_info.table_name||' '||l_whr;
    --
    RETURN (l_str);
    --
  END get_sql_from_vset_id;
--
--
BEGIN
--
  if g_debug then
    l_proc := g_package||'get_display_value';
    hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
--
  if (p_entity_id is not null and p_node_type_id is not null) then
    -- Open cursor to get the VS
    open  csr_value_set;
    fetch csr_value_set into l_value_set_id;
    close csr_value_set;
  end if;
--

  if l_value_set_id is not null then
    --
    if g_debug then
      hr_utility.set_location('Non Null Value Set Id Retrieved', 20);
    end if;
    --

    l_sql_statement := get_sql_from_vset_id(p_vset_id => l_value_set_id);
    --
    /*
     * Convert the sql statement in upper case just once for performance reasons
     * Remove Upper from all other places.
     */
    l_UPPER_SQL_statement := UPPER(l_sql_statement);
    --

    --
    l_id_column := SUBSTR(l_UPPER_SQL_statement,(INSTR(l_UPPER_SQL_statement,'SELECT')
                     +7) ,INSTR(l_UPPER_SQL_statement,',') -
                         (INSTR(l_UPPER_SQL_statement,'SELECT')+ 7));

    /*
     * Bug 4960280: Handle cases in which 'where' or 'order by' is the last word on a line and
     * the rest of the clause is on the other line.
     */
     if INSTR(l_UPPER_SQL_statement,'ORDER BY') > 0 then
      l_sql_statement := SUBSTR(l_sql_statement,1,(INSTR(l_UPPER_SQL_statement,'ORDER BY')-1));
     end if;
    --
    -- Append And clause if Where present, else add where clause.
    if INSTR(l_UPPER_SQL_statement,'WHERE') > 0 Then
      l_sql_statement := l_sql_statement||' and '||l_id_column||' = :id ';
    else
      l_sql_statement := l_sql_statement||' where '||l_id_column||' = :id ';
    end if;
    --
    l_sql_statement := REPLACE(l_sql_statement,':$PROFILES$.PER_BUSINESS_GROUP_ID'
                               ,fnd_profile.value('PER_BUSINESS_GROUP_ID'));
    --
    if g_debug then
      hr_utility.set_location('Value Set Sql Retrieved and Processed', 30);
    end if;
    --
     BEGIN
      --
      EXECUTE IMMEDIATE l_sql_statement INTO l_value_id, l_name USING p_entity_id;
      --
      if g_debug then
      hr_utility.set_location('Valid Sql: Display Value Found', 40);
      end if;
      --
      EXCEPTION
      --
      WHEN OTHERS THEN
        --
      	if g_debug then
      	hr_utility.set_location('Invalid Entity Id or Value Set', 50);
      	end if;
      	--
      	l_name := 'INVALID_VALUE_SET, vs_id :' || l_value_set_id || ', l_value_id: ' || p_entity_id;
        --
      END;
    --
  else
  --
    if g_debug then
      hr_utility.set_location('Value Set Id Not Found: Null', 60);
    end if;
  --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 70);
  end if;
  --
  RETURN l_name;
--
END get_display_value;
--
-- ----------------------------------------------------------------------------
-- |----------------------------<gen_hier_exists>-----------------------------|
-- ----------------------------------------------------------------------------
--
Function gen_hier_exists (p_hierarchy_type in VARCHAR2)
RETURN VARCHAR2 IS
--
--
CURSOR csr_hexist IS
  select 'Y'
  from per_gen_hierarchy
  where type = p_hierarchy_type
  and rownum = 1;
--
l_return Varchar2(1) := null;
l_proc   Varchar2(72);
--
BEGIN
--
if g_debug then
 l_proc := g_package||'gen_hier_exists';
 hr_utility.set_location('Entering:'||l_proc, 10);
end if;
--
open csr_hexist;
fetch csr_hexist into l_return;
close csr_hexist;
--
if g_debug then
 hr_utility.set_location('Leaving:'||l_proc||'with val:'||nvl(l_return,'N'),20);
end if;
RETURN nvl(l_return,'N');
--
END gen_hier_exists;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------<chk_multiple_versions>------------------------|
-- ----------------------------------------------------------------------------
--
Function chk_multiple_versions(p_hierarchy_id in Number)
Return Varchar2
Is
--
Cursor csr_hier_versions
Is
Select 'Y'
From  per_gen_hierarchy_versions
Where hierarchy_id = p_hierarchy_id
And   rownum < 3;
--
l_proc varchar2(72);
--
Begin
--
if g_debug then
 l_proc := g_package||'chk_multiple_versions';
 hr_utility.set_location('Entering:'||l_proc, 10);
end if;
--
for l_rec in csr_hier_versions loop
 if csr_hier_versions%ROWCOUNT = 2 then
  if g_debug then
   hr_utility.set_location('Leaving:'||l_proc||' with val:Y', 20);
  end if;
  return 'Y';
 end if;
end loop;
--
 if g_debug then
   hr_utility.set_location('Leaving:'||l_proc||' with val:N', 30);
 end if;
 return 'N';
--
--
End chk_multiple_versions;
--
Function Node_Sequence(P_Hierarchy_version_id  IN Number,
                       P_Parent_Hierarchy_Id   IN Number)
                       Return Number is
Cursor Seq is
Select Nvl(max(SEQ),0) + 1
  From Per_gen_Hierarchy_Nodes
 Where Hierarchy_Version_Id     = p_Hierarchy_Version_id
   and Parent_Hierarchy_Node_Id = P_Parent_Hierarchy_Id;

l_Seq Per_Gen_hierarchy_nodes.Seq%TYPE;

Begin
 open Seq;
 Fetch Seq into l_seq;
 Close Seq;
 Return l_Seq;
End;
--
Procedure Main
(P_Type                             IN Varchar2,
 P_Trntype                          IN Varchar2,
 P_Code                             IN Varchar2  Default NULL,
 P_Description                      IN Varchar2  Default NULL,
 p_Code_Id                          IN Number    Default NULL,
 P_Hierarchy_version_id             IN Number    Default NULL,
 P_Parent_Hierarchy_id              IN Number    Default NULL,
 P_Hierarchy_Id                     IN Number    Default NULL,
 p_Object_Version_Number            IN Number    Default NULL,
 p_Business_group_Id                IN Number  ,
 p_Effective_Date                   IN Date) Is

 l_Hierarchy_id              Per_Gen_Hierarchy.Hierarchy_Id%TYPE;
 l_Hierarchy_Version_id      Per_Gen_Hierarchy_Versions.Hierarchy_version_Id%TYPE;
 l_HObject_version_Number    Per_Gen_Hierarchy.Object_version_Number%TYPE;
 l_Object_version_Number     Per_Gen_Hierarchy.Object_version_Number%TYPE;
 l_VObject_version_Number    Per_Gen_Hierarchy.Object_version_Number%TYPE;
 l_Hierarchy_Node_id         Per_Gen_Hierarchy_Nodes.Hierarchy_Node_Id%TYPE;
 l_version_count             Number(15);

Cursor C1 IS
 Select Hierarchy_Node_id, Object_version_number
   From Per_gen_Hierarchy_Nodes a
  Start with Hierarchy_Node_Id        = P_Hierarchy_Id
 Connect  by Parent_Hierarchy_Node_Id = Prior Hierarchy_Node_id
 Order By Nvl(Parent_Hierarchy_Node_Id,0) Desc;

Cursor C2 is
 Select Pgh.Hierarchy_id, pgh.Object_version_number hovn,
        pgv.Hierarchy_version_id, pgv.Object_Version_number vovn
   From Per_Gen_hierarchy_Versions pgv, Per_gen_hierarchy pgh
  Where Hierarchy_Version_id = P_Hierarchy_version_id
    and pgv.Hierarchy_id = pgh.Hierarchy_id;

Cursor C3 is
 Select Hierarchy_Node_Id, Object_Version_Number
   From Per_Gen_Hierarchy_Nodes
  Start With Hierarchy_Version_id = P_Hierarchy_Version_id
    and Parent_hierarchy_node_id is NULL
Connect By Parent_hierarchy_Node_id = Prior Hierarchy_Node_id
  Order By Nvl(Parent_Hierarchy_Node_id,0) Desc;

Cursor C4 is
Select count(*)
  From Per_Gen_Hierarchy_Versions pgv, Per_Gen_Hierarchy pgh
 Where pgh.Hierarchy_id = (Select Hierarchy_id
                           From   Per_Gen_Hierarchy_Versions
                           Where Hierarchy_Version_Id = P_Hierarchy_Version_Id)
   and pgv.hierarchy_id = pgh.hierarchy_id;


Begin

If p_Type = 'P' and  P_Trntype = 'I' Then

   Per_hierarchy_api.CREATE_HIERARCHY
   (P_HIERARCHY_ID               => l_Hierarchy_id     ,
    P_BUSINESS_GROUP_ID          => p_Business_group_Id,
    P_NAME                       => P_Description      ,
    P_TYPE                       => 'OPERATION_PLAN'   ,
    P_OBJECT_VERSION_NUMBER      => l_HObject_version_Number,
    P_EFFECTIVE_DATE             => p_Effective_Date);

   Per_hierarchy_versions_api.create_hierarchy_versions
   (P_HIERARCHY_VERSION_ID       => l_Hierarchy_Version_id,
    P_BUSINESS_GROUP_ID          => p_Business_group_Id,
    P_VERSION_NUMBER             => 1,
    P_HIERARCHY_ID               => l_Hierarchy_id,
    P_DATE_FROM                  => P_EFFECTIVE_DATE,
    P_OBJECT_VERSION_NUMBER      => l_VObject_version_Number ,
    P_STATUS                     => 'A',
    P_VALIDATE_FLAG              => 'Y',
    P_EFFECTIVE_DATE             => p_Effective_Date);

ElsIf  P_Trntype = 'R' Then
    --Get the number of versions for the hierarchy
    Open C4;
    Fetch C4 into l_version_count;
    Close C4;
    For C2Rec in C2
    Loop

       For C3rec in C3
       Loop
         l_Object_Version_Number := C3rec.Object_version_Number;
         Per_Hierarchy_Nodes_api.DELETE_HIERARCHY_NODES
        (P_Hierarchy_Node_Id      => C3rec.Hierarchy_Node_id,
         P_Object_Version_Number  => l_Object_Version_Number);
       End Loop;

       l_object_version_number := c2rec.vovn;
       Per_Hierarchy_versions_api.DELETE_HIERARCHY_VERSIONS
       (P_HIERARCHY_VERSION_ID   => C2rec.Hierarchy_version_id,
        P_OBJECT_VERSION_NUMBER  => l_Object_version_Number,
        P_EFFECTIVE_DATE         => P_Effective_Date);

       if(l_version_count < 2) then
         l_object_version_number := c2rec.hovn;
         Per_Hierarchy_api.Delete_Hierarchy
         (P_Hierarchy_Id          => C2rec.Hierarchy_id,
          P_Object_Version_Number => l_Object_Version_Number);
       End if;
    End Loop;

/* ElsIf p_Type = 'G' and  P_Trntype = 'I' Then

    PQH_DE_OPERATION_GROUPS_API.INSERT_OPERATION_GROUPS
   (P_EFFECTIVE_DATE            => P_EFFECTIVE_DATE,
    P_OPERATION_GROUP_CODE      => P_Code,
    P_DESCRIPTION               => P_Description,
    P_BUSINESS_GROUP_ID         => P_BUSINESS_GROUP_ID,
    P_OPERATION_GROUP_ID        => l_Node_id,
    P_OBJECT_VERSION_NUMBER     => l_Object_version_Number);

    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID        => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID        => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                => P_Code,
     P_HIERARCHY_VERSION_ID     => P_Hierarchy_version_id,
     P_NODE_TYPE                => 'OPR_GROUP',
     P_SEQ                      => Node_Sequence(P_Hierarchy_version_id,P_Parent_Hierarchy_Id),
     P_PARENT_HIERARCHY_NODE_ID => P_Parent_Hierarchy_Id,
     P_OBJECT_VERSION_NUMBER    => l_VObject_version_Number,
     P_EFFECTIVE_DATE           => p_Effective_Date);


ElsIf p_Type = 'O' and  P_Trntype = 'I' Then

   PQH_DE_OPERATIONS_API.INSERT_OPERATIONS
    (P_EFFECTIVE_DATE           => P_EFFECTIVE_DATE,
     P_OPERATION_NUMBER         => P_Code,
     P_DESCRIPTION              => P_Description,
     P_OPERATION_ID             => L_Node_id,
     P_OBJECT_VERSION_NUMBER    => l_Object_version_Number);

    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID        => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID        => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                => P_Code,
     P_HIERARCHY_VERSION_ID     => P_Hierarchy_version_id,
     P_NODE_TYPE                => 'OPR_OPTS',
     P_SEQ                      => Node_Sequence(P_Hierarchy_version_id,P_Parent_Hierarchy_Id),
     P_PARENT_HIERARCHY_NODE_ID => P_Parent_Hierarchy_Id,
     P_OBJECT_VERSION_NUMBER    => l_VObject_version_Number,
     P_EFFECTIVE_DATE           => p_Effective_Date);


  ElsIf p_Type = 'J' and  P_Trntype = 'I' Then

    PQH_DE_TKTDTLS_API.INSERT_TKT_DTLS
    (P_EFFECTIVE_DATE           => P_EFFECTIVE_DATE,
     P_TATIGKEIT_NUMBER         => P_Code,
     P_DESCRIPTION              => P_Description,
     P_TATIGKEIT_DETAIL_ID      => L_Node_id,
     P_OBJECT_VERSION_NUMBER    => l_Object_version_Number);

    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID        => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID        => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                => P_Code,
     P_HIERARCHY_VERSION_ID     => P_Hierarchy_version_id,
     P_NODE_TYPE                => 'OPR_JOB_DTLS',
     P_SEQ                      => Node_Sequence(P_Hierarchy_version_id,P_Parent_Hierarchy_Id),
     P_PARENT_HIERARCHY_NODE_ID => P_Parent_Hierarchy_Id,
     P_OBJECT_VERSION_NUMBER    => l_VObject_version_Number,
     P_EFFECTIVE_DATE           => p_Effective_Date); */

ElsIf p_Type = 'F' and  P_Trntype = 'I' Then

    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID        => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID        => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                => P_Code,
     P_HIERARCHY_VERSION_ID     => P_Hierarchy_version_id,
     P_NODE_TYPE                => 'OPR_JOB_FTR',
     P_SEQ                      => Node_Sequence(P_Hierarchy_version_id,P_Parent_Hierarchy_Id),
     P_PARENT_HIERARCHY_NODE_ID => P_Parent_Hierarchy_Id,
     P_OBJECT_VERSION_NUMBER    => l_VObject_version_Number,
     P_EFFECTIVE_DATE           => p_Effective_Date);

ElsIf P_Trntype = 'D' Then

   For C1rec in C1
   Loop

      l_Object_version_Number :=  C1rec.Object_version_Number;

      Per_Hierarchy_Nodes_Api.DELETE_HIERARCHY_NODES
      (P_HIERARCHY_NODE_ID      =>  C1rec.Hierarchy_Node_Id,
       P_OBJECT_VERSION_NUMBER  =>  l_Object_Version_Number);

   End Loop;

End If;
End;

Procedure copy_Hierarchy
(P_Hierarchy_version_id             IN Number,
 P_Parent_Hierarchy_id              IN Number,
 P_Hierarchy_Id                     IN Number,
 p_Business_group_Id                IN Number,
 p_Effective_Date                   IN Date) Is

 Cursor C1 IS
 Select Node_Type     , Entity_Id    , Hierarchy_Node_id           , Parent_Hierarchy_Node_Id    , Hierarchy_Version_Id        , ATTRIBUTE_CATEGORY,
        ATTRIBUTE1    , ATTRIBUTE2   , ATTRIBUTE3   , ATTRIBUTE4   , ATTRIBUTE5   , ATTRIBUTE6   , ATTRIBUTE7   , ATTRIBUTE8   ,
        ATTRIBUTE9    , ATTRIBUTE10  , ATTRIBUTE11  , ATTRIBUTE12  , ATTRIBUTE13  , ATTRIBUTE14  , ATTRIBUTE15  , ATTRIBUTE16  , ATTRIBUTE17  , ATTRIBUTE18  ,
        ATTRIBUTE19   , ATTRIBUTE20  , ATTRIBUTE21  , ATTRIBUTE22  , ATTRIBUTE23  , ATTRIBUTE24  , ATTRIBUTE25  , ATTRIBUTE26  , ATTRIBUTE27  , ATTRIBUTE28  ,
        ATTRIBUTE29   , ATTRIBUTE30  , INFORMATION1 , INFORMATION2 , INFORMATION3 , INFORMATION4 , INFORMATION5 , INFORMATION6 , INFORMATION7 , INFORMATION8 ,
        INFORMATION9  , INFORMATION10, INFORMATION11, INFORMATION12, INFORMATION13, INFORMATION14, INFORMATION15, INFORMATION16, INFORMATION17, INFORMATION18,
        INFORMATION19 , INFORMATION20, INFORMATION21, INFORMATION22, INFORMATION23, INFORMATION24, INFORMATION25, INFORMATION26, INFORMATION27, INFORMATION28,
        INFORMATION29 , INFORMATION30, INFORMATION_CATEGORY
   From Per_gen_Hierarchy_Nodes a
Start with Hierarchy_Node_Id        = P_Hierarchy_Id
Connect by Parent_Hierarchy_Node_Id = Prior Hierarchy_Node_id;

 Cursor C2 (P_Parent_Hierarchy_Node_id IN Number) is
 Select Node_Type, Entity_id
   from Per_Gen_hierarchy_Nodes
  Where Hierarchy_Node_Id    = P_Parent_Hierarchy_Node_id;

 Cursor c3(P_Node_type IN Varchar2,
           P_Entity_Id    Varchar2) Is
 Select hierarchy_Node_Id
   from Per_Gen_Hierarchy_Nodes
  Where Hierarchy_version_Id = p_Hierarchy_version_id
    and Node_type            = P_Node_Type
    and Entity_Id            = P_Entity_Id
    and Request_Id           = -999;

l_Hierarchy_Node_id         Per_Gen_Hierarchy_Nodes.Hierarchy_Node_Id%TYPE;
l_Parent_hierarchy_Node_id  Per_Gen_Hierarchy_Nodes.Parent_Hierarchy_Node_Id%TYPE;
l_Object_version_Number     Per_Gen_Hierarchy.Object_version_Number%TYPE;
l_Node_type                 Per_Gen_Hierarchy_Nodes.Node_type%TYPE;
l_Entity_Id                 Per_Gen_Hierarchy_Nodes.Entity_Id%TYPE;

Begin
l_Parent_hierarchy_Node_Id := NULL;
For C1rec in C1
Loop
If l_Parent_hierarchy_Node_Id Is NULL Then
    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID          => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID          => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                  => C1rec.Entity_id,
     P_HIERARCHY_VERSION_ID       => P_Hierarchy_version_id,
     P_NODE_TYPE                  => C1rec.Node_type,
     P_SEQ                        => Node_Sequence(P_Hierarchy_version_id,P_Parent_hierarchy_Id),
     P_PARENT_HIERARCHY_NODE_ID   => P_Parent_hierarchy_Id,
     P_OBJECT_VERSION_NUMBER      => l_Object_version_Number,
     P_REQUEST_ID                 => -999,
     P_ATTRIBUTE_CATEGORY         => C1rec.Attribute_Category,
     P_ATTRIBUTE1                 => C1rec.Attribute1,
     P_ATTRIBUTE2                 => C1rec.Attribute2,
     P_ATTRIBUTE3                 => C1rec.Attribute3,
     P_ATTRIBUTE4                 => C1rec.Attribute4,
     P_ATTRIBUTE5                 => C1rec.Attribute5,
     P_ATTRIBUTE6                 => C1rec.Attribute6,
     P_ATTRIBUTE7                 => C1rec.Attribute7,
     P_ATTRIBUTE8                 => C1rec.Attribute8,
     P_ATTRIBUTE9                 => C1rec.Attribute9,
     P_ATTRIBUTE10                => C1rec.Attribute10,
     P_ATTRIBUTE11                => C1rec.Attribute11,
     P_ATTRIBUTE12                => C1rec.Attribute12,
     P_ATTRIBUTE13                => C1rec.Attribute13,
     P_ATTRIBUTE14                => C1rec.Attribute14,
     P_ATTRIBUTE15                => C1rec.Attribute15,
     P_ATTRIBUTE16                => C1rec.Attribute16,
     P_ATTRIBUTE17                => C1rec.Attribute17,
     P_ATTRIBUTE18                => C1rec.Attribute18,
     P_ATTRIBUTE19                => C1rec.Attribute19,
     P_ATTRIBUTE20                => C1rec.Attribute20,
     P_ATTRIBUTE21                => C1rec.Attribute21,
     P_ATTRIBUTE22                => C1rec.Attribute22,
     P_ATTRIBUTE23                => C1rec.Attribute23,
     P_ATTRIBUTE24                => C1rec.Attribute24,
     P_ATTRIBUTE25                => C1rec.Attribute25,
     P_ATTRIBUTE26                => C1rec.Attribute26,
     P_ATTRIBUTE27                => C1rec.Attribute27,
     P_ATTRIBUTE28                => C1rec.Attribute28,
     P_ATTRIBUTE29                => C1rec.Attribute29,
     P_ATTRIBUTE30                => C1rec.Attribute30,
     P_INFORMATION_CATEGORY       => C1rec.Information_Category,
     P_INFORMATION1               => C1rec.Information1,
     P_INFORMATION2               => C1rec.Information2,
     P_INFORMATION3               => C1rec.Information3,
     P_INFORMATION4               => C1rec.Information4,
     P_INFORMATION5               => C1rec.Information5,
     P_INFORMATION6               => C1rec.Information6,
     P_INFORMATION7               => C1rec.Information7,
     P_INFORMATION8               => C1rec.Information8,
     P_INFORMATION9               => C1rec.Information9,
     P_INFORMATION10              => C1rec.Information10,
     P_INFORMATION11              => C1rec.Information11,
     P_INFORMATION12              => C1rec.Information12,
     P_INFORMATION13              => C1rec.Information13,
     P_INFORMATION14              => C1rec.Information14,
     P_INFORMATION15              => C1rec.Information15,
     P_INFORMATION16              => C1rec.Information16,
     P_INFORMATION17              => C1rec.Information17,
     P_INFORMATION18              => C1rec.Information18,
     P_INFORMATION19              => C1rec.Information19,
     P_INFORMATION20              => C1rec.Information20,
     P_INFORMATION21              => C1rec.Information21,
     P_INFORMATION22              => C1rec.Information22,
     P_INFORMATION23              => C1rec.Information23,
     P_INFORMATION24              => C1rec.Information24,
     P_INFORMATION25              => C1rec.Information25,
     P_INFORMATION26              => C1rec.Information26,
     P_INFORMATION27              => C1rec.Information27,
     P_INFORMATION28              => C1rec.Information28,
     P_INFORMATION29              => C1rec.Information29,
     P_INFORMATION30              => C1rec.Information30,
     P_EFFECTIVE_DATE             => p_Effective_Date);
     l_Parent_hierarchy_Node_Id := Nvl(P_Parent_hierarchy_Id, 0);

Else
    Open C2(C1rec.Parent_hierarchy_node_Id);
    Fetch C2 into L_Node_Type, l_Entity_Id;
    Close C2;
    Open C3(l_Node_type, l_Entity_Id);
    Fetch C3 into l_Parent_Hierarchy_Node_id;
    Close C3;
    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID          => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID          => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                  => C1rec.Entity_id,
     P_HIERARCHY_VERSION_ID       => P_Hierarchy_version_id,
     P_NODE_TYPE                  => C1rec.Node_type,
     P_SEQ                        => Node_Sequence(P_Hierarchy_version_id,l_Parent_Hierarchy_Node_Id),
     P_PARENT_HIERARCHY_NODE_ID   => l_Parent_hierarchy_Node_id,
     P_OBJECT_VERSION_NUMBER      => l_Object_version_Number,
     P_REQUEST_ID                 => -999,
     P_ATTRIBUTE_CATEGORY         => C1rec.Attribute_Category,
     P_ATTRIBUTE1                 => C1rec.Attribute1,
     P_ATTRIBUTE2                 => C1rec.Attribute2,
     P_ATTRIBUTE3                 => C1rec.Attribute3,
     P_ATTRIBUTE4                 => C1rec.Attribute4,
     P_ATTRIBUTE5                 => C1rec.Attribute5,
     P_ATTRIBUTE6                 => C1rec.Attribute6,
     P_ATTRIBUTE7                 => C1rec.Attribute7,
     P_ATTRIBUTE8                 => C1rec.Attribute8,
     P_ATTRIBUTE9                 => C1rec.Attribute9,
     P_ATTRIBUTE10                => C1rec.Attribute10,
     P_ATTRIBUTE11                => C1rec.Attribute11,
     P_ATTRIBUTE12                => C1rec.Attribute12,
     P_ATTRIBUTE13                => C1rec.Attribute13,
     P_ATTRIBUTE14                => C1rec.Attribute14,
     P_ATTRIBUTE15                => C1rec.Attribute15,
     P_ATTRIBUTE16                => C1rec.Attribute16,
     P_ATTRIBUTE17                => C1rec.Attribute17,
     P_ATTRIBUTE18                => C1rec.Attribute18,
     P_ATTRIBUTE19                => C1rec.Attribute19,
     P_ATTRIBUTE20                => C1rec.Attribute20,
     P_ATTRIBUTE21                => C1rec.Attribute21,
     P_ATTRIBUTE22                => C1rec.Attribute22,
     P_ATTRIBUTE23                => C1rec.Attribute23,
     P_ATTRIBUTE24                => C1rec.Attribute24,
     P_ATTRIBUTE25                => C1rec.Attribute25,
     P_ATTRIBUTE26                => C1rec.Attribute26,
     P_ATTRIBUTE27                => C1rec.Attribute27,
     P_ATTRIBUTE28                => C1rec.Attribute28,
     P_ATTRIBUTE29                => C1rec.Attribute29,
     P_ATTRIBUTE30                => C1rec.Attribute30,
     P_INFORMATION_CATEGORY       => C1rec.Information_Category,
     P_INFORMATION1               => C1rec.Information1,
     P_INFORMATION2               => C1rec.Information2,
     P_INFORMATION3               => C1rec.Information3,
     P_INFORMATION4               => C1rec.Information4,
     P_INFORMATION5               => C1rec.Information5,
     P_INFORMATION6               => C1rec.Information6,
     P_INFORMATION7               => C1rec.Information7,
     P_INFORMATION8               => C1rec.Information8,
     P_INFORMATION9               => C1rec.Information9,
     P_INFORMATION10              => C1rec.Information10,
     P_INFORMATION11              => C1rec.Information11,
     P_INFORMATION12              => C1rec.Information12,
     P_INFORMATION13              => C1rec.Information13,
     P_INFORMATION14              => C1rec.Information14,
     P_INFORMATION15              => C1rec.Information15,
     P_INFORMATION16              => C1rec.Information16,
     P_INFORMATION17              => C1rec.Information17,
     P_INFORMATION18              => C1rec.Information18,
     P_INFORMATION19              => C1rec.Information19,
     P_INFORMATION20              => C1rec.Information20,
     P_INFORMATION21              => C1rec.Information21,
     P_INFORMATION22              => C1rec.Information22,
     P_INFORMATION23              => C1rec.Information23,
     P_INFORMATION24              => C1rec.Information24,
     P_INFORMATION25              => C1rec.Information25,
     P_INFORMATION26              => C1rec.Information26,
     P_INFORMATION27              => C1rec.Information27,
     P_INFORMATION28              => C1rec.Information28,
     P_INFORMATION29              => C1rec.Information29,
     P_INFORMATION30              => C1rec.Information30,
     P_EFFECTIVE_DATE             => p_Effective_Date);
End If;

End Loop;

Update Per_Gen_Hierarchy_Nodes
   Set REQUEST_ID = 0
 Where REQUEST_ID = -999;
End;
--
End;

/
