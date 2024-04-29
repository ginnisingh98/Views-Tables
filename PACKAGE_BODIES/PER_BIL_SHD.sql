--------------------------------------------------------
--  DDL for Package Body PER_BIL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BIL_SHD" as
/* $Header: pebilrhi.pkb 115.10 2003/04/10 09:19:39 jheer noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bil_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
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
  If (p_constraint_name = 'hr_summary_PK') Then
    fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Elsif (p_constraint_name = 'PARENT_RECORD') Then
    fnd_message.set_name('PER', 'PER_74879_PARENT_RECORD');
    fnd_message.raise_error;
  Elsif p_constraint_name = 'CHILD_RECORD_ITU' then
    fnd_message.set_name('PER', 'PER_74880_CHILD_RECORD');
    fnd_message.set_token('TYPE', 'Item Type Usage');
    fnd_message.raise_error;
  Elsif p_constraint_name = 'CHILD_RECORD_VR' then
    fnd_message.set_name('PER', 'PER_74880_CHILD_RECORD');
    fnd_message.set_token('TYPE', 'Valid Restriction');
    fnd_message.raise_error;
  Elsif p_constraint_name = 'CHILD_RECORD_RTU' then
    fnd_message.set_name('PER', 'PER_74880_CHILD_RECORD');
    fnd_message.set_token('TYPE', 'Restriction Usage');
    fnd_message.raise_error;
  Elsif p_constraint_name = 'CHILD_RECORD_KTU' then
    fnd_message.set_name('PER', 'PER_74880_CHILD_RECORD');
    fnd_message.set_token('TYPE', 'Key Type Usage');
    fnd_message.raise_error;
  Elsif p_constraint_name = 'CHILD_RECORD_RV' then
    fnd_message.set_name('PER', 'PER_74880_CHILD_RECORD');
    fnd_message.set_token('TYPE', 'Restriction Value');
    fnd_message.raise_error;
  Elsif p_constraint_name = 'CHILD_RECORD_KV' then
    fnd_message.set_name('PER', 'PER_74880_CHILD_RECORD');
    fnd_message.set_token('TYPE', 'Key Value');
    fnd_message.raise_error;
  Elsif p_constraint_name = 'CHILD_RECORD_IV' then
    fnd_message.set_name('PER', 'PER_74880_CHILD_RECORD');
    fnd_message.set_token('TYPE', 'Item Value');
    fnd_message.raise_error;
  Elsif p_constraint_name = 'CHILD_RECORD_VKT' then
    fnd_message.set_name('PER', 'PER_74880_CHILD_RECORD');
    fnd_message.set_token('TYPE', 'Valid Key Type');
    fnd_message.raise_error;
  Elsif p_constraint_name = 'CHILD_RECORD_PR' then
    fnd_message.set_name('PER', 'PER_74880_CHILD_RECORD');
    fnd_message.set_token('TYPE', 'Process Run');
    fnd_message.raise_error;
  Elsif (p_constraint_name = 'UNIQUE_ROW') Then
    fnd_message.set_name('PER', 'PER_74881_UNIQUE_ROW');
    fnd_message.raise_error;
  Elsif (p_constraint_name = 'UNIQUE_SEQUENCE') Then
    fnd_message.set_name('PER', 'PER_74881_UNIQUE_ROW');
    fnd_message.raise_error;
  Elsif (p_constraint_name = 'RECORD_PROTECT') Then
    fnd_message.set_name('PER', 'PER_74882_RECORD_PROTECT');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PER', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
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
  p_id_value                           in number,
  p_object_version_number              in number
  )      Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	type,
	business_group_id,
	object_version_number,
	id_value,
	fk_value1,
	fk_value2,
	fk_value3,
	text_value1,
	text_value2,
	text_value3,
	text_value4,
	text_value5,
	text_value6,
        text_value7,
	num_value1,
	num_value2,
	num_value3,
	date_value1,
	date_value2,
	date_value3,
        created_by
    from	hr_summary
    where	id_value = p_id_value;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_object_version_number is null and 	p_id_value is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_object_version_number = g_old_rec.object_version_number and 	p_id_value = g_old_rec.id_value
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
  p_id_value                           in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	type,
	business_group_id,
	object_version_number,
	id_value,
	fk_value1,
	fk_value2,
	fk_value3,
	text_value1,
	text_value2,
	text_value3,
	text_value4,
	text_value5,
	text_value6,
        text_value7,
	num_value1,
	num_value2,
	num_value3,
	date_value1,
	date_value2,
	date_value3,
        created_by
    from	hr_summary
    where	id_value = p_id_value
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
    hr_utility.set_message_token('TABLE_NAME', 'hr_summary');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_type                          in varchar2,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_id_value                      in number,
	p_fk_value1                     in number,
	p_fk_value2                     in number,
	p_fk_value3                     in number,
	p_text_value1                   in varchar2,
	p_text_value2                   in varchar2,
	p_text_value3                   in varchar2,
	p_text_value4                   in varchar2,
	p_text_value5                   in varchar2,
	p_text_value6                   in varchar2,
	p_text_value7                   in varchar2,
	p_num_value1                    in number,
	p_num_value2                    in number,
	p_num_value3                    in number,
	p_date_value1                   in date,
	p_date_value2                   in date,
	p_date_value3                   in date
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
  l_rec.type                             := p_type;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.id_value                         := p_id_value;
  l_rec.fk_value1                        := p_fk_value1;
  l_rec.fk_value2                        := p_fk_value2;
  l_rec.fk_value3                        := p_fk_value3;
  l_rec.text_value1                      := p_text_value1;
  l_rec.text_value2                      := p_text_value2;
  l_rec.text_value3                      := p_text_value3;
  l_rec.text_value4                      := p_text_value4;
  l_rec.text_value5                      := p_text_value5;
  l_rec.text_value6                      := p_text_value6;
  l_rec.text_value7                      := p_text_value7;
  l_rec.num_value1                       := p_num_value1;
  l_rec.num_value2                       := p_num_value2;
  l_rec.num_value3                       := p_num_value3;
  l_rec.date_value1                      := p_date_value1;
  l_rec.date_value2                      := p_date_value2;
  l_rec.date_value3                      := p_date_value3;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< row_exist >----------------------------|
-- ----------------------------------------------------------------------------
Function row_exist (p_rec in per_bil_shd.g_rec_type) return boolean is

cursor csr_exists is
  select 'x'
  from   hr_summary
  where  (type = p_rec.type
          and p_rec.type in ('TEMPLATE','ITEM_TYPE','KEY_TYPE','RESTRICTION_TYPE')
          and text_value1 = p_rec.text_value1
          and business_group_id = p_rec.business_group_id
         )
  or     (type = p_rec.type
          and p_rec.type IN ('RESTRICTION_USAGE','VALID_KEY_TYPE','KEY_TYPE_USAGE','VALID_RESTRICTION')
          and fk_value1 = p_rec.fk_value1
          and fk_value2 = p_rec.fk_value2
          and business_group_id = p_rec.business_group_id
         )
  or     (type = p_rec.type
          and p_rec.type = 'ITEM_TYPE_USAGE'
          and fk_value1 = p_rec.fk_value1
          and text_value1 = p_rec.text_value1
          and business_group_id = p_rec.business_group_id
         )
  or     (type = p_rec.type
          and p_rec.type = 'PROCESS_RUN'
          and text_value2 = p_rec.text_value2
          and text_value1 = p_rec.text_value1
          and business_group_id = p_rec.business_group_id
         )
  or     (type = p_rec.type
          and p_rec.type = 'RESTRICTION_VALUE'
          and fk_value1 = p_rec.fk_value1
          and text_value1 = p_rec.text_value1
          and business_group_id = p_rec.business_group_id
         );
--
l_dummy varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering: row_exist', 5);
  --
  open csr_exists;
  fetch csr_exists into l_dummy;
  --
  if csr_exists%found then
     close csr_exists;
     --
     hr_utility.set_location('Leaving: row_exist', 10);
     --
     return true;
  else
     close csr_exists;
     --
     hr_utility.set_location('Leaving: row_exist', 11);
     --
     return false;
  end if;
  --
End row_exist;
--
--
-- ----------------------------------------------------------------------------
-- |------< lookup_exists >------|
-- ----------------------------------------------------------------------------
--
Procedure lookup_exists (p_type in varchar2,
                         p_code in varchar2) is
--
cursor csr_lookup is
  select 'x'
  from   hr_lookups
  where  lookup_type = p_type
  and    lookup_code = p_code
  and    application_id = 800;
--
l_dummy varchar2(1);
--
Begin
--
hr_utility.set_location('Entering: lookup_exist', 5);
--
open csr_lookup;
fetch csr_lookup into l_dummy;
--
if csr_lookup%found then
   null;
else
   fnd_message.set_name('PER','PER_74884_LOOKUP_EXIST');
   fnd_message.set_token('NAME',p_code);
   fnd_message.raise_error;
end if;
--
hr_utility.set_location('Leaving: lookup_exist', 10);
--
End lookup_exists;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< sequence_exist >---------------------------|
-- ----------------------------------------------------------------------------
Function sequence_exist (p_rec in per_bil_shd.g_rec_type) return boolean is
--
cursor csr_exists is
  select 'x'
  from   hr_summary_item_type_usage
  where  sequence_number = p_rec.num_value1
  and    business_group_id = p_rec.business_group_id
  and    template_id = p_rec.fk_value1;
--
l_dummy varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering: sequence_exist', 5);
  --
  open csr_exists;
  fetch csr_exists into l_dummy;
  --
  if csr_exists%found then
     close csr_exists;
     --
     hr_utility.set_location('Leaving: row_exist', 10);
     --
     return true;
  else
     close csr_exists;
     --
     hr_utility.set_location('Leaving: row_exist', 11);
     --
     return false;
  end if;
  --
End sequence_exist;
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_restriction_sql >---------------------|
-- ----------------------------------------------------------------------------
procedure check_restriction_sql (p_stmt in out nocopy varchar2
                                ,p_business_group_id in number) is
--
TYPE TestCurTyp IS REF CURSOR;
test_csr TestCurTyp;
l_value  varchar2(32000) := null;
l_meaning  varchar2(240) :=null;
l_pos_bg number := 1;
l_stmt   varchar2(32000);
l_from   number := 1;
l_error  boolean;
--
begin
--
if ( instr(p_stmt,' VALUE ') > 0
   or  instr(p_stmt,' VALUE'||fnd_global.local_chr(10)) > 0 )
   /* Added additional checks that MEANING column exists - bug 2348887 */
   AND (  instr(p_stmt,' MEANING ') > 0
      or  instr(p_stmt,' MEANING'||fnd_global.local_chr(10)) > 0 ) then
   l_error := false;
else
   l_error := true;
end if;
--
begin
   if instr(lower(p_stmt),':ctl_globals.business_group_id',l_from,1) > 0 then
      --
      -- Loop thro' to change all occurrences of :ctl_globals.business_group_id
      -- into lower case
      --
      loop
         l_pos_bg := instr(lower(p_stmt),':ctl_globals.business_group_id',l_from,1);
         exit when l_pos_bg is null or l_pos_bg > length(p_stmt);
         if l_pos_bg = 0 then
            if length(p_stmt) >= l_pos_bg then
               l_stmt := l_stmt||substr(p_stmt,l_from,length(p_stmt)+1-l_from);
               l_pos_bg := null;
            else
               exit;
            end if;
         end if;
         l_stmt := l_stmt||substr(p_stmt,l_from,(l_pos_bg-l_from))||lower(substr(p_stmt,l_pos_bg,30));
         l_from := l_pos_bg+30;
      end loop;
      --
      -- Replace variable with business group id
      l_stmt := replace(l_stmt,':ctl_globals.business_group_id',p_business_group_id);
      --
   else
      l_stmt := p_stmt;
   end if;
   --
   open test_csr for l_stmt;
   fetch test_csr into l_value, l_meaning;
   close test_csr;
   --
exception when others then
   l_error := true;
end;
--
p_stmt := l_stmt;
--
if l_error then
   fnd_message.set_name('PER','PER_74887_INVALID_SQL');
   fnd_message.raise_error;
end if;
--
end check_restriction_sql;
-- ----------------------------------------------------------------------------
-- |-----------------------------< valid_value >---------------------------|
-- ----------------------------------------------------------------------------
Procedure valid_value (p_rec in per_bil_shd.g_rec_type) is
--
cursor csr_lov_exists (p_ru_id number,
                       p_bus_grp_id number) is
  select rt.restriction_sql,
         rt.title
  from   hr_summary_restriction_type  rt,
         hr_summary_restriction_usage ru,
         hr_summary_valid_restriction vr
  where  vr.restriction_type_id  = rt.restriction_type_id
  and    ru.valid_restriction_id = vr.valid_restriction_id
  and    ru.restriction_usage_id = p_ru_id
  and    ru.business_group_id = p_bus_grp_id;
  --
  l_restriction_sql varchar2(240) := null;
  l_sql             varchar2(1000);
  l_rt_title        varchar2(100);
  l_value           varchar2(100);
  l_meaning         varchar2(240);
  l_found           boolean := false;
  source_cursor integer;
  ignore integer;
  TYPE TestCurTyp IS REF CURSOR;
  test_csr  TestCurTyp;
  --
Begin
  --
  hr_utility.set_location('Entering: valid_value', 5);
  --
  open csr_lov_exists(p_rec.fk_value1,p_rec.business_group_id);
  fetch csr_lov_exists into l_restriction_sql,l_rt_title;
  if csr_lov_exists%found and l_restriction_sql is not null then
     close csr_lov_exists;
     --
     begin
     --
     per_bil_shd.check_restriction_sql (p_stmt              => l_restriction_sql
                                       ,p_business_group_id => p_rec.business_group_id);
     --
     open test_csr for l_restriction_sql;
     loop
          fetch test_csr into l_value, l_meaning;
          if test_csr%notfound then
             l_found := false;
             exit;
          end if;
          if l_value = p_rec.text_value1 then
             l_found := true;
             exit;
          end if;
     end loop;
     close test_csr;
     --
     if not l_found then
        fnd_message.set_name('PER','PER_74888_RESTRICTION_SQL');
        fnd_message.set_token('RESTRICTION_TYPE',l_rt_title);
        fnd_message.raise_error;
     end if;
/*
     source_cursor := dbms_sql.open_cursor;
     --
     begin
         l_restriction_sql := replace(l_restriction_sql,':ctl_globals.business_group_id',p_rec.business_group_id);
         hr_utility.set_location('Valid_Value: Parsing SQL', 10);
         dbms_sql.parse(source_cursor,l_restriction_sql,dbms_sql.v7);
         hr_utility.set_location('Valid_Value: Defining_column', 15);
         dbms_sql.define_column(source_cursor,1,l_value,100);
         ignore := dbms_sql.execute(source_cursor);
       loop
         if dbms_sql.fetch_rows(source_cursor) > 0 then
            hr_utility.set_location('Valid_Value: column_value', 20);
            dbms_sql.column_value(source_cursor,1,l_value);
            if l_value = p_rec.text_value1 then
               l_found := true;
               exit;
            end if;
         else
            l_found := false;
            exit;
         end if;
       end loop;
       --
       dbms_sql.close_cursor(source_cursor);
       --
       if not l_found then
          fnd_message.set_name('PER','PER_74888_RESTRICTION_SQL');
          fnd_message.set_token('RESTRICTION_TYPE',l_rt_title);
          fnd_message.raise_error;
       end if;
       --*/
     end;
  else
    close csr_lov_exists;
  end if;
  --
  hr_utility.set_location('Leaving: valid_value', 25);
  --
End valid_value;
--
-- ----------------------------------------------------------------------------
-- |                     < get_restriction_meaning >                          |
-- | Added for bug 2348887 to enable meanings to be shown in GSP form         |
-- ----------------------------------------------------------------------------
function get_restriction_meaning(p_valid_restriction_id in number
                                ,p_value in varchar2)return varchar2 is
--
cursor csr_get_sql is
  select rt.restriction_sql
       , rt.business_group_id
  from   hr_summary_restriction_type rt,
         hr_summary_valid_restriction vr
  where  rt.restriction_type_id = vr.restriction_type_id
  and    rt.business_group_id = vr.business_group_id
  and    vr.valid_restriction_id = p_valid_restriction_id;
--
l_stmt      varchar2(32000);
l_business_group_id number;
--
TYPE TestCurTyp IS REF CURSOR;
test_csr TestCurTyp;
l_meaning varchar2(32000) := null;
--
BEGIN
    hr_utility.set_location('Entered get_restriction_meaning',5);
   open csr_get_sql;
   fetch csr_get_sql into l_stmt, l_business_group_id;
   close csr_get_sql;
   --
   /* Call Check_restriction_sql to ensure that any occurrence of
   :ctl_globals.business_group_id are replaced with the business group id value */
   per_bil_shd.check_restriction_sql (p_stmt              => l_stmt
                                       ,p_business_group_id => l_business_group_id);
   --
   l_stmt := 'Select rs.meaning from (' || l_stmt || ') rs where rs.value = '''||p_value ||''' ';
   hr_utility.set_location('About to open cursor',17);
   open test_csr for l_stmt;
   hr_utility.set_location('Opened cursor',20);
   fetch test_csr into l_meaning;
   hr_utility.set_location('fetched meaning:'||l_meaning,25);
   close test_csr;
   --
   return l_meaning;
   --
   exception when others then
      /* If the cursor cannot find the meaning, then display the value */
      l_meaning := p_value;
      hr_utility.set_location('meaning defaulted',50);
END  get_restriction_meaning;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< parent_found >----------------------------|
-- ----------------------------------------------------------------------------
Function parent_found (p_rec in per_bil_shd.g_rec_type) return boolean is
--
cursor csr_exists (p_value number) is
  select 'x'
  from   hr_summary
  where  id_value = p_value
  and business_group_id = p_rec.business_group_id;
--
l_dummy varchar2(1);
l_found boolean := FALSE;
--
Begin
  --
  hr_utility.set_location('Entering: parent_found', 5);
  --
  if p_rec.fk_value1 is not null then
     open csr_exists(p_rec.fk_value1);
     fetch csr_exists into l_dummy;
     --
     if csr_exists%found then
        l_found := TRUE;
     else
        l_found := FALSE;
     end if;
     close csr_exists;
  end if;
  if p_rec.fk_value2 is not null and l_found then
     open csr_exists(p_rec.fk_value2);
     fetch csr_exists into l_dummy;
     --
     if csr_exists%found then
        l_found := TRUE;
     else
        l_found := FALSE;
     end if;
     close csr_exists;
  end if;
  if p_rec.fk_value3 is not null and l_found then
     open csr_exists(p_rec.fk_value3);
     fetch csr_exists into l_dummy;
     --
     if csr_exists%found then
        l_found := TRUE;
     else
        l_found := FALSE;
     end if;
     close csr_exists;
  end if;
  --
  hr_utility.set_location('Leaving: parent_found', 10);
  --
  return l_found;
  --
End parent_found;
--
Function chk_date_valid (p_rec in per_bil_shd.g_rec_type) return boolean is
  --
  cursor csr_get_datatype IS
    select rt.data_type
    from   hr_summary_restriction_type rt,
           hr_summary_valid_restriction vr,
           hr_summary_restriction_usage rtu
    where  rt.restriction_type_id = vr.restriction_type_id
    and    rt.business_group_id = vr.business_group_id
    and    vr.valid_restriction_id = rtu.valid_restriction_id
    and    rtu.restriction_usage_id = p_rec.fk_value1;
  --
  l_datatype varchar2(10);
  l_date date;
  --
Begin
  --
  hr_utility.set_location('Entering: chk_valid_date', 5);
  --
  open csr_get_datatype;
  fetch csr_get_datatype into l_datatype;
  close csr_get_datatype;
  if l_datatype = 'D' then
     select to_date(p_rec.text_value1,'YYYY/MM/DD HH24:MI:SS')
     into   l_date
     from   dual;
  end if;
  --
  hr_utility.set_location('Leaving: chk_valid_date', 10);
  --
  return(true);
Exception
   When Others Then
        hr_utility.set_location('Leaving: chk_valid_date', 11);
        return(false);
End chk_date_valid;
--
end per_bil_shd;

/
