--------------------------------------------------------
--  DDL for Package Body PER_JP_EXTRA_PERSON_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_EXTRA_PERSON_RULES" as
/* $Header: pejpexpr.pkb 120.1 2006/08/21 10:38:09 shisriva noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_jp_extra_person_rules.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_kana_format >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_kana_format
  (p_last_name                     in     varchar2
  ,p_first_name                    in     varchar2
  ,p_previous_last_name            in     varchar2
  ,p_person_type_id                in     number -- Added for Bug#3613987
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'chk_kana_format';
  l_system_person_type  per_person_types.system_person_type%type;
  --
  procedure local_chk_kana_format(p_input              in varchar2
                                 ,p_system_person_type in varchar2) is
    l_input             varchar2(255);
    l_output            varchar2(255);
    l_rgeflg            varchar2(1);
  begin
    if p_input is not null then
      --
      -- Bug#3613987
      -- Added check for system_person_type and last_name
      --
      if not(p_input = fnd_message.get_string('PER','IRC_412108_UNKNOWN_NAME')
             and
             p_system_person_type = 'OTHER') then
        l_input := p_input;
        hr_chkfmt.checkformat(value   => l_input
                             ,format  => 'KANA'
                             ,output  => l_output
                             ,minimum => NULL
                             ,maximum => NULL
                             ,nullok  => 'N'
                             ,rgeflg  => l_rgeflg
                             ,curcode => NULL);
      end if;
      --
    end if;
  end local_chk_kana_format;
begin
 /* Bug Fix : 5452289 */
 IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'JP') THEN
       RETURN;
END IF;
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Bug#3613987
  -- Added check for system_person_type
  --
  select system_person_type
  into l_system_person_type
  from per_person_types
  where person_type_id = p_person_type_id;
  --
  -- Validation in addition to Row Handlers
  --
  local_chk_kana_format(p_last_name, l_system_person_type);
  local_chk_kana_format(p_first_name, l_system_person_type);
  local_chk_kana_format(p_previous_last_name, l_system_person_type);
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end chk_kana_format;
--
end per_jp_extra_person_rules;

/
