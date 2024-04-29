--------------------------------------------------------
--  DDL for Package Body PQH_CORPS_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CORPS_COPY" as
/* $Header: pqcpdcpy.pkb 115.9 2003/11/26 02:34:01 kgowripe noship $ */
   g_package varchar2(100) := 'PQH_CORPS_COPY.' ;
procedure copy_corps(p_corps_definition_id     in number,
                     p_effective_date          in date,
                     p_name                    in varchar2,
                     p_nature_cd               in varchar2,
                     p_business_group_id       in number default null,
                     p_copy_grades             in varchar2 default 'Y',
                     p_copy_docs               in varchar2 default 'Y',
                     p_copy_exams              in varchar2 default 'Y',
                     p_copy_training           in varchar2 default 'Y',
                     p_copy_organizations      in varchar2 default 'Y',
                     p_copy_others             in varchar2 default 'Y',
                     p_copy_career             in varchar2 default 'Y',
                     p_filere1_cd              in varchar2 default 'NO',
                     p_filere2_cd              in varchar2 default null,
                     p_filere3_cd              in varchar2 default null,
                     p_filere4_cd              in varchar2 default null,
                     p_filere5_cd              in varchar2 default null,
                     p_filere6_cd              in varchar2 default null,
                     p_filere7_cd              in varchar2 default null,
                     p_filere8_cd              in varchar2 default null,
                     p_filere9_cd              in varchar2 default null,
                     p_filere10_cd             in varchar2 default null
) is
   l_proc varchar2(100) := g_package||'copy_corps' ;
begin
   null;
end copy_corps;
function get_step_name(p_grade_step_id in number) return varchar2 is
   l_step_name varchar2(30);
begin
   select spt.spinal_point step_name
   into l_step_name
   from per_spinal_point_steps_f sps, per_spinal_points spt
   where sps.spinal_point_id = spt.spinal_point_id
      and sps.step_id = p_grade_step_id
and trunc(sysdate) between sps.effective_start_date and sps.effective_end_date
;
   return l_step_name;
end get_step_name;
function get_grade_name(p_grade_step_id in number) return varchar2 is
   l_grade_name varchar2(30);
begin
select grd.name
into l_grade_name
from per_spinal_point_steps_f sps, per_grade_spines_f gsp, per_grades_vl grd
where sps.grade_spine_id  = gsp.grade_spine_id
and gsp.grade_id = grd.grade_id
and sps.step_id = p_grade_step_id
and trunc(sysdate) between sps.effective_start_date and sps.effective_end_date
and trunc(sysdate) between gsp.effective_start_date and gsp.effective_end_date
;
return l_grade_name;
end get_grade_name;
function get_grade_id(p_grade_step_id in number) return number is
   l_grade_id number;
begin
select grd.grade_id
into l_grade_id
from per_spinal_point_steps_f sps, per_grade_spines_f gsp, per_grades grd
where sps.grade_spine_id  = gsp.grade_spine_id
and gsp.grade_id = grd.grade_id
and sps.step_id = p_grade_step_id
and trunc(sysdate) between sps.effective_start_date and sps.effective_end_date
and trunc(sysdate) between gsp.effective_start_date and gsp.effective_end_date
;
return l_grade_id;
end get_grade_id;
function get_hier_ver return number is
   l_hier_ver_id number;
   l_nodes number;
   cursor c1 is
   select ghv.hierarchy_version_id hier_ver
   from per_gen_hierarchy ghr, per_gen_hierarchy_versions ghv
   where ghr.hierarchy_id = ghv.hierarchy_id
   and ghr.type ='CAREER_PATH'
   order by ghv.hierarchy_version_id;
begin
   for i in c1 loop
      if l_hier_ver_id is null then
         l_hier_ver_id := i.hier_ver;
      end if;
      select count(*) into l_nodes
      from per_gen_hierarchy_nodes
      where hierarchy_version_id = i.hier_ver;
      if l_nodes >0 then
         l_hier_ver_id := i.hier_ver;
         exit;
      end if;
   end loop;
   return l_hier_ver_id;
end get_hier_ver;
procedure insert_career_path(p_effective_date           in date,
                             p_hierarchy_version_id     in number,
                             p_business_group_id        in number,
                             p_from_corps_definition_id in number,
                             p_starting_grade_step_id   in number,
                             p_ending_grade_step_id     in number,
                             p_to_corps_definition_id   in number,
                             p_from_seniority           in number default null,
                             p_from_seniority_uom       in varchar2 default null,
                             p_to_seniority             in number default null,
                             p_to_seniority_uom         in varchar2 default null,
                             p_node_id                  out nocopy number,
                             p_object_version_number    out nocopy number) is
   l_node_type varchar2(30) := 'CAREER_NODE';
   l_path varchar2(30);
   cursor csr_career_path is select 'X' from per_gen_hierarchy_nodes
                where entity_id = to_char(p_starting_grade_step_id)
                  and information3 = p_ending_grade_step_id
                  and information4 = p_from_corps_definition_id
                  and information9 = p_to_corps_definition_id
                  and information_category = l_node_type;
begin
   open csr_career_path;
   fetch csr_career_path into l_path;
   if csr_career_path%found then
      close csr_career_path;
      hr_utility.set_message(8302, 'PQH_DUPLICATE_CORPS_CAREER');
      hr_utility.raise_error;
   end if;
   close csr_career_path;
   if p_to_seniority is not null and p_to_seniority_uom is null then
      hr_utility.set_message(8302, 'PQH_CORPS_UOM_MISSING');
      hr_utility.raise_error;
   end if;
   if p_from_seniority is not null and p_from_seniority_uom is null then
      hr_utility.set_message(8302, 'PQH_CORPS_UOM_MISSING');
      hr_utility.raise_error;
   end if;
   if p_from_corps_definition_id = p_to_corps_definition_id and
      p_starting_grade_step_id = p_ending_grade_step_id then
      hr_utility.set_message(8302, 'PQH_CORPS_CAREER_INVALID');
      hr_utility.raise_error;
   end if;
   per_pgn_ins.ins
     (p_effective_date                 => p_effective_date
     ,p_business_group_id              => p_business_group_id
     ,p_entity_id                      => p_starting_grade_step_id
     ,p_hierarchy_version_id           => p_hierarchy_version_id
     ,p_node_type                      => l_node_type
     ,p_seq                            => 40
     ,p_information_category           => l_node_type
     ,p_information3                   => p_ending_grade_step_id
     ,p_information4                   => p_from_corps_definition_id
     ,p_information5                   => p_from_seniority
     ,p_information6                   => p_from_seniority_uom
     ,p_information7                   => p_to_seniority
     ,p_information8                   => p_to_seniority_uom
     ,p_information9                   => p_to_corps_definition_id
     ,p_hierarchy_node_id              => p_node_id
     ,p_object_version_number          => p_object_version_number );
exception when others then
p_node_id                  := null;
p_object_version_number    := null;
raise;
end insert_career_path;
procedure update_career_path(p_effective_date           in date,
                             p_node_id                  in number,
                             p_from_corps_definition_id in number   default null,
                             p_starting_grade_step_id   in number   default null,
                             p_ending_grade_step_id     in number   default null,
                             p_to_corps_definition_id   in number   default null,
                             p_from_seniority           in number   default null,
                             p_from_seniority_uom       in varchar2 default null,
                             p_to_seniority             in number   default null,
                             p_to_seniority_uom         in varchar2 default null,
                             p_object_version_number    in out nocopy number
) is
   l_node_type varchar2(30) := 'CAREER_NODE';
   l_path varchar2(30);
   l_object_version_number number := p_object_version_number;
   cursor csr_check is select 'X' from per_gen_hierarchy_nodes
                where hierarchy_node_id = p_node_id
                  and object_version_number = p_object_version_number;
   cursor csr_career_path is select 'X' from per_gen_hierarchy_nodes
                where entity_id = to_char(p_starting_grade_step_id)
                  and information3 = p_ending_grade_step_id
                  and information4 = p_from_corps_definition_id
                  and information9 = p_to_corps_definition_id
                  and information_category = l_node_type
                  and hierarchy_node_id <> p_node_id;
begin
   open csr_check;
   fetch csr_check into l_path;
   if csr_check%notfound then
      close csr_check;
   else
     close csr_check;
     open csr_career_path;
     fetch csr_career_path into l_path;
     if csr_career_path%found then
        close csr_career_path;
        hr_utility.set_message(8302, 'PQH_DUPLICATE_CORPS_CAREER');
        hr_utility.raise_error;
     end if;
     close csr_career_path;
     if p_to_seniority is not null and p_to_seniority_uom is null then
        hr_utility.set_message(8302, 'PQH_CORPS_UOM_MISSING');
        hr_utility.raise_error;
     end if;
     if p_from_seniority is not null and p_from_seniority_uom is null then
        hr_utility.set_message(8302, 'PQH_CORPS_UOM_MISSING');
        hr_utility.raise_error;
     end if;
     if p_from_corps_definition_id = p_to_corps_definition_id and
        p_starting_grade_step_id = p_ending_grade_step_id then
        hr_utility.set_message(8302, 'PQH_CORPS_CAREER_INVALID');
        hr_utility.raise_error;
     end if;
     per_pgn_upd.upd
        (p_effective_date                 => p_effective_date
        ,p_entity_id                      => p_starting_grade_step_id
        ,p_node_type                      => l_node_type
        ,p_seq                            => 40
        ,p_information_category           => l_node_type
        ,p_information3                   => p_ending_grade_step_id
        ,p_information4                   => p_from_corps_definition_id
        ,p_information5                   => p_from_seniority
        ,p_information6                   => p_from_seniority_uom
        ,p_information7                   => p_to_seniority
        ,p_information8                   => p_to_seniority_uom
        ,p_information9                   => p_to_corps_definition_id
        ,p_hierarchy_node_id              => p_node_id
        ,p_object_version_number          => p_object_version_number );
   end if;
exception when others then
p_object_version_number := l_object_version_number;
raise;
end update_career_path;
procedure delete_career_path(p_node_id               in number,
                             p_object_version_number in number) is
   cursor csr_career_path is select 'X' from per_gen_hierarchy_nodes
                             where hierarchy_node_id = p_node_id
                             and object_version_number = p_object_version_number;
   l_check varchar2(30);
begin
   open csr_career_path;
   fetch csr_career_path into l_check;
   if csr_career_path%found then
      close csr_career_path;
      per_pgn_del.del
        (p_hierarchy_node_id      => p_node_id
        ,p_object_version_number  => p_object_version_number
        );
   else
      close csr_career_path;
   end if;
end delete_career_path;

--
procedure add_corps_fileres(p_corps_definition_id     in number,
                            p_effective_date          in date,
                            p_filere1_cd              in varchar2 ,
                            p_filere2_cd              in varchar2 default null,
                            p_filere3_cd              in varchar2 default null) is
begin
   NULL;
end add_corps_fileres;
--
--
procedure delete_corps_fileres(p_corps_definition_id     in number,
                               p_filere_cd              in varchar2 default null) is
begin
      NULL;
end delete_corps_fileres;
--
procedure delete_corps(p_corps_definition_id     in number) is
begin
  NULL;
end delete_corps;
--
procedure delete_corps_grade(p_corps_definition_id     in number,
                             p_grade_id                in number) is
begin
   NULL;
end delete_corps_grade;
--
end pqh_corps_copy;

/
