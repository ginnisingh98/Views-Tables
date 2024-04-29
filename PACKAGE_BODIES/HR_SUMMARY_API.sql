--------------------------------------------------------
--  DDL for Package Body HR_SUMMARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SUMMARY_API" as
/* $Header: hrsumapi.pkb 115.5 2002/11/26 10:30:14 sfmorris noship $ */
--
g_package varchar2(20) := 'hr_summary_api.';
update_allowed exception;
--
-----------------
procedure lck (p_id_value                  in     number
              ,p_object_version_number     in     number ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := 'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  per_bil_shd.lck
    (
      p_id_value               => p_id_value
     ,p_object_version_number  => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
-----------------
procedure row_data (p_business_group_id in number,
                    p_type              in varchar2,
                    p_text_value1       in varchar2,
                    p_text_value2       in varchar2,
                    p_fk_value1         in number,
                    p_fk_value2         in number,
                    l_id_value          out nocopy number,
                    l_ovn               out nocopy number) is
--
cursor csr_exists is
  select id_value,
         object_version_number
  from   hr_summary
  where  (type = p_type
          and p_type in ('TEMPLATE','ITEM_TYPE','KEY_TYPE','RESTRICTION_TYPE')
          and text_value1 = p_text_value1
          and business_group_id = p_business_group_id
         )
  or
         (type = p_type
          and p_type IN ('RESTRICTION_USAGE','VALID_KEY_TYPE','KEY_TYPE_USAGE','VALID_RESTRICTION')
          and fk_value1 = p_fk_value1
          and fk_value2 = p_fk_value2
          and business_group_id = p_business_group_id
         )
  or     (type = p_type
          and p_type = 'ITEM_TYPE_USAGE'
          and fk_value1 = p_fk_value1
          and business_group_id = p_business_group_id
          and text_value1 = p_text_value1
         )
  or     (type = p_type
          and p_type = 'PROCESS_RUN'
          and text_value2 = p_text_value2
          and text_value1 = p_text_value1
          and business_group_id = p_business_group_id
         )
  or     (type = p_type
          and p_type = 'RESTRICTION_VALUE'
          and fk_value1 = p_fk_value1
          and text_value1 = p_text_value1
          and business_group_id = p_business_group_id
         );
--
begin
--
hr_utility.set_location('Entering: hr_summary_api.row_data', 10);
--
open csr_exists;
fetch csr_exists into l_id_value,
                      l_ovn;
if csr_exists%notfound then
   l_id_value := 0;
   l_ovn := 0;
end if;
close csr_exists;
--
hr_utility.set_location('Leaving: hr_summary_api.row_data', 20);
--
end row_data;
-----------------
function get_id (p_name in varchar2,
                 p_type in varchar2,
                 p_business_group_id in number) return number is
--
l_id number;
--
cursor csr_id is
  select id_value
  from   hr_summary
  where  text_value1 = p_name
  and    type        = p_type
  and    business_group_id = p_business_group_id;
--
begin
  --
  open csr_id;
  fetch csr_id into l_id;
  close csr_id;
  --
  return nvl(l_id,0);
  --
end get_id;
-----------------
function get_itu_id (p_template_name     in varchar2
                    ,p_item_type_name    in varchar2
                    ,p_itu_name          in varchar2
                    ,p_business_group_id in number) return number is
--
l_id number;
--
cursor csr_id is
  select itu.id_value
  from   hr_summary itu,
         hr_summary t,
         hr_summary it
  where  it.id_value = itu.fk_value2
  and    t.id_value = itu.fk_value1
  and    itu.text_value1 = p_itu_name
  and    it.business_group_id = p_business_group_id
  and    it.text_value1 = p_item_type_name
  and    it.type = 'ITEM_TYPE'
  and    t.business_group_id  = p_business_group_id
  and    t.text_value1 = p_template_name
  and    t.type = 'TEMPLATE';
--
begin
  --
  open csr_id;
  fetch csr_id into l_id;
  close csr_id;
  --
  return nvl(l_id,0);
  --
end get_itu_id;
-----------------
function get_itu_id (p_template_name     in varchar2
                    ,p_sequence_number   in number
                    ,p_business_group_id in number) return number is
--
l_id number;
--
cursor csr_id is
  select itu.id_value
  from   hr_summary itu,
         hr_summary t
  where  t.id_value = itu.fk_value1
  and    itu.num_value1 = p_sequence_number
  and    itu.type = 'ITEM_TYPE_USAGE'
  and    t.business_group_id  = p_business_group_id
  and    t.text_value1 = p_template_name
  and    t.type = 'TEMPLATE';
--
begin
  --
  open csr_id;
  fetch csr_id into l_id;
  close csr_id;
  --
  return nvl(l_id,0);
  --
end get_itu_id;
---------------
function get_vkt_id (p_key_type_name     in varchar2
                    ,p_item_type_name    in varchar2
                    ,p_business_group_id in number) return number is
--
l_id number;
--
cursor csr_id is
  select vkt.id_value
  from   hr_summary  vkt,
         hr_summary  kt,
         hr_summary  it
  where  kt.id_value = vkt.fk_value2
  and    it.id_value = vkt.fk_value1
  and    kt.business_group_id = p_business_group_id
  and    kt.text_value1 = p_key_type_name
  and    kt.type = 'KEY_TYPE'
  and    it.business_group_id = p_business_group_id
  and    it.text_value1 = p_item_type_name
  and    it.type = 'ITEM_TYPE';
--
begin
  --
  open csr_id;
  fetch csr_id into l_id;
  close csr_id;
  --
  return nvl(l_id,0);
  --
end get_vkt_id;
-----------------
function get_ru_id (p_restriction_name  in varchar2
                   ,p_item_type_name    in varchar2
                   ,p_business_group_id in number) return number is
l_id number;
cursor csr_id is
  select vr.id_value
  from   hr_summary vr,
         hr_summary it,
         hr_summary rt
  where  it.id_value = vr.fk_value1
  and    vr.fk_value2 = rt.id_value
  and    it.business_group_id = p_business_group_id
  and    it.type = 'ITEM_TYPE'
  and    it.text_value1 = p_item_type_name
  and    rt.business_group_id = p_business_group_id
  and    rt.type = 'RESTRICTION_TYPE'
  and    rt.text_value1 = p_restriction_name;
--
begin
  --
  open csr_id;
  fetch csr_id into l_id;
  close csr_id;
  --
  return nvl(l_id,0);
  --
end get_ru_id;
-----------------
function get_rv_id (p_template          in varchar2
                   ,p_item              in varchar2
                   ,p_restriction       in varchar2
                   ,p_itu_name          in varchar2
                   ,p_business_group_id in number) return number is
l_id number;
cursor csr_id is
  select restriction_usage_id
  from   hr_summary_restriction_usage
  where  item_type_usage_id   = hr_summary_api.get_itu_id(p_template,p_item,p_itu_name,p_business_group_id)
  and    valid_restriction_id = hr_summary_api.get_ru_id(p_restriction,p_item,p_business_group_id)
  and    business_group_id = p_business_group_id;
--
begin
  --
  open csr_id;
  fetch csr_id into l_id;
  close csr_id;
  --
  return nvl(l_id,0);
  --
end get_rv_id;
-----------------
function get_rv_id (p_template          in varchar2
                   ,p_item              in varchar2
                   ,p_restriction       in varchar2
                   ,p_itu_seq_num       in number
                   ,p_business_group_id in number) return number is
l_id number;
cursor csr_id is
  select restriction_usage_id
  from   hr_summary_restriction_usage
  where  item_type_usage_id   = hr_summary_api.get_itu_id(p_template,p_itu_seq_num,p_business_group_id)
  and    valid_restriction_id = hr_summary_api.get_ru_id(p_restriction,p_item,p_business_group_id)
  and    business_group_id = p_business_group_id;
--
begin
  --
  open csr_id;
  fetch csr_id into l_id;
  close csr_id;
  --
  return nvl(l_id,0);
  --
end get_rv_id;
-----------------
procedure create_item_type (p_item_type_id           out nocopy number
                           ,p_business_group_id      in number
                           ,p_object_version_number  out nocopy number
                           ,p_name                   in varchar2
                           ,p_units                  in varchar2
                           ,p_datatype               in varchar2
                           ,p_count_clause1          in varchar2
                           ,p_count_clause2          in varchar2
                           ,p_where_clause           in varchar2
                           ,p_seeded_data            in varchar2) is
--
l_id  number := 0;
l_ovn number := 0;
--
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_item_type', 10);
--
row_data (p_business_group_id => p_business_group_id
         ,p_type              => 'ITEM_TYPE'
         ,p_text_value1       => p_name
         ,l_id_value          => l_id
         ,l_ovn               => l_ovn);
--
if l_id <> 0 and p_seeded_data = 'Y' then
   per_bil_upd.upd(p_type                  => 'ITEM_TYPE'
                  ,p_id_value              => l_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_ovn
                  ,p_text_value1           => p_name
                  ,p_text_value2           => p_units
                  ,p_text_value3           => p_datatype
                  ,p_text_value4           => p_count_clause1
                  ,p_text_value5           => p_count_clause2
                  ,p_text_value6           => p_where_clause
                  ,p_text_value7           => p_seeded_data);
else
   /* call row handler package with correct parameters */
   per_bil_ins.ins(p_type                  => 'ITEM_TYPE'
                  ,p_id_value              => p_item_type_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => p_object_version_number
                  ,p_text_value1           => p_name
                  ,p_text_value2           => p_units
                  ,p_text_value3           => p_datatype
                  ,p_text_value4           => p_count_clause1
                  ,p_text_value5           => p_count_clause2
                  ,p_text_value6           => p_where_clause
                  ,p_text_value7           => p_seeded_data);
end if;
--
hr_utility.set_location('Leaving: hr_summary_api.create_item_type', 20);
--
end create_item_type;
-----------------
procedure create_key_type  (p_key_type_id           out nocopy number
                           ,p_business_group_id     in  number
                           ,p_object_version_number out nocopy number
                           ,p_name                  in varchar2
                           ,p_key_function          in varchar2
                           ,p_seeded_data           in varchar2 ) is
--
l_id  number := 0;
l_ovn number := 0;
--
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_key_type'||p_seeded_data, 10);
--
row_data (p_business_group_id => p_business_group_id
         ,p_type              => 'KEY_TYPE'
         ,p_text_value1       => p_name
         ,l_id_value          => l_id
         ,l_ovn               => l_ovn);
--
if l_id <> 0 and p_seeded_data = 'Y' then
   per_bil_upd.upd(p_type                  => 'KEY_TYPE'
                  ,p_id_value              => l_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_ovn
                  ,p_text_value1           => p_name
                  ,p_text_value6           => p_key_function
                  ,p_text_value7           => p_seeded_data);
else
   /* call row handler package with correct parameters */
   per_bil_ins.ins(p_type                  => 'KEY_TYPE'
                  ,p_id_value              => p_key_type_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => p_object_version_number
                  ,p_text_value1           => p_name
                  ,p_text_value6           => p_key_function
                  ,p_text_value7           => p_seeded_data);
end if;
--
hr_utility.set_location('Leaving: hr_summary_api.create_key_type'||p_seeded_data, 20);
--
end create_key_type;
-----------------
procedure create_key_value (p_key_value_id          out  nocopy number
                           ,p_business_group_id     in number
                           ,p_object_version_number out  nocopy number
                           ,p_key_type_id           in number
                           ,p_item_value_id         in number
                           ,p_name                  in varchar2 ) is
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_key_value', 10);
--
/* call row handler package with correct parameters */
per_bil_ins.ins(p_type                  => 'KEY_VALUE'
               ,p_id_value              => p_key_value_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_fk_value1             => p_key_type_id
               ,p_fk_value2             => p_item_value_id
               ,p_text_value1           => p_name);
--
hr_utility.set_location('Leaving: hr_summary_api.create_key_value', 20);
--
end create_key_value;
-----------------
procedure create_item_value (p_item_value_id          out  nocopy number
                            ,p_business_group_id      in number
                            ,p_object_version_number  out  nocopy number
                            ,p_process_run_id         in number
                            ,p_item_type_usage_id     in number
                            ,p_textvalue              in varchar2
                            ,p_numvalue1              in number
                            ,p_numvalue2              in number
                            ,p_datevalue              in date ) is
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_item_value', 10);
--
/* call row handler package with correct parameters */
per_bil_ins.ins(p_type                  => 'ITEM_VALUE'
               ,p_id_value              => p_item_value_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_fk_value1             => p_process_run_id
               ,p_fk_value2             => p_item_type_usage_id
               ,p_text_value1           => p_textvalue
               ,p_num_value1            => p_numvalue1
               ,p_num_value2            => p_numvalue2
               ,p_date_value1           => p_datevalue);
--
hr_utility.set_location('Leaving: hr_summary_api.create_item_value', 20);
--
end create_item_value;
-----------------
procedure create_valid_restriction (p_valid_restriction_id  out nocopy number
                                   ,p_business_group_id     in number
                                   ,p_object_version_number out nocopy number
                                   ,p_item_type_id          in number
                                   ,p_restriction_type_id   in number
                                   ,p_seeded_data           in varchar2) is
--
l_id  number := 0;
l_ovn number := 0;
--
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_valid_restriction', 10);
--
row_data (p_business_group_id => p_business_group_id
         ,p_type              => 'VALID_RESTRICTION'
         ,p_fk_value1         => p_item_type_id
         ,p_fk_value2         => p_restriction_type_id
         ,l_id_value          => l_id
         ,l_ovn               => l_ovn);
--
if l_id <> 0 and p_seeded_data = 'Y' then
   per_bil_upd.upd(p_type                  => 'VALID_RESTRICTION'
                  ,p_id_value              => l_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_ovn
                  ,p_fk_value1             => p_item_type_id
                  ,p_fk_value2             => p_restriction_type_id
                  ,p_text_value7           => p_seeded_data);
else
   /* call row handler package with correct parameters */
   per_bil_ins.ins(p_type                  => 'VALID_RESTRICTION'
                  ,p_id_value              => p_valid_restriction_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => p_object_version_number
                  ,p_fk_value1             => p_item_type_id
                  ,p_fk_value2             => p_restriction_type_id
                  ,p_text_value7           => p_seeded_data);
end if;
--
hr_utility.set_location('Leaving: hr_summary_api.create_valid_restriction', 20);
--
end create_valid_restriction;
-----------------
procedure create_restriction_type  (p_restriction_type_id   out  nocopy number
                                   ,p_business_group_id     in number
                                   ,p_object_version_number out  nocopy number
                                   ,p_name                  in varchar2
                                   ,p_data_type             in varchar2
                                   ,p_restriction_clause    in varchar2
                                   ,p_restriction_sql       in varchar2
                                   ,p_seeded_data           in varchar2) is
--
l_id  number := 0;
l_ovn number := 0;
--
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_restriction_type', 10);
--
row_data (p_business_group_id => p_business_group_id
         ,p_type              => 'RESTRICTION_TYPE'
         ,p_text_value1       => p_name
         ,l_id_value          => l_id
         ,l_ovn               => l_ovn);
--
if l_id <> 0 and p_seeded_data = 'Y' then
   per_bil_upd.upd(p_type                  => 'RESTRICTION_TYPE'
                  ,p_id_value              => l_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_ovn
                  ,p_text_value1           => p_name
                  ,p_text_value2           => p_data_type
                  ,p_text_value3           => p_restriction_clause
                  ,p_text_value4           => p_restriction_sql
                  ,p_text_value7           => p_seeded_data);
else
   /* call row handler package with correct parameters */
   per_bil_ins.ins(p_type                  => 'RESTRICTION_TYPE'
                  ,p_id_value              => p_restriction_type_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => p_object_version_number
                  ,p_text_value1           => p_name
                  ,p_text_value2           => p_data_type
                  ,p_text_value3           => p_restriction_clause
                  ,p_text_value4           => p_restriction_sql
                  ,p_text_value7           => p_seeded_data);
end if;
--
hr_utility.set_location('Leaving: hr_summary_api.create_restriction_type', 20);
--
end create_restriction_type;
-----------------
procedure create_restriction_usage (p_restriction_usage_id    out  nocopy number
                                   ,p_business_group_id       in number
                                   ,p_object_version_number   out  nocopy number
                                   ,p_item_type_usage_id      in number
                                   ,p_valid_restriction_id    in number
                                   ,p_restriction_type        in varchar2
                                   ,p_seeded_data             in varchar2) is
--
l_id  number := 0;
l_ovn number := 0;
--
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_restriction_usage', 10);
--
row_data (p_business_group_id => p_business_group_id
         ,p_type              => 'RESTRICTION_USAGE'
         ,p_fk_value1         => p_item_type_usage_id
         ,p_fk_value2         => p_valid_restriction_id
         ,l_id_value          => l_id
         ,l_ovn               => l_ovn);
--
if l_id <> 0 and p_seeded_data = 'Y' then
   per_bil_upd.upd(p_type                  => 'RESTRICTION_USAGE'
                  ,p_id_value              => l_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_ovn
                  ,p_fk_value1             => p_item_type_usage_id
                  ,p_fk_value2             => p_valid_restriction_id
                  ,p_text_value1           => p_restriction_type
                  ,p_text_value7           => p_seeded_data);
else
   /* call row handler package with correct parameters */
   per_bil_ins.ins(p_type                  => 'RESTRICTION_USAGE'
                  ,p_id_value              => p_restriction_usage_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => p_object_version_number
                  ,p_fk_value1             => p_item_type_usage_id
                  ,p_fk_value2             => p_valid_restriction_id
                  ,p_text_value1           => p_restriction_type
                  ,p_text_value7           => p_seeded_data);
end if;
--
hr_utility.set_location('Leaving: hr_summary_api.create_restriction_usage', 20);
--
end create_restriction_usage;
-----------------
procedure create_restriction_value ( p_restriction_value_id  out  nocopy number
                                    ,p_business_group_id     in number
                                    ,p_object_version_number out  nocopy number
                                    ,p_restriction_usage_id  in number
                                    ,p_value                 in varchar2
                                    ,p_seeded_data           in varchar2) is
--
l_id  number := 0;
l_ovn number := 0;
--
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_restriction_value', 10);
--
row_data (p_business_group_id => p_business_group_id
         ,p_type              => 'RESTRICTION_VALUE'
         ,p_text_value1       => p_value
         ,p_fk_value1         => p_restriction_usage_id
         ,l_id_value          => l_id
         ,l_ovn               => l_ovn);
--
if l_id <> 0 and p_seeded_data = 'Y' then
   per_bil_upd.upd(p_type                  => 'RESTRICTION_VALUE'
                  ,p_id_value              => l_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_ovn
                  ,p_fk_value1             => p_restriction_usage_id
                  ,p_text_value1           => p_value);
else
   /* call row handler package with correct parameters */
   per_bil_ins.ins(p_type                  => 'RESTRICTION_VALUE'
                  ,p_id_value              => p_restriction_value_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => p_object_version_number
                  ,p_fk_value1             => p_restriction_usage_id
                  ,p_text_value1           => p_value);
end if;
--
hr_utility.set_location('Leaving: hr_summary_api.create_restriction_value', 20);
--
end create_restriction_value;
-----------------
procedure create_item_type_usage ( p_item_type_usage_id     out  nocopy number
                                  ,p_business_group_id      in number
                                  ,p_object_version_number  out  nocopy number
                                  ,p_sequence_number        in number
                                  ,p_name                   in varchar2
                                  ,p_template_id            in number
                                  ,p_item_type_id           in number
                                  ,p_seeded_data            in varchar2) is
--
l_id  number := 0;
l_ovn number := 0;
--
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_item_type_usage', 10);
--
row_data (p_business_group_id => p_business_group_id
         ,p_type              => 'ITEM_TYPE_USAGE'
         ,p_text_value1       => p_name
         ,p_fk_value1         => p_template_id
         ,p_fk_value2         => p_item_type_id
         ,l_id_value          => l_id
         ,l_ovn               => l_ovn);
--
if l_id <> 0 and p_seeded_data = 'Y' then
   per_bil_upd.upd(p_type                  => 'ITEM_TYPE_USAGE'
                  ,p_id_value              => l_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_ovn
                  ,p_text_value1           => p_name
                  ,p_num_value1            => p_sequence_number
                  ,p_fk_value1             => p_template_id
                  ,p_fk_value2             => p_item_type_id
                  ,p_text_value7           => p_seeded_data);
else
   /* call row handler package with correct parameters */
   per_bil_ins.ins(p_type                  => 'ITEM_TYPE_USAGE'
                  ,p_id_value              => p_item_type_usage_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => p_object_version_number
                  ,p_text_value1           => p_name
                  ,p_num_value1            => p_sequence_number
                  ,p_fk_value1             => p_template_id
                  ,p_fk_value2             => p_item_type_id
                  ,p_text_value7           => p_seeded_data);
end if;
--
hr_utility.set_location('Leaving: hr_summary_api.create_item_type_usage', 20);
--
end create_item_type_usage;
-----------------
procedure create_valid_key_type (p_valid_key_type_id      out  nocopy number
                                ,p_business_group_id      in number
                                ,p_object_version_number  out  nocopy number
                                ,p_item_type_id           in number
                                ,p_key_type_id            in number
                                ,p_seeded_data            in varchar2 ) is
--
l_id  number := 0;
l_ovn number := 0;
--
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_valid_key_type', 10);
--
row_data (p_business_group_id => p_business_group_id
         ,p_type              => 'VALID_KEY_TYPE'
         ,p_fk_value1         => p_item_type_id
         ,p_fk_value2         => p_key_type_id
         ,l_id_value          => l_id
         ,l_ovn               => l_ovn);
--
if l_id <> 0 and p_seeded_data = 'Y' then
   per_bil_upd.upd(p_type                  => 'VALID_KEY_TYPE'
                  ,p_id_value              => l_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_ovn
                  ,p_fk_value1             => p_item_type_id
                  ,p_fk_value2             => p_key_type_id
                  ,p_text_value7           => p_seeded_data);
else
   /* call row handler package with correct parameters */
   per_bil_ins.ins(p_type                  => 'VALID_KEY_TYPE'
                  ,p_id_value              => p_valid_key_type_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => p_object_version_number
                  ,p_fk_value1             => p_item_type_id
                  ,p_fk_value2             => p_key_type_id
                  ,p_text_value7           => p_seeded_data);
end if;
--
hr_utility.set_location('Leaving: hr_summary_api.create_valid_key_type', 20);
--
end create_valid_key_type;
-----------------
procedure create_key_type_usage (p_key_type_usage_id      out  nocopy number
                                ,p_business_group_id      in number
                                ,p_object_version_number  out  nocopy number
                                ,p_item_type_usage_id     in number
                                ,p_valid_key_type_id      in number
                                ,p_seeded_data            in varchar2) is
--
l_id  number := 0;
l_ovn number := 0;
--
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_key_type_usage', 10);
--
row_data (p_business_group_id => p_business_group_id
         ,p_type              => 'KEY_TYPE_USAGE'
         ,p_fk_value1         => p_item_type_usage_id
         ,p_fk_value2         => p_valid_key_type_id
         ,l_id_value          => l_id
         ,l_ovn               => l_ovn);
--
if l_id <> 0 and p_seeded_data = 'Y' then
   per_bil_upd.upd(p_type                  => 'KEY_TYPE_USAGE'
                  ,p_id_value              => l_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_ovn
                  ,p_fk_value1             => p_item_type_usage_id
                  ,p_fk_value2             => p_valid_key_type_id
                  ,p_text_value7           => p_seeded_data);
else
   /* call row handler package with correct parameters */
   per_bil_ins.ins(p_type                  => 'KEY_TYPE_USAGE'
                  ,p_id_value              => p_key_type_usage_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => p_object_version_number
                  ,p_fk_value1             => p_item_type_usage_id
                  ,p_fk_value2             => p_valid_key_type_id
                  ,p_text_value7           => p_seeded_data);
end if;
--
hr_utility.set_location('Leaving: hr_summary_api.create_key_type_usage', 20);
--
end create_key_type_usage;
-----------------
procedure create_template (p_template_id            out  nocopy number
                          ,p_business_group_id      in number
                          ,p_object_version_number  out  nocopy number
                          ,p_name                   in varchar2
                          ,p_seeded_data            in varchar2) is
--
l_id  number := 0;
l_ovn number := 0;
--
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_template', 10);
--
row_data (p_business_group_id => p_business_group_id
         ,p_type              => 'TEMPLATE'
         ,p_text_value1       => p_name
         ,l_id_value          => l_id
         ,l_ovn               => l_ovn);
--
if l_id <> 0 and p_seeded_data = 'Y' then
   per_bil_upd.upd(p_type                  => 'TEMPLATE'
                  ,p_id_value              => l_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_ovn
                  ,p_text_value1           => p_name
                  ,p_text_value7           => p_seeded_data);
else
   /* call row handler package with correct parameters */
   per_bil_ins.ins(p_type                  => 'TEMPLATE'
                  ,p_id_value              => p_template_id
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => p_object_version_number
                  ,p_text_value1           => p_name
                  ,p_text_value7           => p_seeded_data);
end if;
--
hr_utility.set_location('Leaving: hr_summary_api.create_template', 20);
--
end create_template;
-----------------
procedure create_process_run (p_process_run_id         out  nocopy number
                             ,p_business_group_id      in  number
                             ,p_object_version_number  out  nocopy number
                             ,p_name                   in  varchar2
                             ,p_template_id            in  varchar2
                             ,p_process_type           in  varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_process_run', 10);
--
/* call row handler package with correct parameters */
per_bil_ins.ins(p_type                  => 'PROCESS_RUN'
               ,p_id_value              => p_process_run_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_text_value2           => p_name
               ,p_fk_value1             => p_template_id
               ,p_text_value1           => p_process_type);
--
hr_utility.set_location('Leaving: hr_summary_api.create_process_run', 20);
--
end create_process_run;
-----------------
procedure create_parameter (p_parameter_id           out  nocopy number
                           ,p_business_group_id      in  number
                           ,p_object_version_number  out  nocopy number
                           ,p_process_run_id         in  number
                           ,p_name                   in  varchar2
                           ,p_value                  in  varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api.create_process_run', 10);
--
/* call row handler package with correct parameters */
per_bil_ins.ins(p_type                  => 'PARAMETER'
               ,p_id_value              => p_parameter_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_fk_value1             => p_process_run_id
               ,p_text_value1           => p_name
               ,p_text_value6           => p_value);
--
hr_utility.set_location('Leaving: hr_summary_api.create_process_run', 20);
--
end create_parameter;
-----------------------------------------------
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@--
-----------------------------------------------
procedure delete_hr_summary (p_validate              in boolean
                            ,p_id_value              in number
                            ,p_object_version_number in number) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := 'hr_summary_api.delete_hr_summary';
  l_object_version_number hr_summary.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_hr_summary;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  per_bil_del.del(p_id_value              => p_id_value
                 ,p_object_version_number => l_object_version_number);
  --
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_hr_summary;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_hr_summary;
    raise;
end delete_hr_summary;
--
end hr_summary_api;

/
