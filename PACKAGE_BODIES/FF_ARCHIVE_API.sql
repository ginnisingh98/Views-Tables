--------------------------------------------------------
--  DDL for Package Body FF_ARCHIVE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_ARCHIVE_API" as
/* $Header: ffarcapi.pkb 115.4 2002/12/23 15:12:07 arashid ship $ */
--
-- Package Variables
--
Type context_id_tab_type is table of number index by binary_integer;
--
g_context_ids          context_id_tab_type;
g_context_stored_names context_tab_type;
g_context_names        context_tab_type;
g_context_values       context_tab_type;
g_package  varchar2(33) := '  ff_archive_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< convert_params (private)>-----------------------|
-- ----------------------------------------------------------------------------
--
procedure convert_params
( p_context_name1                 in     varchar2  default null
 ,p_context1                      in     varchar2  default null
 ,p_context_name2                 in     varchar2  default null
 ,p_context2                      in     varchar2  default null
 ,p_context_name3                 in     varchar2  default null
 ,p_context3                      in     varchar2  default null
 ,p_context_name4                 in     varchar2  default null
 ,p_context4                      in     varchar2  default null
 ,p_context_name5                 in     varchar2  default null
 ,p_context5                      in     varchar2  default null
 ,p_context_name6                 in     varchar2  default null
 ,p_context6                      in     varchar2  default null
 ,p_context_name7                 in     varchar2  default null
 ,p_context7                      in     varchar2  default null
 ,p_context_name8                 in     varchar2  default null
 ,p_context8                      in     varchar2  default null
 ,p_context_name9                 in     varchar2  default null
 ,p_context9                      in     varchar2  default null
 ,p_context_name10                in     varchar2  default null
 ,p_context10                     in     varchar2  default null
 ,p_context_name11                in     varchar2  default null
 ,p_context11                     in     varchar2  default null
 ,p_context_name12                in     varchar2  default null
 ,p_context12                     in     varchar2  default null
 ,p_context_name13                in     varchar2  default null
 ,p_context13                     in     varchar2  default null
 ,p_context_name14                in     varchar2  default null
 ,p_context14                     in     varchar2  default null
 ,p_context_name15                in     varchar2  default null
 ,p_context15                     in     varchar2  default null
 ,p_context_name16                in     varchar2  default null
 ,p_context16                     in     varchar2  default null
 ,p_context_name17                in     varchar2  default null
 ,p_context17                     in     varchar2  default null
 ,p_context_name18                in     varchar2  default null
 ,p_context18                     in     varchar2  default null
 ,p_context_name19                in     varchar2  default null
 ,p_context19                     in     varchar2  default null
 ,p_context_name20                in     varchar2  default null
 ,p_context20                     in     varchar2  default null
 ,p_context_name21                in     varchar2  default null
 ,p_context21                     in     varchar2  default null
 ,p_context_name22                in     varchar2  default null
 ,p_context22                     in     varchar2  default null
 ,p_context_name23                in     varchar2  default null
 ,p_context23                     in     varchar2  default null
 ,p_context_name24                in     varchar2  default null
 ,p_context24                     in     varchar2  default null
 ,p_context_name25                in     varchar2  default null
 ,p_context25                     in     varchar2  default null
 ,p_context_name26                in     varchar2  default null
 ,p_context26                     in     varchar2  default null
 ,p_context_name27                in     varchar2  default null
 ,p_context27                     in     varchar2  default null
 ,p_context_name28                in     varchar2  default null
 ,p_context28                     in     varchar2  default null
 ,p_context_name29                in     varchar2  default null
 ,p_context29                     in     varchar2  default null
 ,p_context_name30                in     varchar2  default null
 ,p_context30                     in     varchar2  default null
 ,p_context_name31                in     varchar2  default null
 ,p_context31                     in     varchar2  default null
) IS
--
l_proc varchar2(70) := g_package||'convert_params';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_context_names(1) := p_context_name1;
  g_context_values(1) := p_context1;
  g_context_names(2) := p_context_name2;
  g_context_values(2) := p_context2;
  g_context_names(3) := p_context_name3;
  g_context_values(3) := p_context3;
  g_context_names(4) := p_context_name4;
  g_context_values(4) := p_context4;
  g_context_names(5) := p_context_name5;
  g_context_values(5) := p_context5;
  g_context_names(6) := p_context_name6;
  g_context_values(6) := p_context6;
  g_context_names(7) := p_context_name7;
  g_context_values(7) := p_context7;
  g_context_names(8) := p_context_name8;
  g_context_values(8) := p_context8;
  g_context_names(9) := p_context_name9;
  g_context_values(9) := p_context9;
  g_context_names(10) := p_context_name10;
  g_context_values(10) := p_context10;
  g_context_names(11) := p_context_name11;
  g_context_values(11) := p_context11;
  g_context_names(12) := p_context_name12;
  g_context_values(12) := p_context12;
  g_context_names(13) := p_context_name13;
  g_context_values(13) := p_context13;
  g_context_names(14) := p_context_name14;
  g_context_values(14) := p_context14;
  g_context_names(15) := p_context_name15;
  g_context_values(15) := p_context15;
  g_context_names(16) := p_context_name16;
  g_context_values(16) := p_context16;
  g_context_names(17) := p_context_name17;
  g_context_values(17) := p_context17;
  g_context_names(18) := p_context_name18;
  g_context_values(18) := p_context18;
  g_context_names(19) := p_context_name19;
  g_context_values(19) := p_context19;
  g_context_names(20) := p_context_name20;
  g_context_values(20) := p_context20;
  g_context_names(21) := p_context_name21;
  g_context_values(21) := p_context21;
  g_context_names(22) := p_context_name22;
  g_context_values(22) := p_context22;
  g_context_names(23) := p_context_name23;
  g_context_values(23) := p_context23;
  g_context_names(24) := p_context_name24;
  g_context_values(24) := p_context24;
  g_context_names(25) := p_context_name25;
  g_context_values(25) := p_context25;
  g_context_names(26) := p_context_name26;
  g_context_values(26) := p_context26;
  g_context_names(27) := p_context_name27;
  g_context_values(27) := p_context27;
  g_context_names(28) := p_context_name28;
  g_context_values(28) := p_context28;
  g_context_names(29) := p_context_name29;
  g_context_values(29) := p_context29;
  g_context_names(30) := p_context_name30;
  g_context_values(30) := p_context30;
  g_context_names(31) := p_context_name31;
  g_context_values(31) := p_context31;
--
hr_utility.set_location('Leaving:'||l_proc, 10);
--
end convert_params;
-- ----------------------------------------------------------------------------
-- |------------------------< get_context_id (private)>-----------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_context_id(p_context_name in varchar2,
                        p_legislation_code in varchar2) RETURN NUMBER IS
--
  l_context_id number;
  l_count number;
--
  cursor get_context1 (c_context_name varchar2, c_legislation_code varchar2) is
  select plc.context_id
  from pay_legislation_contexts plc
  where plc.legislation_name = c_context_name
  and plc.legislation_code = c_legislation_code;
  --
  cursor get_context2 (c_context_name varchar2) is
  select ffc.context_id
  from ff_contexts ffc
  where ffc.context_name = c_context_name;
--
BEGIN
--
  l_count := 0;
  BEGIN
     LOOP
       l_count := l_count + 1;
       IF g_context_stored_names(l_count) = p_context_name THEN
          l_context_id := g_context_ids(l_count);
          hr_utility.trace('Using Cached Context ID for '||p_context_name);
          exit;
       END IF;
     END LOOP;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    --
    open get_context2(p_context_name);
    fetch get_context2 into l_context_id;
    close get_context2;
    --
    if l_context_id is null then
      open get_context1(p_context_name,p_legislation_code);
      fetch get_context1 into l_context_id;
      close get_context1;
    end if;
    --
    g_context_stored_names(l_count) := p_context_name;
    g_context_ids(l_count) := l_context_id;
  END;
--
RETURN l_context_id;
--
end get_context_id;
-- ----------------------------------------------------------------------------
-- |--------------------------< create_archive_item >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_archive_item
  (p_validate                      in     boolean  default false
  ,p_archive_item_id                  out nocopy number
  ,p_user_entity_id                in     number
  ,p_archive_value                 in     varchar2
  ,p_archive_type                  in     varchar2 default 'AAP'
  ,p_action_id                     in     number
  ,p_legislation_code              in     varchar2
  ,p_object_version_number            out nocopy number
  ,p_context_name1                 in     varchar2  default null
  ,p_context1                      in     varchar2  default null
  ,p_context_name2                 in     varchar2  default null
  ,p_context2                      in     varchar2  default null
  ,p_context_name3                 in     varchar2  default null
  ,p_context3                      in     varchar2  default null
  ,p_context_name4                 in     varchar2  default null
  ,p_context4                      in     varchar2  default null
  ,p_context_name5                 in     varchar2  default null
  ,p_context5                      in     varchar2  default null
  ,p_context_name6                 in     varchar2  default null
  ,p_context6                      in     varchar2  default null
  ,p_context_name7                 in     varchar2  default null
  ,p_context7                      in     varchar2  default null
  ,p_context_name8                 in     varchar2  default null
  ,p_context8                      in     varchar2  default null
  ,p_context_name9                 in     varchar2  default null
  ,p_context9                      in     varchar2  default null
  ,p_context_name10                in     varchar2  default null
  ,p_context10                     in     varchar2  default null
  ,p_context_name11                in     varchar2  default null
  ,p_context11                     in     varchar2  default null
  ,p_context_name12                in     varchar2  default null
  ,p_context12                     in     varchar2  default null
  ,p_context_name13                in     varchar2  default null
  ,p_context13                     in     varchar2  default null
  ,p_context_name14                in     varchar2  default null
  ,p_context14                     in     varchar2  default null
  ,p_context_name15                in     varchar2  default null
  ,p_context15                     in     varchar2  default null
  ,p_context_name16                in     varchar2  default null
  ,p_context16                     in     varchar2  default null
  ,p_context_name17                in     varchar2  default null
  ,p_context17                     in     varchar2  default null
  ,p_context_name18                in     varchar2  default null
  ,p_context18                     in     varchar2  default null
  ,p_context_name19                in     varchar2  default null
  ,p_context19                     in     varchar2  default null
  ,p_context_name20                in     varchar2  default null
  ,p_context20                     in     varchar2  default null
  ,p_context_name21                in     varchar2  default null
  ,p_context21                     in     varchar2  default null
  ,p_context_name22                in     varchar2  default null
  ,p_context22                     in     varchar2  default null
  ,p_context_name23                in     varchar2  default null
  ,p_context23                     in     varchar2  default null
  ,p_context_name24                in     varchar2  default null
  ,p_context24                     in     varchar2  default null
  ,p_context_name25                in     varchar2  default null
  ,p_context25                     in     varchar2  default null
  ,p_context_name26                in     varchar2  default null
  ,p_context26                     in     varchar2  default null
  ,p_context_name27                in     varchar2  default null
  ,p_context27                     in     varchar2  default null
  ,p_context_name28                in     varchar2  default null
  ,p_context28                     in     varchar2  default null
  ,p_context_name29                in     varchar2  default null
  ,p_context29                     in     varchar2  default null
  ,p_context_name30                in     varchar2  default null
  ,p_context30                     in     varchar2  default null
  ,p_context_name31                in     varchar2  default null
  ,p_context31                     in     varchar2  default null
  ,p_some_warning                     out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_table_archive_type varchar2(60);
  l_dummy number;
  l_context_id number;
  l_archive_item_id number;
  l_object_version_number number;
  l_count number := 0;
  --
  cursor get_format_item (c_user_entity_id number) is
  select 1 from dual where exists
  (select prfi.archive_type
  from pay_report_format_items_f prfi
  where prfi.user_entity_id = c_user_entity_id);
  --
  l_proc                varchar2(72) := g_package||'create_archive_item';
  invalid_archive_type exception;
  invalid_context exception;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_archive_item;
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Row Handlers
  --
  --1)Is the parameterised or defaulted archive type in the set
  --  'AAC','AAP','PA'. Error if not. If so, check whether there
  --  exists a row in PAY_REPORT_FORMAT_ITEMS_F for this user entity.
  --  This check is only necessary for AAC and PA types, an AAP type
  --  can be valid with no row in the format items table.
  --
  IF p_archive_type not in ('AAC','PA','AAP') then
    --
    -- Incorrect archive type passed in. Error.
       raise invalid_archive_type;
    --
  ELSE
    --
    if p_archive_type <> 'AAP' then
       --
       open get_format_item(p_user_entity_id);
       fetch get_format_item into l_dummy;
       if get_format_item%NOTFOUND then
          raise invalid_archive_type;
       end if;
       close get_format_item;
    end if;
    --
  END IF;
  --
  hr_utility.set_location(l_proc, 40);
  --
  --2)Is the parameter p_action_id either a valid assignment action
  --  or a valid payroll_action. If not, error.
  --  (This validation removed, with fix for 1162102).
  --
  -- Process Logic
  --
  --3)The single row has now been BP-validated so insert into
  --  FF_ARCHIVE_ITEMS using the Row Handler.
  --
  ff_arc_ins.ins
  (p_archive_item_id              => l_archive_item_id, -- an out param.
   p_user_entity_id               => p_user_entity_id,
   p_archive_type                 => p_archive_type,
   p_context1                     => p_action_id,
   p_value                        => p_archive_value,
   p_object_version_number        => l_object_version_number); -- an out param.
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Child table validation. Convert the parameters into a table structure.
  convert_params(
     p_context_name1      ,p_context1
    ,p_context_name2      ,p_context2
    ,p_context_name3      ,p_context3
    ,p_context_name4      ,p_context4
    ,p_context_name5      ,p_context5
    ,p_context_name6      ,p_context6
    ,p_context_name7      ,p_context7
    ,p_context_name8      ,p_context8
    ,p_context_name9      ,p_context9
    ,p_context_name10     ,p_context10
    ,p_context_name11     ,p_context11
    ,p_context_name12     ,p_context12
    ,p_context_name13     ,p_context13
    ,p_context_name14     ,p_context14
    ,p_context_name15     ,p_context15
    ,p_context_name16     ,p_context16
    ,p_context_name17     ,p_context17
    ,p_context_name18     ,p_context18
    ,p_context_name19     ,p_context19
    ,p_context_name20     ,p_context20
    ,p_context_name21     ,p_context21
    ,p_context_name22     ,p_context22
    ,p_context_name23     ,p_context23
    ,p_context_name24     ,p_context24
    ,p_context_name25     ,p_context25
    ,p_context_name26     ,p_context26
    ,p_context_name27     ,p_context27
    ,p_context_name28     ,p_context28
    ,p_context_name29     ,p_context29
    ,p_context_name30     ,p_context30
    ,p_context_name31     ,p_context31);
  --
  --4)Now loop through the record structure, and
  --  validate against either PAY_LEGISLATION_CONTEXTS or FF_CONTEXTS,
  --  by calling private function get_context_id. If there is no
  --  context ID for this, raise an error.
  --  If validated, call the archive_item_context API to insert the
  --  child rows.
  --
  BEGIN
  --
  -- Test that all necessary rows are in table.
     LOOP
       l_count := l_count + 1;
       --
       IF g_context_names(l_count) is not null then
         --
         -- Validate the Context by selecting its ID
         --
         l_context_id := get_context_id(g_context_names(l_count),p_legislation_code);
         --
         hr_utility.trace('Child Context ID:'||to_char(l_context_id));
         --
         IF l_context_id is null then
           raise invalid_context;
         END IF;
         --
         -- Now validated, insert using the Row Handler
         --
         ff_con_ins.ins
           (p_archive_item_id   => l_archive_item_id,
            p_sequence_no       => l_count,
            p_context           => g_context_values(l_count),
            p_context_id        => l_context_id);
       --
       END IF;
       --
       hr_utility.trace('Child Context Count:'||to_char(l_count));
       hr_utility.trace('Child Context Name:'||g_context_names(l_count));
       hr_utility.trace('Child Context Value:'||g_context_values(l_count));
     --
     EXIT WHEN g_context_names(l_count) IS NULL;
     --
     END LOOP;
  --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    -- Finished looping through rows. Handle with null.
    hr_utility.trace('No Data Found raised');
    null;
  END;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_archive_item_id        := l_archive_item_id;
  p_object_version_number  := l_object_version_number;
  p_some_warning           := FALSE;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when invalid_context then
   --
   rollback to create_archive_item;
    --
    -- NOCOPY change.
    --
    p_archive_item_id        := null;
    p_object_version_number  := null;
    p_some_warning           := null;
    --
    hr_utility.set_message(800, 'FF_34957_INVALID_CONTEXT_NAME');
    hr_utility.raise_error;
    --
  when invalid_archive_type then
    --
    rollback to create_archive_item;
    --
    -- NOCOPY change.
    --
    p_archive_item_id        := null;
    p_object_version_number  := null;
    p_some_warning           := null;
    --
    hr_utility.set_message(800, 'FF_34958_INVALID_ARCHIVE_TYPE');
    hr_utility.raise_error;
    --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_archive_item;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_archive_item_id        := null;
    p_object_version_number  := null;
    p_some_warning           := FALSE;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- NOCOPY change.
    --
    p_archive_item_id        := null;
    p_object_version_number  := null;
    p_some_warning           := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_archive_item;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_archive_item;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_archive_item >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_archive_item
  (p_archive_item_id               in     number
  ,p_effective_date                in     date
  ,p_validate                      in     boolean  default false
  ,p_archive_value                 in     varchar2
  ,p_object_version_number         in out nocopy number
  ,p_some_warning                     out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_archive_type varchar2(10);
  l_fi_archive_type varchar2(10);
  l_updatable_flag varchar2(1);
  l_report_type varchar2(30);
  l_report_qualifier varchar2(30);
  l_report_category  varchar2(30);
  l_mapping_updatable_flag varchar2(1);
  l_context1 number;
  l_user_entity_id number;
  l_object_version_number number;
  --
  cursor get_archive_rec (c_archive_item_id number) is
  select user_entity_id,
         archive_type,
         context1
  from ff_archive_items
  where archive_item_id = c_archive_item_id;
  --
  cursor get_report_details(c_payroll_action_id number) is
  select ppa.report_type,
         ppa.report_qualifier,
         ppa.report_category
  from pay_payroll_actions ppa
  where ppa.payroll_action_id = c_payroll_action_id;
  --
  cursor get_format_item (c_report_type varchar2,
                          c_report_qualifier varchar2,
                          c_report_category varchar2,
                          c_user_entity_id number,
                          c_effective_date date) is
  select prfi.updatable_flag,
         prfi.archive_type
  from pay_report_format_items_f prfi
  where prfi.report_type = c_report_type
  and   prfi.report_qualifier = c_report_qualifier
  and   prfi.report_category = c_report_category
  and   prfi.user_entity_id = c_user_entity_id
  and   c_effective_date between
        prfi.effective_start_date and prfi.effective_end_date;
  --
  cursor get_format_mapping (c_report_type varchar2, c_report_qualifier varchar2,
                             c_report_category varchar2, c_effective_date date) is
  select prfm.updatable_flag
  from pay_report_format_mappings_f prfm
  where prfm.report_type = c_report_type
  and   prfm.report_qualifier = c_report_qualifier
  and   prfm.report_category = c_report_category
  and   c_effective_date between
        prfm.effective_start_date and prfm.effective_end_date;
  --
  cursor get_action_details(c_context1 number) is
  select paa.assignment_action_id,
         paa.payroll_action_id
  from pay_assignment_actions paa
  where paa.assignment_action_id = c_context1;
  --
  cursor get_locked_asg_action(c_assignment_action_id number) is
  select locked_action_id
  from pay_action_interlocks
  where locked_action_id = c_assignment_action_id;
  --
  l_proc                varchar2(72) := g_package||'update_archive_item';
  l_assignment_action_id number;
  l_payroll_action_id    number;
  cannot_update_item    exception;
  invalid_action        exception;
  invalid_archive_type  exception;
  locked_action         exception;
--
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_object_version_number := p_object_version_number;
  --
  -- Convert rowid into the necessary table values:
  --
  open get_archive_rec(p_archive_item_id);
  fetch get_archive_rec into
        l_user_entity_id,
        l_archive_type,
        l_context1;
  if get_archive_rec%notfound then
     raise no_data_found;
  end if;
  close get_archive_rec;

  -- Issue a savepoint
  --
  savepoint update_archive_item;
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Row Handlers
  --
  -- 1. Check that the type passed in is updatable, ie the type
  --    must be 'AAP', ie at assignment action level. Then, ensure that
  --    this assignment action is valid
  --
  IF l_archive_type <> 'AAP' THEN
    --
    raise invalid_archive_type;
  ELSE
    --
    -- Check this assignment action
    --
    open get_action_details(l_context1);
    fetch get_action_details into l_assignment_action_id,
                                  l_payroll_action_id;
    if get_action_details%notfound then
      raise invalid_action;
    end if;
    close get_action_details;
    --
  END IF;
  --
  -- 2. Check the PAY_REPORT_FORMAT_ITEMS_F value of UPDATABLE_FLAG
  --    and ARCHIVE_TYPE given this USER_ENTITY_ID and other
  --    report information from the payroll action.
  --
  open get_report_details(l_payroll_action_id);
  fetch get_report_details into l_report_type,
                                l_report_qualifier,
                                l_report_category;
  close get_report_details;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Must use the payroll actions report details,
  -- and the user entity id from this archive item
  --
  open get_format_item(l_report_type,
                       l_report_qualifier,
                       l_report_category,
                       l_user_entity_id,
                       p_effective_date);
  fetch get_format_item into l_updatable_flag, l_fi_archive_type;
  close get_format_item;

  IF l_updatable_flag = 'N' OR l_updatable_flag IS NULL OR l_fi_archive_type <> 'AAP' THEN
     --
     -- Cannot Update, raise error if 'N' for update, OR no
     -- row exists in pay_report_format_items_f, as this defaults
     -- to non-updatable where there is no row.
     --
     raise cannot_update_item;
     --
  END IF;
  --
  -- 3. Check the PAY_REPORT_FORMAT_MAPPINGS_F's value of UPDATABLE_FLAG,
  --    given the information retrieved above. There will be a link value
  --    in PAY_REPORT_FORMAT_ITEMS_F to reach this point.
  --
  open get_format_mapping(l_report_type,l_report_qualifier,
                          l_report_category, p_effective_date);
  fetch get_format_mapping into l_mapping_updatable_flag;
  if get_format_mapping%notfound then
     raise cannot_update_item;
  end if;
  close get_format_mapping;
  --
  hr_utility.set_location(l_proc, 40);
  --
  IF l_mapping_updatable_flag = 'N' THEN
     --
     -- Cannot Update, raise error
     --
     raise cannot_update_item;
     --
  END IF;
  --
  -- 4. Check that the Assignment Action is not being locked by
  --    another process. This is done at assignment action level.
  --
  open get_locked_asg_action(l_context1);
  fetch get_locked_asg_action into l_assignment_action_id;
  if get_locked_asg_action%found then
     raise locked_action;
  end if;
  --
  -- Process Logic.
  --
  hr_utility.set_location(l_proc, 50);
  hr_utility.trace('Archive Item ID:'||to_char(p_archive_item_id));
  hr_utility.trace('Report Type:'||l_report_type);
  hr_utility.trace('Report Category:'||l_report_category);
  hr_utility.trace('Report Qualifier:'||l_report_qualifier);
  --
  -- Now update the archive item as all Business Process validation is
  -- complete.
  --
  ff_arc_upd.upd
    (p_archive_item_id       => p_archive_item_id,
     p_value                 => p_archive_value,
     p_object_version_number => l_object_version_number);
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
  p_object_version_number  := l_object_version_number;
  p_some_warning           := FALSE;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when cannot_update_item then
    --
    rollback to update_archive_item;
    --
    -- NOCOPY change.
    --
    p_some_warning := null;
    --
    hr_utility.set_message(800, 'FF_34961_ARCHIVE_SECURITY');
    hr_utility.raise_error;
    --
  when invalid_archive_type then
    --
    -- NOCOPY change.
    --
    p_some_warning := null;
    --
    rollback to update_archive_item;
    --
    hr_utility.set_message(800, 'FF_34958_INVALID_ARCHIVE_TYPE');
    hr_utility.raise_error;
    --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_archive_item;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_some_warning           := FALSE;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when no_data_found then
    --
    rollback to update_archive_item;
    --
    -- NOCOPY change.
    --
    p_some_warning := null;
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  when locked_action then
   --
   rollback to update_archive_item;
    --
    -- NOCOPY change.
    --
    p_some_warning := null;
    --
    hr_utility.set_message(800, 'FF_34962_ARCH_ACT_INTERLOCK');
    hr_utility.raise_error;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_archive_item;
    --
    -- NOCOPY change.
    --
    p_some_warning := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
--
end update_archive_item;
--
end ff_archive_api;

/
