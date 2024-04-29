--------------------------------------------------------
--  DDL for Package Body PQH_TCT_WIZARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCT_WIZARD_PKG" as
/* $Header: pqtctwiz.pkb 120.2 2005/10/12 20:20:12 srajakum noship $ */
--
--
-----------------------------------------------------------------------------
--
-- This function checks if standard setup is already complete for the
-- transaction category and returns TRUE  if standard setup is complete .
-- It returns FALSE  if standard setup has not yet been done.
--
Function  chk_if_setup_finish(p_transaction_category_id in   number,
                              p_setup_type               out nocopy varchar2)
Return Boolean
IS
--
-- Set_up flag is a new field in pqh_transaction_categories which tells us what
-- part of the setup is complete. Can have values of STANDARD/ADVANCED/NULL
--
l_freeze_status_cd         pqh_transaction_categories.freeze_status_cd%type;
l_set_up_flag              pqh_transaction_categories.setup_type_cd%type;
--
l_proc 	varchar2(72) := 'chk_if_setup_finish';
--
Cursor csr_setup is
 --
 Select nvl(setup_type_cd,'INCOMPLETE') , nvl(freeze_status_cd,'X')
 from pqh_transaction_categories_vl
 where transaction_category_id = p_transaction_category_id;
 --
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
 Open csr_setup;
 Fetch csr_setup into l_set_up_flag,l_freeze_status_cd;
 Close csr_setup;
 --
 p_setup_type := l_set_up_flag;
 --
 -- if the category is frozen , it means that the setup was
 -- successful.
 -- Check if the Standard or Advanced Setup was completed.
 --
 If l_freeze_status_cd = 'FREEZE_CATEGORY' AND
   (l_set_up_flag = 'STANDARD' or l_set_up_flag = 'ADVANCED') then
    return TRUE;
    --
 End if;
 --
 return FALSE;
 --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 exception when others then
 p_setup_type := null;
 raise;
End;
--
-----------------------------------------------------------------------------
--
Function generate_rule_name
Return VARCHAR2 is
--
 Cursor csr_next_rule is
  Select pqh_system_rule_s.nextval
   from dual;
--
l_range_name pqh_attribute_ranges.range_name%type;
l_next_sequence number;
--
l_proc 	varchar2(72) := 'generate_rule_name';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
 --
 l_range_name := 'PQH_$$SYS$$_';
 --
 Open csr_next_rule;
 Fetch csr_next_rule into l_next_sequence;
 Close csr_next_rule;
 --
 l_range_name := l_range_name || to_char(l_next_sequence);
 --
 Return l_range_name;
 --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
-----------------------------------------------------------------------------
--
PROCEDURE create_default_hierarchy
(  p_validate                       in boolean    default false
  ,p_routing_category_id            out nocopy number
  ,p_transaction_category_id        in  number    default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_default_flag                   in  varchar2  default null
  ,p_routing_list_id                in  number    default null
  ,p_position_structure_id          in  number    default null
  ,p_override_position_id           in  number    default null
  ,p_override_assignment_id         in  number    default null
  ,p_override_role_id               in  number    default null
  ,p_override_user_id               in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
) is
l_rule_name varchar2(200);
l_attribute_range_id number;
l_proc 	varchar2(72) := 'create_default_hierarchy';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
    --
    -- Create a routing category and with default_flag 'Y'
    -- File : pqrctapi.pkh/pkb
    --
    pqh_routing_categories_api.create_routing_category
    (
     p_validate                       => p_validate
    ,p_routing_category_id            => p_routing_category_id
    ,p_transaction_category_id        => p_transaction_category_id
    ,p_enable_flag                    => p_enable_flag
    ,p_default_flag                   => p_default_flag
    ,p_delete_flag                    => NULL
    ,p_routing_list_id                => p_routing_list_id
    ,p_position_structure_id          => p_position_structure_id
    ,p_override_position_id           => p_override_position_id
    ,p_override_assignment_id         => p_override_assignment_id
    ,p_override_role_id               => p_override_role_id
    ,p_override_user_id               => p_override_user_id
    ,p_object_version_number          => p_object_version_number
    ,p_effective_date                 => p_effective_date);
    --
    -- Generate a system rule_name
    --
    l_rule_name := generate_rule_name;
    --
    -- Create a  rule with the above generated rule name and attribute
    -- ranges value null
    -- File : pqrngapi.pkh/pkb
    --
    pqh_attribute_ranges_api.create_attribute_range(
    p_validate                       => p_validate
   ,p_attribute_range_id             => l_attribute_range_id
   ,p_approver_flag                  => NULL
   ,p_enable_flag                    => p_enable_flag
   ,p_delete_flag                    => NULL
   ,p_assignment_id                  => NULL
   ,p_attribute_id                   => NULL
   ,p_from_char                      => NULL
   ,p_from_date                      => NULL
   ,p_from_number                    => NULL
   ,p_position_id                    => NULL
   ,p_range_name                     => l_rule_name
   ,p_routing_category_id            => p_routing_category_id
   ,p_routing_list_member_id         => NULL
   ,p_to_char                        => NULL
   ,p_to_date                        => NULL
   ,p_to_number                      => NULL
   ,p_object_version_number          => p_object_version_number
   ,p_effective_date                 => p_effective_date);
   --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 exception when others then
 p_routing_category_id := null;
 p_object_version_number := null;
 raise;
End;
--
-----------------------------------------------------------------------------
--
PROCEDURE update_default_hierarchy
(
   p_validate                       in  boolean    default false
  ,p_old_routing_category_id        in  number
  ,p_routing_category_id            in out nocopy number
  ,p_transaction_category_id        in  number    default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_default_flag                   in  varchar2  default null
  ,p_routing_list_id                in  number    default null
  ,p_position_structure_id          in  number    default null
  ,p_override_position_id           in  number    default null
  ,p_override_assignment_id         in  number    default null
  ,p_override_role_id               in  number    default null
  ,p_override_user_id               in  number    default null
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
)
is
Cursor csr_get_attribute_range(p_routing_category_id number) is
 Select *
  from pqh_attribute_ranges
   where routing_category_id = p_routing_category_id;
--
l_rule_name varchar2(200);
l_attribute_range_id number;
--
l_rng_record pqh_attribute_ranges%ROWTYPE;
--
Cursor csr_old_def_hierarchy is
 Select * from pqh_routing_categories
  Where routing_category_id = p_old_routing_category_id;
--
l_rct_record     pqh_routing_categories%ROWTYPE;
--
l_proc 	varchar2(72) := 'update_default_hierarchy';
l_routing_category_id number := p_routing_category_id;
l_object_version_number number := p_object_version_number;
--
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
    -- Disable default approver and routing rules.
    --
  If p_old_routing_category_id IS NOT NULL then
     --
    /**
    open csr_get_attribute_range(p_routing_category_id => p_old_routing_category_id);
    loop
     fetch csr_get_attribute_range into l_rng_record;
     exit when csr_get_attribute_range%notfound;
        pqh_attribute_ranges_api.update_attribute_range
        (
        p_validate                       => p_validate
       ,p_attribute_range_id             => l_rng_record.attribute_range_id
       ,p_approver_flag                  => l_rng_record.approver_flag
       ,p_enable_flag                    => 'N'
       ,p_delete_flag                    => l_rng_record.delete_flag
       ,p_assignment_id                  => l_rng_record.assignment_id
       ,p_attribute_id                   => l_rng_record.attribute_id
       ,p_from_char                      => l_rng_record.from_char
       ,p_from_date                      => l_rng_record.from_date
       ,p_from_number                    => l_rng_record.from_number
       ,p_position_id                    => l_rng_record.position_id
       ,p_range_name                     => l_rng_record.range_name
       ,p_routing_category_id            => l_rng_record.routing_category_id
       ,p_routing_list_member_id         => l_rng_record.routing_list_member_id
       ,p_to_char                        => l_rng_record.to_char
       ,p_to_date                        => l_rng_record.to_date
       ,p_to_number                      => l_rng_record.to_number
       ,p_object_version_number          => l_rng_record.object_version_number
       ,p_effective_date                 => p_effective_date);

    end loop;

    close csr_get_attribute_range;
    **/
    --
    -- Added by Stella.
    -- Get details of the previous routing category , as the passed
    -- information is the new default hierarchy and approvers.
    --
    Open csr_old_def_hierarchy;
    Fetch csr_old_def_hierarchy into l_rct_record;
    Close csr_old_def_hierarchy;
    --
    -- Disable previously selected default hierarcy
    --
    pqh_routing_categories_api.update_routing_category
    (
     p_validate                       => p_validate
    ,p_routing_category_id            => p_old_routing_category_id
    ,p_transaction_category_id        => l_rct_record.transaction_category_id
    ,p_enable_flag                    => 'N'
    ,p_delete_flag                    => l_rct_record.delete_flag
    ,p_default_flag                   => l_rct_record.default_flag
    ,p_routing_list_id                => l_rct_record.routing_list_id
    ,p_position_structure_id          => l_rct_record.position_structure_id
    ,p_override_position_id           => l_rct_record.override_position_id
    ,p_override_assignment_id         => l_rct_record.override_assignment_id
    ,p_override_role_id               => l_rct_record.override_role_id
    ,p_override_user_id               => l_rct_record.override_user_id
    ,p_object_version_number          => l_rct_record.object_version_number
    ,p_effective_date                 => p_effective_date);
    --
    -- End of change by Stella.
    --
   End if;

    if (p_routing_category_id <> nvl(p_old_routing_category_id,-999)) and (p_routing_category_id is not null) then
    --
    -- Enable the already existing default_hierarchy
    --
    /**
    open csr_get_attribute_range(p_routing_category_id => p_routing_category_id);
    loop
    fetch csr_get_attribute_range into l_rng_record;
    exit when csr_get_attribute_range%notfound;
        pqh_attribute_ranges_api.update_attribute_range
        (
        p_validate                       => p_validate
       ,p_attribute_range_id             => l_rng_record.attribute_range_id
       ,p_approver_flag                  => l_rng_record.approver_flag
       ,p_enable_flag                    => 'Y'
       ,p_delete_flag                    => l_rng_record.delete_flag
       ,p_assignment_id                  => l_rng_record.assignment_id
       ,p_attribute_id                   => l_rng_record.attribute_id
       ,p_from_char                      => l_rng_record.from_char
       ,p_from_date                      => l_rng_record.from_date
       ,p_from_number                    => l_rng_record.from_number
       ,p_position_id                    => l_rng_record.position_id
       ,p_range_name                     => l_rng_record.range_name
       ,p_routing_category_id            => p_routing_category_id
       ,p_routing_list_member_id         => l_rng_record.routing_list_member_id
       ,p_to_char                        => l_rng_record.to_char
       ,p_to_date                        => l_rng_record.to_date
       ,p_to_number                      => l_rng_record.to_number
       ,p_object_version_number          => l_rng_record.object_version_number
       ,p_effective_date                 => p_effective_date);
    end loop;

    close csr_get_attribute_range;
    **/
    --
    --
    -- Enable previously selected default hierarcy
    --
    pqh_routing_categories_api.update_routing_category
    (
     p_validate                       => p_validate
    ,p_routing_category_id            => p_routing_category_id
    ,p_transaction_category_id        => p_transaction_category_id
    ,p_enable_flag                    => 'Y'
    ,p_delete_flag                    => NULL
    ,p_default_flag                   => p_default_flag
    ,p_routing_list_id                => p_routing_list_id
    ,p_position_structure_id          => p_position_structure_id
    ,p_override_position_id           => p_override_position_id
    ,p_override_assignment_id         => p_override_assignment_id
    ,p_override_role_id               => p_override_role_id
    ,p_override_user_id               => p_override_user_id
    ,p_object_version_number          => p_object_version_number
    ,p_effective_date                 => p_effective_date);
    --
    --
    --

else

    --
    -- Create a routing category and with default_flag 'Y'
    --
    pqh_routing_categories_api.create_routing_category
    (
     p_validate                       => p_validate
    ,p_routing_category_id            => p_routing_category_id
    ,p_transaction_category_id        => p_transaction_category_id
    ,p_enable_flag                    => p_enable_flag
    ,p_default_flag                   => p_default_flag
    ,p_delete_flag                    => NULL
    ,p_routing_list_id                => p_routing_list_id
    ,p_position_structure_id          => p_position_structure_id
    ,p_override_position_id           => p_override_position_id
    ,p_override_assignment_id         => p_override_assignment_id
    ,p_override_role_id               => p_override_role_id
    ,p_override_user_id               => p_override_user_id
    ,p_object_version_number          => p_object_version_number
    ,p_effective_date                 => p_effective_date);
    --
    -- Generate a system rule_name
    --
    l_rule_name := generate_rule_name;
    --
    -- Create a  rule with the above generated rule name and attribute
    -- ranges value null
    --
    pqh_attribute_ranges_api.create_attribute_range
    (p_validate                       => p_validate
    ,p_attribute_range_id             => l_attribute_range_id
    ,p_approver_flag                  => NULL
    ,p_enable_flag                    => p_enable_flag
    ,p_delete_flag                    => NULL
    ,p_assignment_id                  => NULL
    ,p_attribute_id                   => NULL
    ,p_from_char                      => NULL
    ,p_from_date                      => NULL
    ,p_from_number                    => NULL
    ,p_position_id                    => NULL
    ,p_range_name                     => l_rule_name
    ,p_routing_category_id            => p_routing_category_id
    ,p_routing_list_member_id         => NULL
    ,p_to_char                        => NULL
    ,p_to_date                        => NULL
    ,p_to_number                      => NULL
    ,p_object_version_number          => p_object_version_number
    ,p_effective_date                 => p_effective_date);

end if;
--
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
exception when others then

p_routing_category_id := l_routing_category_id;
p_object_version_number := l_object_version_number;
raise;
End;
--
-----------------------------------------------------------------------------
--
PROCEDURE create_default_approver
(  p_validate                       in boolean    default false
  ,p_attribute_range_id             out nocopy number
  ,p_approver_flag                  in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_assignment_id                  in  number    default null
  ,p_attribute_id                   in  number    default null
  ,p_position_id                    in  number    default null
  ,p_range_name                     in out nocopy  varchar2
  ,p_routing_category_id            in  number
  ,p_routing_list_member_id         in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
) is
--
l_proc 	varchar2(72) := 'create_default_approver';
l_range_name varchar2(200) := p_range_name;
--
--
Cursor csr_chk_already_approver is
Select attribute_range_id,object_version_number
from pqh_attribute_ranges
Where routing_category_id = p_routing_category_id
  And attribute_id is null
  And nvl(routing_list_member_id,-99) = nvl(p_routing_list_member_id,-99)
  And nvl(position_id,-99) = nvl(p_position_id,-99)
  And nvl(p_assignment_id,-99) = nvl(p_assignment_id,-99)
  And enable_flag = 'N';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- Check if the member was previously selected as approver and then disabled.
 --
  Open csr_chk_already_approver;
  Fetch csr_chk_already_approver into p_attribute_range_id,p_object_version_number;
  If csr_chk_already_approver%notfound then
    --
    --
    -- Generate a system rule_name
    --
    p_range_name := generate_rule_name;
    --
    -- Create a  rule with the above generated rule name and attribute
    -- ranges value null
    pqh_attribute_ranges_api.create_attribute_range(
     p_validate                       => p_validate
    ,p_attribute_range_id             => p_attribute_range_id
    ,p_approver_flag                  => p_approver_flag
    ,p_enable_flag                    => p_enable_flag
    ,p_delete_flag                    => NULL
    ,p_assignment_id                  => p_assignment_id
    ,p_attribute_id                   => p_attribute_id
    ,p_from_char                      => NULL
    ,p_from_date                      => NULL
    ,p_from_number                    => NULL
    ,p_position_id                    => p_position_id
    ,p_range_name                     => p_range_name
    ,p_routing_category_id            => p_routing_category_id
    ,p_routing_list_member_id         => p_routing_list_member_id
    ,p_to_char                        => NULL
    ,p_to_date                        => NULL
    ,p_to_number                      => NULL
    ,p_object_version_number          => p_object_version_number
    ,p_effective_date                 => p_effective_date);
    --
  Else
    --
    pqh_attribute_ranges_api.update_attribute_range(
     p_validate                       => p_validate
    ,p_attribute_range_id             => p_attribute_range_id
    ,p_approver_flag                  => 'Y'
    ,p_enable_flag                    => 'Y'
    ,p_delete_flag                    => NULL
    ,p_object_version_number          => p_object_version_number
    ,p_effective_date                 => p_effective_date);
    --
  End if;
  --
  Close csr_chk_already_approver;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 exception when others then
 p_range_name := l_range_name;
 p_attribute_range_id := null;
 p_object_version_number := null;
 raise;
End;
--
-----------------------------------------------------------------------------
--
PROCEDURE update_default_approver
(  p_validate                       in  boolean   default false
  ,p_attribute_range_id             in  number
  ,p_approver_flag                  in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_assignment_id                  in  number    default null
  ,p_attribute_id                   in  number    default null
  ,p_position_id                    in  number    default null
  ,p_range_name                     in  varchar2
  ,p_routing_category_id            in  number
  ,p_routing_list_member_id         in  number    default null
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
) is
--
l_proc 	varchar2(72) := 'update_default_approver';
l_object_version_number number := p_object_version_number;
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
    --
    --
    pqh_attribute_ranges_api.update_attribute_range
    (
     p_validate                       => p_validate
    ,p_attribute_range_id             => p_attribute_range_id
    ,p_approver_flag                  => p_approver_flag
    ,p_enable_flag                    => p_enable_flag
    ,p_delete_flag                    => NULL
    ,p_assignment_id                  => p_assignment_id
    ,p_attribute_id                   => p_attribute_id
    ,p_from_char                      => NULL
    ,p_from_date                      => NULL
    ,p_from_number                    => NULL
    ,p_position_id                    => p_position_id
    ,p_range_name                     => p_range_name
    ,p_routing_category_id            => p_routing_category_id
    ,p_routing_list_member_id         => p_routing_list_member_id
    ,p_to_char                        => NULL
    ,p_to_date                        => NULL
    ,p_to_number                      => NULL
    ,p_object_version_number          => p_object_version_number
    ,p_effective_date                 => p_effective_date);
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 exception when others then
 p_object_version_number := l_object_version_number;
 raise;
End;
--
--------------------------------------------------------------------------
--
PROCEDURE delete_default_approver
(  p_validate                       in boolean    default false
  ,p_attribute_range_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
) is
l_proc 	varchar2(72) := 'delete_default_approver';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
    --
    -- Delete the authorization rule for the default approver.
    --
    pqh_attribute_ranges_api.delete_attribute_range
    (
     p_validate                       => p_validate
    ,p_attribute_range_id             => p_attribute_range_id
    ,p_object_version_number          => p_object_version_number
    ,p_effective_date                 => p_effective_date
    );
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
--
-----------------------------------------------------------------------------
--
-- The following procedure sets the chosen attribute as routing attribute.
-- Any child attributes it may have are also set as routing attributes.
--
-- Parameters
-- -----------
-- p_txn_category_attribute_id    Primary key of selected routing attribute
-- p_attribute_id                 Attribute id of selected routing attribute
-- p_transaction_category_id      Transaction category to which the routing
--                                attribute belongs to
--
--
--
PROCEDURE select_routing_attribute
          (p_txn_category_attribute_id          in       number,
           p_attribute_id                       in       number,
           p_transaction_category_id            in       number)  is
--
-- The following cursor determines the ovn of the master attribute id
--
Cursor csr_master_attribute is
  Select tca.object_version_number
   From pqh_txn_category_attributes tca
  Where  txn_category_attribute_id = p_txn_category_attribute_id
for update nowait;
--
-- The foll cursor selects the txn_category_attribute_id of all the child
-- attributes of the passed master attribute
--
Cursor csr_child_attributes is
 Select tca.txn_category_attribute_id,tca.object_version_number
   From pqh_txn_category_attributes tca
  Where tca.transaction_category_id = p_transaction_category_id
    and tca.attribute_id in
        (Select attribute_id
           From pqh_attributes
          Where master_attribute_id = p_attribute_id)
for update nowait;
--
l_ovn         pqh_txn_category_attributes.object_version_number%type;
--
l_child_id    pqh_txn_category_attributes.txn_category_attribute_id%type;
l_child_ovn   pqh_txn_category_attributes.object_version_number%type;
--
l_proc 	varchar2(72) := 'select_routing_attribute';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
--
  --
  -- Mark the master as a routing attribute
  --
  Open  csr_master_attribute;
  Fetch csr_master_attribute into l_ovn;
  Close csr_master_attribute;
  --
  pqh_txn_cat_attributes_api.update_TXN_CAT_ATTRIBUTE
  (
   p_validate                      => false
  ,p_txn_category_attribute_id     => p_txn_category_attribute_id
  ,p_object_version_number         => l_ovn
  ,p_list_identifying_flag         => 'Y'
  ,p_value_style_cd                => 'RANGE'
  ,p_effective_date                => sysdate
  ,p_delete_attr_ranges_flag       => 'N'
  );

  --
  -- Mark each of the child attributes as a routing attribute
  --

  For child_rec in  csr_child_attributes loop
    --
    pqh_txn_cat_attributes_api.update_TXN_CAT_ATTRIBUTE
    (
     p_validate                      => false
    ,p_txn_category_attribute_id     => child_rec.txn_category_attribute_id
    ,p_object_version_number         => child_rec.object_version_number
    ,p_list_identifying_flag         => 'Y'
    ,p_value_style_cd                => 'RANGE'
    ,p_effective_date                => sysdate
    ,p_delete_attr_ranges_flag       => 'N'
    );
    --
  End loop;
  --

 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
-----------------------------------------------------------------------------
--
-- Parameters
-- -----------
-- p_txn_category_attribute_id    Primary key of un-selected routing attribute
-- p_attribute_id                 Attribute id of un-selected routing attribute
-- p_transaction_category_id      Transaction category to which the routing
--                                attribute belongs to
--
PROCEDURE unselect_routing_attribute
          (p_txn_category_attribute_id          in       number,
           p_attribute_id                       in       number,
           p_transaction_category_id            in       number)  is
--
-- The following cursor determines the master attribute of the passed attribute
--
Cursor csr_master_attribute is
  Select master_attribute_id
   From pqh_attributes
  Where attribute_id = p_attribute_id;
--
-- The foll cursor selects the txn_category_attribute_id of all the child
-- attributes of the selected master attribute
--
Cursor csr_child_attributes(p_master_attribute in number) is
 Select tca.txn_category_attribute_id,tca.object_version_number
   From pqh_txn_category_attributes tca
  Where (tca.transaction_category_id = p_transaction_category_id and
         tca.attribute_id  = p_master_attribute
         ) OR
         tca.txn_category_attribute_id = p_txn_category_attribute_id
for update nowait;
--
l_master_attribute    pqh_attributes.master_attribute_id%type;
--
l_proc 	varchar2(72) := 'unselect_routing_attribute';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
--
  --
  --  Select the master of the current routing attribute
  --
  Open  csr_master_attribute;
  Fetch csr_master_attribute into l_master_attribute;
  Close csr_master_attribute;

  --
  -- UnMark  the routing attributes
  --

  For child_rec in  csr_child_attributes(l_master_attribute) loop
    --
    pqh_txn_cat_attributes_api.update_TXN_CAT_ATTRIBUTE
    (
     p_validate                      => false
    ,p_txn_category_attribute_id     => child_rec.txn_category_attribute_id
    ,p_object_version_number         => child_rec.object_version_number
    ,p_list_identifying_flag         => 'N'
    ,p_value_style_cd                => 'RANGE'
    ,p_effective_date                => sysdate
    ,p_delete_attr_ranges_flag       => 'I'
    );
    --
  End loop;
  --

 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
-----------------------------------------------------------------------------
--
--
-- Parameters
-- -----------
-- p_txn_category_attribute_id   Primary key of selected authorization attribute
-- p_attribute_id                Attribute id of selected authorization attribut
-- p_transaction_category_id     Transaction category to which the authorization
--                               attribute belongs to
--
PROCEDURE select_authorization_attribute
          (p_txn_category_attribute_id          in       number,
           p_attribute_id                       in       number,
           p_transaction_category_id            in       number)  is
--
-- The following cursor determines the ovn of the master attribute id
--
Cursor csr_master_attribute is
  Select tca.object_version_number
   From pqh_txn_category_attributes tca
  Where  txn_category_attribute_id = p_txn_category_attribute_id
for update nowait;
--
-- The foll cursor selects the txn_category_attribute_id of all the child
-- attributes of the passed master attribute
--
Cursor csr_child_attributes is
 Select tca.txn_category_attribute_id,tca.object_version_number
   From pqh_txn_category_attributes tca
  Where tca.transaction_category_id = p_transaction_category_id
    and tca.attribute_id in
        (Select attribute_id
           From pqh_attributes
          Where master_attribute_id = p_attribute_id)
for update nowait;
--
l_ovn         pqh_txn_category_attributes.object_version_number%type;
--
l_child_id    pqh_txn_category_attributes.txn_category_attribute_id%type;
l_child_ovn   pqh_txn_category_attributes.object_version_number%type;
--
l_proc 	varchar2(72) := 'select_authorization_attribute';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
--
  --
  -- Mark the master as a authorization attribute
  --
  Open  csr_master_attribute;
  Fetch csr_master_attribute into l_ovn;
  Close csr_master_attribute;
  --
  pqh_txn_cat_attributes_api.update_TXN_CAT_ATTRIBUTE
  (
   p_validate                      => false
  ,p_txn_category_attribute_id     => p_txn_category_attribute_id
  ,p_object_version_number         => l_ovn
  ,p_member_identifying_flag         => 'Y'
  ,p_value_style_cd                => 'RANGE'
  ,p_effective_date                => sysdate
  ,p_delete_attr_ranges_flag       => 'N'
  );

  --
  -- Mark each of the child attributes as a authorization attribute
  --

  For child_rec in  csr_child_attributes loop
    --
    pqh_txn_cat_attributes_api.update_TXN_CAT_ATTRIBUTE
    (
     p_validate                      => false
    ,p_txn_category_attribute_id     => child_rec.txn_category_attribute_id
    ,p_object_version_number         => child_rec.object_version_number
    ,p_member_identifying_flag         => 'Y'
    ,p_value_style_cd                => 'RANGE'
    ,p_effective_date                => sysdate
    ,p_delete_attr_ranges_flag       => 'N'
    );
    --
  End loop;
  --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
-----------------------------------------------------------------------------
--
--
-- Parameters
-- -----------
-- p_txn_category_attribute_id  Primary key of un-selected auth attribute
-- p_attribute_id               Attribute id of un-selected auth attribute
-- p_transaction_category_id    Transaction category to which the authorization
--                                attribute belongs to
--
PROCEDURE unselect_auth_attribute
          (p_txn_category_attribute_id          in       number,
           p_attribute_id                       in       number,
           p_transaction_category_id            in       number)  is
--
-- The following cursor determines the master attribute of the passed attribute
--
Cursor csr_master_attribute is
  Select master_attribute_id
   From pqh_attributes
  Where attribute_id = p_attribute_id;
--
-- The foll cursor selects the txn_category_attribute_id of all the child
-- attributes of the selected master attribute
--
Cursor csr_child_attributes(p_master_attribute in number) is
 Select tca.txn_category_attribute_id,tca.object_version_number
   From pqh_txn_category_attributes tca
  Where (tca.transaction_category_id = p_transaction_category_id and
         tca.attribute_id  = p_master_attribute
         ) OR
         tca.txn_category_attribute_id = p_txn_category_attribute_id
for update nowait;
--
l_master_attribute    pqh_attributes.master_attribute_id%type;
--
l_proc 	varchar2(72) := 'unselect_auth_attribute';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
--
  --
  --  Select the master of the current authorization attribute
  --
  Open  csr_master_attribute;
  Fetch csr_master_attribute into l_master_attribute;
  Close csr_master_attribute;

  --
  -- UnMark  the authorization attributes
  --

  For child_rec in  csr_child_attributes(l_master_attribute) loop
    --
    pqh_txn_cat_attributes_api.update_TXN_CAT_ATTRIBUTE
    (
     p_validate                      => false
    ,p_txn_category_attribute_id     => child_rec.txn_category_attribute_id
    ,p_object_version_number         => child_rec.object_version_number
    ,p_member_identifying_flag       => 'N'
    ,p_value_style_cd                => 'RANGE'
    ,p_effective_date                => sysdate
    ,p_delete_attr_ranges_flag       => 'I'
    );
    --
  End loop;
  --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
----------------------------------------------------------------------------
--
-- The foll function adds a null criteria to rules. This is a local function.
--
PROCEDURE  Add_criteria_to_rules
           (p_transaction_category_id  in number,
            p_identifier_type          in varchar2) is
--
Cursor csr_adv_rct is
Select rct.routing_category_id
  From pqh_routing_categories rct
 Where rct.transaction_category_id = p_transaction_category_id
   and nvl(rct.default_flag,'N') <> 'Y' ;
--
-- Cursor to return newly selected routing attributes
--
Cursor new_rout_attr is
Select attribute_id
       from pqh_txn_category_attributes ptca
     Where transaction_category_id = p_transaction_category_id
       and list_identifying_flag = 'Y'
       and not exists
           (Select null
             From pqh_attribute_ranges rng,pqh_routing_categories rct
             Where rct.transaction_category_id = p_transaction_category_id
               and nvl(rct.default_flag,'N') <> 'Y'
               and rct.routing_category_id = rng.routing_category_id
               and routing_list_member_id IS NULL
               and position_id IS NULL
               and assignment_id IS NULL
               and ptca.attribute_id = rng.attribute_id);
--
-- Cursor to return all routing rule names
--
Cursor csr_rout_rule(p_routing_category_id in number) is
 Select distinct rng.range_name,rng.enable_flag, nvl(rng.delete_flag,'N') delete_flag
   From pqh_attribute_ranges rng
  Where rng.routing_category_id = p_routing_category_id
    and routing_list_member_id IS NULL
    and position_id IS NULL
    and assignment_id IS NULL
    and attribute_id IS NOT NULL;
--
-- Cursor to return newly selected authorization attributes
--
Cursor new_auth_attr is
Select attribute_id
       from pqh_txn_category_attributes tca
     Where transaction_category_id = p_transaction_category_id
       and member_identifying_flag = 'Y'
       and not exists
           (Select null
              From pqh_attribute_ranges rng,pqh_routing_categories rct
             Where rct.transaction_category_id = p_transaction_category_id
               and nvl(rct.default_flag,'N') <> 'Y'
               and rct.routing_category_id = rng.routing_category_id
               and (routing_list_member_id IS NOT NULL or
                    position_id IS NOT NULL or
                    assignment_id IS NOT NULL)
               and tca.attribute_id = rng.attribute_id);
--
-- Cursor to return all authorization rule names.
--
Cursor csr_auth_rule(p_routing_category_id in number) is
 Select distinct
 decode(routing_list_member_id,NULL,decode(position_id,NULL,'S','P'),'R') routing_style ,
 nvl(routing_list_member_id,nvl(position_id,assignment_id)) member_id,
        rng.range_name,
        rng.approver_flag,
        rng.enable_flag,
        nvl(rng.delete_flag,'N') delete_flag
   From pqh_attribute_ranges rng
  Where rng.routing_category_id = p_routing_category_id
    and (routing_list_member_id IS NOT NULL or
         position_id IS NOT NULL or
         assignment_id IS NOT NULL)
    and attribute_id IS NOT NULL;
--
l_attribute_range_id         pqh_attribute_ranges.attribute_range_id%type;
l_ovn                        pqh_attribute_ranges.object_version_number%type;
l_routing_list_member_id     pqh_attribute_ranges.routing_list_member_id%type;
l_position_id                pqh_attribute_ranges.position_id%type;
l_assignment_id              pqh_attribute_ranges.assignment_id%type;
l_routing_category_id        pqh_attribute_ranges.routing_category_id%type;
--
--
l_proc 	varchar2(72) := 'Add_criteria_to_rules';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  --
  If p_identifier_type = 'ROUTING' then
     --
     For attr_rec in new_rout_attr loop
         --
         For rct_rec in csr_adv_rct loop
         --
         For rule_rec in csr_rout_rule(rct_rec.routing_category_id) loop
             --
             pqh_attribute_ranges_api.create_ATTRIBUTE_RANGE
             (
              p_validate                       => false
             ,p_attribute_range_id             => l_attribute_range_id
             ,p_enable_flag                    => rule_rec.enable_flag
             ,p_delete_flag                    => rule_rec.delete_flag
             ,p_attribute_id                   => attr_rec.attribute_id
             ,p_range_name                     => rule_rec.range_name
             ,p_routing_category_id            => rct_rec.routing_category_id
             ,p_object_version_number          => l_ovn
             ,p_effective_date                 => sysdate
            );

         End loop;
         End loop;
     End loop;
     --
     --
  Elsif  p_identifier_type = 'AUTHORIZATION' then
     --
     --
     For attr_rec in new_auth_attr loop
         --
         For rct_rec in csr_adv_rct loop
         --
         For rule_rec in csr_auth_rule(rct_rec.routing_category_id) loop
             --
             If rule_rec.routing_style = 'R' then
                l_routing_list_member_id := rule_rec.member_id;
                l_position_id := NULL;
                l_assignment_id := NULL;
             ElsIf rule_rec.routing_style = 'P' then
                l_routing_list_member_id := NULL;
                l_position_id := rule_rec.member_id;
                l_assignment_id := NULL;
             ElsIf rule_rec.routing_style = 'S' then
                l_routing_list_member_id := NULL;
                l_position_id := NULL;
                l_assignment_id := rule_rec.member_id;
             End if;
             --
             pqh_attribute_ranges_api.create_ATTRIBUTE_RANGE
             (
              p_validate                       => false
             ,p_attribute_range_id             => l_attribute_range_id
             ,p_enable_flag                    => rule_rec.enable_flag
             ,p_delete_flag                    => rule_rec.delete_flag
             ,p_attribute_id                   => attr_rec.attribute_id
             ,p_range_name                     => rule_rec.range_name
             ,p_routing_category_id            => rct_rec.routing_category_id
             ,p_routing_list_member_id         => l_routing_list_member_id
             ,p_position_id                    => l_position_id
             ,p_assignment_id                  => l_assignment_id
             ,p_approver_flag                  => rule_rec.approver_flag
             ,p_object_version_number          => l_ovn
             ,p_effective_date                 => sysdate
            );

         End loop;
         End loop;
     End loop;
     --
     --
     --
  End if;
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
----------------------------------------------------------------------------
--
--The following function does 2 things. If an existing routing attribute was
-- de-selected , it removes from all rules under the transaction category,
-- the part of the criteria containing the routing attribute that was now
-- de-selected.
-- When a new routing attribute is added, to all existing routing rules , a
-- new criteria is added containing the selected routing attribute and with
-- range values as null.
--
--
-- Parameters
-- -----------
-- p_transaction_category_id      Transaction category to which the routing
--                                attributes belong to
--
PROCEDURE Refresh_routing_rules(p_transaction_category_id     in     number)
is
--
-- The foll cursor returns the part of routing rules containing the
-- routing attributes which were de-selected.
--
Cursor csr_rct is
 Select rct.routing_category_id
   From pqh_routing_categories rct
  Where rct.transaction_category_id = p_transaction_category_id;
--
/**
Cursor csr_old (p_routing_category_id in number)  is
Select rng.attribute_range_id,rng.object_version_number
   From pqh_attribute_ranges rng
  Where rng.routing_category_id = p_routing_category_id
    and routing_list_member_id IS NULL
    and position_id IS NULL
    and assignment_id IS NULL
    and attribute_id IS NOT NULL
    and attribute_id not in
    (Select attribute_id
       from pqh_txn_category_attributes
     Where transaction_category_id = p_transaction_category_id
       and list_identifying_flag = 'Y');
**/
--
-- Perf changes
Cursor csr_list_attr is
SELECT ATTRIBUTE_ID   FROM PQH_TXN_CATEGORY_ATTRIBUTES
   WHERE TRANSACTION_CATEGORY_ID = p_transaction_category_id  AND LIST_IDENTIFYING_FLAG = 'Y';
--
Cursor csr_old(p_routing_category_id in number) is
SELECT RNG.ATTRIBUTE_RANGE_ID,RNG.OBJECT_VERSION_NUMBER,RNG.ATTRIBUTE_ID
FROM PQH_ATTRIBUTE_RANGES RNG
 WHERE RNG.ROUTING_CATEGORY_ID = p_routing_category_id
    and routing_list_member_id IS NULL
    and position_id IS NULL
    and assignment_id IS NULL
   AND ATTRIBUTE_ID IS NOT NULL ;
--
type attr_rec is record(attribute_id pqh_attributes.attribute_id%type);
type attr_tab is table of attr_rec index by binary_integer;
--
l_attr_tab attr_tab;
l_cnt   number(15) := 0;
l_dummy number(15) := 0;
l_found boolean := false;
l_proc 	varchar2(72) := 'Refresh_routing_rules';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Remove from all routing rules under the transaction category, the part of
  -- the criteria containing the routing attribute that was now de-selected.
  --
  For attr_rec in csr_list_attr loop
      l_cnt := l_cnt + 1;
      l_attr_tab(l_cnt).attribute_id := attr_rec.attribute_id;
      hr_utility.set_location('List Identifier:'||to_char(l_attr_tab(l_cnt).attribute_id), 5);
  End loop;
  --
  For rct_rec in csr_rct loop
  hr_utility.set_location('Getting routing category', 5);
   For old_rec in csr_old(p_routing_category_id => rct_rec.routing_category_id) loop
      --
      hr_utility.set_location('List Identifier:'||to_char(old_rec.attribute_range_id), 5);
      l_found := false;
      For l_dummy in 1..l_cnt loop
          If old_rec.attribute_id = l_attr_tab(l_dummy).attribute_id then
             hr_utility.set_location('Inside If', 5);
             l_found := true;
          End if;
      End loop;
      --
      If not l_found then
         hr_utility.set_location('calling delete_ATTRIBUTE_RANGE', 5);
         pqh_ATTRIBUTE_RANGES_api.delete_ATTRIBUTE_RANGE
             (p_validate              => false
             ,p_attribute_range_id    => old_rec.attribute_range_id
             ,p_object_version_number => old_rec.object_version_number
             ,p_effective_date        => sysdate);
      End if;
      --
   End Loop;
  End Loop;
  --
  -- To all existing routing rules , add a new criteria containing
  -- the newly selected routing attribute and with range values as null.
  --
  Add_criteria_to_rules(p_transaction_category_id => p_transaction_category_id,
                        p_identifier_type         => 'ROUTING');
  --
  --
  disable_rout_hier_if_no_attr
                       (p_transaction_category_id => p_transaction_category_id);
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
-----------------------------------------------------------------------------
--
--The following function does 2 things. If an existing authorization attribute
--was  de-selected , it removes from all rules under the transaction category,
--the part of the criteria containing the authorization attribute that was now
--de-selected.
--When a new authorization attribute is added, to all existing authorization
--rules, a new criteria is added containing the selected authorization
--attribute and with range values as null.
--
-- Parameters
-- -----------
-- p_transaction_category_id    Transaction category to which the authorization
--                              attributes belong to
--

PROCEDURE Refresh_authorization_rules(p_transaction_category_id in number) is
--
-- The foll cursor returns the part of authorization rules containing the
-- authorization attributes which were de-selected.
--
Cursor csr_rct is
 Select rct.routing_category_id
   From pqh_routing_categories rct
  Where rct.transaction_category_id = p_transaction_category_id;
--
/**
Cursor csr_old (p_routing_category_id in number)  is
Select rng.attribute_range_id,rng.object_version_number
   From pqh_attribute_ranges rng
  Where rng.routing_category_id = p_routing_category_id
    and (routing_list_member_id IS NOT NULL or
         position_id IS NOT NULL or
         assignment_id IS NOT NULL)
    and attribute_id IS NOT NULL
    and attribute_id not in
    (Select attribute_id
       from pqh_txn_category_attributes
     Where transaction_category_id = p_transaction_category_id
       and member_identifying_flag = 'Y');
**/
-- Perf changes
Cursor csr_mem_attr is
SELECT ATTRIBUTE_ID   FROM PQH_TXN_CATEGORY_ATTRIBUTES
   WHERE TRANSACTION_CATEGORY_ID = p_transaction_category_id  AND MEMBER_IDENTIFYING_FLAG = 'Y';
--
Cursor csr_auth(p_routing_category_id in number) is
SELECT RNG.ATTRIBUTE_RANGE_ID,RNG.OBJECT_VERSION_NUMBER,RNG.ATTRIBUTE_ID
FROM PQH_ATTRIBUTE_RANGES RNG
 WHERE RNG.ROUTING_CATEGORY_ID = p_routing_category_id
   AND (ROUTING_LIST_MEMBER_ID IS NOT NULL OR POSITION_ID IS NOT NULL OR ASSIGNMENT_ID IS NOT NULL)
   AND ATTRIBUTE_ID IS NOT NULL ;
--
type attr_rec is record(attribute_id pqh_attributes.attribute_id%type);
type attr_tab is table of attr_rec index by binary_integer;
--
l_attr_tab attr_tab;
l_cnt   number(15) := 0;
l_dummy number(15) := 0;
l_found boolean := false;
l_proc 	varchar2(72) := 'Refresh_authorization_rules';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  For attr_rec in csr_mem_attr loop
      l_cnt := l_cnt + 1;
      l_attr_tab(l_cnt).attribute_id := attr_rec.attribute_id;
  End loop;
  --
  -- Remove from all authorization rules under the transaction category,
  -- the part of  the criteria containing the authorization attribute
  -- that was now de-selected.
  --
  For rct_rec in csr_rct loop
   For old_rec in csr_auth(p_routing_category_id => rct_rec.routing_category_id) loop
      --
      l_found := false;
      For l_dummy in 1..l_cnt loop
          If old_rec.attribute_id = l_attr_tab(l_dummy).attribute_id then
             l_found := true;
          End if;
      End loop;
      --
      If not l_found then
        pqh_ATTRIBUTE_RANGES_api.delete_ATTRIBUTE_RANGE
             (p_validate              => false
             ,p_attribute_range_id    => old_rec.attribute_range_id
             ,p_object_version_number => old_rec.object_version_number
             ,p_effective_date        => sysdate);
      End if;

   End Loop;
  End Loop;
  --
  --
  -- To all existing authorization rules, add a new criteria containing
  -- the newly selected authorization attribute and with range values as null.
  --
  Add_criteria_to_rules(p_transaction_category_id => p_transaction_category_id,
                        p_identifier_type         => 'AUTHORIZATION');
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
--------------------------------------------------------------------------------
--
PROCEDURE disable_rout_hier_if_no_attr(p_transaction_category_id in number) is
--
-- The foll cursor returns any routing or authorization attributes  setup for the
-- passed transaction category.
--
Cursor csr_attr is
Select attribute_id
  from pqh_txn_category_attributes
 Where transaction_category_id = p_transaction_category_id
   and nvl(identifier_flag,'N') = 'Y'
   and list_identifying_flag = 'Y';
--
-- The foll cursor returns all non-default routing hierarchies under the current
-- transaction category.
--
Cursor csr_rout_hier is
Select routing_category_id,object_version_number
  from pqh_routing_categories
 Where transaction_category_id = p_transaction_category_id
   and decode(routing_list_id,NULL,decode( Position_structure_id,NULL,'S','P'),'R') = (Select member_cd
                      from pqh_transaction_categories
                     Where transaction_category_id = p_transaction_category_id)
   and nvl(default_flag,'N') <> 'Y'
   and nvl(enable_flag,'Y') = 'Y';
--
l_attribute_id       pqh_txn_category_attributes.attribute_id%type;
l_proc 	varchar2(72) := 'disable_rout_hier_if_no_attr';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open csr_attr;
  Fetch csr_attr into l_attribute_id;
  If csr_attr%notfound then
     --
     For old_rec in csr_rout_hier loop
       --
       pqh_ROUTING_CATEGORIES_api.update_ROUTING_CATEGORY
       (
         p_validate                =>    false
        ,p_routing_category_id     =>    old_rec.routing_category_id
        ,p_enable_flag             =>    'N'
        ,p_object_version_number   =>    old_rec.object_version_number
        ,p_effective_date          =>    sysdate
       );
       --
     End Loop;
  End if;
  Close csr_attr;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
------------------------------------------------------------------------------
--
--This foll function returns TRUE if any rules have been set up for the
--routing hierarchy
--
FUNCTION chk_rules_exist (p_routing_category_id in number)
RETURN BOOLEAN is
 --
 -- Foll cursor checks if there are any rules for the passed routing category
 -- It returns true if there are any rules. Else it returns False.
 -- Only non-default rules are taken into consideration.
 --
 Cursor csr_rules_exist is
  Select null
    From pqh_attribute_ranges
   Where routing_category_id = p_routing_category_id
     and attribute_range_id IS NOT NULL;
 --
 l_dummy    varchar2(1);
l_proc 	varchar2(72) := 'chk_rules_exist';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
 --
  Open csr_rules_exist;
  --
  Fetch csr_rules_exist into l_dummy;
  --
  -- If there are no rules return FALSE;
  --
  If csr_rules_exist%notfound then
     Close csr_rules_exist;
     RETURN FALSE;
  End if;
  --
  Close csr_rules_exist;
  --
  -- If there is at least 1 routing / authorization rule, then return TRUE.
  --
  RETURN TRUE;
 --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
--
-----------------------------------------------------------------------------
--
-- The foll function checks if there are any routing history for the
-- input routing category and returns TRUE if there is any routing history.
--
FUNCTION chk_routing_history_exists (p_routing_category_id in number)
RETURN BOOLEAN is
 --
 -- Foll cursor checks if there is any routing history for the passed routing category
 --
 Cursor csr_hist_exist is
  Select null
    From pqh_routing_history
   Where routing_category_id = p_routing_category_id;
 --
 l_dummy    varchar2(1);
 --
l_proc 	varchar2(72) := 'chk_routing_history_exists';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  --
  Open csr_hist_exist;
  --
  Fetch csr_hist_exist into l_dummy;
  --
  -- If there is no routing history return FALSE;
  --
  If csr_hist_exist%notfound then
     Close csr_hist_exist;
     RETURN FALSE;
  End if;
  --
  Close csr_hist_exist;
  --
  -- If there is routing history, then return TRUE.
  --
  RETURN TRUE;
 --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
-----------------------------------------------------------------------------
PROCEDURE get_all_attribute_range_id(p_routing_category_id    in   number,
                                     p_range_name             in   varchar2,
                                     p_rule_type              in   varchar2,
                                     p_all_attribute_range_id out nocopy  varchar2) is
--
 Cursor csr_rout_rule is
 Select attribute_range_id
   From pqh_attribute_ranges
  Where routing_category_id = p_routing_category_id
    and range_name = p_range_name
    and routing_list_member_id is NULL
    and position_id IS NULL
    and assignment_id IS NULL;
--
 Cursor csr_auth_rule is
 Select attribute_range_id
   From pqh_attribute_ranges
  Where routing_category_id = p_routing_category_id
    and range_name = p_range_name
    and (routing_list_member_id is NOT NULL or
         position_id IS NOT NULL or
         assignment_id IS NOT NULL);
--
l_proc 	varchar2(72) := 'get_all_attribute_range_id';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
 --
 p_all_attribute_range_id := NULL;
 --
 If p_rule_type = 'ROUTING' then
    --
    for id_rec in csr_rout_rule loop
        --
        p_all_attribute_range_id := p_all_attribute_range_id || id_rec.attribute_range_id||',';
        --
    End loop;
    --
    p_all_attribute_range_id := substr(p_all_attribute_range_id,1,length(p_all_attribute_range_id) - 1);
   --
 Elsif  p_rule_type = 'AUTHORIZATION' then
    --
    for id_rec in csr_auth_rule loop
        --
        p_all_attribute_range_id := p_all_attribute_range_id || id_rec.attribute_range_id||',';
        --
    End loop;
    --
    p_all_attribute_range_id := substr(p_all_attribute_range_id,1,length(p_all_attribute_range_id) - 1);
    --
 End if;
--
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 exception when others then
  p_all_attribute_range_id := null;
 raise;
End;
--
-----------------------------------------------------------------------------
--
-- The foll procedure creates a rule with the passed range name and using all
-- the selected routing attributes.
--
-- Parameters
-- ----------
-- p_transaction_category_id       Transaction category id
-- p_routing_category_id           Primary key
-- p_range_name                    Rule name to be created
-- p_all_attribute_range_id        Concatenated attribute_range_id's
--
PROCEDURE create_routing_rule(p_transaction_category_id in  number,
                              p_routing_category_id    in   number,
                              p_range_name             in   varchar2,
                              p_delete_flag            in   varchar2,
                              p_enable_flag            in   varchar2,
                              p_all_attribute_range_id out nocopy  varchar2) is
--
Cursor csr_rout_attr is
Select attribute_id
       from pqh_txn_category_attributes
     Where transaction_category_id = p_transaction_category_id
       and list_identifying_flag = 'Y';
--
--
l_attribute_range_id         pqh_attribute_ranges.attribute_range_id%type;
l_ovn                        pqh_attribute_ranges.object_version_number%type;
--
l_proc 	varchar2(72) := 'create_routing_rule';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
    --
    -- For the input a routing category and rule,insert all the selected
    -- routing attributes with attribute ranges value null
    --
    p_all_attribute_range_id := NULL;
    --
    For attr_rec in csr_rout_attr loop
        --
        pqh_attribute_ranges_api.create_ATTRIBUTE_RANGE
             (
              p_validate                       => false
             ,p_attribute_range_id             => l_attribute_range_id
             ,p_enable_flag                    => p_enable_flag
             ,p_delete_flag                    => p_delete_flag
             ,p_attribute_id                   => attr_rec.attribute_id
             ,p_range_name                     => p_range_name
             ,p_routing_category_id            => p_routing_category_id
             ,p_object_version_number          => l_ovn
             ,p_effective_date                 => sysdate
            );
          --
            p_all_attribute_range_id := p_all_attribute_range_id ||to_char(l_attribute_range_id)||',';
          --
    End loop;
    --
    -- Returning the attribute range id's for this rule in a string.
    --
    p_all_attribute_range_id := substr(p_all_attribute_range_id,1,length(p_all_attribute_range_id) - 1);
    --

 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 exception when others then
 p_all_attribute_range_id := null;
 raise;
End;
--
--
-----------------------------------------------------------------------------
--
-- This is a local function . It is called both of update_routing_rule and
-- update_authorization_rule procedures.
--
--
PROCEDURE update_rule(p_routing_category_id    in   number,
                      p_range_name             in   varchar2,
                      p_enable_flag            in   varchar2,
                      p_delete_flag            in   varchar2 default NULL,
                      p_approver_flag          in   varchar2 default NULL,
                      p_all_attribute_range_id in   varchar2) is
--
type cur_type   IS REF CURSOR;
csr_update_rule     cur_type;
sql_stmt           varchar2(2000);
--
l_all_attribute_range_id  varchar2(2000);
att_range_rec   pqh_attribute_ranges%ROWTYPE;
--
l_proc 	varchar2(72) := 'update_rule';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
   l_all_attribute_range_id := p_all_attribute_range_id;
   --
   if l_all_attribute_range_id IS NULL then
      l_all_attribute_range_id := '-999';
   End if;
   --
   --
   sql_stmt := 'Select * from pqh_attribute_ranges where attribute_range_id in ('
             || l_all_attribute_range_id
             ||') for update nowait';
   --
   -- We have the sql_stmt that we can execute.
   --
   Open csr_update_rule for sql_stmt;
   --
   --
   Loop
     --
     Fetch csr_update_rule into att_range_rec;
     --
     If csr_update_rule%NOTFOUND then
        Exit;
     End if;
     --
     pqh_attribute_ranges_api.update_ATTRIBUTE_RANGE
       (
       p_validate                 => false
      ,p_attribute_range_id       => att_range_rec.attribute_range_id
      ,p_approver_flag            => p_approver_flag
      ,p_enable_flag              => p_enable_flag
      ,p_delete_flag              => p_delete_flag
      ,p_range_name               => p_range_name
      ,p_routing_category_id      => p_routing_category_id
      ,p_object_version_number    => att_range_rec.object_version_number
      ,p_effective_date           => sysdate
      );
     --
   End loop;
   --
   Close csr_update_rule;
   --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
-------------------------------------------------------------------------------------
--
--
-- The foll procedure updates the rule name , enable_flag and approver flag on all
-- the attribute range records belonging to this rule
--
-- Parameters
-- ----------
-- p_routing_category_id           Primary key
-- p_range_name                    Rule name to be created
-- p_enable_flag                   'Y' means enable
-- p_approver_flag                 NULL
-- p_all_attribute_range_id        Concatenated attribute_range_id's
--
PROCEDURE update_routing_rule(p_routing_category_id    in   number,
                              p_range_name             in   varchar2,
                              p_enable_flag            in   varchar2,
                              p_approver_flag          in   varchar2 default NULL,
                              p_delete_flag            in   varchar2 default NULL,
                              p_all_attribute_range_id in   varchar2) is
--
l_proc 	varchar2(72) := 'update_routing_rule';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  --
  update_rule(p_routing_category_id    => p_routing_category_id,
              p_range_name             => p_range_name,
              p_enable_flag            => p_enable_flag,
              p_delete_flag            => p_delete_flag,
              p_approver_flag          => p_approver_flag,
              p_all_attribute_range_id => p_all_attribute_range_id);
  --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
--------------------------------------------------------------------------------------
--
-- This is a local function . It is called both of delete_routing_rule and
-- delete_authorization_rule procedures.
--
PROCEDURE delete_rule(p_routing_category_id    in   number,
                      p_all_attribute_range_id in   varchar2) is
--
type cur_type       IS REF CURSOR;
csr_delete_rule     cur_type;
sql_stmt            varchar2(2000);
--
l_id            pqh_attribute_ranges.attribute_range_id%TYPE;
l_ovn           pqh_attribute_ranges.object_version_number%TYPE;
--
l_all_attribute_range_id  varchar2(2000);
--
l_proc 	varchar2(72) := 'delete_rule';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
   l_all_attribute_range_id := p_all_attribute_range_id;
   --
   if l_all_attribute_range_id IS NULL then
      l_all_attribute_range_id := '-999';
   End if;
   --
   sql_stmt := 'Select attribute_range_id,object_version_number from pqh_attribute_ranges where routing_category_id = :routing_category_id and attribute_range_id in ('
             || l_all_attribute_range_id
             ||') for update nowait';
   --
   -- We have the sql_stmt that we can execute.
   --

   Open csr_delete_rule for sql_stmt using p_routing_category_id;
   --
   Loop
     --
     Fetch csr_delete_rule into l_id,l_ovn;
     --
     If csr_delete_rule%NOTFOUND then
        Exit;
     End if;
     --
     pqh_attribute_ranges_api.delete_ATTRIBUTE_RANGE
       (
       p_validate                 => false
      ,p_attribute_range_id       => l_id
      ,p_object_version_number    => l_ovn
      ,p_effective_date           => sysdate
      );
     --
   End loop;
   --
   Close csr_delete_rule;
   --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
----------------------------------------------------------------------------------
--
-- The foll procedure deletes all the attribute range records belonging to the
-- passed rule
--
-- Parameters
-- ----------
-- p_routing_category_id           Primary key
-- p_all_attribute_range_id        Concatenated attribute_range_id's
--
--
PROCEDURE delete_routing_rule(p_routing_category_id    in   number,
                              p_all_attribute_range_id in   varchar2) is
--
l_proc 	varchar2(72) := 'delete_routing_rule';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
   --
   delete_rule(p_routing_category_id => p_routing_category_id,
               p_all_attribute_range_id => p_all_attribute_range_id);
   --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
-----------------------------------------------------------------------------
--
-- The following procedure creates a system rule of the approver , using all the
-- authorization attributes previously selected.
-- If routing_list_member_id is available pass this as input. NULL should
-- passed to the position id and assignment_id.
-- Similarly , if position is available, pass this as input. NULL  should
-- be passed to routing_list_member_id and assignment id.
-- The same holds good if assignment id is available. NULL  should
-- be passed to routing_list_member_id and  position.
--
-- It returns the system generated rule name.
-- NOTE !! When displaying the rules for the approver, display all rules
-- except the system generated rule.
--
--
PROCEDURE create_approver (   p_transaction_category_id in  number,
                              p_routing_category_id    in   number,
                              p_routing_list_member_id in   number,
                              p_position_id            in   number,
                              p_assignment_id          in   number,
                              p_approver_flag          in   varchar2 ,
                              p_gen_sys_rule_name     out nocopy   varchar2) is
--
Cursor csr_auth_attr is
Select attribute_id
       from pqh_txn_category_attributes
     Where transaction_category_id = p_transaction_category_id
       and member_identifying_flag = 'Y';
--
Cursor csr_chk_already_approver is
Select attribute_range_id,object_version_number
from pqh_attribute_ranges
Where routing_category_id = p_routing_category_id
  And nvl(routing_list_member_id,-99) = nvl(p_routing_list_member_id,-99)
  And nvl(position_id,-99) = nvl(p_position_id,-99)
  And nvl(p_assignment_id,-99) = nvl(p_assignment_id,-99)
  And attribute_id is not null
  And enable_flag = 'N';
--
l_gen_sys_rule_name          pqh_attribute_ranges.range_name%type;
l_attribute_range_id         pqh_attribute_ranges.attribute_range_id%type;
l_ovn                        pqh_attribute_ranges.object_version_number%type;
l_create_appr                boolean := true;
--
l_proc 	varchar2(72) := 'create_approver';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  For exist_appr_rec in csr_chk_already_approver loop
    --
    l_create_appr := false;
    --
    pqh_attribute_ranges_api.update_attribute_range(
     p_validate                       => false
    ,p_attribute_range_id             => exist_appr_rec.attribute_range_id
    ,p_approver_flag                  => 'Y'
    ,p_enable_flag                    => 'Y'
    ,p_delete_flag                    => NULL
    ,p_object_version_number          => exist_appr_rec.object_version_number
    ,p_effective_date                 => trunc(sysdate));
    --
  End loop;
  --
  If l_create_appr then
    --
    --
    -- Generate system rule name
    --
    p_gen_sys_rule_name := generate_rule_name;
    --
    -- For the input a routing category and rule,insert all the selected
    -- authorization attributes with attribute ranges value null
    --
    For attr_rec in csr_auth_attr loop
        --
        pqh_attribute_ranges_api.create_ATTRIBUTE_RANGE
             (
              p_validate                       => false
             ,p_attribute_range_id             => l_attribute_range_id
             ,p_routing_category_id            => p_routing_category_id
             ,p_range_name                     => p_gen_sys_rule_name
             ,p_attribute_id                   => attr_rec.attribute_id
             ,p_routing_list_member_id         => p_routing_list_member_id
             ,p_position_id                    => p_position_id
             ,p_assignment_id                  => p_assignment_id
             ,p_enable_flag                    => 'Y'
             ,p_delete_flag                    => NULL
             ,p_approver_flag                  => p_approver_flag
             ,p_object_version_number          => l_ovn
             ,p_effective_date                 => sysdate
            );
          --
          --
    End loop;
    --
    --
  End if;
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 exception when others then
 p_gen_sys_rule_name := null;
 raise;
End;
--
-----------------------------------------------------------------------------
--
-- The procedure updates the member as approver as in all the authorization rules
-- except the default authorization rules.
-- If routing_list_member_id is available pass this as input. NULL should
-- passed to the position id and assignment_id.
-- Similarly , if position is available, pass this as input. NULL  should
-- be passed to routing_list_member_id and assignment id.
-- The same holds good if assignment id is available. NULL  should
-- be passed to routing_list_member_id and  position.
--
--
--
PROCEDURE update_approver  (p_routing_category_id    in   number,
                            p_routing_style          in   varchar2,
                            p_routing_list_member_id in   number,
                            p_position_id            in   number,
                            p_assignment_id          in   number,
                            p_approver_flag          in   varchar2 ) is
--
type cur_type       IS REF CURSOR;
csr_update_approver cur_type;
sql_stmt            varchar2(2000);
--
l_id            pqh_attribute_ranges.attribute_range_id%TYPE;
l_ovn           pqh_attribute_ranges.object_version_number%TYPE;
--
l_dummy_id      number(10);
l_proc 	varchar2(72) := 'update_approver';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
   --
   -- For the input a routing category , and authorizer
   -- Delete all non-default rules for the authorizer under the
   -- routing category
   --
   sql_stmt := 'Select attribute_range_id,object_version_number from pqh_attribute_ranges where routing_category_id = :routing_category_id and attribute_id is not null and ';
   --
   If p_routing_style = 'R' then
      --
      l_dummy_id := p_routing_list_member_id;
      sql_stmt := sql_stmt || 'routing_list_member_id = :approver_id';
      --
   Elsif p_routing_style = 'P' then
      --
      l_dummy_id := p_position_id;
      sql_stmt := sql_stmt || 'position_id = :approver_id';
      --
   Elsif p_routing_style = 'S' then
      --
      l_dummy_id := p_assignment_id;
      sql_stmt := sql_stmt || 'assignment_id = :approver_id';
      --
   End if;
   --
   sql_stmt := sql_stmt || ' For update nowait';
   --
   --
   Open csr_update_approver for sql_stmt using p_routing_category_id,l_dummy_id;
   --
   Loop
      --
      Fetch csr_update_approver into l_id,l_ovn;
      --
      If csr_update_approver%notfound then
         exit;
      End if;
      --
      pqh_attribute_ranges_api.update_ATTRIBUTE_RANGE
      (
       p_validate                 => false
      ,p_attribute_range_id       => l_id
      ,p_approver_flag            => p_approver_flag
      ,p_enable_flag              => 'Y'
      ,p_delete_flag              => NULL
      ,p_routing_category_id      => p_routing_category_id
      ,p_object_version_number    => l_ovn
      ,p_effective_date           => sysdate
      );
     --
   End loop;
   --
   Close csr_update_approver;
   --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
--------------------------------------------------------------------------
-- The foll procedure deletes all the authorization rules for the given
-- approver.
-- Pass the routing Style as Input - 'R'/'P'/'S'
-- If routing_list_member_id is available pass this as input. NULL should
-- passed to the position id and assignment_id.
-- Similarly , if position is available, pass this as input. NULL  should
-- be passed to routing_list_member_id and assignment id.
-- The same holds good if assignment id is available. NULL  should
-- be passed to routing_list_member_id and  position.
--
--
--
PROCEDURE delete_approver  (p_routing_category_id    in   number,
                            p_routing_style          in   varchar2,
                            p_routing_list_member_id in   number,
                            p_position_id            in   number,
                            p_assignment_id          in   number ) is
--
type cur_type       IS REF CURSOR;
csr_delete_approver cur_type;
sql_stmt            varchar2(2000);
--
l_id            pqh_attribute_ranges.attribute_range_id%TYPE;
l_ovn           pqh_attribute_ranges.object_version_number%TYPE;
--
l_dummy_id      number(10);
l_proc 	varchar2(72) := 'delete_approver';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
   --
   -- For the input a routing category , and authorizer
   -- Delete all non-default rules for the authorizer under the
   -- routing category
   --
   sql_stmt := 'Select attribute_range_id,object_version_number from pqh_attribute_ranges where routing_category_id = :routing_category_id and attribute_id is not null and ';
   --
   If p_routing_style = 'R' then
      --
      l_dummy_id := p_routing_list_member_id;
      sql_stmt := sql_stmt || 'routing_list_member_id = :approver_id';
      --
   Elsif p_routing_style = 'P' then
      --
      l_dummy_id := p_position_id;
      sql_stmt := sql_stmt || 'position_id = :approver_id';
      --
   Elsif p_routing_style = 'S' then
      --
      l_dummy_id := p_assignment_id;
      sql_stmt := sql_stmt || 'assignment_id = :approver_id';
      --
   End if;
   --
   sql_stmt := sql_stmt || ' For update nowait';
   --
   Open csr_delete_approver for sql_stmt using p_routing_category_id,l_dummy_id;
   --
   Loop
      --
      Fetch csr_delete_approver into l_id,l_ovn;
      --
      If csr_delete_approver%notfound then
         exit;
      End if;
      --
      pqh_attribute_ranges_api.delete_ATTRIBUTE_RANGE
      (
       p_validate                 => false
      ,p_attribute_range_id       => l_id
      ,p_object_version_number    => l_ovn
      ,p_effective_date           => sysdate
      );
     --
   End loop;
   --
   Close csr_delete_approver;
   --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
PROCEDURE update_approver_flag(p_routing_category_id    in   number,
                            p_routing_style          in   varchar2,
                            p_routing_list_member_id in   number,
                            p_position_id            in   number,
                            p_assignment_id          in   number,
                            p_approver_flag          in   varchar2 ) is
--
type cur_type       IS REF CURSOR;
csr_delete_approver cur_type;
sql_stmt            varchar2(2000);
--
l_id            pqh_attribute_ranges.attribute_range_id%TYPE;
l_ovn           pqh_attribute_ranges.object_version_number%TYPE;
l_appr_flag     pqh_attribute_ranges.approver_flag%type;
--
l_dummy_id      number(10);
l_proc 	varchar2(72) := 'update_approver_flag';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
   --
   -- For the input a routing category , and authorizer
   -- Delete all non-default rules for the authorizer under the
   -- routing category
   --
   sql_stmt := 'Select attribute_range_id,object_version_number,approver_flag from pqh_attribute_ranges where routing_category_id = :routing_category_id and attribute_id is not null and ';
   --
   --
   If p_routing_style = 'R' then
      --
      l_dummy_id := p_routing_list_member_id;
      sql_stmt := sql_stmt || 'routing_list_member_id = :approver_id';
      --
   Elsif p_routing_style = 'P' then
      --
      l_dummy_id := p_position_id;
      sql_stmt := sql_stmt || 'position_id = :approver_id';
      --
   Elsif p_routing_style = 'S' then
      --
      l_dummy_id := p_assignment_id;
      sql_stmt := sql_stmt || 'assignment_id = :approver_id';
      --
   End if;
   --
   sql_stmt := sql_stmt || ' For update nowait';
   --
   Open csr_delete_approver for sql_stmt using p_routing_category_id,l_dummy_id;
   --
   Loop
      --
      Fetch csr_delete_approver into l_id,l_ovn,l_appr_flag;
      --
      If csr_delete_approver%notfound then
         exit;
      End if;
      --
      --
      pqh_attribute_ranges_api.update_ATTRIBUTE_RANGE
     (p_validate                       => false
     ,p_attribute_range_id             => l_id
     ,p_approver_flag                  => p_approver_flag
     ,p_object_version_number          => l_ovn
     ,p_effective_date                 => sysdate
     );
     --
     --
   End loop;
   --
   Close csr_delete_approver;
   --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
--
-----------------------------------------------------------------------------
--
-- The foll procedure creates a authorization rule using the auth
-- attributes previously selected.
-- If routing_list_member_id is available pass this as input. NULL should
-- passed to the position id and assignment_id.
-- Similarly , if position is available, pass this as input. NULL  should
-- be passed to routing_list_member_id and assignment id.
-- The same holds good if assignment id is available. NULL  should
-- be passed to routing_list_member_id and  position.
--
--
PROCEDURE create_authorization_rule (
                              p_transaction_category_id in  number,
                              p_routing_category_id    in   number,
                              p_routing_list_member_id in   number,
                              p_position_id            in   number,
                              p_assignment_id          in   number,
                              p_approver_flag          in   varchar2,
                              p_delete_flag            in   varchar2,
                              p_enable_flag            in   varchar2,
                              p_range_name             in   varchar2,
                              p_all_attribute_range_id out nocopy  varchar2) is
--
Cursor csr_auth_attr is
Select attribute_id
       from pqh_txn_category_attributes
     Where transaction_category_id = p_transaction_category_id
       and member_identifying_flag = 'Y';
--
Cursor csr_sys_rule is
Select attribute_range_id,object_version_number
  From pqh_attribute_ranges
Where routing_category_id = p_routing_category_id
  and range_name like 'PQH_$$SYS$$%'
  and attribute_id is NOT NULL
  and nvl(routing_list_member_id,-99) = nvl(p_routing_list_member_id,-99)
  and nvl(position_id,-99) = nvl(p_position_id,-99)
  and nvl(assignment_id ,-99) = nvl(p_assignment_id,-99)
For update nowait;
--
l_attribute_range_id         pqh_attribute_ranges.attribute_range_id%type;
l_ovn                        pqh_attribute_ranges.object_version_number%type;
l_proc 	varchar2(72) := 'create_authorization_rule';
--
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
    --
    -- For the input a routing category and rule,insert all the selected
    -- authorization attributes with attribute ranges value null
    --
    p_all_attribute_range_id := NULL;
    --
    For attr_rec in csr_auth_attr loop
        --
        pqh_attribute_ranges_api.create_ATTRIBUTE_RANGE
             (
              p_validate                       => false
             ,p_attribute_range_id             => l_attribute_range_id
             ,p_routing_category_id            => p_routing_category_id
             ,p_range_name                     => p_range_name
             ,p_attribute_id                   => attr_rec.attribute_id
             ,p_routing_list_member_id         => p_routing_list_member_id
             ,p_position_id                    => p_position_id
             ,p_assignment_id                  => p_assignment_id
             ,p_enable_flag                    => p_enable_flag
             ,p_delete_flag                    => p_delete_flag
             ,p_approver_flag                  => p_approver_flag
             ,p_object_version_number          => l_ovn
             ,p_effective_date                 => sysdate
            );
          --
            p_all_attribute_range_id := p_all_attribute_range_id ||to_char(l_attribute_range_id)||',';
          --
    End loop;
    --
    -- Returning the attribute range id's for this rule in a string.
    --
    p_all_attribute_range_id := substr(p_all_attribute_range_id,1,length(p_all_attribute_range_id) - 1);
    --
    -- If there were any system rules for this approver , that we created to save approver
    -- information , we can delete those rules.
    --
    For sys_rec in csr_sys_rule loop
        --
        pqh_attribute_ranges_api.delete_ATTRIBUTE_RANGE
         (
          p_validate                 => false
         ,p_attribute_range_id       => sys_rec.attribute_range_id
         ,p_object_version_number    => sys_rec.object_version_number
         ,p_effective_date           => sysdate
         );
        --
    End loop;
    --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 exception when others then
 p_all_attribute_range_id := null;
 raise;
End;
--
--
-----------------------------------------------------------------------------
-- The following function updates all the attribute range records
-- for the authoriztaion rule.
--
PROCEDURE update_authorization_rule
                             (p_routing_category_id    in   number,
                              p_range_name             in   varchar2,
                              p_enable_flag            in   varchar2,
                              p_approver_flag          in   varchar2 default NULL,
                              p_delete_flag          in   varchar2 default NULL,
                              p_all_attribute_range_id in   varchar2) is
--
l_proc 	varchar2(72) := 'update_authorization_rule';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  --
  update_rule(p_routing_category_id    => p_routing_category_id,
              p_range_name             => p_range_name,
              p_enable_flag            => p_enable_flag,
              p_approver_flag          => p_approver_flag,
              p_delete_flag          => p_delete_flag,
              p_all_attribute_range_id => p_all_attribute_range_id);
  --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
--
-----------------------------------------------------------------------------
-- The following function deletes all the attribute range records
-- for the authoriztaion rule.
--
PROCEDURE delete_authorization_rule (p_routing_category_id    in   number,
                                     p_all_attribute_range_id in   varchar2) is
--
--
l_proc 	varchar2(72) := 'delete_authorization_rule';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
   --
   delete_rule(p_routing_category_id    => p_routing_category_id,
               p_all_attribute_range_id => p_all_attribute_range_id);
   --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
--
-----------------------------------------------------------------------------
PROCEDURE create_local_setup(p_transaction_category_id in  out nocopy NUMBER,
                             p_language                in  varchar2,
                             p_business_group_id       in  number) IS

--- Cursor to copy transaction category detail
CURSOR csr_transaction_category IS
  SELECT *
   FROM  PQH_TRANSACTION_CATEGORIES
   WHERE TRANSACTION_CATEGORY_ID = p_transaction_category_id
   AND BUSINESS_GROUP_ID IS NULL;

--- Cursor to copy default hierarchy detail
CURSOR csr_routing_category IS
  SELECT *
  FROM   PQH_ROUTING_CATEGORIES
  WHERE  TRANSACTION_CATEGORY_ID = p_transaction_category_id
  AND    NVL(ENABLE_FLAG, 'N')   = 'Y'
  AND    NVL(DEFAULT_FLAG,'N')   = 'Y';

--- Cursor to copy default approver detail
CURSOR csr_default_approver(p_routing_category_id NUMBER) IS
  SELECT *
    FROM pqh_attribute_ranges
  WHERE  ROUTING_CATEGORY_ID   = p_routing_category_id
  AND    NVL(ENABLE_FLAG,  'N')= 'Y'
  AND    NVL(APPROVER_FLAG,'N')= 'Y';
--
Cursor csr_attr is
   Select *
     from pqh_txn_category_attributes
  Where transaction_category_id = p_transaction_category_id;
--
attr_rec    pqh_txn_category_Attributes%ROWTYPE;
l_id        pqh_txn_category_Attributes.txn_category_attribute_id%type;
l_ovn       pqh_txn_category_Attributes.object_version_number%type;
--
tct_rec  pqh_transaction_categories%ROWTYPE;
tct_id   pqh_transaction_categories.transaction_category_id%type;
tct_ovn  pqh_transaction_categories.object_version_number%type;
--
rct_rec  pqh_routing_categories%ROWTYPE;
rct_id   pqh_routing_categories.transaction_category_id%type;
rct_ovn  pqh_routing_categories.object_version_number%type;
--
rng_id   pqh_attribute_ranges.attribute_range_id%type;
rng_ovn  pqh_attribute_ranges.object_version_number%type;
--
l_proc 	varchar2(72) := 'create_local_setup';
--
BEGIN
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
--
-- Copying the transaction category details
--
open csr_transaction_category;
fetch csr_transaction_category into tct_rec;
close csr_transaction_category;
--
pqh_tran_category_api.create_tran_category
	  (p_validate                      => false
	  ,p_member_cd                     => tct_rec.member_cd
	  ,p_post_style_cd                 => tct_rec.post_style_cd
	  ,p_timeout_days                  => tct_rec.timeout_days
	  ,p_post_txn_function             => tct_rec.post_txn_function
	  ,p_transaction_category_id       => tct_id
	  ,p_name                          => tct_rec.name
	  ,p_short_name                    => tct_rec.short_name
	  ,p_custom_workflow_name          => tct_rec.custom_workflow_name
	  ,p_form_name                     => tct_rec.form_name
	  ,p_object_version_number         => tct_ovn
	  ,p_future_action_cd              => tct_rec.future_action_cd
	  ,p_custom_wf_process_name        => tct_rec.custom_wf_process_name
	  ,p_freeze_status_cd              => NULL
	  ,p_route_validated_txn_flag      => tct_rec.route_validated_txn_flag
	  ,p_workflow_enable_flag          => tct_rec.workflow_enable_flag
	  ,p_enable_flag                   => 'Y'
	  ,p_consolidated_table_route_id   => tct_rec.consolidated_table_route_id
	  ,p_master_table_route_id         => tct_rec.master_table_route_id
	  ,p_effective_date                => sysdate
	  ,p_language_code                 => p_language
	  ,p_business_Group_id             => p_business_group_id
	  ,p_setup_type_cd                 => NULL);
 --
 -- Copy txn category attributes
 --
 --
 --
 Open csr_attr;
 Loop

   Fetch csr_attr into attr_rec;
   Exit when csr_attr%notfound;
   --
   pqh_txn_cat_attributes_api.create_TXN_CAT_ATTRIBUTE
   (
   p_validate                       => false
  ,p_txn_category_attribute_id      => l_id
  ,p_attribute_id                   => attr_rec.attribute_id
  ,p_transaction_category_id        => tct_id
  ,p_value_set_id                   => attr_rec.value_set_id
  ,p_object_version_number          => l_ovn
  ,p_transaction_table_route_id     => attr_rec.transaction_table_route_id
  ,p_form_column_name               => attr_rec.form_column_name
  ,p_identifier_flag                => attr_rec.identifier_flag
  ,p_list_identifying_flag          => NULL
  ,p_member_identifying_flag        => NULL
  ,p_refresh_flag                   => attr_rec.refresh_flag
  ,p_select_flag                    => attr_rec.select_flag
  ,p_value_style_cd                 => attr_rec.value_style_cd
  ,p_effective_date                 => sysdate
 );

 End loop;
 --
 --
 -- Copy default hierarchy
 --

 open csr_routing_category;
 loop
     fetch csr_routing_category into rct_rec;

     exit when csr_routing_category%notfound;

     Select pqh_routing_categories_s.nextval into rct_id from dual;

     insert into pqh_routing_categories (
           routing_category_id,
           transaction_category_id,
           enable_flag,
           default_flag,
           routing_list_id,
           position_structure_id,
           override_position_id,
           override_assignment_id,
           override_role_id,
           object_version_number)
         Values (
           rct_id,
           tct_id,
           rct_rec.enable_flag,
           rct_rec.default_flag,
           rct_rec.routing_list_id,
           rct_rec.position_structure_id,
           rct_rec.override_position_id,
           rct_rec.override_assignment_id,
           rct_rec.override_role_id,
           1);

    --
    -- Copy approver
    --
    for rng_rec in csr_default_approver(p_routing_category_id => rct_rec.routing_category_id)
    loop

     Select pqh_attribute_ranges_s.nextval into rng_id from dual;

     insert into pqh_attribute_ranges(
       attribute_range_id,
        approver_flag,
        enable_flag,
        assignment_id,
        attribute_id,
        from_char,
        from_date,
        from_number,
        position_id,
        range_name,
        routing_category_id,
        routing_list_member_id,
        to_char,
        to_date,
        to_number,
        object_version_number)

      Values(
        rng_id,
        rng_rec.approver_flag,
        rng_rec.enable_flag,
        rng_rec.assignment_id,
        rng_rec.attribute_id,
        rng_rec.from_char,
        rng_rec.from_date,
        rng_rec.from_number,
        rng_rec.position_id,
        rng_rec.range_name,
        rct_id,
        rng_rec.routing_list_member_id,
        rng_rec.to_char,
        rng_rec.to_date,
        rng_rec.to_number,
        1);


    end loop;

 end loop;

 close csr_routing_category;
 --
 p_transaction_category_id := tct_id;
 --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
END;
-----------------------------------------------------------------------------
PROCEDURE freeze_category (p_transaction_category_id       in   number,
                           p_setup_type_cd                 in   varchar2,
                           p_freeze_status_cd              in   varchar2) is
--
l_proc 	varchar2(72) := 'freeze_category';
--
BEGIN
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  --
  Update pqh_transaction_categories
    set freeze_status_cd = p_freeze_status_cd
       ,setup_type_cd    = p_setup_type_cd
  where transaction_category_id = p_transaction_category_id;
  --
  --
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
END;
-----------------------------------------------------------------------------

FUNCTION  chk_range_name_unique (p_routing_category_id  in number,
                                 p_range_name           in varchar2,
                                 p_attribute_id_list    in varchar2,
                                 p_primary_flag         in varchar2)
RETURN BOOLEAN is
type cur_type   IS REF CURSOR;
range_name_cur     cur_type;
sql_stmt           varchar2(1000);
exist_range_name   pqh_attribute_ranges.range_name%type;
--
l_proc 	varchar2(72) := 'chk_range_name_unique';
--
Begin
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --

   sql_stmt := 'Select distinct range_name from pqh_attribute_ranges where routing_category_id = :r AND attribute_id IS NOT NULL AND attribute_range_id not in ( ' || p_attribute_id_list || ') ';

   if p_primary_flag  = 'Y' then
      sql_stmt := sql_stmt ||' AND routing_list_member_id is NULL AND position_id is NULL AND assignment_id is NULL';
   else
      sql_stmt := sql_stmt ||' AND (routing_list_member_id is NOT NULL  OR position_id is NOT NULL OR assignment_id is NOT NULL)';
   end if;

   open range_name_cur for sql_stmt using p_routing_category_id;

   Loop
       Fetch range_name_cur into exist_range_name;
       exit when range_name_cur%notfound;
       if exist_range_name = p_range_name then
         Return FALSE;
       end if;
   End loop;
   Return TRUE;
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--------------------------------------------------------------------------------------------

PROCEDURE load_row (
				 p_canvas_name          in varchar2,
				 p_form_name            in varchar2,
				 p_current_item         in varchar2,
				 p_previous_item        in varchar2,
				 p_next_item            in varchar2,
				 p_enable_finish_flag   in varchar2,
				 p_post_flag            in varchar2,
				 p_seq_no               in number,
				 p_finish_item          in varchar2,
				 p_refresh_msg_flag     in varchar2,
				 p_image_name           in varchar2,
				 p_warning_item         in varchar2,
				 p_image_item           in varchar2,
				 p_line_size            in number,
				 p_owner	        in varchar2,
                                 p_last_update_date     in varchar2 ) IS

--
 l_language                  	varchar2(30) ;
--
 l_created_by                 pqh_wizard_canvases.created_by%TYPE;
 l_last_updated_by            pqh_wizard_canvases.last_updated_by%TYPE;
 l_creation_date              pqh_wizard_canvases.creation_date%TYPE;
 l_last_update_date           pqh_wizard_canvases.last_update_date%TYPE;
 l_last_update_login          pqh_wizard_canvases.last_update_login%TYPE;
--
--

l_rowid   		ROWID;
l_wizard_canvas_id	NUMBER;

cursor c1 is select userenv('LANG') from dual ;

cursor 	csr_wiz_canvas is
select 	rowid
from 	pqh_wizard_canvases
where canvas_name = p_canvas_name
  and form_name	= p_form_name;

--and		current_item	= p_current_item;
l_data_migrator_mode varchar2(1);
--

begin

--
  l_data_migrator_mode := hr_general.g_data_migrator_mode ;
   hr_general.g_data_migrator_mode := 'Y';
   open c1;
   fetch c1 into l_language ;
   close c1;
--

--
-- populate WHO columns
--
 /**
  if p_owner = 'SEED' then
    l_created_by 		:= 1;
    l_last_updated_by 	:= 1;
  else
    l_created_by 		:= 0;
    l_last_updated_by 	:= 0;
  end if;
  **/
  l_created_by := fnd_load_util.owner_id(p_owner);
  l_last_updated_by := fnd_load_util.owner_id(p_owner);
  --
/**
  l_creation_date 		:= sysdate;
  l_last_update_date 	:= sysdate;
**/
  l_creation_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_date := nvl(to_date(p_last_update_date,'YYYY/MM/DD'),trunc(sysdate));
  l_last_update_login 	:= 0;

  OPEN 	csr_wiz_canvas;
  FETCH 	csr_wiz_canvas INTO l_rowid;
  CLOSE 	csr_wiz_canvas;

  if  ( l_rowid is null ) THEN
	select pqh_wizard_canvases_s.NEXTVAL into l_wizard_canvas_id from dual;

	insert into pqh_wizard_canvases (
		 WIZARD_CANVAS_ID  ,
		 CANVAS_NAME       ,
		 CURRENT_ITEM      ,
		 PREVIOUS_ITEM     ,
		 NEXT_ITEM         ,
		 ENABLE_FINISH_FLAG ,
		 POST_FLAG         ,
		 SEQ_NO            ,
		 FINISH_ITEM       ,
		 REFRESH_MSG_FLAG  ,
		 FORM_NAME         ,
		 IMAGE_NAME        ,
		 WARNING_ITEM      ,
		 IMAGE_ITEM        ,
		 LINE_SIZE         ,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 LAST_UPDATE_LOGIN,
		 CREATED_BY,
		 CREATION_DATE  )
    values (
		 l_wizard_canvas_id  ,
		 P_CANVAS_NAME       ,
		 P_CURRENT_ITEM      ,
		 P_PREVIOUS_ITEM     ,
		 P_NEXT_ITEM         ,
		 P_ENABLE_FINISH_FLAG ,
		 P_POST_FLAG         ,
		 P_SEQ_NO            ,
		 P_FINISH_ITEM       ,
		 P_REFRESH_MSG_FLAG  ,
		 P_FORM_NAME         ,
		 P_IMAGE_NAME        ,
		 P_WARNING_ITEM      ,
		 P_IMAGE_ITEM        ,
		 P_LINE_SIZE         ,
		 l_last_update_date,
		 l_last_updated_by,
		 l_last_update_login,
		 l_created_by,
		 l_creation_date 	);
  else
	update pqh_wizard_canvases
	set
		 CANVAS_NAME       	= P_CANVAS_NAME       	,
		 CURRENT_ITEM      	= P_CURRENT_ITEM      	,
		 PREVIOUS_ITEM     	= P_PREVIOUS_ITEM     	,
		 NEXT_ITEM        	= P_NEXT_ITEM        	,
		 ENABLE_FINISH_FLAG = P_ENABLE_FINISH_FLAG   ,
		 POST_FLAG          = P_POST_FLAG            ,
		 SEQ_NO            	= P_SEQ_NO            	,
		 FINISH_ITEM       	= P_FINISH_ITEM       	,
		 REFRESH_MSG_FLAG  	= P_REFRESH_MSG_FLAG  	,
		 FORM_NAME         	= P_FORM_NAME         	,
		 IMAGE_NAME        	= P_IMAGE_NAME        	,
		 WARNING_ITEM      	= P_WARNING_ITEM      	,
		 IMAGE_ITEM        	= P_IMAGE_ITEM        	,
		 LINE_SIZE         	= P_LINE_SIZE         	,
		 LAST_UPDATE_DATE	= l_LAST_UPDATE_DATE	,
		 LAST_UPDATED_BY	= l_LAST_UPDATED_BY		,
		 LAST_UPDATE_LOGIN	= l_LAST_UPDATE_LOGIN	,
		 CREATED_BY		= l_CREATED_BY			,
		 CREATION_DATE		= l_CREATION_DATE
	where ROWID			= l_rowid ;

  end if;
   hr_general.g_data_migrator_mode := l_data_migrator_mode;
end load_row;
--------------------------------------------------------------------------------------------
--
-- This function checks if there are any errors in standard setup and returns false in case
-- there are errors.
--
Function check_errors_in_std_setup(p_transaction_category_id  in  number,
                                   p_error_messages          out nocopy  warnings_tab)
RETURN boolean IS
--
Cursor csr_member_cd(p_transaction_category_id in  number) is
Select member_cd
  from pqh_transaction_categories
 Where transaction_category_id = p_transaction_category_id;
--
Cursor csr_def_hier (p_transaction_category_id in number,
                     p_member_cd               in varchar2) is
Select routing_category_id
 from pqh_routing_categories_v
where member_cd = p_member_cd
  and transaction_category_id = p_transaction_category_id
  and nvl(enable_flag,'Y') = 'Y'
  and nvl(default_flag,'N') = 'Y';
--
Cursor csr_def_approvers (p_routing_category_id in number) is
Select null
  from pqh_attribute_ranges_v3
 Where routing_category_id = p_routing_category_id
   and nvl(approver_flag,'N') = 'Y'
   and nvl(enable_flag,'Y') = 'Y';
--
l_routing_category_id  pqh_routing_categories.routing_category_id%type;
l_member_cd            pqh_transaction_categories.member_cd%type;
--
l_dummy                varchar2(1);
l_error_status         boolean := TRUE;
--
l_error_index          number(10) := 0;
Begin
  --
  -- There can be two type of errors in standard setup.
  -- 1) There is no default hierarchy
  -- 2) No enabled default approvers.
  --
  -- Obtain the routing style of the transcation category.
  --
  Open csr_member_cd(p_transaction_category_id => p_transaction_category_id);
  Fetch csr_member_cd into l_member_cd;
  Close csr_member_cd;
  --
  Open csr_def_hier(p_transaction_category_id => p_transaction_category_id,
                    p_member_cd               => l_member_cd);
  Fetch csr_def_hier into l_routing_category_id;
  --
  -- Check if any default hierarchy is marked
  --
  If csr_def_hier%notfound then
     --
     -- set error
     --
     l_error_index := l_error_index + 1;
     hr_utility.set_message(8302,'PQH_TCW_STD_ERROR1');
     p_error_messages(l_error_index).message_text := hr_utility.get_message;
     --
     l_error_index := l_error_index + 1;
     hr_utility.set_message(8302,'PQH_TCW_STD_ERROR2');
     p_error_messages(l_error_index).message_text := hr_utility.get_message;
     --
     l_error_status := FALSE;
  Else
     --
     -- Check if there are any enable default approvers.
     --
     Open csr_def_approvers(p_routing_category_id => l_routing_category_id);
     Fetch csr_def_approvers into l_dummy;
     If csr_def_approvers%notfound then
        --
        l_error_index := l_error_index + 1;
        hr_utility.set_message(8302,'PQH_TCW_STD_ERROR2');
        p_error_messages(l_error_index).message_text := hr_utility.get_message;
        l_error_status := FALSE;
        --
     End if;
     Close csr_def_approvers;
     --
  End if;
  --
  Close csr_def_hier;
  --
  RETURN l_error_status;
  --
End;
----------------------------------------------------------------------------------------------
Function chk_valid_rout_hier_exists(p_transaction_category_id     in number,
                                    p_routing_type                in varchar2,
                                    p_error_messages             out nocopy warnings_tab,
                                    p_no_errors                  out nocopy varchar2)
RETURN BOOLEAN is
  --
  TYPE cur_type        IS REF CURSOR;
  csr_routing          cur_type;
  sql_stmt             varchar2(1000);
  --
  l_rec_count                 number(10) := 0;
  l_no_of_rules               number(10) := 0;
  l_no_of_errors              number(10) := 0;
  --
  l_routing_category_id       pqh_routing_categories.routing_category_id%type;
  l_list_name                 varchar2(200);
  --
  type rct_rec is record(routing_category_id pqh_routing_categories.routing_category_id%type,
                         default_flag        pqh_routing_categories.default_flag%type,
                         delete_flag         pqh_routing_categories.delete_flag%type);
  type rct_tab is table of rct_rec index by binary_integer;
  --
  l_rct_tab rct_tab;
  l_cnt   number(15) := 0;
  l_dummy number(15) := 0;
  l_x     varchar2(10);
  --
  l_proc         varchar2(72) := 'chk_valid_rout_hier_exists';
  --

--Perf changes
Cursor csr_ph is
Select rct.routing_category_id,rct.default_flag, rct.delete_flag
from pqh_routing_categories rct
 Where rct.transaction_category_id = p_transaction_category_id
  and rct.enable_flag = 'Y'
  and rct.position_structure_id IS NOT NULL;
--
Cursor csr_sh is
Select rct.routing_category_id,rct.default_flag, rct.delete_flag
from pqh_routing_categories rct
 Where rct.transaction_category_id = p_transaction_category_id
  and rct.enable_flag = 'Y'
  and rct.routing_list_id IS NULL and rct.position_structure_id IS NULL;
--
Cursor csr_rl is
Select rct.routing_category_id,rct.default_flag, rct.delete_flag
from pqh_routing_categories rct
 Where rct.transaction_category_id = p_transaction_category_id
  and rct.enable_flag = 'Y'
  and rct.routing_list_id IS NOT NULL;
--
Cursor csr_rules(p_routing_category_id in number) is
  Select 'x' from pqh_attribute_ranges rng
  Where rng.routing_category_id = p_routing_category_id
  and rng.enable_flag = 'Y'
  and nvl(delete_flag,'N') <> 'Y'
  and rng.routing_list_member_id IS NULL
  and rng.position_id IS NULL
  and rng.assignment_id IS NULL;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- The foll cursor selects the no of enabled routing categories exist for a
  -- transaction category,and how many routing rules exists under each routing
  -- category.
  --
  If p_routing_type = 'R' then
     For rl_rec in csr_rl loop
       If nvl(rl_rec.default_flag,'X') <> 'Y' and nvl(rl_rec.delete_flag,'X') <> 'Y' then
         l_cnt := l_cnt + 1;
         l_rct_tab(l_cnt).routing_category_id := rl_rec.routing_category_id;
       End if;
     End loop;
  Elsif p_routing_type = 'P' then
     For ph_rec in csr_ph loop
       If nvl(ph_rec.default_flag,'X') <> 'Y' and nvl(ph_rec.delete_flag,'X') <> 'Y' then
         l_cnt := l_cnt + 1;
         l_rct_tab(l_cnt).routing_category_id := ph_rec.routing_category_id;
       End if;
     End loop;
  Else
     For sh_rec in csr_sh loop
       If nvl(sh_rec.default_flag,'X') <> 'Y' and nvl(sh_rec.delete_flag,'X') <> 'Y' then
         l_cnt := l_cnt + 1;
         l_rct_tab(l_cnt).routing_category_id := sh_rec.routing_category_id;
       End if;
     End loop;
  End if;
  --
  --
  l_rec_count := 0;
  --
  If l_cnt > 0 then
   For l_dummy in 1..l_cnt loop
    --
    --
    hr_utility.set_location('Getting rules for'||to_char(l_rct_tab(l_dummy).routing_category_id), 100);
    Open csr_rules(l_rct_tab(l_dummy).routing_category_id);
    Fetch csr_rules into l_x;
    If csr_rules%notfound then
       hr_utility.set_location('No routing rules ', 100);
       l_no_of_rules := 0;
    else
       hr_utility.set_location('Exist routing rules ', 100);
      l_no_of_rules := 1;
    End if;
    Close csr_rules;
    --
    l_rec_count := l_rec_count + 1;
    --
    -- No rules were defined for this routing category.
    --
    If l_no_of_rules = 0  then
       --
       hr_utility.set_location('rules =0', 100);
       l_no_of_errors := l_no_of_errors + 1;
       pqh_tct_bus.get_routing_category_name
                                 (p_routing_category_id   => l_rct_tab(l_dummy).routing_category_id,
                                  p_routing_category_name => l_list_name);
       --
       hr_utility.set_message(8302,'PQH_NO_RULES_IN_ROUTING_CAT');
       hr_utility.set_message_token('LIST_NAME', l_list_name);
       p_error_messages(l_no_of_errors).message_text :='* '|| hr_utility.get_message;
       --
       p_no_errors := l_no_of_errors;
       --
       RETURN FALSE;
       --
    End if;
    --
   End loop;
  --
  End if;
  --
  -- The transaction category must have at least one routing category though
  --
  If l_rec_count = 0 then
     --
     l_no_of_errors := l_no_of_errors + 1;
     hr_utility.set_message(8302,'PQH_NO_ROUTING_CAT_IN_TCT');
     p_error_messages(l_no_of_errors).message_text :='* '|| hr_utility.get_message;
     --
     p_no_errors := l_no_of_errors;
     --
     RETURN FALSE;
  End if;
  --
  p_no_errors := l_no_of_errors;
  RETURN TRUE;
  --
  /**
  sql_stmt := 'Select rct.routing_category_id, count(rng.range_name)'
           || ' from pqh_routing_categories rct,pqh_attribute_ranges rng'
           || ' Where rct.transaction_category_id = :p_transaction_category_id'
           || '   and rct.enable_flag = :p_enable_flag'
           || '   and nvl(rct.default_flag,:null1) <> :p_default_flag'
           || '   and nvl(rct.delete_flag,:null2) <> :p_delete_flag';
  --
  If p_routing_type = 'R' then
     sql_stmt := sql_stmt || ' and rct.routing_list_id IS NOT NULL';
  Elsif p_routing_type = 'P' then
     sql_stmt := sql_stmt || ' and rct.position_structure_id IS NOT NULL';
  Else
     sql_stmt := sql_stmt || ' and rct.routing_list_id IS NULL and rct.position_structure_id IS NULL';
  End if;
  --
  sql_stmt := sql_stmt || ' and rct.routing_category_id = rng.routing_category_id(+)'
           || ' and rng.enable_flag(+) = :p_rule_enable'
           || ' and nvl(rng.delete_flag(+),:null3) <> :p_rule_delete'
           || ' and rng.routing_list_member_id(+) IS NULL'
           || ' and rng.position_id(+) IS NULL'
           || ' and rng.assignment_id(+) IS NULL'
           || ' group by rct.routing_category_id'
           || ' order by rct.routing_category_id';
  --
  -- Select the no of routing categories and no of rules under the routing
  -- category.
  --
  --
  Open csr_routing for sql_stmt using p_transaction_category_id,'Y','N','Y',
                                      'N','Y','Y','N','Y';
  --
  l_rec_count := 0;
  --
  Loop
    --
    Fetch csr_routing into l_routing_category_id,l_no_of_rules;
    --
    If csr_routing%notfound then
       exit;
    End if;
    --
    l_rec_count := l_rec_count + 1;
    --
    -- No rules were defined for this routing category.
    --
    If l_no_of_rules = 0  then
       --
       Close csr_routing;
       --
       l_no_of_errors := l_no_of_errors + 1;
       pqh_tct_bus.get_routing_category_name
                                 (p_routing_category_id =>l_routing_category_id,
                                  p_routing_category_name=> l_list_name);
       --
       hr_utility.set_message(8302,'PQH_NO_RULES_IN_ROUTING_CAT');
       hr_utility.set_message_token('LIST_NAME', l_list_name);
       p_error_messages(l_no_of_errors).message_text :='* '|| hr_utility.get_message;
       --
       p_no_errors := l_no_of_errors;
       --
       RETURN FALSE;
       --
    End if;
    --
  End loop;
  --
  Close csr_routing;
  --
  -- The transaction category must have at least one routing category though
  --
  If l_rec_count = 0 then
     --
     l_no_of_errors := l_no_of_errors + 1;
     hr_utility.set_message(8302,'PQH_NO_ROUTING_CAT_IN_TCT');
     p_error_messages(l_no_of_errors).message_text :='* '|| hr_utility.get_message;
     --
     p_no_errors := l_no_of_errors;
     --
     RETURN FALSE;
  End if;
  --
  p_no_errors := l_no_of_errors;
  RETURN TRUE;
  --
  **/
End;
--
------------------------------------------------------------------------------------
--
Function chk_rout_overlap_on_freeze(p_transaction_category_id in number,
                                    p_routing_type            in varchar2)
RETURN BOOLEAN is
--
l_routing_category_id  pqh_routing_categories.routing_category_id%type;
--
type cur_type   IS REF CURSOR;
csr_chk_rule_overlap     cur_type;
sql_stmt           varchar2(2000);
--
l_error_code               number(10);
--
--
l_overlap_range_name       pqh_attribute_ranges.range_name%type;
l_error_range_name         pqh_attribute_ranges.range_name%type;
l_error_routing_category varchar2(200);
l_proc             varchar2(72) := 'chk_overlap_on_freeze_cat';
--
/** Perf changes
Select rct.routing_category_id,default_flag,delete_flag
From pqh_routing_categories rct
Where rct.transaction_category_id = :p_transaction_category_id
and rct.enable_flag = 'Y'
and rct.routing_list_id is not null
**/

Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Select all routing categories under the transaction category that
-- belong to the current routing type
--
sql_stmt := 'Select rct.routing_category_id From pqh_routing_categories rct ';
--
sql_stmt := sql_stmt ||' Where rct.transaction_category_id = :p_transaction_category_id and rct.enable_flag = :p_enable_flag  and nvl(rct.default_flag,:null_value) <> :default_flag and nvl(rct.delete_flag,:null2) <> :delete_flag ';
--
If p_routing_type = 'R' then
   --
   sql_stmt := sql_stmt || ' and rct.routing_list_id is not null';
   --
Elsif p_routing_type = 'P' then
   --
   sql_stmt := sql_stmt || ' and rct.position_structure_id is not null';
   --
Else
   --
   sql_stmt := sql_stmt || ' and rct.routing_list_id is null and rct.position_structure_id is null';
   --
End if;

sql_stmt := sql_stmt || ' order by rct.routing_category_id ';
--
--
-- We have the sql_stmt that we can execute.
--
Open csr_chk_rule_overlap for sql_stmt using p_transaction_category_id,'Y','N','Y','N','Y';
--
loop
  --
  l_error_code := 0;
  --
  Fetch csr_chk_rule_overlap into  l_routing_category_id ;
  --
  If csr_chk_rule_overlap%notfound then
     Close csr_chk_rule_overlap;
     exit;
  End if;
  --
  l_error_code := pqh_attribute_ranges_pkg.chk_enable_routing_category
       (p_routing_category_id      => l_routing_category_id,
        p_transaction_category_id  => p_transaction_category_id,
        p_overlap_range_name       => l_overlap_range_name,
        p_error_routing_category   => l_error_routing_category,
        p_error_range_name         => l_error_range_name);
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
  If l_error_code = 1 then
     --
     Close csr_chk_rule_overlap;
     RETURN FALSE;
     --
  End if;
  --
End loop;
--
RETURN TRUE;
--
End;
--
----------------------------------------------------------------------------------------------
--
FUNCTION chk_mem_overlap_on_freeze(
          p_transaction_category_id in number,
          p_routing_type            in varchar2,
          p_routing_category_id     in number default NULL,
          p_error_routing_cat       out nocopy varchar2,
          p_member_name             out nocopy varchar2,
          p_overlap_range_1         out nocopy varchar2,
          p_overlap_range_2         out nocopy varchar2)
--
RETURN BOOLEAN is
--
  l_error_routing_category   varchar2(200);
  l_member_name              varchar2(300);
  l_overlap_range_name       pqh_attribute_ranges.range_name%type;
  l_error_range_name         pqh_attribute_ranges.range_name%type;
--
  l_prev_range_name       pqh_attribute_ranges.range_name%type;
  l_prev_routing_category_id  pqh_routing_categories.routing_category_id%type;
  l_prev_member_id        number(30);
--
  cnt                     number(10);
  l_attribute_range_id_list  varchar2(2000);
  l_no_mem_identifiers    number(10);
--
  l_routing_category_id  pqh_routing_categories.routing_category_id%type;
  l_range_name       pqh_attribute_ranges.range_name%type;
  l_member_id        number(30);
  l_attribute_range_id pqh_attribute_ranges.attribute_range_id %type;
  l_attribute_id     pqh_attribute_ranges.attribute_id%type;
  l_column_type      pqh_attributes.column_type%type;
  l_from_char        pqh_attribute_ranges.from_char%type;
  l_to_char          pqh_attribute_ranges.to_char%type;
  l_from_date        pqh_attribute_ranges.from_date%type;
  l_to_date          pqh_attribute_ranges.to_date%type;
  l_from_number      pqh_attribute_ranges.from_number%type;
  l_to_number        pqh_attribute_ranges.to_number%type;
--
l_error_code    number(10) := NULL;
--
type cur_type   IS REF CURSOR;
csr_mem_overlap     cur_type;
sql_stmt           varchar2(2000);
--
all_routing_rules  pqh_attribute_ranges_pkg.rule_attr_tab;
all_attributes_tab  pqh_attribute_ranges_pkg.rule_attr_tab;
--
Cursor csr_mem_ident_cnt is
  Select count(*)
    from pqh_txn_category_attributes
  Where transaction_category_id = p_transaction_category_id
    AND member_identifying_flag = 'Y';
--
l_proc             varchar2(72) := 'chk_mem_overlap_on_freeze';
--
Begin
--
 hr_utility.set_location('Entering:'||l_proc, 5);
--
Open csr_mem_ident_cnt;
Fetch csr_mem_ident_cnt into l_no_mem_identifiers;
Close csr_mem_ident_cnt;
--
sql_stmt := 'Select rct.routing_category_id, rng.range_name ,';
--
If p_routing_type = 'R' then
   --
   sql_stmt := sql_stmt || ' rng.routing_list_member_id,';
   --
Elsif p_routing_type = 'P' then
   --
   sql_stmt := sql_stmt || ' rng.position_id,';
   --
Else
   --
   sql_stmt := sql_stmt || ' rng.assignment_id,';
   --
End if;
--
sql_stmt := sql_stmt ||' rng.attribute_range_id, rng.attribute_id, att.column_type, rng.from_char, rng.to_char, rng.from_number, rng.to_number, rng.from_date, rng.to_date ';
--
sql_stmt := sql_stmt ||' From pqh_routing_categories rct,pqh_attribute_ranges rng,pqh_attributes att ';
--
sql_stmt := sql_stmt ||' Where rct.transaction_category_id = :p_transaction_category_id  and rct.enable_flag = :enable_flag and nvl(rct.default_flag,:null_value) <> :default_flag  and nvl(rct.delete_flag,:null2) <> :delete_flag ';
--
-- If a routing category is passed, process only this routing category.
--
If p_routing_category_id IS NOT NULL then
   sql_stmt := sql_stmt ||' and rct.routing_category_id = :routing_category_id';
End if;
--
sql_stmt := sql_stmt ||' and rng.routing_category_id = rct.routing_category_id and rng.attribute_id = att.attribute_id';
--
If p_routing_type = 'R' then
   --
   sql_stmt := sql_stmt || ' and rct.routing_list_id is not null';
   --
Elsif p_routing_type = 'P' then
   --
   sql_stmt := sql_stmt || ' and rct.position_structure_id is not null';
   --
Else
   --
   sql_stmt := sql_stmt || ' and rct.routing_list_id is null and rct.position_structure_id is null';
   --
End if;
--
sql_stmt := sql_stmt || ' and rng.enable_flag = :rule_enable and nvl(rng.delete_flag,:null3) <> :delete_flag ';
--
If p_routing_type = 'R' then
   --
   sql_stmt := sql_stmt || ' and rng.routing_list_member_id is not null';
   --
Elsif p_routing_type = 'P' then
   --
   sql_stmt := sql_stmt || ' and rng.position_id is not null';
   --
Else
   --
   sql_stmt := sql_stmt || ' and rng.assignment_id is not null ';
   --
End if;
--
sql_stmt := sql_stmt || ' order by rct.routing_category_id,rng.range_name,rng.attribute_id';
--
--
-- We have the sql_stmt that we can execute.
--
If p_routing_category_id IS NOT NULL then
  Open csr_mem_overlap for sql_stmt using p_transaction_category_id,'Y','N','Y','N','Y',p_routing_category_id,'Y','N','Y';
Else
  Open csr_mem_overlap for sql_stmt using p_transaction_category_id,'Y','N','Y','N','Y','Y','N','Y';
End if;
--
cnt := 0;
l_prev_range_name := NULL;
l_prev_routing_category_id := NULL;
l_prev_member_id := NULL;
--

loop
  --
  Fetch csr_mem_overlap into  l_routing_category_id, l_range_name,
                                 l_member_id,
                                 l_attribute_range_id,l_attribute_id,
                                 l_column_type,
                                 l_from_char,l_to_char,
                                 l_from_number,l_to_number,
                                 l_from_date,l_to_date;
  If csr_mem_overlap%notfound then
     hr_utility.set_location('Closing cursor',100);
     Close csr_mem_overlap;
     exit;
  End if;
  --
   --
   -- Check if there is a change in rule name
   --
   If  l_routing_category_id <> l_prev_routing_category_id OR
       nvl(l_range_name,'xXx') <> nvl(l_prev_range_name,hr_api.g_varchar2)  then
       --
        hr_utility.set_location('New rule:'||l_range_name ||l_proc, 6);
        --
        If  cnt > 0  then
            hr_utility.set_location('Rules exist '||l_proc, 6);
            --
            -- call chk_routing_range_overlap procedure to check if this rule
            -- overlaps with any other routing rules under that
            -- transaction category.
            --
            hr_utility.set_location('Calling chk_member_range_overlap:'||l_proc, 6);
            l_error_code := pqh_attribute_ranges_pkg.chk_member_range_overlap
                (tab1                      => all_routing_rules ,
                 tab2                      => all_attributes_tab,
                 p_transaction_category_id => p_transaction_category_id,
                 p_routing_category_id     => l_prev_routing_category_id,
                 p_range_name              => l_prev_range_name,
                 p_routing_type            => p_routing_type,
                 p_member_id               => l_prev_member_id,
                 p_attribute_range_id_list => l_attribute_range_id_list,
                 p_no_attributes           => l_no_mem_identifiers,
                 p_error_range             => l_error_range_name);
            --
            If l_error_code = 1 then
               --
               Close csr_mem_overlap;
               --
               p_overlap_range_1 := l_prev_range_name;
               p_overlap_range_2 := l_error_range_name;
               --
               pqh_tct_bus.get_routing_category_name(
                 p_routing_category_id   => l_prev_routing_category_id,
                 p_routing_category_name => l_error_routing_category);
               --
               pqh_attribute_ranges_pkg.get_member_name
                    (p_member_id               => l_prev_member_id,
                     p_routing_type            => p_routing_type,
                     p_member_name             => l_member_name);
               --
               p_error_routing_cat := l_error_routing_category;
               p_member_name := l_member_name;
               --
               RETURN FALSE;
               --
            End if;
            --
        End if;
        -- Reset counters
        hr_utility.set_location('Reset counter'||l_proc, 6);
        --
        cnt := 1;
        l_prev_routing_category_id := l_routing_category_id;
        l_prev_range_name := l_range_name;
        l_prev_member_id  := l_member_id;
        --
        l_error_code := NULL;
        l_error_routing_category := NULL;
        l_error_range_name := NULL;
        l_attribute_range_id_list := NULL;
        --
  Else
     hr_utility.set_location('Increment counter'||l_proc, 6);
         -- If we are processing same rule , increment counter
         cnt := cnt + 1;
         l_attribute_range_id_list := l_attribute_range_id_list || ',';

  End if;
  --
  all_routing_rules(cnt).attribute_id := l_attribute_id;
  all_attributes_tab(cnt).attribute_id := l_attribute_id;
  all_routing_rules(cnt).datatype := l_column_type;
  all_attributes_tab(cnt).datatype := l_column_type;
  all_routing_rules(cnt).from_char := l_from_char;
  all_routing_rules(cnt).to_char := l_to_char;
  all_routing_rules(cnt).from_number := l_from_number;
  all_routing_rules(cnt).to_number := l_to_number;
  all_routing_rules(cnt).from_date := l_from_date;
  all_routing_rules(cnt).to_date := l_to_date;
  --
  l_attribute_range_id_list := l_attribute_range_id_list || to_char(l_attribute_range_id);
  --
End loop;
--
If  cnt > 0  then
--
  hr_utility.set_location('Rules exist '||l_proc, 6);
  --
  -- call chk_routing_range_overlap procedure to check if this rule
  -- overlaps with any other routing rules under that
  -- transaction category.
  --
  hr_utility.set_location('Calling chk_routing_range_overlap:'||l_proc, 6);
  --
  l_error_code := pqh_attribute_ranges_pkg.chk_member_range_overlap
                (tab1                      => all_routing_rules ,
                 tab2                      => all_attributes_tab,
                 p_transaction_category_id => p_transaction_category_id,
                 p_routing_category_id     => l_prev_routing_category_id,
                 p_range_name              => l_prev_range_name,
                 p_routing_type            => p_routing_type,
                 p_member_id               => l_prev_member_id,
                 p_attribute_range_id_list => l_attribute_range_id_list,
                 p_no_attributes           => l_no_mem_identifiers,
                 p_error_range             => l_error_range_name);
  --
  If l_error_code = 1 then
  --
     --
     -- Get the name of the routing category and member for
     -- whom there is a overlap.
     --
     --
     p_overlap_range_1 := l_prev_range_name;
     p_overlap_range_2 := l_error_range_name;
     --
     pqh_tct_bus.get_routing_category_name(
      p_routing_category_id   => l_prev_routing_category_id,
      p_routing_category_name => l_error_routing_category);
     --
     pqh_attribute_ranges_pkg.get_member_name
     (p_member_id               => l_prev_member_id,
      p_routing_type            => p_routing_type,
      p_member_name             => l_member_name);
     --
     p_error_routing_cat := l_error_routing_category;
     p_member_name := l_member_name;
     --
     RETURN FALSE;
     --
  End if;
  --
End if;
--
hr_utility.set_location('Leaving'||l_proc, 10);
--
RETURN TRUE;
--
End;
--
--------------------------------------------------------------------------------------------------
--
FUNCTION check_errors_in_adv_setup(p_transaction_category_id in number,
                                   p_error_messages          out nocopy  warnings_tab)
RETURN boolean IS
--
l_setup_status             boolean := TRUE;
l_status                   boolean := TRUE;
--
l_error_index              number(10) := 0;
l_error_messages           warnings_tab;
--
l_routing_type             pqh_transaction_categories.member_cd%type;
--
l_error_routing_category   varchar2(200);
l_member_name              varchar2(300);
l_overlap_range_name       pqh_attribute_ranges.range_name%type;
l_error_range_name         pqh_attribute_ranges.range_name%type;
--
--
Cursor csr_routing_type is
  Select member_Cd
    From pqh_transaction_categories
  Where transaction_category_id = p_transaction_category_id;
--
Begin
--
-- Obtain the routing type of the transaction category
--
open csr_routing_type;
Fetch csr_routing_type into l_routing_type;
Close csr_routing_type;
--
-- The Advanced setup performs 3 validations. If these 3 validations are successful , then
-- The Advanced setup is considered to be completed sucessfully.
-- The Validations are :
-- 1. There must be at least 1 enabled routing category , with enabled routing
-- rules.
--
l_status := chk_valid_rout_hier_exists
            (p_transaction_category_id     => p_transaction_category_id,
             p_routing_type                => l_routing_type,
             p_error_messages              => l_error_messages,
             p_no_errors                   => l_error_index);
If NOT l_status then
   --
   l_setup_status := FALSE;
   --
End if;
--
-- 2. Routing rules must not overlap with other routing rules in the transaction category.
--
p_error_messages := l_error_messages;
--
l_status := chk_rout_overlap_on_freeze
              (p_transaction_category_id => p_transaction_category_id,
               p_routing_type            => l_routing_type);
--
If NOT l_status then
   --
   l_error_index := l_error_index + 1;
   hr_utility.set_message(8302,'PQH_TCW_ADV_ERROR1');
   p_error_messages(l_error_index).message_text := hr_utility.get_message;
   --
   l_setup_status := FALSE;
   --
End if;
--
-- 3. Authorization rules should not overlap for the same approver, within a routing category.
--
l_status := chk_mem_overlap_on_freeze
         (p_transaction_category_id => p_transaction_category_id,
          p_routing_type            => l_routing_type,
          p_error_routing_cat       => l_error_routing_category,
          p_member_name             => l_member_name,
          p_overlap_range_1         => l_overlap_range_name,
          p_overlap_range_2         => l_error_range_name);
--
If NOT l_status then
   --
   l_error_index := l_error_index + 1;
   hr_utility.set_message(8302,'PQH_TCW_ADV_ERROR2');
   p_error_messages(l_error_index).message_text := hr_utility.get_message;
   --
   l_setup_status := FALSE;
   --
End if;
--
RETURN l_setup_status;
--
End;
--
-----------------------------------------------------------------------------------------------
--
FUNCTION check_if_adv_setup_started(p_transaction_category_id in number)
RETURN BOOLEAN is
--
Cursor csr_member_cd(p_transaction_category_id in  number) is
Select member_cd
  from pqh_transaction_categories
 Where transaction_category_id = p_transaction_category_id;
--
Cursor csr_hier (p_transaction_category_id in number,
                 p_member_cd               in varchar2) is
Select routing_category_id
 from pqh_routing_categories_v a
where a.transaction_category_id = p_transaction_category_id
  and a.member_cd = p_member_cd
  and nvl(a.enable_flag,'Y') = 'Y'
  and nvl(a.delete_flag,'N') <> 'Y'
  and nvl(a.default_flag,'N') <> 'Y';
--
l_routing_category_id  pqh_routing_categories.routing_category_id%type;
l_member_cd            pqh_transaction_categories.member_cd%type;
--
l_error_status         boolean := TRUE;
l_proc 	varchar2(72) := 'check_if_adv_setup_started';
--
--
Begin
  --
  hr_utility.set_location('Entering'||l_proc, 5);
  --
  -- Obtain the routing style of the transcation category.
  --
  Open csr_member_cd(p_transaction_category_id => p_transaction_category_id);
  Fetch csr_member_cd into l_member_cd;
  Close csr_member_cd;
  --
  Open csr_hier(p_transaction_category_id => p_transaction_category_id,
                p_member_cd               => l_member_cd);
  Fetch csr_hier into l_routing_category_id;
  --
  -- Check if any default hierarchy is marked
  --
  If csr_hier%notfound then
     --
     l_error_status := FALSE;
     --
  Else
     --
     l_error_status := TRUE;
     --
  End if;
  --
  Close csr_hier;
  --
  hr_utility.set_location('Leaving'||l_proc, 10);
  --
  RETURN l_error_status;
  --
END;
--
---------------------------------------------------------------------------------------------
Procedure delete_hierarchy_and_rules(p_transaction_category_id  in  number,
                                     p_routing_style            in  varchar2) is
--
--
type cur_type   IS REF CURSOR;
csr_del_all     cur_type;
sql_stmt1       varchar2(2000);
--
l_proc 	varchar2(72) := 'delete_hierarchy_and_rules';
--
BEGIN
--
--
hr_utility.set_location('Entering'||l_proc, 5);
--
-- The following cursor deletes the rules under the routing hierarchies
-- that were selected for  deletion for the passed transaction category
-- and its current routing style.
--
sql_stmt1 := 'Delete From pqh_attribute_ranges rng Where';
--
   sql_stmt1 := sql_stmt1 || ' rng.routing_category_id in ('
                          || ' Select routing_category_id '
                          || ' from pqh_routing_categories rct '
                          ||'  Where rct.transaction_category_id = :p_transaction_category_id  and nvl(rct.default_flag,:null_value) <> :default_flag  and nvl(rct.delete_flag,:null2) = :delete_flag ';
--
If p_routing_style = 'R' then
   --
   sql_stmt1 := sql_stmt1 || ' and rct.routing_list_id is not null)';
   --
Elsif p_routing_style = 'P' then
   --
   sql_stmt1 := sql_stmt1 || ' and rct.position_structure_id is not null)';
   --
Else
   --
   sql_stmt1 := sql_stmt1 || ' and rct.routing_list_id is null and rct.position_structure_id is null)';
   --
End if;
--
Execute immediate sql_stmt1 using p_transaction_category_id,'N','Y','N','Y';
--
-- The following cursor selects all routing hierarchies that were selected for
-- deletion for the passed transaction category and its current routing style.
--
sql_stmt1 := 'Delete From pqh_routing_categories rct';
--
sql_stmt1 := sql_stmt1 ||' Where rct.transaction_category_id = :p_transaction_category_id  and nvl(rct.default_flag,:null_value) <> :default_flag  and nvl(rct.delete_flag,:null2) = :delete_flag ';
--
If p_routing_style = 'R' then
   --
   sql_stmt1 := sql_stmt1 || ' and rct.routing_list_id is not null';
   --
Elsif p_routing_style = 'P' then
   --
   sql_stmt1 := sql_stmt1 || ' and rct.position_structure_id is not null';
   --
Else
   --
   sql_stmt1 := sql_stmt1 || ' and rct.routing_list_id is null and rct.position_structure_id is null';
   --
End if;
--
Execute immediate sql_stmt1 using p_transaction_category_id,'N','Y','N','Y';
--
-- Finally we need to delete just the rules that were selected for deletion
-- under this transaction category and routing style.
--
sql_stmt1 := 'Delete From pqh_attribute_ranges rng '
           ||' Where nvl(rng.delete_flag,:null1) = :delete_flag ';
--
sql_stmt1 := sql_stmt1 ||' and rng.routing_category_id in ('
                       ||' Select routing_category_id '
                       ||' from pqh_routing_categories rct '
                       ||' Where rct.transaction_category_id = :p_transaction_category_id  ';
--
If p_routing_style = 'R' then
   --
   sql_stmt1 := sql_stmt1 || ' and rct.routing_list_id is not null)';
   --
Elsif p_routing_style = 'P' then
   --
   sql_stmt1 := sql_stmt1 || ' and rct.position_structure_id is not null)';
   --
Else
   --
   sql_stmt1 := sql_stmt1 || ' and rct.routing_list_id is null and rct.position_structure_id is null)';
   --
End if;
--
Execute immediate sql_stmt1 using 'N','Y',p_transaction_category_id;
--
hr_utility.set_location('Leaving'||l_proc, 10);
--
END delete_hierarchy_and_rules;
---------------------------------------------------------------------------------------------
FUNCTION return_approver_status(p_routing_category_id   in  number,
                                p_approver_id           in  number,
                                p_routing_style         in  varchar2)
RETURN varchar2 is
--
type cur_type    IS REF CURSOR;
csr_appr         cur_type;
sql_stmt1        varchar2(2000);
--
l_approver_flag  pqh_attribute_ranges.approver_flag%type;
--
l_proc 	varchar2(72) := 'return_approver_status';
--
BEGIN
--
--
hr_utility.set_location('Entering'||l_proc, 5);
--
-- The following cursor selects the approver flag on all the rules for the
-- approver under the passed routing category.
--
sql_stmt1 := 'Select approver_flag From pqh_attribute_ranges rng '
          || ' Where rng.routing_category_id = :routing_category_id';
--
If p_routing_style = 'R' then
   --
   sql_stmt1 := sql_stmt1 || ' and rng.routing_list_member_id IS NOT NULL and rng.routing_list_member_id = :approver_id';
   --
Elsif p_routing_style = 'P' then
   --
   sql_stmt1 := sql_stmt1 || ' and rng.position_id IS NOT NULL and rng.position_id = :approver_id';
   --
Else
   --
   sql_stmt1 := sql_stmt1 || ' and rng.assignment_id IS NOT NULL  and rng.assignment_id = :approver_id';
   --
End if;
--
--
Open  csr_appr for sql_stmt1 using p_routing_category_id,p_approver_id;
--
Loop
  --
  Fetch csr_appr into l_approver_flag;
  If csr_appr%notfound then
     exit;
  End if;

  If nvl(l_approver_flag,'N') = 'Y' then
     Close csr_appr;
     RETURN 'Y';
  End if;
  --
End loop;

--
hr_utility.set_location('Leaving'||l_proc, 10);
--
RETURN 'N';
--
END return_approver_status;
----------------------------------------------------------------------------------------
FUNCTION return_person_name(p_assignment_id   in  number)
RETURN varchar2 is
--
--
Cursor csr_name is
Select full_name
from per_all_assignments_f ASG, per_all_people_f PPL, fnd_sessions ses
Where asg.assignment_id = p_assignment_id
AND asg.person_id = PPL.person_id
AND SES.SESSION_ID = USERENV('sessionid')
AND SES.EFFECTIVE_DATE BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE
AND SES.EFFECTIVE_DATE BETWEEN PPL.EFFECTIVE_START_DATE AND PPL.EFFECTIVE_END_DATE;
--
l_name per_all_people_f.full_name%type;
l_proc 	varchar2(72) := 'return_person_name';
--
BEGIN
--
hr_utility.set_location('Entering'||l_proc, 5);
--
Open csr_name;
Fetch csr_name into l_name;
Close csr_name;
--
hr_utility.set_location('Leaving'||l_proc, 10);
--
RETURN l_name;
--
End return_person_name;

END pqh_tct_wizard_pkg;

/
