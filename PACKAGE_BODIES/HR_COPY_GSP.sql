--------------------------------------------------------
--  DDL for Package Body HR_COPY_GSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COPY_GSP" as
/* $Header: hrcpygsp.pkb 120.0 2005/05/30 23:24:39 appldev noship $ */
--
procedure template (p_template_id       in number,
                    p_new_name          in varchar2,
                    p_business_group_id in number,
                    p_copy_ru           in varchar2,
                    p_copy_rv           in varchar2,
                    p_copy_kt           in varchar2) is
--
cursor csr_itu is
  select item_type_id,
         item_type_usage_id,
         sequence_number,
         name
  from   hr_summary_item_type_usage
  where  template_id = p_template_id
  order by sequence_number;
--
cursor csr_ktu (p_itu_id in number) is
  select valid_key_type_id
  from   hr_summary_key_type_usage
  where  item_type_usage_id = p_itu_id;
--
cursor csr_ru (p_itu_id in number) is
  select ru.restriction_type,
         ru.restriction_usage_id,
         ru.valid_restriction_id
  from   hr_summary_restriction_usage ru
  where  ru.item_type_usage_id = p_itu_id;
--
cursor csr_rv (p_id in number) is
  select value
  from   hr_summary_restriction_value
  where  restriction_usage_id = p_id;
--
l_template_id           number;
l_itu_id                number;
l_restriction_usage_id  number;
l_object_version_number number;
l_id_value              number;
--
begin
--
hr_utility.set_location('Entering: copy_gsp.template', 10);
--
hr_summary_api.CREATE_TEMPLATE (p_template_id           => l_template_id
                               ,p_business_group_id     => p_business_group_id
                               ,p_object_version_number => l_object_version_number
                               ,p_seeded_data           => 'N'
                               ,p_name                  => p_new_name);
--
for r_itu in csr_itu loop
    --
    hr_summary_api.CREATE_ITEM_TYPE_USAGE (p_item_type_usage_id    => l_itu_id
                                          ,p_business_group_id     => p_business_group_id
                                          ,p_object_version_number => l_object_version_number
                                          ,p_sequence_number       => r_itu.sequence_number
                                          ,p_name                  => r_itu.name
                                          ,p_seeded_data           => 'N'
                                          ,p_template_id           => l_template_id
                                          ,p_item_type_id          => r_itu.item_type_id);
    --
    if p_copy_kt = 'Y' then
       for r_ktu in csr_ktu(r_itu.item_type_usage_id) loop
           hr_summary_api.CREATE_KEY_TYPE_USAGE (p_key_type_usage_id     => l_id_value
                                                ,p_business_group_id     => p_business_group_id
                                                ,p_object_version_number => l_object_version_number
                                                ,p_seeded_data           => 'N'
                                                ,p_item_type_usage_id    => l_itu_id
                                                ,p_valid_key_type_id     => r_ktu.valid_key_type_id);
       end loop;
    end if;
    --
    if p_copy_ru = 'Y' then
       for r_ru in csr_ru(r_itu.item_type_usage_id) loop
           hr_summary_api.CREATE_RESTRICTION_USAGE (p_restriction_usage_id  => l_restriction_usage_id
                                                   ,p_business_group_id     => p_business_group_id
                                                   ,p_object_version_number => l_object_version_number
                                                   ,p_seeded_data           => 'N'
                                                   ,p_item_type_usage_id    => l_itu_id
                                                   ,p_valid_restriction_id  => r_ru.valid_restriction_id
                                                   ,p_restriction_type      => r_ru.restriction_type);
           --
           if p_copy_rv = 'Y' then
              for r_rv in csr_rv(r_ru.restriction_usage_id) loop
                  hr_summary_api.CREATE_RESTRICTION_VALUE (p_restriction_value_id  => l_id_value
                                                          ,p_business_group_id     => p_business_group_id
                                                          ,p_object_version_number => l_object_version_number
                                                          ,p_seeded_data           => 'N'
                                                          ,p_restriction_usage_id  => l_restriction_usage_id
                                                          ,p_value                 => r_rv.value);
              end loop;
           end if;
       end loop;
    end if;
    --
end loop;
--
hr_utility.set_location('Leaving: copy_gsp.template', 20);
--
commit;
--
end template;
--
procedure itu (p_itu_id            in number,
               p_template_id       in number,
               p_name              in varchar2,
               p_business_group_id in number,
               p_copy_ru           in varchar2,
               p_copy_rv           in varchar2,
               p_copy_kt           in varchar2) is
--
cursor csr_itu is
  select item_type_id
  from   hr_summary_item_type_usage
  where  item_type_usage_id = p_itu_id;
--
cursor csr_seq is
  select nvl(max(sequence_number),0)+1
  from   hr_summary_item_type_usage
  where  template_id = p_template_id;
--
cursor csr_ktu (p_itu_id in number) is
  select valid_key_type_id
  from   hr_summary_key_type_usage
  where  item_type_usage_id = p_itu_id;
--
cursor csr_ru (p_itu_id in number) is
  select ru.restriction_type,
         ru.restriction_usage_id,
         ru.valid_restriction_id
  from   hr_summary_restriction_usage ru
  where  ru.item_type_usage_id = p_itu_id;
--
cursor csr_rv (p_id in number) is
  select value
  from   hr_summary_restriction_value
  where  restriction_usage_id = p_id;
--
l_item_type_id          number;
l_sequence_number       number;
l_itu_id                number;
l_restriction_usage_id  number;
l_object_version_number number;
l_id_value              number;
--
begin
--
hr_utility.set_location('Entering: copy_gsp.itu', 10);
--
open csr_itu;
fetch csr_itu into l_item_type_id;
close csr_itu;
--
open csr_seq;
fetch csr_seq into l_sequence_number;
close csr_seq;
--
hr_summary_api.CREATE_ITEM_TYPE_USAGE (p_item_type_usage_id    => l_itu_id
                                      ,p_business_group_id     => p_business_group_id
                                      ,p_object_version_number => l_object_version_number
                                      ,p_sequence_number       => l_sequence_number
                                      ,p_name                  => p_name
                                      ,p_seeded_data           => 'N'
                                      ,p_template_id           => p_template_id
                                      ,p_item_type_id          => l_item_type_id);
--
if p_copy_kt = 'Y' then
   for r_ktu in csr_ktu(p_itu_id) loop
       hr_summary_api.CREATE_KEY_TYPE_USAGE (p_key_type_usage_id     => l_id_value
                                            ,p_business_group_id     => p_business_group_id
                                            ,p_object_version_number => l_object_version_number
                                            ,p_seeded_data           => 'N'
                                            ,p_item_type_usage_id    => l_itu_id
                                            ,p_valid_key_type_id     => r_ktu.valid_key_type_id);
   end loop;
end if;
--
if p_copy_ru = 'Y' then
   for r_ru in csr_ru(p_itu_id) loop
       hr_summary_api.CREATE_RESTRICTION_USAGE (p_restriction_usage_id  => l_restriction_usage_id
                                               ,p_business_group_id     => p_business_group_id
                                               ,p_object_version_number => l_object_version_number
                                               ,p_seeded_data           => 'N'
                                               ,p_item_type_usage_id    => l_itu_id
                                               ,p_valid_restriction_id  => r_ru.valid_restriction_id
                                               ,p_restriction_type      => r_ru.restriction_type);
       --
       if p_copy_rv = 'Y' then
          for r_rv in csr_rv(r_ru.restriction_usage_id) loop
              hr_summary_api.CREATE_RESTRICTION_VALUE (p_restriction_value_id  => l_id_value
                                                      ,p_business_group_id     => p_business_group_id
                                                      ,p_object_version_number => l_object_version_number
                                                      ,p_seeded_data           => 'N'
                                                      ,p_restriction_usage_id  => l_restriction_usage_id
                                                      ,p_value                 => r_rv.value);
          end loop;
       end if;
       --
   end loop;
end if;
--
commit;
--
hr_utility.set_location('Leaving: copy_gsp.itu', 10);
--
end itu;
--
procedure item_type (p_item_type_id      in number,
                     p_new_name          in varchar2,
                     p_business_group_id in number,
                     p_copy_vr           in varchar2,
                     p_copy_vkt          in varchar2) is
--
cursor csr_it is
  select name,
         title,
         units,
         datatype,
         count_clause1,
         count_clause2,
         where_clause
  from   hr_summary_item_type
  where  item_type_id = p_item_type_id;
--
cursor csr_vr is
  select restriction_type_id
  from   hr_summary_valid_restriction
  where  item_type_id = p_item_type_id;
--
cursor csr_vkt is
  select key_type_id
  from   hr_summary_valid_key_type
  where  item_type_id = p_item_type_id;
--
r_it                    csr_it%rowtype;
l_item_type_id          number;
l_id_value              number;
l_object_version_number number;
--
begin
--
hr_utility.set_location('Entering: copy_gsp.item_type', 10);
--
open csr_it;
fetch csr_it into r_it;
close csr_it;
--
hr_summary_api.CREATE_ITEM_TYPE (p_item_type_id          => l_item_type_id
                                ,p_business_group_id     => p_business_group_id
                                ,p_object_version_number => l_object_version_number
                                ,p_name                  => p_new_name
                                ,p_units                 => r_it.units
                                ,p_datatype              => r_it.datatype
                                ,p_count_clause1         => r_it.count_clause1
                                ,p_seeded_data           => 'N'
                                ,p_count_clause2         => r_it.count_clause2
                                ,p_where_clause          => r_it.where_clause);
--
if p_copy_vr = 'Y' then
   for r_vr in csr_vr loop
       hr_summary_api.CREATE_VALID_RESTRICTION (p_valid_restriction_id  => l_id_value
                                               ,p_business_group_id     => p_business_group_id
                                               ,p_object_version_number => l_object_version_number
                                               ,p_seeded_data           => 'N'
                                               ,p_item_type_id          => l_item_type_id
                                               ,p_restriction_type_id   => r_vr.restriction_type_id);
   end loop;
end if;
--
if p_copy_vkt = 'Y' then
   for r_vkt in csr_vkt loop
       hr_summary_api.CREATE_VALID_KEY_TYPE (p_valid_key_type_id     => l_id_value
                                            ,p_business_group_id     => p_business_group_id
                                            ,p_object_version_number => l_object_version_number
                                            ,p_seeded_data           => 'N'
                                            ,p_item_type_id          => l_item_type_id
                                            ,p_key_type_id           => r_vkt.key_type_id);
   end loop;
end if;
--
commit;
--
hr_utility.set_location('Leaving: copy_gsp.item_type', 20);
--
end item_type;
--
end hr_copy_gsp;

/
