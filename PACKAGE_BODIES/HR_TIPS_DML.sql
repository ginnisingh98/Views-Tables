--------------------------------------------------------
--  DDL for Package Body HR_TIPS_DML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TIPS_DML" as
/* $Header: hrtipdml.pkb 115.1 99/10/05 17:58:53 porting ship $ */
--
procedure addTip(p_filename            varchar2
                ,p_screen              varchar2
                ,p_field               varchar2
                ,p_language            varchar2
                ,p_business_group_id   number      default null
                ,p_text                long
                ,p_mode                varchar2
      ) is
--
cursor csr_exists_tip is
select 'Y'
  from hr_tips t
 where upper(t.screen)             = upper(p_screen)
   and upper(t.field)              = upper(p_field)
   and upper(t.language_code)      = upper(p_language)
   and nvl(t.business_group_id, 0) = nvl(p_business_group_id, 0);
--
l_exists varchar2(1);
--
begin
--
   open csr_exists_tip;
   fetch csr_exists_tip into l_exists;
   --

   if p_mode = 'UPDATE' then
      -- if the tip already exists in the database then update it
      if csr_exists_tip%found then
         -- update it
         update hr_tips
            set text                      = p_text
          where upper(screen)             = upper(p_screen)
            and upper(field)              = upper(p_field)
            and upper(language_code)      = upper(p_language)
            and nvl(business_group_id, 0) = nvl(p_business_group_id, 0);
      else
         -- insert it
         insert into hr_tips
                     (tip_id
                     ,filename
                     ,screen
                     ,field
                     ,language_code
                     ,business_group_id
                     ,text
                     ,enabled_flag
                     )
                     values
                     (hr_tips_s.nextval
                     ,upper(p_filename)
                     ,upper(p_screen)
                     ,upper(p_field)
                     ,upper(p_language)
                     ,p_business_group_id
                     ,p_text
                     ,'Y'
                     );
      end if;
   elsif (p_mode = 'NOUPDATE' or p_mode = 'DELETE') then
   null;
      -- only insert tips into the database if they are not already there
      if csr_exists_tip%notfound then
         -- insert it
         insert into hr_tips
                     (tip_id
                     ,filename
                     ,screen
                     ,field
                     ,language_code
                     ,business_group_id
                     ,text
                     ,enabled_flag
                     )
                     values
                     (hr_tips_s.nextval
                     ,upper(p_filename)
                     ,upper(p_screen)
                     ,upper(p_field)
                     ,upper(p_language)
                     ,p_business_group_id
                     ,p_text
                     ,'Y'
                     );
      end if;
   end if;
end;
--
procedure clearTips(p_filename           varchar2
                   ,p_language           varchar2
                   ,p_business_group_id  number    default null) is
begin
   -- clear out the tips for the specified filename, language and
   -- business group id
   delete from hr_tips
         where upper(filename)           = upper(p_filename)
           and upper(language_code)      = upper(p_language)
           and nvl(business_group_id, 0) = nvl(p_business_group_id, 0);
end;
--
--
end hr_tips_dml;

/
