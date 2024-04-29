--------------------------------------------------------
--  DDL for Package Body PER_SHT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SHT_SHD" as
/* $Header: peshtrhi.pkb 120.0 2005/05/31 21:06:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_sht_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PER_SHARED_TYPES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_SHARED_TYPE_UK1') Then
    hr_utility.set_message(801, 'PER_9999_DUP_USR_TYP_CODE_COMB');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_shared_type_id                     in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		shared_type_id,
	business_group_id,
	shared_type_name,
	shared_type_code,
	system_type_cd,
	information1,
	information2,
	information3,
	information4,
	information5,
	information6,
	information7,
	information8,
	information9,
	information10,
	information11,
	information12,
	information13,
	information14,
	information15,
	information16,
	information17,
	information18,
	information19,
	information20,
	information21,
	information22,
	information23,
	information24,
	information25,
	information26,
	information27,
	information28,
	information29,
	information30,
	information_category,
	object_version_number,
	lookup_type
    from	per_shared_types
    where	shared_type_id = p_shared_type_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_shared_type_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_shared_type_id = g_old_rec.shared_type_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
      --
      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_shared_type_id                     in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	shared_type_id,
	business_group_id,
	shared_type_name,
	shared_type_code,
	system_type_cd,
	information1,
	information2,
	information3,
	information4,
	information5,
	information6,
	information7,
	information8,
	information9,
	information10,
	information11,
	information12,
	information13,
	information14,
	information15,
	information16,
	information17,
	information18,
	information19,
	information20,
	information21,
	information22,
	information23,
	information24,
	information25,
	information26,
	information27,
	information28,
	information29,
	information30,
	information_category,
	object_version_number,
	lookup_type
    from	per_shared_types
    where	shared_type_id = p_shared_type_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'per_shared_types');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_shared_type_id                in number,
	p_business_group_id             in number,
	p_shared_type_name              in varchar2,
	p_shared_type_code              in varchar2,
	p_system_type_cd                in varchar2,
	p_information1                  in varchar2,
	p_information2                  in varchar2,
	p_information3                  in varchar2,
	p_information4                  in varchar2,
	p_information5                  in varchar2,
	p_information6                  in varchar2,
	p_information7                  in varchar2,
	p_information8                  in varchar2,
	p_information9                  in varchar2,
	p_information10                 in varchar2,
	p_information11                 in varchar2,
	p_information12                 in varchar2,
	p_information13                 in varchar2,
	p_information14                 in varchar2,
	p_information15                 in varchar2,
	p_information16                 in varchar2,
	p_information17                 in varchar2,
	p_information18                 in varchar2,
	p_information19                 in varchar2,
	p_information20                 in varchar2,
	p_information21                 in varchar2,
	p_information22                 in varchar2,
	p_information23                 in varchar2,
	p_information24                 in varchar2,
	p_information25                 in varchar2,
	p_information26                 in varchar2,
	p_information27                 in varchar2,
	p_information28                 in varchar2,
	p_information29                 in varchar2,
	p_information30                 in varchar2,
	p_information_category          in varchar2,
	p_object_version_number         in number,
	p_lookup_type                   in varchar2
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.shared_type_id                   := p_shared_type_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.shared_type_name                 := p_shared_type_name;
  l_rec.shared_type_code                 := p_shared_type_code;
  l_rec.system_type_cd                   := p_system_type_cd;
  l_rec.information1                     := p_information1;
  l_rec.information2                     := p_information2;
  l_rec.information3                     := p_information3;
  l_rec.information4                     := p_information4;
  l_rec.information5                     := p_information5;
  l_rec.information6                     := p_information6;
  l_rec.information7                     := p_information7;
  l_rec.information8                     := p_information8;
  l_rec.information9                     := p_information9;
  l_rec.information10                    := p_information10;
  l_rec.information11                    := p_information11;
  l_rec.information12                    := p_information12;
  l_rec.information13                    := p_information13;
  l_rec.information14                    := p_information14;
  l_rec.information15                    := p_information15;
  l_rec.information16                    := p_information16;
  l_rec.information17                    := p_information17;
  l_rec.information18                    := p_information18;
  l_rec.information19                    := p_information19;
  l_rec.information20                    := p_information20;
  l_rec.information21                    := p_information21;
  l_rec.information22                    := p_information22;
  l_rec.information23                    := p_information23;
  l_rec.information24                    := p_information24;
  l_rec.information25                    := p_information25;
  l_rec.information26                    := p_information26;
  l_rec.information27                    := p_information27;
  l_rec.information28                    := p_information28;
  l_rec.information29                    := p_information29;
  l_rec.information30                    := p_information30;
  l_rec.information_category             := p_information_category;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.lookup_type                      := p_lookup_type;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
procedure load_row
(
  p_shared_type_name               in  varchar2  default null
  ,p_shared_type_code               in  varchar2  default null
  ,p_system_type_cd                 in  varchar2  default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_lookup_type                    in  varchar2  default null
  ,p_owner                          in  varchar2  default 'CUSTOM'
 ) is
   cursor c1 is select userenv('LANG') from dual;

   cursor c2 is select shared_type_id,last_updated_by from per_shared_types
   where shared_type_code = p_shared_type_code
   and lookup_type = p_lookup_type
   and system_type_cd = p_system_type_cd
   and business_group_id is null;

   cursor csr_shared_name_match is select shared_type_id,last_updated_by from per_shared_types
   where shared_type_name = p_shared_type_name
   and lookup_type = p_lookup_type
   and system_type_cd = p_system_type_cd
   and business_group_id is null;

   l_shared_type_id number;
   l_last_update_login number;
   l_last_update_date date;
   l_last_updated_by number;
   l_record_owner number;
   l_rec_owner number;
   l_created_by number;
   l_creation_date date;
   l_object_version_number number := 1;
   l_effective_date date := sysdate;
   l_language varchar2(30);

begin
   if p_owner = 'SEED' then
      l_created_by := 1;
      l_last_updated_by := -1;
   else
      l_created_by := 0;
      l_last_updated_by := 0;
   end if;
   l_last_update_login := 0;
   l_creation_date := sysdate;
   l_last_update_date := sysdate;

   -- whether the key records exist or not
   for i in c2 loop
       l_shared_type_id := i.shared_type_id ;
       l_record_owner := i.last_updated_by;
   end loop;

   if l_shared_type_id is not null then
      -- Key record do exists , both the users , this is for clearing some old data
      if l_record_owner in (-1,1) then
         -- update the entry
         update per_shared_types
         set shared_type_name  = p_shared_type_name
          , information1      = p_information1
          , information2      = p_information2
          , information3      = p_information3
          , information4      = p_information4
          , information5      = p_information5
          , information6      = p_information6
          , information7      = p_information7
          , information8      = p_information8
          , information9      = p_information9
          , information10      = p_information10
          , information11      = p_information11
          , information12      = p_information12
          , information13      = p_information13
          , information14      = p_information14
          , information15      = p_information15
          , information16      = p_information16
          , information17      = p_information17
          , information18      = p_information18
          , information19      = p_information19
          , information20      = p_information20
          , information21      = p_information21
          , information22      = p_information22
          , information23      = p_information23
          , information24      = p_information24
          , information25      = p_information25
          , information26      = p_information26
          , information27      = p_information27
          , information28      = p_information28
          , information29      = p_information29
          , information30      = p_information30
          , information_category = p_information_category
          , last_update_date     = l_last_update_date
          , last_updated_by       = l_last_updated_by
          , last_update_login    = l_last_update_login
          where shared_type_id = l_shared_type_id;

          update per_shared_types_tl
          set shared_type_name   = p_shared_type_name
          , last_update_date     = l_last_update_date
          , last_updated_by      = l_last_updated_by
          , last_update_login    = l_last_update_login
          , source_lang          = userenv('LANG')
          where shared_type_id = l_shared_type_id
          and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
          if sql%notfound then
	     insert into per_shared_types_tl
	     (shared_type_id,
	     shared_type_name,
	     language,
	     source_lang,
	     creation_date,
	     created_by,
	     last_updated_by,
	     last_update_date,
	     last_update_login)
	     select l_shared_type_id,
	     p_shared_type_name,
	     l.language_code,
	     userenv('LANG'),
	     l_creation_date,
	     l_created_by,
	     l_last_updated_by,
	     l_last_update_date,
	     l_last_update_login from fnd_languages l
	     where l.installed_flag in ('I','B')
	     and not exists (select null from per_shared_types_tl t
		     where t.shared_type_id = l_shared_type_id
                             and t.language = l.language_code);
          end if;
      else
         -- record has been updated by custom
         null;
      end if;
   else
      -- key record does not exist.
      -- check whether lookup_type and system_type_cd combination exists for
      -- the shared_type_name
      open csr_shared_name_match;
      fetch csr_shared_name_match into l_shared_type_id,l_rec_owner;
      if csr_shared_name_match%found then
         -- shared_type_name exists for combination
        if l_rec_owner in (-1,1) then
         -- the owner is seed , update the shared_type_code and other info.
         update per_shared_types
         set shared_type_code  = p_shared_type_code
          , information1      = p_information1
          , information2      = p_information2
          , information3      = p_information3
          , information4      = p_information4
          , information5      = p_information5
          , information6      = p_information6
          , information7      = p_information7
          , information8      = p_information8
          , information9      = p_information9
          , information10      = p_information10
          , information11      = p_information11
          , information12      = p_information12
          , information13      = p_information13
          , information14      = p_information14
          , information15      = p_information15
          , information16      = p_information16
          , information17      = p_information17
          , information18      = p_information18
          , information19      = p_information19
          , information20      = p_information20
          , information21      = p_information21
          , information22      = p_information22
          , information23      = p_information23
          , information24      = p_information24
          , information25      = p_information25
          , information26      = p_information26
          , information27      = p_information27
          , information28      = p_information28
          , information29      = p_information29
          , information30      = p_information30
          , information_category = p_information_category
          , last_update_date     = l_last_update_date
          , last_updated_by       = l_last_updated_by
          , last_update_login    = l_last_update_login
          where shared_type_id = l_shared_type_id;

          update per_shared_types_tl
          set shared_type_name   = p_shared_type_name
          , last_update_date     = l_last_update_date
          , last_updated_by      = l_last_updated_by
          , last_update_login    = l_last_update_login
          , source_lang          = userenv('LANG')
          where shared_type_id = l_shared_type_id
          and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
          if sql%notfound then
      	  insert into per_shared_types_tl
      	  (shared_type_id,
      	  shared_type_name,
      	  language,
      	  source_lang,
      	  creation_date,
      	  created_by,
      	  last_updated_by,
      	  last_update_date,
      	  last_update_login)
      	  select l_shared_type_id,
      	  p_shared_type_name,
      	  l.language_code,
      	  userenv('LANG'),
      	  l_creation_date,
      	  l_created_by,
      	  l_last_updated_by,
      	  l_last_update_date,
      	  l_last_update_login from fnd_languages l
      	  where l.installed_flag in ('I','B')
      	  and not exists (select null from per_shared_types_tl t
      			  where t.shared_type_id = l_shared_type_id
      			  and t.language = l.language_code);
         else
            -- record has been updated by custom, update the share_type_code only.
            update per_shared_types
            set shared_type_code  = p_shared_type_code
            where shared_type_id = l_shared_type_id;
         end if;
        end if;
      else
         -- neither key record, nor lookup_type and system_type_cd combination exists
         -- creating a new record for share_type

	 select per_shared_types_s.nextval into l_shared_type_id from dual;
	 insert into per_shared_types (shared_type_id,
	 shared_type_name,
	 shared_type_code,
	 lookup_type,
	 system_type_cd,
	 information1,
	 information2,
	 information3,
	 information4,
	 information5,
	 information6,
	 information7,
	 information8,
	 information9,
	 information10,
	 information11,
	 information12,
	 information13,
	 information14,
	 information15,
	 information16,
	 information17,
	 information18,
	 information19,
	 information20,
	 information21,
	 information22,
	 information23,
	 information24,
	 information25,
	 information26,
	 information27,
	 information28,
	 information29,
	 information30,
	 information_category,
	 last_updated_by,
	 created_by,
	 last_update_login,
	 creation_date,
	 last_update_date,
         object_version_number
)
	 values
	 (l_shared_type_id,
	 p_shared_type_name,
	 p_shared_type_code,
	 p_lookup_type,
	 p_system_type_cd,
	 p_information1,
	 p_information2,
	 p_information3,
	 p_information4,
	 p_information5,
	 p_information6,
	 p_information7,
	 p_information8,
	 p_information9,
	 p_information10,
	 p_information11,
	 p_information12,
	 p_information13,
	 p_information14,
	 p_information15,
	 p_information16,
	 p_information17,
	 p_information18,
	 p_information19,
	 p_information20,
	 p_information21,
	 p_information22,
	 p_information23,
	 p_information24,
	 p_information25,
	 p_information26,
	 p_information27,
	 p_information28,
	 p_information29,
	 p_information30,
	 p_information_category,
	 l_last_updated_by,
	 l_created_by,
	 l_last_update_login,
	 l_creation_date,
	 l_last_update_date,
         l_object_version_number);
	  insert into per_shared_types_tl
	  (shared_type_id,
	  shared_type_name,
	  language,
	  source_lang,
	  creation_date,
	  created_by,
	  last_updated_by,
	  last_update_date,
	  last_update_login)
	  select l_shared_type_id,
	  p_shared_type_name,
	  l.language_code,
	  userenv('LANG'),
	  l_creation_date,
	  l_created_by,
	  l_last_updated_by,
	  l_last_update_date,
	  l_last_update_login from fnd_languages l
	  where l.installed_flag in ('I','B')
	  and not exists (select null from per_shared_types_tl t
			  where t.shared_type_id = l_shared_type_id
			  and t.language = l.language_code);
        end if;
     end if;
end load_row;
--
end per_sht_shd;

/
