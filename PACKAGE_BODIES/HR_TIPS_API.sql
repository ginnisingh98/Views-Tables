--------------------------------------------------------
--  DDL for Package Body HR_TIPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TIPS_API" as
/* $Header: hrtipapi.pkb 120.2 2005/08/04 21:34:39 raranjan noship $ */
--
--
-- private function
--
function isR11i(p_application_id in number default 800)
  RETURN BOOLEAN is
--
cursor csr_get_prod_verison is
select PRODUCT_VERSION
from FND_PRODUCT_INSTALLATIONS
where APPLICATION_ID = p_application_id;
--
l_version    FND_PRODUCT_INSTALLATIONS.PRODUCT_VERSION%TYPE;
--
begin
  open csr_get_prod_verison;
  fetch csr_get_prod_verison into l_version;
  close csr_get_prod_verison;
  l_version := substr(l_version,1,4);
  l_version := replace(l_version,'.');
  if to_number(l_version) >= 115 then
    return true;
  else
    return false;
  end if;

end isR11i;

function getTip(p_screen             varchar2
               ,p_field              varchar2
               ,p_language           varchar2
               ,p_business_group_id  number      default null
               ,p_default            boolean     default true
               ) return varchar2 is
--

l_screen              hr_tips.screen%type default null;
l_field               hr_tips.field%type default null;
l_lang_code           hr_tips.language_code%type default null;
--

-- For performance improvement:
-- We assume that the database attributes, screen, field and language_code
-- are loaded to the database in upper case.  Thus, we can use the index.
cursor csr_get_tip(p_bg NUMBER) is
select t.text
  from hr_tips t
 where t.screen        = l_screen
   and t.field         = l_field
   and t.language_code = l_lang_code
   and t.business_group_id    = p_bg;
--
cursor csr_get_tip_default is
select t.text
  from hr_tips t
 where t.screen        = l_screen
   and t.field         = l_field
   and t.language_code = l_lang_code
   and t.business_group_id is null;
--
l_text varchar2 (32000);
--
begin
   -- Convert the input parms to upper first for performance improvement.
   l_screen := upper(p_screen);
   l_field  := upper(p_field);
   l_lang_code := upper(p_language);

   if p_business_group_id is null then
      open csr_get_tip_default;
      fetch csr_get_tip_default into l_text;
      if csr_get_tip_default%notfound then
         close csr_get_tip_default;
         return null;
      end if;
      return l_text;
   else
      open csr_get_tip(p_business_group_id);
      fetch csr_get_tip into l_text;
      if csr_get_tip%notfound then
         close csr_get_tip;
         -- if p_default is set to true, and the business group that was
         -- passed in was not null then return the default tip (bg = null)
         if p_default AND (p_business_group_id is not null) then
            open csr_get_tip_default;
            fetch csr_get_tip_default into l_text;
            if csr_get_tip_default%notfound then
               close csr_get_tip_default;
               return null;
            end if;
         else
            return null;
         end if;
         close csr_get_tip_default;
         return l_text;
      end if;
      close csr_get_tip;
   end if;

   return l_text;
end;
--
function getAllTips(p_screen             varchar2
                   ,p_language           varchar2
                   ,p_business_group_id  number      default null
                   ,p_default            boolean     default true
                   )  return TipRecTable is
--
l_screen              hr_tips.screen%type default null;
l_lang_code           hr_tips.language_code%type default null;
--

-- For performance improvement:
-- We assume that the database attributes, screen and language_code
-- are loaded to the database in upper case.  Thus, we can use the index.

cursor csr_get_all_tips(p_bg NUMBER) is
select t.field, t.text
  from hr_tips t
 where t.screen        = l_screen
   and t.language_code = l_lang_code
   and t.business_group_id    = p_bg
   and t.field NOT IN ('DISCLAIMER', 'INSTRUCTIONS');
--
cursor csr_get_all_tips_default(p_bg NUMBER) is
select t.field, t.text
  from hr_tips t
 where t.screen        = l_screen
   and t.language_code = l_lang_code
   and t.field NOT IN ('DISCLAIMER', 'INSTRUCTIONS')
   and ((t.business_group_id is null and not exists (select 'Y'
                                    from hr_tips
                                   where screen        = l_screen
                                    and language_code = l_lang_code
                                    and business_group_id    = p_bg
                                    and field = t.field))
   or t.business_group_id = p_bg);
--
l_tip_rec   TipRecTable;

v_tipData   csr_get_all_tips_default%ROWTYPE;
l_count     number;
--
begin

   -- Convert the input parms to upper first for performance improvement.
   l_screen := upper(p_screen);
   l_lang_code := upper(p_language);


   if p_default or p_business_group_id is null then
      -- fill table array with tips
      l_count := 1;
      for v_tipData in csr_get_all_tips_default(p_business_group_id) loop
         l_tip_rec(l_count) := v_tipData;
         l_count := l_count + 1;
      end loop;

      return l_tip_rec;
   else
      -- fill table array with tips
      l_count := 1;
      for v_tipData in csr_get_all_tips(p_business_group_id) loop
         l_tip_rec(l_count) := v_tipData;
         l_count := l_count + 1;
      end loop;

      return l_tip_rec;
   end if;

end;
--
function getInstruction(p_screen              varchar2
                       ,p_language            varchar2
                       ,p_business_group_id   number    default null
                       ,p_instruction_name    varchar2  default 'INSTRUCTIONS'
                       ,p_default             boolean   default true
                       ) return varchar2 is
--
l_screen              hr_tips.screen%type default null;
l_lang_code           hr_tips.language_code%type default null;
l_instruction_name    hr_tips.field%type default null;
--

-- For performance improvement:
-- We assume that the database attributes, screen,field and language_code
-- are loaded to the database in upper case.  Thus, we can use the index.

  cursor csr_get_instructions(p_default_bg NUMBER) IS
  select t.text
    from hr_tips t
   where t.screen        = l_screen
     and t.field         = l_instruction_name
     and t.language_code = l_lang_code
     and (NVL(t.business_group_id,-1) = NVL(p_business_group_id,-1)
         OR NVL(t.business_group_id,-1) = NVL(p_default_bg,-1))
     order by t.business_group_id;
  --
  l_text varchar2 (32000);
  l_default_business_group_id  NUMBER;
  l_r11i boolean;
  --
begin

   -- Convert the input parms to upper first for performance improvement.
   l_screen := upper(p_screen);
   l_lang_code := upper(p_language);
   l_instruction_name := upper(p_instruction_name);

   l_r11i := isR11i;

   IF p_default THEN
     l_default_business_group_id := null;
   ELSE
     l_default_business_group_id := p_business_group_id;
   END IF;

   open csr_get_instructions(l_default_business_group_id);
   fetch csr_get_instructions into l_text;
   close csr_get_instructions;
   if l_r11i then
     l_text := replace(l_text, '/OA_MEDIA/US/','/OA_MEDIA/');
   end if;
   IF substr(l_text, 1, 4) = '<BR>' THEN
     l_text := substr(l_text, 5);
   END IF;
   IF substr(l_text, -4, 4) = '<BR>' THEN
     l_text := substr(l_text, 1, (length(l_text) - 4));
   END IF;
   return l_text;

end;
--
function getDisclaimer(p_screen               varchar2
                      ,p_language             varchar2
                      ,p_business_group_id    number    default null
                      ,p_default              boolean   default true
                      ) return varchar2 is
--
--
l_screen              hr_tips.screen%type default null;
l_lang_code           hr_tips.language_code%type default null;
--
-- For performance improvement:
-- We assume that the database attributes, screen and language_code
-- are loaded to the database in upper case.  Thus, we can use the index.

  cursor csr_get_disclaimer(p_default_bg NUMBER) is
  select t.text
    from hr_tips t
   where t.screen        = l_screen
     and t.field         = 'DISCLAIMER'
     and t.language_code = l_lang_code
     and (NVL(t.business_group_id,0) = NVL(p_business_group_id,0)
          OR NVL(t.business_group_id,0) = NVL(p_default_bg,0));
--
  l_text varchar2 (32000);
  l_default_business_group_id  NUMBER;

--
begin

   -- Convert the input parms to upper first for performance improvement.
   l_screen := upper(p_screen);
   l_lang_code := upper(p_language);

  IF p_default THEN
    l_default_business_group_id := null;
  ELSE
    l_default_business_group_id := p_business_group_id;
  END IF;
  open csr_get_disclaimer(l_default_business_group_id);
  fetch csr_get_disclaimer into l_text;
  close csr_get_disclaimer;
  IF substr(l_text, 1, 4) = '<BR>' THEN
    l_text := substr(l_text, 5);
  END IF;
  IF substr(l_text, -4, 4) = '<BR>' THEN
    l_text := substr(l_text, 1, (length(l_text) - 4));
  END IF;
  return l_text;

end;
--
end hr_tips_api;

/
