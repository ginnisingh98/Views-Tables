--------------------------------------------------------
--  DDL for Package Body PQH_GSP_STAGE_TO_BEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_STAGE_TO_BEN" as
/* $Header: pqgspsbe.pkb 120.9.12010000.2 2009/03/13 09:48:12 lbodired ship $ */
function get_scl_name(p_scl_id in number) return varchar2 is
   l_scl_name varchar2(30);
begin
   select name
   into l_scl_name
   from per_parent_spines
   where parent_spine_id = p_scl_id;
   return l_scl_name;
end get_scl_name;
function build_opt_name(p_opt_cer_id in number) return varchar2 is
   l_scl_id number;
   l_point_name varchar2(30);
   l_scl_name varchar2(240);
   l_opt_name varchar2(240);
begin
-- opt_name is option name which is combination of point and scale
   begin
      select information255,substr(information98,1,30),substr(information5,1,61)
      into l_scl_id,l_point_name,l_opt_name
      from ben_copy_entity_results
      where copy_entity_result_id = p_opt_cer_id;
      if l_scl_id is not null then
         l_scl_name := get_scl_name(p_scl_id => l_scl_id);
         if l_point_name is not null then
            l_opt_name := substr(l_scl_name,1,30) ||':'|| l_point_name;
         end if;
      else
         hr_utility.set_location('invalid scale id '||l_scl_id,3);
         l_opt_name := nvl(l_opt_name,l_point_name);
      end if;
      exception
         when no_data_found then
            l_point_name := '';
         when others then
            raise;
      end;
   return l_opt_name;
exception
   when others then
      hr_utility.set_location('issues in building opt name',11);
      raise;
end build_opt_name;
procedure elp_writeback(p_crset_id           in number,
                        p_elp_id             in number,
                        p_copy_entity_txn_id in number) is
begin
   hr_utility.set_location('crset id is '||p_crset_id,20);
   hr_utility.set_location('cet id is '||p_copy_entity_txn_id,20);
   hr_utility.set_location('elp id is '||p_elp_id,20);
   update ben_copy_entity_results
   set information279 = p_elp_id
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias = 'CRRATE'
   and information160 = p_crset_id;
   hr_utility.set_location('num of crrs updated'||sql%rowcount,20);
end elp_writeback;
procedure end_date_crit(p_elig_prfl_id   in number,
                        p_crit_type      in varchar2,
                        p_effective_date in date) is
   l_pk number;
   l_ovn number;
   l_esd date;
   l_eed date;
begin
   hr_utility.set_location('crit passed is'||p_crit_type,100);
   if p_crit_type ='RL' then
      select eligy_prfl_rl_id,object_version_number
      into l_pk,l_ovn
      from BEN_ELIGY_PRFL_RL_F
      where eligy_prfl_id = p_elig_prfl_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('pk selected is'||l_pk,100);

      BEN_ELIGY_PROFILE_RULE_API.delete_ELIGY_PROFILE_RULE(
         p_eligy_prfl_rl_id       => l_pk
         ,p_effective_start_date  => l_esd
         ,p_effective_end_date    => l_eed
         ,p_object_version_number => l_ovn
         ,p_effective_date        => p_effective_date
         ,p_datetrack_mode        => hr_api.g_delete
         );
   elsif p_crit_type ='PR' then
      select elig_perf_rtng_prte_id,object_version_number
      into l_pk,l_ovn
      from BEN_ELIG_PERF_RTNG_PRTE_F
      where eligy_prfl_id = p_elig_prfl_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('pk selected is'||l_pk,100);

      BEN_ELIG_PERF_RTNG_PRTE_API.delete_ELIG_PERF_RTNG_PRTE(
         p_elig_perf_rtng_prte_id => l_pk
         ,p_effective_start_date  => l_esd
         ,p_effective_end_date    => l_eed
         ,p_object_version_number => l_ovn
         ,p_effective_date        => p_effective_date
         ,p_datetrack_mode        => hr_api.g_delete
         );
   elsif p_crit_type ='PT' then
      select elig_per_typ_prte_id,object_version_number
      into l_pk,l_ovn
      from BEN_ELIG_PER_TYP_PRTE_F
      where eligy_prfl_id = p_elig_prfl_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('pk selected is'||l_pk,100);

      BEN_ELIG_PER_TYP_PRTE_API.delete_ELIG_PER_TYP_PRTE(
         p_elig_per_typ_prte_id    => l_pk
         ,p_effective_start_date   => l_esd
         ,p_effective_end_date     => l_eed
         ,p_object_version_number  => l_ovn
         ,p_effective_date         => p_effective_date
         ,p_datetrack_mode         => hr_api.g_delete
         );
   elsif p_crit_type ='FP' then
      select elig_fl_tm_pt_tm_prte_id,object_version_number
      into l_pk,l_ovn
      from BEN_ELIG_FL_TM_PT_TM_PRTE_F
      where eligy_prfl_id = p_elig_prfl_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('pk selected is'||l_pk,100);

      BEN_ELIG_FL_TM_PT_TM_PRTE_API.delete_ELIG_FL_TM_PT_TM_PRTE(
         p_elig_fl_tm_pt_tm_prte_id => l_pk
         ,p_effective_start_date    => l_esd
         ,p_effective_end_date      => l_eed
         ,p_object_version_number   => l_ovn
         ,p_effective_date          => p_effective_date
         ,p_datetrack_mode          => hr_api.g_delete
         );
   elsif p_crit_type ='BU' then
      select elig_brgng_unit_prte_id,object_version_number
      into l_pk,l_ovn
      from BEN_ELIG_BRGNG_UNIT_PRTE_F
      where eligy_prfl_id = p_elig_prfl_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('pk selected is'||l_pk,100);

      BEN_ELIG_BRGNG_UNIT_PRTE_API.delete_ELIG_BRGNG_UNIT_PRTE(
         p_elig_brgng_unit_prte_id => l_pk
         ,p_effective_start_date   => l_esd
         ,p_effective_end_date     => l_eed
         ,p_object_version_number  => l_ovn
         ,p_effective_date         => p_effective_date
         ,p_datetrack_mode         => hr_api.g_delete
         );
   elsif p_crit_type ='SA' then
      select elig_svc_area_prte_id,object_version_number
      into l_pk,l_ovn
      from BEN_ELIG_SVC_AREA_PRTE_F
      where eligy_prfl_id = p_elig_prfl_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('pk selected is'||l_pk,100);

      BEN_ELIG_SVC_AREA_PRTE_API.delete_ELIG_SVC_AREA_PRTE(
         p_elig_svc_area_prte_id  => l_pk
         ,p_effective_start_date  => l_esd
         ,p_effective_end_date    => l_eed
         ,p_object_version_number => l_ovn
         ,p_effective_date        => p_effective_date
         ,p_datetrack_mode        => hr_api.g_delete
         );
   elsif p_crit_type ='LOC' then
      select elig_wk_loc_prte_id,object_version_number
      into l_pk,l_ovn
      from BEN_ELIG_WK_LOC_PRTE_F
      where eligy_prfl_id = p_elig_prfl_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('pk selected is'||l_pk,100);

      BEN_ELIG_WK_LOC_PRTE_API.delete_ELIG_WK_LOC_PRTE(
         p_elig_wk_loc_prte_id    => l_pk
         ,p_effective_start_date  => l_esd
         ,p_effective_end_date    => l_eed
         ,p_object_version_number => l_ovn
         ,p_effective_date        => p_effective_date
         ,p_datetrack_mode        => hr_api.g_delete
         );
   elsif p_crit_type ='ORG' then
      select elig_org_unit_prte_id,object_version_number
      into l_pk,l_ovn
      from BEN_ELIG_ORG_UNIT_PRTE_F
      where eligy_prfl_id = p_elig_prfl_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('pk selected is'||l_pk,100);

      BEN_ELIG_ORG_UNIT_PRTE_API.delete_ELIG_ORG_UNIT_PRTE(
         p_elig_org_unit_prte_id  => l_pk
         ,p_effective_start_date  => l_esd
         ,p_effective_end_date    => l_eed
         ,p_object_version_number => l_ovn
         ,p_effective_date        => p_effective_date
         ,p_datetrack_mode        => hr_api.g_delete
         );
   elsif p_crit_type ='JOB' then
      select elig_job_prte_id,object_version_number
      into l_pk,l_ovn
      from BEN_ELIG_JOB_PRTE_F
      where eligy_prfl_id = p_elig_prfl_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('pk selected is'||l_pk,100);

      BEN_ELIGY_JOB_PRTE_API.delete_ELIGY_JOB_PRTE(
         p_elig_job_prte_id       => l_pk
         ,p_effective_start_date  => l_esd
         ,p_effective_end_date    => l_eed
         ,p_object_version_number => l_ovn
         ,p_effective_date        => p_effective_date
         ,p_datetrack_mode        => hr_api.g_delete
         );
   else
      hr_utility.set_location('invalid crit passed',100);
   end if;
end end_date_crit;
function get_per_typ_cd(P_PERSON_TYPE_ID in number) return varchar2 is
   l_per_typ_cd varchar2(30);
begin
   select system_person_type
   into l_per_typ_cd
   from per_person_types
   where person_type_id = P_PERSON_TYPE_ID;
   return l_per_typ_cd;
end get_per_typ_cd;
function build_vpf_name(p_crset_id           in number,
                        p_grade_cer_id       in number,
                        p_point_cer_id       in number,
                        p_copy_entity_txn_id in number) return varchar2 is
cursor csr_crset is
   select substr(information151,1,150)
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias = 'CRSET'
   and information161 = p_crset_id
   order by information2;
l_crset_name varchar2(240);
l_vpf_name varchar2(240);
l_grd_name varchar2(80);
l_opt_name varchar2(80);
begin
   if p_crset_id is not null then
      open csr_crset;
      fetch csr_crset into l_crset_name;
      if csr_crset%notfound then
         close csr_crset;
         hr_utility.set_location('criteria set doesnot exist',10);
      else
         close csr_crset;
      end if;
   else
      hr_utility.set_location('crset passed is null',11);
      return l_vpf_name;
   end if;
   if p_grade_cer_id is not null then
      hr_utility.set_location('grd short name to be pulled',11);
      begin
         select substr(information102,1,30)
         into l_grd_name
         from ben_copy_entity_results
         where copy_entity_result_id = p_grade_cer_id;
      exception
         when others then
            hr_utility.set_location('issue in selecting grd_name',11);
            raise;
      end;
      l_vpf_name := l_grd_name ||'-'||l_crset_name;
      return l_vpf_name;
   elsif p_point_cer_id is not null then
      hr_utility.set_location('opt name to be pulled',11);
      l_opt_name := build_opt_name(p_opt_cer_id => p_point_cer_id);
      l_vpf_name := l_opt_name ||'-'||l_crset_name;
      return l_vpf_name;
   else
      hr_utility.set_location('grd and pnt cer null',11);
      return l_vpf_name;
   end if;
end build_vpf_name;
function get_ovn(p_table_name       in varchar2,
                 p_key_column_name  in varchar2,
                 p_key_column_value in number,
                 p_effective_date   in date default null) return number is
    query_str varchar2(2000);
    l_ovn number;
 begin
    query_str := 'select object_version_number from '
         || p_table_name
         || ' where '
         || p_key_column_name || '= :key_column_value' ;
    hr_utility.set_location('query is '||substr(query_str,1,50),10);
    hr_utility.set_location('query1 is '||substr(query_str,51,50),10);
    if p_effective_date is not null then
       query_str := query_str || ' and :effective_date'
                              || ' between effective_start_date and effective_end_date';
       hr_utility.set_location('query1 is '||substr(query_str,51,50),10);
     EXECUTE IMMEDIATE query_str
         INTO l_ovn
         USING p_key_column_value, p_effective_date;
    else
     EXECUTE IMMEDIATE query_str
         INTO l_ovn
         USING p_key_column_value;
    end if;
    return l_ovn;
end get_ovn;
function get_update_mode(p_table_name varchar2,
                         p_key_column_name varchar2,
                         p_key_column_value number,
                         p_effective_date in date) return varchar2 is
    query_str varchar2(2000);
    l_dt_mode varchar2(30);
    l_min_esd date;
 begin
    query_str := 'select min(effective_start_date) from '
         || p_table_name
         || ' where '
         || p_key_column_name || '= :key_column_value'
         || ' and effective_start_date >= :effective_date';

     EXECUTE IMMEDIATE query_str
         INTO l_min_esd
         USING p_key_column_value, p_effective_date;

    if l_min_esd is null then
       -- we r working on last row
       l_dt_mode := 'UPDATE';
    elsif l_min_esd > p_effective_date then
       -- future row exist
       l_dt_mode := 'UPDATE_OVERRIDE';
    elsif l_min_esd = p_effective_date then
       -- row was created as of today
       l_dt_mode := 'CORRECTION';
    end if;
    return l_dt_mode;
end get_update_mode;
function is_oipl_exists(p_effective_date in date,
                        p_pl_id          in number,
                        p_opt_id         in number) return number is
   l_oipl_id number;
begin
   hr_utility.set_location('opt id is '||p_opt_id,1);
   hr_utility.set_location('pl id is '||p_pl_id,2);
   select oipl_id
   into l_oipl_id
   from ben_oipl_f
   where pl_id = p_pl_id
   and   opt_id = p_opt_id
   and p_effective_date between effective_start_date and effective_end_date;
   hr_utility.set_location('oipl is '||l_oipl_id,3);
   return l_oipl_id;
exception
   when no_data_found then
      hr_utility.set_location('oipl doesnot exist ',3);
      return l_oipl_id;
   when others then
      hr_utility.set_location('issues in getting oipl ',4);
      raise;
end is_oipl_exists;
function get_gsp_pt(p_business_group_id in number,
                    p_effective_date    in date) return number is
   l_pt_id number;
   cursor c1 is
   select pl_typ_id
   from ben_pl_typ_f
   where opt_typ_cd ='GSP'
   and business_group_id = p_business_group_id
   and pl_typ_stat_cd ='A'
   and p_effective_date between effective_start_date and effective_end_date;
begin
   open c1;
   fetch c1 into l_pt_id;
   if c1%notfound then
      close c1;
      hr_utility.set_location('pl_typ not defined ',4);
   else
      close c1;
   end if;
   return l_pt_id;
end get_gsp_pt;
procedure plip_writeback(p_copy_entity_txn_id in number,
                         p_plip_id            in number,
                         p_pl_id              in number,
                         p_plip_cer_id        in number) is
begin
   hr_utility.set_location('plip id is '||p_plip_id,1);
   hr_utility.set_location('pl id is '||p_pl_id,1);
   hr_utility.set_location('plip cer id is '||p_plip_cer_id,2);
   hr_utility.set_location('cet id is '||p_copy_entity_txn_id,3);
-- update plip row with plip id
   begin
      hr_utility.set_location('updating oipl for pl:'||p_pl_id,4);
      update ben_copy_entity_results
      set information1 = p_plip_id
      where copy_entity_result_id = p_plip_cer_id;
      hr_utility.set_location('num of plips updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating plip ',10);
         raise;
   end;
-- update oipl rows with pl id
   begin
      hr_utility.set_location('updating oipl for pl:'||p_pl_id,4);
      update ben_copy_entity_results
      set information261 = p_pl_id
      where gs_parent_entity_result_id = p_plip_cer_id
      and table_alias ='COP'
      and copy_entity_txn_id = p_copy_entity_txn_id;
      hr_utility.set_location('num of oipls updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating plip ',10);
         raise;
   end;
-- update epa rows with plip id
   begin
      hr_utility.set_location('updating epa for plip:'||p_plip_id,4);
      update ben_copy_entity_results
      set information1 = p_plip_id
      where copy_entity_result_id = p_plip_cer_id;
      hr_utility.set_location('num of epas updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating plip ',10);
         raise;
   end;
   hr_utility.set_location('plip writeback comp ',5);
end plip_writeback;
procedure oipl_writeback(p_copy_entity_txn_id in number,
                         p_oipl_id             in number,
                         p_oipl_cer_id         in number) is
begin
   hr_utility.set_location('oipl id is '||p_oipl_id,1);
   hr_utility.set_location('oipl cer id is '||p_oipl_cer_id,2);
   hr_utility.set_location('cet id is '||p_copy_entity_txn_id,3);
   begin
      hr_utility.set_location('updating oipl:'||p_oipl_id,4);
      update ben_copy_entity_results
      set information1 = p_oipl_id
      where copy_entity_result_id = p_oipl_cer_id;
      hr_utility.set_location('num of oipls updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating oipl ',10);
         raise;
   end;
   hr_utility.set_location('oipl writeback comp ',5);
end oipl_writeback;
procedure opt_writeback(p_copy_entity_txn_id in number,
                        p_opt_id             in number,
                        p_opt_name           in varchar2,
                        p_opt_cer_id         in number) is
begin
   hr_utility.set_location('opt id is '||p_opt_id,1);
   hr_utility.set_location('opt cer id is '||p_opt_cer_id,2);
   hr_utility.set_location('cet id is '||p_copy_entity_txn_id,3);
-- update oipl rows with opt id
   begin
      -- oipl row is updated with opt id
      hr_utility.set_location('updating oipl for opt :'||p_opt_id,4);
      update ben_copy_entity_results
      set information247 = p_opt_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'COP'
      and information262 = p_opt_cer_id;
      hr_utility.set_location('num of oipls updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating opt to oipl',10);
         raise;
   end;
-- update abr rows with opt id
   begin
      hr_utility.set_location('updating abr for opt:'||p_opt_id,4);
      update ben_copy_entity_results
      set information247 = p_opt_id,
          information170 = p_opt_name
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'ABR'
      and information278 = p_opt_cer_id;
      hr_utility.set_location('num of opts updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating opt to abr',10);
         raise;
   end;
   hr_utility.set_location('opt writeback comp ',5);
end opt_writeback;
procedure pln_writeback(p_copy_entity_txn_id in number,
                        p_pl_id             in number,
                        p_pl_name           in varchar2,
                        p_pl_cer_id         in number,
                        p_plip_cer_id       in number) is
begin
   hr_utility.set_location('pln id is '||p_pl_id,1);
   hr_utility.set_location('pln cer id is '||p_pl_cer_id,2);
   hr_utility.set_location('cet id is '||p_copy_entity_txn_id,3);
-- update plip rows with plan id
   begin
      -- plip row is updated with pl id
      hr_utility.set_location('updating plips for pl :'||p_pl_id,4);
      update ben_copy_entity_results
      set information261 = p_pl_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'CPP'
      and copy_entity_result_id = p_plip_cer_id;
      hr_utility.set_location('num of plips updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating pl to plip',10);
         raise;
   end;
-- update abr rows with pl id
   begin
      hr_utility.set_location('updating abr for pl:'||p_pl_id,4);
      update ben_copy_entity_results
      set information261 = p_pl_id,
          information170 = p_pl_name
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'ABR'
      and information277 = p_pl_cer_id;
      hr_utility.set_location('num of abrs updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating pl to abr',10);
         raise;
   end;
-- update oipl rows with plan id
   begin
      -- oipl row is updated with pl id
      hr_utility.set_location('updating oipls for pl :'||p_pl_id,4);
      update ben_copy_entity_results
      set information261 = p_pl_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'COP'
      and gs_parent_entity_result_id = p_plip_cer_id;
      hr_utility.set_location('num of oipls updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating pl to oipl',10);
         raise;
   end;
-- update pln row
   begin
      update ben_copy_entity_results
      set information1 = p_pl_id
      where copy_entity_result_id = p_pl_cer_id;
      hr_utility.set_location('num of plans updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating pln ',10);
         raise;
   end;
   hr_utility.set_location('pln writeback comp ',5);
end pln_writeback;
procedure pgm_writeback(p_copy_entity_txn_id in number,
                        p_pgm_id             in number,
                        p_pgm_cer_id         in number,
                        p_ptip_id            in number) is
begin
   hr_utility.set_location('pgm id is '||p_pgm_id,1);
   hr_utility.set_location('pgm cer id is '||p_pgm_cer_id,2);
   hr_utility.set_location('ptip id is '||p_ptip_id,3);
   hr_utility.set_location('cet id is '||p_copy_entity_txn_id,4);
-- update plip rows with program id
   begin
      -- plip row is updated with pgm id
      hr_utility.set_location('updating plips for pgm :'||p_pgm_id,4);
      update ben_copy_entity_results
      set information260 = p_pgm_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'CPP';
      hr_utility.set_location('num of plips updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating pgm to plip',10);
         raise;
   end;
-- update cpd rows with program id
   begin
      -- cpd row is updated with pgm id
      hr_utility.set_location('updating cpd for pgm :'||p_pgm_id,4);
      update ben_copy_entity_results
      set information260 = p_pgm_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'CPD';
      hr_utility.set_location('num of cpd updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating pgm to cpd',10);
         raise;
   end;
-- update pgm row for information1
   begin
      update ben_copy_entity_results
      set information1 = p_pgm_id
      where copy_entity_result_id = p_pgm_cer_id;
      hr_utility.set_location('num of pgms updated'||sql%rowcount,20);
   exception
      when others then
         hr_utility.set_location('issues in updating pgm ',10);
         raise;
   end;
   hr_utility.set_location('pgm and ptip writeback comp ',5);
end pgm_writeback;
function get_gsp_le(p_oper_code      in varchar2,
                    p_bg_id          in number,
                    p_effective_date in date) return number is
l_ler_id number;
begin
   select ler_id
   into l_ler_id
   from ben_ler_f
   where typ_cd = 'GSP'
   and lf_evt_oper_cd = p_oper_code
   and business_group_id = p_bg_id
   and p_effective_date between effective_start_date and effective_end_date;
   return l_ler_id;
exception
   when others then
      hr_utility.set_location('issues in selecting ler',2);
      raise;
end get_gsp_le;
procedure pgm_enrl(p_pgm_id         in number,
                   p_bg_id          in number,
                   p_effective_date in date,
                   p_pet_id         out nocopy number) is
   l_ovn number;
   l_esd date;
   l_eed date;
   l_pet_id number;
begin
   hr_utility.set_location('creating pet for pgm'||p_pgm_id,1);
   hr_utility.set_location(' BEN_POPL_ENRT_TYP_CYCL_F CREATE_POPL_ENRT_TYP_CYCL ',20);
   BEN_POPL_ENRT_TYP_CYCL_API.CREATE_POPL_ENRT_TYP_CYCL(
   P_EFFECTIVE_DATE         => p_effective_date
   ,P_BUSINESS_GROUP_ID     => p_bg_id
   ,P_ENRT_TYP_CYCL_CD      => 'L'
   ,P_PGM_ID                => p_PGM_ID
   ,P_POPL_ENRT_TYP_CYCL_ID => l_pet_id
   ,P_EFFECTIVE_START_DATE  => l_esd
   ,P_EFFECTIVE_END_DATE    => l_eed
   ,P_OBJECT_VERSION_NUMBER => l_ovn
   );
   hr_utility.set_location('After per insert ',2);
   p_pet_id := l_pet_id;
end pgm_enrl;
procedure upd_pgm_le(p_pgm_id         in number,
                     p_cet_id         in number,
                     p_effective_date in date,
                     p_bg_id          in number,
                     p_pro_cvg_st_dt  in varchar2,
                     p_pro_rt_st_dt   in varchar2,
                     p_syn_rt_st_dt   in varchar2) is
   l_pet_id number;
   l_ler_id number;
begin
   hr_utility.set_location('updating le_enrl for pgm'||p_pgm_id,1);
   begin
      select popl_enrt_typ_cycl_id
      into l_pet_id
      from ben_popl_enrt_typ_cycl_f
      where pgm_id = p_pgm_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('pet is'||l_pet_id,2);
   exception
      when others then
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID  => p_cet_id,
         P_TXN_ID          => p_cet_id,
         P_MODULE_CD       => 'PQH_GSP_STGBEN',
         p_context         => 'UPD_LE_sel_pet',
         P_MESSAGE_TYPE_CD => 'E',
         P_MESSAGE_TEXT    => 'UPD_LE',
         p_effective_date  => p_effective_date);
         raise;
   end;
   l_ler_id := get_gsp_le (p_bg_id          => p_bg_id,
                           p_effective_date => p_effective_date,
                           p_oper_code      => 'PROG');
   hr_utility.set_location('prog le is'||l_ler_id,2);
   if l_ler_id is not null then
      begin
         update ben_lee_rsn_f
         set ENRT_CVG_STRT_DT_CD = p_pro_cvg_st_dt,
             RT_STRT_DT_CD       = p_pro_rt_st_dt
         where POPL_ENRT_TYP_CYCL_ID = l_pet_id
         and ler_id                  = l_ler_id
         and p_effective_date between effective_start_date and effective_end_date;
         hr_utility.set_location('prog le enrl updated ',4);
      exception
         when others then
            PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
            (P_MASTER_TXN_ID  => p_cet_id,
            P_TXN_ID          => p_cet_id,
            P_MODULE_CD       => 'PQH_GSP_STGBEN',
            p_context         => 'UPD_LE',
            P_MESSAGE_TYPE_CD => 'E',
            P_MESSAGE_TEXT    => 'UPD_LE',
            p_effective_date  => p_effective_date);
            raise;
      end;
   end if;
   l_ler_id := get_gsp_le (p_bg_id          => p_bg_id,
                           p_effective_date => p_effective_date,
                           p_oper_code      => 'SYNC');
   hr_utility.set_location('sync le is'||l_ler_id,2);
   if l_ler_id is not null then
      begin
         update ben_lee_rsn_f
         set ENRT_CVG_STRT_DT_CD = p_syn_rt_st_dt,
             RT_STRT_DT_CD       = p_syn_rt_st_dt
         where POPL_ENRT_TYP_CYCL_ID = l_pet_id
         and ler_id                  = l_ler_id
         and p_effective_date between effective_start_date and effective_end_date;
      exception
         when others then
            PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
            (P_MASTER_TXN_ID  => p_cet_id,
            P_TXN_ID          => p_cet_id,
            P_MODULE_CD       => 'PQH_GSP_STGBEN',
            p_context         => 'UPD_LE',
            P_MESSAGE_TYPE_CD => 'E',
            P_MESSAGE_TEXT    => 'UPD_LE2',
            p_effective_date  => p_effective_date);
            raise;
      end;
   end if;
end upd_pgm_le;
procedure pgm_le(p_pgm_id         in number,
                 p_bg_id          in number,
                 p_effective_date in date,
                 p_pet_id         in number,
                 p_pro_cvg_st_dt  in varchar2,
                 p_pro_rt_st_dt   in varchar2,
                 p_syn_rt_st_dt   in varchar2,
                 p_lee_rsn_id     out nocopy number) is
   l_ovn number;
   l_esd date;
   l_eed date;
   l_ler_id number;
   l_lee_rsn_id number;
begin
   hr_utility.set_location('creating pet for pgm'||p_pgm_id,1);
   l_ler_id := get_gsp_le (p_bg_id          => p_bg_id,
                           p_effective_date => p_effective_date,
                           p_oper_code      => 'PROG');
   if l_ler_id is not null and p_pet_id is not null then
      hr_utility.set_location(' BEN_LEE_RSN_F CREATE_LIFE_EVENT_ENROLL_RSN ',20);
      BEN_LIFE_EVENT_ENROLL_RSN_API.CREATE_LIFE_EVENT_ENROLL_RSN(
      P_EFFECTIVE_DATE         => p_effective_date
      ,P_BUSINESS_GROUP_ID     => p_bg_id
      ,P_LEE_RSN_ID            => p_lee_rsn_id
      ,P_LER_ID                => l_ler_id
      ,P_POPL_ENRT_TYP_CYCL_ID => p_pet_id
      ,P_EFFECTIVE_START_DATE  => l_esd
      ,P_EFFECTIVE_END_DATE    => l_eed
      ,P_OBJECT_VERSION_NUMBER => l_ovn
      ,P_CLS_ENRT_DT_TO_USE_CD => 'ELCNSMADE'
      ,P_ENRT_CVG_END_DT_CD    => 'ODBED'
      ,P_ENRT_CVG_STRT_DT_CD   => p_pro_cvg_st_dt
      ,P_ENRT_PERD_END_DT_CD   => 'ALDCPPY'
      ,P_ENRT_PERD_STRT_DT_CD  => 'AED'
      ,P_RT_END_DT_CD          => 'ODBED'
      ,P_RT_STRT_DT_CD         => p_pro_rt_st_dt
      );
   end if;
   l_ler_id := get_gsp_le (p_bg_id          => p_bg_id,
                           p_effective_date => p_effective_date,
                           p_oper_code      => 'SYNC');
   if l_ler_id is not null and p_pet_id is not null then
      hr_utility.set_location(' BEN_LEE_RSN_F CREATE_LIFE_EVENT_ENROLL_RSN ',20);
      BEN_LIFE_EVENT_ENROLL_RSN_API.CREATE_LIFE_EVENT_ENROLL_RSN(
      P_EFFECTIVE_DATE         => p_effective_date
      ,P_BUSINESS_GROUP_ID     => p_bg_id
      ,P_LEE_RSN_ID            => p_lee_rsn_id
      ,P_LER_ID                => l_ler_id
      ,P_POPL_ENRT_TYP_CYCL_ID => p_pet_id
      ,P_EFFECTIVE_START_DATE  => l_esd
      ,P_EFFECTIVE_END_DATE    => l_eed
      ,P_OBJECT_VERSION_NUMBER => l_ovn
      ,P_CLS_ENRT_DT_TO_USE_CD => 'ELCNSMADE'
      ,P_ENRT_CVG_END_DT_CD    => 'ODBED'
      ,P_ENRT_CVG_STRT_DT_CD   => p_syn_rt_st_dt
      ,P_ENRT_PERD_END_DT_CD   => 'ALDCPPY'
      ,P_ENRT_PERD_STRT_DT_CD  => 'AED'
      ,P_RT_END_DT_CD          => 'ODBED'
      ,P_RT_STRT_DT_CD         => p_syn_rt_st_dt
      );
   end if;
end pgm_le;
procedure create_ptip(p_pgm_id         in number,
                      p_pl_typ_id      in number,
                      p_bg_id          in number,
                      p_effective_date in date,
                      p_ptip_id           out nocopy number) is
   l_ovn number;
   l_esd date;
   l_eed date;
   l_ptip_id number;
begin
   hr_utility.set_location('creating ptip for pgm'||p_pgm_id,1);
   hr_utility.set_location('pl_typ'||p_pl_typ_id,2);
   BEN_PLAN_TYPE_IN_PROGRAM_API.CREATE_PLAN_TYPE_IN_PROGRAM(
   P_EFFECTIVE_DATE                      => p_effective_date
   ,P_BUSINESS_GROUP_ID                  => p_bg_id
   ,P_PGM_ID                             => p_PGM_ID
   ,P_PL_TYP_ID                          => p_PL_TYP_ID
   ,P_PTIP_ID                            => l_ptip_id
   ,P_PTIP_STAT_CD                       => 'A'
   ,P_EFFECTIVE_START_DATE               => l_esd
   ,P_EFFECTIVE_END_DATE                 => l_eed
   ,P_OBJECT_VERSION_NUMBER              => l_ovn
   ,P_ORDR_NUM                           => 1
 /*
   ,P_COORD_CVG_FOR_ALL_PLS_FLAG         => 'N'
   ,P_CRS_THIS_PL_TYP_ONLY_FLAG          => 'N'
   ,P_DPNT_ADRS_RQD_FLAG                 => 'N'
   ,P_DPNT_CVG_NO_CTFN_RQD_FLAG          => 'N'
   ,P_DPNT_DOB_RQD_FLAG                  => 'N'
   ,P_DPNT_LEGV_ID_RQD_FLAG              => 'N'
   ,P_DRVBL_FCTR_APLS_RTS_FLAG           => 'N'
   ,P_DRVBL_FCTR_PRTN_ELIG_FLAG          => 'N'
   ,P_DRVD_FCTR_DPNT_CVG_FLAG            => 'N'
   ,P_ELIG_APLS_FLAG                     => 'N'
   ,P_NO_MN_PL_TYP_OVERID_FLAG           => 'N'
   ,P_NO_MX_PL_TYP_OVRID_FLAG            => 'N'
   ,P_PRTN_ELIG_OVRID_ALWD_FLAG          => 'N'
   ,P_PRVDS_CR_FLAG                      => 'N'
   ,P_SBJ_TO_DPNT_LF_INS_MX_FLAG         => 'N'
   ,P_SBJ_TO_SPS_LF_INS_MX_FLAG          => 'N'
   ,P_TRK_INELIG_PER_FLAG                => 'N'
   ,P_USE_TO_SUM_EE_LF_INS_FLAG          => 'N'
   ,P_WVBL_FLAG                          => 'N'
   ,P_ACRS_PTIP_CVG_ID                   => l_ACRS_PTIP_CVG_ID
   ,P_AUTO_ENRT_MTHD_RL                  => l_AUTO_ENRT_MTHD_RL
   ,P_CMBN_PTIP_ID                       => l_CMBN_PTIP_ID
   ,P_CMBN_PTIP_OPT_ID                   => l_CMBN_PTIP_OPT_ID
   ,P_DFLT_ENRT_CD                       => r_CTP.INFORMATION45
   ,P_DFLT_ENRT_DET_RL                   => l_DFLT_ENRT_DET_RL
   ,P_DPNT_CVG_END_DT_CD                 => r_CTP.INFORMATION36
   ,P_DPNT_CVG_END_DT_RL                 => l_DPNT_CVG_END_DT_RL
   ,P_DPNT_CVG_STRT_DT_CD                => r_CTP.INFORMATION35
   ,P_DPNT_CVG_STRT_DT_RL                => l_DPNT_CVG_STRT_DT_RL
   ,P_DPNT_DSGN_CD                       => r_CTP.INFORMATION34
   ,P_ENRT_CD                            => r_CTP.INFORMATION44
   ,P_ENRT_CVG_END_DT_CD                 => r_CTP.INFORMATION40
   ,P_ENRT_CVG_END_DT_RL                 => l_ENRT_CVG_END_DT_RL
   ,P_ENRT_CVG_STRT_DT_CD                => r_CTP.INFORMATION39
   ,P_ENRT_CVG_STRT_DT_RL                => l_ENRT_CVG_STRT_DT_RL
   ,P_ENRT_MTHD_CD                       => r_CTP.INFORMATION43
   ,P_ENRT_RL                            => l_ENRT_RL
   ,P_IVR_IDENT                          => r_CTP.INFORMATION141
   ,P_MN_ENRD_RQD_OVRID_NUM              => r_CTP.INFORMATION266
   ,P_MX_CVG_ALWD_AMT                    => r_CTP.INFORMATION293
   ,P_MX_ENRD_ALWD_OVRID_NUM             => r_CTP.INFORMATION267
   ,P_PER_CVRD_CD                        => r_CTP.INFORMATION11
   ,P_POSTELCN_EDIT_RL                   => l_POSTELCN_EDIT_RL
   ,P_RQD_ENRT_PERD_TCO_CD               => r_CTP.INFORMATION38
   ,P_RQD_PERD_ENRT_NENRT_RL             => l_RQD_PERD_ENRT_NENRT_RL
   ,P_RQD_PERD_ENRT_NENRT_TM_UOM         => r_CTP.INFORMATION37
   ,P_RQD_PERD_ENRT_NENRT_VAL            => r_CTP.INFORMATION287
   ,P_RT_END_DT_CD                       => r_CTP.INFORMATION42
   ,P_RT_END_DT_RL                       => l_RT_END_DT_RL
   ,P_RT_STRT_DT_CD                      => r_CTP.INFORMATION41
   ,P_RT_STRT_DT_RL                      => l_RT_STRT_DT_RL
   ,P_URL_REF_NAME                       => r_CTP.INFORMATION185
   ,P_VRFY_FMLY_MMBR_CD                  => r_CTP.INFORMATION46
   ,P_VRFY_FMLY_MMBR_RL                  => l_VRFY_FMLY_MMBR_RL
   ,P_SHORT_CODE                         => r_CTP.INFORMATION12
   ,P_SHORT_NAME                         => r_CTP.INFORMATION13
*/
);
p_ptip_id := l_ptip_id;
   hr_utility.set_location('ptip is'||p_ptip_id,3);
end create_ptip;

procedure stage_to_pgi(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date
                       ) is
   cursor c_pgi is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'PGI'
   and   dml_operation in ('INSERT','UPDATE') ;-- only insert/ updates should be there
   --
   r_pgi                     c_pgi%rowtype;

   l_peit_ovn number;
   l_pgm_extra_info_id number;
   l_pgm_id              NUMBER;
   l_pgm_esd             DATE;
   l_pgm_name            VARCHAR2 (240);
begin
   hr_utility.set_location('inside pgm_extra_info_update',10);

    BEGIN
            SELECT information1, information5, information2
              INTO l_pgm_id, l_pgm_name, l_pgm_esd
              FROM ben_copy_entity_results
             WHERE copy_entity_txn_id = p_copy_entity_txn_id
	     and   table_alias = 'PGM'
	     and   result_type_cd='DISPLAY';
         EXCEPTION
            WHEN OTHERS
            THEN
               hr_utility.set_location ('issues in getting pgm name', 10);
               RAISE;
    END;

    open c_pgi;
    loop
    fetch c_pgi into r_pgi;
    exit when c_pgi%notfound;


   if r_pgi.information174 is null then
      hr_utility.set_location('insert pgm extra info ',10);
      ben_pgm_extra_info_api.create_pgm_extra_info
                  ( p_pgm_id                   => l_pgm_id
                   ,p_information_type         => 'PQH_GSP_EXTRA_INFO'
                   ,p_pgi_information_category => 'PQH_GSP_EXTRA_INFO'
                   ,p_pgi_information1         => r_pgi.information11
                   ,p_pgi_information2         => r_pgi.information12
                   ,p_pgi_information3         => r_pgi.information13
		   ,p_pgi_information4         => r_pgi.information14
                   ,p_pgm_extra_info_id        => l_pgm_extra_info_id
                   ,p_object_version_number    => l_peit_ovn
                  );
   else
      hr_utility.set_location('update pgm extra info',10);
      l_peit_ovn := pqh_gsp_stage_to_ben.get_ovn(p_table_name         => 'BEN_PGM_EXTRA_INFO',
                                                 p_key_column_name    => 'PGM_EXTRA_INFO_ID',
                                                 p_key_column_value   =>  r_pgi.information174);
      hr_utility.set_location(' ovn is '||l_peit_ovn,30);
      ben_pgm_extra_info_api.update_pgm_extra_info
                            ( p_pgm_extra_info_id         => r_pgi.information174
                             ,p_object_version_number     => l_peit_ovn
                             ,p_pgi_information1         => r_pgi.information11
                             ,p_pgi_information2         => r_pgi.information12
                             ,p_pgi_information3         => r_pgi.information13
		             ,p_pgi_information4         => r_pgi.information14
                            );
   end if;
   end loop;
   close c_pgi;
   hr_utility.set_location('leaving pgm_extra_info_update',10);
exception
   when others then
      raise;
end stage_to_pgi;

procedure stage_to_ben(p_copy_entity_txn_id in number,
                       p_effective_date     in date,
                       p_business_group_id  in number,
                       p_datetrack_mode     in varchar2,
                       p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
   l_proc varchar2(61) := 'stage_to_ben' ;
   l_effective_date date := p_effective_date;
   l_pl_typ_id number;
/*
order of writing data should be
1) Eligibility profile
2) elig criteria
3) options
4) plans
5) program and ptip and LE linkage
6) oipl
7) plip
8) abr
9) var
10) elig prof linkage with objects
*/
begin
   hr_utility.set_location('inside '||l_proc,10);
   l_pl_typ_id := get_gsp_pt(p_business_group_id => p_business_group_id,
                             p_effective_date    => p_effective_date);
   hr_utility.set_location('pl typ is '||l_pl_typ_id,1);
   stage_to_elp(p_copy_entity_txn_id => p_copy_entity_txn_id,
                p_effective_date     => l_effective_date,
                p_business_group_id  => p_business_group_id,
                p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('elp row update',30);
   stage_to_opt(p_copy_entity_txn_id => p_copy_entity_txn_id,
                p_effective_date     => l_effective_date,
                p_business_group_id  => p_business_group_id,
                p_pl_typ_id          => l_pl_typ_id,
                p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('opt row updated',40);
   stage_to_plan(p_copy_entity_txn_id => p_copy_entity_txn_id,
                 p_effective_date     => l_effective_date,
                 p_business_group_id  => p_business_group_id,
                p_pl_typ_id          => l_pl_typ_id,
                p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('plan row updated',50);
   stage_to_pgm(p_copy_entity_txn_id => p_copy_entity_txn_id,
                p_effective_date     => l_effective_date,
                p_business_group_id  => p_business_group_id,
                p_pl_typ_id          => l_pl_typ_id,
                p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('pgm row updated',60);
   stage_to_pgi(p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_business_group_id => p_business_group_id,
                       p_effective_date   => l_effective_date
                       ) ;
   hr_utility.set_location('pgi row updated',70);
   if p_business_area ='PQH_CORPS_TASK_LIST' then
      pqh_cpd_hr_to_stage.stage_to_corps(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                         p_effective_date     => l_effective_date,
                                         p_business_group_id  => p_business_group_id,
                                         p_datetrack_mode     => p_datetrack_mode);
      hr_utility.set_location('cpd row updated',60);
   end if;
   stage_to_oipl(p_copy_entity_txn_id => p_copy_entity_txn_id,
                 p_effective_date     => l_effective_date,
                 p_business_group_id  => p_business_group_id,
                 p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('oipl row updated',70);
   stage_to_plip(p_copy_entity_txn_id => p_copy_entity_txn_id,
                 p_effective_date     => l_effective_date,
                 p_business_group_id  => p_business_group_id,
                 p_datetrack_mode     => p_datetrack_mode,
                 p_business_area      => p_business_area);
   hr_utility.set_location('plip row updated',70);
   stage_to_abr(p_copy_entity_txn_id => p_copy_entity_txn_id,
                p_effective_date    => l_effective_date,
                p_business_group_id => p_business_group_id,
                p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('abr row updated',70);
   stage_to_vpf(p_copy_entity_txn_id => p_copy_entity_txn_id,
                p_effective_date    => l_effective_date,
                p_business_group_id => p_business_group_id,
                p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('var row updated',70);
   stage_to_epa(p_copy_entity_txn_id => p_copy_entity_txn_id,
                p_effective_date    => l_effective_date,
                p_business_group_id => p_business_group_id,
                p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('epa row updated',70);
   stage_to_cep(p_copy_entity_txn_id => p_copy_entity_txn_id,
                p_effective_date    => l_effective_date,
                p_business_group_id => p_business_group_id,
                p_datetrack_mode     => p_datetrack_mode);
   hr_utility.set_location('cep row updated',70);
exception
   when others then
      hr_utility.set_location('error encountered',420);
      raise;
end stage_to_ben;
procedure stage_to_opt(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_pl_typ_id         in number,
                       p_datetrack_mode     in varchar2) is
   cursor c_OPT is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'OPT'
   and   dml_operation <> 'REUSE' ;
   r_OPT                     c_OPT%rowtype;
   l_proc                    varchar2(61) :='stage_to_opt';
   l_opt_id                  number;
   l_opt_name                varchar2(240);
   l_dt_mode                 varchar2(30);
   l_ovn                     number;
   l_db_ovn                  number;
   l_effective_start_date    date;
   l_pk                      number;
   l_object                  varchar2(80);
   l_effective_end_date      date;
   l_effective_date          date;
   l_message_text            varchar2(2000);
   l_scl_name                varchar2(30);
begin
   hr_utility.set_location('inside '||l_proc,1);
   for r_opt in c_opt loop
       l_opt_id := r_OPT.information1;
       l_ovn    := r_OPT.information265;
       hr_utility.set_location(' l_opt_id '||l_opt_id,2);
       hr_utility.set_location(' point id '||r_opt.information257,3);
       if r_opt.dml_operation in ('INSERT','COPIED','UPD_INS') then
          l_effective_date := pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
       else
          l_effective_date := r_OPT.information2;
       end if;
       l_opt_name := build_opt_name(p_opt_cer_id => r_opt.copy_entity_result_id);
       begin
       if r_opt.dml_operation in ('INSERT','COPIED','UPD_INS')
          and l_opt_id is null
          and r_opt.information257 is not null
          and l_opt_name is not null then
          -- option may have been created thru step api. get the opt id
          l_opt_id := pqh_gsp_hr_to_stage.get_opt_for_point
                         (p_point_id => r_opt.information257,
                          p_effective_date => l_effective_date);
          hr_utility.set_location('opt found'||l_opt_id,5);
          if l_opt_id is null then
             hr_utility.set_location(' BEN_OPT_F CREATE_OPTION_DEFINITION ',4);
             BEN_OPTION_DEFINITION_API.CREATE_OPTION_DEFINITION(
             P_EFFECTIVE_DATE           => l_effective_date
            ,P_BUSINESS_GROUP_ID        => p_business_group_id
            ,P_CMBN_PTIP_OPT_ID         => r_OPT.INFORMATION249
            ,P_COMPONENT_REASON         => r_OPT.INFORMATION13
            ,P_INVK_WV_OPT_FLAG         => nvl(r_OPT.INFORMATION14,'N')
            ,P_MAPPING_TABLE_NAME       => 'PER_SPINAL_POINTS'
            ,P_MAPPING_TABLE_PK_ID      => r_opt.information257
            ,P_NAME                     => l_opt_name
            ,P_OPT_ID                   => l_opt_id
            ,P_RQD_PERD_ENRT_NENRT_RL   => '' -- r_OPT.INFORMATION258
            ,P_RQD_PERD_ENRT_NENRT_UOM  => r_OPT.INFORMATION15
            ,P_RQD_PERD_ENRT_NENRT_VAL  => r_OPT.INFORMATION259
            ,P_SHORT_CODE               => r_OPT.INFORMATION11
            ,P_SHORT_NAME               => r_OPT.INFORMATION12
            ,P_EFFECTIVE_START_DATE     => l_effective_start_date
            ,P_EFFECTIVE_END_DATE       => l_effective_end_date
            ,P_OBJECT_VERSION_NUMBER    => l_ovn
            );
            hr_utility.set_location('opt created'||l_opt_id,5);
            ben_plan_type_option_type_api.create_plan_type_option_type
             (p_pl_typ_opt_typ_id              => l_pk
             ,p_effective_start_date           => l_effective_start_date
             ,p_effective_end_date             => l_effective_end_date
             ,p_pl_typ_opt_typ_cd              => 'GSP'
             ,p_opt_id                         => l_opt_id
             ,p_pl_typ_id                      => p_pl_typ_id
             ,p_business_group_id              => p_Business_Group_id
             ,p_object_version_number          => l_ovn
             ,p_effective_date                 => l_effective_date);
         end if;
         opt_writeback(p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_opt_id             => l_opt_id,
                       p_opt_name           => l_opt_name,
                       p_opt_cer_id         => r_OPT.copy_entity_result_id);
         hr_utility.set_location('opt wrtback comp',8);
      elsif l_opt_id is not null
           and r_opt.dml_operation = 'UPDATE'
           and r_opt.information257 is not null
           and l_opt_name is not null then
           hr_utility.set_location(' BEN_OPT_F UPDATE_OPTION_DEFINITION ',30);
           hr_utility.set_location(' dt mode is '||p_datetrack_mode,30);
           if p_datetrack_mode <> 'CORRECTION' then
              l_dt_mode := get_update_mode('BEN_OPT_F','OPT_ID', l_opt_id, l_effective_date) ;
              hr_utility.set_location(' dt mode is '||l_dt_mode,30);
           else
              l_dt_mode := p_datetrack_mode;
           end if;
           l_db_ovn := get_ovn(p_table_name         => 'BEN_OPT_F',
                               p_key_column_name    => 'OPT_ID',
                               p_key_column_value   => l_opt_id,
                               p_effective_date     => l_effective_date);
           hr_utility.set_location(' ovn is '||l_db_ovn,30);
           if l_db_ovn <> l_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','OPT');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ',l_opt_name);
              fnd_message.raise_error;
           else
              BEN_OPTION_DEFINITION_API.UPDATE_OPTION_DEFINITION(
              P_EFFECTIVE_DATE           => l_effective_date
              ,P_BUSINESS_GROUP_ID       => p_business_group_id
              ,P_COMPONENT_REASON        => r_OPT.INFORMATION13
              ,P_INVK_WV_OPT_FLAG        => r_OPT.INFORMATION14
              ,P_MAPPING_TABLE_NAME      => r_OPT.INFORMATION141
              ,P_MAPPING_TABLE_PK_ID     => r_opt.information257
              ,P_NAME                    => l_opt_name
              ,P_OPT_ID                  => l_opt_id
              ,P_RQD_PERD_ENRT_NENRT_RL  => ''
              ,P_RQD_PERD_ENRT_NENRT_UOM => r_OPT.INFORMATION15
              ,P_RQD_PERD_ENRT_NENRT_VAL => r_OPT.INFORMATION259
              ,P_SHORT_CODE              => r_OPT.INFORMATION11
              ,P_SHORT_NAME              => r_OPT.INFORMATION12
              ,P_EFFECTIVE_START_DATE    => l_effective_start_date
              ,P_EFFECTIVE_END_DATE      => l_effective_end_date
              ,P_OBJECT_VERSION_NUMBER   => l_ovn
              ,P_DATETRACK_MODE          => l_dt_mode
              );
           end if;
       elsif r_opt.dml_operation in ('DELETE') then
          hr_utility.set_location('nothing needs to be done',100);
       else
          l_message_text := 'invalid dml_oper is '||r_opt.dml_operation
          ||' opt id is '||l_opt_id
          ||' opt name is '||l_opt_name
          ||' opt ovn is '||l_ovn
          ||' point id is '||r_opt.information257;
          PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
          (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
          P_TXN_ID          => nvl(l_opt_id,p_copy_entity_txn_id),
          P_MODULE_CD       => 'PQH_GSP_STGBEN',
          p_context         => 'OPT',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => l_message_text,
          p_effective_date  => p_effective_date);
       end if;
       exception when others then
          hr_utility.set_location('issues in writing opt, skipping'||l_proc,100);
          raise;
       end;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => nvl(l_opt_id,p_copy_entity_txn_id),
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'OPT',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'OPT',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_opt;
procedure stage_to_plan(p_copy_entity_txn_id in number,
                        p_business_group_id in number,
                        p_effective_date    in date,
                        p_pl_typ_id         in number,
                        p_datetrack_mode     in varchar2) is
   cursor c_pln is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'PLN'
   and   dml_operation <> 'REUSE' ;
   r_pln                    c_pln%rowtype;
   l_proc                   varchar2(61) :='stage_to_pln';
   l_pl_id                  number ;
   l_pl_name                varchar2(240);
   l_ovn                    number ;
   l_object                  varchar2(80);
   l_db_ovn                  number;
   l_effective_start_date   date ;
   l_effective_end_date     date ;
   l_effective_date         date;
   l_message_text            varchar2(2000);
   l_dt_mode                varchar2(30);
begin
   hr_utility.set_location('inside '||l_proc,1);
   for r_pln in c_pln loop
       l_pl_id := r_pln.information1;
       l_ovn   := r_pln.information265;
       hr_utility.set_location('for pln_id:'||l_pl_id ||'dml '||r_pln.dml_operation,2);
       if r_pln.dml_operation in ('INSERT','COPIED','UPD_INS') then
          l_effective_date := pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
       else
          l_effective_date := r_pln.information2;
       end if;
       hr_utility.set_location('effdt is :'||to_char(l_effective_date,'DD/MM/RRRR'),3);
       hr_utility.set_location('pl typ id is :'||p_pl_typ_id,4);
       hr_utility.set_location('grd id is :'||r_pln.information294,5);
       l_pl_name := nvl(r_PLN.INFORMATION170,r_PLN.INFORMATION5);
       begin
       if l_pl_id is null and r_pln.dml_operation in ('INSERT','COPIED','UPD_INS')
          and r_pln.information294 is not null then
           hr_utility.set_location(' BEN_PL_F CREATE_PLAN ',4);
           BEN_PLAN_API.CREATE_PLAN(
             P_EFFECTIVE_DATE                      => l_effective_date
             ,P_BUSINESS_GROUP_ID                  => p_business_group_id
             ,P_ACTL_PREM_ID                       => r_PLN.INFORMATION250
	     ,P_ALWS_QDRO_FLAG                     => nvl(r_PLN.INFORMATION36,'N')
	     ,P_ALWS_QMCSO_FLAG                    => nvl(r_PLN.INFORMATION37,'N')
	     ,P_ALWS_REIMBMTS_FLAG                 => nvl(r_PLN.INFORMATION51,'N')
	     ,P_ALWS_TMPRY_ID_CRD_FLAG             => nvl(r_PLN.INFORMATION24,'N')
	     ,P_ALWS_UNRSTRCTD_ENRT_FLAG           => nvl(r_PLN.INFORMATION52,'N')
	     ,P_AUTO_ENRT_MTHD_RL                  => r_PLN.INFORMATION281
	     ,P_BNDRY_PERD_CD                      => r_PLN.INFORMATION101
	     ,P_BNFT_OR_OPTION_RSTRCTN_CD          => r_PLN.INFORMATION77
	     ,P_BNFT_PRVDR_POOL_ID                 => r_PLN.INFORMATION235
	     ,P_BNF_ADDL_INSTN_TXT_ALWD_FLAG       => nvl(r_PLN.INFORMATION53,'N')
	     ,P_BNF_ADRS_RQD_FLAG                  => nvl(r_PLN.INFORMATION54,'N')
	     ,P_BNF_CNTNGT_BNFS_ALWD_FLAG          => nvl(r_PLN.INFORMATION56,'N')
	     ,P_BNF_CTFN_RQD_FLAG                  => nvl(r_PLN.INFORMATION55,'N')
	     ,P_BNF_DFLT_BNF_CD                    => r_PLN.INFORMATION82
	     ,P_BNF_DOB_RQD_FLAG                   => nvl(r_PLN.INFORMATION66,'N')
	     ,P_BNF_DSGE_MNR_TTEE_RQD_FLAG         => nvl(r_PLN.INFORMATION60,'N')
	     ,P_BNF_DSGN_CD                        => r_PLN.INFORMATION89
	     ,P_BNF_INCRMT_AMT                     => r_PLN.INFORMATION302
	     ,P_BNF_LEGV_ID_RQD_FLAG               => nvl(r_PLN.INFORMATION57,'N')
	     ,P_BNF_MAY_DSGT_ORG_FLAG              => nvl(r_PLN.INFORMATION58,'N')
	     ,P_BNF_MN_DSGNTBL_AMT                 => r_PLN.INFORMATION303
	     ,P_BNF_MN_DSGNTBL_PCT_VAL             => r_PLN.INFORMATION290
	     ,P_BNF_PCT_AMT_ALWD_CD                => r_PLN.INFORMATION83
	     ,P_BNF_PCT_INCRMT_VAL                 => r_PLN.INFORMATION293
	     ,P_BNF_QDRO_RL_APLS_FLAG              => nvl(r_PLN.INFORMATION59,'N')
	     ,P_CMPR_CLMS_TO_CVG_OR_BAL_CD         => r_PLN.INFORMATION84
	     ,P_COBRA_PYMT_DUE_DY_NUM              => r_PLN.INFORMATION285
	     ,P_COST_ALLOC_KEYFLEX_1_ID            => r_PLN.INFORMATION287
	     ,P_COST_ALLOC_KEYFLEX_2_ID            => r_PLN.INFORMATION288
	     ,P_CVG_INCR_R_DECR_ONLY_CD            => r_PLN.INFORMATION68
	     ,P_DFLT_TO_ASN_PNDG_CTFN_CD           => r_PLN.INFORMATION91
	     ,P_DFLT_TO_ASN_PNDG_CTFN_RL           => r_PLN.INFORMATION272
	     ,P_DPNT_ADRS_RQD_FLAG                 => nvl(r_PLN.INFORMATION30,'N')
	     ,P_DPNT_CVD_BY_OTHR_APLS_FLAG         => nvl(r_PLN.INFORMATION29,'N')
	     ,P_DPNT_CVG_END_DT_CD                 => r_PLN.INFORMATION85
	     ,P_DPNT_CVG_END_DT_RL                 => r_PLN.INFORMATION258
	     ,P_DPNT_CVG_STRT_DT_CD                => r_PLN.INFORMATION86
	     ,P_DPNT_CVG_STRT_DT_RL                => r_PLN.INFORMATION259
	     ,P_DPNT_DOB_RQD_FLAG                  => nvl(r_PLN.INFORMATION32,'N')
	     ,P_DPNT_DSGN_CD                       => r_PLN.INFORMATION87
	     ,P_DPNT_LEG_ID_RQD_FLAG               => nvl(r_PLN.INFORMATION31,'N')
	     ,P_DPNT_NO_CTFN_RQD_FLAG              => nvl(r_PLN.INFORMATION27,'N')
	     ,P_DRVBL_DPNT_ELIG_FLAG               => nvl(r_PLN.INFORMATION25,'N')
	     ,P_DRVBL_FCTR_APLS_RTS_FLAG           => nvl(r_PLN.INFORMATION33,'N')
	     ,P_DRVBL_FCTR_PRTN_ELIG_FLAG          => nvl(r_PLN.INFORMATION26,'N')
	     ,P_ELIG_APLS_FLAG                     => nvl(r_PLN.INFORMATION34,'N')
	     ,P_ENRT_CD                            => r_PLN.INFORMATION17
	     ,P_ENRT_CVG_END_DT_CD                 => r_PLN.INFORMATION21
	     ,P_ENRT_CVG_END_DT_RL                 => r_PLN.INFORMATION260
	     ,P_ENRT_CVG_STRT_DT_CD                => r_PLN.INFORMATION20
	     ,P_ENRT_CVG_STRT_DT_RL                => r_PLN.INFORMATION262
	     ,P_ENRT_MTHD_CD                       => r_PLN.INFORMATION92
	     ,P_ENRT_PL_OPT_FLAG                   => nvl(r_PLN.INFORMATION39,'N')
	     ,P_ENRT_RL                            => r_PLN.INFORMATION274
	     ,P_FRFS_APLY_FLAG                     => nvl(r_PLN.INFORMATION40,'N')
	     ,P_FRFS_CNTR_DET_CD                   => r_PLN.INFORMATION96
	     ,P_FRFS_DISTR_DET_CD                  => r_PLN.INFORMATION97
	     ,P_FRFS_DISTR_MTHD_CD                 => r_PLN.INFORMATION13
	     ,P_FRFS_DISTR_MTHD_RL                 => r_PLN.INFORMATION257
	     ,P_FRFS_MX_CRYFWD_VAL                 => r_PLN.INFORMATION304
	     ,P_FRFS_PORTION_DET_CD                => r_PLN.INFORMATION100
	     ,P_FRFS_VAL_DET_CD                    => r_PLN.INFORMATION99
	     ,P_FUNCTION_CODE                      => r_PLN.INFORMATION95
	     ,P_HC_PL_SUBJ_HCFA_APRVL_FLAG         => nvl(r_PLN.INFORMATION47,'N')
	     ,P_HC_SVC_TYP_CD                      => r_PLN.INFORMATION15
	     ,P_HGHLY_CMPD_RL_APLS_FLAG            => nvl(r_PLN.INFORMATION38,'N')
	     ,P_IMPTD_INCM_CALC_CD                 => r_PLN.INFORMATION73
	     ,P_INCPTN_DT                          => r_PLN.INFORMATION306
	     ,P_INVK_DCLN_PRTN_PL_FLAG             => nvl(r_PLN.INFORMATION50,'N')
	     ,P_INVK_FLX_CR_PL_FLAG                => nvl(r_PLN.INFORMATION49,'N')
	     ,P_IVR_IDENT                          => r_PLN.INFORMATION142
	     ,P_MAPPING_TABLE_NAME                 => 'PER_GRADES'
	     ,P_MAPPING_TABLE_PK_ID                => r_PLN.INFORMATION294
	     ,P_MAY_ENRL_PL_N_OIPL_FLAG            => nvl(r_PLN.INFORMATION28,'N')
	     ,P_MN_CVG_RL                          => r_PLN.INFORMATION283
	     ,P_MN_CVG_RQD_AMT                     => r_PLN.INFORMATION300
	     ,P_MN_OPTS_RQD_NUM                    => r_PLN.INFORMATION269
	     ,P_MX_CVG_ALWD_AMT                    => r_PLN.INFORMATION299
	     ,P_MX_CVG_INCR_ALWD_AMT               => r_PLN.INFORMATION297
	     ,P_MX_CVG_INCR_WCF_ALWD_AMT           => r_PLN.INFORMATION298
	     ,P_MX_CVG_MLT_INCR_NUM                => r_PLN.INFORMATION271
	     ,P_MX_CVG_MLT_INCR_WCF_NUM            => r_PLN.INFORMATION273
	     ,P_MX_CVG_RL                          => r_PLN.INFORMATION284
	     ,P_MX_CVG_WCFN_AMT                    => r_PLN.INFORMATION295
	     ,P_MX_CVG_WCFN_MLT_NUM                => r_PLN.INFORMATION267
	     ,P_MX_OPTS_ALWD_NUM                   => r_PLN.INFORMATION270
	     ,P_MX_WTG_DT_TO_USE_CD                => r_PLN.INFORMATION80
	     ,P_MX_WTG_DT_TO_USE_RL                => r_PLN.INFORMATION275
	     ,P_MX_WTG_PERD_PRTE_UOM               => r_PLN.INFORMATION79
	     ,P_MX_WTG_PERD_PRTE_VAL               => r_PLN.INFORMATION289
	     ,P_MX_WTG_PERD_RL                     => r_PLN.INFORMATION282
	     ,P_NAME                               => l_pl_name
	     ,P_NIP_ACTY_REF_PERD_CD               => r_PLN.INFORMATION16
	     ,P_NIP_DFLT_ENRT_CD                   => r_PLN.INFORMATION88
	     ,P_NIP_DFLT_ENRT_DET_RL               => r_PLN.INFORMATION286
	     ,P_NIP_DFLT_FLAG                      => nvl(r_PLN.INFORMATION12,'N')
	     ,P_NIP_ENRT_INFO_RT_FREQ_CD           => r_PLN.INFORMATION22
	     ,P_NIP_PL_UOM                         => r_PLN.INFORMATION81
	     ,P_NO_MN_CVG_AMT_APLS_FLAG            => nvl(r_PLN.INFORMATION61,'N')
	     ,P_NO_MN_CVG_INCR_APLS_FLAG           => nvl(r_PLN.INFORMATION63,'N')
	     ,P_NO_MN_OPTS_NUM_APLS_FLAG           => nvl(r_PLN.INFORMATION65,'N')
	     ,P_NO_MX_CVG_AMT_APLS_FLAG            => nvl(r_PLN.INFORMATION62,'N')
	     ,P_NO_MX_CVG_INCR_APLS_FLAG           => nvl(r_PLN.INFORMATION64,'N')
	     ,P_NO_MX_OPTS_NUM_APLS_FLAG           => nvl(r_PLN.INFORMATION35,'N')
	     ,P_ORDR_NUM                           => r_PLN.INFORMATION266
	     ,P_PER_CVRD_CD                        => r_PLN.INFORMATION76
	     ,P_PL_CD                              => 'MSTBPGM'
	     ,P_PL_ID                              => l_pl_id
	     ,P_PL_STAT_CD                         => 'A'
	     ,P_PL_TYP_ID                          => p_pl_typ_id
	     ,P_PL_YR_NOT_APPLCBL_FLAG             => nvl(r_PLN.INFORMATION14,'N')
	     ,P_POSTELCN_EDIT_RL                   => r_PLN.INFORMATION279
	     ,P_POST_TO_GL_FLAG                    => nvl(r_PLN.INFORMATION98,'N')
	     ,P_PRMRY_FNDG_MTHD_CD                 => r_PLN.INFORMATION90
	     ,P_PRORT_PRTL_YR_CVG_RSTRN_CD         => r_PLN.INFORMATION18
	     ,P_PRORT_PRTL_YR_CVG_RSTRN_RL         => r_PLN.INFORMATION268
	     ,P_PRTN_ELIG_OVRID_ALWD_FLAG          => nvl(r_PLN.INFORMATION46,'N')
	     ,P_RQD_PERD_ENRT_NENRT_RL             => r_PLN.INFORMATION276
	     ,P_RQD_PERD_ENRT_NENRT_UOM            => r_PLN.INFORMATION69
	     ,P_RQD_PERD_ENRT_NENRT_VAL            => r_PLN.INFORMATION301
	     ,P_RT_END_DT_CD                       => r_PLN.INFORMATION74
	     ,P_RT_END_DT_RL                       => r_PLN.INFORMATION277
	     ,P_RT_STRT_DT_CD                      => r_PLN.INFORMATION75
	     ,P_RT_STRT_DT_RL                      => r_PLN.INFORMATION278
	     ,P_SHORT_CODE                         => r_PLN.INFORMATION93
	     ,P_SHORT_NAME                         => r_PLN.INFORMATION94
	     ,P_SUBJ_TO_IMPTD_INCM_TYP_CD          => r_PLN.INFORMATION71
	     ,P_SVGS_PL_FLAG                       => nvl(r_PLN.INFORMATION41,'N')
	     ,P_TRK_INELIG_PER_FLAG                => nvl(r_PLN.INFORMATION42,'N')
	     ,P_UNSSPND_ENRT_CD                    => r_PLN.INFORMATION72
	     ,P_URL_REF_NAME                       => r_PLN.INFORMATION185
	     ,P_USE_ALL_ASNTS_ELIG_FLAG            => nvl(r_PLN.INFORMATION43,'N')
	     ,P_USE_ALL_ASNTS_FOR_RT_FLAG          => nvl(r_PLN.INFORMATION44,'N')
	     ,P_VRFY_FMLY_MMBR_CD                  => r_PLN.INFORMATION23
	     ,P_VRFY_FMLY_MMBR_RL                  => r_PLN.INFORMATION264
	     ,P_VSTG_APLS_FLAG                     => nvl(r_PLN.INFORMATION45,'N')
             ,P_WVBL_FLAG                          => nvl(r_PLN.INFORMATION48,'N')
             ,P_EFFECTIVE_START_DATE               => l_effective_start_date
             ,P_EFFECTIVE_END_DATE                 => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER              => l_ovn
           );
           hr_utility.set_location('After pl insert'||l_pl_id,12);
           pln_writeback(p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_pl_id              => l_pl_id,
                         p_pl_name            => l_pl_name,
                         p_pl_cer_id          => r_PLN.copy_entity_result_id,
                         p_plip_cer_id        => r_PLN.gs_mirror_src_entity_result_id);
           hr_utility.set_location('pl wrtback comp ',15);
         elsif r_pln.dml_operation = 'UPDATE' and l_pl_id is not null
               and r_pln.information294 is not null then
           hr_utility.set_location(' BEN_PL_F UPDATE_PLAN ',30);
           hr_utility.set_location(' dt mode is '||p_datetrack_mode,30);
           if p_datetrack_mode <> 'CORRECTION' then
              l_dt_mode := get_update_mode(p_table_name  => 'BEN_PL_F',
                                           p_key_column_name => 'PL_ID',
                                           p_key_column_value => l_pl_id,
                                           p_effective_date => l_effective_date);
              hr_utility.set_location(' dt mode is '||l_dt_mode,30);
           else
              l_dt_mode := p_datetrack_mode;
           end if;
           l_db_ovn := get_ovn(p_table_name         => 'BEN_PL_F',
                               p_key_column_name    => 'PL_ID',
                               p_key_column_value   => l_pl_id,
                               p_effective_date     => l_effective_date);
           hr_utility.set_location(' ovn is '||l_db_ovn,30);
           if l_db_ovn <> l_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','PLN');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ',l_pl_name);
              fnd_message.raise_error;
           else
              BEN_PLAN_API.UPDATE_PLAN(
              P_EFFECTIVE_DATE                      => l_effective_date
             ,P_BUSINESS_GROUP_ID                  => p_business_group_id
	     ,P_NAME                               => l_pl_name
	     ,P_SHORT_CODE                         => r_PLN.INFORMATION93
	     ,P_SHORT_NAME                         => r_PLN.INFORMATION94
	     ,P_PL_ID                              => l_pl_id
	     ,P_RT_STRT_DT_RL                      => ''
	     ,P_VRFY_FMLY_MMBR_RL                  => ''
             ,P_EFFECTIVE_START_DATE               => l_effective_start_date
             ,P_EFFECTIVE_END_DATE                 => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER              => l_ovn
             ,P_DATETRACK_MODE                     => l_dt_mode
             );
           end if;
         else
            l_message_text := 'invalid dml_oper is'||r_pln.dml_operation
            ||' pl_id is'||l_pl_id
            ||' pl_ovn is'||l_ovn
            ||' grd_id is'||r_pln.information294;
            PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
            (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
            P_TXN_ID          => nvl(l_pl_id,p_copy_entity_txn_id),
            P_MODULE_CD       => 'PQH_GSP_STGBEN',
            p_context         => 'PLN',
            P_MESSAGE_TYPE_CD => 'E',
            P_MESSAGE_TEXT    => l_message_text,
            p_effective_date  => p_effective_date);
         end if;
       exception when others then
          hr_utility.set_location('issues in writing pln'||l_proc,100);
          raise;
       end;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'PLN',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'PLN',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_plan;
procedure stage_to_pgm(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_pl_typ_id         in number,
                       p_datetrack_mode     in varchar2) is
   cursor c_pgm is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'PGM'
   and   dml_operation in ('INSERT','UPDATE') ;-- only insert/ updates should be there
   --
   r_pgm                     c_pgm%rowtype;
   l_proc                    varchar2(61) :='stage_to_pgm';
   l_pgm_id                  number ;
   l_pet_id                  number ;
   l_pgm_cer_id              number ;
   l_lee_rsn_id              number ;
   l_object                  varchar2(80);
   l_ovn                     number ;
   l_message_text            varchar2(2000);
   l_db_ovn                  number;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_effective_date          date;
   l_ptip_id                 number;
   l_sal_upd_cd              varchar2(30);
   l_dflt_step_cd            varchar2(30);
   l_dt_mode                 varchar2(30);
begin
   hr_utility.set_location('inside '||l_proc,10);
   for r_pgm in c_pgm loop
       l_pgm_id := r_pgm.information1;
       l_ovn    := r_pgm.information265;
       hr_utility.set_location('for pgm_id:'||l_pgm_id ||'dml '||r_pgm.dml_operation,20);
       l_effective_date := r_pgm.information2;
       l_pgm_cer_id     := r_pgm.copy_entity_result_id;
       if r_pgm.information16 = 'N' then
          l_sal_upd_cd := 'NO_UPDATE' ;
       else
          l_sal_upd_cd := r_pgm.information71;
       end if;
       if r_pgm.information51 in ('PQH_GSP_GP','PQH_GSP_SP','PQH_GSP_NP') then
          l_dflt_step_cd := r_pgm.information51;
       else
          l_dflt_step_cd := nvl(r_pgm.information14,'MINSTEP');
       end if;
       hr_utility.set_location('dflt_step_cd is'||l_dflt_step_cd,3);
       hr_utility.set_location('l_sal_upd_cd is'||l_sal_upd_cd,4);
       if l_pgm_id is null and r_pgm.dml_operation = 'INSERT' then
           hr_utility.set_location('dflt_step '||l_dflt_step_cd,1);
           hr_utility.set_location('sal_upd '||l_sal_upd_cd,2);
           hr_utility.set_location(' BEN_PGM_F CREATE_PROGRAM ',20);
           begin
           BEN_PROGRAM_API.CREATE_PROGRAM(
             P_EFFECTIVE_DATE                 => l_effective_date
             ,P_BUSINESS_GROUP_ID             => p_business_group_id
             ,P_ACTY_REF_PERD_CD              => r_PGM.INFORMATION41
	     ,P_ALWS_UNRSTRCTD_ENRT_FLAG      => nvl(r_PGM.INFORMATION36,'N')
	     ,P_AUTO_ENRT_MTHD_RL             => r_PGM.INFORMATION272
	     ,P_COORD_CVG_FOR_ALL_PLS_FLG     => nvl(r_PGM.INFORMATION30,'N')
	     ,P_DFLT_ELEMENT_TYPE_ID          => r_PGM.INFORMATION257
	     ,P_DFLT_INPUT_VALUE_ID           => r_PGM.INFORMATION258
	     ,P_DFLT_PGM_FLAG                 => nvl(r_PGM.INFORMATION13,'N')
	     ,P_DFLT_STEP_CD                  => l_dflt_step_cd
	     ,P_PGM_STAT_CD                   => 'A'
	     ,P_UPDATE_SALARY_CD              => l_sal_upd_cd
	     ,P_ENRT_CD                       => 'CCKCNCC'
	     ,P_DFLT_STEP_RL                  => r_PGM.INFORMATION259
	     ,P_DPNT_ADRS_RQD_FLAG            => nvl(r_PGM.INFORMATION21,'N')
	     ,P_DPNT_CVG_END_DT_CD            => r_PGM.INFORMATION43
	     ,P_DPNT_CVG_END_DT_RL            => r_PGM.INFORMATION269
	     ,P_DPNT_CVG_STRT_DT_CD           => r_PGM.INFORMATION44
	     ,P_DPNT_CVG_STRT_DT_RL           => r_PGM.INFORMATION268
	     ,P_DPNT_DOB_RQD_FLAG             => nvl(r_PGM.INFORMATION23,'N')
	     ,P_DPNT_DSGN_CD                  => r_PGM.INFORMATION40
	     ,P_DPNT_DSGN_LVL_CD              => r_PGM.INFORMATION37
	     ,P_DPNT_DSGN_NO_CTFN_RQD_FLAG    => nvl(r_PGM.INFORMATION31,'N')
	     ,P_DPNT_LEGV_ID_RQD_FLAG         => nvl(r_PGM.INFORMATION25,'N')
	     ,P_DRVBL_FCTR_APLS_RTS_FLAG      => nvl(r_PGM.INFORMATION34,'N')
	     ,P_DRVBL_FCTR_DPNT_ELIG_FLAG     => nvl(r_PGM.INFORMATION32,'N')
	     ,P_DRVBL_FCTR_PRTN_ELIG_FLAG     => nvl(r_PGM.INFORMATION33,'N')
	     ,P_ELIG_APLS_FLAG                => nvl(r_PGM.INFORMATION26,'N')
	     ,P_ENRT_CVG_END_DT_CD            => 'ODBED'
	     ,P_ENRT_CVG_END_DT_RL            => r_PGM.INFORMATION266
	     ,P_ENRT_CVG_STRT_DT_CD           => nvl(r_PGM.INFORMATION45,'AED')
	     ,P_ENRT_CVG_STRT_DT_RL           => r_PGM.INFORMATION267
	     ,P_ENRT_INFO_RT_FREQ_CD          => 'MO'
	     ,P_ENRT_MTHD_CD                  => r_PGM.INFORMATION52
	     ,P_ENRT_RL                       => r_PGM.INFORMATION273
	     ,P_IVR_IDENT                     => r_PGM.INFORMATION141
	     ,P_MX_DPNT_PCT_PRTT_LF_AMT       => r_PGM.INFORMATION287
	     ,P_MX_SPS_PCT_PRTT_LF_AMT        => r_PGM.INFORMATION288
	     ,P_NAME                          => r_PGM.INFORMATION170
	     ,P_PER_CVRD_CD                   => r_PGM.INFORMATION20
	     ,P_PGM_DESC                      => r_PGM.INFORMATION219
	     ,P_PGM_GRP_CD                    => r_PGM.INFORMATION49
	     ,P_PGM_ID                        => l_pgm_id
	     ,P_PGM_PRVDS_NO_AUTO_ENRT_FLAG   => nvl(r_PGM.INFORMATION22,'N')
	     ,P_PGM_PRVDS_NO_DFLT_ENRT_FLAG   => nvl(r_PGM.INFORMATION24,'N')
	     ,P_PGM_TYP_CD                    => r_PGM.INFORMATION39
	     ,P_PGM_UOM                       => r_PGM.INFORMATION50
	     ,P_PGM_USE_ALL_ASNTS_ELIG_FLAG   => nvl(r_PGM.INFORMATION29,'N')
--	     ,P_POE_LVL_CD                    => r_PGM.INFORMATION53
	     ,P_PRTN_ELIG_OVRID_ALWD_FLAG     => nvl(r_PGM.INFORMATION28,'N')
	     ,P_RT_END_DT_CD                  => nvl(r_PGM.INFORMATION48,'ODBED')
	     ,P_RT_END_DT_RL                  => r_PGM.INFORMATION271
	     ,P_RT_STRT_DT_CD                 => nvl(r_PGM.INFORMATION47,'AED')
	     ,P_RT_STRT_DT_RL                 => r_PGM.INFORMATION270
	     ,P_SCORES_CALC_MTHD_CD           => r_PGM.INFORMATION15
	     ,P_SCORES_CALC_RL                => r_PGM.INFORMATION261
	     ,P_SHORT_CODE                    => r_PGM.INFORMATION11
	     ,P_SHORT_NAME                    => r_PGM.INFORMATION12
	     ,P_TRK_INELIG_PER_FLAG           => nvl(r_PGM.INFORMATION35,'N')
	     ,P_URL_REF_NAME                  => r_PGM.INFORMATION185
	     ,P_USES_ALL_ASMTS_FOR_RTS_FLAG   => nvl(r_PGM.INFORMATION27,'N')
	     ,P_USE_MULTI_PAY_RATES_FLAG      => nvl(r_PGM.INFORMATION17,'N')
	     ,P_USE_PROG_POINTS_FLAG          => nvl(r_PGM.INFORMATION18,'N')
	     ,P_USE_SCORES_CD                 => r_PGM.INFORMATION19
	     ,P_VRFY_FMLY_MMBR_CD             => r_PGM.INFORMATION54
             ,P_VRFY_FMLY_MMBR_RL             => r_PGM.INFORMATION274
             ,P_USE_VARIABLE_RATES_FLAG       => NVL(r_PGM.INFORMATION69,'N')
             ,P_SALARY_CALC_MTHD_CD           => r_PGM.INFORMATION70
             ,P_GSP_ALLOW_OVERRIDE_FLAG       => NVL(r_PGM.INFORMATION72,'N')
             ,P_SALARY_CALC_MTHD_RL           => r_PGM.INFORMATION293
             ,P_EFFECTIVE_START_DATE          => l_effective_start_date
             ,P_EFFECTIVE_END_DATE            => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER         => l_ovn
           );
           exception when others then
              hr_utility.set_location('issues in creating pgm, skipping',100);
              raise;
           end;
           hr_utility.set_location('After pgm insert '||l_pgm_id,1);
           create_ptip(p_pgm_id         => l_pgm_id,
                       p_pl_typ_id      => p_pl_typ_id,
                       p_bg_id          => p_business_group_id,
                       p_effective_date => p_effective_date,
                       p_ptip_id        => l_ptip_id);
           hr_utility.set_location('ptip id is '||l_ptip_id,2);
           pgm_enrl(p_pgm_id         => l_pgm_id,
                    p_bg_id          => p_business_group_id,
                    p_effective_date => p_effective_date,
                    p_pet_id         => l_pet_id);
           hr_utility.set_location('pet id is '||l_pet_id,2);
           if l_pet_id is not null then
              pgm_le(p_pgm_id         => l_pgm_id,
                     p_bg_id          => p_business_group_id,
                     p_effective_date => p_effective_date,
                     p_pet_id         => l_pet_id,
                     p_pro_cvg_st_dt  => nvl(r_PGM.INFORMATION45,'AED'),
                     p_pro_rt_st_dt   => nvl(r_PGM.INFORMATION47,'AED'),
                     p_syn_rt_st_dt   => nvl(r_PGM.INFORMATION53,'AED'),
                     p_lee_rsn_id     => l_lee_rsn_id) ;
              hr_utility.set_location('lee_rsn id is '||l_lee_rsn_id,3);
           end if;
           pgm_writeback(p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_pgm_id     => l_pgm_id,
                         p_pgm_cer_id => l_pgm_cer_id,
                         p_ptip_id    => l_ptip_id);
           hr_utility.set_location('pgm writeback comp ',3);
           --
         elsif r_pgm.dml_operation ='UPDATE' and l_pgm_id is not null then
           hr_utility.set_location(' BEN_PGM_F UPDATE_PROGRAM ',30);
           hr_utility.set_location(' dt mode is '||p_datetrack_mode,30);
           if p_datetrack_mode <> 'CORRECTION' then
              l_dt_mode := get_update_mode(p_table_name  => 'BEN_PGM_F',
                                           p_key_column_name => 'PGM_ID',
                                           p_key_column_value => l_pgm_id,
                                           p_effective_date => l_effective_date);
              hr_utility.set_location(' dt mode is '||l_dt_mode,30);
           else
              l_dt_mode := p_datetrack_mode;
           end if;
           l_db_ovn := get_ovn(p_table_name         => 'BEN_PGM_F',
                               p_key_column_name    => 'PGM_ID',
                               p_key_column_value   => l_pgm_id,
                               p_effective_date     => l_effective_date);
           hr_utility.set_location(' ovn is '||l_db_ovn,30);
           if l_db_ovn <> l_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','PGM');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ',r_pgm.information170);
              fnd_message.raise_error;
           else
           BEN_PROGRAM_API.UPDATE_PROGRAM(
             P_EFFECTIVE_DATE                    => l_effective_date
             ,P_BUSINESS_GROUP_ID                => p_business_group_id
	     ,P_ENRT_CD                          => 'CCKCNCC'
             ,P_ACTY_REF_PERD_CD                 => r_PGM.INFORMATION41
	     ,P_ALWS_UNRSTRCTD_ENRT_FLAG         => r_PGM.INFORMATION36
	     ,P_AUTO_ENRT_MTHD_RL                => r_PGM.INFORMATION272
	     ,P_COORD_CVG_FOR_ALL_PLS_FLG        => r_PGM.INFORMATION30
	     ,P_DFLT_ELEMENT_TYPE_ID             => r_PGM.INFORMATION257
	     ,P_DFLT_INPUT_VALUE_ID              => r_PGM.INFORMATION258
	     ,P_DFLT_PGM_FLAG                    => r_PGM.INFORMATION13
	     ,P_DFLT_STEP_CD                     => l_dflt_step_cd
	     ,P_DFLT_STEP_RL                     => r_PGM.INFORMATION259
	     ,P_DPNT_ADRS_RQD_FLAG               => r_PGM.INFORMATION21
	     ,P_DPNT_CVG_END_DT_CD               => r_PGM.INFORMATION43
	     ,P_DPNT_CVG_END_DT_RL               => r_PGM.INFORMATION269
	     ,P_DPNT_CVG_STRT_DT_CD              => r_PGM.INFORMATION44
	     ,P_DPNT_CVG_STRT_DT_RL              => r_PGM.INFORMATION268
	     ,P_DPNT_DOB_RQD_FLAG                => r_PGM.INFORMATION23
	     ,P_DPNT_DSGN_CD                     => r_PGM.INFORMATION40
	     ,P_DPNT_DSGN_LVL_CD                 => r_PGM.INFORMATION37
	     ,P_DPNT_DSGN_NO_CTFN_RQD_FLAG       => r_PGM.INFORMATION31
	     ,P_DPNT_LEGV_ID_RQD_FLAG            => r_PGM.INFORMATION25
	     ,P_DRVBL_FCTR_APLS_RTS_FLAG         => r_PGM.INFORMATION34
	     ,P_DRVBL_FCTR_DPNT_ELIG_FLAG        => r_PGM.INFORMATION32
	     ,P_DRVBL_FCTR_PRTN_ELIG_FLAG        => r_PGM.INFORMATION33
	     ,P_ELIG_APLS_FLAG                   => r_PGM.INFORMATION26
	     ,P_ENRT_CVG_END_DT_CD               => nvl(r_PGM.INFORMATION42,'ODBED')
	     ,P_ENRT_CVG_END_DT_RL               => r_PGM.INFORMATION266
	     ,P_ENRT_CVG_STRT_DT_CD              => nvl(r_PGM.INFORMATION45,'AED')
	     ,P_ENRT_CVG_STRT_DT_RL              => r_PGM.INFORMATION267
	     ,P_ENRT_INFO_RT_FREQ_CD             => r_PGM.INFORMATION46
	     ,P_ENRT_MTHD_CD                     => r_PGM.INFORMATION52
	     ,P_ENRT_RL                          => r_PGM.INFORMATION273
	     ,P_IVR_IDENT                        => r_PGM.INFORMATION141
	     ,P_MX_DPNT_PCT_PRTT_LF_AMT          => r_PGM.INFORMATION287
	     ,P_MX_SPS_PCT_PRTT_LF_AMT           => r_PGM.INFORMATION288
	     ,P_NAME                             => r_PGM.INFORMATION170
	     ,P_PER_CVRD_CD                      => r_PGM.INFORMATION20
	     ,P_PGM_DESC                         => r_PGM.INFORMATION219
	     ,P_PGM_GRP_CD                       => r_PGM.INFORMATION49
	     ,P_PGM_ID                           => l_pgm_id
	     ,P_PGM_PRVDS_NO_AUTO_ENRT_FLAG      => r_PGM.INFORMATION22
	     ,P_PGM_PRVDS_NO_DFLT_ENRT_FLAG      => r_PGM.INFORMATION24
	     ,P_PGM_STAT_CD                      => r_PGM.INFORMATION38
	     ,P_PGM_TYP_CD                       => r_PGM.INFORMATION39
	     ,P_PGM_UOM                          => r_PGM.INFORMATION50
	     ,P_PGM_USE_ALL_ASNTS_ELIG_FLAG      => r_PGM.INFORMATION29
	     -- ,P_POE_LVL_CD                       => r_PGM.INFORMATION53
	     ,P_PRTN_ELIG_OVRID_ALWD_FLAG        => r_PGM.INFORMATION28
	     ,P_RT_END_DT_CD                     => nvl(r_PGM.INFORMATION48,'ODBED')
	     ,P_RT_END_DT_RL                     => r_PGM.INFORMATION271
	     ,P_RT_STRT_DT_CD                    => nvl(r_PGM.INFORMATION47,'AED')
	     ,P_RT_STRT_DT_RL                    => r_PGM.INFORMATION270
	     ,P_SCORES_CALC_MTHD_CD              => r_PGM.INFORMATION15
	     ,P_SCORES_CALC_RL                   => r_PGM.INFORMATION261
	     ,P_SHORT_CODE                       => r_PGM.INFORMATION11
	     ,P_SHORT_NAME                       => r_PGM.INFORMATION12
	     ,P_TRK_INELIG_PER_FLAG              => r_PGM.INFORMATION35
	     ,P_UPDATE_SALARY_CD                 => l_sal_upd_cd
	     ,P_URL_REF_NAME                     => r_PGM.INFORMATION185
	     ,P_USES_ALL_ASMTS_FOR_RTS_FLAG      => r_PGM.INFORMATION27
	     ,P_USE_MULTI_PAY_RATES_FLAG         => r_PGM.INFORMATION17
	     ,P_USE_PROG_POINTS_FLAG             => r_PGM.INFORMATION18
	     ,P_USE_SCORES_CD                    => r_PGM.INFORMATION19
	     ,P_VRFY_FMLY_MMBR_CD                => r_PGM.INFORMATION54
             ,P_VRFY_FMLY_MMBR_RL                => r_PGM.INFORMATION274
             ,P_USE_VARIABLE_RATES_FLAG          => NVL(r_PGM.INFORMATION69,'N')
             ,P_SALARY_CALC_MTHD_CD              => r_PGM.INFORMATION70
             ,P_GSP_ALLOW_OVERRIDE_FLAG          => NVL(r_PGM.INFORMATION72,'N')
             ,P_SALARY_CALC_MTHD_RL              => r_PGM.INFORMATION293
             ,P_EFFECTIVE_START_DATE             => l_effective_start_date
             ,P_EFFECTIVE_END_DATE               => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER            => l_ovn
             ,P_DATETRACK_MODE                   => l_dt_mode
           );
              upd_pgm_le(p_pgm_id         => l_pgm_id,
                         p_cet_id         => p_copy_entity_txn_id,
                         p_effective_date => p_effective_date,
                         p_bg_id          => p_business_group_id,
                         p_pro_cvg_st_dt  => nvl(r_PGM.INFORMATION45,'AED'),
                         p_pro_rt_st_dt   => nvl(r_PGM.INFORMATION47,'AED'),
                         p_syn_rt_st_dt   => nvl(r_PGM.INFORMATION53,'AED'));
           end if;
       else
          l_message_text := 'invalid dml_oper'||r_pgm.dml_operation
          ||' pgm_ovn:'||l_ovn
          ||' pgm_dt_mode:'||l_dt_mode
          ||' for pgm_id:'||l_pgm_id;
          PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
          (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
          P_TXN_ID          => nvl(l_pgm_id,p_copy_entity_txn_id),
          P_MODULE_CD       => 'PQH_GSP_STGBEN',
          p_context         => 'PGM',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => l_message_text,
          p_effective_date  => p_effective_date);
       end if;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'PGM',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'PGM',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_pgm;
procedure stage_to_oipl(p_copy_entity_txn_id in number,
                        p_business_group_id  in number,
                        p_effective_date     in date,
                        p_datetrack_mode     in varchar2) is
   cursor c_cop is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'COP'
   and   dml_operation <> 'REUSE' ;
   --
   r_cop                     c_cop%rowtype;
   l_proc                    varchar2(61) :='stage_to_cop';
   l_oipl_id                  number ;
   l_ovn                     number ;
   l_pl_id  number;
   l_object                  varchar2(80);
   l_opt_id number;
   l_db_ovn                  number;
   l_effective_start_date    date ;
   l_message_text            varchar2(2000);
   l_effective_end_date      date ;
   l_effective_date          date;
   l_dt_mode varchar2(30);
   l_grd_effstdt date;       --DN code for BugId: 3242976
begin
   hr_utility.set_location('inside '||l_proc,10);
   for r_cop in c_cop loop
       l_ovn     := r_cop.information265;
       l_effective_date := r_cop.information2;
       if r_cop.INFORMATION261 is null and r_cop.gs_parent_entity_result_id is not null then
          select information261
          into l_pl_id
          from ben_copy_entity_results
          where copy_entity_result_id = r_cop.gs_parent_entity_result_id;
       else
          l_pl_id :=  r_cop.INFORMATION261;
       end if;
       if r_cop.INFORMATION247 is null and r_cop.information262 is not null then
          select information1
          into l_opt_id
          from ben_copy_entity_results
          where copy_entity_result_id = r_cop.information262;
       else
          l_opt_id :=  r_cop.INFORMATION247;
       end if;
       if l_pl_id is not null and l_opt_id is not null and r_cop.information1 is null then
          -- oipl may have been created by step api call.
          l_oipl_id := is_oipl_exists(p_effective_date => l_effective_date,
                                      p_pl_id          => l_pl_id,
                                      p_opt_id         => l_opt_id);
       else
          l_oipl_id := r_cop.information1;
       end if;
       if l_oipl_id is null
          and r_cop.dml_operation in ('INSERT','COPIED','UPD_INS')
          and l_pl_id is not null
          and l_ovn is null
          and l_opt_id is not null then
          if l_oipl_id is null then
             hr_utility.set_location(' BEN_OIPL_F CREATE_OPTION_IN_PLAN ',20);
             --DN: Start code for BugId: 3242976
             begin
			   SELECT grd.date_from
			     INTO l_grd_effstdt
			     FROM per_grades grd,
			          ben_pl_f   pln
  			    WHERE pln.pl_id    = l_pl_id
                  AND p_effective_date BETWEEN pln.effective_start_date
				                           AND pln.effective_end_date
                  AND grd.grade_id = pln.mapping_table_pk_id;
             exception
			   WHEN OTHERS THEN
                    l_grd_effstdt := l_effective_date;
             end;
			 --End code for BugId: 3242976
             BEN_OPTION_IN_PLAN_API.CREATE_OPTION_IN_PLAN(
             P_EFFECTIVE_DATE                  => l_grd_effstdt --l_effective_date --DN code for BugId: 3242976
             ,P_BUSINESS_GROUP_ID              => p_business_group_id
             ,P_ACTL_PREM_ID                   => r_COP.INFORMATION250
	     ,P_AUTO_ENRT_FLAG                 => nvl(r_COP.INFORMATION25,'N')
	     ,P_AUTO_ENRT_MTHD_RL              => r_COP.INFORMATION264
	     ,P_DFLT_ENRT_CD                   => r_COP.INFORMATION26
	     ,P_DFLT_ENRT_DET_RL               => r_COP.INFORMATION266
	     ,P_DFLT_FLAG                      => nvl(r_COP.INFORMATION18,'N')
	     ,P_DRVBL_FCTR_APLS_RTS_FLAG       => nvl(r_COP.INFORMATION24,'N')
	     ,P_DRVBL_FCTR_PRTN_ELIG_FLAG      => nvl(r_COP.INFORMATION22,'N')
	     ,P_ELIG_APLS_FLAG                 => nvl(r_COP.INFORMATION20,'N')
	     ,P_ENRT_CD                        => r_COP.INFORMATION14
	     ,P_ENRT_RL                        => r_COP.INFORMATION257
	     ,P_HIDDEN_FLAG                    => nvl(r_COP.INFORMATION13,'N')
	     ,P_IVR_IDENT                      => r_COP.INFORMATION141
	     ,P_MNDTRY_FLAG                    => nvl(r_COP.INFORMATION17,'N')
	     ,P_MNDTRY_RL                      => r_COP.INFORMATION268
	     ,P_OIPL_ID                        => l_oipl_id
	     ,P_OIPL_STAT_CD                   => 'A'
	     ,P_OPT_ID                         => l_opt_id
	     ,P_ORDR_NUM                       => r_COP.INFORMATION263
	     ,P_PCP_DPNT_DSGN_CD               => r_COP.INFORMATION16
	     ,P_PCP_DSGN_CD                    => r_COP.INFORMATION15
	     ,P_PER_CVRD_CD                    => r_COP.INFORMATION27
	     ,P_PL_ID                          => l_pl_id
	     ,P_POSTELCN_EDIT_RL               => r_COP.INFORMATION269
	     ,P_PRTN_ELIG_OVRID_ALWD_FLAG      => nvl(r_COP.INFORMATION23,'N')
	     ,P_RQD_PERD_ENRT_NENRT_RL         => r_COP.INFORMATION267
	     ,P_RQD_PERD_ENRT_NENRT_UOM        => r_COP.INFORMATION29
	     ,P_RQD_PERD_ENRT_NENRT_VAL        => r_COP.INFORMATION293
	     ,P_SHORT_CODE                     => r_COP.INFORMATION11
	     ,P_SHORT_NAME                     => r_COP.INFORMATION12
	     ,P_TRK_INELIG_PER_FLAG            => nvl(r_COP.INFORMATION21,'N')
	     ,P_URL_REF_NAME                   => r_COP.INFORMATION185
	     ,P_VRFY_FMLY_MMBR_CD              => r_COP.INFORMATION28
             ,P_VRFY_FMLY_MMBR_RL              => r_COP.INFORMATION270
             ,P_EFFECTIVE_START_DATE           => l_effective_start_date
             ,P_EFFECTIVE_END_DATE             => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER          => l_ovn
             );
             hr_utility.set_location('After oipl ins '||l_oipl_id,222);
          end if;
          oipl_writeback(p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_oipl_id            => l_oipl_id,
                         p_oipl_cer_id        => r_COP.copy_entity_result_id);
          hr_utility.set_location('oipl wrtback comp'||l_oipl_id,222);
       elsif l_oipl_id is not null and r_cop.dml_operation ='UPDATE'
                                   and l_ovn is not null
                                   and l_pl_id is not null
                                   and l_opt_id is not null then
           hr_utility.set_location(' BEN_OIPL_F UPDATE_OPTION_IN_PLAN ',30);
           hr_utility.set_location(' dt mode is '||p_datetrack_mode,30);
           if p_datetrack_mode <> 'CORRECTION' then
              l_dt_mode := get_update_mode(p_table_name       => 'BEN_OIPL_F',
                                           p_key_column_name  => 'OIPL_ID',
                                           p_key_column_value => l_oipl_id,
                                           p_effective_date   => l_effective_date);
           else
              l_dt_mode := p_datetrack_mode;
           end if;
           hr_utility.set_location(' dt mode is '||l_dt_mode,30);
           l_db_ovn := get_ovn(p_table_name         => 'BEN_OIPL_F',
                               p_key_column_name    => 'OIPL_ID',
                               p_key_column_value   => l_oipl_id,
                               p_effective_date     => l_effective_date);
           hr_utility.set_location(' ovn is '||l_db_ovn,30);
           if l_db_ovn <> l_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','OIPL');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ','PL :'||l_pl_id||' OPT :'||l_opt_id);
              fnd_message.raise_error;
           else
           BEN_OPTION_IN_PLAN_API.UPDATE_OPTION_IN_PLAN(
             P_EFFECTIVE_DATE                  => l_effective_date
             ,P_BUSINESS_GROUP_ID              => p_business_group_id
	     ,P_OIPL_ID                        => l_oipl_id
	     ,P_ORDR_NUM                       => r_COP.INFORMATION263
	     ,P_OPT_ID                         => l_opt_id
	     ,P_PL_ID                          => l_pl_id
             ,P_EFFECTIVE_START_DATE           => l_effective_start_date
             ,P_EFFECTIVE_END_DATE             => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER          => l_ovn
             ,P_DATETRACK_MODE                 => l_dt_mode
           );
           end if;
       elsif l_oipl_id is not null and r_cop.dml_operation in ('INSERT','COPIED','UPD_INS') then
          hr_utility.set_location('step api call created oipl'||l_proc,100);
       elsif l_oipl_id is not null and r_cop.dml_operation in ('DELETE') then
          hr_utility.set_location('oipl is being deleted '||l_proc,100);
       else
          l_message_text := 'invalid dml_operation is'||r_cop.dml_operation
          ||' oipl_id is'||l_oipl_id
          ||' pl_id is'||l_pl_id
          ||' opt_id is'||l_opt_id
          ||' ovn is'||l_ovn;
          PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
          (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
          P_TXN_ID          => nvl(l_oipl_id,p_copy_entity_txn_id),
          P_MODULE_CD       => 'PQH_GSP_STGBEN',
          p_context         => 'OIPL',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => l_message_text,
          p_effective_date  => p_effective_date);
       end if;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'OIPL',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'OIPL',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_oipl;
procedure stage_to_plip(p_copy_entity_txn_id in number,
                        p_business_group_id  in number,
                        p_effective_date     in date,
                        p_datetrack_mode     in varchar2,
                        p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
   cursor c_updated_cpp is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'CPP'
   and information1 is not null
   and   dml_operation = 'UPDATE' ; -- only  updated plips should be selected

   cursor c_cpp is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'CPP'
   and   dml_operation in ('INSERT','UPDATE') -- only insert/ updates should be there
   order by information263 desc;-- order by highest seq 1st
   --
   r_cpp                     c_cpp%rowtype;
   l_proc                    varchar2(61) :='stage_to_cpp';
   l_plip_id                  number ;
   l_pgm_id                   number ;
   l_pl_id                    number ;
   l_dt_mode varchar2(30);
   l_corps_definition_id     number(15);
   l_object                  varchar2(80);
   l_ovn                     number ;
   l_db_ovn                  number;
   l_message_text            varchar2(2000);
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_effective_date          date;
begin
   hr_utility.set_location('inside '||l_proc,10);
   hr_utility.set_location('bus_area is '||p_business_area,10);
   for r_upd_cpp in c_updated_cpp loop
      -- api is not called as we don't want to update ovn
      update ben_plip_f
      set ordr_num = null
      where plip_id = r_upd_cpp.information1;
   end loop;
   for r_cpp in c_cpp loop
       l_plip_id := r_cpp.information1;
       l_ovn := r_cpp.information265;
       if r_CPP.INFORMATION260 is null then
          select information1
          into l_pgm_id
          from ben_copy_entity_results
          where copy_entity_txn_id = p_copy_entity_txn_id
          and table_alias = 'PGM'
	  and copy_entity_result_id = r_cpp.gs_parent_entity_result_id;  -- 7610624
       else
          l_pgm_id := r_CPP.INFORMATION260;
       end if;
       if r_CPP.INFORMATION261 is null then
          select information1
          into l_pl_id
          from ben_copy_entity_results
          where copy_entity_txn_id = p_copy_entity_txn_id
          and table_alias = 'PLN'
          and copy_entity_result_id = r_CPP.INFORMATION252;
       else
          l_pl_id := r_CPP.INFORMATION261;
       end if;
       hr_utility.set_location('for cpp_id:'||l_plip_id ||'dml '||r_cpp.dml_operation,20);
       hr_utility.set_location('pgm_id: '||l_pgm_id,20);
       hr_utility.set_location('pl_id: '||l_pl_id,20);
--Added by kgowripe for bug#3532412
       if r_cpp.information291 IS NULL AND p_business_area = 'PQH_CORPS_TASK_LIST' THEN
         SELECT information1
         INTO   l_corps_definition_id
         FROM   ben_copy_entity_results
         WHERE  copy_entity_txn_id = p_copy_entity_txn_id
         AND    table_alias = 'CPD';
       else
         l_corps_definition_id := r_cpp.information291;
       end if;
--End changes for bug#3532412
       l_effective_date := r_cpp.information2;
       begin
       if l_plip_id is null and r_cpp.dml_operation = 'INSERT'
          and l_pgm_id is not null and l_pl_id is not null then
           hr_utility.set_location(' BEN_PLIP_F CREATE_PLAN_IN_PROGRAM ',20);
           BEN_PLAN_IN_PROGRAM_API.CREATE_PLAN_IN_PROGRAM(
             P_EFFECTIVE_DATE                       => l_effective_date
             ,P_BUSINESS_GROUP_ID                   => p_business_group_id
             ,P_ALWS_UNRSTRCTD_ENRT_FLAG            => nvl(r_CPP.INFORMATION15,'N')
	     ,P_AUTO_ENRT_MTHD_RL                   => r_CPP.INFORMATION266
	     ,P_BNFT_OR_OPTION_RSTRCTN_CD           => r_CPP.INFORMATION36
	     ,P_CMBN_PLIP_ID                        => r_CPP.INFORMATION239
	     ,P_CVG_INCR_R_DECR_ONLY_CD             => r_CPP.INFORMATION28
	     ,P_DFLT_ENRT_CD                        => r_CPP.INFORMATION21
	     ,P_DFLT_ENRT_DET_RL                    => r_CPP.INFORMATION264
	     ,P_DFLT_FLAG                           => nvl(r_CPP.INFORMATION13,'N')
	     ,P_DFLT_TO_ASN_PNDG_CTFN_CD            => r_CPP.INFORMATION29
	     ,P_DFLT_TO_ASN_PNDG_CTFN_RL            => r_CPP.INFORMATION264
	     ,P_DRVBL_FCTR_APLS_RTS_FLAG            => nvl(r_CPP.INFORMATION16,'N')
	     ,P_DRVBL_FCTR_PRTN_ELIG_FLAG           => nvl(r_CPP.INFORMATION17,'N')
	     ,P_ELIG_APLS_FLAG                      => nvl(r_CPP.INFORMATION18,'N')
	     ,P_ENRT_CD                             => r_CPP.INFORMATION22
	     ,P_ENRT_CVG_END_DT_CD                  => r_CPP.INFORMATION25
	     ,P_ENRT_CVG_END_DT_RL                  => r_CPP.INFORMATION269
	     ,P_ENRT_CVG_STRT_DT_CD                 => r_CPP.INFORMATION24
	     ,P_ENRT_CVG_STRT_DT_RL                 => r_CPP.INFORMATION268
	     ,P_ENRT_MTHD_CD                        => r_CPP.INFORMATION23
	     ,P_ENRT_RL                             => r_CPP.INFORMATION267
	     ,P_IVR_IDENT                           => r_CPP.INFORMATION141
	     ,P_MN_CVG_AMT                          => r_CPP.INFORMATION293
	     ,P_MN_CVG_RL                           => r_CPP.INFORMATION273
	     ,P_MX_CVG_ALWD_AMT                     => r_CPP.INFORMATION294
	     ,P_MX_CVG_INCR_ALWD_AMT                => r_CPP.INFORMATION295
	     ,P_MX_CVG_INCR_WCF_ALWD_AMT            => r_CPP.INFORMATION296
	     ,P_MX_CVG_MLT_INCR_NUM                 => r_CPP.INFORMATION274
	     ,P_MX_CVG_MLT_INCR_WCF_NUM             => r_CPP.INFORMATION275
	     ,P_MX_CVG_RL                           => r_CPP.INFORMATION276
	     ,P_MX_CVG_WCFN_AMT                     => r_CPP.INFORMATION297
	     ,P_MX_CVG_WCFN_MLT_NUM                 => r_CPP.INFORMATION277
	     ,P_NO_MN_CVG_AMT_APLS_FLAG             => nvl(r_CPP.INFORMATION30,'N')
	     ,P_NO_MN_CVG_INCR_APLS_FLAG            => nvl(r_CPP.INFORMATION31,'N')
	     ,P_NO_MX_CVG_AMT_APLS_FLAG             => nvl(r_CPP.INFORMATION32,'N')
	     ,P_NO_MX_CVG_INCR_APLS_FLAG            => nvl(r_CPP.INFORMATION33,'N')
	     ,P_ORDR_NUM                            => r_CPP.INFORMATION263
	     ,P_PER_CVRD_CD                         => r_CPP.INFORMATION38
	     ,P_PGM_ID                              => l_pgm_id
	     ,P_PLIP_ID                             => l_plip_id
	     ,P_PLIP_STAT_CD                        => 'A'
	     ,P_PL_ID                               => l_pl_id
	     ,P_POSTELCN_EDIT_RL                    => r_CPP.INFORMATION257
	     ,P_PRORT_PRTL_YR_CVG_RSTRN_CD          => r_CPP.INFORMATION35
	     ,P_PRORT_PRTL_YR_CVG_RSTRN_RL          => r_CPP.INFORMATION278
	     ,P_PRTN_ELIG_OVRID_ALWD_FLAG           => nvl(r_CPP.INFORMATION19,'N')
	     ,P_RT_END_DT_CD                        => r_CPP.INFORMATION27
	     ,P_RT_END_DT_RL                        => r_CPP.INFORMATION271
	     ,P_RT_STRT_DT_CD                       => r_CPP.INFORMATION26
	     ,P_RT_STRT_DT_RL                       => r_CPP.INFORMATION270
	     ,P_SHORT_CODE                          => r_CPP.INFORMATION11
	     ,P_SHORT_NAME                          => r_CPP.INFORMATION12
	     ,P_TRK_INELIG_PER_FLAG                 => nvl(r_CPP.INFORMATION20,'N')
	     ,P_UNSSPND_ENRT_CD                     => r_CPP.INFORMATION34
	     ,P_URL_REF_NAME                        => r_CPP.INFORMATION185
	     ,P_VRFY_FMLY_MMBR_CD                   => r_CPP.INFORMATION37
             ,P_VRFY_FMLY_MMBR_RL                   => r_CPP.INFORMATION279
             ,P_EFFECTIVE_START_DATE                => l_effective_start_date
             ,P_EFFECTIVE_END_DATE                  => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER               => l_ovn
           );
           hr_utility.set_location('After plip ins'||l_plip_id,22);
           plip_writeback(p_copy_entity_txn_id => p_copy_entity_txn_id,
                          p_plip_id            => l_plip_id,
                          p_pl_id              => l_pl_id,
                          p_plip_cer_id        => r_CPP.copy_entity_result_id);
           hr_utility.set_location('plip wrtback comp'||l_plip_id,222);
           if p_business_area = 'PQH_CORPS_TASK_LIST' then
              hr_utility.set_location('going for quota cr'||l_plip_id,222);
              pqh_cpd_hr_to_stage.grd_quota_update(p_effective_date      => l_effective_date,
                                                   p_grade_id            => r_cpp.information253,
                                                   p_corps_definition_id => l_corps_definition_id,
                                                   p_corps_extra_info_id => r_cpp.information290,
                                                   p_perc_quota          => r_cpp.information287,
                                                   p_population_cd       => r_cpp.information99,
                                                   p_comb_grades         => r_cpp.information219,
                                                   p_max_speed_quota     => r_cpp.information288,
                                                   p_avg_speed_quota     => r_cpp.information289);
           end if;
         elsif l_plip_id is not null and r_cpp.dml_operation = 'UPDATE'
           and l_ovn is not null and l_pgm_id is not null
           and l_pl_id is not null then
           hr_utility.set_location(' BEN_PLIP_F UPDATE_PLAN_IN_PROGRAM ',30);
           hr_utility.set_location(' dt mode is '||p_datetrack_mode,30);
           if p_datetrack_mode <> 'CORRECTION' then
              l_dt_mode := get_update_mode(p_table_name  => 'BEN_PLIP_F',
                                           p_key_column_name => 'PLIP_ID',
                                           p_key_column_value => l_plip_id,
                                           p_effective_date => l_effective_date);
              hr_utility.set_location(' dt mode is '||l_dt_mode,30);
           else
              l_dt_mode := p_datetrack_mode;
           end if;
           l_db_ovn := get_ovn(p_table_name         => 'BEN_PLIP_F',
                               p_key_column_name    => 'PLIP_ID',
                               p_key_column_value   => l_plip_id,
                               p_effective_date     => l_effective_date);
           hr_utility.set_location(' ovn is '||l_db_ovn,30);
           if l_db_ovn <> l_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','PLIP');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ','PL :'||l_pl_id);
              fnd_message.raise_error;
           else
           BEN_PLAN_IN_PROGRAM_API.UPDATE_PLAN_IN_PROGRAM(
             P_EFFECTIVE_DATE                       => l_effective_date
             ,P_BUSINESS_GROUP_ID                   => p_business_group_id
	     ,P_ORDR_NUM                            => r_CPP.INFORMATION263
	     ,P_PGM_ID                              => l_pgm_id
	     ,P_PLIP_ID                             => l_plip_id
	     ,P_PL_ID                               => l_pl_id
             ,P_EFFECTIVE_START_DATE                => l_effective_start_date
             ,P_EFFECTIVE_END_DATE                  => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER               => l_ovn
             ,P_DATETRACK_MODE                      => l_dt_mode
           );
           end if;
           if p_business_area = 'PQH_CORPS_TASK_LIST' then
              pqh_cpd_hr_to_stage.grd_quota_update(p_effective_date      => l_effective_date,
                                                   p_grade_id            => r_cpp.information253,
                                                   p_corps_definition_id => l_corps_definition_id,
                                                   p_corps_extra_info_id => r_cpp.information290,
                                                   p_perc_quota          => r_cpp.information287,
                                                   p_population_cd       => r_cpp.information99,
                                                   p_comb_grades         => r_cpp.information219,
                                                   p_max_speed_quota     => r_cpp.information288,
                                                   p_avg_speed_quota     => r_cpp.information289);
           end if;
       else
          l_message_text := 'invalid plip dml_oper: '||r_CPP.dml_operation
          ||' plip_id: '||l_plip_id
          ||' ovn: '||l_ovn
          ||' pgm_id: '||l_pgm_id
          ||' pl_id: '||l_pl_id;
          PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
          (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
          P_TXN_ID          => nvl(l_plip_id,p_copy_entity_txn_id),
          P_MODULE_CD       => 'PQH_GSP_STGBEN',
          p_context         => 'PLIP',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => l_message_text,
          p_effective_date  => p_effective_date);
       end if;
       exception when others then
          hr_utility.set_location('issues in writing cpp, skipping'||l_proc,100);
          raise;
       end;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'PLIP',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'PLIP',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_plip;
procedure stage_to_elp(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_datetrack_mode     in varchar2) is
   cursor c_elp is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'CRSET'
   and   dml_operation in ('INSERT','UPDATE') -- only insert/ updates should be there
   order by information161,information2;
   --
   r_elp                     c_elp%rowtype;
   l_proc                    varchar2(61) :='stage_to_elp';
   l_elp_id                  number ;
   l_object                  varchar2(80);
   l_elp_ovn                 number ;
   l_old_elp_id              number ;
   l_old_crset_id            number ;
   l_old_elp_ovn             number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_message_text            varchar2(2000);
   l_effective_date          date;
   l_dt_mode                 varchar2(30);
   l_db_ovn                  number;
   l_loc_flag                varchar2(30);
   l_org_flag                varchar2(30);
   l_job_flag                varchar2(30);
   l_pt_flag                 varchar2(30);
   l_sa_flag                 varchar2(30);
   l_pr_flag                 varchar2(30);
   l_fp_flag                 varchar2(30);
   l_rl_flag                 varchar2(30);
   l_bu_flag                 varchar2(30);
   l_old_loc_flag            varchar2(30);
   l_old_org_flag            varchar2(30);
   l_old_job_flag            varchar2(30);
   l_old_pt_flag             varchar2(30);
   l_old_sa_flag             varchar2(30);
   l_old_pr_flag             varchar2(30);
   l_old_fp_flag             varchar2(30);
   l_old_rl_flag             varchar2(30);
   l_old_bu_flag             varchar2(30);
   l_dml_operation           varchar2(30);
   l_ovn number;
   l_pk number;
   l_pt_cd varchar2(30);
   l_esd date;
   l_eed date;
begin
   hr_utility.set_location('inside '||l_proc,10);
   for r_elp in c_elp loop
       l_elp_id := r_elp.information161;
       hr_utility.set_location('for elp_id:'||l_elp_id ||'dml '||r_elp.dml_operation,20);
       l_effective_date := r_elp.information2;
       if r_elp.information277 is null and r_elp.information161 = l_old_crset_id then
          hr_utility.set_location('reusing earlier values ',20);
          -- reuse old values
          l_elp_id := l_old_elp_id;
          l_elp_ovn := l_old_elp_ovn;
       else
          hr_utility.set_location('earlier values cannot be reused',20);
          -- new crset_id is to be entered
          l_elp_id := r_elp.information277;
          l_elp_ovn := r_elp.information265;
          l_old_elp_id := '';
          l_old_elp_ovn := '';
          l_old_crset_id := '';
          l_old_sa_flag := '';
          l_old_fp_flag := '';
          l_old_pt_flag := '';
          l_old_rl_flag := '';
          l_old_bu_flag := '';
          l_old_pr_flag := '';
          l_old_loc_flag := '';
          l_old_org_flag := '';
          l_old_job_flag := '';
       end if;
       if r_elp.dml_operation = 'INSERT' and l_elp_id is null then
          l_dml_operation := 'INSERT';
       elsif r_elp.dml_operation in ('INSERT','UPDATE') and l_elp_id is not null then
          l_dml_operation := 'UPDATE';
       else
          l_dml_operation := '';
       end if;
       hr_utility.set_location('dml_operation is '||l_dml_operation,4);
       if r_elp.information232 is not null then
          l_loc_flag := 'Y';
       else
          l_loc_flag := 'N';
       end if;
       if r_elp.information233 is not null then
          l_job_flag := 'Y';
       else
          l_job_flag := 'N';
       end if;
       if r_elp.information234 is not null then
          l_org_flag := 'Y';
       else
          l_org_flag := 'N';
       end if;
       if r_elp.information235 is not null then
          l_rl_flag := 'Y';
       else
          l_rl_flag := 'N';
       end if;
       if r_elp.information236 is not null then
          l_pt_flag := 'Y';
       else
          l_pt_flag := 'N';
       end if;
       if r_elp.information237 is not null then
          l_sa_flag := 'Y';
       else
          l_sa_flag := 'N';
       end if;
       if r_elp.information101 is not null then
          l_bu_flag := 'Y';
       else
          l_bu_flag := 'N';
       end if;
       if r_elp.information102 is not null then
          l_fp_flag := 'Y';
       else
          l_fp_flag := 'N';
       end if;
       if r_elp.information103 is not null then
          l_pr_flag := 'Y';
       else
          l_pr_flag := 'N';
       end if;
       if l_dml_operation = 'INSERT' then
          hr_utility.set_location(' BEN_ELIGY_PRFL_F CREATE_ELIGY_PROFILE ',20);
          begin
             BEN_ELIGY_PROFILE_API.CREATE_ELIGY_PROFILE(
             P_EFFECTIVE_DATE                  => l_effective_date
             ,P_BUSINESS_GROUP_ID              => p_business_group_id
             ,P_ASMT_TO_USE_CD                 => 'ANY'
             ,P_BNFT_CAGR_PRTN_CD              => 'BNFT'
             ,P_DESCRIPTION                    => r_ELP.INFORMATION151
             ,P_ELIGY_PRFL_ID                  => l_elp_id
             ,P_ELIGY_PRFL_RL_FLAG             => 'N'
	     ,P_ELIG_BRGNG_UNIT_FLAG           => 'N'
             ,P_ELIG_FL_TM_PT_TM_FLAG          => 'N'
             ,P_ELIG_JOB_FLAG                  => 'N'
             ,P_ELIG_ORG_UNIT_FLAG             => 'N'
             ,P_ELIG_PERF_RTNG_FLAG            => 'N'
             ,P_ELIG_PER_TYP_FLAG              => 'N'
             ,P_ELIG_SVC_AREA_FLAG             => 'N'
             ,P_ELIG_WK_LOC_FLAG               => 'N'
             ,P_NAME                           => r_ELP.INFORMATION151
             ,P_STAT_CD                        => 'A'
             ,P_EFFECTIVE_START_DATE           => l_effective_start_date
             ,P_EFFECTIVE_END_DATE             => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER          => l_elp_ovn
             );
             elp_writeback(p_crset_id           => r_elp.information161,
                           p_elp_id             => l_elp_id,
                           p_copy_entity_txn_id => p_copy_entity_txn_id);
             hr_utility.set_location('effdt is '||to_char(l_effective_date,'DD/MM/RRRR'),20);
             if l_rl_flag = 'Y' then
                hr_utility.set_location(' BEN_ELIGY_PRFL_RL_F CREATE_ELIGY_PROFILE_RULE ',20);
                hr_utility.set_location('rule id is'||r_elp.information235,20);
                BEN_ELIGY_PROFILE_RULE_API.CREATE_ELIGY_PROFILE_RULE(
                P_EFFECTIVE_DATE        => l_effective_date
               ,P_BUSINESS_GROUP_ID     => p_business_group_id
               ,P_DRVBL_FCTR_APLS_FLAG  => 'N'
               ,P_ELIGY_PRFL_ID         => l_elp_id
               ,P_ELIGY_PRFL_RL_ID      => l_pk
               ,P_FORMULA_ID            => r_elp.information235
               ,P_ORDR_TO_APLY_NUM      => 1
               ,P_EFFECTIVE_START_DATE  => l_esd
               ,P_EFFECTIVE_END_DATE    => l_eed
               ,P_OBJECT_VERSION_NUMBER => l_ovn
               );
             end if;
             if l_bu_flag = 'Y' then
                hr_utility.set_location(' BEN_ELIG_BRGNG_UNIT_PRTE_F CREATE_ELIG_BRGNG_UNIT_PRTE ',20);
                hr_utility.set_location('bargaining unit cd is'||r_elp.information101,20);
                BEN_ELIG_BRGNG_UNIT_PRTE_API.CREATE_ELIG_BRGNG_UNIT_PRTE(
                  P_EFFECTIVE_DATE          => l_effective_date
                 ,P_BUSINESS_GROUP_ID       => p_business_group_id
                 ,P_BRGNG_UNIT_CD           => r_elp.information101
                 ,P_ELIGY_PRFL_ID           => l_elp_id
                 ,P_ELIG_BRGNG_UNIT_PRTE_ID => l_pk
                 ,P_EXCLD_FLAG              => 'N'
                 ,P_ORDR_NUM                => 1
                 ,P_EFFECTIVE_START_DATE    => l_esd
                 ,P_EFFECTIVE_END_DATE      => l_eed
                 ,P_OBJECT_VERSION_NUMBER   => l_ovn
                 );
             end if;
             if l_fp_flag = 'Y' then
                hr_utility.set_location(' BEN_ELIG_FL_TM_PT_TM_PRTE_F CREATE_ELIG_FL_TM_PT_TM_PRTE ',20);
                hr_utility.set_location('fulltime cd is'||r_elp.information102,20);
                BEN_ELIG_FL_TM_PT_TM_PRTE_API.CREATE_ELIG_FL_TM_PT_TM_PRTE(
                P_EFFECTIVE_DATE           => l_effective_date
               ,P_BUSINESS_GROUP_ID        => p_business_group_id
               ,P_ELIGY_PRFL_ID            => l_elp_id
               ,P_ELIG_FL_TM_PT_TM_PRTE_ID => l_pk
               ,P_EXCLD_FLAG               => 'N'
               ,P_FL_TM_PT_TM_CD           => r_elp.INFORMATION102
               ,P_ORDR_NUM                 => 1
               ,P_EFFECTIVE_START_DATE     => l_esd
               ,P_EFFECTIVE_END_DATE       => l_eed
               ,P_OBJECT_VERSION_NUMBER    => l_ovn
               );
             end if;
             if l_pr_flag = 'Y' then
                hr_utility.set_location(' BEN_ELIG_PERF_RTNG_PRTE_F CREATE_ELIG_PERF_RTNG_PRTE ',20);
                hr_utility.set_location('event type is'||r_elp.information103,20);
                hr_utility.set_location('perf_rtng_cd is'||r_elp.information104,20);
                BEN_ELIG_PERF_RTNG_PRTE_API.CREATE_ELIG_PERF_RTNG_PRTE(
                P_EFFECTIVE_DATE          => l_effective_date
                ,P_BUSINESS_GROUP_ID      => p_business_group_id
                ,P_ELIGY_PRFL_ID          => l_elp_id
                ,P_ELIG_PERF_RTNG_PRTE_ID => l_pk
                ,P_EVENT_TYPE             => r_elp.information103
                ,P_EXCLD_FLAG             => 'N'
                ,P_ORDR_NUM               => 1
                ,P_PERF_RTNG_CD           => r_elp.information104
                ,P_EFFECTIVE_START_DATE   => l_esd
                ,P_EFFECTIVE_END_DATE     => l_eed
                ,P_OBJECT_VERSION_NUMBER  => l_ovn
                );
             end if;
             if l_pt_flag = 'Y' then
                l_pt_cd := get_per_typ_cd(P_PERSON_TYPE_ID => r_elp.information236);
                hr_utility.set_location(' BEN_ELIG_PER_TYP_PRTE_F CREATE_ELIG_PER_TYP_PRTE ',20);
                hr_utility.set_location('per type id is'||r_elp.information236,20);
                hr_utility.set_location('per type cd is'||l_pt_cd,20);
                BEN_ELIG_PER_TYP_PRTE_API.CREATE_ELIG_PER_TYP_PRTE(
                P_EFFECTIVE_DATE         => l_effective_date
                ,P_BUSINESS_GROUP_ID     => p_business_group_id
                ,P_ELIGY_PRFL_ID         => l_elp_id
                ,P_ELIG_PER_TYP_PRTE_ID  => l_pk
                ,P_EXCLD_FLAG            => 'N'
                ,P_ORDR_NUM              => 1
                ,P_PERSON_TYPE_ID        => r_elp.information236
                ,P_PER_TYP_CD            => l_pt_cd
                ,P_EFFECTIVE_START_DATE  => l_esd
                ,P_EFFECTIVE_END_DATE    => l_eed
                ,P_OBJECT_VERSION_NUMBER => l_ovn
                );
             end if;
             if l_sa_flag = 'Y' then
                hr_utility.set_location(' BEN_ELIG_SVC_AREA_PRTE_F CREATE_ELIG_SVC_AREA_PRTE ',20);
                hr_utility.set_location('serv area id is'||r_elp.information237,20);
                BEN_ELIG_SVC_AREA_PRTE_API.CREATE_ELIG_SVC_AREA_PRTE(
                P_EFFECTIVE_DATE        => l_effective_date
               ,P_BUSINESS_GROUP_ID     => p_business_group_id
               ,P_ELIGY_PRFL_ID         => l_elp_id
               ,P_ELIG_SVC_AREA_PRTE_ID => l_pk
               ,P_EXCLD_FLAG            => 'N'
               ,P_ORDR_NUM              => 1
               ,P_SVC_AREA_ID           => r_elp.information237
               ,P_EFFECTIVE_START_DATE  => l_esd
               ,P_EFFECTIVE_END_DATE    => l_eed
               ,P_OBJECT_VERSION_NUMBER => l_ovn
               );
             end if;
             if l_loc_flag = 'Y' then
                hr_utility.set_location(' BEN_ELIG_WK_LOC_PRTE_F CREATE_ELIG_WK_LOC_PRTE ',20);
                hr_utility.set_location('location id is'||r_elp.information232,20);
                BEN_ELIG_WK_LOC_PRTE_API.CREATE_ELIG_WK_LOC_PRTE(
                 P_EFFECTIVE_DATE         => l_effective_date
                 ,P_BUSINESS_GROUP_ID     => p_business_group_id
		 ,P_ELIGY_PRFL_ID         => l_elp_id
		 ,P_ELIG_WK_LOC_PRTE_ID   => l_pk
		 ,P_EXCLD_FLAG            => 'N'
		 ,P_LOCATION_ID           => r_elp.information232
		 ,P_ORDR_NUM              => 1
		 ,P_EFFECTIVE_START_DATE  => l_esd
		 ,P_EFFECTIVE_END_DATE    => l_eed
		 ,P_OBJECT_VERSION_NUMBER => l_ovn
		 );
             end if;
             if l_org_flag = 'Y' then
                hr_utility.set_location(' BEN_ELIG_ORG_UNIT_PRTE_F CREATE_ELIG_ORG_UNIT_PRTE ',20);
                hr_utility.set_location('org id is'||r_elp.information234,20);
                BEN_ELIG_ORG_UNIT_PRTE_API.CREATE_ELIG_ORG_UNIT_PRTE(
                P_EFFECTIVE_DATE         => l_effective_date
                ,P_BUSINESS_GROUP_ID     => p_business_group_id
                ,P_ELIGY_PRFL_ID         => l_elp_id
                ,P_ELIG_ORG_UNIT_PRTE_ID => l_pk
                ,P_EXCLD_FLAG            => 'N'
                ,P_ORDR_NUM              => 1
                ,P_ORGANIZATION_ID       => r_elp.information234
                ,P_EFFECTIVE_START_DATE  => l_esd
                ,P_EFFECTIVE_END_DATE    => l_eed
                ,P_OBJECT_VERSION_NUMBER => l_ovn
               );
             end if;
             if l_job_flag = 'Y' then
                hr_utility.set_location(' BEN_ELIG_JOB_PRTE_F CREATE_ELIGY_JOB_PRTE ',20);
                hr_utility.set_location('org id is'||r_elp.information233,20);
                BEN_ELIGY_JOB_PRTE_API.CREATE_ELIGY_JOB_PRTE(
                   P_EFFECTIVE_DATE         => l_effective_date
                   ,P_BUSINESS_GROUP_ID     => p_business_group_id
	   	   ,P_ELIGY_PRFL_ID         => l_elp_id
		   ,P_ELIG_JOB_PRTE_ID      => l_pk
		   ,P_EXCLD_FLAG            => 'N'
		   ,P_JOB_ID                => r_elp.information233
		   ,P_ORDR_NUM              => 1
		   ,P_EFFECTIVE_START_DATE  => l_esd
		   ,P_EFFECTIVE_END_DATE    => l_eed
		   ,P_OBJECT_VERSION_NUMBER => l_ovn
		);
             end if;
          exception when others then
             hr_utility.set_location('issues in writing elp, skipping'||l_proc,100);
             raise;
          end;
          hr_utility.set_location('After plsql table ',222);
       elsif l_dml_operation = 'UPDATE' then
          hr_utility.set_location(' dt mode is '||p_datetrack_mode,30);
          if p_datetrack_mode <> 'CORRECTION' then
             l_dt_mode := get_update_mode(p_table_name       => 'BEN_ELIGY_PRFL_F',
                                          p_key_column_name  => 'ELIGY_PRFL_ID',
                                          p_key_column_value => l_elp_id,
                                          p_effective_date   => l_effective_date);
             hr_utility.set_location(' dt mode is '||l_dt_mode,30);
          else
             l_dt_mode := p_datetrack_mode;
          end if;
           l_db_ovn := get_ovn(p_table_name         => 'BEN_ELIGY_PRFL_F',
                               p_key_column_name    => 'ELIGY_PRFL_ID',
                               p_key_column_value   => l_elp_id,
                               p_effective_date     => l_effective_date);
           hr_utility.set_location(' ovn is '||l_db_ovn,30);
           if l_db_ovn <> l_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','ELP');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ',r_ELP.INFORMATION151);
              fnd_message.raise_error;
           else
               hr_utility.set_location(' BEN_ELIGY_PRFL_F UPDATE_ELIGY_PROFILE ',30);
               begin
                  BEN_ELIGY_PROFILE_API.UPDATE_ELIGY_PROFILE(
                  P_EFFECTIVE_DATE                  => l_effective_date
                  ,P_BUSINESS_GROUP_ID              => p_business_group_id
                  ,P_DESCRIPTION                    => r_ELP.INFORMATION151
                  ,P_ELIGY_PRFL_ID                  => l_elp_id
                  ,P_ELIGY_PRFL_RL_FLAG             => 'N'
     	          ,P_ELIG_BRGNG_UNIT_FLAG           => 'N'
                  ,P_ELIG_FL_TM_PT_TM_FLAG          => 'N'
                  ,P_ELIG_JOB_FLAG                  => 'N'
                  ,P_ELIG_ORG_UNIT_FLAG             => 'N'
                  ,P_ELIG_PERF_RTNG_FLAG            => 'N'
                  ,P_ELIG_PER_TYP_FLAG              => 'N'
                  ,P_ELIG_SVC_AREA_FLAG             => 'N'
                  ,P_ELIG_WK_LOC_FLAG               => 'N'
                  ,P_NAME                           => r_ELP.INFORMATION151
                  ,P_EFFECTIVE_START_DATE           => l_effective_start_date
                  ,P_EFFECTIVE_END_DATE             => l_effective_end_date
                  ,P_OBJECT_VERSION_NUMBER          => l_elp_ovn
                  ,P_DATETRACK_MODE                 => l_dt_mode
                  );
                exception when others then
                   hr_utility.set_location('issues in writing elp, skipping'||l_proc,100);
                   raise;
                end;
             end if;
             if l_rl_flag = 'Y' and l_old_rl_flag is null and r_elp.information225 is null then
                hr_utility.set_location(' BEN_ELIGY_PRFL_RL_F CREATE_ELIGY_PROFILE_RULE ',20);
                BEN_ELIGY_PROFILE_RULE_API.CREATE_ELIGY_PROFILE_RULE(
                P_EFFECTIVE_DATE        => l_effective_date
               ,P_BUSINESS_GROUP_ID     => p_business_group_id
               ,P_DRVBL_FCTR_APLS_FLAG  => 'N'
               ,P_ELIGY_PRFL_ID         => l_elp_id
               ,P_ELIGY_PRFL_RL_ID      => l_pk
               ,P_FORMULA_ID            => r_elp.information235
               ,P_ORDR_TO_APLY_NUM      => 1
               ,P_EFFECTIVE_START_DATE  => l_esd
               ,P_EFFECTIVE_END_DATE    => l_eed
               ,P_OBJECT_VERSION_NUMBER => l_ovn
               );
             elsif l_rl_flag is null and l_old_rl_flag = 'Y' and r_elp.information225 is null then
               end_date_crit(p_elig_prfl_id   => l_elp_id,
                             p_crit_type      => 'RL',
                             p_effective_date => l_effective_date);
             end if;
             if l_bu_flag = 'Y' and l_old_bu_flag is null and r_elp.information228 is null then
                hr_utility.set_location(' BEN_ELIG_BRGNG_UNIT_PRTE_F CREATE_ELIG_BRGNG_UNIT_PRTE ',20);
                BEN_ELIG_BRGNG_UNIT_PRTE_API.CREATE_ELIG_BRGNG_UNIT_PRTE(
                  P_EFFECTIVE_DATE          => l_effective_date
                 ,P_BUSINESS_GROUP_ID       => p_business_group_id
                 ,P_BRGNG_UNIT_CD           => r_elp.information101
                 ,P_ELIGY_PRFL_ID           => l_elp_id
                 ,P_ELIG_BRGNG_UNIT_PRTE_ID => l_pk
                 ,P_EXCLD_FLAG              => 'N'
                 ,P_ORDR_NUM                => 1
                 ,P_EFFECTIVE_START_DATE    => l_esd
                 ,P_EFFECTIVE_END_DATE      => l_eed
                 ,P_OBJECT_VERSION_NUMBER   => l_ovn
                 );
             elsif l_bu_flag is null and l_old_bu_flag = 'Y' and r_elp.information228 is null then
               end_date_crit(p_elig_prfl_id   => l_elp_id,
                             p_crit_type      => 'BU',
                             p_effective_date => l_effective_date);
             end if;
             if l_fp_flag = 'Y' and l_old_fp_flag is null and r_elp.information229 is null then
                hr_utility.set_location(' BEN_ELIG_FL_TM_PT_TM_PRTE_F CREATE_ELIG_FL_TM_PT_TM_PRTE ',20);
                BEN_ELIG_FL_TM_PT_TM_PRTE_API.CREATE_ELIG_FL_TM_PT_TM_PRTE(
                P_EFFECTIVE_DATE           => l_effective_date
               ,P_BUSINESS_GROUP_ID        => p_business_group_id
               ,P_ELIGY_PRFL_ID            => l_elp_id
               ,P_ELIG_FL_TM_PT_TM_PRTE_ID => l_pk
               ,P_EXCLD_FLAG               => 'N'
               ,P_FL_TM_PT_TM_CD           => r_elp.INFORMATION102
               ,P_ORDR_NUM                 => 1
               ,P_EFFECTIVE_START_DATE     => l_esd
               ,P_EFFECTIVE_END_DATE       => l_eed
               ,P_OBJECT_VERSION_NUMBER    => l_ovn
               );
             elsif l_fp_flag is null and l_old_fp_flag = 'Y' and r_elp.information229 is null then
               end_date_crit(p_elig_prfl_id   => l_elp_id,
                             p_crit_type      => 'FP',
                             p_effective_date => l_effective_date);
             end if;
             if l_pr_flag = 'Y' and l_old_pr_flag is null and r_elp.information230 is null then
                hr_utility.set_location(' BEN_ELIG_PERF_RTNG_PRTE_F CREATE_ELIG_PERF_RTNG_PRTE ',20);
                BEN_ELIG_PERF_RTNG_PRTE_API.CREATE_ELIG_PERF_RTNG_PRTE(
                P_EFFECTIVE_DATE          => l_effective_date
                ,P_BUSINESS_GROUP_ID      => p_business_group_id
                ,P_ELIGY_PRFL_ID          => l_elp_id
                ,P_ELIG_PERF_RTNG_PRTE_ID => l_pk
                ,P_EVENT_TYPE             => r_elp.information104
                ,P_EXCLD_FLAG             => 'N'
                ,P_ORDR_NUM               => 1
                ,P_PERF_RTNG_CD           => r_elp.information103
                ,P_EFFECTIVE_START_DATE   => l_esd
                ,P_EFFECTIVE_END_DATE     => l_eed
                ,P_OBJECT_VERSION_NUMBER  => l_ovn
                );
             elsif l_pr_flag is null and l_old_pr_flag = 'Y' and r_elp.information230 is null then
               end_date_crit(p_elig_prfl_id   => l_elp_id,
                             p_crit_type      => 'PR',
                             p_effective_date => l_effective_date);
             end if;
             if l_pt_flag = 'Y' and l_old_pt_flag is null and r_elp.information226 is null then
                l_pt_cd := get_per_typ_cd(P_PERSON_TYPE_ID => r_elp.information236);
                hr_utility.set_location(' BEN_ELIG_PER_TYP_PRTE_F CREATE_ELIG_PER_TYP_PRTE ',20);
                BEN_ELIG_PER_TYP_PRTE_API.CREATE_ELIG_PER_TYP_PRTE(
                P_EFFECTIVE_DATE         => l_effective_date
                ,P_BUSINESS_GROUP_ID     => p_business_group_id
                ,P_ELIGY_PRFL_ID         => l_elp_id
                ,P_ELIG_PER_TYP_PRTE_ID  => l_pk
                ,P_EXCLD_FLAG            => 'N'
                ,P_ORDR_NUM              => 1
                ,P_PERSON_TYPE_ID        => r_elp.information236
                ,P_PER_TYP_CD            => l_pt_cd
                ,P_EFFECTIVE_START_DATE  => l_esd
                ,P_EFFECTIVE_END_DATE    => l_eed
                ,P_OBJECT_VERSION_NUMBER => l_ovn
                );
             elsif l_pt_flag is null and l_old_pt_flag = 'Y' and r_elp.information226 is null then
               end_date_crit(p_elig_prfl_id   => l_elp_id,
                             p_crit_type      => 'PT',
                             p_effective_date => l_effective_date);
             end if;
             if l_sa_flag = 'Y' and l_old_sa_flag is null and r_elp.information227 is null then
                hr_utility.set_location(' BEN_ELIG_SVC_AREA_PRTE_F CREATE_ELIG_SVC_AREA_PRTE ',20);
                BEN_ELIG_SVC_AREA_PRTE_API.CREATE_ELIG_SVC_AREA_PRTE(
                P_EFFECTIVE_DATE        => l_effective_date
               ,P_BUSINESS_GROUP_ID     => p_business_group_id
               ,P_ELIGY_PRFL_ID         => l_elp_id
               ,P_ELIG_SVC_AREA_PRTE_ID => l_pk
               ,P_EXCLD_FLAG            => 'N'
               ,P_ORDR_NUM              => 1
               ,P_SVC_AREA_ID           => r_elp.information237
               ,P_EFFECTIVE_START_DATE  => l_esd
               ,P_EFFECTIVE_END_DATE    => l_eed
               ,P_OBJECT_VERSION_NUMBER => l_ovn
               );
             elsif l_sa_flag is null and l_old_sa_flag = 'Y' and r_elp.information227 is null then
               end_date_crit(p_elig_prfl_id   => l_elp_id,
                             p_crit_type      => 'SA',
                             p_effective_date => l_effective_date);
             end if;
             if l_loc_flag = 'Y' and l_old_loc_flag is null and r_elp.information222 is null then
                hr_utility.set_location(' BEN_ELIG_WK_LOC_PRTE_F CREATE_ELIG_WK_LOC_PRTE ',20);
                BEN_ELIG_WK_LOC_PRTE_API.CREATE_ELIG_WK_LOC_PRTE(
                 P_EFFECTIVE_DATE         => l_effective_date
                 ,P_BUSINESS_GROUP_ID     => p_business_group_id
		 ,P_ELIGY_PRFL_ID         => l_elp_id
		 ,P_ELIG_WK_LOC_PRTE_ID   => l_pk
		 ,P_EXCLD_FLAG            => 'N'
		 ,P_LOCATION_ID           => r_elp.information232
		 ,P_ORDR_NUM              => 1
		 ,P_EFFECTIVE_START_DATE  => l_esd
		 ,P_EFFECTIVE_END_DATE    => l_eed
		 ,P_OBJECT_VERSION_NUMBER => l_ovn
		 );
             elsif l_loc_flag is null and l_old_loc_flag = 'Y' and r_elp.information222 is null then
               end_date_crit(p_elig_prfl_id   => l_elp_id,
                             p_crit_type      => 'LOC',
                             p_effective_date => l_effective_date);
             end if;
             if l_org_flag = 'Y' and l_old_org_flag is null and r_elp.information224 is null then
                hr_utility.set_location(' BEN_ELIG_ORG_UNIT_PRTE_F CREATE_ELIG_ORG_UNIT_PRTE ',20);
                BEN_ELIG_ORG_UNIT_PRTE_API.CREATE_ELIG_ORG_UNIT_PRTE(
                P_EFFECTIVE_DATE         => l_effective_date
                ,P_BUSINESS_GROUP_ID     => p_business_group_id
                ,P_ELIGY_PRFL_ID         => l_elp_id
                ,P_ELIG_ORG_UNIT_PRTE_ID => l_pk
                ,P_EXCLD_FLAG            => 'N'
                ,P_ORDR_NUM              => 1
                ,P_ORGANIZATION_ID       => r_elp.information234
                ,P_EFFECTIVE_START_DATE  => l_esd
                ,P_EFFECTIVE_END_DATE    => l_eed
                ,P_OBJECT_VERSION_NUMBER => l_ovn
               );
             elsif l_org_flag is null and l_old_org_flag = 'Y' and r_elp.information224 is null then
               end_date_crit(p_elig_prfl_id   => l_elp_id,
                             p_crit_type      => 'ORG',
                             p_effective_date => l_effective_date);
             end if;
             if l_job_flag = 'Y' and l_old_job_flag is null and r_elp.information223 is null then
                hr_utility.set_location(' BEN_ELIG_JOB_PRTE_F CREATE_ELIGY_JOB_PRTE ',20);
                BEN_ELIGY_JOB_PRTE_API.CREATE_ELIGY_JOB_PRTE(
                   P_EFFECTIVE_DATE         => l_effective_date
                   ,P_BUSINESS_GROUP_ID     => p_business_group_id
	   	   ,P_ELIGY_PRFL_ID         => l_elp_id
		   ,P_ELIG_JOB_PRTE_ID      => l_pk
		   ,P_EXCLD_FLAG            => 'N'
		   ,P_JOB_ID                => r_elp.information233
		   ,P_ORDR_NUM              => 1
		   ,P_EFFECTIVE_START_DATE  => l_esd
		   ,P_EFFECTIVE_END_DATE    => l_eed
		   ,P_OBJECT_VERSION_NUMBER => l_ovn
		);
             elsif l_job_flag is null and l_old_job_flag = 'Y' and r_elp.information223 is null then
               end_date_crit(p_elig_prfl_id   => l_elp_id,
                             p_crit_type      => 'JOB',
                             p_effective_date => l_effective_date);
             end if;
       else
          l_message_text := 'invalid dml_oper'||l_dml_operation
          ||' elp_ovn'||l_elp_ovn
          ||' elp_id'||l_elp_id;
          PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
          (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
          P_TXN_ID          => nvl(l_elp_id,p_copy_entity_txn_id),
          P_MODULE_CD       => 'PQH_GSP_STGBEN',
          p_context         => 'ELP',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => l_message_text,
          p_effective_date  => p_effective_date);
       end if;
       l_old_elp_id := l_elp_id;
       l_old_elp_ovn := l_elp_ovn;
       l_old_crset_id := r_elp.information161;
       l_old_sa_flag := l_sa_flag;
       l_old_fp_flag := l_fp_flag;
       l_old_pt_flag := l_pt_flag;
       l_old_rl_flag := l_rl_flag;
       l_old_bu_flag := l_bu_flag;
       l_old_pr_flag := l_pr_flag;
       l_old_loc_flag := l_loc_flag;
       l_old_org_flag := l_org_flag;
       l_old_job_flag := l_job_flag;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'ELP',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'ELP',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_elp;
procedure stage_to_cep(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_datetrack_mode     in varchar2) is
   cursor c_cep is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'CEP'
   and   dml_operation in ('INSERT','UPDATE') ; -- only insert/update should be there
   --
   r_cep                     c_cep%rowtype;
   l_proc                    varchar2(61) :='stage_to_cep';
   l_cep_id                  number ;
   l_ovn                     number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_effective_date          date;
   l_message_text            varchar2(2000);
   l_dt_mode varchar2(30);
   l_object varchar2(80);
   l_db_ovn varchar2(30);
   l_epa_id number;
   l_pk number;
   l_tab varchar2(30);
begin
   hr_utility.set_location('inside '||l_proc,10);
   for r_cep in c_cep loop
       l_cep_id := r_cep.information1;
       l_ovn := r_cep.information265;
       hr_utility.set_location('for cep_id:'||l_cep_id ||'dml '||r_cep.dml_operation,20);
       if r_cep.gs_mirror_src_entity_result_id is not null then
          select information1,table_alias
          into l_pk, l_tab
          from ben_copy_entity_results
          where copy_entity_result_id = r_cep.gs_mirror_src_entity_result_id;
          hr_utility.set_location('parent tab is'||l_tab ||' pk is '||l_pk,5);
          if l_tab ='EPA' then
             l_epa_id := l_pk;
          else
             l_epa_id := null;
          end if;
       else
          l_epa_id := null;
       end if;
       l_effective_date := r_cep.information2;
       begin
       if l_cep_id is null and l_epa_id is not null and l_ovn is null and r_cep.dml_operation = 'INSERT' then
           hr_utility.set_location(' BEN_PRTN_ELIG_PRFL_F CREATE_PRTN_ELIG_PRFL ',20);
           BEN_PRTN_ELIG_PRFL_API.CREATE_PRTN_ELIG_PRFL(
             P_EFFECTIVE_DATE         => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_business_group_id
	     ,P_ELIGY_PRFL_ID         => r_CEP.INFORMATION263
	     ,P_ELIG_PRFL_TYPE_CD     => r_CEP.INFORMATION11
	     ,P_MNDTRY_FLAG           => nvl(r_CEP.INFORMATION12,'N')
	     ,P_COMPUTE_SCORE_FLAG    => r_CEP.INFORMATION13
	     ,P_PRTN_ELIG_ID          => l_epa_id
	     ,P_PRTN_ELIG_PRFL_ID     => l_cep_id
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_ovn
           );
       elsif l_cep_id is not null and l_epa_id is not null and l_ovn is not null and r_cep.dml_operation = 'UPDATE' then
          hr_utility.set_location(' dt mode is '||p_datetrack_mode,30);
          if p_datetrack_mode <> 'CORRECTION' then
             l_dt_mode := get_update_mode(p_table_name       => 'BEN_PRTN_ELIG_PRFL_F',
                                          p_key_column_name  => 'PRTN_ELIG_PRFL_ID',
                                          p_key_column_value => l_cep_id,
                                          p_effective_date   => l_effective_date);
             hr_utility.set_location(' dt mode is '||l_dt_mode,30);
          else
             l_dt_mode := p_datetrack_mode;
          end if;
           l_db_ovn := get_ovn(p_table_name         => 'BEN_PRTN_ELIG_PRFL_F',
                               p_key_column_name    => 'PRTN_ELIG_PRFL_ID',
                               p_key_column_value   => l_cep_id,
                               p_effective_date     => l_effective_date);
           hr_utility.set_location(' ovn is '||l_db_ovn,30);
           if l_db_ovn <> l_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','CEP');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ','CEP :'||l_cep_id);
              fnd_message.raise_error;
           else
              hr_utility.set_location(' BEN_PRTN_ELIG_PRFL_F UPDATE_PRTN_ELIG_PRFL ',30);
              BEN_PRTN_ELIG_PRFL_API.UPDATE_PRTN_ELIG_PRFL(
                P_EFFECTIVE_DATE         => l_effective_date
                ,P_BUSINESS_GROUP_ID     => p_business_group_id
	        ,P_ELIGY_PRFL_ID         => r_CEP.INFORMATION263
	        ,P_MNDTRY_FLAG           => r_CEP.INFORMATION12
                ,P_COMPUTE_SCORE_FLAG    => r_CEP.INFORMATION13
		,P_PRTN_ELIG_ID          => l_epa_id
	        ,P_PRTN_ELIG_PRFL_ID     => l_cep_id
                ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                ,P_OBJECT_VERSION_NUMBER => l_ovn
                ,P_DATETRACK_MODE        => l_dt_mode);
           end if;
       else
          l_message_text := 'invalid dml_oper'||r_cep.dml_operation
          ||' cep_id '||l_cep_id
          ||' cep_ovn '||l_ovn
          ||' epa_id '||l_epa_id;
          PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
          (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
          P_TXN_ID          => nvl(l_cep_id,p_copy_entity_txn_id),
          P_MODULE_CD       => 'PQH_GSP_STGBEN',
          p_context         => 'CEP',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => l_message_text,
          p_effective_date  => p_effective_date);
       end if;
       exception when others then
          hr_utility.set_location('issues in writing cep, skipping'||l_proc,100);
          raise;
       end;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'CEP',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'CEP',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_cep;
procedure stage_to_abr(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_datetrack_mode     in varchar2) is
   cursor c_abr is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'ABR'
   and   dml_operation = 'INSERT' ;-- only insert should be there
   --
   r_abr                     c_abr%rowtype;
   l_proc                    varchar2(61) :='stage_to_abr';
   l_abr_id                  number ;
   l_pl_id                  number ;
   l_message_text            varchar2(2000);
   l_opt_id                  number ;
   l_ovn                     number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_effective_date          date;
begin
   hr_utility.set_location('inside '||l_proc,10);
   for r_abr in c_abr loop
       l_pl_id := null;
       l_opt_id := null;
       l_abr_id := r_abr.information1;
       hr_utility.set_location('for abr_id:'||l_abr_id ||'dml '||r_abr.dml_operation,20);
       l_effective_date := r_abr.information2;
       hr_utility.set_location('effdt is'||to_char(l_effective_date,'DD/MM/RRRR'),21);
       hr_utility.set_location('hrr id is '||r_ABR.INFORMATION266,22);
       if r_ABR.INFORMATION277 is not null and r_ABR.INFORMATION261 is null then
          hr_utility.set_location('pl_cer_id :'||r_ABR.INFORMATION277,3);
          begin
             select information1
             into l_pl_id
             from ben_copy_entity_results
             where copy_entity_result_id = r_ABR.INFORMATION277;
          exception
             when others then
                l_pl_id := '';
          end;
       elsif r_ABR.INFORMATION261 is not null then
          l_pl_id := r_ABR.INFORMATION261;
       elsif r_ABR.INFORMATION247 is not null then
          l_opt_id := r_ABR.INFORMATION247;
       elsif r_ABR.INFORMATION278 is not null and r_ABR.INFORMATION247 is null then
          hr_utility.set_location('opt_cer_id :'||r_ABR.INFORMATION278,3);
          begin
             select information1
             into l_opt_id
             from ben_copy_entity_results
             where copy_entity_result_id = r_ABR.INFORMATION278;
          exception
             when others then
                l_opt_id := '';
          end;
       else
          hr_utility.set_location('pl id is '||r_ABR.INFORMATION261,3);
          hr_utility.set_location('pl cer id is '||r_ABR.INFORMATION277,3);
          hr_utility.set_location('opt id is '||r_ABR.INFORMATION247,3);
          hr_utility.set_location('opt cer id is '||r_ABR.INFORMATION278,3);
       end if;
/*
          l_message_text := 'oper is'||r_ABR.dml_operation
          ||' pl id is '||r_ABR.INFORMATION261
          ||' abr id is '||l_abr_id
          ||' hrr id is '||r_abr.information266
          ||' abr ovn is '||l_ovn
          ||' opt id is '||r_ABR.INFORMATION247;
          PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
          (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
          P_TXN_ID          => nvl(l_abr_id,p_copy_entity_txn_id),
          P_MODULE_CD       => 'PQH_GSP_STGBEN',
          p_context         => 'ABR',
          P_MESSAGE_TYPE_CD => 'C',
          P_MESSAGE_TEXT    => l_message_text,
          p_effective_date  => p_effective_date);
*/
       begin
       if l_abr_id is null and (l_pl_id is not null or l_opt_id is not null) and r_abr.information266 is not null then
           hr_utility.set_location(' BEN_ACTY_BASE_RT_F CREATE_ACTY_BASE_RATE ',20);
           BEN_ACTY_BASE_RATE_API.CREATE_ACTY_BASE_RATE(
             P_EFFECTIVE_DATE                 => l_effective_date
             ,P_BUSINESS_GROUP_ID             => p_business_group_id
	     ,P_ABV_MX_ELCN_VAL_ALWD_FLAG     => nvl(r_ABR.INFORMATION27,'N')
	     ,P_ACTL_PREM_ID                  => r_ABR.information250
	     ,P_ACTY_BASE_RT_ID               => l_abr_id
	     ,P_ACTY_BASE_RT_STAT_CD          => 'A'
	     ,P_ACTY_TYP_CD                   => 'GSPSA'
	     ,P_ALWS_CHG_CD                   => r_ABR.INFORMATION11
	     ,P_ANN_MN_ELCN_VAL               => r_ABR.INFORMATION298
	     ,P_ANN_MX_ELCN_VAL               => r_ABR.INFORMATION299
	     ,P_ASMT_TO_USE_CD                => r_ABR.INFORMATION23
	     ,P_ASN_ON_ENRT_FLAG              => nvl(r_ABR.INFORMATION26,'N')
	     ,P_BLW_MN_ELCN_ALWD_FLAG         => nvl(r_ABR.INFORMATION28,'N')
	     ,P_BNFT_RT_TYP_CD                => r_ABR.INFORMATION51
	     ,P_CLM_COMP_LVL_FCTR_ID          => r_ABR.information273
--	     ,P_CMBN_PLIP_ID                  => r_ABR.information239
--	     ,P_CMBN_PTIP_ID                  => r_ABR.information236
--	     ,P_CMBN_PTIP_OPT_ID              => r_ABR.information249
	     ,P_COMP_LVL_FCTR_ID              => r_ABR.information254
	     ,P_COST_ALLOCATION_KEYFLEX_ID    => r_ABR.information262
	     ,P_DET_PL_YTD_CNTRS_CD           => r_ABR.INFORMATION24
	     ,P_DFLT_FLAG                     => nvl(r_ABR.INFORMATION39,'N')
	     ,P_DFLT_VAL                      => r_ABR.INFORMATION297
	     ,P_DSPLY_ON_ENRT_FLAG            => nvl(r_ABR.INFORMATION29,'N')
	     ,P_ELEMENT_TYPE_ID               => r_ABR.information174
	     ,P_ELE_ENTRY_VAL_CD              => r_ABR.INFORMATION12
	     ,P_ELE_RQD_FLAG                  => nvl(r_ABR.INFORMATION45,'N')
	     ,P_ENTR_ANN_VAL_FLAG             => nvl(r_ABR.INFORMATION44,'N')
	     ,P_ENTR_VAL_AT_ENRT_FLAG         => nvl(r_ABR.INFORMATION41,'N')
	     ,P_FRGN_ERG_DED_IDENT            => r_ABR.INFORMATION141
	     ,P_FRGN_ERG_DED_NAME             => r_ABR.INFORMATION185
	     ,P_FRGN_ERG_DED_TYP_CD           => r_ABR.INFORMATION19
	     ,P_INCRMT_ELCN_VAL               => r_ABR.INFORMATION296
	     ,P_INPUT_VALUE_ID                => r_ABR.information178
	     ,P_INPUT_VA_CALC_RL              => r_ABR.information263
	     ,P_LWR_LMT_CALC_RL               => r_ABR.information268
	     ,P_LWR_LMT_VAL                   => r_ABR.INFORMATION300
	     ,P_MN_ELCN_VAL                   => r_ABR.INFORMATION293
	     ,P_MX_ELCN_VAL                   => r_ABR.INFORMATION294
	     ,P_NAME                          => r_ABR.INFORMATION170
	     ,P_NNMNTRY_UOM                   => r_ABR.INFORMATION14
	     ,P_NO_MN_ELCN_VAL_DFND_FLAG      => nvl(r_ABR.INFORMATION42,'N')
	     ,P_NO_MX_ELCN_VAL_DFND_FLAG      => nvl(r_ABR.INFORMATION40,'N')
	     ,P_NO_STD_RT_USED_FLAG           => nvl(r_ABR.INFORMATION36,'N')
--	     ,P_OIPLIP_ID                     => r_ABR.information227
--	     ,P_OIPL_ID                       => r_ABR.information258
	     ,P_ONE_ANN_PYMT_CD               => r_ABR.INFORMATION46
	     ,P_ONLY_ONE_BAL_TYP_ALWD_FLAG    => nvl(r_ABR.INFORMATION43,'N')
	     ,P_OPT_ID                        => l_opt_id
	     ,P_ORDR_NUM                      => r_ABR.INFORMATION264
	     ,P_PARNT_ACTY_BASE_RT_ID         => r_ABR.information267
	     ,P_PARNT_CHLD_CD                 => r_ABR.INFORMATION53
	     ,P_PAY_RATE_GRADE_RULE_ID        => r_ABR.INFORMATION266
--	     ,P_PGM_ID                        => r_ABR.information260
--	     ,P_PLIP_ID                       => r_ABR.information256
	     ,P_PL_ID                         => l_pl_id
	     ,P_PRDCT_FLX_CR_WHEN_ELIG_FLAG   => nvl(r_ABR.INFORMATION35,'N')
	     ,P_PROCG_SRC_CD                  => r_ABR.INFORMATION18
	     ,P_PROC_EACH_PP_DFLT_FLAG        => nvl(r_ABR.INFORMATION34,'N')
	     ,P_PRORT_MN_ANN_ELCN_VAL_CD      => r_ABR.INFORMATION47
	     ,P_PRORT_MN_ANN_ELCN_VAL_RL      => r_ABR.information274
	     ,P_PRORT_MX_ANN_ELCN_VAL_CD      => r_ABR.INFORMATION48
	     ,P_PRORT_MX_ANN_ELCN_VAL_RL      => r_ABR.information275
	     ,P_PRTL_MO_DET_MTHD_CD           => r_ABR.INFORMATION16
	     ,P_PRTL_MO_DET_MTHD_RL           => r_ABR.information281
	     ,P_PRTL_MO_EFF_DT_DET_CD         => r_ABR.INFORMATION20
	     ,P_PRTL_MO_EFF_DT_DET_RL         => r_ABR.information280
	     ,P_PTD_COMP_LVL_FCTR_ID          => r_ABR.information272
--	     ,P_PTIP_ID                       => r_ABR.information259
	     ,P_RCRRG_CD                      => r_ABR.INFORMATION13
	     ,P_RNDG_CD                       => r_ABR.INFORMATION15
	     ,P_RNDG_RL                       => r_ABR.information279
	     ,P_RT_MLT_CD                     => 'PRV'                -- use payrate value
	     ,P_RT_TYP_CD                     => r_ABR.INFORMATION50
	     ,P_RT_USG_CD                     => 'STD'
	     ,P_SUBJ_TO_IMPTD_INCM_FLAG       => nvl(r_ABR.INFORMATION22,'N')
	     ,P_TTL_COMP_LVL_FCTR_ID          => r_ABR.information257
	     ,P_TX_TYP_CD                     => 'PRETAX'
	     ,P_UPR_LMT_CALC_RL               => r_ABR.information269
	     ,P_UPR_LMT_VAL                   => r_ABR.INFORMATION301
	     ,P_USES_DED_SCHED_FLAG           => nvl(r_ABR.INFORMATION31,'N')
	     ,P_USES_PYMT_SCHED_FLAG          => nvl(r_ABR.INFORMATION37,'N')
	     ,P_USES_VARBL_RT_FLAG            => 'N'  -- uses variable rate
	     ,P_USE_CALC_ACTY_BS_RT_FLAG      => 'Y'  -- value is to be computed
	     ,P_USE_TO_CALC_NET_FLX_CR_FLAG   => nvl(r_ABR.INFORMATION25,'N')
	     ,P_VAL                           => r_ABR.INFORMATION295
	     ,P_VAL_CALC_RL                   => r_ABR.information282
	     ,P_VAL_OVRID_ALWD_FLAG           => nvl(r_ABR.INFORMATION38,'N')
	     ,P_VSTG_FOR_ACTY_RT_ID           => r_ABR.information271
	     ,P_VSTG_SCHED_APLS_FLAG          => nvl(r_ABR.INFORMATION33,'N')
             ,P_WSH_RL_DY_MO_NUM              => r_ABR.INFORMATION270
             ,P_EFFECTIVE_START_DATE          => l_effective_start_date
             ,P_EFFECTIVE_END_DATE            => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER         => l_ovn
           );
           hr_utility.set_location('After plsql table ',222);
           update ben_copy_entity_results
           set information1 = l_abr_id
           where copy_entity_result_id = r_abr.copy_entity_result_id;
           hr_utility.set_location('abr id updated '||l_abr_id,222);
       else
          l_message_text := 'invalid oper'||r_ABR.dml_operation
          ||' pl id is '||r_ABR.INFORMATION261
          ||' abr id is '||l_abr_id
          ||' hrr id is '||r_abr.information266
          ||' abr ovn is '||l_ovn
          ||' opt id is '||r_ABR.INFORMATION247;
          PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
          (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
          P_TXN_ID          => nvl(l_abr_id,p_copy_entity_txn_id),
          P_MODULE_CD       => 'PQH_GSP_STGBEN',
          p_context         => 'ABR',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => l_message_text,
          p_effective_date  => p_effective_date);
       end if;
       exception when others then
          hr_utility.set_location('issues in writing abr, skipping'||l_proc,100);
          raise;
       end;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'ABR',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'ABR',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_abr;
procedure stage_to_epa(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_datetrack_mode     in varchar2) is
   cursor c_epa is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'EPA'
   and   dml_operation = 'INSERT' ; -- only insert should be there
   --
   r_epa                     c_epa%rowtype;
   l_proc                    varchar2(61) :='stage_to_epa';
   l_epa_id                  number ;
   l_ovn                     number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_message_text            varchar2(2000);
   l_effective_date          date;
   l_tab varchar2(30);
   l_pk number;
   l_plip_id number;
   l_pl_id number;
   l_oipl_id number;
   l_pgm_id number;
begin
   hr_utility.set_location('inside '||l_proc,10);
   for r_epa in c_epa loop
       l_epa_id := r_epa.information1;
       hr_utility.set_location('for epa_id:'||l_epa_id ||'dml '||r_epa.dml_operation,20);
       hr_utility.set_location('epa_cer_id:'||r_epa.copy_entity_result_id,20);
       if r_epa.gs_mirror_src_entity_result_id is not null then
          begin
             select information1,table_alias
             into l_pk, l_tab
             from ben_copy_entity_results
             where copy_entity_result_id = r_epa.gs_mirror_src_entity_result_id;
          exception
             when others then
                raise;
          end;
          hr_utility.set_location('parent tab is'||l_tab ||' pk is '||l_pk,5);
          if l_tab ='PGM' then
             l_pgm_id := l_pk;
             l_plip_id := null;
             l_oipl_id := null;
             l_pl_id := null;
          elsif l_tab = 'CPP' then
             l_plip_id := l_pk;
             l_pgm_id := null;
             l_oipl_id := null;
             l_pl_id := null;
          elsif l_tab = 'PLN' then
             l_pl_id := l_pk;
             l_plip_id := null;
             l_oipl_id := null;
             l_pgm_id := null;
          elsif l_tab = 'COP' then
-- we may not have oipl id in information1 when step api creates the oipl
             l_oipl_id := l_pk;
             l_plip_id := null;
             l_pgm_id := null;
             l_pl_id := null;
          else
             l_oipl_id := null;
             l_plip_id := null;
             l_pgm_id := null;
             l_pl_id := null;
             l_pk := null;
          end if;
       end if;
       l_effective_date := r_epa.information2;
       begin
       if l_epa_id is null and l_pk is not null and r_epa.dml_operation = 'INSERT' then
           hr_utility.set_location(' BEN_PRTN_ELIG_F CREATE_PARTICIPATION_ELIG ',20);
           BEN_PARTICIPATION_ELIG_API.CREATE_PARTICIPATION_ELIG(
             P_EFFECTIVE_DATE             => l_effective_date
             ,P_BUSINESS_GROUP_ID         => p_business_group_id
	     ,P_MX_POE_APLS_CD            => r_EPA.INFORMATION17
	     ,P_MX_POE_DET_DT_CD          => r_EPA.INFORMATION13
	     ,P_MX_POE_DET_DT_RL          => r_EPA.INFORMATION269
	     ,P_MX_POE_RL                 => r_EPA.INFORMATION267
	     ,P_MX_POE_UOM                => r_EPA.INFORMATION11
	     ,P_MX_POE_VAL                => r_EPA.INFORMATION266
	     ,P_OIPL_ID                   => l_oipl_id
	     ,P_PGM_ID                    => l_pgm_id
	     ,P_PLIP_ID                   => l_plip_id
	     ,P_PL_ID                     => l_pl_id
	     ,P_PRTN_EFF_END_DT_CD        => r_EPA.INFORMATION16
	     ,P_PRTN_EFF_END_DT_RL        => r_EPA.INFORMATION271
	     ,P_PRTN_EFF_STRT_DT_CD       => r_EPA.INFORMATION15
	     ,P_PRTN_EFF_STRT_DT_RL       => r_EPA.INFORMATION270
	     ,P_PRTN_ELIG_ID              => l_epa_id
	     ,P_PTIP_ID                   => r_EPA.INFORMATION259
	     ,P_WAIT_PERD_DT_TO_USE_CD    => r_EPA.INFORMATION12
	     ,P_WAIT_PERD_DT_TO_USE_RL    => r_EPA.INFORMATION264
	     ,P_WAIT_PERD_RL              => r_EPA.INFORMATION268
	     ,P_WAIT_PERD_UOM             => r_EPA.INFORMATION14
             ,P_WAIT_PERD_VAL             => r_EPA.INFORMATION287
             ,P_EFFECTIVE_START_DATE      => l_effective_start_date
             ,P_EFFECTIVE_END_DATE        => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER     => l_ovn
           );
           update ben_copy_entity_results
           set information1 = l_epa_id
           where copy_entity_result_id = r_epa.copy_entity_result_id;
       else
          l_message_text := 'invalid oper'||r_epa.dml_operation
          ||' epa_id is'||l_epa_id
          ||' epa_ovn is'||l_ovn
          ||' l_tab is'||l_tab
          ||' l_pk is'||l_pk;
          PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
          (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
          P_TXN_ID          => nvl(l_epa_id,p_copy_entity_txn_id),
          P_MODULE_CD       => 'PQH_GSP_STGBEN',
          p_context         => 'EPA',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => l_message_text,
          p_effective_date  => p_effective_date);
       end if;
       exception when others then
          hr_utility.set_location('issues in writing epa, skipping'||l_proc,100);
          raise;
       end;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'EPA',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'EPA',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_epa;
procedure stage_to_vpf(p_copy_entity_txn_id in number,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_datetrack_mode     in varchar2) is
   cursor c_crr is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'CRRATE'
   and   dml_operation in ('INSERT','UPDATE') -- only insert/ updates should be there
   order by information230,information169,information160,information2;
   --
   l_proc                    varchar2(61) :='stage_to_crr';
   l_crr_id                  number ;
   l_abr_id                  number ;
   l_avr_id                  number ;
   l_message_text            varchar2(2000);
   l_object                  varchar2(80);
   l_vep_id                  number ;
   l_crr_ovn                 number ;
   l_ovn                     number ;
   l_db_ovn                  number;
   l_avr_num                 number ;
   l_esd                     date ;
   l_eed                     date ;
   l_effective_date          date;
   dummy char(1);
   l_elp_id number;
   l_old_grd_cer_id number;
   l_old_pnt_cer_id number;
   l_old_abr_id number;
   l_old_crr_id number;
   l_old_crset_id number;
   l_old_crr_ovn number;
   l_old_crr_name varchar2(240);
   l_crr_name varchar2(240);
   l_dml_operation varchar2(30);
   l_dt_mode varchar2(30);
begin
   hr_utility.set_location('inside '||l_proc,10);
   for crr_rec in c_crr loop
       l_effective_date := crr_rec.information2;
       if crr_rec.information278 is null then
          hr_utility.set_location('new variable rate is being created'||l_proc,10);
          if (crr_rec.information230 is null or crr_rec.information230 = l_old_grd_cer_id)
          and (crr_rec.information169 is null or crr_rec.information169 = l_old_pnt_cer_id)
          and crr_rec.information160 = l_old_crset_id
          and l_old_crr_id is not null then
             hr_utility.set_location('reusing prev row pk and ovn',16);
             l_crr_id := l_old_crr_id; -- previous row created id can be used
             l_crr_ovn := l_old_crr_ovn;
             l_abr_id  := l_old_abr_id;
             l_crr_name := l_old_crr_name;
          else
             hr_utility.set_location('nothing to reuse'||l_proc,10);
             l_crr_id := crr_rec.information278;
             l_crr_ovn := crr_rec.information298;
             l_abr_id  := '';
             l_avr_num := '';
             l_crr_name := build_vpf_name(p_crset_id           => crr_rec.information160,
                                          p_point_cer_id       => crr_rec.information169,
                                          p_grade_cer_id       => crr_rec.information230,
                                          p_copy_entity_txn_id => p_copy_entity_txn_id);
          end if;
       else
          hr_utility.set_location('existing vpf is being updated'||l_proc,10);
          l_crr_id := crr_rec.information278;
          l_crr_ovn := crr_rec.information298;
          l_abr_id  := '';
          l_avr_num := '';
          l_crr_name := crr_rec.information170;
       end if;
       if crr_rec.dml_operation = 'INSERT'
          and nvl(crr_rec.datetrack_mode,'CORRECTION') <> 'UPDATE_REPLACE' then
          l_dml_operation := 'INSERT';
       elsif crr_rec.dml_operation = 'INSERT' and crr_rec.datetrack_mode = 'UPDATE_REPLACE' then
          l_dml_operation := 'UPDATE';
       elsif crr_rec.dml_operation = 'UPDATE' then
          l_dml_operation := 'UPDATE';
       end if;
       if l_abr_id is null and crr_rec.information161 is not null then
          hr_utility.set_location('abr_id is null ,getting it'||l_proc,10);
          begin
             select information1
             into l_abr_id
             from ben_copy_entity_results
             where copy_entity_txn_id = p_copy_entity_txn_id
             and copy_entity_result_id = crr_rec.information161;
          exception
             when no_data_found then
                hr_utility.set_location('abr id not found'||l_proc,100);
             when others then
                hr_utility.set_location('issues in getting abr'||l_proc,100);
                raise;
          end;
       else
          hr_utility.set_location('abr_id is '||l_abr_id,10);
       end if;
       if l_dml_operation = 'INSERT' and l_abr_id is not null and l_crr_id is null and l_crr_ovn is null then
          begin
             hr_utility.set_location(' BEN_VRBL_RT_PRFL_F CREATE_VRBL_RATE_PROFILE ',20);
             BEN_VRBL_RATE_PROFILE_API.CREATE_VRBL_RATE_PROFILE(
               P_EFFECTIVE_DATE         => l_effective_date
               ,P_BUSINESS_GROUP_ID     => p_business_group_id
	       ,P_ACTY_TYP_CD           => 'GSPSA'
	       ,P_NAME                  => l_crr_name
	       ,P_VAL                   => nvl(crr_rec.INFORMATION293,0)
	       ,P_VRBL_RT_PRFL_ID       => l_crr_id
	       ,P_VRBL_RT_PRFL_STAT_CD  => 'A'
               ,P_ACTY_REF_PERD_CD      => 'MO'
	       ,P_VRBL_RT_TRTMT_CD      => 'RPLC'
               ,P_VRBL_USG_CD           => 'RT'
               ,P_RT_ELIG_PRFL_FLAG     => 'N'
	       ,P_RT_AGE_FLAG             => 'N'
	       ,P_RT_ASNT_SET_FLAG        => 'N'
	       ,P_RT_BENFTS_GRP_FLAG      => 'N'
	       ,P_RT_BRGNG_UNIT_FLAG      => 'N'
	       ,P_RT_CBR_QUALD_BNF_FLAG   => 'N'
	       ,P_RT_CMBN_AGE_LOS_FLAG    => 'N'
	       ,P_RT_CNTNG_PRTN_PRFL_FLAG => 'N'
	       ,P_RT_COMPTNCY_FLAG        => 'N'
	       ,P_RT_COMP_LVL_FLAG        => 'N'
	       ,P_RT_DPNT_CVRD_PGM_FLAG   => 'N'
	       ,P_RT_DPNT_CVRD_PLIP_FLAG => 'N'
	       ,P_RT_DPNT_CVRD_PL_FLAG   => 'N'
	       ,P_RT_DPNT_CVRD_PTIP_FLAG => 'N'
	       ,P_RT_DPNT_OTHR_PTIP_FLAG => 'N'
	       ,P_RT_DSBLD_FLAG         => 'N'
	       ,P_RT_EE_STAT_FLAG       => 'N'
	       ,P_RT_ENRLD_OIPL_FLAG    => 'N'
	       ,P_RT_ENRLD_PGM_FLAG     => 'N'
	       ,P_RT_ENRLD_PLIP_FLAG    => 'N'
	       ,P_RT_ENRLD_PL_FLAG      => 'N'
	       ,P_RT_ENRLD_PTIP_FLAG    => 'N'
	       ,P_RT_FL_TM_PT_TM_FLAG   => 'N'
	       ,P_RT_GNDR_FLAG          => 'N'
	       ,P_RT_GRD_FLAG           => 'N'
	       ,P_RT_HLTH_CVG_FLAG      => 'N'
	       ,P_RT_HRLY_SLRD_FLAG     => 'N'
	       ,P_RT_HRS_WKD_FLAG       => 'N'
	       ,P_RT_JOB_FLAG           => 'N'
	       ,P_RT_LBR_MMBR_FLAG      => 'N'
	       ,P_RT_LGL_ENTY_FLAG      => 'N'
	       ,P_RT_LOA_RSN_FLAG       => 'N'
	       ,P_RT_LOS_FLAG           => 'N'
	       ,P_RT_LVG_RSN_FLAG       => 'N'
	       ,P_RT_NO_OTHR_CVG_FLAG   => 'N'
	       ,P_RT_OPTD_MDCR_FLAG     => 'N'
	       ,P_RT_ORG_UNIT_FLAG      => 'N'
	       ,P_RT_OTHR_PTIP_FLAG     => 'N'
	       ,P_RT_PCT_FL_TM_FLAG     => 'N'
	       ,P_RT_PERF_RTNG_FLAG     => 'N'
	       ,P_RT_PER_TYP_FLAG       => 'N'
	       ,P_RT_POE_FLAG           => 'N'
	       ,P_RT_PPL_GRP_FLAG       => 'N'
	       ,P_RT_PRFL_RL_FLAG       => 'N'
	       ,P_RT_PRTT_ANTHR_PL_FLAG => 'N'
	       ,P_RT_PRTT_PL_FLAG       => 'N'
	       ,P_RT_PSTL_CD_FLAG       => 'N'
	       ,P_RT_PSTN_FLAG          => 'N'
	       ,P_RT_PYRL_FLAG          => 'N'
	       ,P_RT_PY_BSS_FLAG        => 'N'
	       ,P_RT_QUAL_TITL_FLAG     => 'N'
	       ,P_RT_QUA_IN_GR_FLAG     => 'N'
	       ,P_RT_SCHEDD_HRS_FLAG    => 'N'
	       ,P_RT_SVC_AREA_FLAG      => 'N'
	       ,P_RT_TBCO_USE_FLAG      => 'N'
	       ,P_RT_TTL_CVG_VOL_FLAG   => 'N'
	       ,P_RT_TTL_PRTT_FLAG      => 'N'
	       ,P_RT_WK_LOC_FLAG        => 'N'
	       ,P_ASMT_TO_USE_CD        => 'ANY'
	       ,P_TX_TYP_CD             => 'PRETAX'
	       ,P_MLT_CD                => 'FLFX'
               ,P_EFFECTIVE_START_DATE  => l_esd
               ,P_EFFECTIVE_END_DATE    => l_eed
               ,P_OBJECT_VERSION_NUMBER => l_crr_ovn
             );
             hr_utility.set_location('after vpf insert ',222);
             begin
                if l_avr_num is null then
                   hr_utility.set_location('1st crr for abr',222);
                   begin
                      select null
                      into dummy
                      from ben_acty_base_rt_f
                      where acty_base_rt_id = l_abr_id
                      and USES_VARBL_RT_FLAG = 'Y'
                      and l_effective_date between effective_start_date
                                               and effective_end_date;
                   exception
                      when no_data_found then
                         hr_utility.set_location('abr has vrbl flag No',222);
                         begin
                            update ben_acty_base_rt_f
                            set USES_VARBL_RT_FLAG = 'Y'
                            where acty_base_rt_id = l_abr_id;
                            hr_utility.set_location('updated to Yes',223);
                         exception
                            when others then
                               hr_utility.set_location('issues in updating abr flag to Y',225);
                               raise;
                         end;
                      when others then
                         hr_utility.set_location('issues in gettting abr row ',226);
                         raise;
                   end;
                   select nvl(max(ordr_num),0) + 1
                   into l_avr_num
                   from ben_acty_vrbl_rt_f
                   where acty_base_rt_id = l_abr_id;
                else
                   l_avr_num := l_avr_num + 1;
                end if;
                hr_utility.set_location(' BEN_ACTY_VRBL_RT_F CREATE_ACTY_VRBL_RATE ',20);
                BEN_ACTY_VRBL_RATE_API.CREATE_ACTY_VRBL_RATE(
                P_EFFECTIVE_DATE         => l_effective_date
                ,P_BUSINESS_GROUP_ID     => p_business_group_id
                ,P_ACTY_BASE_RT_ID       => l_abr_id
      	        ,P_ACTY_VRBL_RT_ID       => l_avr_id
	        ,P_ORDR_NUM              => l_avr_num
                ,P_VRBL_RT_PRFL_ID       => l_crr_id
                ,P_EFFECTIVE_START_DATE  => l_esd
                ,P_EFFECTIVE_END_DATE    => l_eed
                ,P_OBJECT_VERSION_NUMBER => l_ovn
              );
             exception when others then
                hr_utility.set_location('issues in writing avr'||l_proc,100);
                raise;
             end;
             if crr_rec.information279 is null and crr_rec.information160 is not null then
                -- elp id is null for crrate while crset id is there
                begin
                   select information277
                   into l_elp_id
                   from ben_copy_entity_results
                   where copy_entity_txn_id = p_copy_entity_txn_id
                   and table_alias = 'CRSET'
                   and information161 = crr_rec.information160;
                exception
                   when others then
                      l_elp_id := '';
                end;
             else
                l_elp_id :=  crr_rec.information279;
             end if;
             if l_elp_id is null or l_crr_id is null then
                l_message_text := 'fks not there for creating vep row'
                ||' elp_id is '||l_elp_id
                ||' effdt is '||to_char(p_effective_date,'DD/MM/RRRR')
                ||' vpf id is '||l_crr_id;
                PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
                (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
                P_TXN_ID          => nvl(l_crr_id,p_copy_entity_txn_id),
                P_MODULE_CD       => 'PQH_GSP_STGBEN',
                p_context         => 'VPF',
                P_MESSAGE_TYPE_CD => 'E',
                P_MESSAGE_TEXT    => l_message_text,
                p_effective_date  => p_effective_date);
             else
                begin
                   hr_utility.set_location(' BEN_VRBL_RT_ELIG_PRFL_F CREATE_VRBL_RT_ELIG_PRFL ',20);
                   BEN_VRBL_RT_ELIG_PRFL_API.CREATE_VRBL_RT_ELIG_PRFL(
                   P_EFFECTIVE_DATE         => p_effective_date -- vep will be created as of Grade ladder effdt
                   ,P_BUSINESS_GROUP_ID     => p_business_group_id
                   ,P_ELIGY_PRFL_ID         => l_elp_id
                   ,P_MNDTRY_FLAG           => 'Y'
                   ,P_VRBL_RT_ELIG_PRFL_ID  => l_vep_id
                   ,P_VRBL_RT_PRFL_ID       => l_crr_id
                   ,P_EFFECTIVE_START_DATE  => l_esd
                   ,P_EFFECTIVE_END_DATE    => l_eed
                   ,P_OBJECT_VERSION_NUMBER => l_ovn
                   );
                exception when others then
                   l_message_text := 'issues in writing vep '
                   ||' elp_id is '||l_elp_id
                   ||' GL effdt is '||to_char(p_effective_date,'DD/MM/RRRR')
                   ||' VR effdt is '||to_char(l_effective_date,'DD/MM/RRRR')
                   ||' vpf id is '||l_crr_id;
                   PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
                   (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
                   P_TXN_ID          => nvl(l_crr_id,p_copy_entity_txn_id),
                   P_MODULE_CD       => 'PQH_GSP_STGBEN',
                   p_context         => 'VPF',
                   P_MESSAGE_TYPE_CD => 'E',
                   P_MESSAGE_TEXT    => l_message_text,
                   p_effective_date  => p_effective_date);
                   raise;
                end;
             end if;
          exception when others then
             hr_utility.set_location('issues in writing var'||l_proc,100);
             raise;
          end;
       elsif l_dml_operation = 'UPDATE'
             and l_abr_id is not null
             and l_crr_id is not null
             and l_crr_ovn is not null then
             hr_utility.set_location(' BEN_VRBL_RT_PRFL_F UPDATE_VRBL_RATE_PROFILE ',30);
             hr_utility.set_location(' dt mode is '||p_datetrack_mode,30);
             --if p_datetrack_mode <> 'CORRECTION' then   /* Commented out to fix Bug:3964291 */
                l_dt_mode := get_update_mode(p_table_name  => 'BEN_VRBL_RT_PRFL_F',
                                             p_key_column_name => 'VRBL_RT_PRFL_ID',
                                             p_key_column_value => l_crr_id,
                                             p_effective_date => l_effective_date);
                hr_utility.set_location(' dt mode is '||l_dt_mode,30);
             /*else
                l_dt_mode := p_datetrack_mode;
             end if;*/
           l_db_ovn := get_ovn(p_table_name         => 'BEN_VRBL_RT_PRFL_F',
                               p_key_column_name    => 'VRBL_RT_PRFL_ID',
                               p_key_column_value   => l_crr_id,
                               p_effective_date     => l_effective_date);
           hr_utility.set_location(' ovn is '||l_db_ovn,30);
           if l_db_ovn <> l_crr_ovn then
              l_object := hr_general.decode_lookup('PQH_GSP_OBJECT_TYPE','VPF');
              fnd_message.set_name('PQH','PQH_GSP_OBJ_OVN_INVALID');
              fnd_message.set_token('OBJECT ',l_object);
              fnd_message.set_token('OBJECT_NAME ','VPF : '||l_crr_id);
              fnd_message.raise_error;
           else
              begin
                 BEN_VRBL_RATE_PROFILE_API.UPDATE_VRBL_RATE_PROFILE(
                 P_EFFECTIVE_DATE         => l_effective_date
   	         ,P_VAL                   => crr_rec.INFORMATION293
   	         ,P_VRBL_RT_PRFL_ID       => l_crr_id
                 ,P_EFFECTIVE_START_DATE  => l_esd
                 ,P_EFFECTIVE_END_DATE    => l_eed
                 ,P_OBJECT_VERSION_NUMBER => l_crr_ovn
                 ,P_DATETRACK_MODE        => l_dt_mode
                 );
              exception when others then
                 hr_utility.set_location('issues in updating var'||l_proc,100);
                 raise;
              end;
           end if;
       else
         l_message_text := 'invalid operation '||l_dml_operation
          ||' abr_id is '||l_abr_id
          ||' crr_ovn is '||l_crr_ovn
          ||' crr_name is '||l_crr_name
          ||' val is '||crr_rec.INFORMATION293
          ||' crr_id is '||l_crr_id;
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
         P_TXN_ID          => nvl(l_crr_id,p_copy_entity_txn_id),
         P_MODULE_CD       => 'PQH_GSP_STGBEN',
         p_context         => 'VPF',
         P_MESSAGE_TYPE_CD => 'E',
         P_MESSAGE_TEXT    => l_message_text,
         p_effective_date  => p_effective_date);
       end if;
       l_old_crr_ovn := l_crr_ovn;
       l_old_abr_id  := l_abr_id;
       l_old_crr_id  := l_crr_id;
       l_old_crr_name := l_crr_name;
       l_old_grd_cer_id := crr_rec.information230;
       l_old_pnt_cer_id := crr_rec.information169;
       l_old_crset_id   := crr_rec.information160;
   end loop;
   hr_utility.set_location('leaving '||l_proc,100);
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID  => p_copy_entity_txn_id,
      P_TXN_ID          => p_copy_entity_txn_id,
      P_MODULE_CD       => 'PQH_GSP_STGBEN',
      p_context         => 'VPF',
      P_MESSAGE_TYPE_CD => 'E',
      P_MESSAGE_TEXT    => 'VPF',
      p_effective_date  => p_effective_date);
      raise;
end stage_to_vpf;
   FUNCTION get_pgm_name (p_pgm_id IN NUMBER, p_effective_date IN DATE)
      RETURN VARCHAR2
   IS
      l_pgm_name   ben_pgm_f.NAME%TYPE;
   BEGIN
      SELECT NAME
        INTO l_pgm_name
        FROM ben_pgm_f
       WHERE pgm_id = p_pgm_id
         AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

      RETURN l_pgm_name;
   END get_pgm_name;

      PROCEDURE create_le_for_pgm (
      p_pgm_id              IN   NUMBER,
      p_business_group_id   IN   NUMBER,
      p_ler_id              IN   NUMBER,
      p_effective_date      IN   DATE
   )
   IS
      l_pet_id       NUMBER;
      l_lee_rsn_id   NUMBER;
      l_continue     BOOLEAN DEFAULT FALSE;
      l_esd          DATE;
      l_eed          DATE;
      l_ovn          NUMBER;

      CURSOR csr_pgm_enrl (p_pgm_id IN NUMBER)
      IS
         SELECT popl_enrt_typ_cycl_id
           FROM ben_popl_enrt_typ_cycl_f
          WHERE pgm_id = p_pgm_id;

      CURSOR csr_lee_rsns (p_popl_enrt_typ_cycl_id IN NUMBER)
      IS
         SELECT NULL
           FROM ben_lee_rsn_f
          WHERE ler_id = p_ler_id
            AND business_group_id = p_business_group_id
            AND popl_enrt_typ_cycl_id = p_popl_enrt_typ_cycl_id;
   BEGIN
      OPEN csr_pgm_enrl (p_pgm_id);

      FETCH csr_pgm_enrl
       INTO l_pet_id;

      CLOSE csr_pgm_enrl;

      OPEN csr_lee_rsns (l_pet_id);

      FETCH csr_lee_rsns
       INTO l_lee_rsn_id;

      IF csr_lee_rsns%NOTFOUND
      THEN
         l_continue := TRUE;
      END IF;

      CLOSE csr_lee_rsns;

      IF l_continue
      THEN
         ben_life_event_enroll_rsn_api.create_life_event_enroll_rsn
                                 (p_effective_date             => p_effective_date,
                                  p_business_group_id          => p_business_group_id,
                                  p_lee_rsn_id                 => l_lee_rsn_id,
                                  p_ler_id                     => p_ler_id,
                                  p_popl_enrt_typ_cycl_id      => l_pet_id,
                                  p_effective_start_date       => l_esd,
                                  p_effective_end_date         => l_eed,
                                  p_object_version_number      => l_ovn,
                                  p_cls_enrt_dt_to_use_cd      => 'ELCNSMADE',
                                  p_enrt_cvg_end_dt_cd         => 'ODBED',
                                  p_enrt_cvg_strt_dt_cd        => 'AED',
                                  p_enrt_perd_end_dt_cd        => 'ALDCPPY',
                                  p_enrt_perd_strt_dt_cd       => 'AED',
                                  p_rt_end_dt_cd               => 'ODBED',
                                  p_rt_strt_dt_cd              => 'AED'
                                 );
      fnd_file.put_line (which      => fnd_file.LOG,
                         buff       =>    'Program Name : '
                                       || get_pgm_name (p_pgm_id,
                                                        p_effective_date
                                                       )
                        );
      fnd_file.put_line (which      => fnd_file.LOG,
                         buff       => 'Program Id : ' || p_pgm_id
                        );
END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_file.put_line
            (which      => fnd_file.LOG,
             buff       => 'Error while creating Program Enrollement Reasons..exiting'
            );
         ROLLBACK;
   END create_le_for_pgm;

   PROCEDURE create_pgm_le (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      NUMBER,
      p_effective_date      IN              VARCHAR2,
      p_business_group_id   IN              VARCHAR2,
      p_pgm_id              IN              NUMBER DEFAULT NULL
   )
   IS
      CURSOR csr_ler_id
      IS
         SELECT ler_id
           FROM ben_ler_f
          WHERE typ_cd = 'GSP'
            AND lf_evt_oper_cd = 'SYNC'
            AND business_group_id = p_business_group_id
            AND effective_start_date = pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id, null);

      CURSOR csr_pgm_details (eff_date IN DATE)
      IS
         SELECT pgm_id
           FROM ben_pgm_f
          WHERE business_group_id = p_business_group_id
            AND pgm_typ_cd = 'GSP'
            AND eff_date BETWEEN effective_start_date AND effective_end_date;

      Cursor csr_pgm_start_date(p_program_id in number)
      is
      select min(effective_start_date)
      from ben_pgm_f
      where pgm_id = p_program_id;

      l_ler_id                     NUMBER;
      l_effective_date             DATE;
      l_pgm_effective_start_date   DATE;
   BEGIN
      fnd_file.put_line (which      => fnd_file.LOG,buff => 'Entering create_pgm_le');
      l_effective_date := TO_DATE (p_effective_date, 'YYYY/MM/DD HH24:MI:SS');
      l_effective_date :=TO_DATE (TO_CHAR (TRUNC (l_effective_date), 'DD/MM/RRRR'),'DD/MM/RRRR');

      OPEN csr_ler_id;
      FETCH csr_ler_id
       INTO l_ler_id;

      IF csr_ler_id%NOTFOUND
      THEN
         errbuf :='No Life Event of Type Grade/Step Progression with Operator Code Synchronization found. Exiting';
         retcode := -20;
         RETURN;
      ELSE
         fnd_file.put_line (which => fnd_file.LOG,buff => 'Life Event Exists');
      END IF;

      CLOSE csr_ler_id;
      fnd_file.put_line
         (which      => fnd_file.LOG,
          buff       => 'Created Program Enrolment Reason for the following Programs '
         );
      fnd_file.put_line
         (which      => fnd_file.LOG,
          buff       => '==========================================================='
         );
      IF p_pgm_id IS NULL
      THEN
         FOR i IN csr_pgm_details (l_effective_date)
         LOOP
             OPEN csr_pgm_start_date(i.pgm_id);
             FETCH csr_pgm_start_date into l_pgm_effective_start_date;
             CLOSE csr_pgm_start_date;
            create_le_for_pgm (p_pgm_id                 => i.pgm_id,
                               p_business_group_id      => p_business_group_id,
                               p_ler_id                 => l_ler_id,
                               p_effective_date         => l_pgm_effective_start_date
                              );
         END LOOP;
      ELSE
         OPEN csr_pgm_start_date(p_pgm_id);
         FETCH csr_pgm_start_date into l_pgm_effective_start_date;
         CLOSE csr_pgm_start_date;
         create_le_for_pgm (p_pgm_id                 => p_pgm_id,
                            p_business_group_id      => p_business_group_id,
                            p_ler_id                 => l_ler_id,
                            p_effective_date         => l_pgm_effective_start_date
                           );
      END IF;
      COMMIT;
      fnd_file.put_line (which      => fnd_file.LOG,
                         buff       => 'Leaving create_pgm_le'
                        );
   END create_pgm_le;

procedure upd_stg_elig_prfl_id(
   p_copy_entity_txn_id  number
   ,p_business_group_id number
   ,p_effective_date     date
   )
is
begin
     hr_utility.set_location('Entering pqh_gsp_stage_to_ben.upd_stg_elig_prfl_id',99);

      update ben_copy_entity_results cer
      set information263 =
          ( select ELIGY_PRFL_ID
              from BEN_ELIGY_PRFL_F elp
             where elp.BUSINESS_GROUP_ID = p_business_group_id
               and elp.name = cer.information5
               and p_effective_date between
                   elp.effective_start_date and elp.effective_end_date)
      where cer.copy_entity_txn_id = p_copy_entity_txn_id
        and cer.information4 = p_business_group_id
        and cer.table_alias = 'CEP'
        and p_effective_date between
            cer.information2 and nvl(cer.information3,to_date('4712/12/31','YYYY/MM/DD'))
        and exists ( select ELIGY_PRFL_ID
                       from BEN_ELIGY_PRFL_F elp
                      where elp.BUSINESS_GROUP_ID = p_business_group_id
                        and elp.name = cer.information5
                        and p_effective_date between
                            elp.effective_start_date and elp.effective_end_date);

     hr_utility.set_location('No of staging rows updated :'||sql%rowcount||':',99);
     hr_utility.set_location('Leaving pqh_gsp_stage_to_ben.upd_stg_elig_prfl_id',99);
end upd_stg_elig_prfl_id ;

procedure cre_update_elig_prfl(
        p_copy_entity_txn_id in number
       ,p_effective_date     in date
       ,p_business_group_id  in number
       ,p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST')
is
l_delete_failed varchar2(10);
begin
  hr_utility.set_location('Entering pqh_gsp_stage_to_ben.cre_update_elig_prfl ',999);
  hr_utility.set_location('Copy_Entity_Txn_Id passed is:'||p_copy_entity_txn_id,800);
  hr_utility.set_location('Effective Date Passed is:'||p_effective_date,801);
  hr_utility.set_location('Business Group Id passed is:'||p_business_group_id,902);
  hr_utility.set_location('Business Area Passed is:'||p_business_area,903);

hr_utility.set_location('Calling purge:'||p_business_area,903);

pqh_gsp_prgrules.purge_duplicate_elp_tree(p_copy_entity_txn_id => p_copy_entity_txn_id);

hr_utility.set_location('Done with purge:'||p_business_area,903);

-- update the dml operation of those records which have already been
-- taken care by gsp pre push code

  UPDATE ben_copy_entity_results cer
     set dml_operation  = 'GSPDEL'
   where cer.copy_entity_txn_id = p_copy_entity_txn_id
     and cer.dml_operation = 'DELETE'
     and table_alias in ('CPP','CEP','EPA','COP','OPT','ABR');

  -- Set for same Business Group
  BEN_PD_COPY_TO_BEN_ONE.g_mapping_done := false ;

  -- Copied the following 4 calls from ben_plan_design_copy_process.process
  -- Populate table_route_id in staging table
  ben_plan_design_wizard_api.write_route_and_hierarchy(p_copy_entity_txn_id);
  ben_plan_design_wizard_api.update_result_rows(p_copy_entity_txn_id => p_copy_entity_txn_id);
  ben_plan_design_delete_api.call_delete_apis(
    p_copy_entity_txn_id => p_copy_entity_txn_id
   ,p_delete_failed      => l_delete_failed
   );

  UPDATE ben_copy_entity_results cer
     set number_of_copies = 0
   where cer.copy_entity_txn_id = p_copy_entity_txn_id
     and p_effective_date between nvl(information2,p_effective_date)
                              and nvl(information3,p_effective_date)
     and cer.dml_operation = 'DELETE';

  -- Initialise
  ben_pd_copy_to_ben_one.init_table_data_in_cer(p_copy_entity_txn_id);

    BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl.delete;
    BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(0) := null ;
    BEN_PD_COPY_TO_BEN_ONE.g_count := 1 ;

  -- Create all derived factors first

  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CLF') then
     hr_utility.set_location('   Calling create CLF rows ',999);
     BEN_PD_COPY_TO_BEN_ONE.create_CLF_rows(
        p_copy_entity_txn_id  => p_copy_entity_txn_id
       ,p_effective_date      => p_effective_date
       ,p_reuse_object_flag   => 'Y'
       ,p_target_business_group_id => p_business_group_id
     );
  end if;
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('HWF') then
     hr_utility.set_location('   Calling create HWF rows ',999);
     BEN_PD_COPY_TO_BEN_ONE.create_HWF_rows(
        p_copy_entity_txn_id  => p_copy_entity_txn_id
       ,p_effective_date      => p_effective_date
       ,p_reuse_object_flag   => 'Y'
       ,p_target_business_group_id => p_business_group_id
     );
  end if;
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('AGF') then
     hr_utility.set_location('   Calling create AGF rows ',999);
     BEN_PD_COPY_TO_BEN_ONE.create_AGF_rows(
        p_copy_entity_txn_id  => p_copy_entity_txn_id
       ,p_effective_date      => p_effective_date
       ,p_reuse_object_flag   => 'Y'
       ,p_target_business_group_id => p_business_group_id
     );
  end if;
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('LSF') then
     hr_utility.set_location('   Calling create LSF rows ',999);
     BEN_PD_COPY_TO_BEN_ONE.create_LSF_rows(
        p_copy_entity_txn_id  => p_copy_entity_txn_id
       ,p_effective_date      => p_effective_date
       ,p_reuse_object_flag   => 'Y'
       ,p_target_business_group_id => p_business_group_id
     );
  end if;
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('PFF') then
     hr_utility.set_location('   Calling create PFF rows ',999);
     BEN_PD_COPY_TO_BEN_ONE.create_PFF_rows(
        p_copy_entity_txn_id  => p_copy_entity_txn_id
       ,p_effective_date      => p_effective_date
       ,p_reuse_object_flag   => 'Y'
       ,p_target_business_group_id => p_business_group_id
     );
  end if;
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CLA') then
     hr_utility.set_location('   Calling create CLA rows ',999);
     BEN_PD_COPY_TO_BEN_ONE.create_CLA_rows(
        p_copy_entity_txn_id  => p_copy_entity_txn_id
       ,p_effective_date      => p_effective_date
       ,p_reuse_object_flag   => 'Y'
       ,p_target_business_group_id => p_business_group_id
     );
  end if;

  --
  -- Create ELP Row
  --

  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('ELP') then
     hr_utility.set_location('   Calling create ELP rows ',999);
     BEN_PD_COPY_TO_BEN_ONE.create_ELP_rows(
        p_copy_entity_txn_id  => p_copy_entity_txn_id
       ,p_effective_date      => p_effective_date
       ,p_reuse_object_flag   => 'Y'
       ,p_target_business_group_id => p_business_group_id
     );
  end if;

  --
  -- Create elig prf ben rows
  --

  hr_utility.set_location('   Calling create all elig prf ben rows',999);
  BEN_PD_COPY_TO_BEN_FOUR.create_all_elig_prf_ben_rows(
        p_copy_entity_txn_id  => p_copy_entity_txn_id
       ,p_effective_date      => p_effective_date
       ,p_reuse_object_flag   => 'Y'
       ,p_target_business_group_id => p_business_group_id
     );

  --
  -- Update elig_prfl_id of staging records
  --
  hr_utility.set_location('   Update elig_prfl_id in staging area ',999);
  upd_stg_elig_prfl_id(
     p_copy_entity_txn_id => p_copy_entity_txn_id
     ,p_business_group_id => p_business_group_id
     ,p_effective_date    => p_effective_date
  );

UPDATE ben_copy_entity_results cer
     set dml_operation  = 'DELETE'
   where cer.copy_entity_txn_id = p_copy_entity_txn_id
     and cer.dml_operation = 'GSPDEL';

  hr_utility.set_location('Leaving pqh_gsp_stage_to_ben.cre_update_elig_prfl ',999);
end cre_update_elig_prfl ;


end pqh_gsp_stage_to_ben;

/
