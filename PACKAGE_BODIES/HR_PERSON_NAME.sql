--------------------------------------------------------
--  DDL for Package Body HR_PERSON_NAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_NAME" as
/* $Header: pepernam.pkb 120.5 2007/05/21 12:27:27 ktithy noship $ */
--
  g_package CONSTANT varchar2(30) := 'hr_person_name.';
--
  g_format_name_cached           hr_name_formats.format_name%TYPE := null;
  g_format_mask_cached           hr_name_formats.format_mask%TYPE := null;
  g_user_format_choice_cached    hr_name_formats.user_format_choice%TYPE := null;
  g_legislation_code_cached      hr_name_formats.legislation_code%TYPE := null;
  g_business_group_id_cached     per_all_people_f.business_group_id%TYPE := null;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_token_position >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_token_position(p_format_mask in varchar2
                            ,p_token       in varchar2
                            ,p_start_pos   out nocopy number
                            ,p_end_pos     out nocopy number) is
--
   l_token_start_pos number;
   l_token_end_pos   number;
--
begin
   if p_format_mask is null or p_token is null then
      l_token_start_pos := 0;
      l_token_end_pos := 0;
   else
      l_token_start_pos := instr(p_format_mask,'$'||p_token||'$');
      l_token_end_pos   := l_token_start_pos + length(p_token) + 1;
   end if;
   --
   p_start_pos := l_token_start_pos;
   p_end_pos   := l_token_end_pos;
   --
end get_token_position;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_token_value >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_token_value(p_token          in varchar2
                         ,p_person_columns in hr_person_name.t_nameColumns_Rec
                         ,p_value          out nocopy varchar2) is
--
   l_value varchar2(240);
--
begin
   l_value := null;
   if    p_token = 'FIR'    then l_value := p_person_columns.FIRST_NAME;
   elsif p_token = 'MID'    then l_value := p_person_columns.MIDDLE_NAMES;
   elsif p_token = 'LAS'    then l_value := p_person_columns.LAST_NAME;
   elsif p_token = 'SUF'    then l_value := p_person_columns.SUFFIX;
   elsif p_token = 'PNADJ'  then l_value := p_person_columns.PRE_NAME_ADJUNCT;
   elsif p_token = 'TITLE'  then
         begin
           SELECT meaning into l_value
             FROM hr_lookups
            WHERE lookup_type = 'TITLE'
              AND lookup_code = p_person_columns.TITLE;
         exception
           when others then
              l_value := null;
         end;
   elsif p_token = 'KNOWN'  then l_value := p_person_columns.KNOWN_AS ;
   elsif p_token = 'USEFIR' then l_value := nvl(p_person_columns.KNOWN_AS,p_person_columns.FIRST_NAME);
   elsif p_token = 'EMAIL'  then l_value := p_person_columns.EMAIL_ADDRESS;
   elsif p_token = 'ENUM'   then l_value := p_person_columns.EMPLOYEE_NUMBER;
   elsif p_token = 'ANUM'   then l_value := p_person_columns.APPLICANT_NUMBER;
   elsif p_token = 'CWNUM'  then l_value := p_person_columns.NPW_NUMBER;
   elsif p_token = 'PRVLAS' then l_value := p_person_columns.PREVIOUS_LAST_NAME;
   elsif p_token = 'MIDINIT' then l_value := Substr(p_person_columns.MIDDLE_NAMES,1,1);
   elsif p_token = 'FIRINIT' then l_value := Substr(p_person_columns.FIRST_NAME,1,1);
   elsif p_token = 'LASINIT' then l_value := Substr(p_person_columns.LAST_NAME,1,1);
   elsif p_token = 'I01' then l_value := p_person_columns.PER_INFORMATION1;
   elsif p_token = 'I02' then l_value := p_person_columns.PER_INFORMATION2;
   elsif p_token = 'I03' then l_value := p_person_columns.PER_INFORMATION3;
   elsif p_token = 'I04' then l_value := p_person_columns.PER_INFORMATION4;
   elsif p_token = 'I05' then l_value := p_person_columns.PER_INFORMATION5;
   elsif p_token = 'I06' then l_value := p_person_columns.PER_INFORMATION6;
   elsif p_token = 'I07' then l_value := p_person_columns.PER_INFORMATION7;
   elsif p_token = 'I08' then l_value := p_person_columns.PER_INFORMATION8;
   elsif p_token = 'I09' then l_value := p_person_columns.PER_INFORMATION9;
   elsif p_token = 'I10' then l_value := p_person_columns.PER_INFORMATION10;
   elsif p_token = 'I11' then l_value := p_person_columns.PER_INFORMATION11;
   elsif p_token = 'I12' then l_value := p_person_columns.PER_INFORMATION12;
   elsif p_token = 'I13' then l_value := p_person_columns.PER_INFORMATION13;
   elsif p_token = 'I14' then l_value := p_person_columns.PER_INFORMATION14;
   elsif p_token = 'I15' then l_value := p_person_columns.PER_INFORMATION15;
   elsif p_token = 'I16' then l_value := p_person_columns.PER_INFORMATION16;
   elsif p_token = 'I17' then l_value := p_person_columns.PER_INFORMATION17;
   elsif p_token = 'I18' then l_value := p_person_columns.PER_INFORMATION18;
   elsif p_token = 'I19' then l_value := p_person_columns.PER_INFORMATION19;
   elsif p_token = 'I20' then l_value := p_person_columns.PER_INFORMATION20;
   elsif p_token = 'I21' then l_value := p_person_columns.PER_INFORMATION21;
   elsif p_token = 'I22' then l_value := p_person_columns.PER_INFORMATION22;
   elsif p_token = 'I23' then l_value := p_person_columns.PER_INFORMATION23;
   elsif p_token = 'I24' then l_value := p_person_columns.PER_INFORMATION24;
   elsif p_token = 'I25' then l_value := p_person_columns.PER_INFORMATION25;
   elsif p_token = 'I26' then l_value := p_person_columns.PER_INFORMATION26;
   elsif p_token = 'I27' then l_value := p_person_columns.PER_INFORMATION27;
   elsif p_token = 'I28' then l_value := p_person_columns.PER_INFORMATION28;
   elsif p_token = 'I29' then l_value := p_person_columns.PER_INFORMATION29;
   elsif p_token = 'I30' then l_value := p_person_columns.PER_INFORMATION30;
   elsif p_token = 'A01' then l_value := p_person_columns.ATTRIBUTE1;
   elsif p_token = 'A02' then l_value := p_person_columns.ATTRIBUTE2;
   elsif p_token = 'A03' then l_value := p_person_columns.ATTRIBUTE3;
   elsif p_token = 'A04' then l_value := p_person_columns.ATTRIBUTE4;
   elsif p_token = 'A05' then l_value := p_person_columns.ATTRIBUTE5;
   elsif p_token = 'A06' then l_value := p_person_columns.ATTRIBUTE6;
   elsif p_token = 'A07' then l_value := p_person_columns.ATTRIBUTE7;
   elsif p_token = 'A08' then l_value := p_person_columns.ATTRIBUTE8;
   elsif p_token = 'A09' then l_value := p_person_columns.ATTRIBUTE9;
   elsif p_token = 'A10' then l_value := p_person_columns.ATTRIBUTE10;
   elsif p_token = 'A11' then l_value := p_person_columns.ATTRIBUTE11;
   elsif p_token = 'A12' then l_value := p_person_columns.ATTRIBUTE12;
   elsif p_token = 'A13' then l_value := p_person_columns.ATTRIBUTE13;
   elsif p_token = 'A14' then l_value := p_person_columns.ATTRIBUTE14;
   elsif p_token = 'A15' then l_value := p_person_columns.ATTRIBUTE15;
   elsif p_token = 'A16' then l_value := p_person_columns.ATTRIBUTE16;
   elsif p_token = 'A17' then l_value := p_person_columns.ATTRIBUTE17;
   elsif p_token = 'A18' then l_value := p_person_columns.ATTRIBUTE18;
   elsif p_token = 'A19' then l_value := p_person_columns.ATTRIBUTE19;
   elsif p_token = 'A20' then l_value := p_person_columns.ATTRIBUTE20;
   elsif p_token = 'A21' then l_value := p_person_columns.ATTRIBUTE21;
   elsif p_token = 'A22' then l_value := p_person_columns.ATTRIBUTE22;
   elsif p_token = 'A23' then l_value := p_person_columns.ATTRIBUTE23;
   elsif p_token = 'A24' then l_value := p_person_columns.ATTRIBUTE24;
   elsif p_token = 'A25' then l_value := p_person_columns.ATTRIBUTE25;
   elsif p_token = 'A26' then l_value := p_person_columns.ATTRIBUTE26;
   elsif p_token = 'A27' then l_value := p_person_columns.ATTRIBUTE27;
   elsif p_token = 'A28' then l_value := p_person_columns.ATTRIBUTE28;
   elsif p_token = 'A29' then l_value := p_person_columns.ATTRIBUTE29;
   elsif p_token = 'A30' then l_value := p_person_columns.ATTRIBUTE30;
   elsif p_token = 'P01' then l_value := '/'; -- Added for BUG 5530099
   end if;
   --
   p_value := l_value;
   --
end get_token_value;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_formatted_name >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_formatted_name(p_name_values    in hr_person_name.t_nameColumns_Rec
                            ,p_formatted_name in out nocopy varchar2) is
--
   l_formatted_name      varchar2(2000);
   l_token_start_pos     number;
   l_token_end_pos       number;
   l_token_value         varchar2(240);
   l_delimeter_start_pos number;
   l_delimeter_end_pos   number;
   l_expr                varchar2(240);
   l_token_found         boolean;
--
   cursor csr_valid_tokens is
      select lookup_code token_name
        from hr_standard_lookups
       where lookup_type = 'PER_FORMAT_MASK_TOKENS';
--
begin
   l_token_start_pos  := 0;
   l_token_end_pos    := 0;
   l_token_value      := null;
   l_delimeter_start_pos := 0;
   l_delimeter_end_pos := 0;
   l_expr := null;
   l_token_found := FALSE;
   --
   l_formatted_name := p_formatted_name;
   if l_formatted_name is not null then
      for l_token in csr_valid_tokens loop
         --
         -- check whether token is referenced by format mask
         -- get the start/end positions in string
         --
         get_token_position(p_format_mask => l_formatted_name
                           ,p_token       => l_token.token_name
                           ,p_start_pos   => l_token_start_pos
                           ,p_end_pos     => l_token_end_pos);
         if l_token_start_pos > 0 then
            -- found token referenced in format mask
            get_token_value(p_token          => l_token.token_name
                           ,p_person_columns => p_name_values
                           ,p_value          => l_token_value);
            --
            -- if db column is null, then ignore token and its punctuation
            --
            if l_token_value is not null then
               l_token_found := TRUE;
               loop -- replace all ocurrences
                 l_formatted_name := REPLACE(l_formatted_name,'$'||l_token.token_name||'$',l_token_value);
                 get_token_position(p_format_mask => l_formatted_name
                                   ,p_token       => l_token.token_name
                                   ,p_start_pos   => l_token_start_pos
                                   ,p_end_pos     => l_token_end_pos);
                 if l_token_start_pos <= 0 then
                    l_token_found := FALSE;
                 end if;
                 exit when NOT l_token_found;
               end loop;

            else
               --
               -- extract the following expression: '|' [punctuation] $token$ [punctuation] '|'
               -- this expression will be replaced by a single '|'
               --
               l_token_found := TRUE;
               loop
                 l_delimeter_start_pos := instr(substr(l_formatted_name,1,l_token_start_pos-1),'|',-1);
                 l_delimeter_end_pos   := instr(substr(l_formatted_name,l_delimeter_start_pos+1),'|');
                 l_expr := substr(l_formatted_name, l_delimeter_start_pos,l_delimeter_end_pos);
                 l_formatted_name := REPLACE(l_formatted_name,l_expr,'|');
                 get_token_position(p_format_mask => l_formatted_name
                                   ,p_token       => l_token.token_name
                                   ,p_start_pos   => l_token_start_pos
                                   ,p_end_pos     => l_token_end_pos);
                 if l_token_start_pos <= 0 then
                    l_token_found := FALSE;
                 end if;
                 exit when NOT l_token_found;
               end loop;
            end if;
         end if;
      end loop;
      l_formatted_name := REPLACE(l_formatted_name, '|', null);
   end if;
   --
   p_formatted_name := l_formatted_name;
   --
end get_formatted_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_person_name_internal >-------------------------|
-- ----------------------------------------------------------------------------
--
function get_person_name_internal
              (p_rowid              in rowid
              ,p_format_mask        in varchar2)
  return varchar2 is
--
   l_proc   CONSTANT  varchar2(80) := g_package||'get_person_name_internal';
--
   l_person_names_rec    hr_person_name.t_nameColumns_Rec;
   l_formatted_name      varchar2(2000);
--
   cursor csr_get_name_columns is
      select rowid row_id
            ,FIRST_NAME
            ,MIDDLE_NAMES
            ,LAST_NAME
            ,SUFFIX
            ,PRE_NAME_ADJUNCT
            ,TITLE
            ,KNOWN_AS
            ,EMAIL_ADDRESS
            ,EMPLOYEE_NUMBER
            ,APPLICANT_NUMBER
            ,NPW_NUMBER
            ,PREVIOUS_LAST_NAME
            ,PER_INFORMATION1
            ,PER_INFORMATION2
            ,PER_INFORMATION3
            ,PER_INFORMATION4
            ,PER_INFORMATION5
            ,PER_INFORMATION6
            ,PER_INFORMATION7
            ,PER_INFORMATION8
            ,PER_INFORMATION9
            ,PER_INFORMATION10
            ,PER_INFORMATION11
            ,PER_INFORMATION12
            ,PER_INFORMATION13
            ,PER_INFORMATION14
            ,PER_INFORMATION15
            ,PER_INFORMATION16
            ,PER_INFORMATION17
            ,PER_INFORMATION18
            ,PER_INFORMATION19
            ,PER_INFORMATION20
            ,PER_INFORMATION21
            ,PER_INFORMATION22
            ,PER_INFORMATION23
            ,PER_INFORMATION24
            ,PER_INFORMATION25
            ,PER_INFORMATION26
            ,PER_INFORMATION27
            ,PER_INFORMATION28
            ,PER_INFORMATION29
            ,PER_INFORMATION30
            ,ATTRIBUTE1
            ,ATTRIBUTE2
            ,ATTRIBUTE3
            ,ATTRIBUTE4
            ,ATTRIBUTE5
            ,ATTRIBUTE6
            ,ATTRIBUTE7
            ,ATTRIBUTE8
            ,ATTRIBUTE9
            ,ATTRIBUTE10
            ,ATTRIBUTE11
            ,ATTRIBUTE12
            ,ATTRIBUTE13
            ,ATTRIBUTE14
            ,ATTRIBUTE15
            ,ATTRIBUTE16
            ,ATTRIBUTE17
            ,ATTRIBUTE18
            ,ATTRIBUTE19
            ,ATTRIBUTE20
            ,ATTRIBUTE21
            ,ATTRIBUTE22
            ,ATTRIBUTE23
            ,ATTRIBUTE24
            ,ATTRIBUTE25
            ,ATTRIBUTE26
            ,ATTRIBUTE27
            ,ATTRIBUTE28
            ,ATTRIBUTE29
            ,ATTRIBUTE30
            ,FULL_NAME
            ,ORDER_NAME
            ,LOCAL_NAME
            ,GLOBAL_NAME
            ,BUSINESS_GROUP_ID
       from per_all_people_f
      where rowid = p_rowid;
--
begin
   --
   if p_format_mask is null then
      l_formatted_name := null;
   else
      l_formatted_name := p_format_mask;
      --
      -- retrieve all name columns for the person record
      --
      open csr_get_name_columns;
      fetch csr_get_name_columns into l_person_names_rec;
      if csr_get_name_columns%FOUND then
         --
         close csr_get_name_columns;
         --
         -- replace all tokens in format mask using name column values
         --
         get_formatted_name(p_name_values    => l_person_names_rec
                           ,p_formatted_name => l_formatted_name);
         --
         l_formatted_name := substr(l_formatted_name,1,240);
      else
         close csr_get_name_columns;
         --
      end if; -- person record found
      --
   end if; -- format mask is null
   RETURN l_formatted_name;
end get_person_name_internal;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_person_name >-----------------------------|
-- ----------------------------------------------------------------------------
--
function get_person_name(p_person_id          in number
                        ,p_effective_date     in date
                        ,p_format_name        in varchar2
                        ,p_user_format_choice in varchar2
                        )
  return varchar2 is
--
   l_proc CONSTANT    varchar2(80) := g_package||'get_person_name';
--
   l_retrieve_flag       varchar2(10);
   l_legislation_code    varchar2(30);
   l_user_format_choice  hr_name_formats.user_format_choice%TYPE;
   l_format_mask         hr_name_formats.format_mask%TYPE;
   l_person_name         varchar2(240);
--
   cursor csr_get_format_mask(cp_format_name varchar2
                             ,cp_user_format_choice varchar2
                             ,cp_legislation_code   varchar2) is
      select format_mask
        from hr_name_formats
       where format_name        = cp_format_name
         and user_format_choice = cp_user_format_choice
         and ((cp_legislation_code is not null
               and legislation_code   = cp_legislation_code)
             or (cp_legislation_code is null and legislation_code is null));
   --
   cursor csr_get_person_details is
     select rowid, business_group_id, full_name, order_name
           ,local_name, global_name
       from per_all_people_f
      where person_id = p_person_id
        and p_effective_date between effective_start_date and effective_end_date;

   l_person_rec csr_get_person_details%ROWTYPE;
--
--
begin
   l_retrieve_flag := 'N';
   open csr_get_person_details;
   fetch csr_get_person_details into l_person_rec;
   if csr_get_person_details%NOTFOUND then
      close csr_get_person_details;
      fnd_message.set_name('PER','HR_51834_QUA_PER_ID_INV');
      fnd_message.raise_error;
   else
      close csr_get_person_details;
      if p_user_format_choice is null or p_user_format_choice not in ('G','L') then
         l_user_format_choice := nvl(fnd_profile.value('HR_LOCAL_OR_GLOBAL_NAME_FORMAT'),'L');
      else
         l_user_format_choice := p_user_format_choice;
      end if;
      --
      if l_user_format_choice <> nvl(g_user_format_choice_cached,hr_api.g_varchar2) then
         l_retrieve_flag := 'Y';
         g_user_format_choice_cached := l_user_format_choice;
      end if;
      --
      if p_format_name = g_FULL_NAME then
         RETURN l_person_rec.full_name;
      elsif p_format_name = g_ORDER_NAME then
         RETURN l_person_rec.order_name;
      elsif p_format_name = g_LIST_NAME then
         if g_user_format_choice_cached = 'L' then
           RETURN l_person_rec.local_name;
         else
           RETURN l_person_rec.global_name;
         end if;
      else
         if l_person_rec.business_group_id <> nvl(g_business_group_id_cached,hr_api.g_number) then
            g_business_group_id_cached := l_person_rec.business_group_id;
            l_legislation_code := hr_api.return_legislation_code(l_person_rec.business_group_id);
            if l_legislation_code <> nvl(g_legislation_code_cached,hr_api.g_varchar2) then
               l_retrieve_flag := 'Y';
               g_legislation_code_cached := l_legislation_code;
            end if;
         end if;
      end if;
      --
      if p_format_name <> nvl(g_format_name_cached,hr_api.g_varchar2) then
         l_retrieve_flag := 'Y';
         g_format_name_cached := p_format_name;
      end if;
      --
      if l_retrieve_flag = 'Y' then
         open csr_get_format_mask(g_format_name_cached, g_user_format_choice_cached
                                , g_legislation_code_cached);
         fetch csr_get_format_mask into l_format_mask;
         if csr_get_format_mask%NOTFOUND then
            close csr_get_format_mask;
            open csr_get_format_mask(p_format_name, l_user_format_choice, null);
            fetch csr_get_format_mask into l_format_mask;
            if csr_get_format_mask%NOTFOUND then
               close csr_get_format_mask;
               RETURN null;
            end if;
         end if;
         g_format_mask_cached := l_format_mask;
      end if;
      -- name is already truncated to 240 characters
      l_person_name := get_person_name_internal(l_person_rec.rowid, g_format_mask_cached);
      RETURN l_person_name;
   --
   end if; --person found
end get_person_name;
--
--
-- ----------------------------------------------------------------------------
-- ---------------------------< is_valid_format >------------------------------
-- ----------------------------------------------------------------------------
-- Returns 'TRUE' if format exists per legislation or a seeded one exists
--
function is_valid_format(p_format_name    in varchar2
                        ,p_legislation    in varchar2)
  return varchar2 is
--
  l_valid varchar2(10);
  --
  cursor csr_validate_name is
    select 'TRUE'
      from hr_name_formats
     where format_name = p_format_name
       and ((p_legislation is not null and legislation_code = p_legislation)
            or legislation_code is null);
  --
begin
  l_valid := 'FALSE';
  if p_format_name is not null then
    open csr_validate_name;
    fetch csr_validate_name into l_valid;
    if csr_validate_name%NOTFOUND then
      l_valid := 'FALSE';
    end if;
  end if;
  close csr_validate_name;
  return l_valid;
  --
end is_valid_format;
--
--
-- This routine is kept for backwards compatibility
-- ----------------------------------------------------------------------------
-- |----------------------< OLD_get_person_name >-----------------------------|
-- ----------------------------------------------------------------------------
--
function get_person_name(
  p_person_id            in number,
  p_effective_date       in date default null,
  p_format               in varchar2 default null) return varchar2 is
--
  l_formatted_name varchar2(240);
  l_format_name    hr_name_formats.format_name%TYPE;
  l_legislation    varchar2(30);
  --
  cursor csr_get_leg is
    select bg.legislation_code
      from per_all_people_f   peo
          ,per_business_groups_perf bg
     where peo.person_id = p_person_id
       and p_effective_date between peo.effective_start_date and peo.effective_end_date
       and peo.business_group_id = bg.business_group_id;
  --
begin
   l_format_name := p_format;
   if l_format_name is null then
     l_format_name := g_LIST_NAME;
   else
     open csr_get_leg;
     fetch csr_get_leg into l_legislation;
     close csr_get_leg;
     if is_valid_format(l_format_name,l_legislation) = 'FALSE' then
       l_format_name := g_LIST_NAME;
     end if;
   end if;
   l_formatted_name := get_person_name
            (p_person_id          => p_person_id
            ,p_effective_date     => p_effective_date
            ,p_format_name        => l_format_name
            ,p_user_format_choice => 'G');
   --
   return l_formatted_name;
   --
end get_person_name;
-- ----------------------------------------------------------------------------
-- |-------------------< OBSOLETE_get_person_name >---------------------------|
-- ----------------------------------------------------------------------------
--
--function get_person_name(p_person_id in number,
--                        p_effective_date in date,
--                        p_format in varchar2) return varchar2 is
--
-- l_proc             varchar2(80) := g_package||'get_person_name';
--cursor to select the person information.
--
-- cursor c1 is
--   select
--       first_name
--     , middle_names
--    , last_name
--     , pre_name_adjunct
--     , suffix
--     , hr_general.decode_lookup('TITLE',title) title
--     , full_name
--     , known_as
--   from per_all_people_f
--   where person_id = p_person_id
--   and   trunc(nvl(p_effective_date,sysdate)) between effective_start_date
--                                              and     effective_end_date;
--
-- person_rec c1%rowtype;
-- l_format             varchar2(400);
--
--begin
--
-- hr_utility.set_location('Entering '||l_proc,10);
--
--open c1;
-- fetch c1 into person_rec;
--
-- if c1%notfound then   --if person not found
 --
--   close c1;
--   fnd_message.set_name('PER','HR_51834_QUA_PER_ID_INV');
--   fnd_message.raise_error;
--
-- else    -- person found..
 --
   --
   -- checking whether required format is specified
--   if p_format is not null then  --format specified
   --
--     l_format := p_format;
     --
--     hr_utility.set_location('Replacing tokens '||l_proc,20);
     -- Replacing the tokens with person name components.
     --
--     l_format := replace(l_format,'$FI',person_rec.first_name);
--     l_format := replace(l_format,'$MI',person_rec.middle_names);
--     l_format := replace(l_format,'$LA',person_rec.last_name);
--     l_format := replace(l_format,'$PR',person_rec.pre_name_adjunct);
--     l_format := replace(l_format,'$SU',person_rec.suffix);
--     l_format := replace(l_format,'$TI',person_rec.title);
--     l_format := replace(l_format,'$FU',person_rec.full_name);
--     l_format := replace(l_format,'$KN',person_rec.known_as);
--     l_format := replace(l_format,'$IF',substr(ltrim(person_rec.first_name),1,1));
--     l_format := replace(l_format,'$IM',substr(ltrim(person_rec.middle_names),1,1));
   --
--   elsif fnd_profile.value('HR_INFORMAL_NAME_FORMAT') is not null then
   --
--     hr_utility.set_location('Replacing tokens '||l_proc,20);

--     l_format := fnd_profile.value('HR_INFORMAL_NAME_FORMAT');
--     hr_utility.trace('profile option value : ' || l_format);
     --
     -- Replacing the tokens with person name components.
     --
--     l_format := replace(l_format,'$FI',person_rec.first_name);
--     l_format := replace(l_format,'$MI',person_rec.middle_names);
--     l_format := replace(l_format,'$LA',person_rec.last_name);
--     l_format := replace(l_format,'$PR',person_rec.pre_name_adjunct);
--     l_format := replace(l_format,'$SU',person_rec.suffix);
--     l_format := replace(l_format,'$TI',person_rec.title);
--     l_format := replace(l_format,'$FU',person_rec.full_name);
--     l_format := replace(l_format,'$KN',person_rec.known_as);
--     l_format := replace(l_format,'$IF',substr(ltrim(person_rec.first_name),1,1));
--     l_format := replace(l_format,'$IM',substr(ltrim(person_rec.middle_names),1,1));

--   else  -- format not specified.
   --
     --
--     hr_utility.set_location('No format specified Full_Name '||l_proc,40);
     -- in this case returning full_name.
     --
--     l_format := person_rec.full_name;
     --
   --
--   end if;
   --
   --
--   hr_utility.set_location('Leaving '||l_proc,50);
   --
--   return l_format;
   --
 --
-- end if;
 --
-- close c1;
-- hr_utility.set_location('Leaving '||l_proc,60);
--
--end get_person_name; --function
--
-- ----------------------------------------------------------------------------
-- |-------------------< get_seeded_procedure_name >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_seeded_procedure_name
   (p_format_name       IN varchar2
   ,p_legislation_code  IN varchar2
   ,p_package_name      OUT nocopy varchar2
   ,p_procedure_name    OUT nocopy varchar2 ) is
--
   l_package_name VARCHAR2(50);
   l_dummy VARCHAR2(1);
   l_procedure_name VARCHAR2(50);
   --
   cursor csr_leg_pkg(cp_pkg VARCHAR2) IS
     select '1'
     from user_objects
     where object_name = cp_pkg
     and object_type = 'PACKAGE';
--
  CURSOR lgsl_pkb(cp_pkg VARCHAR2) IS
    SELECT object_name
    FROM user_objects
    WHERE object_type='PACKAGE BODY'
      AND object_name = cp_pkg
      AND length(object_name)=13
    ORDER BY object_name;
--
begin
   l_package_name := null;
   l_procedure_name := null;
   --
   if hr_general.g_data_migrator_mode <> 'Y' then
   if ( hr_utility.chk_product_install('Oracle Human Resources',p_legislation_code)
        or (p_legislation_code = 'JP')) then
      --
      l_package_name := 'HR_'||p_legislation_code||'_UTILITY';
      if p_format_name = g_FULL_NAME then
         l_procedure_name := 'per_'||lower(p_legislation_code)||'_full_name';
      elsif p_format_name = g_ORDER_NAME then
         l_procedure_name := 'per_'||lower(p_legislation_code)||'_order_name';
      else
         l_procedure_name := null;
      end if;
      --
      -- check package exists
      --
      open csr_leg_pkg(l_package_name);
      fetch csr_leg_pkg into l_dummy;
      if csr_leg_pkg%NOTFOUND then
         l_package_name   := null;
         l_procedure_name := null;
      end if;
      close csr_leg_pkg;
      open lgsl_pkb(l_package_name);
      FETCH lgsl_pkb INTO l_package_name;
      IF lgsl_pkb%NOTFOUND THEN
         l_package_name   := null;
         l_procedure_name := null;
      END IF;
      CLOSE lgsl_pkb;

   else
      l_package_name   := null;
      l_procedure_name := null;
   end if;
   --
   end if;
   p_package_name   := l_package_name;
   p_procedure_name := l_procedure_name;
   --
end get_seeded_procedure_name;
--
-- ----------------------------------------------------------------------------
-- |------------------< derive_name_using_seeded_proc >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure derive_name_using_seeded_proc
   (p_format_name       IN varchar2
   ,p_legislation_code  IN varchar2
   ,p_name_column_rec   IN hr_person_name.t_nameColumns_Rec
   ,p_package_name      IN varchar2 default NULL
   ,p_procedure_name    IN varchar2 default NULL
   ,p_formatted_name    OUT nocopy varchar2
   ) is
--
    e_InvalidProc exception;
     pragma exception_init(e_InvalidProc, -904);

   l_formatted_name varchar2(2000);
   l_package_name VARCHAR2(50);
   l_procedure_name VARCHAR2(50);
   l_proc_call VARCHAR2(4790);
--
begin
   l_formatted_name := null;
   l_package_name   := p_package_name;
   l_procedure_name := p_procedure_name;
   --
   if p_package_name is null then
      get_seeded_procedure_name
         (p_format_name       => p_format_name
         ,p_legislation_code  => p_legislation_code
         ,p_package_name      => l_package_name
         ,p_procedure_name    => l_procedure_name);
   end if;
   --
   if l_package_name is not null then
      --
      -- construct an anonymous block with bind variable
      --
      l_proc_call := 'SELECT rtrim(substrb( '|| l_package_name ||'.'||l_procedure_name||'(:p_first_name,:p_middle_names,:p_last_name,:p_known_as,:p_title,';

      l_proc_call := l_proc_call||':p_suffix,:p_pre_name_adjunct,:p_per_information1,:p_per_information2,:p_per_information3,:p_per_information4,:p_per_information5,';

      l_proc_call := l_proc_call||':p_per_information6,:p_per_information7,:p_per_information8,:p_per_information9,:p_per_information10,';

      l_proc_call := l_proc_call||':p_per_information11,:p_per_information12,:p_per_information13,:p_per_information14,:p_per_information15,:p_per_information16,:p_per_information17,';

      l_proc_call := l_proc_call||':p_per_information18,:p_per_information19,:p_per_information20,:p_per_information21,:p_per_information22,:p_per_information23,:p_per_information24,';

      l_proc_call := l_proc_call||':p_per_information25,:p_per_information26,:p_per_information27,:p_per_information28,:p_per_information29,:p_per_information30),1,240)) FROM sys.dual ';

      EXECUTE IMMEDIATE l_proc_call
        INTO l_formatted_name
        USING  p_name_column_rec.first_name
              ,p_name_column_rec.middle_names
              ,p_name_column_rec.last_name
              ,p_name_column_rec.known_as
              ,p_name_column_rec.title
              ,p_name_column_rec.suffix
              ,p_name_column_rec.pre_name_adjunct
              ,p_name_column_rec.per_information1
              ,p_name_column_rec.per_information2
              ,p_name_column_rec.per_information3
              ,p_name_column_rec.per_information4
              ,p_name_column_rec.per_information5
              ,p_name_column_rec.per_information6
              ,p_name_column_rec.per_information7
              ,p_name_column_rec.per_information8
              ,p_name_column_rec.per_information9
              ,p_name_column_rec.per_information10
              ,p_name_column_rec.per_information11
              ,p_name_column_rec.per_information12
              ,p_name_column_rec.per_information13
              ,p_name_column_rec.per_information14
              ,p_name_column_rec.per_information15
              ,p_name_column_rec.per_information16
              ,p_name_column_rec.per_information17
              ,p_name_column_rec.per_information18
              ,p_name_column_rec.per_information19
              ,p_name_column_rec.per_information20
              ,p_name_column_rec.per_information21
              ,p_name_column_rec.per_information22
              ,p_name_column_rec.per_information23
              ,p_name_column_rec.per_information24
              ,p_name_column_rec.per_information25
              ,p_name_column_rec.per_information26
              ,p_name_column_rec.per_information27
              ,p_name_column_rec.per_information28
              ,p_name_column_rec.per_information29
              ,p_name_column_rec.per_information30;

      p_formatted_name := substr(rtrim(l_formatted_name),1,240);
   end if;
   --
exception
   when e_InvalidProc then  -- we need to trap this error in case procedure
                            -- does not exist; that's a a valid condition
      p_formatted_name := null;
--
end derive_name_using_seeded_proc;
--
-- ----------------------------------------------------------------------------
-- |------------------------< derive_person_names >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure derive_person_names
(p_format_name        hr_name_formats.format_name%TYPE,
 p_business_group_id  per_all_people_f.business_group_id%TYPE,
 p_person_id          per_all_people_f.person_id%TYPE,
 p_first_name         per_all_people_f.first_name%TYPE,
 p_middle_names       per_all_people_f.middle_names%TYPE,
 p_last_name          per_all_people_f.last_name%TYPE,
 p_known_as           per_all_people_f.known_as%TYPE,
 p_title              per_all_people_f.title%TYPE,
 p_suffix             per_all_people_f.suffix%TYPE,
 p_pre_name_adjunct   per_all_people_f.pre_name_adjunct%TYPE,
 p_date_of_birth      per_all_people_f.date_of_birth%TYPE,
 p_previous_last_name per_all_people_f.previous_last_name%TYPE DEFAULT NULL,
 p_email_address      per_all_people_f.email_address%TYPE DEFAULT NULL,
 p_employee_number    per_all_people_f.employee_number%TYPE DEFAULT NULL,
 p_applicant_number   per_all_people_f.applicant_number%TYPE DEFAULT NULL,
 p_npw_number         per_all_people_f.npw_number%TYPE DEFAULT NULL,
 p_per_information1   per_all_people_f.per_information1%TYPE DEFAULT NULL,
 p_per_information2   per_all_people_f.per_information2%TYPE DEFAULT NULL,
 p_per_information3   per_all_people_f.per_information3%TYPE DEFAULT NULL,
 p_per_information4   per_all_people_f.per_information4%TYPE DEFAULT NULL,
 p_per_information5   per_all_people_f.per_information5%TYPE DEFAULT NULL,
 p_per_information6   per_all_people_f.per_information6%TYPE DEFAULT NULL,
 p_per_information7   per_all_people_f.per_information7%TYPE DEFAULT NULL,
 p_per_information8   per_all_people_f.per_information8%TYPE DEFAULT NULL,
 p_per_information9   per_all_people_f.per_information9%TYPE DEFAULT NULL,
 p_per_information10  per_all_people_f.per_information10%TYPE DEFAULT NULL,
 p_per_information11  per_all_people_f.per_information11%TYPE DEFAULT NULL,
 p_per_information12  per_all_people_f.per_information12%TYPE DEFAULT NULL,
 p_per_information13  per_all_people_f.per_information13%TYPE DEFAULT NULL,
 p_per_information14  per_all_people_f.per_information14%TYPE DEFAULT NULL,
 p_per_information15  per_all_people_f.per_information15%TYPE DEFAULT NULL,
 p_per_information16  per_all_people_f.per_information16%TYPE DEFAULT NULL,
 p_per_information17  per_all_people_f.per_information17%TYPE DEFAULT NULL,
 p_per_information18  per_all_people_f.per_information18%TYPE DEFAULT NULL,
 p_per_information19  per_all_people_f.per_information19%TYPE DEFAULT NULL,
 p_per_information20  per_all_people_f.per_information20%TYPE DEFAULT NULL,
 p_per_information21  per_all_people_f.per_information21%TYPE DEFAULT NULL,
 p_per_information22  per_all_people_f.per_information22%TYPE DEFAULT NULL,
 p_per_information23  per_all_people_f.per_information23%TYPE DEFAULT NULL,
 p_per_information24  per_all_people_f.per_information24%TYPE DEFAULT NULL,
 p_per_information25  per_all_people_f.per_information25%TYPE DEFAULT NULL,
 p_per_information26  per_all_people_f.per_information26%TYPE DEFAULT NULL,
 p_per_information27  per_all_people_f.per_information27%TYPE DEFAULT NULL,
 p_per_information28  per_all_people_f.per_information28%TYPE DEFAULT NULL,
 p_per_information29  per_all_people_f.per_information29%TYPE DEFAULT NULL,
 p_per_information30  per_all_people_f.per_information30%TYPE DEFAULT NULL,
 p_attribute1         per_all_people_f.attribute1%TYPE DEFAULT NULL,
 p_attribute2         per_all_people_f.attribute2%TYPE DEFAULT NULL,
 p_attribute3         per_all_people_f.attribute3%TYPE DEFAULT NULL,
 p_attribute4         per_all_people_f.attribute4%TYPE DEFAULT NULL,
 p_attribute5         per_all_people_f.attribute5%TYPE DEFAULT NULL,
 p_attribute6         per_all_people_f.attribute6%TYPE DEFAULT NULL,
 p_attribute7         per_all_people_f.attribute7%TYPE DEFAULT NULL,
 p_attribute8         per_all_people_f.attribute8%TYPE DEFAULT NULL,
 p_attribute9         per_all_people_f.attribute9%TYPE DEFAULT NULL,
 p_attribute10        per_all_people_f.attribute10%TYPE DEFAULT NULL,
 p_attribute11        per_all_people_f.attribute11%TYPE DEFAULT NULL,
 p_attribute12        per_all_people_f.attribute12%TYPE DEFAULT NULL,
 p_attribute13        per_all_people_f.attribute13%TYPE DEFAULT NULL,
 p_attribute14        per_all_people_f.attribute14%TYPE DEFAULT NULL,
 p_attribute15        per_all_people_f.attribute15%TYPE DEFAULT NULL,
 p_attribute16        per_all_people_f.attribute16%TYPE DEFAULT NULL,
 p_attribute17        per_all_people_f.attribute17%TYPE DEFAULT NULL,
 p_attribute18        per_all_people_f.attribute18%TYPE DEFAULT NULL,
 p_attribute19        per_all_people_f.attribute19%TYPE DEFAULT NULL,
 p_attribute20        per_all_people_f.attribute20%TYPE DEFAULT NULL,
 p_attribute21        per_all_people_f.attribute21%TYPE DEFAULT NULL,
 p_attribute22        per_all_people_f.attribute22%TYPE DEFAULT NULL,
 p_attribute23        per_all_people_f.attribute23%TYPE DEFAULT NULL,
 p_attribute24        per_all_people_f.attribute24%TYPE DEFAULT NULL,
 p_attribute25        per_all_people_f.attribute25%TYPE DEFAULT NULL,
 p_attribute26        per_all_people_f.attribute26%TYPE DEFAULT NULL,
 p_attribute27        per_all_people_f.attribute27%TYPE DEFAULT NULL,
 p_attribute28        per_all_people_f.attribute28%TYPE DEFAULT NULL,
 p_attribute29        per_all_people_f.attribute29%TYPE DEFAULT NULL,
 p_attribute30        per_all_people_f.attribute30%TYPE DEFAULT NULL,
 p_full_name          OUT NOCOPY per_all_people_f.full_name%TYPE ,
 p_order_name         OUT NOCOPY per_all_people_f.order_name%TYPE,
 p_global_name        OUT NOCOPY per_all_people_f.global_name%TYPE,
 p_local_name         OUT NOCOPY per_all_people_f.local_name%TYPE,
 p_duplicate_flag     OUT NOCOPY VARCHAR2
 ) is
--
   l_proc   CONSTANT   varchar2(80) := g_package||'get_derive_person_names';
--
   l_person_names_rec           hr_person_name.t_nameColumns_Rec;
   l_format_name                hr_name_formats.format_name%TYPE;
   l_legislation_code           varchar2(30);
   l_FULL_NAME_format_mask      hr_name_formats.format_mask%TYPE;
   l_ORDER_NAME_format_mask     hr_name_formats.format_mask%TYPE;
   l_GLOBAL_NAME_format_mask    hr_name_formats.format_mask%TYPE;
   l_LOCAL_NAME_format_mask     hr_name_formats.format_mask%TYPE;
   l_full_name_formatted        varchar2(2000);
   l_order_name_formatted       varchar2(2000);
   l_global_name_formatted      varchar2(2000);
   l_local_name_formatted       varchar2(2000);
   l_pkg_full_name              VARCHAR2(50);
   l_proc_full_name             VARCHAR2(50);
   l_pkg_order_name             VARCHAR2(50);
   l_proc_order_name            VARCHAR2(50);
   l_gen_all_per_cols           VARCHAR2(10);
--
   local_warning exception;
   l_first_char  VARCHAR2(5);
   l_second_char VARCHAR2(5);
   l_ul_check    VARCHAR2(15);
   l_lu_check    VARCHAR2(15);
   l_uu_check    VARCHAR2(15);
   l_ll_check    VARCHAR2(15);
   l_status      varchar(5);
--
   cursor csr_get_format_mask
      (cp_format_name        varchar2
      ,cp_legcode            varchar2
      ,cp_user_format_choice varchar2 ) is
      select nmf.format_mask
        from HR_NAME_FORMATS nmf
       where nmf.format_name = cp_format_name
         and (cp_legcode is not null and nmf.legislation_code = cp_legcode
              or
              cp_legcode is null and nmf.legislation_code is null)
         and nmf.user_format_choice = cp_user_format_choice;
--
begin
   -- ------------------------------------------------------------------------+
   -- Populate record with column values
   -- ------------------------------------------------------------------------+
   l_person_names_rec.first_name         := p_first_name;
   l_person_names_rec.middle_names       := p_middle_names;
   l_person_names_rec.last_name          := p_last_name;
   l_person_names_rec.known_as           := p_known_as;
   l_person_names_rec.title              := p_title;
   l_person_names_rec.suffix             := p_suffix;
   l_person_names_rec.pre_name_adjunct   := p_pre_name_adjunct;
   l_person_names_rec.previous_last_name := p_previous_last_name;
   l_person_names_rec.email_address      := p_email_address;
   l_person_names_rec.employee_number    := p_employee_number;
   l_person_names_rec.applicant_number   := p_applicant_number;
   l_person_names_rec.npw_number         := p_npw_number;
   l_person_names_rec.per_information1   := p_per_information1;
   l_person_names_rec.per_information2   := p_per_information2;
   l_person_names_rec.per_information3   := p_per_information3;
   l_person_names_rec.per_information4   := p_per_information4;
   l_person_names_rec.per_information5   := p_per_information5;
   l_person_names_rec.per_information6   := p_per_information6;
   l_person_names_rec.per_information7   := p_per_information7;
   l_person_names_rec.per_information8   := p_per_information8;
   l_person_names_rec.per_information9   := p_per_information9;
   l_person_names_rec.per_information10  := p_per_information10;
   l_person_names_rec.per_information11  := p_per_information11;
   l_person_names_rec.per_information12  := p_per_information12;
   l_person_names_rec.per_information13  := p_per_information13;
   l_person_names_rec.per_information14  := p_per_information14;
   l_person_names_rec.per_information15  := p_per_information15;
   l_person_names_rec.per_information16  := p_per_information16;
   l_person_names_rec.per_information17  := p_per_information17;
   l_person_names_rec.per_information18  := p_per_information18;
   l_person_names_rec.per_information19  := p_per_information19;
   l_person_names_rec.per_information20  := p_per_information20;
   l_person_names_rec.per_information21  := p_per_information21;
   l_person_names_rec.per_information22  := p_per_information22;
   l_person_names_rec.per_information23  := p_per_information23;
   l_person_names_rec.per_information24  := p_per_information24;
   l_person_names_rec.per_information25  := p_per_information25;
   l_person_names_rec.per_information26  := p_per_information26;
   l_person_names_rec.per_information27  := p_per_information27;
   l_person_names_rec.per_information28  := p_per_information28;
   l_person_names_rec.per_information29  := p_per_information29;
   l_person_names_rec.per_information30  := p_per_information30;
   l_person_names_rec.attribute1         := p_attribute1;
   l_person_names_rec.attribute2         := p_attribute2;
   l_person_names_rec.attribute3         := p_attribute3;
   l_person_names_rec.attribute4         := p_attribute4;
   l_person_names_rec.attribute5         := p_attribute5;
   l_person_names_rec.attribute6         := p_attribute6;
   l_person_names_rec.attribute7         := p_attribute7;
   l_person_names_rec.attribute8         := p_attribute8;
   l_person_names_rec.attribute9         := p_attribute9;
   l_person_names_rec.attribute10        := p_attribute10;
   l_person_names_rec.attribute11        := p_attribute11;
   l_person_names_rec.attribute12        := p_attribute12;
   l_person_names_rec.attribute13        := p_attribute13;
   l_person_names_rec.attribute14        := p_attribute14;
   l_person_names_rec.attribute15        := p_attribute15;
   l_person_names_rec.attribute16        := p_attribute16;
   l_person_names_rec.attribute17        := p_attribute17;
   l_person_names_rec.attribute18        := p_attribute18;
   l_person_names_rec.attribute19        := p_attribute19;
   l_person_names_rec.attribute20        := p_attribute20;
   l_person_names_rec.attribute21        := p_attribute21;
   l_person_names_rec.attribute22        := p_attribute22;
   l_person_names_rec.attribute23        := p_attribute23;
   l_person_names_rec.attribute24        := p_attribute24;
   l_person_names_rec.attribute25        := p_attribute25;
   l_person_names_rec.attribute26        := p_attribute26;
   l_person_names_rec.attribute27        := p_attribute27;
   l_person_names_rec.attribute28        := p_attribute28;
   l_person_names_rec.attribute29        := p_attribute29;
   l_person_names_rec.attribute30        := p_attribute30;
   l_person_names_rec.full_name           := null;


   -- ------------------------------------------------------------------------+
   -- End populate record
   -- ------------------------------------------------------------------------+
   --
   -- Initialize local variables
   --
   p_duplicate_flag:= 'N';
   l_global_name_formatted    := null;
   l_local_name_formatted     := null;
   l_full_name_formatted      := null;
   l_order_name_formatted     := null;
   l_GLOBAL_NAME_format_mask  := null;
   l_LOCAL_NAME_format_mask   := null;
   l_FULL_NAME_format_mask    := null;
   l_ORDER_NAME_format_mask   := null;
   --
   l_format_name              := p_format_name;
   if p_format_name is null then
      l_gen_all_per_cols := 'Y';
   else
      l_gen_all_per_cols := 'N';
   end if;
   l_legislation_code := hr_api.return_legislation_code(p_business_group_id);
   -- -------------------------------------------------------------------+
   -- Derive FULL_NAME
   -- -------------------------------------------------------------------+
   if l_format_name = g_FULL_NAME or l_gen_all_per_cols = 'Y' then
      --
      open csr_get_format_mask(g_FULL_NAME, l_legislation_code,'L');
      fetch csr_get_format_mask into l_FULL_NAME_format_mask;
      if csr_get_format_mask%NOTFOUND then
         close csr_get_format_mask;
         --
         get_seeded_procedure_name
            (p_format_name       => g_FULL_NAME
            ,p_legislation_code  => l_legislation_code
            ,p_package_name      => l_pkg_full_name
            ,p_procedure_name    => l_proc_full_name);
         --
         if l_pkg_full_name is null then -- use seeded procedure?
            --
            -- seeded procedure does not exist, use seeded format
            --
            open csr_get_format_mask(g_FULL_NAME, null,'L');
            fetch csr_get_format_mask into l_FULL_NAME_format_mask;
            if csr_get_format_mask%NOTFOUND then
               l_FULL_NAME_format_mask := null;
            end if;
            close csr_get_format_mask;
         end if;
      else
         close csr_get_format_mask;
      end if;
      -- -------------------------------------------------------------------+
      -- DERIVE the name
      -- -------------------------------------------------------------------+
      if l_FULL_NAME_format_mask is not null then
         --
         -- replace all tokens in format mask using name column values
         --
         l_full_name_formatted := l_FULL_NAME_format_mask;
         get_formatted_name(p_name_values    => l_person_names_rec
                           ,p_formatted_name => l_full_name_formatted);
         --
         l_full_name_formatted := substr(l_full_name_formatted,1,240);
         --
      elsif l_pkg_full_name is not null then
         -- use seeded procedure to derive name
         derive_name_using_seeded_proc
            (p_format_name       => g_FULL_NAME
            ,p_legislation_code  => l_legislation_code
            ,p_name_column_rec   => l_person_names_rec
            ,p_package_name      => l_pkg_full_name
            ,p_procedure_name    => l_proc_full_name
            ,p_formatted_name    => l_full_name_formatted);
         l_full_name_formatted := rtrim(l_full_name_formatted);
      end if;
      l_person_names_rec.full_name := l_full_name_formatted;
   end if;
   -- -------------------------------------------------------------------+
   -- Derive ORDER_NAME
   -- -------------------------------------------------------------------+
   if l_format_name = g_ORDER_NAME or l_gen_all_per_cols = 'Y' then
      open csr_get_format_mask(g_ORDER_NAME, l_legislation_code,'L');
      fetch csr_get_format_mask into l_ORDER_NAME_format_mask;
      if csr_get_format_mask%NOTFOUND then
         close csr_get_format_mask;
         --
         get_seeded_procedure_name
            (p_format_name       => g_ORDER_NAME
            ,p_legislation_code  => l_legislation_code
            ,p_package_name      => l_pkg_order_name
            ,p_procedure_name    => l_proc_order_name);
         --
         if l_pkg_order_name is null then -- use seeded procedure?
            --
            -- seeded procedure does not exist, use seeded format
            --
            open csr_get_format_mask(g_ORDER_NAME, null,'L');
            fetch csr_get_format_mask into l_ORDER_NAME_format_mask;
            if csr_get_format_mask%NOTFOUND then
               l_ORDER_NAME_format_mask := null;
            end if;
            close csr_get_format_mask;
         end if;
      else
         close csr_get_format_mask;
      end if;
      --  -------------------------------------------------------------------+
      -- Derive Order Name
      --  -------------------------------------------------------------------+
      if l_ORDER_NAME_format_mask is not null then
         --
         -- replace all tokens in format mask using name column values
         --
         l_order_name_formatted := l_ORDER_NAME_format_mask;
         get_formatted_name(p_name_values    => l_person_names_rec
                           ,p_formatted_name => l_order_name_formatted);
         --
         l_order_name_formatted := substr(l_order_name_formatted,1,240);
         --
      elsif l_pkg_order_name is not null then
         -- use seeded procedure to derive name
         derive_name_using_seeded_proc
            (p_format_name       => g_ORDER_NAME
            ,p_legislation_code  => l_legislation_code
            ,p_name_column_rec   => l_person_names_rec
            ,p_package_name      => l_pkg_order_name
            ,p_procedure_name    => l_proc_order_name
            ,p_formatted_name    => l_order_name_formatted);
         l_order_name_formatted := rtrim(l_order_name_formatted);
      end if;
   end if;
   -- -------------------------------------------------------------------+
   -- -------------------------------------------------------------------+
   if l_format_name in (g_DISPLAY_NAME, g_LIST_NAME)
      or l_gen_all_per_cols = 'Y' then
      --
      if l_gen_all_per_cols = 'Y' then
         l_format_name := g_LIST_NAME;
      end if;
      --
      -- Get Global format mask
      --
      open csr_get_format_mask(l_format_name, l_legislation_code,'G');
      fetch csr_get_format_mask into l_GLOBAL_NAME_format_mask;
      if csr_get_format_mask%NOTFOUND then
         close csr_get_format_mask;
         -- look for non legislation specific
         open csr_get_format_mask(l_format_name, null,'G');
         fetch csr_get_format_mask into l_GLOBAL_NAME_format_mask;
         if csr_get_format_mask%NOTFOUND then
            l_GLOBAL_NAME_format_mask := null;
         end if;
         close csr_get_format_mask;
      else
         close csr_get_format_mask;
      end if;
      --
      -- Get Local format mask
      --
      open csr_get_format_mask(l_format_name, l_legislation_code,'L');
      fetch csr_get_format_mask into l_LOCAL_NAME_format_mask;
      if csr_get_format_mask%NOTFOUND then
         close csr_get_format_mask;
         -- look for non legislation specific
         open csr_get_format_mask(l_format_name, null,'L');
         fetch csr_get_format_mask into l_LOCAL_NAME_format_mask;
         if csr_get_format_mask%NOTFOUND then
            l_LOCAL_NAME_format_mask := null;
         end if;
         close csr_get_format_mask;
      else
         close csr_get_format_mask;
      end if;
      -- -------------------------------------------------------------------+
      -- Derive Global and Local Names
      -- -------------------------------------------------------------------+
      if l_GLOBAL_NAME_format_mask is not null then
         --
         -- replace all tokens in format mask using name column values
         --
         l_global_name_formatted := l_GLOBAL_NAME_format_mask;
         get_formatted_name(p_name_values    => l_person_names_rec
                           ,p_formatted_name => l_global_name_formatted);
         --
         l_global_name_formatted := substr(l_global_name_formatted,1,240);
         --
      end if;
      -- -------------------------------------------------------------------+
      if l_LOCAL_NAME_format_mask is not null then
         --
         -- replace all tokens in format mask using name column values
         --
         l_local_name_formatted := l_LOCAL_NAME_format_mask;
         get_formatted_name(p_name_values    => l_person_names_rec
                           ,p_formatted_name => l_local_name_formatted);
         --
         l_local_name_formatted := substr(l_local_name_formatted,1,240);
         --
      end if;
      --
   end if; -- Display/List Names
   -- -------------------------------------------------------------------+
   --
   -- Set OUT parameters
   --
   p_full_name   := l_full_name_formatted;
   p_order_name  := l_order_name_formatted;
   p_global_name := l_global_name_formatted;
   p_local_name  := l_local_name_formatted;
   -- ----------------------------------------------------------------------- +
   -- Check duplicates Cross Business Groups is not enabled
   -- ----------------------------------------------------------------------- +
   if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' then
   declare
     -- bug 3988762
     l_legislation_code VARCHAR2(10) := HR_API.GET_LEGISLATION_CONTEXT;
   begin
    --
      l_first_char  := substr( p_last_name , 1 , 1 ) ;
      l_second_char := substr( p_last_name , 2 , 1 ) ;
      l_ul_check    := upper(l_first_char)||lower(l_second_char)||'%';
      l_lu_check    := lower(l_first_char)||upper(l_second_char)||'%';
      l_uu_check    := upper(l_first_char)||upper(l_second_char)||'%';
      l_ll_check    := lower(l_first_char)||lower(l_second_char)||'%';

       SELECT 'Y'
       INTO   l_status
       FROM   sys.dual
       WHERE  EXISTS (SELECT /*+ no_expand */ 'Duplicate Person Exists'
       FROM   per_all_people_f pp
       WHERE  /* Perform case insensitive check on last name */
              /* trying to use the index on last name        */
              upper(pp.last_name)  = upper(p_last_name)
       AND   (    pp.last_name like l_ul_check
               OR pp.last_name like l_lu_check
               OR pp.last_name like l_uu_check
               OR pp.last_name like l_ll_check
             )
       AND   (upper(pp.first_name) = upper(p_first_name)
              OR p_first_name IS NULL
              OR pp.first_name IS NULL)
       AND   (pp.date_of_birth = p_date_of_birth
              OR p_date_of_birth IS NULL
              OR pp.date_of_birth IS NULL)
       AND   ((p_person_id IS NOT NULL
           AND p_person_id <> pp.person_id)
            OR p_person_id IS NULL)
       AND    pp.business_group_id +0 = p_business_group_id
       AND -- Include Kanji Name for JP Legislation
	   (
	      l_legislation_code <> 'JP'
	      OR
	      (
	        l_legislation_code = 'JP'
	        AND
	        (
	         upper(pp.per_information18) = upper(p_per_information18)
	          OR p_per_information18 IS NULL
	          OR pp.per_information18 IS NULL
	        )
	        AND
	        (
	          upper(pp.per_information19) = upper(p_per_information19)
	          OR p_per_information19 IS NULL
	          OR pp.per_information18 IS NULL
	        )
	      )
          )
         );
       --
       hr_utility.set_message(801,'HR_PERSON_DUPLICATE');

       raise local_warning;

      --
   exception
      when NO_DATA_FOUND then null ;
   --
   end;
   end if;
--
exception
  when local_warning then
    hr_utility.set_warning;
    p_duplicate_flag:='Y';
--
end derive_person_names;
--
-- ----------------------------------------------------------------------------
-- |--------------------< derive_formatted_name >-----------------------------|
-- ----------------------------------------------------------------------------
-- Used within Conc Program
--
FUNCTION derive_formatted_name
  (p_person_names_rec   in hr_person_name.t_nameColumns_Rec
  ,p_format_name        in varchar2
  ,p_legislation_code   in varchar2
  ,p_format_mask        in varchar2
  ,p_seeded_pkg         in varchar2 default NULL
  ,p_seeded_procedure   in varchar2 default NULL
  ,p_seeded_format_mask in varchar2 default NULL) return varchar2 IS
  --
  l_formatted_name      varchar2(2000);
  --
BEGIN
  --
  l_formatted_name := p_format_mask;
  if p_format_name in (g_FULL_NAME, g_ORDER_NAME) then
    if p_format_mask is null then
      if p_seeded_pkg is not null and p_seeded_procedure is not null then
        derive_name_using_seeded_proc
           (p_format_name       => p_format_name
           ,p_legislation_code  => p_legislation_code
           ,p_name_column_rec   => p_person_names_rec
           ,p_package_name      => p_seeded_pkg
           ,p_procedure_name    => p_seeded_procedure
           ,p_formatted_name    => l_formatted_name
           );
      elsif p_seeded_format_mask is not null then
          --
          -- replace all tokens in format mask using name column values
          --
          l_formatted_name := p_seeded_format_mask;
          get_formatted_name(p_name_values    => p_person_names_rec
                           ,p_formatted_name  => l_formatted_name);
          --
      else  -- this should be abnormal condition
        if p_format_name = g_FULL_NAME then
          l_formatted_name := p_person_names_rec.full_name;
        elsif  p_format_name = g_ORDER_NAME then
          l_formatted_name := p_person_names_rec.order_name;
        end if;
      end if;
    else -- localized format mask is not null
      --
      -- replace all tokens in format mask using name column values
      --
      get_formatted_name(p_name_values    => p_person_names_rec
                       ,p_formatted_name  => l_formatted_name);
      --
    end if;

  else
    --
    -- replace all tokens in format mask using name column values
    --
    if l_formatted_name is null and p_seeded_format_mask is not null then
      l_formatted_name := p_seeded_format_mask;
    end if;
    get_formatted_name(p_name_values    => p_person_names_rec
                     ,p_formatted_name  => l_formatted_name);
    --
  end if;
  --
  l_formatted_name := substr(l_formatted_name,1,240);
  --
  RETURN(l_formatted_name);
  --
END derive_formatted_name;
--
--
-- ---------------------------------------------------------------------------+
-- |--------------------< get_formatMask_desc >-------------------------------|
-- ---------------------------------------------------------------------------+
function get_formatMask_desc(p_formatMask varchar2) return varchar2 is
--
   l_formatted_mask      varchar2(2000);
   l_token_start_pos     number;
   l_token_end_pos       number;
   l_token_value         varchar2(240);
   l_delimeter_start_pos number;
   l_delimeter_end_pos   number;
   l_expr                varchar2(240);
--
   cursor csr_valid_tokens is
      select lookup_code token_name, meaning token_desc
        from hr_standard_lookups
       where lookup_type = 'PER_FORMAT_MASK_TOKENS';
--
begin
   l_token_start_pos  := 0;
   l_token_end_pos    := 0;
   l_token_value      := null;
   l_delimeter_start_pos := 0;
   l_delimeter_end_pos := 0;
   l_expr := null;
   --
   l_formatted_mask := p_formatMask;
   if l_formatted_mask is not null then
      for l_token in csr_valid_tokens loop
         --
         -- check whether token is referenced by format mask
         -- get the start/end positions in string
         --
         get_token_position(p_format_mask => l_formatted_mask
                           ,p_token       => l_token.token_name
                           ,p_start_pos   => l_token_start_pos
                           ,p_end_pos     => l_token_end_pos);
         if l_token_start_pos > 0 then
            -- found token referenced in format mask
            --
            if l_token.token_desc is not null then
               l_formatted_mask := REPLACE(l_formatted_mask,'$'||l_token.token_name||'$',l_token.token_desc);
            else
               l_formatted_mask := REPLACE(l_formatted_mask,'$'||l_token.token_name||'$',l_token.token_name);
            end if;
         end if;
      end loop;
      l_formatted_mask := REPLACE(l_formatted_mask, '|', null);
   end if;
   --
   return(l_formatted_mask);
   --
end get_formatMask_desc;
--
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< get_token  >-------------------------------------|
-- ---------------------------------------------------------------------------+
function get_token(p_format_mask    in varchar2
                   ,p_token_number   in number) return varchar2 is
--
   l_token_start_pos number;
   l_token_end_pos   number;
   l_token           fnd_lookup_values.lookup_code%type;
--
begin
   if p_format_mask is null or p_token_number = 0 then
      l_token := null;
   else
      l_token_start_pos := instr(p_format_mask,'$',1,p_token_number + (p_token_number -1));
      l_token_end_pos   := instr(p_format_mask,'$',1,p_token_number + p_token_number);
      l_token := substr(p_format_mask,l_token_start_pos + 1,l_token_end_pos - l_token_start_pos - 1);
   end if;
   --
   return(l_token);
   --
end get_token;
--
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< get_token_desc >---------------------------------|
-- ---------------------------------------------------------------------------+
function get_token_desc(p_token in varchar2) return varchar2 is
--
   l_token_desc      fnd_lookup_values.meaning%type;
--
   cursor csr_valid_tokens(cp_token varchar2) is
      select meaning token_desc
        from hr_standard_lookups
       where lookup_type = 'PER_FORMAT_MASK_TOKENS'
         and lookup_code = cp_token;
begin
   open csr_valid_tokens(p_token);
   fetch csr_valid_tokens into l_token_desc;
   close csr_valid_tokens;
   --
   return(l_token_desc);
   --
end get_token_desc;
--
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< get_prefix >-------------------------------------|
-- ---------------------------------------------------------------------------+
function get_prefix(p_format_mask    in varchar2
                   ,p_token_number   in number) return varchar2 is
--
   l_token_start_pos number;
   l_token_end_pos   number;
   l_delimeter_pos   number;
   l_prefix          varchar2(30);
--
begin
   if p_format_mask is null or p_token_number = 0 then
      l_prefix := null;
   else
      l_token_start_pos := instr(p_format_mask,'$',1,p_token_number + (p_token_number -1));
      l_delimeter_pos   := instr(substr(p_format_mask,1,l_token_start_pos),'|',-1);

      l_prefix := substr(p_format_mask,l_delimeter_pos+1,l_token_start_pos - l_delimeter_pos -1);
   end if;
   --
   return(l_prefix);
   --
end get_prefix;
--
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< get_suffix >-------------------------------------|
-- ---------------------------------------------------------------------------+
function get_suffix(p_format_mask    in varchar2
                   ,p_token_number   in number) return varchar2 is
--
   l_token_start_pos number;
   l_token_end_pos   number;
   l_delimeter_pos   number;
   l_suffix varchar2(30);
--
begin
   if p_format_mask is null or p_token_number = 0 then
      l_suffix := null;
   else
      l_token_end_pos := instr(p_format_mask,'$',1,(p_token_number + p_token_number -1) + 1);
      l_delimeter_pos := instr(substr(p_format_mask,l_token_end_pos),'|',1);

      l_suffix := substr(p_format_mask,l_token_end_pos + 1, l_delimeter_pos-2);
   end if;
   --
   return(l_suffix);
   --
end get_suffix;
--
--
-- ---------------------------------------------------------------------------+
-- |----------------------< get_total_tokens >--------------------------------|
-- ---------------------------------------------------------------------------+
function get_total_tokens(p_format_mask    in varchar2) return number is
--
   l_token_start_pos number;
   l_token_end_pos   number;
   l_token           fnd_lookup_values.lookup_code%type;
   l_mask            hr_name_formats.format_mask%type;
   l_total           number;
   l_count           number;
--
begin
   l_total := 0;
   l_count := 0;
   if p_format_mask is not null  then
      l_mask := p_format_mask;
      l_mask := REPLACE(l_mask, '|', null);
      while l_mask is not null loop
        l_token_start_pos := instr(l_mask,'$');
        l_token_end_pos   := instr(l_mask,'$',1,2);
        if l_token_start_pos > 0 and l_token_end_pos > 0 then
          l_token := substr(l_mask,l_token_start_pos,l_token_end_pos - l_token_start_pos +1 );
          l_total := l_total + 1;
          --
          -- loop through the entire format mask and look for all occurrences of the token
          --
          l_count := 2; -- start with second occurrence
          loop
            if instr(l_mask, l_token,1,l_count) > 0 then
              l_total := l_total + 1;
              l_count := l_count + 1;
            else
              exit;
            end if;
          end loop;
          l_mask := REPLACE(l_mask, l_token, null);
        else
          l_mask := null;
          exit;
        end if;
      end loop;
   end if;
   --
   return (l_total);
   --
end get_total_tokens;
--
--
-- ---------------------------------------------------------------------------+
-- |----------------------< get_space_before >--------------------------------|
-- ---------------------------------------------------------------------------+
function get_space_before(p_component varchar2) return varchar2 is
--
  l_white_delimeter varchar2(10);
--
begin
  l_white_delimeter := 'N';
  if p_component is not null then
    if p_component = ' ' or instr(p_component,' ') = 1 then
      l_white_delimeter := 'Y';
    end if;
  end if;
  return (l_white_delimeter);
end get_space_before;
--
-- ---------------------------------------------------------------------------+
-- |----------------------< get_space_after  >--------------------------------|
-- ---------------------------------------------------------------------------+
function get_space_after(p_component varchar2) return varchar2 is
--
  l_white_delimeter varchar2(10);
--
begin
  l_white_delimeter := 'N';
  if p_component is not null then
    if p_component <> ' ' and instr(substr(p_component,2),' ') > 0 then
      l_white_delimeter := 'Y';
    end if;
  end if;
  return (l_white_delimeter);
end get_space_after;
--
--
-- ---------------------------------------------------------------------------+
-- |----------------------< get_punctuation  >--------------------------------|
-- ---------------------------------------------------------------------------+
function get_punctuation(p_component varchar2) return varchar2 is
--
  l_punctuation varchar2(100);
  l_spaceB varchar2(10);
  l_spaceA varchar2(10);
  l_start number;
  l_end number;

--
begin
  l_start := 1;
  l_end := length(p_component);
  if p_component is not null then
    if p_component = ' ' then
      l_punctuation := '';
    else
      l_spaceB := substr(p_component,1,1);
      l_spaceA := substr(p_component, l_end,1);
      if l_spaceB = ' ' then
         l_start := 2;
      end if;
      if l_spaceA = ' ' then
        l_end := l_end - 1;
      end if;
      l_punctuation := substr(p_component,l_start,l_end);

    end if;
  end if;
  return (l_punctuation);
end get_punctuation;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_list_namne  >--------------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   This returns either a global or local name depending on the profile
--   option setting. This function is to be used within the inter-operable
--   views (See 4428910).
--
function get_list_name(p_global_name in varchar2
                      ,p_local_name  in varchar2) return varchar2 is
begin
  if fnd_profile.value('HR_LOCAL_OR_GLOBAL_NAME_FORMAT') = 'G' then
    return p_global_name;
  else
    return p_local_name;
  end if;
end get_list_name;
--
--
--
-- ------------------------------------------------------------------------------
-- |--------------------------<derive_person_names>----------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   This is overloaded method same as derive_person_names , but does not take
--   person_id and does not perform the duplicate check.
--   The procedure computes the global_name and return full_name,local_name and order_name.
--
--
procedure derive_person_names
(p_format_name        hr_name_formats.format_name%TYPE,
 p_business_group_id  per_all_people_f.business_group_id%TYPE,
 p_first_name         per_all_people_f.first_name%TYPE,
 p_middle_names       per_all_people_f.middle_names%TYPE,
 p_last_name          per_all_people_f.last_name%TYPE,
 p_known_as           per_all_people_f.known_as%TYPE,
 p_title              per_all_people_f.title%TYPE,
 p_suffix             per_all_people_f.suffix%TYPE,
 p_pre_name_adjunct   per_all_people_f.pre_name_adjunct%TYPE,
 p_date_of_birth      per_all_people_f.date_of_birth%TYPE,
 p_previous_last_name per_all_people_f.previous_last_name%TYPE DEFAULT NULL,
 p_email_address      per_all_people_f.email_address%TYPE DEFAULT NULL,
 p_employee_number    per_all_people_f.employee_number%TYPE DEFAULT NULL,
 p_applicant_number   per_all_people_f.applicant_number%TYPE DEFAULT NULL,
 p_npw_number         per_all_people_f.npw_number%TYPE DEFAULT NULL,
 p_per_information1   per_all_people_f.per_information1%TYPE DEFAULT NULL,
 p_per_information2   per_all_people_f.per_information2%TYPE DEFAULT NULL,
 p_per_information3   per_all_people_f.per_information3%TYPE DEFAULT NULL,
 p_per_information4   per_all_people_f.per_information4%TYPE DEFAULT NULL,
 p_per_information5   per_all_people_f.per_information5%TYPE DEFAULT NULL,
 p_per_information6   per_all_people_f.per_information6%TYPE DEFAULT NULL,
 p_per_information7   per_all_people_f.per_information7%TYPE DEFAULT NULL,
 p_per_information8   per_all_people_f.per_information8%TYPE DEFAULT NULL,
 p_per_information9   per_all_people_f.per_information9%TYPE DEFAULT NULL,
 p_per_information10  per_all_people_f.per_information10%TYPE DEFAULT NULL,
 p_per_information11  per_all_people_f.per_information11%TYPE DEFAULT NULL,
 p_per_information12  per_all_people_f.per_information12%TYPE DEFAULT NULL,
 p_per_information13  per_all_people_f.per_information13%TYPE DEFAULT NULL,
 p_per_information14  per_all_people_f.per_information14%TYPE DEFAULT NULL,
 p_per_information15  per_all_people_f.per_information15%TYPE DEFAULT NULL,
 p_per_information16  per_all_people_f.per_information16%TYPE DEFAULT NULL,
 p_per_information17  per_all_people_f.per_information17%TYPE DEFAULT NULL,
 p_per_information18  per_all_people_f.per_information18%TYPE DEFAULT NULL,
 p_per_information19  per_all_people_f.per_information19%TYPE DEFAULT NULL,
 p_per_information20  per_all_people_f.per_information20%TYPE DEFAULT NULL,
 p_per_information21  per_all_people_f.per_information21%TYPE DEFAULT NULL,
 p_per_information22  per_all_people_f.per_information22%TYPE DEFAULT NULL,
 p_per_information23  per_all_people_f.per_information23%TYPE DEFAULT NULL,
 p_per_information24  per_all_people_f.per_information24%TYPE DEFAULT NULL,
 p_per_information25  per_all_people_f.per_information25%TYPE DEFAULT NULL,
 p_per_information26  per_all_people_f.per_information26%TYPE DEFAULT NULL,
 p_per_information27  per_all_people_f.per_information27%TYPE DEFAULT NULL,
 p_per_information28  per_all_people_f.per_information28%TYPE DEFAULT NULL,
 p_per_information29  per_all_people_f.per_information29%TYPE DEFAULT NULL,
 p_per_information30  per_all_people_f.per_information30%TYPE DEFAULT NULL,
 p_attribute1         per_all_people_f.attribute1%TYPE DEFAULT NULL,
 p_attribute2         per_all_people_f.attribute2%TYPE DEFAULT NULL,
 p_attribute3         per_all_people_f.attribute3%TYPE DEFAULT NULL,
 p_attribute4         per_all_people_f.attribute4%TYPE DEFAULT NULL,
 p_attribute5         per_all_people_f.attribute5%TYPE DEFAULT NULL,
 p_attribute6         per_all_people_f.attribute6%TYPE DEFAULT NULL,
 p_attribute7         per_all_people_f.attribute7%TYPE DEFAULT NULL,
 p_attribute8         per_all_people_f.attribute8%TYPE DEFAULT NULL,
 p_attribute9         per_all_people_f.attribute9%TYPE DEFAULT NULL,
 p_attribute10        per_all_people_f.attribute10%TYPE DEFAULT NULL,
 p_attribute11        per_all_people_f.attribute11%TYPE DEFAULT NULL,
 p_attribute12        per_all_people_f.attribute12%TYPE DEFAULT NULL,
 p_attribute13        per_all_people_f.attribute13%TYPE DEFAULT NULL,
 p_attribute14        per_all_people_f.attribute14%TYPE DEFAULT NULL,
 p_attribute15        per_all_people_f.attribute15%TYPE DEFAULT NULL,
 p_attribute16        per_all_people_f.attribute16%TYPE DEFAULT NULL,
 p_attribute17        per_all_people_f.attribute17%TYPE DEFAULT NULL,
 p_attribute18        per_all_people_f.attribute18%TYPE DEFAULT NULL,
 p_attribute19        per_all_people_f.attribute19%TYPE DEFAULT NULL,
 p_attribute20        per_all_people_f.attribute20%TYPE DEFAULT NULL,
 p_attribute21        per_all_people_f.attribute21%TYPE DEFAULT NULL,
 p_attribute22        per_all_people_f.attribute22%TYPE DEFAULT NULL,
 p_attribute23        per_all_people_f.attribute23%TYPE DEFAULT NULL,
 p_attribute24        per_all_people_f.attribute24%TYPE DEFAULT NULL,
 p_attribute25        per_all_people_f.attribute25%TYPE DEFAULT NULL,
 p_attribute26        per_all_people_f.attribute26%TYPE DEFAULT NULL,
 p_attribute27        per_all_people_f.attribute27%TYPE DEFAULT NULL,
 p_attribute28        per_all_people_f.attribute28%TYPE DEFAULT NULL,
 p_attribute29        per_all_people_f.attribute29%TYPE DEFAULT NULL,
 p_attribute30        per_all_people_f.attribute30%TYPE DEFAULT NULL,
 p_full_name          OUT NOCOPY per_all_people_f.full_name%TYPE ,
 p_order_name         OUT NOCOPY per_all_people_f.order_name%TYPE,
 p_global_name        OUT NOCOPY per_all_people_f.global_name%TYPE,
 p_local_name         OUT NOCOPY per_all_people_f.local_name%TYPE
 ) is
--
   l_proc   CONSTANT   varchar2(80) := g_package||'get_derive_person_names';
--
   l_person_names_rec           hr_person_name.t_nameColumns_Rec;
   l_format_name                hr_name_formats.format_name%TYPE;
   l_legislation_code           varchar2(30);
   l_FULL_NAME_format_mask      hr_name_formats.format_mask%TYPE;
   l_ORDER_NAME_format_mask     hr_name_formats.format_mask%TYPE;
   l_GLOBAL_NAME_format_mask    hr_name_formats.format_mask%TYPE;
   l_LOCAL_NAME_format_mask     hr_name_formats.format_mask%TYPE;
   l_full_name_formatted        varchar2(2000);
   l_order_name_formatted       varchar2(2000);
   l_global_name_formatted      varchar2(2000);
   l_local_name_formatted       varchar2(2000);
   l_pkg_full_name              VARCHAR2(50);
   l_proc_full_name             VARCHAR2(50);
   l_pkg_order_name             VARCHAR2(50);
   l_proc_order_name            VARCHAR2(50);
   l_gen_all_per_cols           VARCHAR2(10);
--
   local_warning exception;
   l_first_char  VARCHAR2(5);
   l_second_char VARCHAR2(5);
   l_ul_check    VARCHAR2(15);
   l_lu_check    VARCHAR2(15);
   l_uu_check    VARCHAR2(15);
   l_ll_check    VARCHAR2(15);
   l_status      varchar(5);
--
   cursor csr_get_format_mask
      (cp_format_name        varchar2
      ,cp_legcode            varchar2
      ,cp_user_format_choice varchar2 ) is
      select nmf.format_mask
        from HR_NAME_FORMATS nmf
       where nmf.format_name = cp_format_name
         and (cp_legcode is not null and nmf.legislation_code = cp_legcode
              or
              cp_legcode is null and nmf.legislation_code is null)
         and nmf.user_format_choice = cp_user_format_choice;
--
begin
   -- ------------------------------------------------------------------------+
   -- Populate record with column values
   -- ------------------------------------------------------------------------+
   l_person_names_rec.first_name         := p_first_name;
   l_person_names_rec.middle_names       := p_middle_names;
   l_person_names_rec.last_name          := p_last_name;
   l_person_names_rec.known_as           := p_known_as;
   l_person_names_rec.title              := p_title;
   l_person_names_rec.suffix             := p_suffix;
   l_person_names_rec.pre_name_adjunct   := p_pre_name_adjunct;
   l_person_names_rec.previous_last_name := p_previous_last_name;
   l_person_names_rec.email_address      := p_email_address;
   l_person_names_rec.employee_number    := p_employee_number;
   l_person_names_rec.applicant_number   := p_applicant_number;
   l_person_names_rec.npw_number         := p_npw_number;
   l_person_names_rec.per_information1   := p_per_information1;
   l_person_names_rec.per_information2   := p_per_information2;
   l_person_names_rec.per_information3   := p_per_information3;
   l_person_names_rec.per_information4   := p_per_information4;
   l_person_names_rec.per_information5   := p_per_information5;
   l_person_names_rec.per_information6   := p_per_information6;
   l_person_names_rec.per_information7   := p_per_information7;
   l_person_names_rec.per_information8   := p_per_information8;
   l_person_names_rec.per_information9   := p_per_information9;
   l_person_names_rec.per_information10  := p_per_information10;
   l_person_names_rec.per_information11  := p_per_information11;
   l_person_names_rec.per_information12  := p_per_information12;
   l_person_names_rec.per_information13  := p_per_information13;
   l_person_names_rec.per_information14  := p_per_information14;
   l_person_names_rec.per_information15  := p_per_information15;
   l_person_names_rec.per_information16  := p_per_information16;
   l_person_names_rec.per_information17  := p_per_information17;
   l_person_names_rec.per_information18  := p_per_information18;
   l_person_names_rec.per_information19  := p_per_information19;
   l_person_names_rec.per_information20  := p_per_information20;
   l_person_names_rec.per_information21  := p_per_information21;
   l_person_names_rec.per_information22  := p_per_information22;
   l_person_names_rec.per_information23  := p_per_information23;
   l_person_names_rec.per_information24  := p_per_information24;
   l_person_names_rec.per_information25  := p_per_information25;
   l_person_names_rec.per_information26  := p_per_information26;
   l_person_names_rec.per_information27  := p_per_information27;
   l_person_names_rec.per_information28  := p_per_information28;
   l_person_names_rec.per_information29  := p_per_information29;
   l_person_names_rec.per_information30  := p_per_information30;
   l_person_names_rec.attribute1         := p_attribute1;
   l_person_names_rec.attribute2         := p_attribute2;
   l_person_names_rec.attribute3         := p_attribute3;
   l_person_names_rec.attribute4         := p_attribute4;
   l_person_names_rec.attribute5         := p_attribute5;
   l_person_names_rec.attribute6         := p_attribute6;
   l_person_names_rec.attribute7         := p_attribute7;
   l_person_names_rec.attribute8         := p_attribute8;
   l_person_names_rec.attribute9         := p_attribute9;
   l_person_names_rec.attribute10        := p_attribute10;
   l_person_names_rec.attribute11        := p_attribute11;
   l_person_names_rec.attribute12        := p_attribute12;
   l_person_names_rec.attribute13        := p_attribute13;
   l_person_names_rec.attribute14        := p_attribute14;
   l_person_names_rec.attribute15        := p_attribute15;
   l_person_names_rec.attribute16        := p_attribute16;
   l_person_names_rec.attribute17        := p_attribute17;
   l_person_names_rec.attribute18        := p_attribute18;
   l_person_names_rec.attribute19        := p_attribute19;
   l_person_names_rec.attribute20        := p_attribute20;
   l_person_names_rec.attribute21        := p_attribute21;
   l_person_names_rec.attribute22        := p_attribute22;
   l_person_names_rec.attribute23        := p_attribute23;
   l_person_names_rec.attribute24        := p_attribute24;
   l_person_names_rec.attribute25        := p_attribute25;
   l_person_names_rec.attribute26        := p_attribute26;
   l_person_names_rec.attribute27        := p_attribute27;
   l_person_names_rec.attribute28        := p_attribute28;
   l_person_names_rec.attribute29        := p_attribute29;
   l_person_names_rec.attribute30        := p_attribute30;
   l_person_names_rec.full_name           := null;


   -- ------------------------------------------------------------------------+
   -- End populate record
   -- ------------------------------------------------------------------------+
   --
   -- Initialize local variables
   --
   l_global_name_formatted    := null;
   l_local_name_formatted     := null;
   l_full_name_formatted      := null;
   l_order_name_formatted     := null;
   l_GLOBAL_NAME_format_mask  := null;
   l_LOCAL_NAME_format_mask   := null;
   l_FULL_NAME_format_mask    := null;
   l_ORDER_NAME_format_mask   := null;
   --
   l_format_name              := p_format_name;
   if p_format_name is null then
      l_gen_all_per_cols := 'Y';
   else
      l_gen_all_per_cols := 'N';
   end if;
   l_legislation_code := hr_api.return_legislation_code(p_business_group_id);
   -- -------------------------------------------------------------------+
   -- Derive FULL_NAME
   -- -------------------------------------------------------------------+
   if l_format_name = g_FULL_NAME or l_gen_all_per_cols = 'Y' then
      --
      open csr_get_format_mask(g_FULL_NAME, l_legislation_code,'L');
      fetch csr_get_format_mask into l_FULL_NAME_format_mask;
      if csr_get_format_mask%NOTFOUND then
         close csr_get_format_mask;
         --
         get_seeded_procedure_name
            (p_format_name       => g_FULL_NAME
            ,p_legislation_code  => l_legislation_code
            ,p_package_name      => l_pkg_full_name
            ,p_procedure_name    => l_proc_full_name);
         --
         if l_pkg_full_name is null then -- use seeded procedure?
            --
            -- seeded procedure does not exist, use seeded format
            --
            open csr_get_format_mask(g_FULL_NAME, null,'L');
            fetch csr_get_format_mask into l_FULL_NAME_format_mask;
            if csr_get_format_mask%NOTFOUND then
               l_FULL_NAME_format_mask := null;
            end if;
            close csr_get_format_mask;
         end if;
      else
         close csr_get_format_mask;
      end if;
      -- -------------------------------------------------------------------+
      -- DERIVE the name
      -- -------------------------------------------------------------------+
      if l_FULL_NAME_format_mask is not null then
         --
         -- replace all tokens in format mask using name column values
         --
         l_full_name_formatted := l_FULL_NAME_format_mask;
         get_formatted_name(p_name_values    => l_person_names_rec
                           ,p_formatted_name => l_full_name_formatted);
         --
         l_full_name_formatted := substr(l_full_name_formatted,1,240);
         --
      elsif l_pkg_full_name is not null then
         -- use seeded procedure to derive name
         derive_name_using_seeded_proc
            (p_format_name       => g_FULL_NAME
            ,p_legislation_code  => l_legislation_code
            ,p_name_column_rec   => l_person_names_rec
            ,p_package_name      => l_pkg_full_name
            ,p_procedure_name    => l_proc_full_name
            ,p_formatted_name    => l_full_name_formatted);
         l_full_name_formatted := rtrim(l_full_name_formatted);
      end if;
      l_person_names_rec.full_name := l_full_name_formatted;
   end if;
   -- -------------------------------------------------------------------+
   -- Derive ORDER_NAME
   -- -------------------------------------------------------------------+
   if l_format_name = g_ORDER_NAME or l_gen_all_per_cols = 'Y' then
      open csr_get_format_mask(g_ORDER_NAME, l_legislation_code,'L');
      fetch csr_get_format_mask into l_ORDER_NAME_format_mask;
      if csr_get_format_mask%NOTFOUND then
         close csr_get_format_mask;
         --
         get_seeded_procedure_name
            (p_format_name       => g_ORDER_NAME
            ,p_legislation_code  => l_legislation_code
            ,p_package_name      => l_pkg_order_name
            ,p_procedure_name    => l_proc_order_name);
         --
         if l_pkg_order_name is null then -- use seeded procedure?
            --
            -- seeded procedure does not exist, use seeded format
            --
            open csr_get_format_mask(g_ORDER_NAME, null,'L');
            fetch csr_get_format_mask into l_ORDER_NAME_format_mask;
            if csr_get_format_mask%NOTFOUND then
               l_ORDER_NAME_format_mask := null;
            end if;
            close csr_get_format_mask;
         end if;
      else
         close csr_get_format_mask;
      end if;
      --  -------------------------------------------------------------------+
      -- Derive Order Name
      --  -------------------------------------------------------------------+
      if l_ORDER_NAME_format_mask is not null then
         --
         -- replace all tokens in format mask using name column values
         --
         l_order_name_formatted := l_ORDER_NAME_format_mask;
         get_formatted_name(p_name_values    => l_person_names_rec
                           ,p_formatted_name => l_order_name_formatted);
         --
         l_order_name_formatted := substr(l_order_name_formatted,1,240);
         --
      elsif l_pkg_order_name is not null then
         -- use seeded procedure to derive name
         derive_name_using_seeded_proc
            (p_format_name       => g_ORDER_NAME
            ,p_legislation_code  => l_legislation_code
            ,p_name_column_rec   => l_person_names_rec
            ,p_package_name      => l_pkg_order_name
            ,p_procedure_name    => l_proc_order_name
            ,p_formatted_name    => l_order_name_formatted);
         l_order_name_formatted := rtrim(l_order_name_formatted);
      end if;
   end if;
   -- -------------------------------------------------------------------+
   -- -------------------------------------------------------------------+
   if l_format_name in (g_DISPLAY_NAME, g_LIST_NAME)
      or l_gen_all_per_cols = 'Y' then
      --
      if l_gen_all_per_cols = 'Y' then
         l_format_name := g_LIST_NAME;
      end if;
      --
      -- Get Global format mask
      --
      open csr_get_format_mask(l_format_name, l_legislation_code,'G');
      fetch csr_get_format_mask into l_GLOBAL_NAME_format_mask;
      if csr_get_format_mask%NOTFOUND then
         close csr_get_format_mask;
         -- look for non legislation specific
         open csr_get_format_mask(l_format_name, null,'G');
         fetch csr_get_format_mask into l_GLOBAL_NAME_format_mask;
         if csr_get_format_mask%NOTFOUND then
            l_GLOBAL_NAME_format_mask := null;
         end if;
         close csr_get_format_mask;
      else
         close csr_get_format_mask;
      end if;
      --
      -- Get Local format mask
      --
      open csr_get_format_mask(l_format_name, l_legislation_code,'L');
      fetch csr_get_format_mask into l_LOCAL_NAME_format_mask;
      if csr_get_format_mask%NOTFOUND then
         close csr_get_format_mask;
         -- look for non legislation specific
         open csr_get_format_mask(l_format_name, null,'L');
         fetch csr_get_format_mask into l_LOCAL_NAME_format_mask;
         if csr_get_format_mask%NOTFOUND then
            l_LOCAL_NAME_format_mask := null;
         end if;
         close csr_get_format_mask;
      else
         close csr_get_format_mask;
      end if;
      -- -------------------------------------------------------------------+
      -- Derive Global and Local Names
      -- -------------------------------------------------------------------+
      if l_GLOBAL_NAME_format_mask is not null then
         --
         -- replace all tokens in format mask using name column values
         --
         l_global_name_formatted := l_GLOBAL_NAME_format_mask;
         get_formatted_name(p_name_values    => l_person_names_rec
                           ,p_formatted_name => l_global_name_formatted);
         --
         l_global_name_formatted := substr(l_global_name_formatted,1,240);
         --
      end if;
      -- -------------------------------------------------------------------+
      if l_LOCAL_NAME_format_mask is not null then
         --
         -- replace all tokens in format mask using name column values
         --
         l_local_name_formatted := l_LOCAL_NAME_format_mask;
         get_formatted_name(p_name_values    => l_person_names_rec
                           ,p_formatted_name => l_local_name_formatted);
         --
         l_local_name_formatted := substr(l_local_name_formatted,1,240);
         --
      end if;
      --
   end if; -- Display/List Names
   -- -------------------------------------------------------------------+
   --
   -- Set OUT parameters
   --
   p_full_name   := l_full_name_formatted;
   p_order_name  := l_order_name_formatted;
   p_global_name := l_global_name_formatted;
   p_local_name  := l_local_name_formatted;
end derive_person_names;
--
end hr_person_name;
--

/
