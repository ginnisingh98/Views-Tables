--------------------------------------------------------
--  DDL for Package Body PQH_GSP_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_RATES" as
/* $Header: pqgsprat.pkb 120.3.12010000.1 2008/07/28 12:57:52 appldev ship $ */
procedure delete_grrate(p_copy_entity_txn_id in number) is
begin
   delete from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='GRRATE';
exception
   when others then
      hr_utility.set_location('issues in deleteing gr rates',10);
      raise;
end delete_grrate;
procedure delete_gsrate(p_copy_entity_txn_id in number) is
begin
   delete from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='GSRATE';
exception
   when others then
      hr_utility.set_location('issues in deleteing gs rates',10);
      raise;
end delete_gsrate;
procedure get_point_value(p_point_cer_id         in number,
                         p_copy_entity_txn_id   in number,
                         p_crset_id             in number,
                         p_effective_start_date in date,
                         p_effective_end_date   in date,
                         p_point_value  out nocopy number,
                         p_point_old_value out nocopy number)
IS
begin
   hr_utility.set_location('point cer is '||p_point_cer_id,1);
   hr_utility.set_location('crset is '||p_crset_id,1);
   hr_utility.set_location('stdt is '||to_char(p_effective_start_date,'dd-mm-RRRR'),2);
   hr_utility.set_location('endt is '||to_char(p_effective_end_date,'dd-mm-RRRR'),3);
   select information293,information287
   into p_point_value,p_point_old_value
   from ben_copy_entity_results
   where table_alias = 'CRRATE'
   and copy_entity_txn_id = p_copy_entity_txn_id
   and information169 = p_point_cer_id
   and information160 = p_crset_id
   and p_effective_start_date between information2 and information3
   and p_effective_end_date between information2 and information3;
   hr_utility.set_location('rate is '||p_point_value,10);
exception
   when no_data_found then
      hr_utility.set_location('null value returned ',10);
   when others then
      hr_utility.set_location('issues in getting rate for'||p_point_cer_id,50);
      hr_utility.set_location('crset is '||p_crset_id,51);
      raise;
end get_point_value;
procedure get_point_value(p_point_cer_id         in number,
                         p_copy_entity_txn_id   in number,
                         p_effective_start_date in date,
                         p_effective_end_date   in date,
                         p_point_value out nocopy number,
                         p_point_old_value out nocopy number)is
begin
   hr_utility.set_location('point cer is '||p_point_cer_id,1);
   hr_utility.set_location('stdt is '||to_char(p_effective_start_date,'dd-mm-RRRR'),2);
   hr_utility.set_location('endt is '||to_char(p_effective_end_date,'dd-mm-RRRR'),3);
   select information297,information287
   into p_point_value,p_point_old_value
   from ben_copy_entity_results
   where table_alias = 'HRRATE'
   and copy_entity_txn_id = p_copy_entity_txn_id
   and information278 = p_point_cer_id
   and p_effective_start_date between information2 and information3
   and p_effective_end_date between information2 and information3;
   hr_utility.set_location('rate is '||p_point_value,10);
exception
   when no_data_found then
      hr_utility.set_location('null value returned ',10);
      p_point_value := null;
   when others then
      hr_utility.set_location('issues in getting rate'||p_point_cer_id,50);
      raise;
end get_point_value;
procedure build_grrate(p_copy_entity_txn_id in number,
                       p_gr_rate_matx       in t_gs_rate_matx,
                       p_effective_date     in date,
                       p_business_group_id  in number) is
   l_grr_tr_id number;
   l_grr_tr_name varchar2(80);
   l_grr_cer_id number;
   l_grr_cer_ovn number;
   l_point1_value number default null;
   l_point2_value number default null;
   l_point3_value number default null;
   l_point4_value number default null;
   l_point5_value number default null;
   l_point1_old_value number default null;
   l_point2_old_value number default null;
   l_point3_old_value number default null;
   l_point4_old_value number default null;
   l_point5_old_value number default null;

begin
   pqh_gsp_hr_to_stage.get_table_route_details(p_table_alias    => 'GRRATE',
                           p_table_route_id => l_grr_tr_id,
                           p_table_name     => l_grr_tr_name);
   for i in 1..p_gr_rate_matx.count loop
      hr_utility.set_location('crset id is '||p_gr_rate_matx(i).crset_id,1);
      if p_gr_rate_matx(i).point1_cer_id is not null then
         hr_utility.set_location('going for value ',1);
         get_point_value(p_point_cer_id         => p_gr_rate_matx(i).point1_cer_id,
                         p_copy_entity_txn_id   => p_copy_entity_txn_id,
                         p_crset_id             => p_gr_rate_matx(i).crset_id,
                         p_effective_start_date => p_gr_rate_matx(i).esd,
                         p_effective_end_date   => p_gr_rate_matx(i).eed,
                         p_point_value          => l_point1_value,
                         p_point_old_value      => l_point1_old_value);
      else
         l_point1_value   := null;
         l_point1_old_value := null;
      end if;
      if p_gr_rate_matx(i).point2_cer_id is not null then
         hr_utility.set_location('going for value ',1);
         get_point_value(p_point_cer_id         => p_gr_rate_matx(i).point2_cer_id,
                         p_copy_entity_txn_id   => p_copy_entity_txn_id,
                         p_crset_id             => p_gr_rate_matx(i).crset_id,
                         p_effective_start_date => p_gr_rate_matx(i).esd,
                         p_effective_end_date   => p_gr_rate_matx(i).eed,
                         p_point_value          => l_point2_value,
                         p_point_old_value      => l_point2_old_value);
      else
         l_point2_value   := null;
         l_point2_old_value := null;
      end if;
      if p_gr_rate_matx(i).point3_cer_id is not null then
         hr_utility.set_location('going for value ',1);
         get_point_value(p_point_cer_id         => p_gr_rate_matx(i).point3_cer_id,
                         p_copy_entity_txn_id   => p_copy_entity_txn_id,
                         p_crset_id             => p_gr_rate_matx(i).crset_id,
                         p_effective_start_date => p_gr_rate_matx(i).esd,
                         p_effective_end_date   => p_gr_rate_matx(i).eed,
                         p_point_value          => l_point3_value,
                         p_point_old_value      => l_point3_old_value);
      else
         l_point3_value   := null;
         l_point3_old_value := null;
      end if;
      if p_gr_rate_matx(i).point4_cer_id is not null then
         hr_utility.set_location('going for value ',1);
         get_point_value(p_point_cer_id         => p_gr_rate_matx(i).point4_cer_id,
                         p_copy_entity_txn_id   => p_copy_entity_txn_id,
                         p_crset_id             => p_gr_rate_matx(i).crset_id,
                         p_effective_start_date => p_gr_rate_matx(i).esd,
                         p_effective_end_date   => p_gr_rate_matx(i).eed,
                         p_point_value          => l_point4_value,
                         p_point_old_value      => l_point4_old_value);
      else
         l_point4_value   := null;
         l_point4_old_value := null;
      end if;
      if p_gr_rate_matx(i).point5_cer_id is not null then
         hr_utility.set_location('going for value ',1);
         get_point_value(p_point_cer_id         => p_gr_rate_matx(i).point5_cer_id,
                         p_copy_entity_txn_id   => p_copy_entity_txn_id,
                         p_crset_id             => p_gr_rate_matx(i).crset_id,
                         p_effective_start_date => p_gr_rate_matx(i).esd,
                         p_effective_end_date   => p_gr_rate_matx(i).eed,
                         p_point_value          => l_point5_value,
                         p_point_old_value      => l_point5_old_value);
      else
         l_point5_value   := null;
         l_point5_old_value := null;
      end if;
      begin
         ben_copy_entity_results_api.create_copy_entity_results(
            p_effective_date              => p_effective_date
            ,p_copy_entity_txn_id         => p_copy_entity_txn_id
            ,p_result_type_cd             => 'DISPLAY'
            ,p_table_name                 => l_grr_tr_name
            ,p_table_route_id             => l_grr_tr_id
            ,p_table_alias                => 'GRRATE'
            ,p_information2               => p_gr_rate_matx(i).esd
            ,p_information3               => p_gr_rate_matx(i).eed
            ,p_information4               => p_business_group_id
            ,p_information160             => p_gr_rate_matx(i).grade_cer_id
            ,p_information162             => p_gr_rate_matx(i).plip_cer_id
            ,p_information161             => p_gr_rate_matx(i).crset_id
            ,p_information229             => p_gr_rate_matx(i).point1_cer_id
            ,p_information231             => p_gr_rate_matx(i).point2_cer_id
            ,p_information174             => p_gr_rate_matx(i).point3_cer_id
            ,p_information178             => p_gr_rate_matx(i).point4_cer_id
            ,p_information222             => p_gr_rate_matx(i).point5_cer_id
            ,p_information228             => p_gr_rate_matx(i).range
            ,p_information287             => l_point1_value
            ,p_information288             => l_point2_value
            ,p_information289             => l_point3_value
            ,p_information290             => l_point4_value
            ,p_information291             => l_point5_value
            ,p_information297             => l_point1_old_value
            ,p_information298             => l_point2_old_value
            ,p_information299             => l_point3_old_value
            ,p_information300             => l_point4_old_value
            ,p_information301             => l_point5_old_value
            ,p_copy_entity_result_id      => l_grr_cer_id
            ,p_object_version_number      => l_grr_cer_ovn);
      exception
         when others then
            hr_utility.set_location('issue in creation grrate cer ',400);
            raise;
      end;
   end loop;
end build_grrate;
procedure build_gsrate(p_copy_entity_txn_id in number,
                       p_gs_rate_matx       in t_gs_rate_matx,
                       p_effective_date     in date,
                       p_business_group_id  in number) is
   l_gsr_tr_id number;
   l_gsr_tr_name varchar2(80);
   l_gsr_cer_id number;
   l_gsr_cer_ovn number;
   l_point1_value number default null;
   l_point2_value number default null;
   l_point3_value number default null;
   l_point4_value number default null;
   l_point5_value number default null;
   l_point1_old_value number default null;
   l_point2_old_value number default null;
   l_point3_old_value number default null;
   l_point4_old_value number default null;
   l_point5_old_value number default null;
begin
   pqh_gsp_hr_to_stage.get_table_route_details(p_table_alias    => 'GSRATE',
                           p_table_route_id => l_gsr_tr_id,
                           p_table_name     => l_gsr_tr_name);
   for i in 1..p_gs_rate_matx.count loop
      if p_gs_rate_matx(i).point1_cer_id is not null then
         hr_utility.set_location('going for value ',1);
         get_point_value(p_point_cer_id => p_gs_rate_matx(i).point1_cer_id,
                         p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_effective_start_date => p_gs_rate_matx(i).esd,
                         p_effective_end_date => p_gs_rate_matx(i).eed,
                         p_point_value       =>l_point1_value,
                         p_point_old_value   => l_point1_old_value);
      else
        l_point1_value  :=null;
        l_point1_old_value  :=null;
      end if;
      if p_gs_rate_matx(i).point2_cer_id is not null then
         hr_utility.set_location('going for value ',1);
         get_point_value(p_point_cer_id => p_gs_rate_matx(i).point2_cer_id,
                         p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_effective_start_date => p_gs_rate_matx(i).esd,
                         p_effective_end_date => p_gs_rate_matx(i).eed,
                         p_point_value       =>l_point2_value,
                         p_point_old_value   => l_point2_old_value);
      else
        l_point2_value  :=null;
        l_point2_old_value  :=null;
      end if;
      if p_gs_rate_matx(i).point3_cer_id is not null then
         hr_utility.set_location('going for value ',1);
          get_point_value(p_point_cer_id => p_gs_rate_matx(i).point3_cer_id,
                          p_copy_entity_txn_id => p_copy_entity_txn_id,
                          p_effective_start_date => p_gs_rate_matx(i).esd,
                          p_effective_end_date => p_gs_rate_matx(i).eed,
                          p_point_value       =>l_point3_value,
                          p_point_old_value   => l_point3_old_value);
      else
        l_point3_value  :=null;
        l_point3_old_value  :=null;
      end if;
      if p_gs_rate_matx(i).point4_cer_id is not null then
         hr_utility.set_location('going for value ',1);
         get_point_value(p_point_cer_id => p_gs_rate_matx(i).point4_cer_id,
                         p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_effective_start_date => p_gs_rate_matx(i).esd,
                         p_effective_end_date => p_gs_rate_matx(i).eed,
                         p_point_value       =>l_point4_value,
                         p_point_old_value   => l_point4_old_value);
      else
        l_point4_value  :=null;
        l_point4_old_value  :=null;
      end if;
      if p_gs_rate_matx(i).point5_cer_id is not null then
         hr_utility.set_location('going for value ',1);
         get_point_value(p_point_cer_id => p_gs_rate_matx(i).point5_cer_id,
                         p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_effective_start_date => p_gs_rate_matx(i).esd,
                         p_effective_end_date => p_gs_rate_matx(i).eed,
                         p_point_value       =>l_point5_value,
                         p_point_old_value   => l_point5_old_value);
      else
        l_point5_value  :=null;
        l_point5_old_value  :=null;
      end if;
      begin
         ben_copy_entity_results_api.create_copy_entity_results(
            p_effective_date              => p_effective_date
            ,p_copy_entity_txn_id         => p_copy_entity_txn_id
            ,p_result_type_cd             => 'DISPLAY'
            ,p_table_name                 => l_gsr_tr_name
            ,p_table_route_id             => l_gsr_tr_id
            ,p_table_alias                => 'GSRATE'
            ,p_dml_operation              => '' -- hrrate has the values
            -- ,p_information1            => p_oipl_id         -- new ben object
            ,p_information2               => p_gs_rate_matx(i).esd
            ,p_information3               => p_gs_rate_matx(i).eed
            ,p_information4               => p_business_group_id
            ,p_information160             => p_gs_rate_matx(i).grade_cer_id
            ,p_information229             => p_gs_rate_matx(i).point1_cer_id
            ,p_information231             => p_gs_rate_matx(i).point2_cer_id
            ,p_information174             => p_gs_rate_matx(i).point3_cer_id
            ,p_information178             => p_gs_rate_matx(i).point4_cer_id
            ,p_information222             => p_gs_rate_matx(i).point5_cer_id
            ,p_information228             => p_gs_rate_matx(i).range
            ,p_information287             => l_point1_value
            ,p_information288             => l_point2_value
            ,p_information289             => l_point3_value
            ,p_information290             => l_point4_value
            ,p_information291             => l_point5_value
            ,p_information297             => l_point1_old_value
            ,p_information298             => l_point2_old_value
            ,p_information299             => l_point3_old_value
            ,p_information300             => l_point4_old_value
            ,p_information301             => l_point5_old_value
            ,p_copy_entity_result_id      => l_gsr_cer_id
            ,p_object_version_number      => l_gsr_cer_ovn);
      exception
         when others then
            hr_utility.set_location('issue in creation gsrate cer ',400);
            raise;
      end;
   end loop;
end build_gsrate;
procedure build_gs_rate_matrix(p_dt_matx             in t_pt_matx
                               ,p_gs_matx            in t_gs_matx
                               ,p_gs_rate_matx       out nocopy t_gs_rate_matx
                               ,p_business_group_id  in number
                               ,p_copy_entity_txn_id in number ) is
   gs_cnt number := 1;
   l_esd date;
   l_eed date;
   l_sot date := pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
   l_eot date := hr_general.end_of_time;
   l_num_rec number;
begin
   l_num_rec := p_dt_matx.count;
   if l_num_rec >1 then
      hr_utility.set_location('num_rec is'||l_num_rec,10);
      for i in 1..p_dt_matx.count loop
          l_esd := p_dt_matx(i);
          hr_utility.set_location('start date is'||to_char(l_esd,'dd-mm-RRRR'),10);
          if p_dt_matx.exists(i+1) then
             l_eed := p_dt_matx(i+1) - 1;
          else
             l_eed := l_eot;
          end if;
          hr_utility.set_location('end date is'||to_char(l_eed,'dd-mm-RRRR'),20);
          for j in 1..p_gs_matx.count loop
              p_gs_rate_matx(gs_cnt).grade_cer_id := p_gs_matx(j).grade_cer_id;
              p_gs_rate_matx(gs_cnt).plip_cer_id := p_gs_matx(j).plip_cer_id;
              p_gs_rate_matx(gs_cnt).num_steps := p_gs_matx(j).num_steps;
              p_gs_rate_matx(gs_cnt).crset_id := p_gs_matx(j).crset_id;
              p_gs_rate_matx(gs_cnt).range := p_gs_matx(j).range;
              p_gs_rate_matx(gs_cnt).point1_cer_id := p_gs_matx(j).point1_cer_id;
              p_gs_rate_matx(gs_cnt).point2_cer_id := p_gs_matx(j).point2_cer_id;
              p_gs_rate_matx(gs_cnt).point3_cer_id := p_gs_matx(j).point3_cer_id;
              p_gs_rate_matx(gs_cnt).point4_cer_id := p_gs_matx(j).point4_cer_id;
              p_gs_rate_matx(gs_cnt).point5_cer_id := p_gs_matx(j).point5_cer_id;
              p_gs_rate_matx(gs_cnt).esd := l_esd;
              p_gs_rate_matx(gs_cnt).eed := l_eed;
              gs_cnt := gs_cnt + 1;
          end loop;
      end loop;
   else
      hr_utility.set_location('num_rec is'||l_num_rec,10);
      l_esd := l_sot;
      l_eed := l_eot;
      for j in 1..p_gs_matx.count loop
          p_gs_rate_matx(j).grade_cer_id  := p_gs_matx(j).grade_cer_id;
          p_gs_rate_matx(j).plip_cer_id := p_gs_matx(j).plip_cer_id;
          p_gs_rate_matx(j).num_steps     := p_gs_matx(j).num_steps;
          p_gs_rate_matx(j).crset_id      := p_gs_matx(j).crset_id;
          p_gs_rate_matx(j).range         := p_gs_matx(j).range;
          p_gs_rate_matx(j).point1_cer_id := p_gs_matx(j).point1_cer_id;
          p_gs_rate_matx(j).point2_cer_id := p_gs_matx(j).point2_cer_id;
          p_gs_rate_matx(j).point3_cer_id := p_gs_matx(j).point3_cer_id;
          p_gs_rate_matx(j).point4_cer_id := p_gs_matx(j).point4_cer_id;
          p_gs_rate_matx(j).point5_cer_id := p_gs_matx(j).point5_cer_id;
          p_gs_rate_matx(j).esd           := l_esd;
          p_gs_rate_matx(j).eed           := l_eed;
      end loop;
   end if;
end build_gs_rate_matrix;
procedure update_date_ranges(p_start_date in date,
                             p_dt_matx    in out nocopy t_pt_matx) is
   l_exists boolean := false;
   l_count number;
begin
   for i in 1..p_dt_matx.count loop
      if p_dt_matx(i)= p_start_date then
         l_exists := true;
      end if;
   end loop;
   if not l_exists then
      l_count := nvl(p_dt_matx.last,0) + 1;
      p_dt_matx(l_count):= p_start_date;
   end if;
end;
procedure build_hrr_dt_matx(p_point_cer_id       in number,
                            p_copy_entity_txn_id in number,
                            p_effective_date     in date,
                            p_business_group_id  in number,
                            p_dt_matx            in out nocopy t_pt_matx) is
   cursor csr_dates is
      select information2 start_date
      from   ben_copy_entity_results
      where  copy_entity_txn_id = p_copy_entity_txn_id
      and    result_type_cd ='DISPLAY' -- which are displayed
      and    table_alias = 'HRRATE' -- check oipl row
      and    information278 = p_point_cer_id  -- check rate of point row
      order by 1 ;
   l_rate_st_dt date := pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
   l_abr_cer_id number;
   l_hrr_cer_id number;
   l_num_pt_rates number;
   l_min_st_dt date;
   l_max_end_dt date;
begin
   select count(*),min(information2),max(information3)
   into l_num_pt_rates,l_min_st_dt,l_max_end_dt
   from   ben_copy_entity_results
   where  copy_entity_txn_id = p_copy_entity_txn_id
   and    result_type_cd ='DISPLAY' -- which are displayed
   and    table_alias = 'HRRATE' -- check hrr row
   and    information278 = p_point_cer_id;
   if nvl(l_num_pt_rates,0) = 0 then
      hr_utility.set_location('creating abr for pt',5);
      pqh_gsp_hr_to_stage.create_abr_row
          (p_copy_entity_txn_id => p_copy_entity_txn_id,
           p_start_date         => l_rate_st_dt,
           p_opt_cer_id         => p_point_cer_id,
           p_business_group_id  => p_business_group_id,
           p_effective_date     => p_effective_date,
           p_abr_cer_id         => l_abr_cer_id,
           p_dml_oper           => '');
      if l_abr_cer_id is not null then
         hr_utility.set_location('creating hrr for pt',5);
         pqh_gsp_hr_to_stage.create_hrrate_row
             (p_copy_entity_txn_id => p_copy_entity_txn_id,
              p_effective_date     => p_effective_date,
              p_start_date         => l_rate_st_dt,
              p_business_group_id  => p_business_group_id,
              p_abr_cer_id         => l_abr_cer_id,
              p_point_cer_id       => p_point_cer_id,
              p_point_value        => 0,
              p_dml_oper           => '',
              p_hrrate_cer_id      => l_hrr_cer_id);
          if l_hrr_cer_id is null then
             hr_utility.set_location('issue in creating hrr',10);
          end if;
      else
         hr_utility.set_location('issue in creating abr',9);
      end if;
   else
      hr_utility.set_location('num of rates :'||l_num_pt_rates||'for point '||p_point_cer_id,10);
      hr_utility.set_location('min st date is '||to_char(l_min_st_dt,'dd-mm-RRRR'),10);
      hr_utility.set_location('max end date is '||to_char(l_max_end_dt,'dd-mm-RRRR'),10);
   end if;
   for rate in csr_dates loop
       hr_utility.set_location('date is '||to_char(rate.start_date,'dd-mm-RRRR'),10);
       update_date_ranges(p_start_date => rate.start_date,
                          p_dt_matx    => p_dt_matx);
   end loop;
end build_hrr_dt_matx;
procedure build_crr_dt_matx(p_point_cer_id       in number,
                            p_crset_id           in number,
                            p_effective_date     in date,
                            p_copy_entity_txn_id in number,
                            p_business_group_id  in number,
                            p_dt_matx            in out nocopy t_pt_matx) is
   cursor csr_dates is
      select information2 start_date
      from   ben_copy_entity_results
      where  copy_entity_txn_id = p_copy_entity_txn_id
      and    result_type_cd ='DISPLAY' -- which are displayed
      and    table_alias = 'CRRATE' -- check oipl row
      and    information169 = p_point_cer_id  -- check rate of point row
      and    information160 = p_crset_id
      order by 1 ;
   l_rate_st_dt date := pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
   l_abr_cer_id number;
   l_hrr_cer_id number;
   l_crr_cer_id number;
   l_num_pt_rates number;
   l_min_st_dt date;
   l_max_end_dt date;
begin
   select count(*),min(information2),max(information3)
   into l_num_pt_rates,l_min_st_dt,l_max_end_dt
   from   ben_copy_entity_results
   where  copy_entity_txn_id = p_copy_entity_txn_id
   and    result_type_cd ='DISPLAY' -- which are displayed
   and    table_alias = 'CRRATE' -- check crr row
   and    information160 = p_crset_id
   and    information278 = p_point_cer_id;
   if nvl(l_num_pt_rates,0) = 0 then
      hr_utility.set_location('creating abr for pt',5);
      pqh_gsp_hr_to_stage.create_abr_row
          (p_copy_entity_txn_id => p_copy_entity_txn_id,
           p_start_date         => l_rate_st_dt,
           p_opt_cer_id         => p_point_cer_id,
           p_business_group_id  => p_business_group_id,
           p_effective_date     => p_effective_date,
           p_abr_cer_id         => l_abr_cer_id,
           p_dml_oper           => '');
      if l_abr_cer_id is not null then
         hr_utility.set_location('creating hrr for pt',5);
         pqh_gsp_hr_to_stage.create_hrrate_row
             (p_copy_entity_txn_id => p_copy_entity_txn_id,
              p_effective_date     => p_effective_date,
              p_start_date         => l_rate_st_dt,
              p_business_group_id  => p_business_group_id,
              p_abr_cer_id         => l_abr_cer_id,
              p_point_cer_id       => p_point_cer_id,
              p_point_value        => 0,
              p_dml_oper           => '',
              p_hrrate_cer_id      => l_hrr_cer_id);
          if l_hrr_cer_id is not null then
              hr_utility.set_location('creating crr for pt',5);
              pqh_gsp_hr_to_stage.create_crrate_row
              (p_point_cer_id       => p_point_cer_id,
               p_copy_entity_txn_id => p_copy_entity_txn_id,
               p_business_group_id  => p_business_group_id,
               p_effective_date     => l_rate_st_dt,
               p_vpf_value          => 0,
               p_crset_id           => p_crset_id,
               p_crr_cer_id         => l_crr_cer_id);
             if l_crr_cer_id is null then
                hr_utility.set_location('issue in creating crr',10);
             end if;
          else
             hr_utility.set_location('issue in creating hrr',10);
          end if;
      else
         hr_utility.set_location('issue in creating abr',9);
      end if;
   else
      hr_utility.set_location('num of rates :'||l_num_pt_rates||'for point '||p_point_cer_id,10);
      hr_utility.set_location('min st date is '||to_char(l_min_st_dt,'dd-mm-RRRR'),10);
      hr_utility.set_location('max end date is '||to_char(l_max_end_dt,'dd-mm-RRRR'),10);
   end if;
   for rate in csr_dates loop
       hr_utility.set_location('date is '||to_char(rate.start_date,'dd-mm-RRRR'),10);
       update_date_ranges(p_start_date => rate.start_date,
                          p_dt_matx    => p_dt_matx);
   end loop;
end build_crr_dt_matx;
procedure build_gs_matx(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_context            in varchar2,
                        p_crset_id           in number default null,
                        p_grd_matx           out nocopy t_gs_matx,
                        p_dt_matx            out nocopy t_pt_matx) is
   cursor csr_grds is
      select copy_entity_result_id,information252,information253
      -- into p_plip_cer_id,p_grade_cer_id,p_grade_id
      from   ben_copy_entity_results
      where  copy_entity_txn_id = p_copy_entity_txn_id
      and    result_type_cd ='DISPLAY' -- which are displayed
      and    information104 = 'LINK' -- checked linked rows
      and    table_alias = 'CPP'   -- check plip row
      order by information263 ; -- for getting the order of grades correct
   cursor csr_grd_stps(p_plip_cer_id number) is
      select information262
      -- into p_point_cer_id
      from   ben_copy_entity_results
      where  copy_entity_txn_id = p_copy_entity_txn_id
      and    result_type_cd ='DISPLAY' -- which are displayed
      and    information104 = 'LINK' -- checked linked rows
      and    table_alias = 'COP' -- check oipl row
      and    gs_parent_entity_result_id = p_plip_cer_id  -- check child of plip row
      order by information263 ; -- step sequence

   grd_counter number := 0;
   l_grd_num_steps number;
   l_num_ranges number;
   stp_counter number := 1;
   range_counter number := 1;
   l_continue varchar2(30) := 'Y';
begin
   hr_utility.set_location('inside gs matrix build',1);

   for grd in csr_grds loop
      hr_utility.set_location('grd_cer_id is '||grd.copy_entity_result_id,2);
      select count(*)
      into   l_grd_num_steps
      from   ben_copy_entity_results
      where  copy_entity_txn_id = p_copy_entity_txn_id
      and    result_type_cd ='DISPLAY' -- which are displayed
      and    information104 = 'LINK' -- checked linked rows
      and    table_alias = 'COP' -- check oipl row
      and    gs_parent_entity_result_id = grd.copy_entity_result_id;  -- check child of plip row
      hr_utility.set_location('# of steps'||l_grd_num_steps,10);
      l_num_ranges := ceil(nvl(l_grd_num_steps,0)/5);
      hr_utility.set_location('# of ranges'||l_num_ranges,4);
      for step in csr_grd_stps(grd.copy_entity_result_id) loop
         hr_utility.set_location('pt used in step is'||step.information262,5);
         if stp_counter = 1 then
            grd_counter := grd_counter + 1;
            p_grd_matx(grd_counter).grade_cer_id := grd.information252 ;
            p_grd_matx(grd_counter).plip_cer_id := grd.copy_entity_result_id ;
            p_grd_matx(grd_counter).crset_id := p_crset_id;
            hr_utility.set_location('grd cer is'||grd.information252,4);
            p_grd_matx(grd_counter).num_steps := nvl(l_grd_num_steps,0);
            p_grd_matx(grd_counter).point1_cer_id := step.information262;
            p_grd_matx(grd_counter).range := range_counter;
            stp_counter := 2;
            range_counter := range_counter + 1;
         elsif stp_counter = 2 then
            stp_counter := 3;
            p_grd_matx(grd_counter).point2_cer_id := step.information262;
         elsif stp_counter = 3 then
            stp_counter := 4;
            p_grd_matx(grd_counter).point3_cer_id := step.information262;
         elsif stp_counter = 4 then
            stp_counter := 5;
            p_grd_matx(grd_counter).point4_cer_id := step.information262;
         elsif stp_counter = 5 then
            stp_counter := 1;
            p_grd_matx(grd_counter).point5_cer_id := step.information262;
         end if;
         if p_context ='HRR' then
            build_hrr_dt_matx(p_point_cer_id       => step.information262,
                              p_copy_entity_txn_id => p_copy_entity_txn_id,
                              p_effective_date     => p_effective_date,
                              p_business_group_id  => p_business_group_id,
                              p_dt_matx            => p_dt_matx);
         elsif p_context ='CRR' then
            build_crr_dt_matx(p_point_cer_id       => step.information262,
                              p_copy_entity_txn_id => p_copy_entity_txn_id,
                              p_effective_date     => p_effective_date,
                              p_business_group_id  => p_business_group_id,
                              p_crset_id           => p_crset_id,
                              p_dt_matx            => p_dt_matx);
         else
            hr_utility.set_location('invalid context '||p_context,98);
         end if;
         hr_utility.set_location('going for next oipl',98);
      end loop;
      range_counter := 1; -- resetting range counter for next grade
      stp_counter := 1 ;-- resetting step counter for next plip;
      hr_utility.set_location('going for next plip',99);
   end loop;
end build_gs_matx;
procedure build_gs_matrix(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_business_group_id  in number) is

   l_grd_matx t_gs_matx;
   l_dt_matx t_pt_matx;
   l_gs_rate_matx t_gs_rate_matx;
begin
   hr_utility.set_location('inside gs matrix build',1);
   PQH_GSP_PROCESS_LOG.START_LOG
   (P_TXN_ID    => p_copy_entity_txn_id,
   P_TXN_NAME  => 'CET_gs_matx : '||p_copy_entity_txn_id,
   P_MODULE_CD => 'PQH_GSP_BENSTG');
   pqh_gsp_hr_to_stage.g_master_txn_id := p_copy_entity_txn_id;
   pqh_gsp_hr_to_stage.g_txn_id        := p_copy_entity_txn_id;
   build_gs_matx(p_copy_entity_txn_id => p_copy_entity_txn_id,
                 p_effective_date     => p_effective_date,
                 p_business_group_id  => p_business_group_id,
                 p_context            => 'HRR',
                 p_grd_matx           => l_grd_matx,
                 p_dt_matx            => l_dt_matx);
   hr_utility.set_location('grd and dt matrix build',2);
   build_gs_rate_matrix(p_dt_matx      => l_dt_matx
                       ,p_gs_matx      => l_grd_matx
                       ,p_gs_rate_matx => l_gs_rate_matx
                       ,p_business_group_id => p_business_group_id
                       ,p_copy_entity_txn_id => p_copy_entity_txn_id);
   delete_gsrate(p_copy_entity_txn_id => p_copy_entity_txn_id);
   build_gsrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                p_gs_rate_matx       => l_gs_rate_matx,
                p_effective_date     => p_effective_date,
                p_business_group_id  => p_business_group_id);
   hr_utility.set_location('leaving gs matrix build',420);
   PQH_PROCESS_BATCH_LOG.END_LOG;
end build_gs_matrix;
procedure build_gr_matrix(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_crset_id           in number,
                          p_business_group_id  in number) is

   l_grd_matx t_gs_matx;
   l_dt_matx t_pt_matx;
   l_gr_rate_matx t_gs_rate_matx;
begin
   hr_utility.set_location('inside gr matrix build',1);
   PQH_GSP_PROCESS_LOG.START_LOG
   (P_TXN_ID    => p_copy_entity_txn_id,
   P_TXN_NAME  => 'CET_gr_matx : '||p_copy_entity_txn_id,
   P_MODULE_CD => 'PQH_GSP_BENSTG');
   pqh_gsp_hr_to_stage.g_master_txn_id := p_copy_entity_txn_id;
   pqh_gsp_hr_to_stage.g_txn_id        := p_copy_entity_txn_id;
   build_gs_matx(p_copy_entity_txn_id => p_copy_entity_txn_id,
                 p_effective_date     => p_effective_date,
                 p_business_group_id  => p_business_group_id,
                 p_context            => 'CRR',
                 p_crset_id           => p_crset_id,
                 p_grd_matx           => l_grd_matx,
                 p_dt_matx            => l_dt_matx);
   hr_utility.set_location('grd and dt matrix build',2);
   for j in 1..l_grd_matx.count loop
      hr_utility.set_location('grade cer id is'||l_grd_matx(j).grade_cer_id,15);
      hr_utility.set_location('crset id is'||l_grd_matx(j).crset_id,15);
      hr_utility.set_location('# steps is'||l_grd_matx(j).num_steps,20);
      hr_utility.set_location('range is'||l_grd_matx(j).range,20);
      hr_utility.set_location('point1_cer_id is '||l_grd_matx(j).point1_cer_id,25);
      hr_utility.set_location('point2_cer_id is '||l_grd_matx(j).point2_cer_id,25);
      hr_utility.set_location('point3_cer_id is '||l_grd_matx(j).point3_cer_id,25);
      hr_utility.set_location('point4_cer_id is '||l_grd_matx(j).point4_cer_id,25);
      hr_utility.set_location('point5_cer_id is '||l_grd_matx(j).point5_cer_id,25);
   end loop;
   build_gs_rate_matrix(p_dt_matx      => l_dt_matx
                       ,p_gs_matx      => l_grd_matx
                       ,p_gs_rate_matx => l_gr_rate_matx
                       ,p_business_group_id => p_business_group_id
                       ,p_copy_entity_txn_id => p_copy_entity_txn_id);

   hr_utility.set_location('grd rate matrix build',2);
   for k in 1..l_gr_rate_matx.count loop
      hr_utility.set_location('grade cer id is'||l_gr_rate_matx(k).grade_cer_id,15);
      hr_utility.set_location('crset id is'||l_gr_rate_matx(k).crset_id,15);
      hr_utility.set_location('# steps is'||l_gr_rate_matx(k).num_steps,20);
      hr_utility.set_location('range is'||l_gr_rate_matx(k).range,20);
      hr_utility.set_location('point1_cer_id is '||l_gr_rate_matx(k).point1_cer_id,25);
      hr_utility.set_location('point2_cer_id is '||l_gr_rate_matx(k).point2_cer_id,25);
      hr_utility.set_location('point3_cer_id is '||l_gr_rate_matx(k).point3_cer_id,25);
      hr_utility.set_location('point4_cer_id is '||l_gr_rate_matx(k).point4_cer_id,25);
      hr_utility.set_location('point5_cer_id is '||l_gr_rate_matx(k).point5_cer_id,25);
   end loop;
   delete_grrate(p_copy_entity_txn_id => p_copy_entity_txn_id);
   build_grrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                p_gr_rate_matx       => l_gr_rate_matx,
                p_effective_date     => p_effective_date,
                p_business_group_id  => p_business_group_id);
   hr_utility.set_location('leaving gr matrix build',420);
   PQH_PROCESS_BATCH_LOG.END_LOG;
end build_gr_matrix;
procedure correct_hrrate(p_copy_entity_txn_id in number,
                         p_point_cer_id       in number,
                         p_effective_date     in date,
                         p_new_value          in number) is
begin
   update ben_copy_entity_results
   set INFORMATION297 = p_new_value,
       dml_operation  = nvl(dml_operation,'UPDATE')
   where information278 = p_point_cer_id
   and table_alias ='HRRATE'
   and p_effective_date between information2 and information3
   and copy_entity_txn_id = p_copy_entity_txn_id;
exception
   when no_data_found then
      hr_utility.set_location('no hrrate row found',10);
      raise;
   when too_many_rows then
      hr_utility.set_location('2 or more hrrate row found',15);
      raise;
   when others then
      hr_utility.set_location('issues in correcting hrrate row',20);
      raise;
end correct_hrrate;
procedure update_hrrate(p_copy_entity_txn_id in number,
                        p_point_cer_id       in number,
                        p_datetrack_mode     in varchar2,
                        p_effective_date     in date,
                        p_new_value          in number) is
   l_old_hrr_cer_id number;
   l_new_hrr_cer_id number;
begin
   begin
      select copy_entity_result_id
      into l_old_hrr_cer_id
      from ben_copy_entity_results
      where information278 = p_point_cer_id
      and table_alias ='HRRATE'
      and p_effective_date between information2 and information3
      and copy_entity_txn_id = p_copy_entity_txn_id;
   exception
      when no_data_found then
         hr_utility.set_location('no hrrate row found',10);
         raise;
      when too_many_rows then
         hr_utility.set_location('2 or more hrrate rows found',15);
         raise;
      when others then
         hr_utility.set_location('issues in correcting hrrate row',20);
         raise;
   end;
   if l_old_hrr_cer_id is not null then
      update_hrrate(p_old_hrrate_cer_id => l_old_hrr_cer_id,
                    p_effective_date    => p_effective_date,
                    p_datetrack_mode    => p_datetrack_mode,
                    p_new_hrrate_cer_id => l_new_hrr_cer_id,
                    p_value             => p_new_value);
      hr_utility.set_location('hrrate cer replaced '||l_new_hrr_cer_id,40);
   else
      hr_utility.set_location('old hrrate not found ',50);
   end if;
end update_hrrate;
procedure update_hrrate(p_old_hrrate_cer_id in number,
                        p_effective_date    in date,
                        p_value             in number,
                        p_datetrack_mode    in varchar2,
                        p_grd_min_value     in number default null,
                        p_grd_mid_value     in number default null,
                        p_grd_max_value     in number default null,
                        p_new_hrrate_cer_id out nocopy number) is
   l_eot date := to_date('31/12/4712','dd/mm/RRRR');
   l_hrr_cer_ovn number;
   l_cet_id number;
   l_table_alias varchar2(30);
   l_table_name  varchar2(60);
   l_table_route_id number;
   l_pk number;
   l_esd date;
   l_eed date;
   l_bg number;
   l_grade_cer_id number;
   l_point_cer_id number;
   l_payrate_id number;
   l_abr_cer_id number;
   l_dml_oper varchar2(30);
   l_dt_mode varchar2(30);
   l_new_dml_oper varchar2(30);
   l_new_dt_mode varchar2(30);
   l_ins_row    varchar2(30);
   l_del_future varchar2(30);
   l_upd_curr   varchar2(30);
   l_upd_effdt  varchar2(30);
   l_hrr_eed    date;
   l_hrr_ovn    number;
begin
   hr_utility.set_location('inside update_hrrate '||p_old_hrrate_cer_id,10);
   select copy_entity_txn_id,table_alias,table_name,table_route_id,dml_operation,datetrack_mode,
          information1,information2,information3,information4,information277,information278,
          information293,information300,information298
   into   l_cet_id,l_table_alias,l_table_name,l_table_route_id,l_dml_oper,l_dt_mode,
          l_pk,l_esd,l_eed,l_bg,l_grade_cer_id,l_point_cer_id,
          l_payrate_id,l_abr_cer_id,l_hrr_ovn
   from ben_copy_entity_results
   where copy_entity_result_id = p_old_hrrate_cer_id;
   if nvl(l_dml_oper,'REUSE') = 'REUSE' then
      l_new_dml_oper := 'UPDATE';
   else
      l_new_dml_oper := l_dml_oper;
   end if;
   if l_dt_mode is null then
      l_new_dt_mode := 'CORRECTION';
   else
      l_new_dt_mode := l_dt_mode;
   end if;
   hr_utility.set_location('dt_mode is'||p_datetrack_mode,10);
   hr_utility.set_location('effdt is'||to_char(p_effective_date,'dd-mm-RRRR'),10);
   hr_utility.set_location('esd is'||to_char(l_esd,'dd-mm-RRRR'),10);
   if p_datetrack_mode ='CORRECTION' then
      l_ins_row    := 'N';
      l_del_future := 'N';
      l_upd_curr   := 'Y';
      l_upd_effdt  := 'N';
      l_hrr_eed    := l_eed;
   else
      if l_esd = p_effective_date then
         l_upd_curr  := 'Y';
         l_upd_effdt := 'N';
         l_ins_row   := 'N';
         l_hrr_eed   := l_eot;
         if l_eed <> l_eot then
            l_del_future := 'Y';
         else
            l_del_future := 'N';
         end if;
      else
         l_hrr_eed   := p_effective_date - 1;
         l_ins_row    := 'Y';
         l_del_future := 'Y';
         l_upd_curr   := 'N';
         l_upd_effdt  := 'Y';
      end if;
   end if;
   if l_upd_curr ='Y' then
      hr_utility.set_location('updating current row with values',10);
      begin
         update ben_copy_entity_results
         set information294 = p_grd_min_value,
             information295 = p_grd_max_value,
             information296 = p_grd_mid_value,
             information297 = p_value,
             dml_operation  = l_new_dml_oper,
             datetrack_mode = l_new_dt_mode,
             information3   = l_hrr_eed
         where copy_entity_result_id = p_old_hrrate_cer_id;
       --ggnanagu

         update ben_copy_entity_results
         set information287 = p_value
         where copy_entity_result_id = p_old_hrrate_cer_id
         and nvl(information287,0) =0 ;

       --ggnanagu

         hr_utility.set_location('old hrrate updated '||p_old_hrrate_cer_id,10);
         p_new_hrrate_cer_id := p_old_hrrate_cer_id;
      exception
         when others then
            hr_utility.set_location('some issue in updating hrrate row ',80);
            raise;
      end;
   end if;
   if l_del_future = 'Y' then
      hr_utility.set_location('deleting future rows ',10);
      begin
         delete from ben_copy_entity_results
         where  copy_entity_txn_id = l_cet_id
         and table_alias = 'HRRATE'
         and (information277 is null or information277 = l_grade_cer_id)
         and (information278 is null or information278 = l_point_cer_id)
         and information2 > p_effective_date;
      exception
         when others then
            hr_utility.set_location('some issue in deleting hrrate row ',100);
            raise;
      end;
   end if;
   if l_upd_effdt = 'Y' then
      hr_utility.set_location('updating effdt of curr row ',10);
      begin
         update ben_copy_entity_results
         set information3 = l_hrr_eed
         where copy_entity_result_id = p_old_hrrate_cer_id;
         hr_utility.set_location('old hrrate updated '||p_old_hrrate_cer_id,10);
      exception
         when others then
            hr_utility.set_location('some issue in updating hrrate row ',80);
            raise;
      end;
   end if;
   if l_ins_row = 'Y' then
      hr_utility.set_location('inserting new row ',10);
      begin
         -- These mappings have been taken from hrben_to_stage document
         -- call to create ben_cer is made here using api.
         ben_copy_entity_results_api.create_copy_entity_results
         (p_effective_date         => p_effective_date
         ,p_copy_entity_txn_id     => l_cet_id
         ,p_result_type_cd         => 'DISPLAY'
         ,p_table_name             => l_table_name
         ,p_table_alias            => l_table_alias
         ,p_table_route_id         => l_table_route_id
         ,p_dml_operation          => 'INSERT'
         ,p_datetrack_mode         => 'UPDATE_REPLACE'
         ,p_information1           => l_pk
         ,p_information2           => p_effective_date
         ,p_information3           => l_eot
         ,p_information4           => l_bg
         ,p_information277         => l_grade_cer_id
         ,p_information278         => l_point_cer_id
         ,p_information293         => l_payrate_id
         ,p_information294         => p_grd_min_value
         ,p_information288         => p_grd_min_value
         ,p_information295         => p_grd_max_value
         ,p_information289         => p_grd_max_value
         ,p_information296         => p_grd_mid_value
         ,p_information290         => p_grd_mid_value
         ,p_information297         => p_value
         ,p_information287         => p_value
         ,p_information298         => l_hrr_ovn
         ,p_information300         => l_abr_cer_id
         ,p_copy_entity_result_id  => p_new_hrrate_cer_id
         ,p_object_version_number  => l_hrr_cer_ovn);
         hr_utility.set_location('new hrrate created '||p_new_hrrate_cer_id,10);
      exception
         when others then
            hr_utility.set_location('some issue in creating hrrate row ',120);
            raise;
      end;
   end if;
end update_hrrate;
procedure update_hgrid_data(p_copy_entity_txn_id in number,
                            p_pl_cer_id          in number default null,
                            p_point_cer_id       in number default null,
                            p_value              in number) is
begin
   hr_utility.set_location('applying data to hgrid',10);
   if p_pl_cer_id is not null then
      begin
         update ben_copy_entity_results
         set information298 = p_value
         where table_alias ='CPP'
         and   information252 = p_pl_cer_id
         and copy_entity_txn_id = p_copy_entity_txn_id;
      exception
         when others then
            hr_utility.set_location('issues in updating plip ',20);
            raise;
      end;
   else
      begin
         update ben_copy_entity_results
         set information298 = p_value
         where table_alias ='COP'
         and   information262 = p_point_cer_id
         and copy_entity_txn_id = p_copy_entity_txn_id;
      exception
         when others then
            hr_utility.set_location('issues in updating oipl ',30);
            raise;
      end;
   end if;
   hr_utility.set_location('done applying data ',100);
end update_hgrid_data;
procedure update_grade_hrrate(p_copy_entity_txn_id in number,
                              p_rt_effective_date  in date,
                              p_gl_effective_date  in date,
                              p_business_group_id  in number,
                              p_hrrate_cer_id      in out nocopy number,
                              p_grade_cer_id       in number,
                              p_grd_value          in number,
                              p_grd_min_value      in number,
                              p_grd_mid_value      in number,
                              p_grd_max_value      in number,
                              p_datetrack_mode     in varchar2) is
   l_abr_cer_id number;
   l_start_date date ;
   l_dml_operation varchar2(30);
   l_datetrack_mode varchar2(30);
   l_old_hrrate_cer_id number;
   l_new_hrrate_cer_id number;
   l_esd date;
   l_eed date;
   l_eot date := to_date('31/12/4712','dd/mm/RRRR');
begin
-- if the hrrate cer is passed then abr exists else we may have to create it
-- find the hrrate row which lies on this effective date for this grade cer
   if p_hrrate_cer_id is null then
   -- hrrate doesnot exist, we have to create it, check abr for the Grade whether that exists or not
      hr_utility.set_location('hrrate doesnot exist ',10);
      if p_grade_cer_id is not null then
         hr_utility.set_location('grade cer is '||p_grade_cer_id,20);
         l_start_date := pqh_gsp_hr_to_stage.get_grd_start_date(p_grade_cer_id);
         l_abr_cer_id := pqh_gsp_hr_to_stage.get_abr_cer
                           (p_copy_entity_txn_id => p_copy_entity_txn_id,
                            p_pl_cer_id          => p_grade_cer_id,
                            p_effective_date     => p_rt_effective_date);
         hr_utility.set_location('abr cer is '||l_abr_cer_id,30);
         if l_abr_cer_id is null then
            hr_utility.set_location('going for abr row create ',40);
            pqh_gsp_hr_to_stage.create_abr_row
              (p_copy_entity_txn_id => p_copy_entity_txn_id,
               p_pl_cer_id          => p_grade_cer_id,
               p_business_group_id  => p_business_group_id,
               p_effective_date     => p_rt_effective_date,
               p_start_date         => l_start_date,
               p_abr_cer_id         => l_abr_cer_id,
               p_dml_oper           => 'INSERT');
            hr_utility.set_location('abr cer is '||l_abr_cer_id,50);
         end if;
         hr_utility.set_location('going for hrrate row create ',60);
         pqh_gsp_hr_to_stage.create_hrrate_row
           (p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_effective_date     => p_rt_effective_date,
            p_start_date         => l_start_date,
            p_business_group_id  => p_business_group_id,
            p_abr_cer_id         => l_abr_cer_id,
            p_grade_cer_id       => p_grade_cer_id,
            p_grd_value          => p_grd_value,
            p_grd_min_value      => p_grd_min_value,
            p_grd_mid_value      => p_grd_mid_value,
            p_grd_max_value      => p_grd_max_value,
            p_dml_oper           => 'INSERT',
            p_hrrate_cer_id      => p_hrrate_cer_id);
         hr_utility.set_location('hrrate cer is '||p_hrrate_cer_id,70);
         if p_gl_effective_date <= p_rt_effective_date then
            update_hgrid_data(p_copy_entity_txn_id => p_copy_entity_txn_id,
                              p_pl_cer_id          => p_grade_cer_id,
                              p_value              => p_grd_value);
         end if;
      else
         hr_utility.set_location('grade not in stage ',80);
      end if;
   else
      update_hrrate(p_old_hrrate_cer_id => p_hrrate_cer_id,
                    p_effective_date    => p_rt_effective_date,
                    p_new_hrrate_cer_id => l_new_hrrate_cer_id,
                    p_value             => p_grd_value,
                    p_datetrack_mode    => p_datetrack_mode,
                    p_grd_min_value     => p_grd_min_value,
                    p_grd_mid_value     => p_grd_mid_value,
                    p_grd_max_value     => p_grd_max_value);
      hr_utility.set_location('hrrate cer replaced '||l_new_hrrate_cer_id,200);
      if p_datetrack_mode ='CORRECTION' and p_gl_effective_date between l_esd and nvl(l_eed,l_eot) then
            update_hgrid_data(p_copy_entity_txn_id => p_copy_entity_txn_id,
                              p_pl_cer_id          => p_grade_cer_id,
                              p_value              => p_grd_value);
      elsif p_datetrack_mode = 'UPDATE_REPLACE' and p_gl_effective_date >= p_rt_effective_date then
            update_hgrid_data(p_copy_entity_txn_id => p_copy_entity_txn_id,
                              p_pl_cer_id          => p_grade_cer_id,
                              p_value              => p_grd_value);
      else
         hr_utility.set_location('wrong datetrack mode passed ',200);
      end if;
   end if;
end update_grade_hrrate;
procedure update_point_hrrate(p_copy_entity_txn_id in number,
                              p_rt_effective_date  in date,
                              p_gl_effective_date  in date,
                              p_business_group_id  in number,
                              p_hrrate_cer_id      in out nocopy number,
                              p_point_cer_id       in number,
                              p_point_value        in number,
                              p_datetrack_mode     in varchar2) is
   l_abr_cer_id number;
   l_start_date date := pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
   l_dml_operation varchar2(30);
   l_datetrack_mode varchar2(30);
   l_old_hrrate_cer_id number;
   l_new_hrrate_cer_id number;
   l_esd date;
   l_eed date;
   l_eot date := to_date('31/12/4712','dd/mm/RRRR');
begin
-- if the hrrate cer is passed then abr exists else we may have to create it
-- find the hrrate row which lies on this effective date for this grade cer
   if p_hrrate_cer_id is null then
   -- hrrate doesnot exist, we have to create it, check abr for the Grade whether that exists or not
      hr_utility.set_location('hrrate doesnot exist ',10);
      if p_point_cer_id is not null then
         hr_utility.set_location('grade cer is '||p_point_cer_id,20);
         l_abr_cer_id := pqh_gsp_hr_to_stage.get_abr_cer
                           (p_copy_entity_txn_id => p_copy_entity_txn_id,
                            p_opt_cer_id         => p_point_cer_id,
                            p_effective_date     => p_rt_effective_date);
         hr_utility.set_location('abr cer is '||l_abr_cer_id,30);
         if l_abr_cer_id is null then
            hr_utility.set_location('going for abr row create ',40);
            pqh_gsp_hr_to_stage.create_abr_row
              (p_copy_entity_txn_id => p_copy_entity_txn_id,
               p_start_date         => l_start_date,
               p_opt_cer_id         => p_point_cer_id,
               p_business_group_id  => p_business_group_id,
               p_effective_date     => p_rt_effective_date,
               p_abr_cer_id         => l_abr_cer_id,
               p_dml_oper           => 'INSERT');
            hr_utility.set_location('abr cer is '||l_abr_cer_id,50);
         end if;
         hr_utility.set_location('going for hrrate row create ',60);
         pqh_gsp_hr_to_stage.create_hrrate_row
           (p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_start_date         => l_start_date,
            p_effective_date     => p_rt_effective_date,
            p_business_group_id  => p_business_group_id,
            p_abr_cer_id         => l_abr_cer_id,
            p_point_cer_id       => p_point_cer_id,
            p_point_value        => p_point_value,
            p_dml_oper           => 'INSERT',
            p_hrrate_cer_id      => p_hrrate_cer_id);
         hr_utility.set_location('hrrate cer is '||p_hrrate_cer_id,70);
         if p_gl_effective_date <= p_rt_effective_date then
            update_hgrid_data(p_copy_entity_txn_id => p_copy_entity_txn_id,
                              p_point_cer_id       => p_point_cer_id,
                              p_value              => p_point_value);
         end if;
      else
         hr_utility.set_location('point not in stage ',80);
      end if;
   else
      update_hrrate(p_old_hrrate_cer_id => p_hrrate_cer_id,
                    p_effective_date    => p_rt_effective_date,
                    p_datetrack_mode    => p_datetrack_mode,
                    p_new_hrrate_cer_id => l_new_hrrate_cer_id,
                    p_value             => p_point_value);
      hr_utility.set_location('hrrate cer replaced '||l_new_hrrate_cer_id,200);
      if p_datetrack_mode ='CORRECTION' and p_gl_effective_date between l_esd and nvl(l_eed,l_eot) then
            update_hgrid_data(p_copy_entity_txn_id => p_copy_entity_txn_id,
                              p_point_cer_id       => p_point_cer_id,
                              p_value              => p_point_value);
      elsif p_datetrack_mode = 'UPDATE_REPLACE' and p_gl_effective_date >= p_rt_effective_date then
            update_hgrid_data(p_copy_entity_txn_id => p_copy_entity_txn_id,
                              p_point_cer_id       => p_point_cer_id,
                              p_value              => p_point_value);
      end if;
   end if;
end update_point_hrrate;
procedure create_grade_hrrate(p_copy_entity_txn_id in number,
                              p_effective_date     in date,
                              p_abr_id             in number,
                              p_abr_cer_id         in number,
                              p_pay_rule_id        in number,
                              p_grade_id           in number) is
   cursor csr_grd_rate is
      select EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, BUSINESS_GROUP_ID,
             RATE_ID, MAXIMUM, MID_VALUE, MINIMUM,VALUE, OBJECT_VERSION_NUMBER
      from pay_grade_rules_f
      where grade_rule_id = p_pay_rule_id
      and rate_type ='G'
      and GRADE_OR_SPINAL_POINT_ID = p_grade_id
      order by effective_start_date;
   l_hrr_tr_name varchar2(30);
   l_hrr_tr_id number;
   l_hrrate_exists boolean;
   l_hrrate_cer_id number;
   l_hrr_cer_ovn number;
   l_grd_cer_id number;
   l_continue boolean := TRUE;
begin
   l_hrrate_exists := pqh_gsp_hr_to_stage.is_hrrate_for_abr_exists
                        (p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_abr_id             => p_abr_id);
   if not l_hrrate_exists then
      hr_utility.set_location('hrrate doesnot exist for abr'||p_abr_id,10);
      -- get the table route id and table alias
      pqh_gsp_hr_to_stage.get_table_route_details
        (p_table_alias    => 'HRRATE',
         p_table_route_id => l_hrr_tr_id,
         p_table_name     => l_hrr_tr_name);
      hr_utility.set_location('hrrate tr name'||l_hrr_tr_name,20);
      l_grd_cer_id := pqh_gsp_hr_to_stage.is_grd_exists_in_txn
                        (p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_grd_id             => p_grade_id);
      if l_grd_cer_id is null then
         hr_utility.set_location('grade doesnot exist in stage'||p_grade_id,30);
         l_continue := FALSE;
      else
         hr_utility.set_location('grade in stage'||l_grd_cer_id,40);
      end if;
      if l_hrr_tr_name is null then
         hr_utility.set_location('hrrate tr name'||l_hrr_tr_name,45);
         l_continue := FALSE;
      end if;
      if p_copy_entity_txn_id is null then
         hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
         l_continue := FALSE;
      end if;
      if l_continue then
         for rec in csr_grd_rate loop
            begin
               -- These mappings have been taken from hrben_to_stage document
               -- call to create ben_cer is made here using api.
               ben_copy_entity_results_api.create_copy_entity_results
               (p_effective_date         => p_effective_date
               ,p_copy_entity_txn_id     => p_copy_entity_txn_id
               ,p_result_type_cd         => 'DISPLAY'
               ,p_table_name             => l_hrr_tr_name
               ,p_table_alias            => 'HRRATE'
               ,p_table_route_id         => l_hrr_tr_id
               ,p_dml_operation          => ''
               ,p_datetrack_mode         => ''
               ,p_information1           => p_pay_rule_id
               ,p_information2           => rec.effective_start_date
               ,p_information3           => rec.effective_end_date
               ,p_information4           => rec.business_group_id
               ,p_information255         => p_grade_id
               ,p_information277         => l_grd_cer_id
               ,p_information293         => rec.rate_id
               ,p_information294         => rec.minimum
               ,p_information288         => rec.minimum
               ,p_information295         => rec.maximum
               ,p_information289         => rec.maximum
               ,p_information296         => rec.mid_value
               ,p_information290         => rec.mid_value
               ,p_information297         => rec.value
               ,p_information287         => rec.value
               ,p_information298         => rec.object_version_number
               ,p_information299         => p_abr_id
               ,p_information300         => p_abr_cer_id
               ,p_copy_entity_result_id  => l_hrrate_cer_id
               ,p_object_version_number  => l_hrr_cer_ovn);
            exception
               when others then
                  hr_utility.set_location('some issue in creating hrrate row ',120);
            end;
         end loop;
      end if;
   else
      hr_utility.set_location('hrrate exists ',60);
   end if;
end create_grade_hrrate;
procedure create_point_hrrate(p_copy_entity_txn_id in number,
                              p_effective_date     in date,
                              p_abr_id             in number,
                              p_abr_cer_id         in number,
                              p_pay_rule_id        in number,
                              p_point_id           in number) is
   cursor csr_point_rate is
      select EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, BUSINESS_GROUP_ID,
             RATE_ID,VALUE, OBJECT_VERSION_NUMBER
      from pay_grade_rules_f
      where grade_rule_id = p_pay_rule_id
      and rate_type ='SP'
      and GRADE_OR_SPINAL_POINT_ID = p_point_id
      order by effective_start_date;
   l_hrr_tr_name varchar2(30);
   l_hrr_tr_id number;
   l_hrrate_exists boolean;
   l_hrrate_cer_id number;
   l_hrr_cer_ovn number;
   l_continue boolean := TRUE;
   l_point_cer_id number;
begin
   l_hrrate_exists := pqh_gsp_hr_to_stage.is_hrrate_for_abr_exists
                        (p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_abr_id             => p_abr_id);
   if not l_hrrate_exists then
      -- get the table route id and table alias
      pqh_gsp_hr_to_stage.get_table_route_details
        (p_table_alias    => 'HRRATE',
         p_table_route_id => l_hrr_tr_id,
         p_table_name     => l_hrr_tr_name);
      hr_utility.set_location('hrrate tr name'||l_hrr_tr_name,50);
      l_point_cer_id := pqh_gsp_hr_to_stage.is_point_exists_in_txn
                          (p_copy_entity_txn_id => p_copy_entity_txn_id,
                           p_point_id           => p_point_id);
      if l_point_cer_id is null then
         hr_utility.set_location('point doesnot exist in stage'||p_point_id,30);
         l_continue := FALSE;
      else
         hr_utility.set_location('point in stage'||l_point_cer_id,40);
      end if;
      if l_hrr_tr_name is null then
         hr_utility.set_location('hrrate tr name'||l_hrr_tr_name,45);
         l_continue := FALSE;
      end if;
      if p_copy_entity_txn_id is null then
         hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
         l_continue := FALSE;
      end if;
      if l_continue then
         for rec in csr_point_rate loop
            begin
               -- These mappings have been taken from hrben_to_stage document
               -- call to create ben_cer is made here using api.
               ben_copy_entity_results_api.create_copy_entity_results
               (p_effective_date         => p_effective_date
               ,p_copy_entity_txn_id     => p_copy_entity_txn_id
               ,p_result_type_cd         => 'DISPLAY'
               ,p_table_name             => l_hrr_tr_name
               ,p_table_alias            => 'HRRATE'
               ,p_dml_operation          => ''
               ,p_datetrack_mode         => ''
               ,p_table_route_id         => l_hrr_tr_id
               ,p_information1           => p_pay_rule_id
               ,p_information2           => rec.effective_start_date
               ,p_information3           => rec.effective_end_date
               ,p_information4           => rec.business_group_id
               ,p_information276         => p_point_id
               ,p_information278         => l_point_cer_id
               ,p_information293         => rec.rate_id
               ,p_information297         => rec.value
               ,p_information287         => rec.value
               ,p_information298         => rec.object_version_number
               ,p_information299         => p_abr_id
               ,p_information300         => p_abr_cer_id
               ,p_copy_entity_result_id  => l_hrrate_cer_id
               ,p_object_version_number  => l_hrr_cer_ovn);
            exception
               when others then
                  hr_utility.set_location('some issue in creating point hrrate row ',120);
            end;
         end loop;
      end if;
   else
      hr_utility.set_location('hrrate exists ',60);
   end if;
end create_point_hrrate;
procedure update_crrate(p_crset_id           in number,
                        p_effective_date     in date,
                        p_copy_entity_txn_id in number,
                        p_datetrack_mode     in varchar2,
                        p_grade_cer_id       in number default null,
                        p_point_cer_id       in number default null,
                        p_new_value          in number) is
cursor csr_crrate is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias = 'CRRATE'
   and   (information230 is null or information230 = p_grade_cer_id)
   and   (information169 is null or information169 = p_point_cer_id)
   and  information160 = p_crset_id
   and p_effective_date between information2 and information3;
l_continue boolean := TRUE;
l_dml_operation varchar2(30);
l_upd_curr   varchar2(30);
l_del_future varchar2(30);
l_crrate_eed date;
l_upd_effdt  varchar2(30);
l_ins_row    varchar2(30);
l_crr_cer_id number;
l_eot date := to_date('31-12-4712','dd-mm-RRRR');
begin
   if p_datetrack_mode not in ('CORRECTION','UPDATE_REPLACE') then
      hr_utility.set_location('invalid dt mode '||p_datetrack_mode,1);
      l_continue := false;
   end if;
   if p_grade_cer_id is null and p_point_cer_id is null then
      hr_utility.set_location('grd/pr cer should be passed',2);
      l_continue := false;
   end if;
   if l_continue then
      for crrate_rec in csr_crrate loop
         hr_utility.set_location('criteria rate row found'||crrate_rec.copy_entity_result_id,10);
         if nvl(crrate_rec.dml_operation,'REUSE') = 'REUSE' then
            l_dml_operation := 'UPDATE';
         else
            l_dml_operation := crrate_rec.dml_operation;
         end if;
         hr_utility.set_location('crrate dml_oper is'||l_dml_operation,3);
         if p_datetrack_mode = 'CORRECTION' then
            hr_utility.set_location('same row is to be updated',6);
            l_upd_curr   := 'Y';
            l_del_future := 'N';
            l_crrate_eed := crrate_rec.information3;
            l_upd_effdt  := 'N';
            l_ins_row    := 'N';
         else
            if crrate_rec.information2 = p_effective_date then
               -- row is getting updated on same date, so no insert only update
               hr_utility.set_location('row started today, so no ins',7);
               l_ins_row    := 'N';
               l_upd_curr   := 'Y';
               l_upd_effdt  := 'N';
               l_crrate_eed := l_eot;
               if crrate_rec.information3 <> l_eot then
               -- current row goes till end of time so no delete too
                  hr_utility.set_location('row ending early , del fut',8);
                  l_del_future := 'Y';
               else
                  hr_utility.set_location('row going till eot , so no del',9);
                  l_del_future := 'N';
               end if;
            else
               hr_utility.set_location('row started earlier, so upd_repl',10);
               l_del_future := 'Y';
               l_upd_curr   := 'N';
               l_ins_row    := 'Y';
               l_upd_effdt  := 'Y';
               l_crrate_eed := p_effective_date - 1;
            end if;
         end if;
         if l_del_future = 'Y' then
            hr_utility.set_location('fut rows being deleted',11);
            delete from ben_copy_entity_results
            where copy_entity_txn_id = p_copy_entity_txn_id
            and table_alias = 'CRRATE'
            and information160 = p_crset_id
            and (information230 is null or information230 = p_grade_cer_id)
            and (information169 is null or information169 = p_point_cer_id)
            and information2 > p_effective_date;
         end if;
         if l_upd_effdt ='Y' then
            hr_utility.set_location('effdt of curr_row being changed',12);
            update ben_copy_entity_results
            set INFORMATION3 = l_crrate_eed
            where copy_entity_result_id = crrate_rec.copy_entity_result_id;
         end if;
         if l_upd_curr ='Y' then
            hr_utility.set_location('curr_row data being changed',13);
            update ben_copy_entity_results
            set dml_operation = l_dml_operation,
                INFORMATION293 = p_new_value,
                information3   = l_crrate_eed
            where copy_entity_result_id = crrate_rec.copy_entity_result_id;
            --ggnanagu
            update ben_copy_entity_results
            set INFORMATION287 = p_new_value
            where copy_entity_result_id = crrate_rec.copy_entity_result_id
            and nvl(information287,0) =0 ;
            --ggnanagu


         end if;
         if l_ins_row ='Y' then
            hr_utility.set_location('eot is '||to_char(l_eot,'dd-mm-RRRR'),14);
            pqh_gsp_hr_to_stage.create_crrate_row
              (p_effective_date     => p_effective_date,
               p_copy_entity_txn_id => p_copy_entity_txn_id,
               p_grade_cer_id       => p_grade_cer_id,
               p_point_cer_id       => p_point_cer_id,
               p_business_group_id  => crrate_rec.information4,
               p_abr_cer_id         => crrate_rec.information161,
               p_vpf_esd            => p_effective_date,
               p_vpf_eed            => l_eot,
               p_vpf_ovn            => crrate_rec.information298,
               p_vpf_value          => p_new_value,
               p_datetrack_mode     => 'UPDATE_REPLACE',
               p_vpf_cer_id         => crrate_rec.information162,
               p_vpf_name           => crrate_rec.information170,
               p_vpf_id             => crrate_rec.information278,
               p_crset_id           => crrate_rec.information160,
               p_elp_id             => crrate_rec.information279,
               p_crr_cer_id         => l_crr_cer_id);
         end if;
         hr_utility.set_location('1 row should be processed ',15);
      end loop;
   end if;
end update_crrate;
procedure create_gsr_row(p_copy_entity_txn_id in number,
                         p_start_date         in date,
                         p_grade_cer_id       in number,
                         p_point1_cer_id      in number,
                         p_point2_cer_id      in number,
                         p_point3_cer_id      in number,
                         p_point4_cer_id      in number,
                         p_point5_cer_id      in number,
                         p_point1_value       in number,
                         p_point2_value       in number,
                         p_point3_value       in number,
                         p_point4_value       in number,
                         p_point5_value       in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_step_range         in number,
                         p_gsr_cer_id         out nocopy number) is
   l_eot date := to_date('31/12/4712','dd/mm/RRRR');
   l_gsr_tr_id number;
   l_gsr_tr_name varchar2(30);
   l_gsr_cer_ovn number;
   l_continue boolean := TRUE;
begin
   pqh_gsp_hr_to_stage.get_table_route_details
     (p_table_alias    => 'GSRATE',
      p_table_route_id => l_gsr_tr_id,
      p_table_name     => l_gsr_tr_name);
   hr_utility.set_location('gsr tr name'||l_gsr_tr_name,20);
   if l_gsr_tr_name is null then
      hr_utility.set_location('gsr tr name'||l_gsr_tr_name,45);
      l_continue := FALSE;
   end if;
   if p_copy_entity_txn_id is null then
      hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
      l_continue := FALSE;
   end if;
   if p_grade_cer_id is null then
      hr_utility.set_location('grade cer id is reqd',55);
      l_continue := FALSE;
   end if;
   if l_continue then
      begin
         -- These mappings have been taken from hrben_to_stage document
         -- call to create ben_cer is made here using api.
         ben_copy_entity_results_api.create_copy_entity_results
         (p_effective_date         => p_effective_date
         ,p_copy_entity_txn_id     => p_copy_entity_txn_id
         ,p_result_type_cd         => 'DISPLAY'
         ,p_table_name             => l_gsr_tr_name
         ,p_table_alias            => 'GSRATE'
         ,p_table_route_id         => l_gsr_tr_id
         ,p_dml_operation          => ''
         ,p_information2           => p_start_date
         ,p_information3           => l_eot
         ,p_information4           => p_business_group_id
         ,p_INFORMATION160         => p_grade_cer_id
         ,p_INFORMATION229         => p_point1_cer_id
         ,p_INFORMATION231         => p_point2_cer_id
         ,p_INFORMATION174         => p_point3_cer_id
         ,p_INFORMATION178         => p_point4_cer_id
         ,p_INFORMATION222         => p_point5_cer_id
         ,p_INFORMATION287         => p_point1_value
         ,p_INFORMATION288         => p_point2_value
         ,p_INFORMATION289         => p_point3_value
         ,p_INFORMATION290         => p_point4_value
         ,p_INFORMATION291         => p_point5_value
         ,p_INFORMATION297         => p_point1_value
         ,p_INFORMATION298         => p_point2_value
         ,p_INFORMATION299         => p_point3_value
         ,p_INFORMATION300         => p_point4_value
         ,p_INFORMATION301         => p_point5_value
         ,p_INFORMATION228         => p_step_range
         ,p_copy_entity_result_id  => p_gsr_cer_id
         ,p_object_version_number  => l_gsr_cer_ovn);
      exception
         when others then
            hr_utility.set_location('some issue in creating gsr row ',120);
      end;
   end if;
end create_gsr_row;
procedure create_grr_row(p_copy_entity_txn_id in number,
                         p_start_date         in date,
                         p_grade_cer_id       in number,
                         p_plip_cer_id       in number,
                         p_crset_id           in number,
                         p_point1_cer_id      in number,
                         p_point2_cer_id      in number,
                         p_point3_cer_id      in number,
                         p_point4_cer_id      in number,
                         p_point5_cer_id      in number,
                         p_point1_value       in number,
                         p_point2_value       in number,
                         p_point3_value       in number,
                         p_point4_value       in number,
                         p_point5_value       in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_step_range         in number,
                         p_grr_cer_id         out nocopy number) is
   l_eot date := to_date('31/12/4712','dd/mm/RRRR');
   l_grr_tr_id number;
   l_grr_tr_name varchar2(30);
   l_grr_cer_ovn number;
   l_continue boolean := TRUE;
begin
   pqh_gsp_hr_to_stage.get_table_route_details
     (p_table_alias    => 'GRRATE',
      p_table_route_id => l_grr_tr_id,
      p_table_name     => l_grr_tr_name);
   hr_utility.set_location('grr tr name'||l_grr_tr_name,20);
   if l_grr_tr_name is null then
      hr_utility.set_location('grr tr name'||l_grr_tr_name,45);
      l_continue := FALSE;
   end if;
   if p_copy_entity_txn_id is null then
      hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
      l_continue := FALSE;
   end if;
   if p_grade_cer_id is null then
      hr_utility.set_location('grade cer id is reqd',55);
      l_continue := FALSE;
   end if;
   if l_continue then
      begin
         -- These mappings have been taken from hrben_to_stage document
         -- call to create ben_cer is made here using api.
         ben_copy_entity_results_api.create_copy_entity_results
         (p_effective_date         => p_effective_date
         ,p_copy_entity_txn_id     => p_copy_entity_txn_id
         ,p_result_type_cd         => 'DISPLAY'
         ,p_table_name             => l_grr_tr_name
         ,p_table_alias            => 'GRRATE'
         ,p_table_route_id         => l_grr_tr_id
         ,p_dml_operation          => ''
         ,p_information2           => p_start_date
         ,p_information3           => l_eot
         ,p_information4           => p_business_group_id
         ,p_INFORMATION160         => p_grade_cer_id
         ,p_INFORMATION162         => p_plip_cer_id
         ,p_INFORMATION161         => p_crset_id
         ,p_INFORMATION229         => p_point1_cer_id
         ,p_INFORMATION231         => p_point2_cer_id
         ,p_INFORMATION174         => p_point3_cer_id
         ,p_INFORMATION178         => p_point4_cer_id
         ,p_INFORMATION222         => p_point5_cer_id
         ,p_INFORMATION287         => p_point1_value
         ,p_INFORMATION288         => p_point2_value
         ,p_INFORMATION289         => p_point3_value
         ,p_INFORMATION290         => p_point4_value
         ,p_INFORMATION291         => p_point5_value
         ,p_INFORMATION297         => p_point1_value
         ,p_INFORMATION298         => p_point2_value
         ,p_INFORMATION299         => p_point3_value
         ,p_INFORMATION300         => p_point4_value
         ,p_INFORMATION301         => p_point5_value
         ,p_INFORMATION228         => p_step_range
         ,p_copy_entity_result_id  => p_grr_cer_id
         ,p_object_version_number  => l_grr_cer_ovn);
      exception
         when others then
            hr_utility.set_location('some issue in creating grr row ',120);
      end;
   end if;
end create_grr_row;
procedure update_gsrate(p_copy_entity_txn_id in number,
                        p_gsr_cer_id         in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_value1             in number,
                        p_value2             in number,
                        p_value3             in number,
                        p_value4             in number,
                        p_value5             in number,
                        p_datetrack_mode     in varchar2) is
   l_grade_cer_id number;
   l_point1_cer_id number;
   l_point2_cer_id number;
   l_point3_cer_id number;
   l_point4_cer_id number;
   l_point5_cer_id number;
   l_point1_value number;
   l_point2_value number;
   l_point3_value number;
   l_point4_value number;
   l_point5_value number;
   l_step_range number;
   l_esd date;
   l_eed date;
   l_eot date := to_date('31-12-4712','dd-mm-RRRR');
   l_gsr_cer_id number;
   l_upd_curr   varchar2(30);
   l_del_future varchar2(30);
   l_crrate_eed date;
   l_upd_effdt  varchar2(30);
   l_ins_row    varchar2(30);
begin
   hr_utility.set_location('cet is '||p_copy_entity_txn_id,1);
   hr_utility.set_location('gsr cer is '||p_gsr_cer_id,2);
   hr_utility.set_location('dt mode is '||p_datetrack_mode,3);
   select information160, information229, information231, information174,
          information178, information222, information287, information288, information289,
          information290, information291, information228, information2, information3
   into l_grade_cer_id, l_point1_cer_id, l_point2_cer_id, l_point3_cer_id,
        l_point4_cer_id, l_point5_cer_id, l_point1_value, l_point2_value, l_point3_value,
        l_point4_value, l_point5_value, l_step_range, l_esd, l_eed
   from ben_copy_entity_results
   where copy_entity_result_id = p_gsr_cer_id
   and copy_entity_txn_id = p_copy_entity_txn_id;
   hr_utility.set_location('values pulled',4);
   if p_datetrack_mode ='CORRECTION' then
      l_upd_curr   := 'Y';
      l_del_future := 'N';
      l_crrate_eed := l_eed;
      l_upd_effdt  := 'N';
      l_ins_row    := 'N';
   else
      if l_esd = p_effective_date then
         l_ins_row    := 'N';
         l_upd_effdt  := 'N';
         l_upd_curr   := 'Y';
         l_crrate_eed := l_eot;
         if l_eed = l_eot then
            l_del_future := 'N';
         else
            l_del_future := 'Y';
         end if;
      else
         l_upd_curr   := 'N';
         l_del_future := 'Y';
         l_crrate_eed := l_eed - 1;
         l_upd_effdt  := 'Y';
         l_ins_row    := 'Y';
      end if;
   end if;
   if l_upd_curr ='Y' then
      -- correct the gsrate row
      update ben_copy_entity_results
      set information287 = p_value1,
          information288 = p_value2,
          information289 = p_value3,
          information290 = p_value4,
          information291 = p_value5,
          information3   = l_crrate_eed
      where copy_entity_result_id = p_gsr_cer_id
      and copy_entity_txn_id = p_copy_entity_txn_id;
      hr_utility.set_location('gsrate row corr',5);
   end if;
   if l_upd_effdt = 'Y' then
      update ben_copy_entity_results
      set INFORMATION3 = p_effective_date -1
      where copy_entity_result_id = p_gsr_cer_id
      and copy_entity_txn_id = p_copy_entity_txn_id;
      hr_utility.set_location('curr row end dt',12);
   end if;
   if l_del_future = 'Y' then
      -- remove the future rows
      delete from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'GSRATE'
      and information160 = l_grade_cer_id
      and information2 > p_effective_date;
      hr_utility.set_location('fut row removed',13);
   end if;
   if l_ins_row = 'Y' then
      -- insert the new row
      create_gsr_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                     p_start_date         => p_effective_date,
                     p_grade_cer_id       => l_grade_cer_id,
                     p_point1_cer_id      => l_point1_cer_id,
                     p_point2_cer_id      => l_point2_cer_id,
                     p_point3_cer_id      => l_point3_cer_id,
                     p_point4_cer_id      => l_point4_cer_id,
                     p_point5_cer_id      => l_point5_cer_id,
                     p_point1_value       => p_value1,
                     p_point2_value       => p_value2,
                     p_point3_value       => p_value3,
                     p_point4_value       => p_value4,
                     p_point5_value       => p_value5,
                     p_business_group_id  => p_business_group_id,
                     p_effective_date     => p_effective_date,
                     p_step_range         => l_step_range,
                     p_gsr_cer_id         => l_gsr_cer_id);
      hr_utility.set_location('new row inserted',14);
   end if;
   -- update the hrrate rows
   update_hrrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                 p_point_cer_id       => l_point1_cer_id,
                 p_datetrack_mode     => p_datetrack_mode,
                 p_effective_date     => p_effective_date,
                 p_new_value          => p_value1);
   hr_utility.set_location('hrrate row upd_r'||l_point1_cer_id,15);
   if l_point2_cer_id is not null then
      update_hrrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                    p_point_cer_id       => l_point2_cer_id,
                    p_datetrack_mode     => p_datetrack_mode,
                    p_effective_date     => p_effective_date,
                    p_new_value          => p_value2);
      hr_utility.set_location('hrrate row upd_r'||l_point2_cer_id,16);
   end if;
   if l_point3_cer_id is not null then
      update_hrrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                    p_point_cer_id       => l_point3_cer_id,
                    p_datetrack_mode     => p_datetrack_mode,
                    p_effective_date     => p_effective_date,
                    p_new_value          => p_value3);
      hr_utility.set_location('hrrate row upd_r'||l_point3_cer_id,17);
   end if;
   if l_point4_cer_id is not null then
      update_hrrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                    p_point_cer_id       => l_point4_cer_id,
                    p_datetrack_mode     => p_datetrack_mode,
                    p_effective_date     => p_effective_date,
                    p_new_value          => p_value4);
      hr_utility.set_location('hrrate row upd_r'||l_point4_cer_id,18);
   end if;
   if l_point5_cer_id is not null then
      update_hrrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                    p_point_cer_id       => l_point5_cer_id,
                    p_datetrack_mode     => p_datetrack_mode,
                    p_effective_date     => p_effective_date,
                    p_new_value          => p_value5);
      hr_utility.set_location('hrrate row upd_r'||l_point5_cer_id,19);
   end if;
end update_gsrate;
procedure update_grrate(p_copy_entity_txn_id in number,
                        p_grr_cer_id         in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_value1             in number,
                        p_value2             in number,
                        p_value3             in number,
                        p_value4             in number,
                        p_value5             in number,
                        p_datetrack_mode     in varchar2) is
   l_grade_cer_id number;
   l_plip_cer_id number;
   l_crset_id number;
   l_point1_cer_id number;
   l_point2_cer_id number;
   l_point3_cer_id number;
   l_point4_cer_id number;
   l_point5_cer_id number;
   l_point1_value number;
   l_point2_value number;
   l_point3_value number;
   l_point4_value number;
   l_point5_value number;
   l_step_range number;
   l_esd date;
   l_eed date;
   l_eot date := to_date('31-12-4712','dd-mm-RRRR');
   l_grr_cer_id number;
   l_upd_curr   varchar2(30);
   l_del_future varchar2(30);
   l_crrate_eed date;
   l_upd_effdt  varchar2(30);
   l_ins_row    varchar2(30);
begin
   hr_utility.set_location('cet is '||p_copy_entity_txn_id,1);
   hr_utility.set_location('grr cer is '||p_grr_cer_id,2);
   hr_utility.set_location('dt mode is '||p_datetrack_mode,3);
   select information160, information161,information162,information229, information231, information174,
          information178, information222, information287, information288, information289,
          information290, information291, information228, information2, information3
   into l_grade_cer_id, l_crset_id, l_plip_cer_id,l_point1_cer_id, l_point2_cer_id, l_point3_cer_id,
        l_point4_cer_id, l_point5_cer_id, l_point1_value, l_point2_value, l_point3_value,
        l_point4_value, l_point5_value, l_step_range, l_esd, l_eed
   from ben_copy_entity_results
   where copy_entity_result_id = p_grr_cer_id
   and copy_entity_txn_id = p_copy_entity_txn_id;
   hr_utility.set_location('values pulled',4);
   if p_datetrack_mode ='CORRECTION' then
      l_upd_curr   := 'Y';
      l_del_future := 'N';
      l_crrate_eed := l_eed;
      l_upd_effdt  := 'N';
      l_ins_row    := 'N';
   else
      if l_esd = p_effective_date then
         l_ins_row    := 'N';
         l_upd_effdt  := 'N';
         l_upd_curr   := 'Y';
         l_crrate_eed := l_eot;
         if l_eed = l_eot then
            l_del_future := 'N';
         else
            l_del_future := 'Y';
         end if;
      else
         l_upd_curr   := 'N';
         l_del_future := 'Y';
         l_crrate_eed := l_eed - 1;
         l_upd_effdt  := 'Y';
         l_ins_row    := 'Y';
      end if;
   end if;
   if l_upd_curr ='Y' then
      -- correct the grrate row
      update ben_copy_entity_results
      set information287 = p_value1,
          information288 = p_value2,
          information289 = p_value3,
          information290 = p_value4,
          information291 = p_value5,
          information3   = l_crrate_eed
      where copy_entity_result_id = p_grr_cer_id
      and copy_entity_txn_id = p_copy_entity_txn_id;
      hr_utility.set_location('grrate row corr',5);
   end if;
   if l_upd_effdt = 'Y' then
      update ben_copy_entity_results
      set INFORMATION3 = p_effective_date -1
      where copy_entity_result_id = p_grr_cer_id
      and copy_entity_txn_id = p_copy_entity_txn_id;
      hr_utility.set_location('curr row end dt',12);
   end if;
   if l_del_future = 'Y' then
      -- remove the future rows
      delete from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'GRRATE'
      and information160 = l_grade_cer_id
      and information2 > p_effective_date;
      hr_utility.set_location('fut row removed',13);
   end if;
   if l_ins_row = 'Y' then
      hr_utility.set_location('new row inserted',14);
      create_grr_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                     p_start_date         => p_effective_date,
                     p_grade_cer_id       => l_grade_cer_id,
                     p_plip_cer_id        => l_plip_cer_id,
                     p_crset_id           => l_crset_id,
                     p_point1_cer_id      => l_point1_cer_id,
                     p_point2_cer_id      => l_point2_cer_id,
                     p_point3_cer_id      => l_point3_cer_id,
                     p_point4_cer_id      => l_point4_cer_id,
                     p_point5_cer_id      => l_point5_cer_id,
                     p_point1_value       => p_value1,
                     p_point2_value       => p_value2,
                     p_point3_value       => p_value3,
                     p_point4_value       => p_value4,
                     p_point5_value       => p_value5,
                     p_business_group_id  => p_business_group_id,
                     p_effective_date     => p_effective_date,
                     p_step_range         => l_step_range,
                     p_grr_cer_id         => l_grr_cer_id);
   end if;
   -- update the crrate rows
   update_crrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                 p_point_cer_id       => l_point1_cer_id,
                 p_crset_id           => l_crset_id,
                 p_datetrack_mode     => p_datetrack_mode,
                 p_effective_date     => p_effective_date,
                 p_new_value          => p_value1);
   hr_utility.set_location('crrate row upd_r'||l_point1_cer_id,15);
   if l_point2_cer_id is not null then
      update_crrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                    p_point_cer_id       => l_point2_cer_id,
                    p_crset_id           => l_crset_id,
                    p_datetrack_mode     => p_datetrack_mode,
                    p_effective_date     => p_effective_date,
                    p_new_value          => p_value2);
      hr_utility.set_location('crrate row upd_r'||l_point2_cer_id,16);
   end if;
   if l_point3_cer_id is not null then
      update_crrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                    p_point_cer_id       => l_point3_cer_id,
                    p_crset_id           => l_crset_id,
                    p_datetrack_mode     => p_datetrack_mode,
                    p_effective_date     => p_effective_date,
                    p_new_value          => p_value3);
      hr_utility.set_location('crrate row upd_r'||l_point3_cer_id,17);
   end if;
   if l_point4_cer_id is not null then
      update_crrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                    p_point_cer_id       => l_point4_cer_id,
                    p_crset_id           => l_crset_id,
                    p_datetrack_mode     => p_datetrack_mode,
                    p_effective_date     => p_effective_date,
                    p_new_value          => p_value4);
      hr_utility.set_location('crrate row upd_r'||l_point4_cer_id,18);
   end if;
   if l_point5_cer_id is not null then
      update_crrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                    p_point_cer_id       => l_point5_cer_id,
                    p_crset_id           => l_crset_id,
                    p_datetrack_mode     => p_datetrack_mode,
                    p_effective_date     => p_effective_date,
                    p_new_value          => p_value5);
      hr_utility.set_location('crrate row upd_r'||l_point5_cer_id,19);
   end if;
end update_grrate;
procedure sync_crrate(p_crset_id           in number,
                      p_point_cer_id       in number,
                      p_copy_entity_txn_id in number,
                      p_value              in number) is
cursor csr_crr is
   select * from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and information160 is null
   and table_alias = 'CRRATE'
   and information169 = p_point_cer_id;
l_dml_operation varchar2(30);
begin
   for crr_rec in csr_crr loop
       if crr_rec.information278 is null then
          if nvl(crr_rec.dml_operation,'REUSE') = 'REUSE' then
             l_dml_operation := 'INSERT';
          else
             l_dml_operation := crr_rec.dml_operation;
          end if;
       else
          if nvl(crr_rec.dml_operation,'REUSE') = 'REUSE' then
             l_dml_operation := 'UPDATE';
          else
             l_dml_operation := crr_rec.dml_operation;
          end if;
       end if;
       update ben_copy_entity_results
       set information293 = p_value,
           information160 = p_crset_id,
           dml_operation  = l_dml_operation
       where copy_entity_txn_id = p_copy_entity_txn_id
       and copy_entity_result_id = crr_rec.copy_entity_result_id
       and information160 is null
       and table_alias = 'CRRATE'
       and information169 = p_point_cer_id;
--ggnanagu
            update ben_copy_entity_results
            set INFORMATION287 = p_value
            where copy_entity_result_id = crr_rec.copy_entity_result_id
            and nvl(information287,0) =0 ;
--ggnanagu

   end loop;
end sync_crrate;
procedure sync_grrate(p_crset_id           in number,
                      p_copy_entity_txn_id in number) is
   cursor csr_grr is
      select * from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and information161 is null
      and table_alias = 'GRRATE';
begin
-- this routine will be called from create grrate page
-- we have to take values from grrate rows and update crrate rows so that
-- next time matrix build can take care of it
   for grr_rec in csr_grr loop
       if grr_rec.information229 is not null then
          sync_crrate(p_crset_id           => p_crset_id,
                      p_point_cer_id       => grr_rec.information229,
                      p_copy_entity_txn_id => p_copy_entity_txn_id,
                      p_value              => grr_rec.information287);
       end if;
       if grr_rec.information231 is not null then
          sync_crrate(p_crset_id           => p_crset_id,
                      p_point_cer_id       => grr_rec.information231,
                      p_copy_entity_txn_id => p_copy_entity_txn_id,
                      p_value              => grr_rec.information288);
       end if;
       if grr_rec.information174 is not null then
          sync_crrate(p_crset_id           => p_crset_id,
                      p_point_cer_id       => grr_rec.information174,
                      p_copy_entity_txn_id => p_copy_entity_txn_id,
                      p_value              => grr_rec.information289);
       end if;
       if grr_rec.information178 is not null then
          sync_crrate(p_crset_id           => p_crset_id,
                      p_point_cer_id       => grr_rec.information178,
                      p_copy_entity_txn_id => p_copy_entity_txn_id,
                      p_value              => grr_rec.information290);
       end if;
       if grr_rec.information222 is not null then
          sync_crrate(p_crset_id           => p_crset_id,
                      p_point_cer_id       => grr_rec.information222,
                      p_copy_entity_txn_id => p_copy_entity_txn_id,
                      p_value              => grr_rec.information291);
       end if;
   end loop;
end sync_grrate;

procedure populate_old_values(p_copy_entity_txn_id in number)
is
l_status varchar2(2);

Cursor csr_grades
Is
select copy_entity_result_id
from ben_copy_entity_results
where table_alias = 'PLN'
and copy_entity_txn_id =  p_copy_entity_txn_id;


Cursor csr_grade_std_rates(p_grade_cer_id in number)
IS
select copy_entity_result_id,information1,information2,information3,information294,information295,information296,information297,dml_operation
from ben_copy_entity_results
where table_alias = 'HRRATE'
and information277= p_grade_cer_id
and copy_entity_txn_id = p_copy_entity_txn_id;

Cursor csr_grade_cri_rates(p_grade_cer_id in number)
IS
select copy_entity_result_id,information1,information2,information3,information293,dml_operation
from ben_copy_entity_results
where table_alias = 'CRRATE'
and information230= p_grade_cer_id
and copy_entity_txn_id = p_copy_entity_txn_id;

Cursor csr_grd_db_values(p_grade_rule_id in number,p_effective_start_date in date)
Is
select value,minimum,maximum,mid_value
from pay_grade_rules_f
where grade_rule_id = p_grade_rule_id
and effective_start_date = p_effective_start_date;

Cursor csr_Points
Is
select copy_entity_result_id
from ben_copy_entity_results
where table_alias = 'OPT'
and copy_entity_txn_id =  p_copy_entity_txn_id;


Cursor csr_point_std_rates(p_point_cer_id in number)
IS
select copy_entity_result_id,information1,information2,information3,information297,dml_operation
from ben_copy_entity_results
where table_alias = 'HRRATE'
and information278= p_point_cer_id
and copy_entity_txn_id = p_copy_entity_txn_id;

Cursor csr_point_cri_rates(p_point_cer_id in number)
IS
select copy_entity_result_id,information1,information2,information3,information293,dml_operation
from ben_copy_entity_results
where table_alias = 'CRRATE'
and information169= p_point_cer_id
and copy_entity_txn_id = p_copy_entity_txn_id;

Cursor csr_pnt_db_values(p_grade_rule_id in number,p_effective_start_date in date)
Is
select value
from pay_grade_rules_f
where grade_rule_id = p_grade_rule_id
and effective_start_date = p_effective_start_date;

Cursor csr_gsp_task_list is
select copy_entity_result_id
  from ben_copy_entity_results
 where information109 is null --nvl(information109,0) = 0
   and table_alias = 'PQH_GSP_TASK_LIST'
   and copy_entity_txn_id =  p_copy_entity_txn_id
   and rownum < 2 ;

l_value number;
l_grd_min_value number;
l_grd_max_value number;
l_grd_mid_value number;

begin

for rec_gsp_task_list in csr_gsp_task_list
loop
   update ben_copy_entity_results
      set information109 = 'Y'
    where copy_entity_result_id = rec_gsp_task_list.copy_entity_result_id;

for grades_rec in csr_grades loop

  for grade_std_rates_rec in csr_grade_std_rates(grades_rec.copy_entity_result_id) loop
   if grade_std_rates_rec.dml_operation = 'INSERT' then
     update ben_copy_entity_results
     set  information287 = information297
         ,information288 = information294
         ,information289 = information295
         ,information290 = information296
     where copy_entity_result_id = grade_std_rates_rec.copy_entity_result_id;
   else
     Open csr_grd_db_values(grade_std_rates_rec.information1,grade_std_rates_rec.information2);
     fetch csr_grd_db_values into l_value,l_grd_min_value,l_grd_max_value,l_grd_mid_value;
     close csr_grd_db_values;
     update ben_copy_entity_results
     set  information287 = l_value
         ,information288 = l_grd_min_value
         ,information289 = l_grd_max_value
         ,information290 = l_grd_mid_value
     where copy_entity_result_id = grade_std_rates_rec.copy_entity_result_id;
   end if;
  end loop; -- csr_grade_std_rates

  for grade_cri_rates_rec in csr_grade_cri_rates(grades_rec.copy_entity_result_id) loop
     update ben_copy_entity_results
     set  information287 = information293
     where copy_entity_result_id = grade_cri_rates_rec.copy_entity_result_id;
  end loop; -- csr_grade_cri_rates

end loop; --csr_grades

for pnt in csr_points loop

  for pnt_rate in csr_point_std_rates(pnt.copy_entity_result_id) loop
   if pnt_rate.dml_operation = 'INSERT' then
     update ben_copy_entity_results
     set  information287 = information297
     where copy_entity_result_id = pnt_rate.copy_entity_result_id;
   else
     Open csr_pnt_db_values(pnt_rate.information1,pnt_rate.information2);
     fetch csr_pnt_db_values into l_value;
     close csr_pnt_db_values;
     update ben_copy_entity_results
     set  information287 = l_value
     where copy_entity_result_id = pnt_rate.copy_entity_result_id;
   end if;
  end loop; -- csr_point_std_rates

  for pnt_cri_rate in csr_point_cri_rates(pnt.copy_entity_result_id) loop
     update ben_copy_entity_results
     set  information287 = information293
     where copy_entity_result_id = pnt_cri_rate.copy_entity_result_id;
  end loop; -- csr_point_cri_rates

end loop; --csr_points
end loop ; -- csr_gsp_task_list

end populate_old_values;


end pqh_gsp_rates;

/
