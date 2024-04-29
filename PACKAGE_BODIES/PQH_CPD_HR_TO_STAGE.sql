--------------------------------------------------------
--  DDL for Package Body PQH_CPD_HR_TO_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CPD_HR_TO_STAGE" as
/* $Header: pqcpdhrs.pkb 120.1 2005/06/06 22:33 sankjain noship $ */
function get_crpth_hier_ver return number is
   cursor c1 is
   SELECT gvr.hierarchy_version_id
   FROM   per_gen_hierarchy_versions gvr
         ,per_gen_hierarchy gh
   WHERE  gh.type = 'CAREER_PATH'
   AND    gh.name = 'Corps Carrer Path ' --the seeded hierarchy name has a space in it.
   AND    gh.hierarchy_id = gvr.hierarchy_id
   AND    gvr.version_number = 1;
  l_hierarchy_version_id number;
begin
   open c1;
   fetch c1 into l_hierarchy_version_id;
   if c1%found then
      return l_hierarchy_version_id;
   else
      hr_utility.set_location('hierarchy doesnot exist',10);
      return -1;
   end if;
end get_crpth_hier_ver;
procedure get_scale_ddf_det(p_scale_id             in number,
                            p_information_category    out nocopy varchar2,
                            p_information1            out nocopy varchar2,
                            p_information2            out nocopy varchar2) is
begin
   hr_utility.set_location('getting scale ddf det',10);
   if p_scale_id is not null then
      select information_category,information1,information2
      into p_information_category,p_information1,p_information2
      from per_parent_spines
      where parent_spine_id = p_scale_id;
   end if;
exception
   when others then
      hr_utility.set_location('issues is selecting scale',10);
      raise;
end get_scale_ddf_det;

procedure pgm_extra_info_update(p_pgm_id            in number,
                                p_pgm_extra_info_id in number,
                                p_quota_flag          in varchar2,
                                p_appraisal_type       in varchar2,
                                p_review_period     in number) is
   l_peit_ovn number;
   l_pgm_extra_info_id number;
begin
   hr_utility.set_location('inside pgm_extra_info_update',10);
   if p_pgm_extra_info_id is null then
      hr_utility.set_location('insert pgm extra info ',10);
      ben_pgm_extra_info_api.create_pgm_extra_info
                  ( p_pgm_id                   => p_pgm_id
                   ,p_information_type         => 'PQH_FR_CORP_INFO'
                   ,p_pgi_information_category => 'PQH_FR_CORP_INFO'
                   ,p_pgi_information1         => p_quota_flag
                   ,p_pgi_information2         => p_appraisal_type
                   ,p_pgi_information3         => to_char(p_review_period)
                   ,p_pgm_extra_info_id        => l_pgm_extra_info_id
                   ,p_object_version_number    => l_peit_ovn
                  );
   else
      hr_utility.set_location('update pgm extra info',10);
      l_peit_ovn := pqh_gsp_stage_to_ben.get_ovn(p_table_name         => 'BEN_PGM_EXTRA_INFO',
                                               p_key_column_name    => 'PGM_EXTRA_INFO_ID',
                                               p_key_column_value   => p_pgm_extra_info_id);
      hr_utility.set_location(' ovn is '||l_peit_ovn,30);
      ben_pgm_extra_info_api.update_pgm_extra_info
                            ( p_pgm_extra_info_id         => p_pgm_extra_info_id
                             ,p_object_version_number     => l_peit_ovn
                             ,p_pgi_information1          => p_quota_flag
                             ,p_pgi_information2          => p_appraisal_type
                             ,p_pgi_information3          => to_char(p_review_period)
                            );
   end if;
   hr_utility.set_location('leaving pgm_extra_info_update',10);
exception
   when others then
      raise;
end pgm_extra_info_update;

procedure get_pgm_extra_info(p_pgm_id          in number,
                        p_quota_flag          out nocopy varchar2,
                        p_appraisal_type      out nocopy varchar2,
                        p_review_period       out nocopy number,
                        p_pgm_extra_info_id out nocopy number) is

cursor c1 is
      SELECT pgm_extra_info_id,pgi_information1,pgi_information2,pgi_information3
      FROM ben_pgm_extra_info
      where information_type ='PQH_FR_CORP_INFO'
      and pgm_id = p_pgm_id;
begin
   hr_utility.set_location('pgm id is'||p_pgm_id,10);
   if p_pgm_id is not null then
      for i in c1 loop
          hr_utility.set_location('assigning value',11);
          p_pgm_extra_info_id := i.pgm_extra_info_id;
          p_quota_flag          := i.pgi_information1;
          p_appraisal_type      := i.pgi_information2;
          p_review_period       := to_number(i.pgi_information3);
      end loop;

   end if;
exception
   when no_data_found then
      hr_utility.set_location('no extra info ',10);
   when others then
      hr_utility.set_location('issues is selecting pgm extra info',10);
      raise;
end get_pgm_extra_info;

procedure get_point_details(p_point_id             in number,
                            p_information_category    out nocopy varchar2,
                            p_information1            out nocopy varchar2,
                            p_information2            out nocopy varchar2,
                            p_information3            out nocopy varchar2,
                            p_information4            out nocopy varchar2,
                            p_information5            out nocopy varchar2) is
begin
   hr_utility.set_location('getting point ddf det',10);
   if p_point_id is not null then
      select information_category,information1,information2,information3,information4,information5
      into p_information_category,p_information1,p_information2,p_information3,p_information4,p_information5
      from per_spinal_points
      where spinal_point_id = p_point_id;
   end if;
exception
   when others then
      hr_utility.set_location('issues is selecting point',10);
      raise;
end get_point_details;
procedure get_corp(p_pgm_cer_id in number,
                   p_corps_id      out nocopy number,
                   p_cet_id        out nocopy number) is
   l_pgm_id number;
begin
   select cer.information1,cer.copy_entity_txn_id,cpd.corps_definition_id
   into l_pgm_id,p_cet_id,p_corps_id
   from ben_copy_entity_results cer, pqh_corps_definitions cpd
   where copy_entity_result_id = p_pgm_cer_id
   and   cpd.ben_pgm_id = cer.information1;
exception
   when no_data_found then
    p_cet_id := -1;
    p_corps_id := -1;
   when others then
      raise;
end get_corp;
function build_comb_for_plip(p_cet_id     in number,
                             p_comb_grade in varchar2) return varchar2 is
  l_grade_id    number;
  l_plip_cer_id number;
  l_grade_pos   number;
  l_comb_grade pqh_corps_extra_info.information30%type;
  l_comb_plip_cer pqh_corps_extra_info.information30%type;
  cursor get_plip_cer (p_grade_id number)is
  select plip.copy_entity_result_id
  from ben_copy_entity_results plip, ben_copy_entity_results pln
  where plip.table_alias = 'CPP' -- plip row
  and   pln.table_alias = 'PLN'
  and   plip.information261 = pln.information1
  and   pln.information294 = p_grade_id
  and   pln.information141 = 'PER_GRADES'
  and   plip.copy_entity_txn_id = p_cet_id
  and   pln.copy_entity_txn_id = p_cet_id;
begin
-- data passed is having grade_ids concatenated
-- what we have to pass is plip_cer_ids concatenated for page to read
-- this routine will get the grade_ids and for the grade get the plip cer
   l_comb_grade := p_comb_grade;
   hr_utility.set_location('inside build_comb_for_plip cet'||p_cet_id,10);
   loop
      l_grade_pos := instr(l_comb_grade,',');
      hr_utility.set_location('sep pos is'||l_grade_pos,11);
      if l_grade_pos = 0 then
         l_grade_id := l_comb_grade;
      else
         l_grade_id := substr(l_comb_grade,1,l_grade_pos-1);
         l_comb_grade := substr(l_comb_grade,l_grade_pos+1);
      end if;
      hr_utility.set_location('grade is'||l_grade_id,12);
      open get_plip_cer(l_grade_id);
      fetch get_plip_cer into l_plip_cer_id;
      if get_plip_cer%notfound then
         hr_utility.set_location('plip not found '||l_grade_id,12);
         close get_plip_cer;
      else
         close get_plip_cer;
         hr_utility.set_location('plip cer is '||l_plip_cer_id,12);
         if l_comb_plip_cer is null then
            l_comb_plip_cer := l_plip_cer_id;
         else
            l_comb_plip_cer := l_comb_plip_cer||','||l_plip_cer_id;
         end if;
      end if;
      if l_grade_pos = 0 then
         exit;
      end if;
   end loop;
   return l_comb_plip_cer;
end build_comb_for_plip;
function build_comb_for_grd(p_comb_plip in varchar2) return varchar2 is
  l_grade_id    number;
  l_plip_cer_id number;
  l_plip_pos   number;
  l_comb_grade pqh_corps_extra_info.information30%type;
  l_comb_plip pqh_corps_extra_info.information30%type;
  cursor get_grade(p_plip_cer_id number)is
  select information253
  from ben_copy_entity_results
  where copy_entity_result_id = p_plip_cer_id;
begin
-- data passed is having grade_ids concatenated
-- what we have to pass is plip_cer_ids concatenated for page to read
-- this routine will get the grade_ids and for the grade get the plip cer
   l_comb_plip := p_comb_plip;
   hr_utility.set_location('inside build_comb_for_grd',10);
   loop
      l_plip_pos := instr(l_comb_plip,',');
      hr_utility.set_location('separator pos is'||l_plip_pos,11);
      if l_plip_pos = 0 then
         l_plip_cer_id := l_comb_plip;
      else
         l_plip_cer_id := substr(l_comb_plip,1,l_plip_pos-1);
         l_comb_plip := substr(l_comb_plip,l_plip_pos+1);
      end if;
      hr_utility.set_location('plip_cer is'||l_plip_cer_id,12);
      open get_grade(l_plip_cer_id);
      fetch get_grade into l_grade_id;
      if get_grade%notfound then
         close get_grade;
      else
         close get_grade;
         hr_utility.set_location('grade is'||l_grade_id,12);
         if l_comb_grade is null then
            l_comb_grade := l_grade_id;
         else
            l_comb_grade := l_comb_grade||','||l_grade_id;
         end if;
      end if;
      if nvl(l_plip_pos,0) = 0 then
         exit;
      end if;
   end loop;
   return l_comb_grade;
end build_comb_for_grd;
procedure get_grd_quota(p_pgm_cer_id          in number,
                        p_grade_id            in number,
                        p_corps_definition_id in number,
                        p_cet_id              in number,
                        p_perc_quota          out nocopy number,
                        p_population_cd       out nocopy varchar2,
                        p_comb_grade          out nocopy varchar2,
                        p_max_speed_quota     out nocopy number,
                        p_avg_speed_quota     out nocopy number,
                        p_corps_extra_info_id out nocopy number) is
   l_comb_grade pqh_corps_extra_info.information30%type;
   cursor c1 is
      SELECT corps_extra_info_id,information4,information6,information7,information8,information30
      FROM pqh_corps_extra_info
      where information_type ='GRADE'
      and corps_definition_id = p_corps_definition_id
      and to_number(information3) = p_grade_id;
begin
   hr_utility.set_location('grade id is'||p_grade_id,10);
   hr_utility.set_location('cpd id id is'||p_corps_definition_id,10);
   hr_utility.set_location('pgm_cer id is'||p_pgm_cer_id,10);
   if p_corps_definition_id is not null then
      for i in c1 loop
          hr_utility.set_location('assigning value',11);
          p_corps_extra_info_id := i.corps_extra_info_id;
          p_perc_quota          := i.information4;
          p_max_speed_quota     := i.information6;
          p_avg_speed_quota     := i.information7;
          p_population_cd       := i.information8;
          l_comb_grade          := i.information30;
      end loop;
      if l_comb_grade is not null then
         hr_utility.set_location('going for building plip cer',11);
         hr_utility.set_location('comb plip is'||substr(l_comb_grade,1,30),17);
         hr_utility.set_location('comb plip2 is'||substr(l_comb_grade,31,30),17);
         p_comb_grade := build_comb_for_plip(p_cet_id     => p_cet_id,
                                             p_comb_grade => l_comb_grade);
         hr_utility.set_location('comb grd is'||substr(p_comb_grade,1,30),17);
         hr_utility.set_location('comb grd2 is'||substr(p_comb_grade,31,30),17);
      end if;
   end if;
exception
   when no_data_found then
      hr_utility.set_location('no quota defined ',10);
   when others then
      hr_utility.set_location('issues is selecting quota',10);
      raise;
end get_grd_quota;
function check_cdd_row(p_copy_entity_txn_id in number) return varchar2 is
l_cdd_exists varchar2(10) := 'N';
l_cdd_count number;
begin
   select count(*)
   into l_cdd_count
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias = 'CORPS_DOC';
   if nvl(l_cdd_count,0) > 0 then
      l_cdd_exists := 'Y';
   else
      l_cdd_exists := 'N';
   end if;
   return l_cdd_exists;
end check_cdd_row;
function check_cpd_row(p_copy_entity_txn_id in number) return varchar2 is
l_cpd_exists varchar2(10) := 'N';
l_cpd_count number;
begin
   select count(*)
   into l_cpd_count
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias = 'CPD';
   if nvl(l_cpd_count,0) > 0 then
      l_cpd_exists := 'Y';
   else
      l_cpd_exists := 'N';
   end if;
   return l_cpd_exists;
end check_cpd_row;
procedure crpaths_to_stage(p_copy_entity_txn_id  in number,
                           p_corps_definition_id in number,
                           p_business_group_id   in number,
                           p_effective_date      in date,
                           p_cpd_cer_id          in number) is
   l_pth_tr_id number;
   l_pth_tr_name varchar2(80);
   l_pth_cer_id number;
   l_pth_cer_ovn number;
   l_continue boolean := TRUE;
   l_hierarchy_version_id number;
   l_step_cer_id number;
   cursor csr_pth_rec is
      select *
      from per_gen_hierarchy_nodes
      where information4 = p_corps_definition_id
      and hierarchy_version_id = l_hierarchy_version_id;
begin
   hr_utility.set_location('inside pth create',10);
   l_hierarchy_version_id := get_crpth_hier_ver;
   hr_utility.set_location('pth hier ver'||l_hierarchy_version_id,10);
   if l_hierarchy_version_id is null then
      l_continue := FALSE;
   end if;
   pqh_gsp_hr_to_stage.get_table_route_details
  (p_table_alias    => 'CRPATH',
   p_table_route_id => l_pth_tr_id,
   p_table_name     => l_pth_tr_name);
   hr_utility.set_location('pth tr name'||l_pth_tr_name,20);
   if l_pth_tr_name is null then
      hr_utility.set_location('pth tr name'||l_pth_tr_name,45);
      l_continue := FALSE;
   end if;
   if p_copy_entity_txn_id is null then
      hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
      l_continue := FALSE;
   end if;
   if p_cpd_cer_id is null then
      hr_utility.set_location('cpd cer is '||p_cpd_cer_id,50);
      l_continue := FALSE;
   end if;
   if l_continue then
      for pth_rec in csr_pth_rec loop
         if pth_rec.entity_id is not null then
            -- step id is there, for UI we need step cer id
            begin
               select copy_entity_result_id
               into l_step_cer_id
               from ben_copy_entity_results
               where copy_entity_txn_id = p_copy_entity_txn_id
               and table_alias = 'COP'
               and information253 = pth_rec.entity_id;
            exception
               when others then
                  raise;
            end;
         end if;
         hr_utility.set_location('step cer id is '||l_step_cer_id,10);
         hr_utility.set_location('hier ver is '||l_hierarchy_version_id,11);
         begin
            hr_utility.set_location('cer insert api called',55);
            ben_copy_entity_results_api.create_copy_entity_results
            (p_effective_date             => p_effective_date
            ,p_copy_entity_txn_id         => p_copy_entity_txn_id
            ,p_result_type_cd             => 'DISPLAY'
            ,p_table_name                 => l_pth_tr_name
            ,p_table_alias                => 'CRPATH'
            ,p_table_route_id             => l_pth_tr_id
            ,p_dml_operation              => 'REUSE'
            ,p_information1               => pth_rec.hierarchy_node_id
            ,p_information2               => p_effective_date
            ,p_information234             => pth_rec.entity_id
            ,p_information229             => pth_rec.information3
            ,p_information232             => pth_rec.information4
            ,p_information227             => pth_rec.information9
            ,p_information100             => pth_rec.information10
            ,p_information162             => pth_rec.information11
            ,p_information169             => pth_rec.information12
            ,p_information174             => pth_rec.information13
            ,p_information176             => pth_rec.information14
            ,p_information178             => pth_rec.information15
            ,p_information180             => pth_rec.information16
            ,p_information221             => pth_rec.information17
            ,p_information222             => pth_rec.information18
            ,p_information223             => pth_rec.information19
            ,p_information224             => pth_rec.information20
            ,p_information225             => pth_rec.information21
            ,p_information226             => pth_rec.information22
            ,p_information228             => pth_rec.information23
            ,p_information230             => pth_rec.information30
            ,p_information298             => pth_rec.object_version_number
            ,p_gs_mr_src_entity_result_id => l_step_cer_id
            ,p_information161             => l_step_cer_id
            ,p_information160             => p_cpd_cer_id
            ,p_copy_entity_result_id      => l_pth_cer_id
            ,p_object_version_number      => l_pth_cer_ovn);
         exception
            when others then
               hr_utility.set_location('some issue in creating pth row ',120);
               raise;
         end;
      end loop;
   end if;
   hr_utility.set_location('leaving create pth',55);
end crpaths_to_stage;
procedure documents_to_stage(p_copy_entity_txn_id in number,
                             p_corps_definition_id in number,
                             p_effective_date      in date,
                             p_cpd_cer_id          in number) is
   l_cdd_tr_id number;
   l_cdd_tr_name varchar2(80);
   l_cdd_cer_id number;
   l_cdd_cer_ovn number;
   l_continue boolean := TRUE;
   cursor csr_cdd_rec is
      select *
      from pqh_corps_extra_info
      where corps_definition_id = p_corps_definition_id
      and information_type = 'DOCUMENT';
begin
   hr_utility.set_location('inside cdd create',10);
   pqh_gsp_hr_to_stage.get_table_route_details
  (p_table_alias    => 'CORPS_DOC',
   p_table_route_id => l_cdd_tr_id,
   p_table_name     => l_cdd_tr_name);
   hr_utility.set_location('cdd tr name'||l_cdd_tr_name,20);
   if l_cdd_tr_name is null then
      hr_utility.set_location('cdd tr name'||l_cdd_tr_name,45);
      l_continue := FALSE;
   end if;
   if p_copy_entity_txn_id is null then
      hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
      l_continue := FALSE;
   end if;
   if p_cpd_cer_id is null then
      hr_utility.set_location('cpd cer is '||p_cpd_cer_id,50);
      l_continue := FALSE;
   end if;
   if l_continue then
      for cdd_rec in csr_cdd_rec loop
         begin
            hr_utility.set_location('cer insert api called',55);
            ben_copy_entity_results_api.create_copy_entity_results
            (p_effective_date             => p_effective_date
            ,p_copy_entity_txn_id         => p_copy_entity_txn_id
            ,p_result_type_cd             => 'DISPLAY'
            ,p_table_name                 => l_cdd_tr_name
            ,p_table_alias                => 'CORPS_DOC'
            ,p_table_route_id             => l_cdd_tr_id
            ,p_dml_operation              => 'REUSE'
            ,p_information1               => cdd_rec.corps_extra_info_id
            ,p_information101             => cdd_rec.information_type
            ,p_information111             => cdd_rec.information3
            ,p_information112             => cdd_rec.information4
            ,p_information113             => cdd_rec.information5
            ,p_information114             => cdd_rec.information6
            ,p_information115             => cdd_rec.information7
            ,p_information298             => cdd_rec.object_version_number
            ,p_gs_mr_src_entity_result_id => p_cpd_cer_id
            ,p_copy_entity_result_id      => l_cdd_cer_id
            ,p_object_version_number      => l_cdd_cer_ovn);
         exception
            when others then
               hr_utility.set_location('some issue in creating cdd row ',120);
               raise;
         end;
      end loop;
   end if;
   hr_utility.set_location('leaving create cdd',55);
end documents_to_stage;
procedure corps_to_stage(p_copy_entity_txn_id in number,
                         p_pgm_id             in number,
                         p_effective_date     in date,
                         p_pgm_cer_id         in number) is
   cursor csr_cpd_rec is
      select *
      from pqh_corps_definitions
      where ben_pgm_id = p_pgm_id;
   l_cpd_tr_id number;
   l_cpd_tr_name varchar2(80);
   l_cpd_cer_id number;
   l_cpd_cer_ovn number;
   l_continue boolean := TRUE;
   l_starting_plip_cer_id number;
   l_starting_oipl_cer_id number;
   l_quota_flag   varchar2(30);
   l_appraisal_type varchar2(30);
   l_pgm_extra_info_id number;
   l_review_period number;
begin
   hr_utility.set_location('inside corps_to_stage',10);
   for cpd_rec in csr_cpd_rec loop
      pqh_gsp_hr_to_stage.get_table_route_details
      (p_table_alias    => 'CPD',
       p_table_route_id => l_cpd_tr_id,
       p_table_name     => l_cpd_tr_name);
      hr_utility.set_location('cpd tr name'||l_cpd_tr_name,20);
      if l_cpd_tr_name is null then
         hr_utility.set_location('cpd tr name'||l_cpd_tr_name,45);
         l_continue := FALSE;
      end if;
      if p_copy_entity_txn_id is null then
         hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
         l_continue := FALSE;
      end if;
      if p_pgm_cer_id is null then
         hr_utility.set_location('pgm cer is '||p_pgm_cer_id,50);
         l_continue := FALSE;
      end if;
      if cpd_rec.starting_grade_id is not null then
         hr_utility.set_location('starting grade is '||cpd_rec.starting_grade_id,60);
         begin
            select copy_entity_result_id
            into l_starting_plip_cer_id
            from ben_copy_entity_results
            where copy_entity_txn_id = p_copy_entity_txn_id
            and table_alias = 'CPP'
            and information253 = cpd_rec.starting_grade_id;
         exception
            when no_data_found then
               hr_utility.set_location('no plip found for the grd'||cpd_rec.starting_grade_id,65);
            when others then
               hr_utility.set_location('issues in selecting plip',70);
               raise;
         end;
         if cpd_rec.starting_grade_step_id is not null then
            hr_utility.set_location('starting grade step is '||cpd_rec.starting_grade_step_id,60);
            begin
               select copy_entity_result_id
               into l_starting_oipl_cer_id
               from ben_copy_entity_results
               where copy_entity_txn_id = p_copy_entity_txn_id
               and table_alias = 'COP'
               and information253 = cpd_rec.starting_grade_step_id;
            exception
               when no_data_found then
                  hr_utility.set_location('no plip found for the grd'||cpd_rec.starting_grade_step_id,65);
               when others then
                  hr_utility.set_location('issues in selecting oipl',70);
                  raise;
            end;
         end if;
      end if;
      if l_continue then
         begin
	    get_pgm_extra_info(p_pgm_id       =>  cpd_rec.ben_pgm_id,
                        p_quota_flag         => l_quota_flag,
                        p_appraisal_type     => l_appraisal_type,
                        p_review_period      => l_review_period,
                        p_pgm_extra_info_id  => l_pgm_extra_info_id);

            hr_utility.set_location('quota flag '||l_quota_flag,55);
            hr_utility.set_location('l_appraisal_type flag '||l_appraisal_type,55);
            hr_utility.set_location('l_review_period flag '||l_review_period,55);
            hr_utility.set_location('l_pgm_extra_info_id flag '||l_pgm_extra_info_id,55);

            hr_utility.set_location('cer insert api called',55);
            ben_copy_entity_results_api.create_copy_entity_results
            (p_effective_date             => p_effective_date
            ,p_copy_entity_txn_id         => p_copy_entity_txn_id
            ,p_result_type_cd             => 'DISPLAY'
            ,p_table_name                 => l_cpd_tr_name
            ,p_table_alias                => 'CPD'
            ,p_table_route_id             => l_cpd_tr_id
            ,p_dml_operation              => 'REUSE'
            ,p_information1               => cpd_rec.corps_definition_id
            ,p_information2               => cpd_rec.date_from
            ,p_information3               => cpd_rec.date_to
            ,p_information4               => cpd_rec.business_group_id
            ,p_information5               => cpd_rec.name
            ,p_information11              => cpd_rec.type_of_ps
            ,p_information14              => cpd_rec.corps_type_cd
            ,p_information13              => cpd_rec.category_cd
            ,p_information15              => cpd_rec.normal_hours_frequency
            ,p_information16              => cpd_rec.minimum_hours_frequency
            ,p_information17              => cpd_rec.probation_units
            ,p_information160             => cpd_rec.starting_grade_id
            ,p_information161             => cpd_rec.starting_grade_step_id
            ,p_information162             => l_starting_plip_cer_id
            ,p_information169             => l_starting_oipl_cer_id
            ,p_information219             => cpd_rec.task_desc
            ,p_information260             => cpd_rec.ben_pgm_id
            ,p_information287             => cpd_rec.retirement_age
            ,p_information288             => cpd_rec.secondment_threshold
            ,p_information289             => cpd_rec.normal_hours
            ,p_information290             => cpd_rec.minimum_hours
            ,p_information291             => cpd_rec.probation_period
            ,p_information292             => cpd_rec.primary_prof_field_id
            ,p_information298             => cpd_rec.object_version_number
            ,p_information307             => cpd_rec.recruitment_end_date
            ,p_information18              => l_quota_flag
            ,p_information19              =>  l_appraisal_type
            ,p_information174             => l_pgm_extra_info_id
            ,p_information221             => l_review_period
            ,p_gs_mr_src_entity_result_id => p_pgm_cer_id
            ,p_copy_entity_result_id      => l_cpd_cer_id
            ,p_object_version_number      => l_cpd_cer_ovn);
         exception
            when others then
               hr_utility.set_location('some issue in creating cpd row ',120);
               raise;
         end;
      end if;
      if l_cpd_cer_id is not null then
         hr_utility.set_location('calling documents',55);
         documents_to_stage(p_copy_entity_txn_id  => p_copy_entity_txn_id,
                            p_corps_definition_id => cpd_rec.corps_definition_id,
                            p_effective_date      => p_effective_date,
                            p_cpd_cer_id          => l_cpd_cer_id);
         hr_utility.set_location('documents done',55);
         hr_utility.set_location('calling crpaths',55);
         crpaths_to_stage(p_copy_entity_txn_id  => p_copy_entity_txn_id,
                          p_corps_definition_id => cpd_rec.corps_definition_id,
                          p_business_group_id   => cpd_rec.business_group_id,
                          p_effective_date      => p_effective_date,
                          p_cpd_cer_id          => l_cpd_cer_id);
         hr_utility.set_location('crpaths done',55);
      end if;
      hr_utility.set_location('leaving create cpd',55);
   end loop;
end corps_to_stage;
procedure stage_to_crpaths(p_copy_entity_txn_id in number,
                           p_effective_date     in date,
                           p_pgm_id             in number,
                           p_business_group_id  in number,
                           p_datetrack_mode     in varchar2) is
   cursor csr_crpth_rec is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and   table_alias = 'CRPATH'
      and dml_operation <> 'REUSE';
   l_pth_ovn number;
   l_pth_id number;
   l_cpd_id number;
   l_entity_id number;
   l_db_ovn number;
   l_object varchar2(80);
   l_message_text varchar2(2000);
   l_hierarchy_version_id number;
begin
   l_hierarchy_version_id := get_crpth_hier_ver;

    update ben_copy_entity_results
      set dml_operation = 'DELETE'
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias in ('CRPATH')
      and information104 = 'UNLINK';

   for pth_rec in csr_crpth_rec loop
      l_pth_id := pth_rec.information1;
      l_pth_ovn := pth_rec.information298;
      if pth_rec.information232 is null and pth_rec.information160 is not null then
         hr_utility.set_location('getting corps id from corp_cer',10);
         select information1
         into l_cpd_id
         from ben_copy_entity_results
         where copy_entity_result_id = pth_rec.information160;
      else
         l_cpd_id := pth_rec.information232;
      end if;
      if pth_rec.information234 is null and pth_rec.information161 is not null then
         hr_utility.set_location('getting step id from oipl_cer',10);
         select information253
         into l_entity_id
         from ben_copy_entity_results
         where copy_entity_result_id = pth_rec.information161;
      else
         l_entity_id := pth_rec.information234;
      end if;
      if pth_rec.dml_operation ='INSERT'
         and l_pth_id is null
         and l_entity_id is not null
         and l_hierarchy_version_id is not null
         and l_cpd_id is not null then
         per_hierarchy_nodes_api.create_hierarchy_nodes
         (p_hierarchy_node_id     => l_pth_id
         ,p_business_group_id     => p_business_group_id
         ,p_entity_id             => l_entity_id
         ,p_hierarchy_version_id  => l_hierarchy_version_id
         ,p_object_version_number => l_pth_ovn
         ,p_node_type             => 'CAREER_NODE'
         ,p_seq                   => 40
         ,p_information_category  => 'CAREER_NODE'
         ,p_information3          => pth_rec.information229
         ,p_information4          => pth_rec.information232
         ,p_information9          => pth_rec.information227
         ,p_information10         => pth_rec.information100
         ,p_information11         => pth_rec.information162
         ,p_information12         => pth_rec.information169
         ,p_information13         => pth_rec.information174
         ,p_information14         => pth_rec.information176
         ,p_information15         => pth_rec.information178
         ,p_information16         => pth_rec.information180
         ,p_information17         => pth_rec.information221
         ,p_information18         => pth_rec.information222
         ,p_information19         => pth_rec.information223
         ,p_information20         => pth_rec.information224
         ,p_information21         => pth_rec.information225
         ,p_information22         => pth_rec.information226
         ,p_information23         => pth_rec.information228
         ,p_information30         => nvl(pth_rec.information230,p_pgm_id)
         ,p_effective_date        => p_effective_date
         );
       elsif pth_rec.dml_operation ='UPDATE'
         and l_pth_id is not null
         and l_hierarchy_version_id is not null
         and l_pth_ovn is not null
         and l_entity_id is not null
         and l_cpd_id is not null then
           hr_utility.set_location(' dt mode is '||p_datetrack_mode,30);
           l_db_ovn := pqh_gsp_stage_to_ben.get_ovn(p_table_name         => 'PER_GEN_HIERARCHY_NODES',
                                                    p_key_column_name    => 'HIERARCHY_NODE_ID',
                                                    p_key_column_value   => l_pth_id);
           hr_utility.set_location(' ovn is '||l_db_ovn,30);
           if l_db_ovn <> l_pth_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','CCP');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ',substr(pth_rec.information1,1,30));
              fnd_message.raise_error;
           else
              per_hierarchy_nodes_api.update_hierarchy_nodes
             (p_hierarchy_node_id     => l_pth_id
             ,p_entity_id             => pth_rec.information234
             ,p_object_version_number => l_pth_ovn
             ,p_node_type             => 'CAREER_NODE'
             ,p_seq                   => 40
             ,p_information_category  => 'CAREER_NODE'
             ,p_information3          => pth_rec.information229
             ,p_information4          => pth_rec.information232
             ,p_information9          => pth_rec.information227
             ,p_information10         => pth_rec.information100
             ,p_information11         => pth_rec.information162
             ,p_information12         => pth_rec.information169
             ,p_information13         => pth_rec.information174
             ,p_information14         => pth_rec.information176
             ,p_information15         => pth_rec.information178
             ,p_information16         => pth_rec.information180
             ,p_information17         => pth_rec.information221
             ,p_information18         => pth_rec.information222
             ,p_information19         => pth_rec.information223
             ,p_information20         => pth_rec.information224
             ,p_information21         => pth_rec.information225
             ,p_information22         => pth_rec.information226
             ,p_information23         => pth_rec.information228
             ,p_information30         => pth_rec.information230
             ,p_effective_date        => p_effective_date
             );
           end if;
       elsif pth_rec.dml_operation ='DELETE'
         and l_pth_id is not null
         and l_pth_ovn is not null then
             per_hierarchy_nodes_api.delete_hierarchy_nodes
             (p_hierarchy_node_id     => l_pth_id
             ,p_object_version_number => l_pth_ovn);
       else
           l_message_text := 'invalid dml_oper'||pth_rec.dml_operation
           ||' pth_ovn:'||l_pth_ovn
           ||' hier_ver:'||l_hierarchy_version_id
           ||' l_pth_id:'||l_pth_id
           ||' l_entity_id:'||l_entity_id
           ||' l_cpd_id:'||l_cpd_id;
           PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
           (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
           P_TXN_ID          => nvl(l_pth_id,p_copy_entity_txn_id),
           P_MODULE_CD       => 'PQH_GSP_STGBEN',
           p_context         => 'CRPATH',
           P_MESSAGE_TYPE_CD => 'E',
           P_MESSAGE_TEXT    => l_message_text,
           p_effective_date  => p_effective_date);
       end if;
   end loop;
end stage_to_crpaths;
procedure stage_to_docs(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_datetrack_mode     in varchar2) is
   cursor csr_doc_rec is
      select *
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and   table_alias = 'CORPS_DOC'
      and dml_operation <> 'REUSE';
   l_cdd_ovn number;
   l_cpd_id number;
   l_cdd_id number;
   l_db_ovn number;
   l_object varchar2(80);
   l_message_text varchar2(2000);
begin
   for cdd_rec in csr_doc_rec loop
      l_cdd_id := cdd_rec.information1;
      l_cdd_ovn := cdd_rec.information298;
      if cdd_rec.information160 is null then
         select information1
         into l_cpd_id
         from ben_copy_entity_results
         where copy_entity_result_id = cdd_rec.GS_MIRROR_SRC_ENTITY_RESULT_ID;
      else
         l_cpd_id := cdd_rec.information160;
      end if;
      if cdd_rec.dml_operation ='INSERT'
         and l_cdd_id is null
         and l_cpd_id is not null then
         pqh_corps_extra_info_api.create_corps_extra_info
         (p_effective_date        => p_effective_date
         ,p_corps_extra_info_id   => l_cdd_id
         ,p_corps_definition_id   => l_cpd_id
         ,p_information_type      => 'DOCUMENT'
         ,p_information3          => cdd_rec.information111
         ,p_information4          => cdd_rec.information112
         ,p_information5          => cdd_rec.information113
         ,p_information6          => cdd_rec.information114
         ,p_information7          => cdd_rec.information115
         ,p_object_version_number => l_cdd_ovn
         );
       elsif cdd_rec.dml_operation ='UPDATE'
         and l_cdd_id is not null
         and l_cdd_ovn is not null
         and l_cpd_id is not null then
           hr_utility.set_location(' dt mode is '||p_datetrack_mode,30);
           l_db_ovn := pqh_gsp_stage_to_ben.get_ovn(p_table_name         => 'PQH_CORPS_EXTRA_INFO',
                                                    p_key_column_name    => 'CORPS_EXTRA_INFO_ID',
                                                    p_key_column_value   => l_cdd_id);
           hr_utility.set_location(' ovn is '||l_db_ovn,30);
           if l_db_ovn <> l_cdd_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','CDD');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ',substr(cdd_rec.information113,1,30));
              fnd_message.raise_error;
           else
              pqh_corps_extra_info_api.update_corps_extra_info
              (p_effective_date        => p_effective_date
              ,p_corps_extra_info_id   => l_cdd_id
              ,p_corps_definition_id   => l_cpd_id
              ,p_information3          => cdd_rec.information111
              ,p_information4          => cdd_rec.information112
              ,p_information5          => cdd_rec.information113
              ,p_information6          => cdd_rec.information114
              ,p_information7          => cdd_rec.information115
              ,p_object_version_number => l_cdd_ovn
              );
           end if;
       elsif cdd_rec.dml_operation ='DELETE'
         and l_cdd_id is not null
         and l_cdd_ovn is not null then
              pqh_corps_extra_info_api.delete_corps_extra_info
              (p_corps_extra_info_id   => l_cdd_id
              ,p_object_version_number => l_cdd_ovn);
       else
           l_message_text := 'invalid dml_oper'||cdd_rec.dml_operation
           ||' cdd_ovn:'||l_cdd_ovn
           ||' l_cpd_id:'||l_cpd_id;
           PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
           (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
           P_TXN_ID          => nvl(l_cdd_id,p_copy_entity_txn_id),
           P_MODULE_CD       => 'PQH_GSP_STGBEN',
           p_context         => 'CORPS_DOC',
           P_MESSAGE_TYPE_CD => 'E',
           P_MESSAGE_TEXT    => l_message_text,
           p_effective_date  => p_effective_date);
       end if;
   end loop;
end stage_to_docs;
procedure cpd_writeback(p_copy_entity_txn_id in number,
                        p_cpd_id             in number,
                        p_cpd_cer_id         in number) is
begin
   hr_utility.set_location('cpd id is '||p_cpd_id,1);
   hr_utility.set_location('cpd cer id is '||p_cpd_cer_id,2);
   hr_utility.set_location('cet id is '||p_copy_entity_txn_id,4);
-- update corp rows with corps id
   begin
      hr_utility.set_location('updating plips for cpd :'||p_cpd_id,4);
      update ben_copy_entity_results
      set information1 = p_cpd_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'CPD';
      hr_utility.set_location('num of corp updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating cpd to corp',10);
         raise;
   end;
-- update crpath rows with corps id
   begin
      hr_utility.set_location('updating plips for cpd :'||p_cpd_id,4);
      update ben_copy_entity_results
      set information232 = p_cpd_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'CRPATH';
      hr_utility.set_location('num of crpaths updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating cpd to crpaths',10);
         raise;
   end;
-- update cpp rows with corps id
   begin
      hr_utility.set_location('updating plips for cpd :'||p_cpd_id,4);
      update ben_copy_entity_results
      set information291 = p_cpd_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'CPP';
      hr_utility.set_location('num of plips updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating cpd to plips',10);
         raise;
   end;
-- update cdd rows with corps id
   begin
      hr_utility.set_location('updating docs for cpd :'||p_cpd_id,4);
      update ben_copy_entity_results
      set information160 = p_cpd_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'CORPS_DOC';
      hr_utility.set_location('num of docs updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating cpd to docs',10);
         raise;
   end;
end cpd_writeback;
procedure pop_pri_filiere(p_corps_definition_id in number,
                          p_filiere_id          in number,
                          p_effective_date      in date) is
   cursor c1 is select corps_extra_info_id
                from   pqh_corps_extra_info
                where  corps_definition_id = p_corps_definition_id
                and    information4        = p_filiere_id
                and    information_type    = 'FILERE';
   l_cei_id number;
   l_cei_ovn number;
begin
   open c1;
   fetch c1 into l_cei_id;
   if c1%notfound then
      pqh_corps_extra_info_api.create_corps_extra_info(
       p_effective_date               => p_effective_date
      ,p_corps_extra_info_id          => l_cei_id
      ,p_corps_definition_id          => p_corps_definition_id
      ,p_information_type             => 'FILERE'
      ,p_information4                 => p_filiere_id
      ,p_object_version_number        => l_cei_ovn
      );
   end if;
   close c1;
end pop_pri_filiere;

--
   PROCEDURE stage_to_corps (
      p_copy_entity_txn_id   IN   NUMBER,
      p_effective_date       IN   DATE,
      p_business_group_id    IN   NUMBER,
      p_datetrack_mode       IN   VARCHAR2
   )
   IS
      CURSOR csr_corp_rec
      IS
         SELECT *
           FROM ben_copy_entity_results
          WHERE copy_entity_txn_id = p_copy_entity_txn_id
            AND table_alias = 'CPD'
            AND dml_operation <> 'REUSE';

      l_pgm_id              NUMBER;
      l_pgm_esd             DATE;
      l_pgm_name            VARCHAR2 (240);
      l_cpd_ovn             NUMBER;
      l_cpd_id              NUMBER;
      l_db_ovn              NUMBER;
      l_object              VARCHAR2 (80);
      l_message_text        VARCHAR2 (2000);
      l_min_freq            VARCHAR2 (30);
      l_starting_grade_id   NUMBER;
      l_starting_step_id    NUMBER;
      l_plip_cer_id         NUMBER;
      l_oipl_cer_id         NUMBER;

      CURSOR c_plip
      IS
         SELECT   copy_entity_result_id, information253
             FROM ben_copy_entity_results
            WHERE copy_entity_txn_id = p_copy_entity_txn_id
              AND table_alias = 'CPP'
              AND information104 <> 'UNLINK'
              AND result_type_cd = 'DISPLAY'
         ORDER BY information263;

      CURSOR c_oipl (p_plip_cer_id NUMBER)
      IS
         SELECT   copy_entity_result_id, information253
             FROM ben_copy_entity_results
            WHERE copy_entity_txn_id = p_copy_entity_txn_id
              AND table_alias = 'COP'
              AND information104 <> 'UNLINK'
              AND gs_parent_entity_result_id = p_plip_cer_id
              AND result_type_cd = 'DISPLAY'
         ORDER BY information263;

      l_status_cd           VARCHAR2 (10);
      l_updated             BOOLEAN;
      l_corps_def_id        NUMBER;
      l_ovn                 NUMBER;
   BEGIN
      l_updated := FALSE;

      SELECT DECODE (information38, 'A', 'ACTIVE', 'INACTIVE')
        INTO l_status_cd
        FROM ben_copy_entity_results
       WHERE copy_entity_txn_id = p_copy_entity_txn_id
         AND table_alias = 'PGM'
         AND dml_operation <> 'REUSE';

      FOR cpd_rec IN csr_corp_rec
      LOOP
         l_cpd_id := cpd_rec.information1;
         l_cpd_ovn := cpd_rec.information298;
         l_updated := TRUE;

         BEGIN
            SELECT information1, information5, information2
              INTO l_pgm_id, l_pgm_name, l_pgm_esd
              FROM ben_copy_entity_results
             WHERE copy_entity_result_id =
                                        cpd_rec.gs_mirror_src_entity_result_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               hr_utility.set_location ('issues in getting pgm name', 10);
               RAISE;
         END;

         hr_utility.set_location ('corps name is ' || l_pgm_name, 10);
         hr_utility.set_location ('pgm id is ' || l_pgm_id, 10);

         IF cpd_rec.information290 IS NOT NULL
         THEN
            l_min_freq := cpd_rec.information15;
         ELSE
            l_min_freq := '';
         END IF;

         IF cpd_rec.information162 IS NULL
         THEN
            hr_utility.set_location
                                 ('no value selected, get lowest plip grade',
                                  10
                                 );

            OPEN c_plip;

            FETCH c_plip
             INTO l_plip_cer_id, l_starting_grade_id;

            IF c_plip%NOTFOUND
            THEN
               hr_utility.set_location ('no plip defined', 10);
            ELSE
               hr_utility.set_location ('plip cer is' || l_plip_cer_id, 10);

               OPEN c_oipl (l_plip_cer_id);

               FETCH c_oipl
                INTO l_oipl_cer_id, l_starting_step_id;

               IF c_oipl%NOTFOUND
               THEN
                  hr_utility.set_location (   'no oipl defined for plip'
                                           || l_plip_cer_id,
                                           30
                                          );
               ELSE
                  hr_utility.set_location ('oipl cer is' || l_oipl_cer_id,
                                           10);
               END IF;

               CLOSE c_oipl;
            END IF;

            CLOSE c_plip;
         ELSE
            hr_utility.set_location ('start plip entered', 10);

            IF cpd_rec.information169 IS NULL
            THEN
               hr_utility.set_location ('start oipl not entered,get lowest',
                                        10
                                       );

               OPEN c_oipl (cpd_rec.information162);

               FETCH c_oipl
                INTO l_oipl_cer_id, l_starting_step_id;

               IF c_oipl%NOTFOUND
               THEN
                  hr_utility.set_location (   'no oipl defined for plip'
                                           || cpd_rec.information162,
                                           30
                                          );
               END IF;

               CLOSE c_oipl;
            ELSE
               hr_utility.set_location
                               ('start plip and oipl entered,get grade step',
                                50
                               );

               BEGIN
                  SELECT information253
                    INTO l_starting_grade_id
                    FROM ben_copy_entity_results
                   WHERE copy_entity_result_id = cpd_rec.information162;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     hr_utility.set_location
                                       ('issues in selecting grade for plip',
                                        10
                                       );
               END;

               BEGIN
                  SELECT information253
                    INTO l_starting_step_id
                    FROM ben_copy_entity_results
                   WHERE copy_entity_result_id = cpd_rec.information169;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     hr_utility.set_location
                                        ('issues in selecting step for oipl',
                                         10
                                        );
               END;
            END IF;
         END IF;

         hr_utility.set_location ('starting grade id is'
                                  || l_starting_grade_id,
                                  100
                                 );
         hr_utility.set_location ('starting step id is' || l_starting_step_id,
                                  100
                                 );

         IF     cpd_rec.dml_operation = 'INSERT'
            AND l_cpd_id IS NULL
            AND l_pgm_id IS NOT NULL
            AND l_pgm_esd IS NOT NULL
            AND l_pgm_name IS NOT NULL
         THEN
            pqh_corps_definitions_api.create_corps_definition
                          (p_effective_date               => p_effective_date,
                           p_date_from                    => l_pgm_esd,
                           p_date_to                      => cpd_rec.information3,
                           p_business_group_id            => p_business_group_id,
                           p_name                         => l_pgm_name,
                           p_type_of_ps                   => cpd_rec.information11,
                           p_corps_type_cd                => cpd_rec.information14,
                           p_category_cd                  => cpd_rec.information13,
                           p_normal_hours_frequency       => cpd_rec.information15,
                           p_minimum_hours_frequency      => l_min_freq,
                           p_probation_units              => cpd_rec.information17,
                           p_task_desc                    => cpd_rec.information219,
                           p_starting_grade_id            => l_starting_grade_id,
                           p_starting_grade_step_id       => l_starting_step_id,
                           p_retirement_age               => cpd_rec.information287,
                           p_secondment_threshold         => cpd_rec.information288,
                           p_normal_hours                 => cpd_rec.information289,
                           p_minimum_hours                => cpd_rec.information290,
                           p_probation_period             => cpd_rec.information291,
                           p_primary_prof_field_id        => cpd_rec.information292,
                           p_recruitment_end_date         => cpd_rec.information307,
                           p_status_cd                    => l_status_cd,
                           p_ben_pgm_id                   => l_pgm_id,
                           p_corps_definition_id          => l_cpd_id,
                           p_object_version_number        => l_cpd_ovn
                          );
              pgm_extra_info_update(p_pgm_id           => l_pgm_id,
                                p_pgm_extra_info_id    => cpd_rec.information174,
                                p_quota_flag           => cpd_rec.information18,
                                p_appraisal_type       => cpd_rec.information19,
                                p_review_period        => cpd_rec.information221);

         ELSIF     (   cpd_rec.dml_operation = 'UPDATE'
                    OR NVL (cpd_rec.information5, 'X') <> l_pgm_name
                   )
               AND l_cpd_id IS NOT NULL
               AND l_cpd_ovn IS NOT NULL
               AND l_pgm_name IS NOT NULL
               AND l_pgm_id IS NOT NULL
         THEN
            hr_utility.set_location (' dt mode is ' || p_datetrack_mode, 30);
            l_db_ovn :=
               pqh_gsp_stage_to_ben.get_ovn
                                 (p_table_name            => 'PQH_CORPS_DEFINITIONS',
                                  p_key_column_name       => 'CORPS_DEFINITION_ID',
                                  p_key_column_value      => l_cpd_id
                                 );
            hr_utility.set_location (' ovn is ' || l_db_ovn, 30);

            IF l_db_ovn <> l_cpd_ovn
            THEN
               l_object :=
                      hr_general.decode_lookup ('PQH_GSP_OBJECT_TYPE', 'CPD');
               fnd_message.set_name ('PQH', 'PQH_GSP_OBJ_OVN_INVALID');
               fnd_message.set_token ('OBJECT ', l_object);
               fnd_message.set_token ('OBJECT_NAME ', cpd_rec.information5);
               fnd_message.raise_error;
            ELSE
               pqh_corps_definitions_api.update_corps_definition
                          (p_effective_date               => p_effective_date,
                           p_date_from                    => l_pgm_esd,
                           p_date_to                      => cpd_rec.information3,
                           p_business_group_id            => p_business_group_id,
                           p_name                         => l_pgm_name,
                           p_type_of_ps                   => cpd_rec.information11,
                           p_corps_type_cd                => cpd_rec.information14,
                           p_category_cd                  => cpd_rec.information13,
                           p_normal_hours_frequency       => cpd_rec.information15,
                           p_minimum_hours_frequency      => l_min_freq,
                           p_probation_units              => cpd_rec.information17,
                           p_task_desc                    => cpd_rec.information219,
                           p_starting_grade_id            => l_starting_grade_id,
                           p_starting_grade_step_id       => l_starting_step_id,
                           p_retirement_age               => cpd_rec.information287,
                           p_secondment_threshold         => cpd_rec.information288,
                           p_normal_hours                 => cpd_rec.information289,
                           p_minimum_hours                => cpd_rec.information290,
                           p_probation_period             => cpd_rec.information291,
                           p_primary_prof_field_id        => cpd_rec.information292,
                           p_recruitment_end_date         => cpd_rec.information307,
                           p_status_cd                    => l_status_cd,
                           p_ben_pgm_id                   => l_pgm_id,
                           p_corps_definition_id          => l_cpd_id,
                           p_object_version_number        => l_cpd_ovn
                          );
	        pgm_extra_info_update(p_pgm_id           => l_pgm_id,
                                p_pgm_extra_info_id    => cpd_rec.information174,
                                p_quota_flag           => cpd_rec.information18,
                                p_appraisal_type       => cpd_rec.information19,
                                p_review_period        => cpd_rec.information221);
            END IF;
         ELSE
            l_message_text :=
                  'invalid dml_oper'
               || cpd_rec.dml_operation
               || ' cpd_ovn:'
               || l_cpd_ovn
               || ' ben_pgm_id:'
               || l_pgm_id
               || ' ben_pgm_esd:'
               || l_pgm_esd
               || ' ben_pgm_name:'
               || l_pgm_name
               || ' for cpd_id:'
               || l_cpd_id;
            pqh_gsp_process_log.log_process_dtls
                                     (p_master_txn_id        => p_copy_entity_txn_id,
                                      p_txn_id               => NVL
                                                                   (l_cpd_id,
                                                                    p_copy_entity_txn_id
                                                                   ),
                                      p_module_cd            => 'PQH_GSP_STGBEN',
                                      p_context              => 'CPD',
                                      p_message_type_cd      => 'E',
                                      p_message_text         => l_message_text,
                                      p_effective_date       => p_effective_date
                                     );
         END IF;

         IF l_cpd_id IS NOT NULL AND cpd_rec.information292 IS NOT NULL
         THEN
            hr_utility.set_location ('going for populating pri filere', 10);
            pop_pri_filiere (p_corps_definition_id      => l_cpd_id,
                             p_filiere_id               => cpd_rec.information292,
                             p_effective_date           => p_effective_date
                            );
            hr_utility.set_location ('pri filere done', 11);
         END IF;

         IF l_cpd_id IS NOT NULL AND cpd_rec.copy_entity_result_id IS NOT NULL
         THEN
            hr_utility.set_location ('going for cpd writeback ', 12);
            cpd_writeback (p_copy_entity_txn_id      => p_copy_entity_txn_id,
                           p_cpd_id                  => l_cpd_id,
                           p_cpd_cer_id              => cpd_rec.copy_entity_result_id
                          );
            hr_utility.set_location ('cpd writeback done', 13);
         END IF;
      END LOOP;

      IF l_updated = FALSE
      THEN
         SELECT information1, information298
           INTO l_corps_def_id, l_cpd_ovn
           FROM ben_copy_entity_results
          WHERE copy_entity_txn_id = p_copy_entity_txn_id
            AND table_alias = 'CPD'
            AND dml_operation = 'REUSE';

         pqh_corps_definitions_api.update_corps_definition
                                     (p_effective_date             => p_effective_date,
                                      p_corps_definition_id        => l_corps_def_id,
                                      p_status_cd                  => l_status_cd,
                                      p_object_version_number      => l_cpd_ovn
                                     );
      END IF;

      stage_to_docs (p_copy_entity_txn_id      => p_copy_entity_txn_id,
                     p_effective_date          => p_effective_date,
                     p_business_group_id       => p_business_group_id,
                     p_datetrack_mode          => p_datetrack_mode
                    );
      stage_to_crpaths (p_copy_entity_txn_id      => p_copy_entity_txn_id,
                        p_effective_date          => p_effective_date,
                        p_pgm_id                  => l_pgm_id,
                        p_business_group_id       => p_business_group_id,
                        p_datetrack_mode          => p_datetrack_mode
                       );
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.set_location ('Error thrown', 13);
         pqh_gsp_process_log.log_process_dtls
                                    (p_master_txn_id        => p_copy_entity_txn_id,
                                     p_txn_id               => NVL
                                                                  (l_cpd_id,
                                                                   p_copy_entity_txn_id
                                                                  ),
                                     p_module_cd            => 'PQH_GSP_STGBEN',
                                     p_context              => 'CPD',
                                     p_message_type_cd      => 'E',
                                     p_message_text         => l_message_text,
                                     p_effective_date       => p_effective_date
                                    );
         RAISE;
   END stage_to_corps;

--
procedure grd_quota_update(p_effective_date      in date,
                           p_grade_id            in number,
                           p_corps_definition_id in number,
                           p_corps_extra_info_id in number,
                           p_perc_quota          in number,
                           p_population_cd       in varchar2,
                           p_comb_grades         in varchar2,
                           p_max_speed_quota     in number,
                           p_avg_speed_quota     in number) is
   l_db_ovn number;
   l_cei_id number;
   l_comp_grd varchar2(2000);
begin
   hr_utility.set_location('inside grd_quota_update',10);
   if p_comb_grades is not null then
      l_comp_grd := build_comb_for_grd(p_comb_plip => p_comb_grades);
   end if;
   if p_corps_extra_info_id is null then
      hr_utility.set_location('insert grd quota ',10);
      pqh_corps_extra_info_api.create_corps_extra_info(
       p_effective_date               => p_effective_date
      ,p_corps_extra_info_id          => l_cei_id
      ,p_corps_definition_id          => p_corps_definition_id
      ,p_information_type             => 'GRADE'
      ,p_information3                 => p_grade_id
      ,p_information4                 => p_perc_quota
      ,p_information6                 => p_max_speed_quota
      ,p_information7                 => p_avg_speed_quota
      ,p_information8                 => p_population_cd
      ,p_information30                => l_comp_grd
      ,p_object_version_number        => l_db_ovn
      );
   else
      hr_utility.set_location('update grd quota',10);
      l_db_ovn := pqh_gsp_stage_to_ben.get_ovn(p_table_name         => 'PQH_CORPS_EXTRA_INFO',
                                               p_key_column_name    => 'CORPS_EXTRA_INFO_ID',
                                               p_key_column_value   => p_corps_extra_info_id);
      hr_utility.set_location(' ovn is '||l_db_ovn,30);
      pqh_corps_extra_info_api.update_corps_extra_info(
       p_effective_date               => p_effective_date
      ,p_corps_extra_info_id          => p_corps_extra_info_id
      ,p_corps_definition_id          => p_corps_definition_id
      ,p_information_type             => 'GRADE'
      ,p_information3                 => p_grade_id
      ,p_information4                 => p_perc_quota
      ,p_information6                 => p_max_speed_quota
      ,p_information7                 => p_avg_speed_quota
      ,p_information8                 => p_population_cd
      ,p_information30                => l_comp_grd
      ,p_object_version_number        => l_db_ovn
      );
   end if;
   hr_utility.set_location('leaving grd_quota_update',10);
exception
   when others then
      raise;
end grd_quota_update;
procedure pull_career_path(p_copy_entity_txn_id in number,
                           p_step_id            in number,
                           p_effective_date     in date,
                           p_grade_id           in number) is
begin
   null;
end pull_career_path;
procedure update_point(p_point_id             in number,
                       p_point_ovn            in out nocopy number,
                       p_information_category in varchar2,
                       p_information1         in varchar2,
                       p_information2         in varchar2,
                       p_information3         in varchar2,
                       p_information4         in varchar2,
                       p_information5         in varchar2,
                       p_effective_date       in date,
                       p_business_group_id    in number,
                       p_parent_spine_id      in number,
                       p_sequence             in number,
                       p_spinal_point         in varchar2) is
begin
   hr_progression_point_api.update_progression_point
   (p_effective_date        => p_effective_date
   ,p_business_group_id     => p_business_group_id
   ,p_parent_spine_id       => p_parent_spine_id
   ,p_sequence              => p_sequence
   ,p_spinal_point          => p_spinal_point
   ,p_spinal_point_id       => p_point_id
   ,p_object_version_number => p_point_ovn
   ,p_information_category  => p_information_category
   ,p_information1          => p_information1
   ,p_information2          => p_information2
   ,p_information3          => p_information3
   ,p_information4          => p_information4
   ,p_information5          => p_information5
   );
exception
   when others then
      hr_utility.set_location('issues in updating point'||p_spinal_point,30);
      raise;
end update_point;
procedure create_point(p_point_id             out nocopy number,
                       p_point_ovn            out nocopy number,
                       p_information_category in varchar2,
                       p_information1         in varchar2,
                       p_information2         in varchar2,
                       p_information3         in varchar2,
                       p_information4         in varchar2,
                       p_information5         in varchar2,
                       p_effective_date       in date,
                       p_business_group_id    in number,
                       p_parent_spine_id      in number,
                       p_sequence             in number,
                       p_spinal_point         in varchar2) is
begin
   hr_progression_point_api.create_progression_point
   (p_effective_date        => p_effective_date
   ,p_business_group_id     => p_business_group_id
   ,p_parent_spine_id       => p_parent_spine_id
   ,p_sequence              => p_sequence
   ,p_spinal_point          => p_spinal_point
   ,p_spinal_point_id       => p_point_id
   ,p_object_version_number => p_point_ovn
   ,p_information_category  => p_information_category
   ,p_information1          => p_information1
   ,p_information2          => p_information2
   ,p_information3          => p_information3
   ,p_information4          => p_information4
   ,p_information5          => p_information5
   );
exception
   when others then
      hr_utility.set_location('issues in creating point'||p_spinal_point,30);
      raise;
end create_point;
procedure create_scale(p_scale_id             out nocopy number,
                       p_scale_ovn            out nocopy number,
                       p_information_category in varchar2,
                       p_information1         in varchar2,
                       p_information2         in varchar2,
                       p_business_group_id    in number,
                       p_name                 in varchar2,
                       p_effective_date       in date,
                       p_increment_frequency  in number,
                       p_increment_period     in varchar2) is
begin
   hr_utility.set_location('inf_cat is'||p_information_category,10);
   hr_utility.set_location('inf1 is'||p_information1,10);
   hr_utility.set_location('inf2 is'||p_information2,10);
   hr_pay_scale_api.create_pay_scale
   (p_business_group_id     => p_business_group_id
   ,p_name                  => p_name
   ,p_effective_date        => p_effective_date
   ,p_increment_frequency   => p_increment_frequency
   ,p_increment_period      => p_increment_period
   ,p_parent_spine_id       => p_scale_id
   ,p_object_version_number => p_scale_ovn
   ,p_information_category  => p_information_category
   ,p_information1          => p_information1
   ,p_information2          => p_information2
   ) ;
exception
   when others then
      hr_utility.set_location('issues in creating scale'||p_name,30);
      raise;
end create_scale;
procedure update_scale(p_scale_id             in number,
                       p_scale_ovn            in out nocopy number,
                       p_information_category in varchar2,
                       p_information1         in varchar2,
                       p_information2         in varchar2,
                       p_business_group_id    in number,
                       p_name                 in varchar2,
                       p_effective_date       in date,
                       p_increment_frequency  in number,
                       p_increment_period     in varchar2) is
begin
   hr_pay_scale_api.update_pay_scale
   (p_business_group_id     => p_business_group_id
   ,p_name                  => p_name
   ,p_effective_date        => p_effective_date
   ,p_increment_frequency   => p_increment_frequency
   ,p_increment_period      => p_increment_period
   ,p_parent_spine_id       => p_scale_id
   ,p_object_version_number => p_scale_ovn
   ,p_information_category  => p_information_category
   ,p_information1          => p_information1
   ,p_information2          => p_information2
   ) ;
exception
   when others then
      hr_utility.set_location('issues in updating scale'||p_name,30);
      raise;
end update_scale;
end pqh_cpd_hr_to_stage;

/
