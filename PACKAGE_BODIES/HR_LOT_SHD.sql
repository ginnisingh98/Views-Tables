--------------------------------------------------------
--  DDL for Package Body HR_LOT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOT_SHD" as
/* $Header: hrlotrhi.pkb 115.10 2002/12/04 05:45:04 hjonnala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package              varchar2(33)	:= '  hr_lot_shd.';  -- Global package name
g_loc_bg_id            number(15);                           -- Efficiency global
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%type) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_message(800, 'HR_7877_API_INVALID_CONSTRAINT');
  hr_utility.set_message_token('PROCEDURE', l_proc);
  hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
  hr_utility.raise_error;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
--
Function api_updating
  (
   p_location_id                        in number,
   p_language                           in varchar2
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     	location_id,
	language,
	source_lang,
	location_code,
	description
       from hr_locations_all_tl
       where location_id = p_location_id
         and language = p_language;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
 	p_location_id is null or
	p_language is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_location_id = g_old_rec.location_id and
	p_language    = g_old_rec.language
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
        hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      --
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
  p_location_id                        in number,
  p_language                           in varchar2
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select location_id,
           language,
           source_lang,
           location_code,
           description
       from hr_locations_all_tl
       where location_id = p_location_id
       and   language = p_language
       for update nowait;
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
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'location_id',
     p_argument_value => p_location_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'language',
     p_argument_value => p_language);
  --
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  --
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
    hr_utility.set_message(800, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'hr_locations_all_tl');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< add_language >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure add_language Is
   --
   l_proc         varchar2(72) := g_package||'add_language';
begin
   delete from hr_locations_all_tl t
     where not exists
     (  select null
           from hr_locations_all b
           where b.location_id = t.location_id
     );

   update hr_locations_all_tl t
      set ( location_code,
            description ) =
             ( select b.location_code,
                      b.description
                  from hr_locations_all_tl b
                  where b.location_id = t.location_id
                  and   b.language = t.source_lang       )
     where ( t.location_id,
             t.language
	   ) in
        ( select subt.location_id,
                 subt.language
             from hr_locations_all_tl subb, hr_locations_all_tl subt
             where subb.location_id = subt.location_id
             and subb.language = subt.source_lang
             and ( subb.location_code <> subt.location_code
             or    subb.description <> subt.description
             or    (subb.description is null and subt.description is not null)
             or    (subb.description is not null and subt.description is null)
		  )
	);

   insert into hr_locations_all_tl
   (
      location_id,
      location_code,
      description,
      last_update_date,
      last_updated_by,
      last_update_login,
      created_by,
      creation_date,
      language,
      source_lang
   )
   select b.location_id,
          b.location_code,
          b.description,
          b.last_update_date,
          b.last_updated_by,
          b.last_update_login,
          b.created_by,
          b.creation_date,
          l.language_code,
          b.source_lang
      from hr_locations_all_tl b, fnd_languages l
      where l.installed_flag in ('I', 'B')
      and   b.language = userenv('LANG')
      and not exists
         (select null
             from hr_locations_all_tl t
             where t.location_id = b.location_id
             and   t.language = l.language_code);
-- Begin Bug: 2148847, Removed set_location to fix VALUE ERROR, this unknown
-- error is coming while running PERNLINS.sql script.

--   hr_utility.set_location(' Leaving:'||l_proc, 10);

-- End of Bug: 2148847.
End add_language;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_location_id                   in number,
	p_language                      in varchar2,
	p_source_lang                   in varchar2,
	p_location_code                 in varchar2,
	p_description                   in varchar2
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
  l_rec.location_id                      := p_location_id;
  l_rec.language                         := p_language;
  l_rec.source_lang                      := p_source_lang;
  l_rec.location_code                    := p_location_code;
  l_rec.description                      := p_description;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------< return_value_business_group_id >--------------------|
-- ----------------------------------------------------------------------------
Function return_value_business_group_id (p_location_id number) Return number
Is
   --
   -- Cursor to obtain underlying business group id.
   --
   cursor csr_bg_id is
      select business_group_id
         from hr_locations_all
         where location_id = p_location_id;
   --
   l_proc         varchar2(72) := g_package||'return_value_business_group_id';
   --
begin
   --
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   if (p_location_id <> nvl(g_old_rec.location_id, hr_api.g_number) ) then
      --
      -- Only fetch business_group_id from database if required - i.e.
      -- the location_id has changed since last insert or update.  Otherwise
      -- use stored value in g_loc_bg_id.  This value is set when
      -- an insert takes place, or in this procedure if a database
      -- fetch takes palce.
      --
      open csr_bg_id;
      fetch csr_bg_id into g_loc_bg_id;
      --
      if csr_bg_id%notfound then
	 close csr_bg_id;
	 --
	 -- The primary key is invalid therefore we must error
	 --
	 hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
	 hr_utility.raise_error;
      end if;
      --
      close csr_bg_id;
   end if;
   --
   hr_utility.set_location('Leaving:'||l_proc, 10);
   --
   return g_loc_bg_id;
--
end return_value_business_group_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< set_value_business_group_id >--------------------|
-- ----------------------------------------------------------------------------
Procedure set_value_business_group_id (p_business_group_id number)
Is
   --
   l_proc         varchar2(72) := g_package||'set_value_business_group_id';
begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   g_loc_bg_id := p_business_group_id;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end set_value_business_group_id;
--
end hr_lot_shd;

/
