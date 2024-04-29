--------------------------------------------------------
--  DDL for Package Body PQH_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_UTILITY" as
/* $Header: pqutilty.pkb 120.6.12010000.2 2008/08/05 13:42:14 ubhat ship $ */
--
-- Declaring global variables
--
g_warning_no            number(10) := 0;
g_next_warning_no       number(10) := 0;
g_warnings_table        warnings_tab;
--
g_rule_level_cd         pqh_rule_sets.rule_level_cd%type;
--
g_package  varchar2(33)	:= '  pqh_utility';  -- Global package name
--
g_query_date   date := null;
--
function get_shared_type_name (
          p_shared_type_id     IN Number,
          p_business_group_id  IN Number ) return varchar2 IS
Cursor csr_shd_type IS
select stt.shared_type_name
from   per_shared_types_tl stt,
       per_shared_types    st
where  stt.shared_type_id   = st.shared_type_id
and    stt.language         = userenv('lang')
and    st.shared_type_id    = p_shared_type_id
and   (st.business_group_id =  p_business_group_id or st.business_group_id is null );

l_shared_type_name  per_shared_types_tl.shared_type_name%TYPE;

Begin

  If ( p_shared_type_id IS NULL OR p_business_group_id IS NULL) Then
     Return NULL;
  End If;

  Open  csr_shd_type;
  Fetch csr_shd_type into l_shared_type_name;
  Close csr_shd_type;

  Return l_shared_type_name;

End;

--
Procedure chk_message_name(p_application_id        IN number,
                           p_message_name          IN varchar2);
--
Procedure get_rule_set_id(p_application_id        IN number,
                          p_message_name          IN varchar2,
                          p_rule_set_id          OUT nocopy number);

Procedure  get_org_business_group_id(p_organization_id     IN number,
                                     p_business_group_id  OUT nocopy number);

FUNCTION  get_exist_org_level_cd
                    (p_business_group_id        IN number,
                     p_ref_rule_set_id          IN number,
                     p_organization_id          IN number,
                     p_rule_level_cd            OUT nocopy varchar2)
          RETURN BOOLEAN;

Procedure get_rule_set_level_cd(p_rule_set_id        IN number,
                                p_rule_level_cd      OUT nocopy varchar2);

---------------------------------get_message_level_cd-------------------------
--
Procedure get_message_level_cd
                            (p_organization_id       IN number default null,
                             p_application_id        IN number,
                             p_message_name          IN varchar2,
                             p_rule_level_cd        OUT nocopy varchar2) is
--
l_proc 	varchar2(72) := g_package||'get_message_level_cd';
--
l_rule_set_id          pqh_rules.rule_set_id%type;
l_rule_level_cd        pqh_rule_sets.rule_level_cd%type;
l_business_group_id    hr_all_organization_units.business_group_id%type;
l_record_found         BOOLEAN := FALSE;
l_no_rule_sets         number(10);
--
Cursor csr_rule_set is
  Select rule_set_id
    From pqh_rules a
   Where a.application_id = p_application_id
     AND a.message_name   = p_message_name;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Chk if the message_name is valid in fnd_messages.
  --
  Chk_message_name(p_application_id    => p_application_id,
                   p_message_name      => p_message_name);
  --
  -- A rule may belong to more than one rule set . The most severe error
  -- level associated with the rule set must be raised.
  --
  p_rule_level_cd := NULL;
  l_no_rule_sets := 0;
  --
  Open csr_rule_set;
  --
  loop
  --
  --
     Fetch csr_rule_set into l_rule_set_id;
     --
     If csr_rule_set%notfound then
     --
        Exit;
     --
     End if;
     --
     l_no_rule_sets := l_no_rule_sets + 1;
     l_record_found := FALSE;
     --
     -- If organization is not provided , we will return the error level of the
     -- seeded rule set to which this rule belongs
     --
     --
     If p_organization_id IS NOT NULL then
        --
        -- Added on 17-jan-2001.
        -- Initialising l_business_group_id to NULL.
        --
        l_business_group_id := NULL;

        get_org_business_group_id(p_organization_id    => p_organization_id,
                                  p_business_group_id  => l_business_group_id);
        --
        --
        -- Changed on 17-jan-2001.
        -- If organization is not a valid org , we will return the error level
        -- for the seeded rule.
        --
        If l_business_group_id IS NOT NULL then
           --
           l_record_found := get_exist_org_level_cd
                    (p_business_group_id => l_business_group_id,
                     p_ref_rule_set_id   => l_rule_set_id,
                     p_organization_id   => p_organization_id,
                     p_rule_level_cd     => l_rule_level_cd);
           --
        Else
          l_record_found := FALSE;
        End if;
        --
     End if;
     --
     -- Check if the rule has been configured . Else return the error level
     -- of the seeded rule set.
     --
     If NOT l_record_found  then
        --
        get_rule_set_level_cd( p_rule_set_id   => l_rule_set_id,
                               p_rule_level_cd => l_rule_level_cd);
        --
     End if;
     --
     -- Return the most severe error level
     --
     If l_rule_level_cd = 'I' then
        --
        If p_rule_level_cd IS NULL then
           --
           p_rule_level_cd := l_rule_level_cd;
           --
        End if;
        --
     End if;
     --
     If l_rule_level_cd = 'W' then
        --
        If p_rule_level_cd IS NULL OR p_rule_level_cd = 'I' then
           --
           p_rule_level_cd := l_rule_level_cd;
           --
        End if;
        --
     End if;
     --
     If l_rule_level_cd = 'E' then
        --
        If p_rule_level_cd IS NULL OR p_rule_level_cd = 'I' OR p_rule_level_cd = 'W' then
           --
           p_rule_level_cd := l_rule_level_cd;
           --
        End if;
        --
     End if;
     --
     --
  End loop;
  --
  Close csr_rule_set;
  --
  --
  If l_no_rule_sets = 0 then
    --
    -- This is a valid message in fnd_messages but has not been configured.
    -- Hence return message level as error.
    --
    p_rule_level_cd := 'E' ;
    --
  End if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
     when others then
         p_rule_level_cd := null;
End;
--
----------------------------chk_message_name----------------------------------
--
Procedure chk_message_name(p_application_id        IN number,
                           p_message_name          IN varchar2) is
Cursor c1 is
  Select null
    From fnd_new_messages a
   Where a.application_id = p_application_id
     AND a.message_name   = p_message_name;
  --
  l_proc 	varchar2(72) := g_package||'chk_message_name';
  l_dummy       varchar2(1);
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if the message_name supplied is a valid message in fnd_messages
  --
  Open c1;
  --
  Fetch c1 into l_dummy;
  --
  If c1%notfound then
     Close c1;
     hr_utility.set_message(8302,'PQH_INVALID_MESSAGE_NAME');
     hr_utility.raise_error;
  End if;
  --
  Close c1;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End;
--
---------------------------get_rule_set_id-------------------------------------
--
Procedure get_rule_set_id(p_application_id        IN number,
                          p_message_name          IN varchar2,
                          p_rule_set_id          OUT nocopy number) is
Cursor c1 is
  Select rule_set_id
    From pqh_rules a
   Where a.application_id = p_application_id
     AND a.message_name   = p_message_name;
  --
  l_proc 	varchar2(72) := g_package||'get_rule_set_id';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Fetch the rule_set_id , if the message name exists in pqh_rules.
  --
  Open c1;
  --
  Fetch c1 into p_rule_set_id;
  --
  Close c1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
     when others then
        p_rule_set_id := null;
End;
--
------------------------get_org_business_group_id-----------------------------
--
Procedure  get_org_business_group_id(p_organization_id     IN number,
                                     p_business_group_id  OUT nocopy number) is
Cursor c1 is
  /**
  Select business_group_id
    From per_organization_units a
   Where a.organization_id = p_organization_id
     And a.organization_id <> a.business_group_id;
  **/
  --
  -- Added on 17-jan-2001.
  --
  -- Retreiving the business group of the organization. A rule set may be created
  -- for a business group also . Also , we support cross business groups in
  -- position transaction  . Hence looking at hr_all_organization units to
  -- get the organizations business group.
  --
  Select business_group_id
    From hr_all_organization_units a
   Where a.organization_id = p_organization_id;
  --
  l_proc 	varchar2(72) := g_package||'get_org_business_group_id';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  Open c1;
  --
  Fetch c1 into p_business_group_id;
  --
  --
  -- Change made on 17-jan-2001. Will not raise error if the org is not valid.
  --
  /**
  If c1%notfound then
     Close c1;
     hr_utility.set_message(8302,'PQH_INVALID_ORGANISATION');
     hr_utility.raise_error;
  End if;
  **/
  --
  Close c1;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
    when others then
        p_business_group_id := null;
End;
--
function get_error_level (p_organization_structure_id in number,
                          p_starting_organization_id  IN number,
                          p_referenced_rule_set_id    in number,
                          p_business_group_id         in number) return varchar2 is
  cursor c1 (p_organization_structure_id in number,
             p_starting_organization_id in number,
             p_referenced_rule_set_id in number,
             p_business_group_id in number) is
    Select rule_level_cd
    From pqh_rule_sets
   Where business_group_id      = p_business_group_id
     AND referenced_rule_set_id = p_referenced_rule_set_id
     and starting_organization_id = P_STARTING_ORGANIZATION_ID
     and organization_structure_id = p_organization_structure_id;
begin
   for i in c1 (p_organization_structure_id => p_organization_structure_id,
                p_starting_organization_id  => p_starting_organization_id,
                p_referenced_rule_set_id    => p_referenced_rule_set_id,
                p_business_group_id         => p_business_group_id) loop
      return i.rule_level_cd;
   end loop;
   return null;
end get_error_level;
--
-----------------------------get_exist_org_level_cd----------------------------
--
FUNCTION get_exist_org_level_cd
                    (p_business_group_id        IN number,
                     p_ref_rule_set_id          IN number,
                     p_organization_id          IN number,
                     p_rule_level_cd            OUT nocopy varchar2)
RETURN BOOLEAN is
--
l_organization_structure_id  pqh_rule_sets.organization_structure_id%type;
l_org_structure_version_id   per_org_structure_versions.org_structure_version_id%type;
--
l_hierarchy_level            number(10);
l_parent_node                pqh_rule_sets.organization_id%type;
--
Cursor csr_bg_config is
 Select a.rule_level_cd
   From pqh_rule_sets a
  Where a.business_group_id      = p_business_group_id
    AND a.referenced_rule_set_id = p_ref_rule_set_id
    AND a.organization_id is null
    AND a.organization_structure_id IS NULL;
--
-- Check if the rule has been configured specifically for this organization
-- alone
--
Cursor csr_org_config is
 Select a.rule_level_cd
   From pqh_rule_sets a
  Where a.business_group_id      = p_business_group_id
    AND a.referenced_rule_set_id = p_ref_rule_set_id
    AND a.organization_id = p_organization_id
    AND a.organization_structure_id IS NULL;
--
-- The foll cursor selects all distinct org structures that have been
-- configured for the passed referenced rule set and business group . Ideally
-- this cursor should return one record only
-- We do not want to select configuartions made for induvidual organizations.
--
Cursor csr_org_struct is
  Select  distinct a.organization_structure_id
    From pqh_rule_sets a
   Where a.business_group_id      = p_business_group_id
     AND a.referenced_rule_set_id = p_ref_rule_set_id
     and a.organization_structure_id IS NOT NULL;
--
-- Check if the passed organization is within the above structure and
-- return its parents if any , if the organization belongs to the org
-- structure
--
Cursor csr_parent_nodes(P_ORGANIZATION_ID in number ,
                        P_ORG_STRUCTURE_VERSION_ID in number) is
  Select level,organization_id_parent
    From per_org_structure_elements
   where org_structure_version_id = p_org_structure_version_id
connect by prior organization_id_parent = organization_id_child
       and ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID
  start with ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID
        and organization_id_child = P_ORGANIZATION_ID
  UNION
  Select 0,p_organization_id
    from dual
  order by 1 asc;
--
l_proc 	varchar2(72) := g_package||'get_exist_org_level_cd';
l_oh_rule boolean := FALSE;
l_rule_level_cd varchar2(30);
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if the rule has been configured for the organization alone
  --
  Open csr_org_config;
  --
  Fetch csr_org_config into p_rule_level_cd;
  --
  If csr_org_config%found then
     hr_utility.set_location('Rule is defined for the org'||l_proc, 10);
     Close csr_org_config;
     RETURN TRUE;
  End if;
  --
  Close csr_org_config;
  --
  --
  -- Check if the rule has been configured for any parent organization
  -- of the passed organization
  --
  Open csr_org_struct;
  --
  Loop
     --
     Fetch csr_org_struct into l_organization_structure_id;
     --
     If csr_org_struct%notfound then
        exit;
     End if;
     --
     -- get the latest version id for the organization structure.
     --
     get_org_structure_version_id
                 (p_org_structure_id        => l_organization_structure_id,
                  p_org_structure_version_id=> l_org_structure_version_id);
     --
     -- Select all parent nodes for the organization
     --
-- severest rule is being computed here if we get E, we go out of
-- this loop immediately else, we loop thru all the combinations
     Open csr_parent_nodes(p_organization_id          => p_organization_id,
                           p_org_structure_version_id => l_org_structure_version_id);
     --
     loop
     --
       Fetch csr_parent_nodes into l_hierarchy_level,l_parent_node;
       --
       hr_utility.set_location('node is '||l_parent_node, 30);
       hr_utility.set_location('hierarchy_level is '||l_hierarchy_level, 40);
       If csr_parent_nodes%notfound then
          exit;
       End if;
       --
       -- Check if the rule set has been configured for the parent node fetched
       --
       l_rule_level_cd := get_error_level (p_organization_structure_id => l_organization_structure_id,
                                           p_starting_organization_id  => l_parent_node,
                                           p_business_group_id         => p_business_group_id,
                                           p_referenced_rule_set_id    => p_ref_rule_set_id);
       if l_rule_level_cd is not null then
          hr_utility.set_location('found a rule for node'||l_parent_node||' and rule is'||l_rule_level_cd, 30);
          l_oh_rule := TRUE;
          if l_rule_level_cd ='E' then
             p_rule_level_cd := 'E' ;
             Close csr_org_struct;
             Close csr_parent_nodes;
             RETURN TRUE;
          else
             hr_utility.set_location('did not found a E'||l_proc, 40);
             -- severest rule not found so far, should go for next hierarchy, if any
             if nvl(p_rule_level_cd,'I') ='I' then
                p_rule_level_cd := l_rule_level_cd;
             end if;
             exit;
          -- lowest rule defined for this org-hier is pulled, we don't need to go thru
          -- this hierachy any longer.
          end if;
       end if;
       --
     End loop;
     --
     Close csr_parent_nodes;
     --
  End loop;
  --
  Close csr_org_struct;
  if l_oh_rule then
     hr_utility.set_location('OH rule is being returned'||p_rule_level_cd, 50);
     RETURN TRUE;
  end if;
  --
  --bg check
  --
  Open csr_bg_config;
  --
  Fetch csr_bg_config into p_rule_level_cd;
  --
  If csr_bg_config%found then
     hr_utility.set_location('BG rule is being returned'||p_rule_level_cd, 50);
     Close csr_bg_config;
     RETURN TRUE;
  End if;
  --
  Close csr_bg_config;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  RETURN FALSE;
  --
exception
    when others then
        p_rule_level_cd := null;
End;
--
--
-- ----------------------------------------------------------------------------
-- |------< get_org_structure_version_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if there is a overlap of entered
--   org structure and existing org structures for the Business Group
--   and Referenced rule set
--
Procedure get_org_structure_version_id(p_org_structure_id          IN          NUMBER,
                                       p_org_structure_version_id  OUT nocopy  NUMBER) is
Cursor c1 is
  Select org_structure_version_id
    From per_org_structure_versions
   Where organization_structure_id = p_org_structure_id
     AND version_number =
         (select max(version_number)
          From per_org_structure_versions
          Where organization_structure_id = p_org_structure_id);
  --
  l_proc 	varchar2(72) := g_package||'g_org_structure_version_id';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open c1;
  Fetch c1 into p_org_structure_version_id;
  If c1%notfound then
     hr_utility.set_message(8302, 'PQH_ORG_STRUCT_VER_NOT_FOUND');
     hr_utility.raise_error;
  End if;
  Close c1;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
    when others then
        p_org_structure_version_id := null;
End;
--
-- ----------------------------------------------------------------------------
-- |------< get_rule_set_level_cd>------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure returns the level_cd for the rule_set_id
--
Procedure get_rule_set_level_cd(p_rule_set_id        IN number,
                                p_rule_level_cd      OUT nocopy varchar2) is
  --
  Cursor c1 is
  Select rule_level_cd
    From pqh_rule_sets a
   Where a.rule_set_id = p_rule_set_id;
  --
  l_proc 	varchar2(72) := g_package||'get_rule_set_level_cd';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    Open c1;
    Fetch c1 into p_rule_level_cd;
    If c1%NOTFOUND then
       p_rule_level_cd := NULL;
       Close c1;
       hr_utility.set_message(8302, 'PQH_INVALID_RULE_SET_ID');
       hr_utility.raise_error;
    End if;
    Close c1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
exception
     when others then
         p_rule_level_cd := null;
End get_rule_set_level_cd;
--
-- ----------------------------------------------------------------------------
-- |------< get_language_code>------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure returns the language_code
--
Procedure get_language_code( p_language_code  OUT nocopy varchar2) is
  --
  Cursor c1 is
  Select userenv('LANG')
    From dual;
  --
  l_proc 	varchar2(72) := g_package||'get_language_code';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
    Open c1;
    Fetch c1 into p_language_code;
    If c1%NOTFOUND then
       p_language_code := 'US';
    End if;
    Close c1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
exception
      when others then
           p_language_code := null;
End get_language_code;
--
--
Procedure init_query_date is
  --
  l_proc 	     varchar2(72) := g_package||'init_query_date';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_query_date         := null;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end;
--
Procedure set_query_date(p_effective_date in date) is
  --
  l_proc 	     varchar2(72) := g_package||'set_query_date';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_query_date         := p_effective_date;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end;
--
--
function get_query_date return date is
  --
  l_proc 	     varchar2(72) := g_package||'get_query_date';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  return nvl(g_query_date, trunc(sysdate));
  --
end;
--
-- ----------------------------------------------------------------------------
-- |------< init_warnings_table>------|
-- ----------------------------------------------------------------------------
--
Procedure init_warnings_table is
  --
  dummy_table        warnings_tab;
  l_proc 	     varchar2(72) := g_package||'init_warnings_table';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  g_warning_no         := 0;
  g_next_warning_no    := 0;
  --
  --Tried to assign NULL to the table . Does not work
  --Hence assigned another dummy table
  --g_warnings_table   := NULL;
  --
  -- g_warnings_table     := dummy_table;
  g_warnings_table.DELETE;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end;
--
-- ----------------------------------------------------------------------------
-- |------< insert_warning>------|
-- ----------------------------------------------------------------------------
--
Procedure insert_warning(p_warnings_rec IN warnings_rec) is
  --
  l_new_warning      boolean := TRUE;
  cnt                number(10);
  l_proc 	     varchar2(72) := g_package||'insert_warning';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if this warning is already in table .
  --
  If g_warning_no > 0 then
     --
     For cnt in g_warnings_table.first..g_warnings_table.last loop
         --
         If p_warnings_rec.message_text = g_warnings_table(cnt).message_text then
            --
            l_new_warning := false;
            Exit;
            --
         End if;
         --
     End loop;
     --
  End if;
  --
  -- Insert new warning
  --
  If l_new_warning then
     --
     -- Increment the warning no
     --
     g_warning_no := g_warning_no + 1;
     --
     -- Insert the input record into the next row in the warnings table.
     --
     g_warnings_table(g_warning_no).message_text := p_warnings_rec.message_text;
     --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
-- ----------------------------------------------------------------------------
-- |------< get_next_warning>------|
-- ----------------------------------------------------------------------------
--
Procedure get_next_warning(p_warnings_rec OUT nocopy warnings_rec) is
 --
 l_proc 	     varchar2(72) := g_package||'get_next_warning';
 --
Begin
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 g_next_warning_no := g_next_warning_no + 1;
 --
 -- Raise error if the next warning no exceeds the actual number of warnings
 -- in the table.
 --
 If g_next_warning_no > g_warning_no then
    --
    hr_utility.set_message(8302,'PQH_INVALID_WARNING_NO');
    hr_utility.raise_error;
    --
 End if;
 --
 -- Return the next warning.
 --
 p_warnings_rec.message_text := g_warnings_table(g_next_warning_no).message_text ;
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
exception
    when others then
        p_warnings_rec := null;
End;
--
-- ----------------------------------------------------------------------------
-- |------< get_all_warnings>------|
-- ----------------------------------------------------------------------------
--
Procedure get_all_warnings(p_warnings_tab OUT nocopy warnings_tab,
                           p_no_warnings  OUT nocopy number) is
  --
  l_proc 	     varchar2(72) := g_package||'get_all_warnings';
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  p_warnings_tab := g_warnings_table;
  --
  --
  p_no_warnings  := g_warning_no;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
exception
    when others then
        p_no_warnings := null;
End;

-- Rewriting hr_utility functions

-----------------------------------set_message --------------------------------
--
--  NAME
--    set_message
--  DESCRIPTION
--    Calls FND_MESSAGE.SET_NAME and sets the message name and application id as
--    package globals.
--
  Procedure set_message (applid            in number,
                         l_message_name    in varchar2,
                         l_organization_id in number default NULL) is
  --
  l_rule_level_cd        pqh_rule_sets.rule_level_cd%type;
  --
  --
  l_proc 	     varchar2(72) := g_package||'set_message';
  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    --
    get_message_level_cd(p_application_id => applid,
                         p_message_name   => l_message_name,
                         p_organization_id=> l_organization_id,
                         p_rule_level_cd  => l_rule_level_cd);
    --
    g_rule_level_cd := l_rule_level_cd;
    --
    hr_utility.set_message(applid,l_message_name);
    --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
  end set_message;
--
-----------------------------------set_warning_message --------------------------------
--
--  NAME
--    set_warning_message
--  DESCRIPTION
--    Calls FND_MESSAGE.SET_NAME and sets the message name and application id as
--    package globals. Also sets the global rule level code as warning.
--	If the g_rule_level_cd is warning error is not thrown, only a warning is
--	shown.
--
  Procedure set_warning_message (applid            in number,
                         l_message_name    in varchar2) is
  --
  --
  --
  l_proc 	     varchar2(72) := g_package||'set_message';
  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    --
    g_rule_level_cd := 'W';
    --
    hr_utility.set_message(applid,l_message_name);
    --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
  end set_warning_message;
--
------------------------------ set_message_token ------------------------------
--
--  NAME
--    set_message_token
--  DESCRIPTION
--    Sets message token. Just calls AOL routine.
--
  procedure set_message_token (l_token_name in varchar2,
                               l_token_value in varchar2) is
  --
  l_proc 	     varchar2(72) := g_package||'set_message_token';
  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    hr_utility.set_message_token(l_token_name,l_token_value);
    --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
  end set_message_token;

------------------------------ set_message_token ------------------------------
--  NAME
--    set_message_token
--
--  DESCRIPTION
--    Overloaded: Sets up a translated message token
--    Note that the application id passed a parameter is ignored.The FND_MESSAGE
--    routine uses the application of the last message that was set.
--
  procedure set_message_token (l_applid        in number,
                               l_token_name    in varchar2,
                               l_token_message in varchar2) is
  --
  l_proc 	     varchar2(72) := g_package||'set_message_token';
  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_utility.set_message_token(l_applid,l_token_name,l_token_message);
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
  end set_message_token;
------------------------------raise_error---------------------------------------
--  NAME
--   raise_error
--
--  DESCRIPTION
--    Raises error based on g_rule_level_cd
--
Procedure raise_error is
  --
  l_warnings_rec warnings_rec;
  --
  l_proc 	     varchar2(72) := g_package||'raise_error';
  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    If g_rule_level_cd = 'E' then
       hr_utility.raise_error;
    Elsif g_rule_level_cd = 'W' then
       l_warnings_rec.message_text := hr_utility.get_message;
       insert_warning(p_warnings_rec => l_warnings_rec);
    End if;
    --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End raise_error;
--
--
-------------------------------------------------------------------------------
--                  decode_assignment_name
-------------------------------------------------------------------------------
--
-- Description :  Common function to return assignment_name given assignment_id
--
FUNCTION DECODE_ASSIGNMENT_NAME(p_assignment_id in number)
         Return VARCHAR2 is

ret_assignment_name  varchar2(500);
--
  l_proc  varchar2(72) := g_package||'decode_assignment_name';
--
Cursor assignment_name is
  Select substr(ppl.full_name||'('||hr_general.decode_lookup('PQH_GEN_LOV','EMP_
NUM')||'='||ppl.employee_number||')',1,240)
    from per_all_assignments_f asg , per_all_people_f ppl,fnd_sessions ses
   where asg.assignment_id = p_assignment_id
     and asg.person_id     = ppl.person_id
     and ses.session_id = userenv('sessionid')
     and ses.effective_date between ppl.effective_start_date and ppl.effective_end_date
     and ses.effective_date between asg.effective_start_date and asg.effective_end_date;
Begin
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
  Open assignment_name;
  Fetch assignment_name into ret_assignment_name;
  Close assignment_name;
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 Return ret_assignment_name;
End;
--
--
function get_message_type_cd return varchar2 is
  l_proc 	     varchar2(72) := g_package||'get_message_type_cd';
  --
  begin
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    return g_rule_level_cd;
    --
    hr_utility.set_location('Leaving:'||l_proc, 10);
end;
--
--
function get_message return varchar2 is
  l_proc 	     varchar2(72) := g_package||'get_message';
begin
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    return hr_utility.get_message;
    --
    hr_utility.set_location('Leaving:'||l_proc, 10);
end;
--
--
procedure save_point is
begin
 savepoint a;
end;
--
procedure roll_back is
begin
rollback to a;
end;
--
--
procedure set_session_date(p_date date) is
 PRAGMA                  AUTONOMOUS_TRANSACTION;
 l_commit number;
begin
 dt_fndate.change_ses_date(trunc(p_date),l_commit);
 if l_commit=1 then
   commit;
 end if;
end;
--
-- ------------------------------------------------------------------------
--
FUNCTION get_pos_budget_values(p_position_id       in  number,
                               p_period_start_dt  in  date,
                               p_period_end_dt    in  date,
                               p_unit_of_measure   in  varchar2)
RETURN number is
--
l_business_group_id         hr_all_positions_f.business_group_id%type;
l_position_name             hr_all_positions_f.name%type := NULL;
l_pbv       number(27,2);
--
 Cursor csr_pos is
   Select name,business_group_id
     From hr_all_positions_f_vl
    Where position_id = p_position_id;
--
l_proc        varchar2(72) := g_package||'get_pos_budget_values';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 --
 -- Obtain the business group and position_name of the position.
 --
 Open csr_pos;
 Fetch csr_pos into l_position_name, l_business_group_id;
 Close csr_pos;
 --
 -- Call function that returns commitment.
 --
 l_pbv := hr_discoverer.get_actual_budget_values
 (p_unit             => p_unit_of_measure,
  p_bus_group_id     => l_business_group_id ,
  p_organization_id  => NULL ,
  p_job_id           => NULL ,
  p_position_id      => p_position_id ,
  p_grade_id         => NULL ,
  p_start_date       => p_period_start_dt ,
  p_end_date         => p_period_end_dt ,
  p_actual_val       => NULL
 );
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
RETURN l_pbv;
--
Exception When others then
  --
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
  --
End;
--
Procedure get_all_unit_desc(p_worksheet_detail_id in number,
                            p_unit1_desc             out nocopy varchar2,
                            p_unit2_desc             out nocopy varchar2,
                            p_unit3_desc             out nocopy varchar2) is
   cursor c1 is select budget_unit1_id,budget_unit2_id,budget_unit3_id
                from pqh_budgets bgt,pqh_worksheets wks,
pqh_worksheet_details wkd
                where wkd.worksheet_id = wks.worksheet_id
                and wks.budget_id = bgt.budget_id
                and wkd.worksheet_detail_id = p_worksheet_detail_id;
   l_budget_unit1_id pqh_budgets.budget_unit1_id%type;
   l_budget_unit2_id pqh_budgets.budget_unit1_id%type;
   l_budget_unit3_id pqh_budgets.budget_unit1_id%type;
begin
   if p_worksheet_detail_id is not null then
      begin
         open c1;
         fetch c1 into
l_budget_unit1_id,l_budget_unit2_id,l_budget_unit3_id;
         close c1;
      exception
         when others then
            hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
            hr_utility.raise_error;
      end;
      p_unit1_desc := get_unit_desc(l_budget_unit1_id);
      if l_budget_unit2_id is not null then
         p_unit2_desc := get_unit_desc(l_budget_unit2_id);
      else
         p_unit2_desc := null;
      end if;
      if l_budget_unit3_id is not null then
         p_unit3_desc := get_unit_desc(l_budget_unit3_id);
      else
         p_unit3_desc := null;
      end if;
   else
      hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
      hr_utility.raise_error;
   end if;
exception
   when others then
      p_unit1_desc  := null;
      p_unit2_desc := null;
      p_unit3_desc := null;
      hr_utility.set_message(8302,'PQH_INVALID_WKD_PASSED');
      hr_utility.raise_error;
end get_all_unit_desc;


function get_unit_desc(p_unit_id in number) return varchar2 is
   cursor c1 is select shared_type_name
                from per_shared_types_vl
                where lookup_type ='BUDGET_MEASUREMENT_TYPE'
                and shared_type_id = p_unit_id;
   l_shared_type_name per_shared_types_vl.shared_type_name%type;
begin
   open c1;
   fetch c1 into l_shared_type_name;
   close c1;
   return l_shared_type_name;
exception
   when others then
      hr_utility.set_message(8302,'PQH_INVALID_UNIT_ENTERED');
      hr_utility.raise_error;
end get_unit_desc;
--
function chk_pos_pending_txns(p_position_id in number, p_position_transaction_id in number default null) return varchar2 is
l_count_pending_txns number:=0;
--
cursor c_count_pending_txns(p_position_id number) is
select count(*)
from pqh_position_transactions ptx
where position_id = p_position_id
and nvl(ptx.transaction_status,'PENDING') in ('APPROVED','SUBMITTED','PENDING')
and position_transaction_id <> nvl(p_position_transaction_id, -1);
--
begin
  open c_count_pending_txns(p_position_id);
  fetch c_count_pending_txns into l_count_pending_txns;
  close c_count_pending_txns;
  if l_count_pending_txns <> 0 then
    return 'Y';
  else
    return 'N';
  end if;
  return l_count_pending_txns;
end;
--
--
function get_attribute_name(p_table_alias in varchar2, p_column_name in varchar2) return varchar2 is
l_attribute_name varchar2(100);
--
cursor c_attributes(p_table_alias in varchar2, p_column_name in varchar2) is
select attribute_name
from pqh_table_route trt, pqh_attributes_vl att
where trt.table_route_id = att.master_table_route_id
and trt.table_alias = p_table_alias
and att.column_name = p_column_name;
--
begin
  open c_attributes(p_table_alias, p_column_name);
  fetch c_attributes into l_attribute_name;
  close c_attributes;
  return l_attribute_name;
end;
--
procedure change_ptx_txn_status(
	p_position_transaction_id number,
	p_transaction_status varchar2,
	p_effective_date date default sysdate) is
--
l_object_version_number		number;
l_review_flag               pqh_position_transactions.review_flag%TYPE;  -- bug 6112935
--
cursor c_position_transactions(p_position_transaction_id number) is
select object_version_number
from pqh_position_transactions ptx
where position_transaction_id  = p_position_transaction_id;
--
begin
  open  c_position_transactions(p_position_transaction_id);
  fetch c_position_transactions into l_object_version_number;
  close c_position_transactions;
  --lock the position transaction.
    pqh_ptx_shd.lck
  (
   p_position_transaction_id        => p_position_transaction_id
  ,p_object_version_number          => l_object_version_number
  );

hr_utility.set_location('p_status '||p_transaction_status||'l_review_flag '||l_review_flag, 15);
 -- If condition added for Bug 6112905 / Modified for bug 6524175
 if p_transaction_status in ('REJECT','TERMINATE','SUBMITTED') then
   l_review_flag := 'N';
 end if;
hr_utility.set_location('p_status '||p_transaction_status||'l_review_flag '||l_review_flag, 25);

  -- Update the position transaction
  pqh_position_transactions_api.update_position_transaction
  (
   p_validate                       => false
  ,p_position_transaction_id        => p_position_transaction_id
  ,p_object_version_number          => l_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_transaction_status             =>  p_transaction_status    -- bug 6112905
  ,p_review_flag                    =>  l_review_flag           -- bug 6112905
  );
  --
end;
--
--
function position_exists(p_position_id number, p_effective_date date) return varchar2 is
l_dummy  varchar2(10);
cursor c_position is
select 'x'
from hr_all_positions_f
where position_id = p_position_id
and p_effective_date between effective_start_date and effective_end_date;
begin
  open c_position;
  fetch c_position into l_dummy;
  if c_position%found then
    close c_position;
    return 'Y';
  else
    close c_position;
    return 'N';
  end if;
  close c_position;
end;
--
function position_start_date(p_position_id number) return date is
l_date  date;
cursor c_position is
select min(effective_start_date)
from hr_all_positions_f
where position_id = p_position_id;
begin
  open c_position;
  fetch c_position into l_date;
  if c_position%found then
    close c_position;
    return l_date;
  else
    close c_position;
    return null;
  end if;
  close c_position;
end;
--
--
function decode_grade_rule (
--
         p_grade_rule_id      number, p_type  varchar2) return varchar2 is
--
cursor csr_grade_rule is
         select    value, minimum, maximum, mid_value
         from      pay_grade_rules
         where     grade_rule_id  = p_grade_rule_id;
--
l_point_value   number;
l_min           number;
l_mid           number;
l_max           number;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_grade_rule_id is not null then
  --
  open csr_grade_rule;
  fetch csr_grade_rule into l_point_value, l_min, l_mid, l_max;
  close csr_grade_rule;
  --
end if;
if p_type = 'VALUE' then
  return l_point_value;
elsif p_type = 'MIN' then
  return l_min;
elsif p_type = 'MID' then
  return l_mid;
elsif p_type = 'MAX' then
  return l_max;
end if;
return -1;
end decode_grade_rule;
--
-----------------------------------------------------------------------------
--
-- Procedure to check if a valid value set id is passed and to return its
-- values
--
Procedure chk_if_valid_value_set( p_value_set_id  in number,
                                  p_value_set    out nocopy g_value_set%type,
                                  p_error_status out nocopy number)
is
--
-- The foll cursor returns values of a value set id.
--
Cursor csr_validation_type is
 Select *
   from fnd_flex_value_sets
  where flex_value_set_id = p_value_set_id;
--
l_validation_type  fnd_flex_value_sets.validation_type%type;
l_map              varchar2(2000);
--
Begin
  --
  -- Check if a valid value set id is passed and fetch its values.
  --
  Open csr_validation_type;
  Fetch csr_validation_type into p_value_set;
  If csr_validation_type%notfound then
     --
     -- Invalid value set id
     --
     p_error_status := 1;
  Else
     p_error_status := 0;
  End if;
  Close csr_validation_type;
  --
exception
   when others then
      p_value_set := null;
      p_error_status := null;
End;
--
----------------------------------------------------------------------------
--
-- Procedure to return the format mask for a number field given the size
-- and its precision.
--
Procedure get_num_format_mask(p_size         in     number,
                              p_precision    in     number,
                              p_format_mask  out  nocopy   varchar2) is
--
l_decimal  varchar2(50) := NULL;
--
Begin
 --
 p_format_mask := NULL;
 --
 -- If there is a decimal part, then form the decimal part firt.
 --
 If p_precision > 0 then
    --
    l_decimal := '.';
    -- Form decimal part.
    For i in 1..p_precision loop
        l_decimal := l_decimal||'9';
    End loop;
    --
    -- The size of the field must be greater than the precision + 1
    --
    If p_size > p_precision+1 then
       --
       -- Form the format mask for the integral part.
       --
       For i in 1..(p_size - (p_precision + 1)) loop
           p_format_mask := p_format_mask||'9';
       End loop;
       --
       -- Concatenate with the mask for the decimal part.
       --
       p_format_mask := p_format_mask || l_decimal;
    Else
       p_format_mask := l_decimal;
    End if;
 Else
    --
    -- If there is no decimal part, then
    --
    If p_size > 0 then
       --
       -- Create the format mask for the integral part alone.
       --
       For i in 1..p_size loop
           p_format_mask := p_format_mask ||'9';
       End loop;
    End if;
    --
 End if;
--
exception
    when others then
      p_format_mask := null;
End;
--
----------------------------------------------------------------------------
--
-- Given the value set id , the item returns the corresponding sql statement
-- / its format .
--
Procedure get_valueset(p_value_set_id     in number,
                       p_validation_type out nocopy varchar2,
                       p_num_format_mask out nocopy varchar2,
                       p_min_value       out nocopy varchar2,
                       p_max_value       out nocopy varchar2,
                       p_sql_stmt        out nocopy varchar2,
                       p_error_status    out nocopy number) is
--
l_map              varchar2(2000);
l_value_set        g_value_set%type;
l_error_status     number(10);
--
Begin
  --
  -- Check if a valid value set id is passed and fetch its validation type.
  --
  chk_if_valid_value_set( p_value_set_id  => p_value_set_id,
                          p_value_set     => l_value_set,
                          p_error_status  => l_error_status);
  --
  If l_error_status <> 0 then
     --
     -- Invalid value set id
     --
     p_error_status := 1;
     p_sql_stmt := NULL;
     --
  Else
     p_validation_type := l_value_set.validation_type;

     If l_value_set.validation_type = 'F' then
        --
        -- Call the fnd function that returns the sql stmt;
        --
        fnd_flex_val_api.get_table_vset_select
        (
        p_value_set_id   => p_value_set_id,
        x_select         => p_sql_stmt,
        x_mapping_code   => l_map,
        x_success        => p_error_status);
        --
        p_min_value := NULL;
        p_max_value := NULL;
        p_num_format_mask := NULL;
        --
     Elsif l_value_set.validation_type = 'N' then
        --
        -- The validation type is  none
        --
        p_min_value := l_value_set.minimum_value;
        p_max_value := l_value_set.maximum_value;
        --
        -- If number , return its format mask.
        --
        If l_value_set.format_type = 'N' then
           --
           get_num_format_mask
                           ( p_size        => l_value_set.maximum_size,
                             p_precision   => l_value_set.number_precision,
                             p_format_mask => p_num_format_mask);
           --
        Else
           --
           p_num_format_mask := NULL;
           --
        End if;
        --
        p_sql_stmt  := NULL;
        p_error_status := 0;
        --
     Else
        --
        -- The validation type may be Independent / dependent.
        --
        p_sql_stmt := NULL;
        p_error_status := 0;
        p_num_format_mask := NULL;
        --
     End if;
     --
  End if;
  --
  --
exception
   when others then
      p_validation_type := null;
      p_num_format_mask := null;
      p_min_value       := null;
      p_max_value       := null;
      p_sql_stmt        := null;
      p_error_status    := null;
--

End;

Procedure get_valueset_sql(p_value_set_id     in number,
                       p_validation_type out nocopy varchar2,
                       p_sql_stmt        out nocopy varchar2,
                       p_error_status    out nocopy number) is
--
l_map              varchar2(2000);
l_value_set        g_value_set%type;
l_error_status     number(10);
l_value_column_name varchar2(2000);
l_app_tab_name varchar2(2000);
l_add_where_clause varchar2(2000);
l_id_column_name varchar2(2000);
--
Begin
  --
  -- Check if a valid value set id is passed and fetch its validation type.
  --
  chk_if_valid_value_set( p_value_set_id  => p_value_set_id,
                          p_value_set     => l_value_set,
                          p_error_status  => l_error_status);
  --
  If l_error_status <> 0 then
     --
     -- Invalid value set id
     --
     p_validation_type := null;
     p_error_status := 1;
     p_sql_stmt := NULL;
     --
  Else
     p_validation_type := l_value_set.validation_type;

     If l_value_set.validation_type = 'F' then
		select value_column_name, application_table_name,
			additional_where_clause, id_column_name into l_value_column_name, l_app_tab_name,
			l_add_where_clause, l_id_column_name from fnd_flex_validation_tables where flex_value_set_id = p_value_set_id;

     p_sql_stmt := rtrim('select '||l_id_column_name||' Id,'||l_value_column_name||' Val,'||'null Att_Name'||' from '||l_app_tab_name||' '||l_add_where_clause, ' ');
        --
     Else
        --
        -- The validation type may be Independent / dependent.
        --
        p_sql_stmt := NULL;
        p_error_status := 0;
        --
     End if;
     --
  End if;
  --
  --
exception
   when others then
      p_sql_stmt        := null;
      p_error_status    := null;
--

End get_valueset_sql;
--
FUNCTION get_display_value(p_value         IN VARCHAR2,
                           p_value_set_id  IN NUMBER) return VARCHAR2 IS
  l_value_set_rec      g_value_set%type;
  l_error_status       number(10);
  l_display            varchar2(2000);
  l_value_column_name  varchar2(2000);
  l_app_tab_name       varchar2(2000);
  l_add_where_clause   varchar2(2000);
  l_id_column_name     varchar2(2000);
  l_stmt               varchar2(2000);
  l_per_business_group number := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
BEGIN
  IF p_value_set_id IS NOT NULL THEN
  -- Check if a valid value set id is passed and fetch its validation type.
     chk_if_valid_value_set(p_value_set_id  => p_value_set_id,
                            p_value_set     => l_value_set_rec,
                            p_error_status  => l_error_status);
     IF l_error_status <> 0 THEN
     -- Invalid value set id. No value set attached. so return value given.
        l_display := p_value;
     ELSE
        IF l_value_set_rec.validation_type = 'F' THEN
           SELECT value_column_name, application_table_name, additional_where_clause, id_column_name
             INTO l_value_column_name, l_app_tab_name, l_add_where_clause, l_id_column_name
             FROM fnd_flex_validation_tables
            WHERE flex_value_set_id = p_value_set_id;
           IF l_add_where_clause IS NOT NULL THEN
              IF INSTR(UPPER(l_add_where_clause), 'ORDER BY') <> 0 THEN
                 l_add_where_clause := REPLACE(l_add_where_clause,
                                               SUBSTR(l_add_where_clause, INSTR(UPPER(l_add_where_clause), 'ORDER BY')),
                                               '');
              END IF;
              l_add_where_clause := REPLACE(UPPER(l_add_where_clause), 'WHERE', 'AND');
              l_stmt := RTRIM('select '||l_value_column_name||
                               ' from '||l_app_tab_name||' '||
                               'where '||l_id_column_name||'='||''''||p_value||''''||' '||l_add_where_clause,
                              ' ');
           ELSE
              l_stmt := RTRIM('select '||l_value_column_name||
                               ' from '||l_app_tab_name||' '||
                               'where '||l_id_column_name||'='||''''||p_value||'''',
                              ' ');
           END IF;

       hr_utility.set_location('before '||l_stmt,10);
       hr_utility.set_location('1 -> '||substr(l_stmt,1,50),11);
       hr_utility.set_location('1 -> '||substr(l_stmt,1,50),11);
       hr_utility.set_location('2 -> '||substr(l_stmt,51,50),11);
       hr_utility.set_location('3 -> '||substr(l_stmt,101,50),11);
       hr_utility.set_location('4 -> '||substr(l_stmt,151,50),11);
       hr_utility.set_location('5 -> '||substr(l_stmt,201,50),11);
       hr_utility.set_location('6 -> '||substr(l_stmt,251,50),11);
       hr_utility.set_location('7 -> '||substr(l_stmt,301,50),11);
       hr_utility.set_location('8 -> '||substr(l_stmt,351,50),11);
       hr_utility.set_location('zzzzzzzzzzzzzzzzzzzzzzzzzzzz',11);
        -- Added by DN for CBR Enhancements
           IF INSTR(UPPER(l_stmt), ':1') <> 0 THEN
           -- Replace :1 with business_group_id;
              l_stmt := REPLACE(l_stmt, ':1', 'BUSINESS_GROUP_ID');
           ELSE
           -- Replace FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID') with business_group_id;
              l_stmt := REPLACE(l_stmt, 'FND_PROFILE.VALUE(''PER_BUSINESS_GROUP_ID'')', 'BUSINESS_GROUP_ID');
           END IF;
         -- FOR RBC
           if instr(upper(l_stmt),':$PROFILES$.PER_BUSINESS_GROUP_ID') > 0 then
              hr_utility.set_location('inside bg pattern',11);
              l_stmt := REPLACE(l_stmt,':$PROFILES$.PER_BUSINESS_GROUP_ID','FND_PROFILE.VALUE(''PER_BUSINESS_GROUP_ID'')');

           end if;
           if instr(upper(l_stmt),':$FLEX$.PER_DATES_STANDARD') > 0 then
              hr_utility.set_location('inside date pattern',11);
/**
              l_stmt := REPLACE(l_stmt,'TO_DATE(:$FLEX$.PER_DATES_STANDARD,''YYYY/MM/DD HH24:MI:SS'')','trunc(sysdate)');
**/
              l_stmt := REPLACE(l_stmt,'TO_DATE(:$FLEX$.PER_DATES_STANDARD,''YYYY/MM/DD HH24:MI:SS'')','pqh_utility.get_query_date');
           end if;
           hr_utility.set_location(' Now executing :'||l_stmt,909);

           EXECUTE IMMEDIATE l_stmt INTO l_display;
        ELSE
        -- If validation type is not table then return entered value as result.
           l_display := p_value;
        END IF;
     END IF;
  ELSE
  -- If value set is null then sent the entered value as result.
     l_display := p_value;
  END IF;
  RETURN l_display;
EXCEPTION
  WHEN OTHERS THEN
       hr_utility.set_location(sqlerrm,10);
       hr_utility.set_location('in exception stmt executed is',10);
       hr_utility.set_location('1 -> '||substr(l_stmt,1,50),11);
       hr_utility.set_location('2 -> '||substr(l_stmt,51,50),11);
       hr_utility.set_location('3 -> '||substr(l_stmt,101,50),11);
       hr_utility.set_location('4 -> '||substr(l_stmt,151,50),11);
       hr_utility.set_location('5 -> '||substr(l_stmt,201,50),11);
       hr_utility.set_location('6 -> '||substr(l_stmt,251,50),11);
       hr_utility.set_location('7 -> '||substr(l_stmt,301,50),11);
       hr_utility.set_location('8 -> '||substr(l_stmt,351,50),11);
       l_display := p_value;
       RETURN l_display;
END;
--
FUNCTION get_display_value(p_value         IN VARCHAR2,
                           p_value_set_id  IN NUMBER,
                           p_prnt_valset_nm IN VARCHAR2,
                           p_prnt_value IN VARCHAR2) return VARCHAR2 IS
  l_value_set_rec      g_value_set%type;
  l_error_status       number(10);
  l_display            varchar2(2000);
  l_value_column_name  varchar2(2000);
  l_app_tab_name       varchar2(2000);
  l_add_where_clause   varchar2(2000);
  l_id_column_name     varchar2(2000);
  l_stmt               varchar2(2000);
  l_per_business_group number := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
BEGIN
  IF p_value_set_id IS NOT NULL THEN
  -- Check if a valid value set id is passed and fetch its validation type.
     chk_if_valid_value_set(p_value_set_id  => p_value_set_id,
                            p_value_set     => l_value_set_rec,
                            p_error_status  => l_error_status);
     IF l_error_status <> 0 THEN
     -- Invalid value set id. No value set attached. so return value given.
        l_display := p_value;
     ELSE
        IF l_value_set_rec.validation_type = 'F' THEN
           SELECT value_column_name, application_table_name, additional_where_clause, id_column_name
             INTO l_value_column_name, l_app_tab_name, l_add_where_clause, l_id_column_name
             FROM fnd_flex_validation_tables
            WHERE flex_value_set_id = p_value_set_id;
           IF l_add_where_clause IS NOT NULL THEN
              IF INSTR(UPPER(l_add_where_clause), 'ORDER BY') <> 0 THEN
                 l_add_where_clause := REPLACE(l_add_where_clause,
                                               SUBSTR(l_add_where_clause, INSTR(UPPER(l_add_where_clause), 'ORDER BY')),
                                               '');
              END IF;
              l_add_where_clause := REPLACE(UPPER(l_add_where_clause), 'WHERE', 'AND');
              l_stmt := RTRIM('select '||l_value_column_name||
                               ' from '||l_app_tab_name||' '||
                               'where '||l_id_column_name||'='||''''||p_value||''''||' '||l_add_where_clause,
                              ' ');
           ELSE
              l_stmt := RTRIM('select '||l_value_column_name||
                               ' from '||l_app_tab_name||' '||
                               'where '||l_id_column_name||'='||''''||p_value||'''',
                              ' ');
           END IF;

       hr_utility.set_location('before replace stmt is ',10);
       hr_utility.set_location('1 -> '||substr(l_stmt,1,50),11);
       hr_utility.set_location('2 -> '||substr(l_stmt,51,50),11);
       hr_utility.set_location('3 -> '||substr(l_stmt,101,50),11);
       hr_utility.set_location('4 -> '||substr(l_stmt,151,50),11);
       hr_utility.set_location('5 -> '||substr(l_stmt,201,50),11);
       hr_utility.set_location('6 -> '||substr(l_stmt,251,50),11);
       hr_utility.set_location('7 -> '||substr(l_stmt,301,50),11);
       hr_utility.set_location('8 -> '||substr(l_stmt,351,50),11);
       hr_utility.set_location('zzzzzzzzzzzzzzzzzzzzzzzzzzzz',11);
        -- Added by DN for CBR Enhancements
           IF INSTR(UPPER(l_stmt), ':1') <> 0 THEN
           -- Replace :1 with business_group_id;
              l_stmt := REPLACE(l_stmt, ':1', 'BUSINESS_GROUP_ID');
           ELSE
           -- Replace FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID') with business_group_id;
              l_stmt := REPLACE(l_stmt, 'FND_PROFILE.VALUE(''PER_BUSINESS_GROUP_ID'')', 'BUSINESS_GROUP_ID');
           END IF;
           if instr(upper(l_stmt),':$PROFILES$.PER_BUSINESS_GROUP_ID') > 0 then
              hr_utility.set_location('inside bg pattern',11);
              l_stmt := REPLACE(l_stmt,':$PROFILES$.PER_BUSINESS_GROUP_ID','FND_PROFILE.VALUE(''PER_BUSINESS_GROUP_ID'')');
           end if;
           if instr(upper(l_stmt),':$FLEX$.PER_DATES_STANDARD') > 0 then
              hr_utility.set_location('inside date pattern',11);
              l_stmt := REPLACE(l_stmt,'TO_DATE(:$FLEX$.PER_DATES_STANDARD,''YYYY/MM/DD HH24:MI:SS'')','trunc(sysdate)');
           end if;
           if instr(upper(l_stmt),':$FLEX$.'||p_prnt_valset_nm) > 0 then
              hr_utility.set_location('inside date pattern',11);
              l_stmt := REPLACE(l_stmt,':$FLEX$.'||p_prnt_valset_nm,p_prnt_value);
           end if;
           EXECUTE IMMEDIATE l_stmt INTO l_display;
        ELSE
        -- If validation type is not table then return entered value as result.
           l_display := p_value;
        END IF;
     END IF;
  ELSE
  -- If value set is null then sent the entered value as result.
     l_display := p_value;
  END IF;
  RETURN l_display;
EXCEPTION
  WHEN OTHERS THEN
       hr_utility.set_location('in exception stmt executed is',10);
       hr_utility.set_location('1 -> '||substr(l_stmt,1,50),11);
       hr_utility.set_location('2 -> '||substr(l_stmt,51,50),11);
       hr_utility.set_location('3 -> '||substr(l_stmt,101,50),11);
       hr_utility.set_location('4 -> '||substr(l_stmt,151,50),11);
       hr_utility.set_location('5 -> '||substr(l_stmt,201,50),11);
       hr_utility.set_location('6 -> '||substr(l_stmt,251,50),11);
       hr_utility.set_location('7 -> '||substr(l_stmt,301,50),11);
       hr_utility.set_location('8 -> '||substr(l_stmt,351,50),11);
       l_display := p_value;
       RETURN l_display;
END;
--
function get_transaction_category_id(p_short_name in varchar2, p_business_group_id in number default null) return number is
l_transaction_category_id number;
cursor c1 is
select transaction_category_id
from pqh_transaction_categories
where short_name = p_short_name
and business_group_id = p_business_group_id;
begin
if p_short_name is not null then
  open c1;
  fetch c1 into l_transaction_category_id;
  close c1;
end if;
return l_transaction_category_id;
end;
--
--
Procedure set_message_level_cd
                            ( p_rule_level_cd        IN varchar2) is
--
l_proc 	varchar2(72) := g_package||'get_message_level_cd';
--
Begin
--
   if  p_rule_level_cd = 'E' Then
	g_rule_level_cd  := 'E' ;
   Elsif p_rule_level_cd = 'W' Then
	g_rule_level_cd  := 'W' ;
   End if;
--
End;
--
--
function get_ptx_create_flag(p_position_transaction_id number) return varchar2 is
l_create_flag varchar2(10);
cursor c_transaction_templates(p_transaction_id number) is
select create_flag
from pqh_transaction_templates ttl, pqh_templates tem
where ttl.template_id = tem.template_id
and ttl.transaction_id = p_transaction_id
and rownum<2;
begin
  open c_transaction_templates(p_position_transaction_id);
  fetch c_transaction_templates into l_create_flag;
  close c_transaction_templates;
  return l_create_flag;
end;
--
--
function get_pos_rec_eed(p_position_id number, p_start_date date) return date is
l_eed date;
cursor c_pos_rec_eed(p_position_id number, p_start_date date) is
SELECT min(effective_start_date)-1 effective_end_date
FROM
(select effective_start_date
from hr_all_positions_f
where position_id = p_position_id
and effective_start_date > p_start_date
union
select action_date effective_start_date
from pqh_position_transactions
where position_id = p_position_id
and action_date > p_start_date
and transaction_status = 'SUBMITTED'
);
begin
  open c_pos_rec_eed(p_position_id, p_start_date);
  fetch c_pos_rec_eed into l_eed;
  close c_pos_rec_eed;
  return NVL(l_eed, to_date('4712/12/31 12:00:00', 'RRRR/MM/DD HH:MI:SS'));
end;
--
--
function get_df_context_desc(p_df_name varchar2, p_context_code varchar2) return varchar2 is
l_desc varchar2(100);
cursor c1 is
    select description
    from  FND_DESCR_FLEX_CONTEXTS_VL
    where application_id = 800   -- NS: 29-Mar-2006: Perf: SQL ID: 16596807
    and   descriptive_flexfield_name = p_df_name
    and   descriptive_flex_context_code = p_context_code;
begin
    open c1;
    fetch c1 into l_desc;
    close c1;
    return l_desc;
end;
--
function get_pte_context_desc(p_pte_id number) return varchar2 is
l_information_type varchar2(100);
l_df_context varchar2(100);
cursor c1 is
    select information_type
    from pqh_ptx_extra_info
    where ptx_extra_info_id = p_pte_id;
begin
   open c1;
   fetch c1 into l_information_type;
   close c1;
   l_df_context := get_df_context_desc('Extra Position Info DDF', l_information_type);
   return l_df_context;
end;
--
function get_kf_structure_name(p_kf_short_name varchar2, p_id_flex_num number) return
 varchar2 is
l_id_flex_structure_name varchar2(100);
l_id_flex_structure_code varchar2(100);
cursor c1 is
select fs.id_flex_structure_name, fs.id_flex_structure_code
from fnd_id_flex_structures_vl fs
where  fs.id_flex_code = p_kf_short_name
and fs.id_flex_num = p_id_flex_num;
begin
open c1;
fetch c1 into l_id_flex_structure_name, l_id_flex_structure_code;
close c1;
return l_id_flex_structure_name;
end;
--
function get_tjr_classification(p_tjr_id number) return varchar2 is
l_id_flex_num number;
cursor c1 is
select id_flex_num
from pqh_txn_job_requirements tjr, PER_ANALYSIS_CRITERIA pac
where txn_job_requirement_id = p_tjr_id
and tjr.analysis_criteria_id = pac.analysis_criteria_id;
begin
 open c1;
 fetch c1 into l_id_flex_num;
 close c1;
 return get_kf_structure_name('PEA', l_id_flex_num);
end;
--
/* The function modified on 24-AUG-2001 to check for Public Sector Installation for
   a particular legislation */
/* function is_pqh_installed return boolean is
l_oracle_schema varchar2(40);
l_status	fnd_product_installations.status%type;
l_industry 	fnd_product_installations.industry%type;
l_pqh_installed boolean :=FALSE;
--
 begin
	if ( fnd_installation.get_app_info('PQH',l_status,l_industry,l_oracle_schema)) then
		if l_status = 'I' then
			l_pqh_installed := TRUE;
		end if;
	end if;
  return l_pqh_installed;
--
end is_pqh_installed; */
--
/* The function changed on 11-SEP-2001 to incorporate new approach taken
   to identify Public Sector Product */
--
/* function is_pqh_installed(p_legislation_code IN VARCHAR2) return boolean is
--
begin
--
  return hr_utility.chk_product_install('PQH',p_legislation_code);
--
end is_pqh_installed;*/
--
function is_pqh_installed(p_business_group_id IN NUMBER) return boolean is
--
 Cursor csr_pqh_installed is
  Select org_information2
   from hr_organization_information
    where org_information_context = 'Public Sector Details'
     and organization_id = p_business_group_id ;
 l_pqh_installed varchar2(1);
begin
--
  open csr_pqh_installed;
  fetch csr_pqh_installed into l_pqh_installed;
  close csr_pqh_installed;
  if l_pqh_installed = 'Y' then
     return TRUE;
  else
     return FALSE;
  end if;
--
end is_pqh_installed;
--
function GET_PATEO_PROJECT_NAME(p_project_id in number) return varchar2 is
  cursor c1 is select project_name
               from gms_pqh_projects_v
               where project_id = p_project_id;
  l_name gms_pqh_projects_v.project_name%type;
begin
   if p_project_id is not null then
      open c1;
      fetch c1 into l_name;
      close c1;
   end if;
   return l_name;
end;

function GET_PATEO_TASK_NAME(p_task_id in number,
                             p_project_id in number) return varchar2 is
  cursor c1 is select task_name
               from pa_tasks_expend_v
               where task_id = p_task_id
               and Project_id = p_project_id;
  l_name pa_tasks_expend_v.task_name%type;
begin
   if p_project_id is not null and p_task_id is not null then
      open c1;
      fetch c1 into l_name;
      close c1;
   end if;
   return l_name;
end;

function GET_PATEO_AWARD_NAME(p_award_id in number,
                        p_project_id in number,
                        p_task_id in number) return varchar2 is
  cursor c1 is select award_short_name
               from gms_pqh_awards_v
               where award_id = p_award_id
               and project_id = p_project_id
               and task_id    = p_task_id;
  l_name gms_pqh_awards_v.award_short_name%type;
begin
   if p_award_id is not null and p_task_id is not null and p_project_id is not null then
      open c1;
      fetch c1 into l_name;
      close c1;
   end if;
   return l_name;
end;

function GET_PATEO_EXPENDITURE_TYPE(p_project_id in number,
                              p_award_id   in number,
                              p_task_id    in number,
                              p_expenditure_type in varchar2) return varchar2 is
  cursor c1 is select expenditure_type
               from gms_pqh_exp_types_v
               where project_id = p_project_id
                 and task_id = p_task_id
                 and award_id = p_award_id
                 and expenditure_type = p_expenditure_type
                 and (sysdate between expnd_typ_start_date_active and
                                      nvl(expnd_typ_end_date_active , sysdate)) ;
  l_name gms_pqh_exp_types_v.expenditure_type%type;
begin
   if p_project_id is not null and p_award_id is not null and p_task_id is not null and p_expenditure_type is not null then
      open c1;
      fetch c1 into l_name;
      close c1;
   end if;
   return l_name;
end;

function GET_PATEO_ORGANIZATION_NAME(p_organization_id in number) return varchar2 is
  cursor c1 is select name
               from pa_organizations_expend_v
               where organization_id = p_organization_id;
  l_name pa_organizations_expend_v.name%type;
begin
   if p_organization_id is not null then
      open c1;
      fetch c1 into l_name;
      close c1;
   end if;
   return l_name;
end;
--
function pqh_rule_scope(p_business_group_id in number,
                                          p_organization_structure_id in number,
                                          p_starting_organization_id in number,
                                          p_organization_id in number) return varchar2 is
   l_scope varchar2(1000);
   l_oh_name per_organization_structures.name%type;
begin
   if p_business_group_id is null then
      l_scope := hr_general.decode_lookup('PQH_RULE_SET_SCOPE','GLOBAL');
   else
      l_scope := hr_general.decode_lookup('PQH_RULE_SET_SCOPE','BG')||':'||hr_general.decode_organization(p_business_group_id);
      if p_organization_structure_id is not null then
         select name into l_oh_name from per_organization_structures where organization_structure_id = p_organization_structure_id;
         l_scope := l_scope||' / '||hr_general.decode_lookup('PQH_RULE_SET_SCOPE','OH')||':'||l_oh_name;
         if p_starting_organization_id is not null then
         l_scope := l_scope||' / '||hr_general.decode_lookup('PQH_RULE_SET_SCOPE','STORG')||':'||hr_general.decode_organization(p_starting_organization_id);
         end if;
      end if;
     if p_organization_id is not null then
              l_scope := l_scope||' / '||hr_general.decode_lookup('PQH_RULE_SET_SCOPE','ORG')||':'||hr_general.decode_organization(p_organization_id);
     end if;
   end if;
   return l_scope;
end;
--
function get_rule_set_name(p_rule_set_id in number) return varchar2 is
--
	l_rule_set_name varchar2(240);
begin
	if p_rule_set_id is not null then
		select rule_set_name into l_rule_set_name from pqh_rule_sets_vl
                 where rule_set_id = p_rule_set_id;
	end if;
	return l_rule_set_name;
exception when others then
	return null;
end; --get_rule_set_name
--
FUNCTION get_number_of_days (DURATION NUMBER, duration_units VARCHAR2)
   RETURN NUMBER
IS
BEGIN
   IF (duration_units = 'Y')
   THEN
      RETURN ADD_MONTHS (SYSDATE, DURATION * 12) - SYSDATE;
   ELSIF (duration_units = 'M')
   THEN
      RETURN ADD_MONTHS (SYSDATE, DURATION) - SYSDATE;
   ELSIF (duration_units = 'W')
   THEN
      RETURN DURATION * 7;
   ELSE
      RETURN DURATION;
   END IF;
END;
---
FUNCTION get_org_hierarchy_name(p_organization_structure_id IN NUMBER) RETURN VARCHAR2
IS
  v_org_hier_name per_organization_structures.name%TYPE := NULL;
  CURSOR c_hier_cur
  IS SELECT name FROM per_organization_structures
      WHERE organization_structure_id = p_organization_structure_id;
BEGIN
  IF p_organization_structure_id IS NOT NULL THEN
    OPEN c_hier_cur;
    FETCH c_hier_cur INTO v_org_hier_name;
    CLOSE c_hier_cur;
  END IF;
  RETURN v_org_hier_name;
EXCEPTION
  WHEN OTHERS THEN
    IF c_hier_cur%ISOPEN THEN
      CLOSE c_hier_cur;
    END IF;
    RETURN NULL;
END;
--
End pqh_utility;

/
