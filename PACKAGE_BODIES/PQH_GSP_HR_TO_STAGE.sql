--------------------------------------------------------
--  DDL for Package Body PQH_GSP_HR_TO_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_HR_TO_STAGE" as
/* $Header: pqgsphrs.pkb 120.11.12010000.1 2008/07/28 12:57:41 appldev ship $ */
function get_display_vpf_cer(p_vpf_id             in number,
                             p_copy_entity_txn_id in number) return number is
   l_vpf_cer_id number;
begin
   select copy_entity_result_id
   into l_vpf_cer_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and result_type_cd ='DISPLAY'
   and table_alias = 'VPF'
   and information1 = p_vpf_id;
   return l_vpf_cer_id;
exception
   when others then
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_display_vpf_cer',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => sqlerrm,
       p_effective_date  => trunc(sysdate));
      raise;
end;
procedure update_crset_type(p_copy_entity_txn_id in number,
                            p_crset_id           in number,
                            p_crset_type         in varchar2) is
begin
   update ben_copy_entity_results
   set information100 = p_crset_type
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='CRSET'
   and information161 = p_crset_id;
exception
   when others then
      hr_utility.set_location('crset type upd issue ',11);
      raise;
end;
function is_crrate_there(p_oipl_cer_id        in number default null,
                         p_plip_cer_id        in number default null,
                         p_pl_cer_id          in number default null,
                         p_point_cer_id       in number default null,
                         p_copy_entity_txn_id in number,
                         p_effective_date     in date) return varchar2 is
   l_count number;
   l_grade_cer_id number;
   l_point_cer_id number;
begin
   if p_oipl_cer_id is null and p_plip_cer_id is null
      and p_pl_cer_id is null and p_point_cer_id is null then
      return 'N';
   elsif p_oipl_cer_id is not null and p_point_cer_id is null then
      select information262
      into l_point_cer_id
      from ben_copy_entity_results
      where copy_entity_result_id = p_oipl_cer_id;
   elsif p_plip_cer_id is not null and p_pl_cer_id is null then
      select information252
      into l_grade_cer_id
      from ben_copy_entity_results
      where copy_entity_result_id = p_plip_cer_id;
   elsif p_point_cer_id is not null then
      l_point_cer_id := p_point_cer_id;
   elsif p_pl_cer_id is not null then
      l_grade_cer_id := p_pl_cer_id;
   end if;
   if l_point_cer_id is not null then
      select count(*)
      into l_count
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='CRRATE'
      and p_effective_date between information2 and information3
      and information169 = l_point_cer_id
      and information160 is not null;
   end if;
   if l_grade_cer_id is not null then
      select count(*)
      into l_count
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='CRRATE'
      and p_effective_date between information2 and information3
      and information230 = l_grade_cer_id
      and information160 is not null;
   end if;
   if nvl(l_count,0) >0 then
      return 'Y';
   else
      return 'N';
   end if;
end is_crrate_there;
function get_elp_for_vpf(p_vpf_cer_id         in number,
                         p_copy_entity_txn_id in number,
                         p_effective_date     in date) return number is
   l_elp_id number;
   l_message_text varchar2(240);
begin
   hr_utility.set_location('vpf_cer_id is '||p_vpf_cer_id,1);
   select information1
   into l_elp_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='ELP'
   and parent_entity_result_id = p_vpf_cer_id
   and p_effective_date between information2 and information3;
   hr_utility.set_location('elp id is '||l_elp_id,1);
   return l_elp_id;
exception
   when no_data_found then
      l_message_text := 'no_data_found for vpf_cer is :'||p_vpf_cer_id
                     ||' cet id is '||p_copy_entity_txn_id
                     ||' effdt is '||to_char(p_effective_date,'DD-MM-RRRR');
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_elp_for_vpf_no_data',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => l_message_text,
       p_effective_date  => p_effective_date);
      raise;
   when others then
      hr_utility.set_location('elp pull had issues',10);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_elp_for_vpf_other',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm)||l_message_text,
       p_effective_date  => p_effective_date);
      raise;
end get_elp_for_vpf;
procedure validate_crset(p_name               in varchar2,
                         p_bu_cd              in varchar2 default null,
                         p_bu_name            in varchar2 default null,
                         p_fp_cd              in varchar2 default null,
                         p_fp_name            in varchar2 default null,
                         p_job_id             in number default null,
                         p_job_name           in varchar2 default null,
                         p_org_id             in number default null,
                         p_org_name           in varchar2 default null,
                         p_pt_id              in number default null,
                         p_pt_name            in varchar2 default null,
                         p_loc_id             in number default null,
                         p_loc_name           in varchar2 default null,
                         p_perf_rtng_cd       in varchar2 default null,
                         p_event_type         in varchar2 default null,
                         p_perf_rtng_name     in varchar2 default null,
                         p_event_name         in varchar2 default null,
                         p_sa_id              in number default null,
                         p_sa_name            in varchar2 default null,
                         p_ff_id              in number default null,
                         p_ff_name            in varchar2 default null,
                         p_valid              out nocopy boolean) is
   l_continue boolean := true;
begin
   if p_name is null then
      l_continue := false;
   end if;
   if p_event_name is not null and p_event_type is null then
      l_continue := false;
   end if;
   if p_event_name is null and p_event_type is not null then
      l_continue := false;
   end if;
   if p_perf_rtng_cd is not null and p_perf_rtng_name is null then
      l_continue := false;
   end if;
   if p_perf_rtng_cd is null and p_perf_rtng_name is not null then
      l_continue := false;
   end if;
   if p_perf_rtng_cd is null and p_event_type is not null then
      l_continue := false;
   end if;
   if p_perf_rtng_cd is not null and p_event_type is null then
      l_continue := false;
   end if;
   if p_bu_cd is null and p_bu_name is not null then
      l_continue := false;
   end if;
   if p_bu_cd is not null and p_bu_name is null then
      l_continue := false;
   end if;
   if p_fp_cd is null and p_fp_name is not null then
      l_continue := false;
   end if;
   if p_fp_cd is not null and p_fp_name is null then
      l_continue := false;
   end if;
   if p_sa_id is null and p_sa_name is not null then
      l_continue := false;
   end if;
   if p_sa_id is not null and p_sa_name is null then
      l_continue := false;
   end if;
   if p_pt_id is null and p_pt_name is not null then
      l_continue := false;
   end if;
   if p_pt_id is not null and p_pt_name is null then
      l_continue := false;
   end if;
   if p_ff_id is null and p_ff_name is not null then
      l_continue := false;
   end if;
   if p_ff_id is not null and p_ff_name is null then
      l_continue := false;
   end if;
   if p_loc_id is null and p_loc_name is not null then
      l_continue := false;
   end if;
   if p_loc_id is not null and p_loc_name is null then
      l_continue := false;
   end if;
   if p_job_id is null and p_job_name is not null then
      l_continue := false;
   end if;
   if p_job_id is not null and p_job_name is null then
      l_continue := false;
   end if;
   if p_org_id is null and p_org_name is not null then
      l_continue := false;
   end if;
   if p_org_id is not null and p_org_name is null then
      l_continue := false;
   end if;
   p_valid := l_continue;
end validate_crset;
procedure get_abr_detl(p_abr_cer_id in number,
                       p_abr_type   out nocopy varchar2,
                       p_pl_id      out nocopy number,
                       p_opt_id     out nocopy number,
                       p_grade_cer_id out nocopy number,
                       p_point_cer_id out nocopy number) is
begin
   hr_utility.set_location('abr cer is'||p_abr_cer_id,10);
   select information261,information247,information277,information278
   into p_pl_id,p_opt_id,p_grade_cer_id,p_point_cer_id
   from ben_copy_entity_results
   where copy_entity_result_id = p_abr_cer_id;
   hr_utility.set_location('pl is'||p_pl_id,10);
   hr_utility.set_location('opt is'||p_opt_id,10);
   if p_pl_id is not null then
      p_abr_type := 'GRADE';
   elsif p_opt_id is not null then
      p_abr_type := 'POINT';
   else
      p_abr_type := '';
   end if;
exception
   when others then
      hr_utility.set_location('abr fetch issues '||p_abr_cer_id,11);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_abr_detl',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
end get_abr_detl;
function get_abr_cer(p_copy_entity_txn_id in number,
                     p_pl_cer_id          in number default null,
                     p_opt_cer_id         in number default null,
                     p_effective_date     in date) return number is
   l_abr_cer_id number;
begin
   if p_pl_cer_id is not null then
      begin
         hr_utility.set_location('getting abr cer for pl cer'||p_pl_cer_id,10);
         select copy_entity_result_id
         into l_abr_cer_id
         from ben_copy_entity_results
         where INFORMATION277 = p_pl_cer_id
         and table_alias = 'ABR'
         and copy_entity_txn_id = p_copy_entity_txn_id
         and p_effective_date between information2 and information3;
         hr_utility.set_location('abr cer '||l_abr_cer_id,20);
         return l_abr_cer_id;
      exception
         when no_data_found then
            hr_utility.set_location('abr cer doesnot exist',30);
            return l_abr_cer_id;
         when others then
            hr_utility.set_location('issues in getting abr cer ',40);
            PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
            (P_MASTER_TXN_ID   => g_master_txn_id,
             P_TXN_ID          => g_txn_id,
             p_context         => 'get_abr_cer',
             P_MODULE_CD       => 'PQH_GSP_BENSTG',
             P_MESSAGE_TYPE_CD => 'E',
             P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
             p_effective_date  => p_effective_date);
            raise;
      end;
   elsif p_opt_cer_id is not null then
      begin
         hr_utility.set_location('getting abr cer for opt cer'||p_opt_cer_id,10);
         select copy_entity_result_id
         into l_abr_cer_id
         from ben_copy_entity_results
         where INFORMATION278 = p_opt_cer_id
         and table_alias = 'ABR'
         and copy_entity_txn_id = p_copy_entity_txn_id
         and p_effective_date between information2 and information3;
         hr_utility.set_location('abr cer '||l_abr_cer_id,20);
         return l_abr_cer_id;
      exception
         when no_data_found then
            hr_utility.set_location('abr cer doesnot exist',30);
            return l_abr_cer_id;
         when others then
            hr_utility.set_location('issues in getting abr cer ',40);
            PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
            (P_MASTER_TXN_ID   => g_master_txn_id,
             P_TXN_ID          => g_txn_id,
             p_context         => 'get_abr_cer',
             P_MODULE_CD       => 'PQH_GSP_BENSTG',
             P_MESSAGE_TYPE_CD => 'E',
             P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
             p_effective_date  => p_effective_date);
            raise;
      end;
   else
      hr_utility.set_location('pl or opt cer is to be passed',50);
   end if;
end get_abr_cer;
function is_hrr_exists(p_copy_entity_txn_id in number,
                       p_grade_cer_id       in number default null,
                       p_point_cer_id       in number default null,
                       p_hrr_esd            in date) return number is
   l_hrr_cer_id number;
begin
   hr_utility.set_location('inside is_hrr_exists',10);
   select copy_entity_result_id
   into l_hrr_cer_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'HRRATE'
   and (information277 is null or information277 = p_grade_cer_id)
   and (information278 is null or information278 = p_point_cer_id)
   and p_hrr_esd between information2 and information3;
   return l_hrr_cer_id;
exception
   when no_data_found then
      hr_utility.set_location('hrr cer doesnot exist',30);
      return l_hrr_cer_id;
   when others then
      hr_utility.set_location('issues in getting hrr cer ',40);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'is_hrr_exists',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
end is_hrr_exists;
function is_crr_exists(p_copy_entity_txn_id in number,
                       p_crset_id           in number,
                       p_grade_cer_id       in number,
                       p_point_cer_id       in number,
                       p_crr_esd            in date) return boolean is
   l_count number;
begin
   hr_utility.set_location('inside is_crr_exists',10);
   select count(*) into l_count
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'CRRATE'
   and (information230 is null or information230 = p_grade_cer_id)
   and (information169 is null or information169 = p_point_cer_id)
   and p_crr_esd between information2 and information3
   and information160 = p_crset_id;
   hr_utility.set_location('count is '||l_count,20);
   if nvl(l_count,0) > 0 then
      return TRUE;
   else
      return FALSE;
   end if;
end is_crr_exists;
procedure create_crrate_row(p_vpf_cer_id         in number default null,
                            p_abr_cer_id         in number ,
                            p_vpf_id             in number default null,
                            p_vpf_name           in varchar2 default null,
                            p_vpf_ovn            in number default null,
                            p_grade_cer_id       in number default null,
                            p_point_cer_id       in number default null,
                            p_copy_entity_txn_id in number,
                            p_business_group_id  in number,
                            p_effective_date     in date,
                            p_vpf_esd            in date,
                            p_vpf_eed            in date,
                            p_vpf_value          in number,
                            p_crset_id           in number,
                            p_dml_operation      in varchar2 default 'INSERT',
                            p_datetrack_mode     in varchar2 default 'INSERT',
                            p_elp_id             in number default null,
                            p_crr_cer_id         out nocopy number) is
   l_crr_tr_id number;
   l_crr_tr_name varchar2(30);
   l_crr_cer_ovn number;
   l_crr_cer_id number;
   l_continue boolean := TRUE;
   l_crr_exists boolean ;
begin
   hr_utility.set_location('inside crr create',10);
   get_table_route_details(p_table_alias    => 'CRRATE',
                           p_table_route_id => l_crr_tr_id,
                           p_table_name     => l_crr_tr_name);
   hr_utility.set_location('crr tr name'||l_crr_tr_name,20);
   if l_crr_tr_name is null then
      hr_utility.set_location('crr tr name'||l_crr_tr_name,45);
      l_continue := FALSE;
   end if;
   if p_copy_entity_txn_id is null then
      hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
      l_continue := FALSE;
   end if;
   if p_crset_id is null then
      hr_utility.set_location('crset id passed is null',55);
      -- in case of create grrate, we will like to create crrate with no crset id.
   end if;
   if p_abr_cer_id is null then
      hr_utility.set_location('crr has to have abr cer',55);
      l_continue := FALSE;
   end if;
   if p_grade_cer_id is null and p_point_cer_id is null then
      hr_utility.set_location('crr has to have grd/pt cer',55);
      l_continue := FALSE;
   end if;
   if p_vpf_esd is null or p_vpf_eed is null then
      hr_utility.set_location('crr has to have dt range',55);
      l_continue := FALSE;
   end if;
   if p_dml_operation not in ('INSERT','REUSE','UPDATE') then
      hr_utility.set_location('wrong dml_oper passed ',55);
      l_continue := FALSE;
   end if;
   if p_datetrack_mode not in ('INSERT','UPDATE_REPLACE') then
      hr_utility.set_location('wrong dt_mode passed ',55);
      l_continue := FALSE;
   end if;
   l_crr_exists := is_crr_exists(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                 p_crset_id           => p_crset_id,
                                 p_grade_cer_id       => p_grade_cer_id,
                                 p_point_cer_id       => p_point_cer_id,
                                 p_crr_esd            => p_vpf_esd);
   if l_crr_exists then
      hr_utility.set_location('crr exists, no insert',55);
      l_continue := FALSE;
   end if;
   if l_continue then
      begin
         hr_utility.set_location('cer insert api called',55);
         ben_copy_entity_results_api.create_copy_entity_results
         (p_effective_date         => p_effective_date
         ,p_copy_entity_txn_id     => p_copy_entity_txn_id
         ,p_result_type_cd         => 'DISPLAY'
         ,p_table_name             => l_crr_tr_name
         ,p_table_alias            => 'CRRATE'
         ,p_table_route_id         => l_crr_tr_id
         ,p_dml_operation          => p_dml_operation
         ,p_datetrack_mode         => p_datetrack_mode
         ,p_information2           => p_vpf_esd
         ,p_information3           => p_vpf_eed
         ,p_information4           => p_business_group_id
         ,p_information160         => p_crset_id
         ,p_information161         => p_abr_cer_id
         ,p_information162         => p_vpf_cer_id
         ,p_information169         => p_point_cer_id
         ,p_information170         => p_vpf_name
         ,p_information278         => p_vpf_id
         ,p_information279         => p_elp_id
         ,p_information298         => p_vpf_ovn
         ,p_information230         => p_grade_cer_id
         ,p_information293         => p_vpf_value
         ,p_information287         => p_vpf_value
         ,p_copy_entity_result_id  => l_crr_cer_id
         ,p_object_version_number  => l_crr_cer_ovn);
      exception
         when others then
            hr_utility.set_location('some issue in creating crr row ',120);
            raise;
      end;
      p_crr_cer_id := l_crr_cer_id;
   end if;
   hr_utility.set_location('leaving create crrate',55);
end create_crrate_row;
procedure create_crrate_row(p_grade_cer_id       in number default null,
                            p_point_cer_id       in number default null,
                            p_copy_entity_txn_id in number,
                            p_business_group_id  in number,
                            p_effective_date     in date,
                            p_vpf_value          in number,
                            p_crset_id           in number,
                            p_crr_cer_id         out nocopy number) is
   l_eot date := to_date('31-12-4712','DD-MM-RRRR');
   l_sot date := pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
   l_abr_cer_id number;
   l_grd_st_dt date;
   l_continue boolean := true;
begin
   hr_utility.set_location('inside create crrate',55);
-- this routine will be called by setup UI.
   if p_grade_cer_id is null and p_point_cer_id is null then
      hr_utility.set_location('grd/pt cer id should be there',10);
      l_continue := false;
   else
      l_abr_cer_id := get_abr_cer(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                  p_pl_cer_id          => p_grade_cer_id,
                                  p_opt_cer_id         => p_point_cer_id,
                                  p_effective_date     => p_effective_date);
      if l_abr_cer_id is null then
         hr_utility.set_location('going for abr row create ',40);
         if p_grade_cer_id is not null then
            l_grd_st_dt := get_grd_start_date(p_grade_cer_id => p_grade_cer_id);
         end if;
         create_abr_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_pl_cer_id          => p_grade_cer_id,
                        p_opt_cer_id         => p_point_cer_id,
                        p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_start_date         => nvl(l_grd_st_dt,l_sot),
                        p_abr_cer_id         => l_abr_cer_id,
                        p_create_hrr         => 'Y',
                        p_dml_oper           => 'INSERT');
         hr_utility.set_location('abr cer is '||l_abr_cer_id,50);
         if l_abr_cer_id is null then
            l_continue := false;
         end if;
      end if;
   end if;
   if l_continue then
      create_crrate_row(p_grade_cer_id       => p_grade_cer_id,
                        p_point_cer_id       => p_point_cer_id,
                        p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_business_group_id  => p_business_group_id,
                        p_abr_cer_id         => l_abr_cer_id,
                        p_effective_date     => p_effective_date,
                        p_vpf_esd            => p_effective_date,
                        p_vpf_eed            => l_eot,
                        p_vpf_value          => p_vpf_value,
                        p_crset_id           => p_crset_id,
                        p_elp_id             => '',
                        p_crr_cer_id         => p_crr_cer_id);
   end if;
   hr_utility.set_location('leaving create crrate',56);
end create_crrate_row;
procedure create_crset_row(p_crset_id           in number,
                           p_effective_date     in date,
                           p_copy_entity_txn_id in number,
                           p_bu_cd              in varchar2 default null,
                           p_bu_name            in varchar2 default null,
                           p_bu_cer_id          in number default null,
                           p_fp_cd              in varchar2 default null,
                           p_fp_name            in varchar2 default null,
                           p_fp_cer_id          in number default null,
                           p_job_id             in number default null,
                           p_job_name           in varchar2 default null,
                           p_job_cer_id         in number default null,
                           p_org_id             in number default null,
                           p_org_name           in varchar2 default null,
                           p_org_cer_id         in number default null,
                           p_pt_id              in number default null,
                           p_pt_name            in varchar2 default null,
                           p_pt_cer_id          in number default null,
                           p_loc_id             in number default null,
                           p_loc_name           in varchar2 default null,
                           p_loc_cer_id         in number default null,
                           p_perf_rtng_cd       in varchar2 default null,
                           p_event_type         in varchar2 default null,
                           p_perf_rtng_name     in varchar2 default null,
                           p_event_name         in varchar2 default null,
                           p_pr_cer_id          in number default null,
                           p_sa_id              in number default null,
                           p_sa_name            in varchar2 default null,
                           p_sa_cer_id          in number default null,
                           p_ff_id              in number default null,
                           p_ff_name            in varchar2 default null,
                           p_ff_cer_id          in number default null,
                           p_elp_id             in number default null,
                           p_crset_type         in varchar2,
                           p_elp_esd            in date,
                           p_elp_eed            in date default null,
                           p_elp_cer_id         in number default null,
                           p_name               in varchar2) is
   l_crs_tr_id number;
   l_crs_tr_name varchar2(30);
   l_crs_cer_ovn number;
   l_crs_cer_id number;
   l_continue boolean := TRUE;
   l_hyphen number;
   l_event_name varchar2(240);
   l_perf_rating varchar2(240);
   l_dml_oper varchar2(30);
   l_eot date := to_date('31-12-4712','DD-MM-RRRR');
   l_crs_eed date;
   l_Elg_Ovn  Ben_Eligy_Prfl_F.Object_Version_Number%TYPE;
begin
   get_table_route_details(p_table_alias    => 'CRSET',
                           p_table_route_id => l_crs_tr_id,
                           p_table_name     => l_crs_tr_name);
   hr_utility.set_location('crs tr name'||l_crs_tr_name,20);
   if l_crs_tr_name is null then
      hr_utility.set_location('crs tr name'||l_crs_tr_name,45);
      l_continue := FALSE;
   end if;
   if p_copy_entity_txn_id is null then
      hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
      l_continue := FALSE;
   end if;
   if p_crset_id is null then
      hr_utility.set_location('crset id has to be passed ',55);
      l_continue := FALSE;
   end if;
   if p_elp_id is null then
      l_dml_oper := 'INSERT';
   end if;
   if p_elp_eed is null then
      l_crs_eed := l_eot;
   else
      l_crs_eed := p_elp_eed;
   end if;
   Begin
   If P_Elp_Id is NOT NULL Then
      l_Elg_Ovn := Pqh_Gsp_Stage_To_Ben.Get_ovn(p_table_name         => 'BEN_ELIGY_PRFL_F',
                                                p_key_column_name    => 'ELIGY_PRFL_ID',
                                                p_key_column_value   =>  p_elp_id,
                                                P_effective_date     =>  P_effective_date);
   Else
     l_Elg_Ovn := NULL;
   End If;
   Exception
   When No_Data_Found Then
        l_Elg_Ovn := NULL;
   End;
   if l_continue then
      begin
         -- These mappings have been taken from hrben_to_stage document
         -- call to create ben_cer is made here using api.
         ben_copy_entity_results_api.create_copy_entity_results
         (p_effective_date         => p_effective_date
         ,p_copy_entity_txn_id     => p_copy_entity_txn_id
         ,p_result_type_cd         => 'DISPLAY'
         ,p_table_name             => l_crs_tr_name
         ,p_table_alias            => 'CRSET'
         ,p_table_route_id         => l_crs_tr_id
         ,p_dml_operation          => l_dml_oper
         ,p_information2           => p_elp_esd
         ,p_information3           => l_crs_eed
         ,p_information5           => p_name
         ,p_information151         => p_name
         ,p_information1           => p_crset_id
         ,p_information277         => p_elp_id
         ,p_information160         => p_elp_cer_id
         ,p_information161         => p_crset_id
         ,p_information100         => p_crset_type
-- copy the cers
         ,p_INFORMATION222         => p_loc_cer_id
         ,p_INFORMATION223         => p_job_cer_id
         ,p_INFORMATION224         => p_org_cer_id
         ,p_INFORMATION225         => p_ff_cer_id
         ,p_INFORMATION226         => p_pt_cer_id
         ,p_INFORMATION227         => p_sa_cer_id
         ,p_INFORMATION228         => p_bu_cer_id
         ,p_INFORMATION229         => p_fp_cer_id
         ,p_INFORMATION230         => p_pr_cer_id
-- copy the id/codes
         ,p_INFORMATION232         => p_loc_id
         ,p_INFORMATION233         => p_job_id
         ,p_INFORMATION234         => p_org_id
         ,p_INFORMATION235         => p_ff_id
         ,p_INFORMATION236         => p_pt_id
         ,p_INFORMATION237         => p_sa_id
         ,p_INFORMATION101         => p_bu_cd
         ,p_INFORMATION102         => p_fp_cd
         ,p_INFORMATION103         => p_perf_rtng_cd
         ,p_INFORMATION104         => p_event_type
-- copy the values
         ,p_INFORMATION179         => p_loc_name
         ,p_INFORMATION181         => p_job_name
         ,p_INFORMATION182         => p_org_name
         ,p_INFORMATION170         => p_ff_name
         ,p_INFORMATION173         => p_pt_name
         ,p_INFORMATION185         => p_sa_name
         ,p_INFORMATION186         => p_bu_name
         ,p_INFORMATION187         => p_fp_name
         ,p_INFORMATION188         => p_perf_rtng_name
         ,p_INFORMATION175         => p_event_name
	 ,p_INFORMATION265         => l_Elg_Ovn
         ,p_copy_entity_result_id  => l_crs_cer_id
         ,p_object_version_number  => l_crs_cer_ovn);
      exception
         when others then
            hr_utility.set_location('some issue in creating crs row ',120);
            raise;
      end;
   end if;
end create_crset_row;
procedure update_crset(p_crset_id           in number,
                       p_effective_date     in date,
                       p_crset_name         in varchar2,
                       p_copy_entity_txn_id in number,
                       p_datetrack_mode     in varchar2,
                       p_bu_cd              in varchar2 default null,
                       p_bu_name            in varchar2 default null,
                       p_fp_cd              in varchar2 default null,
                       p_fp_name            in varchar2 default null,
                       p_job_id             in number default null,
                       p_job_name           in varchar2 default null,
                       p_org_id             in number default null,
                       p_org_name           in varchar2 default null,
                       p_pt_id              in number default null,
                       p_pt_name            in varchar2 default null,
                       p_loc_id             in number default null,
                       p_loc_name           in varchar2 default null,
                       p_perf_rtng_cd       in varchar2 default null,
                       p_perf_rtng_name     in varchar2 default null,
                       p_event_type         in varchar2 default null,
                       p_event_name         in varchar2 default null,
                       p_sa_id              in number default null,
                       p_sa_name            in varchar2 default null,
                       p_ff_id              in number default null,
                       p_ff_name            in varchar2 default null) is
cursor csr_crset is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias = 'CRSET'
   and   information161 = p_crset_id
   and p_effective_date between information2 and information3;
l_continue boolean := TRUE;
l_dml_operation varchar2(30);
l_upd_curr   varchar2(30);
l_del_future varchar2(30);
l_crset_eed date;
l_upd_effdt  varchar2(30);
l_ins_row    varchar2(30);
l_eot date := to_date('31-12-4712','DD-MM-RRRR');
begin
   hr_utility.set_location('inside update_crset ',10);
   validate_crset(p_name               => p_crset_name,
                  p_bu_cd              => p_bu_cd,
                  p_bu_name            => p_bu_name,
                  p_fp_cd              => p_fp_cd,
                  p_fp_name            => p_fp_name,
                  p_job_id             => p_job_id,
                  p_job_name           => p_job_name,
                  p_org_id             => p_org_id,
                  p_org_name           => p_org_name,
                  p_pt_id              => p_pt_id,
                  p_pt_name            => p_pt_name,
                  p_loc_id             => p_loc_id,
                  p_loc_name           => p_loc_name,
                  p_perf_rtng_cd       => p_perf_rtng_cd,
                  p_event_type         => p_event_type,
                  p_perf_rtng_name     => p_perf_rtng_name,
                  p_event_name         => p_event_name,
                  p_sa_id              => p_sa_id,
                  p_sa_name            => p_sa_name,
                  p_ff_id              => p_ff_id,
                  p_ff_name            => p_ff_name,
                  p_valid              => l_continue);
   hr_utility.set_location('data validated ',10);
   if p_datetrack_mode not in ('CORRECTION','UPDATE_REPLACE') then
      hr_utility.set_location('invalid dt mode '||p_datetrack_mode,1);
      l_continue := false;
   else
      hr_utility.set_location('dt mode '||p_datetrack_mode,1);
   end if;
   if l_continue then
      for crset_rec in csr_crset loop
         hr_utility.set_location('criteria set row found'||substr(p_crset_name,1,40),10);
         if nvl(crset_rec.dml_operation,'REUSE') = 'REUSE' then
            l_dml_operation := 'UPDATE';
         else
            l_dml_operation := crset_rec.dml_operation;
         end if;
         hr_utility.set_location('new dml oper is '||l_dml_operation,4);
         if p_datetrack_mode = 'CORRECTION' then
            hr_utility.set_location('same row is to be updated',10);
            l_upd_curr   := 'Y';
            l_del_future := 'N';
            l_crset_eed := crset_rec.information3;
            l_upd_effdt  := 'N';
            l_ins_row    := 'N';
         else
            if crset_rec.information2 = p_effective_date then
               -- row is getting updated on same date, so no insert only update
               hr_utility.set_location('rec started as of today',5);
               l_ins_row   := 'N';
               l_upd_curr  := 'Y';
               l_upd_effdt := 'N';
               l_crset_eed := l_eot;
               if crset_rec.information3 <> l_eot then
               -- current row goes till end of time so no delete too
                  hr_utility.set_location('rec is not till eot ',5);
                  l_del_future := 'Y';
               else
                  hr_utility.set_location('rec is till eot ',5);
                  l_del_future := 'N';
               end if;
            else
               hr_utility.set_location('rec started earlier than today',5);
               l_del_future := 'Y';
               l_upd_curr   := 'N';
               l_ins_row    := 'Y';
               l_upd_effdt  := 'Y';
               l_crset_eed := p_effective_date - 1;
            end if;
         end if;
         if l_del_future = 'Y' then
            hr_utility.set_location('deleting future recs',6);
            delete from ben_copy_entity_results
            where copy_entity_txn_id = p_copy_entity_txn_id
            and table_alias = 'CRSET'
            and information161 = p_crset_id
            and information2 > p_effective_date;
         end if;
         if l_upd_effdt ='Y' then
            hr_utility.set_location('updating effdt of curr row',6);
            update ben_copy_entity_results
            set INFORMATION3 = l_crset_eed
            where copy_entity_result_id = crset_rec.copy_entity_result_id;
         end if;
         if l_upd_curr ='Y' then
            hr_utility.set_location('updating curr row with new values',6);
            update ben_copy_entity_results
            set dml_operation = l_dml_operation,
                INFORMATION232 = p_loc_id,
                INFORMATION233 = p_job_id,
                INFORMATION234 = p_org_id,
                INFORMATION235 = p_ff_id,
                INFORMATION236 = p_pt_id,
                INFORMATION237 = p_sa_id,
                INFORMATION101 = p_bu_cd,
                INFORMATION102 = p_fp_cd,
                INFORMATION103 = p_perf_rtng_cd,
                INFORMATION104 = p_event_type,
                INFORMATION179 = p_loc_name,
                INFORMATION181 = p_job_name,
                INFORMATION182 = p_org_name,
                INFORMATION170 = p_ff_name,
                INFORMATION173 = p_pt_name,
                INFORMATION185 = p_sa_name,
                INFORMATION186 = p_bu_name,
                INFORMATION187 = p_fp_name,
                INFORMATION188 = p_perf_rtng_name,
                INFORMATION175 = p_event_name,
                information151 = p_crset_name,
                information3   = l_crset_eed
            where copy_entity_result_id = crset_rec.copy_entity_result_id;
         end if;
         if l_ins_row ='Y' then
            hr_utility.set_location('creating new row with new values',6);
            create_crset_row(p_crset_id           => p_crset_id,
                             p_effective_date     => p_effective_date,
                             p_copy_entity_txn_id => p_copy_entity_txn_id,
                             p_bu_cd              => p_bu_cd,
                             p_bu_name            => p_bu_name,
                             p_bu_cer_id          => crset_rec.information228,
                             p_fp_cd              => p_fp_cd,
                             p_fp_name            => p_fp_name,
                             p_fp_cer_id          => crset_rec.information229,
                             p_job_id             => p_job_id,
                             p_job_name           => p_job_name,
                             p_job_cer_id         => crset_rec.information223,
                             p_org_id             => p_org_id,
                             p_org_name           => p_org_name,
                             p_org_cer_id         => crset_rec.information224,
                             p_pt_id              => p_pt_id,
                             p_pt_name            => p_pt_name,
                             p_pt_cer_id          => crset_rec.information226,
                             p_loc_id             => p_loc_id,
                             p_loc_name           => p_loc_name,
                             p_loc_cer_id         => crset_rec.information222,
                             p_perf_rtng_cd       => p_perf_rtng_cd,
                             p_event_type         => p_event_type,
                             p_perf_rtng_name     => p_perf_rtng_name,
                             p_event_name         => p_event_name,
                             p_pr_cer_id          => crset_rec.information230,
                             p_sa_id              => p_sa_id,
                             p_sa_name            => p_sa_name,
                             p_sa_cer_id          => crset_rec.information227,
                             p_ff_id              => p_ff_id,
                             p_ff_name            => p_ff_name,
                             p_ff_cer_id          => crset_rec.information225,
                             p_crset_type         => crset_rec.information100,
                             p_elp_id             => crset_rec.information277,
                             p_elp_esd            => p_effective_date,
                             p_elp_eed            => l_eot,
                             p_name               => p_crset_name,
                             p_elp_cer_id         => crset_rec.information160);
         end if;
         hr_utility.set_location('end of update_crset ',6);
      end loop;
   else
      hr_utility.set_location('invalid data passed',7);
   end if;
   hr_utility.set_location('out of update_crset',8);
end update_crset;
procedure create_crset_row(p_crset_id           out nocopy number,
                           p_effective_date     in date,
                           p_copy_entity_txn_id in number,
                           p_bu_cd              in varchar2 default null,
                           p_bu_name            in varchar2 default null,
                           p_fp_cd              in varchar2 default null,
                           p_fp_name            in varchar2 default null,
                           p_job_id             in number default null,
                           p_job_name           in varchar2 default null,
                           p_org_id             in number default null,
                           p_org_name           in varchar2 default null,
                           p_pt_id              in number default null,
                           p_pt_name            in varchar2 default null,
                           p_loc_id             in number default null,
                           p_loc_name           in varchar2 default null,
                           p_perf_rtng_cd       in varchar2 default null,
                           p_event_type         in varchar2 default null,
                           p_perf_rtng_name     in varchar2 default null,
                           p_event_name         in varchar2 default null,
                           p_sa_id              in number default null,
                           p_sa_name            in varchar2 default null,
                           p_ff_id              in number default null,
                           p_ff_name            in varchar2 default null,
                           p_validate           in varchar2 default 'TRUE',
                           p_crset_type         in varchar2,
                           p_name               in varchar2) is
   l_eot date := to_date('31-12-4712','DD-MM-RRRR');
   l_crset_id number;
   l_continue boolean := true;
begin
   if p_validate = 'TRUE' then
      validate_crset(p_name               => p_name,
                     p_bu_cd              => p_bu_cd,
                     p_bu_name            => p_bu_name,
                     p_fp_cd              => p_fp_cd,
                     p_fp_name            => p_fp_name,
                     p_job_id             => p_job_id,
                     p_job_name           => p_job_name,
                     p_org_id             => p_org_id,
                     p_org_name           => p_org_name,
                     p_pt_id              => p_pt_id,
                     p_pt_name            => p_pt_name,
                     p_loc_id             => p_loc_id,
                     p_loc_name           => p_loc_name,
                     p_perf_rtng_cd       => p_perf_rtng_cd,
                     p_event_type         => p_event_type,
                     p_perf_rtng_name     => p_perf_rtng_name,
                     p_event_name         => p_event_name,
                     p_sa_id              => p_sa_id,
                     p_sa_name            => p_sa_name,
                     p_ff_id              => p_ff_id,
                     p_ff_name            => p_ff_name,
                     p_valid              => l_continue);
   else
      hr_utility.set_location('data is not to be validated coming from SFL',11);
   end if;
   if l_continue then
      select pqh_gsp_criteria_set_id_s.nextval into l_crset_id from dual;
      hr_utility.set_location('crset id value is '||l_crset_id,30);
      create_crset_row
      (p_crset_id           => l_crset_id,
       p_effective_date     => p_effective_date,
       p_copy_entity_txn_id => p_copy_entity_txn_id,
       p_bu_cd              => p_bu_cd,
       p_bu_name            => p_bu_name,
       p_fp_cd              => p_fp_cd,
       p_fp_name            => p_fp_name,
       p_job_id             => p_job_id,
       p_job_name           => p_job_name,
       p_org_id             => p_org_id,
       p_org_name           => p_org_name,
       p_pt_id              => p_pt_id,
       p_pt_name            => p_pt_name,
       p_loc_id             => p_loc_id,
       p_loc_name           => p_loc_name,
       p_perf_rtng_cd       => p_perf_rtng_cd,
       p_event_type         => p_event_type,
       p_perf_rtng_name     => p_perf_rtng_name,
       p_event_name         => p_event_name,
       p_sa_id              => p_sa_id,
       p_sa_name            => p_sa_name,
       p_ff_id              => p_ff_id,
       p_ff_name            => p_ff_name,
       p_crset_type         => p_crset_type,
       p_elp_esd            => p_effective_date,
       p_elp_eed            => l_eot,
       p_name               => p_name);
   else
      hr_utility.set_location('data incomplete',20);
   end if;
   p_crset_id := l_crset_id;
end create_crset_row;
procedure is_elp_exists_in_crset(p_copy_entity_txn_id in number,
                                 p_elp_id             in number,
                                 p_start_date         in date,
                                 p_end_date           in date,
                                 p_crset_id           out nocopy number,
                                 p_crset_type         out nocopy varchar2,
                                 p_ins_flag           out nocopy boolean) is
cursor csr_crset is
   select information151,copy_entity_result_id,information161,information2,information3,information100
   from ben_copy_entity_results
   where table_alias ='CRSET'
   and copy_entity_txn_id = p_copy_entity_txn_id
   and information277 = p_elp_id;
begin
-- crset may exist but not for the date range, with this routine we are
-- telling whether it exists or not and also , for this range can the row is to be inserted
-- or not
   hr_utility.set_location('inside is_elp_exists_in_crset ',10);
   hr_utility.set_location('elp_id is '||p_elp_id,10);
   hr_utility.set_location('elp esd '||to_char(p_start_date,'DD-MM-RRRR'),11);
   hr_utility.set_location('elp eed '||to_char(p_end_date,'DD-MM-RRRR'),11);
   p_ins_flag := true;
   for i in csr_crset loop
      p_crset_id := i.information161;
      p_crset_type := i.information100;
      hr_utility.set_location('crset name is '||substr(i.information151,1,45),12);
      hr_utility.set_location('crset cer id is '||i.copy_entity_result_id,12);
      hr_utility.set_location('crset esd '||to_char(i.information2,'DD-MM-RRRR'),13);
      hr_utility.set_location('crset eed '||to_char(i.information3,'DD-MM-RRRR'),14);
      if p_start_date between i.information2 and i.information3 and
         p_end_date between i.information2 and i.information3 then
         p_ins_flag := false;
      end if;
   end loop;
end is_elp_exists_in_crset;
procedure build_crset_for_elp(p_elp_id             in number,
                              p_copy_entity_txn_id in number,
                              p_abr_type           in varchar2,
                              p_effective_date     in date,
                              p_business_group_id  in number,
                              p_crset_id           out nocopy number) is
l_elp_cer_id     number;
l_crset_name     varchar2(240);
l_elp_id         number;
l_bu_cd          varchar2(30);
l_bu_name        varchar2(240);
l_fp_name        varchar2(240);
l_fp_cd          varchar2(30);
l_job_id         varchar2(30);
l_org_id         varchar2(30);
l_org_name       varchar2(240);
l_job_name       varchar2(240);
l_loc_name       varchar2(240);
l_pt_id          varchar2(30);
l_pt_name        varchar2(240);
l_pr_name        varchar2(240);
l_loc_id         varchar2(30);
l_perf_rtng_cd   varchar2(30);
l_event_type     varchar2(30);
l_perf_rtng_name varchar2(240);
l_event_name     varchar2(240);
l_sa_id          varchar2(30);
l_sa_name        varchar2(30);
l_ff_id          varchar2(30);
l_ff_name        varchar2(30);
l_continue       varchar2(30);
l_elp_esd        date;
l_abr_type varchar2(30);
l_crset_type varchar2(30);
l_ins_flag boolean;
l_crset_id number;
l_bu_cer_id number;
l_sa_cer_id number;
l_pt_cer_id number;
l_pr_cer_id number;
l_ff_cer_id number;
l_fp_cer_id number;
l_job_cer_id number;
l_org_cer_id number;
l_loc_cer_id number;
l_hyphen varchar2(30);
cursor csr_elig_prof is
   select *
   from   ben_copy_entity_results
   where information1 = p_elp_id
   and copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='ELP'
   order by result_type_cd;
cursor csr_elig_crit (l_elp_cer_id number) is
   select *
   from ben_copy_entity_results
   where parent_entity_result_id = l_elp_cer_id
   and   copy_entity_txn_id      = p_copy_entity_txn_id
   and l_elp_esd between information2 and information3;
begin
   hr_utility.set_location('inside build_crset_for_elp ',10);
   for elp_rec in csr_elig_prof loop
       hr_utility.set_location('elp avail,pull detl ',30);
       l_ins_flag := TRUE;
       l_elp_esd := elp_rec.information2;
       hr_utility.set_location('elp esd is '||to_char(l_elp_esd,'DD-MM-RRRR'),13);
       if l_elp_cer_id is null then
-- as all criteria rows are linked to display elp row, we are getting that
          l_elp_cer_id  := elp_rec.copy_entity_result_id;
       end if;
       hr_utility.set_location('elp cer id is '||l_elp_cer_id,13);
       -- if crset exists in this txn then we don't have to create it
       is_elp_exists_in_crset(p_copy_entity_txn_id => p_copy_entity_txn_id,
                              p_elp_id             => elp_rec.information1,
                              p_start_date         => elp_rec.information2,
                              p_end_date           => elp_rec.information3,
                              p_crset_id           => l_crset_id,
                              p_ins_flag           => l_ins_flag,
                              p_crset_type         => l_crset_type);
       hr_utility.set_location('exist crset type is '||l_crset_type,30);
       if l_crset_type is null then
          l_crset_type := p_abr_type;
       elsif ((l_crset_type ='GRADE' and p_abr_type ='POINT') or
             (l_crset_type ='POINT' and p_abr_type ='GRADE')) then
            l_crset_type := 'GRADE_POINT';
            hr_utility.set_location('upd crset type is '||l_crset_type,30);
            update_crset_type(p_copy_entity_txn_id => p_copy_entity_txn_id,
                              p_crset_id           => l_crset_id,
                              p_crset_type         => l_crset_type);
       end if;
       hr_utility.set_location('crset type updated to be '||l_crset_type,30);
       if l_ins_flag then
          -- the elp current row is to be inserted in crset table
          -- if crset id is null then new crset is to be pulled from seq.
          if l_crset_id is null then
             select pqh_gsp_criteria_set_id_s.nextval into l_crset_id from dual;
             hr_utility.set_location('crset id value is '||l_crset_id,30);
          end if;

          l_bu_cd := null;
          l_bu_name := null;
          l_bu_cer_id := null;

          l_fp_name := null;
          l_fp_cd := null;
          l_fp_cer_id := null;

          l_job_id := null;
          l_job_name := null;
          l_job_cer_id := null;

          l_org_id := null;
          l_org_name := null;
          l_org_cer_id := null;

          l_pt_id := null;
          l_pt_name := null;
          l_pt_cer_id := null;

          l_loc_id := null;
          l_loc_name := null;
          l_loc_cer_id := null;

          l_pr_cer_id := null;
          l_pr_name := null;
          l_perf_rtng_cd := null;
          l_event_type := null;
          l_perf_rtng_name := null;
          l_event_name := null;

          l_sa_id := null;
          l_sa_name := null;
          l_sa_cer_id := null;

          l_ff_id := null;
          l_ff_name := null;
          l_ff_cer_id := null;

          hr_utility.set_location('local_var initialized',11);
          for crit_rec in csr_elig_crit(l_elp_cer_id ) loop
             hr_utility.set_location('table alias is '||crit_rec.table_alias,30);
             if crit_rec.table_alias = 'EBU' then
                l_bu_cd     := crit_rec.information11;
                l_bu_name   := crit_rec.information5;
                l_bu_cer_id := crit_rec.copy_entity_result_id;
                hr_utility.set_location('bargain_unit is '||substr(l_bu_name,1,40),11);
             elsif crit_rec.table_alias = 'EFP' then
                l_fp_cd     := crit_rec.information12;
                l_fp_name   := crit_rec.information5;
                l_fp_cer_id := crit_rec.copy_entity_result_id;
                hr_utility.set_location('fp is '||substr(l_fp_name,1,40),11);
             elsif crit_rec.table_alias = 'EJP' then
                l_job_id     := crit_rec.information174;
                l_job_name   := crit_rec.information5;
                l_job_cer_id := crit_rec.copy_entity_result_id;
                hr_utility.set_location('job is '||substr(l_job_name,1,40),11);
             elsif crit_rec.table_alias = 'EOU' then
                l_org_id     := crit_rec.information174;
                l_org_name   := crit_rec.information5;
                l_org_cer_id := crit_rec.copy_entity_result_id;
                hr_utility.set_location('org is '||substr(l_org_name,1,40),11);
             elsif crit_rec.table_alias = 'EPT' then
                l_pt_id     := crit_rec.information174;
                l_pt_name   := crit_rec.information5;
                l_pt_cer_id := crit_rec.copy_entity_result_id;
                hr_utility.set_location('per_typ is '||substr(l_pt_name,1,40),11);
             elsif crit_rec.table_alias = 'EWL' then
                l_loc_id     := crit_rec.information174;
                l_loc_name   := crit_rec.information5;
                l_loc_cer_id := crit_rec.copy_entity_result_id;
                hr_utility.set_location('loc is '||substr(l_loc_name,1,40),11);
             elsif crit_rec.table_alias = 'ERG' then
                l_event_type   := crit_rec.information12;
                l_perf_rtng_cd := crit_rec.information13;
                l_pr_name      := crit_rec.information5;
                l_pr_cer_id    := crit_rec.copy_entity_result_id;
                if l_pr_name is not null then
                   l_hyphen         := instr(l_pr_name,'-');
                   l_perf_rtng_name := substr(l_pr_name,1,l_hyphen-1);
                   l_event_name     := substr(l_pr_name,l_hyphen+2);
                end if;
                hr_utility.set_location('perf_rtng is '||substr(l_pr_name,1,40),11);
             elsif crit_rec.table_alias = 'ESA' then
                l_sa_id     := crit_rec.information241;
                l_sa_name   := crit_rec.information5;
                l_sa_cer_id := crit_rec.copy_entity_result_id;
                hr_utility.set_location('svc_area is '||substr(l_sa_name,1,40),11);
             elsif crit_rec.table_alias = 'ERL' then
                l_ff_id     := crit_rec.information251;
                l_ff_name   := crit_rec.information5;
                l_ff_cer_id := crit_rec.copy_entity_result_id;
                hr_utility.set_location('rule is '||substr(l_ff_name,1,40),11);
             end if;
          end loop;
          hr_utility.set_location('all variables pulled',11);
          create_crset_row(p_crset_id           => l_crset_id,
                           p_effective_date     => p_effective_date,
                           p_copy_entity_txn_id => p_copy_entity_txn_id,
                           p_bu_cd              => l_bu_cd,
                           p_bu_name            => l_bu_name,
                           p_bu_cer_id          => l_bu_cer_id,
                           p_fp_cd              => l_fp_cd,
                           p_fp_name            => l_fp_name,
                           p_fp_cer_id          => l_fp_cer_id,
                           p_job_id             => l_job_id,
                           p_job_name           => l_job_name,
                           p_job_cer_id         => l_job_cer_id,
                           p_org_id             => l_org_id,
                           p_org_name           => l_org_name,
                           p_org_cer_id         => l_org_cer_id,
                           p_pt_id              => l_pt_id,
                           p_pt_name            => l_pt_name,
                           p_pt_cer_id          => l_pt_cer_id,
                           p_loc_id             => l_loc_id,
                           p_loc_name           => l_loc_name,
                           p_loc_cer_id         => l_loc_cer_id,
                           p_perf_rtng_cd       => l_perf_rtng_cd,
                           p_event_type         => l_event_type,
                           p_perf_rtng_name     => l_perf_rtng_name,
                           p_event_name         => l_event_name,
                           p_pr_cer_id          => l_pr_cer_id,
                           p_sa_id              => l_sa_id,
                           p_sa_name            => l_sa_name,
                           p_sa_cer_id          => l_sa_cer_id,
                           p_ff_id              => l_ff_id,
                           p_ff_name            => l_ff_name,
                           p_ff_cer_id          => l_ff_cer_id,
                           p_crset_type         => l_crset_type,
                           p_elp_id             => elp_rec.information1,
                           p_elp_esd            => elp_rec.information2,
                           p_elp_eed            => elp_rec.information3,
                           p_name               => substr(elp_rec.information5,1,150),
                           p_elp_cer_id         => elp_rec.copy_entity_result_id);
       else
          hr_utility.set_location('elp row in crset,skipping',50);
       end if;
   end loop;
   p_crset_id := l_crset_id;
   hr_utility.set_location('build_crset_for_elp done',50);
end build_crset_for_elp;
procedure pull_elp_for_crset(p_elp_id             in number,
                             p_copy_entity_txn_id in number,
                             p_crset_type         in varchar2,
                             p_effective_date     in date,
                             p_business_group_id  in number,
                             p_crset_id           out nocopy number,
                             p_dup_crset          out nocopy varchar2) is
   l_elp_cer_id number;
   l_job_id number;
   l_loc_id number;
   l_org_id number;
   l_rule_id number;
   l_pt_id number;
   l_sa_id number;
   l_bu_cd varchar2(30);
   l_pr_cd varchar2(30);
   l_event_type varchar2(30);
   l_crset_name varchar2(240);
   l_fp_cd varchar2(30);
   l_dup_exists varchar2(30) := 'N';
   l_dup_crset varchar2(150);
   cursor crset_rec is select information151 crset_name,
                              INFORMATION232 loc_id,
                              INFORMATION233 job_id,
                              INFORMATION234 org_id,
                              INFORMATION235 rule_id,
                              INFORMATION236 pt_id,
                              INFORMATION237 sa_id,
                              INFORMATION101 bu_cd,
                              INFORMATION102 fp_cd,
                              INFORMATION103 pr_cd,
                              INFORMATION104 event_type
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='CRSET'
   and information161 = p_crset_id
   and p_effective_date between information2 and information3;
begin
   hr_utility.set_location('elig-prof to be copied',1);
   savepoint pull_elp;
   populate_ep_hierarchy(p_copy_entity_txn_id => p_copy_entity_txn_id,
                         p_effective_date     => p_effective_date,
                         p_business_group_id  => p_business_group_id,
                         p_business_area      => 'PQH_GSP_TASK_LIST',
                         p_ep_id              => p_elp_id,
                         p_ep_cer_id          => l_elp_cer_id);
   hr_utility.set_location('elig-prof copied',10);
   build_crset_for_elp(p_elp_id             => p_elp_id,
                       p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_abr_type           => p_crset_type,
                       p_effective_date     => p_effective_date,
                       p_business_group_id  => p_business_group_id,
                       p_crset_id           => p_crset_id);
   hr_utility.set_location('crset is '||p_crset_id,20);
   if p_crset_id is not null then
      open crset_rec;
      fetch crset_rec into l_crset_name,l_loc_id,l_job_id,l_org_id,l_rule_id,l_pt_id,l_sa_id,l_bu_cd,l_fp_cd,l_pr_cd,l_event_type;
      if crset_rec%found then
         pqh_gsp_utility.chk_duplicate_crset_exists(
                         p_copy_entity_txn_id  => p_copy_entity_txn_id,
                         p_effective_date      => p_effective_date,
                         p_cset_id             => p_crset_id,
                         p_location_id         => l_loc_id,
                         p_job_id              => l_job_id,
                         p_org_id              => l_org_id,
                         p_rule_id             => l_rule_id,
                         p_person_type_id      => l_pt_id,
                         p_service_area_id     => l_sa_id,
                         p_barg_unit_cd        => l_bu_cd,
                         p_full_part_time_cd   => l_fp_cd,
                         p_perf_type_cd        => l_pr_cd,
                         p_rating_type_cd      => l_event_type,
                         p_duplicate_exists    => l_dup_exists,
                         p_duplicate_cset_name => l_dup_crset);
        if l_dup_exists = 'Y' then
           rollback to pull_elp;
           p_dup_crset := l_dup_crset;
        end if;
     end if;
     close crset_rec;
  end if;
exception
  when others then
     raise;
end pull_elp_for_crset;
procedure vpf_to_stage(p_vpf_cer_id         in number,
                       p_copy_entity_txn_id in number,
                       p_effective_date     in date,
                       p_result_type_cd     in varchar2) is
l_abr_cer_id   number;
l_crr_cer_id   number;
l_vpf_name     varchar2(240);
l_vpf_value    number;
l_vpf_id       number;
l_vpf_ovn      number;
l_pl_id        number;
l_opt_id       number;
l_continue     varchar2(30) := 'Y';
l_abr_type     varchar2(30);
l_dis_vpf_cer_id number;
l_crset_id     number;
l_grade_cer_id number;
l_point_cer_id number;
l_vpf_esd      date;
l_vpf_eed      date;
l_bg number;
l_elp_id number;
begin
   hr_utility.set_location('inside vpf_to_stage ',10);
-- variable rate row is pulled to staging area, based on this we have to build
-- crrate row and crset row
-- the hierarchy on the ben side is like this
-- abr -> avr -> vpf -> vep -> elp -> criteria rows
   begin
      select PARENT_ENTITY_RESULT_ID    ,        -- abr_cer_id
             INFORMATION170 NAME        ,        -- name of Variable Rate
             INFORMATION303 VAL         ,        -- value
             INFORMATION2 esd         ,        -- st dt
             INFORMATION3 eed         ,        -- end dt
             INFORMATION4 bg         ,        -- end dt
             INFORMATION1 VRBL_RT_PRFL_ID ,     -- pk of database row
             INFORMATION265 ovn
      into l_abr_cer_id,l_vpf_name, l_vpf_value, l_vpf_esd, l_vpf_eed, l_bg, l_vpf_id, l_vpf_ovn
      from   ben_copy_entity_results
      where copy_entity_result_id = p_vpf_cer_id
      and information72 ='GSPSA'
      and INFORMATION77 = 'A';
   exception
      when no_data_found then
         hr_utility.set_location('vpf is not for GSP ',10);
         l_continue := 'N';
      when others then
         hr_utility.set_location('issues in getting vpf ',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'vpf_to_stage_vpf_pull',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => p_effective_date);
         raise;
   end;
   hr_utility.set_location('abr cer id is '||l_abr_cer_id,10);
   get_abr_detl(p_abr_cer_id    => l_abr_cer_id,
                p_abr_type      => l_abr_type,
                p_pl_id         => l_pl_id,
                p_opt_id        => l_opt_id,
                p_grade_cer_id  => l_grade_cer_id,
                p_point_cer_id  => l_point_cer_id);
   hr_utility.set_location('abr_type is '||l_abr_type,10);
   if l_abr_type is null then
      l_continue := 'N';
   end if;
   if p_result_type_cd <> 'DISPLAY' then
      l_dis_vpf_cer_id := get_display_vpf_cer(p_vpf_id             => l_vpf_id,
                                              p_copy_entity_txn_id => p_copy_entity_txn_id);
   else
      l_dis_vpf_cer_id := p_vpf_cer_id;
   end if;
   if l_dis_vpf_cer_id is not null then
      l_elp_id := get_elp_for_vpf(p_vpf_cer_id         => l_dis_vpf_cer_id,
                                  p_copy_entity_txn_id => p_copy_entity_txn_id,
                                  p_effective_date     => p_effective_date);
      if l_elp_id is null then
         l_continue := 'N';
      end if;
   else
      l_continue := 'N';
   end if;
   if l_continue = 'Y' then
      build_crset_for_elp(p_elp_id             => l_elp_id,
                          p_copy_entity_txn_id => p_copy_entity_txn_id,
                          p_abr_type           => l_abr_type,
                          p_business_group_id  => l_bg,
                          p_effective_date     => p_effective_date,
                          p_crset_id           => l_crset_id);
   end if;
   if l_crset_id is not null then
      create_crrate_row(p_vpf_cer_id         => p_vpf_cer_id,
                        p_abr_cer_id         => l_abr_cer_id,
                        p_vpf_id             => l_vpf_id,
                        p_vpf_ovn            => l_vpf_ovn,
                        p_vpf_name           => l_vpf_name,
                        p_grade_cer_id       => l_grade_cer_id,
                        p_point_cer_id       => l_point_cer_id,
                        p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_business_group_id  => l_bg,
                        p_effective_date     => p_effective_date,
                        p_vpf_esd            => l_vpf_esd,
                        p_vpf_eed            => l_vpf_eed,
                        p_vpf_value          => l_vpf_value,
                        p_crset_id           => l_crset_id,
                        p_dml_operation      => 'REUSE',
                        p_elp_id             => l_elp_id,
                        p_crr_cer_id         => l_crr_cer_id);
   end if;
   hr_utility.set_location('vpf_to_stage done',50);
exception
   when others then
      hr_utility.set_location('issues in vpf_to_stage ',20);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'vpf_to_stage',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => p_effective_date);
      raise;
end vpf_to_stage;
procedure scl_writeback(p_copy_entity_txn_id in number,
                        p_scale_id           in number,
                        p_scale_cer_id       in number) is
begin
-- this routine will update scale_cer_id for all plips
   update ben_copy_entity_results
   set information255 = p_scale_id,
       information258 = p_scale_cer_id
   where table_alias = 'CPP'
   and copy_entity_txn_id = p_copy_entity_txn_id
   and (information258 = p_scale_cer_id or information255 = p_scale_id);
exception
   when others then
      hr_utility.set_location('issue in updating parent ',420);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'scl_writeback',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
end scl_writeback;
-- this routine is not needed as of now, because elig-prof can be attached to
-- oipls only
procedure change_parent_oipl(p_copy_entity_txn_id in number,
                             p_oipl_cer_id        in number,
                             p_opt_cer_id         in number) is
begin
   hr_utility.set_location('inside chg_parent for oipl'||p_oipl_cer_id,10);
   begin
      update ben_copy_entity_results
      set parent_entity_result_id = p_oipl_cer_id,
          gs_parent_entity_result_id = p_oipl_cer_id
      where table_alias = 'ELP'
      and copy_entity_txn_id = p_copy_entity_txn_id
      and parent_entity_result_id = p_opt_cer_id;
      hr_utility.set_location('ELP rows changed '||p_oipl_cer_id,20);
   exception
      when others then
         hr_utility.set_location('issue in updating parent ',420);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'change_parent_oipl',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
         raise;
   end;
end change_parent_oipl;
procedure change_parent_plip(p_copy_entity_txn_id in number,
                             p_plip_cer_id        in number,
                             p_pl_cer_id          in number) is
begin
   hr_utility.set_location('inside chg_parent for plp: plip_cer'||p_plip_cer_id,10);
   hr_utility.set_location('inside chg_parent for plp: pl_cer'||p_pl_cer_id,20);
 -- The following Update Call is commented as the same is taken care by plan Copy APIs
 --  update_txn_table_route(p_copy_entity_txn_id);
   hr_utility.set_location('table routes updated ',25);
   begin
      update ben_copy_entity_results
      set parent_entity_result_id = p_plip_cer_id,
          gs_parent_entity_result_id = p_plip_cer_id
      where table_alias = 'COP'
      and copy_entity_txn_id = p_copy_entity_txn_id
      and parent_entity_result_id = p_pl_cer_id;
      hr_utility.set_location('oipl rows changed '||p_plip_cer_id,420);
   exception
      when others then
         hr_utility.set_location('issue in updating parent ',420);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'change_parent_plip',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
         raise;
   end;
   begin
      update ben_copy_entity_results
      set parent_entity_result_id = p_plip_cer_id,
          gs_parent_entity_result_id = p_plip_cer_id
      where table_alias = 'ELP'
      and copy_entity_txn_id = p_copy_entity_txn_id
      and parent_entity_result_id = p_pl_cer_id;
      hr_utility.set_location('ELP rows changed '||p_plip_cer_id,420);
   exception
      when others then
         hr_utility.set_location('issue in updating parent ',420);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'change_parent_plip-2',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
         raise;
   end;
end change_parent_plip;
procedure create_plip_row(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_business_group_id  in number,
                          p_grade_id           in number,
                          p_pgm_cer_id         in number,
                          p_pl_cer_id          in number default null,
                          p_grade_name         in varchar2,
                          p_plip_cer_id        out nocopy number,
                          p_plip_cer_ovn       out nocopy number) is
   l_cpp_tr_id number;
   l_cpp_tr_name varchar2(80);
   l_grd_short_name varchar2(30);
   l_grd_date_from date;
   l_grd_date_to date;
   l_ordr_num number;
begin
   get_table_route_details(p_table_alias    => 'CPP',
                           p_table_route_id => l_cpp_tr_id,
                           p_table_name     => l_cpp_tr_name);
   if p_pl_cer_id is not null then
      select information102,information307,information308
      into l_grd_short_name,l_grd_date_from,l_grd_date_to
      from ben_copy_entity_results
      where copy_entity_result_id = p_pl_cer_id;
   end if;
   begin
      select max(information263) into l_ordr_num
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = 'CPP';
      l_ordr_num := nvl(l_ordr_num,0) + 1;
      hr_utility.set_location('ord_num is '||l_ordr_num,20);
   end;
   begin
      ben_copy_entity_results_api.create_copy_entity_results(
         p_effective_date                  => p_effective_date
         ,p_copy_entity_txn_id             => p_copy_entity_txn_id
         ,p_gs_mr_src_entity_result_id     => p_pgm_cer_id
         ,p_gs_parent_entity_result_id     => p_pgm_cer_id
         ,p_mirror_src_entity_result_id    => p_pgm_cer_id
         ,p_parent_entity_result_id        => p_pgm_cer_id
         ,p_result_type_cd                 => 'DISPLAY'
         ,p_table_name                     => l_cpp_tr_name
         ,p_table_route_id                 => l_cpp_tr_id
         ,p_table_alias                    => 'CPP'
         ,p_dml_operation                  => 'INSERT'
         -- ,p_information1          => p_plip_id       -- new ben object
         ,p_information2                   => p_effective_date
         ,p_information4                   => p_business_group_id
         ,p_information5                   => p_grade_name
         ,p_information12                  => l_grd_short_name
         ,p_information104                 => 'LINK'
         ,p_information252                 => p_pl_cer_id
         ,p_information263                 => l_ordr_num
         ,p_information306                 => l_grd_date_from
         ,p_information307                 => l_grd_date_to
         ,p_copy_entity_result_id          => p_plip_cer_id
         ,p_object_version_number          => p_plip_cer_ovn);
   exception
      when others then
         hr_utility.set_location('issue in creation cpp cer '||p_grade_id,400);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'create_plip_row',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => p_effective_date);
         raise;
   end;
exception
   when others then
      hr_utility.set_location('issue in cpp cer '||p_grade_id,420);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'create_plip_row2',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => p_effective_date);
      raise;
end create_plip_row;
function get_grd_start_date(p_grade_cer_id in number) return date is
   l_start_date date;
begin
   select information307
   into l_start_date
   from ben_copy_entity_results
   where copy_entity_result_id = p_grade_cer_id;
   return l_start_date;
exception
   when others then
      hr_utility.set_location('issue in getting grd start date '||p_grade_cer_id,10);
      raise;
end get_grd_start_date;
procedure post_pull_process(p_copy_entity_txn_id in number,
                            p_start_cer          in number default null,
                            p_effective_date     in date,
                            p_business_group_id  in number,
                            p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
   cursor csr_scl is
      select copy_entity_result_id,information1
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='SCALE';
begin
   -- update_txn_table_route(p_copy_entity_txn_id);
   begin
      hr_to_stage(p_copy_entity_txn_id => p_copy_entity_txn_id,
                  p_start_cer_id       => p_start_cer,
                  p_effective_date     => p_effective_date,
                  p_business_group_id  => p_business_group_id,
                  p_business_area      => p_business_area);
   exception
      when others then
         hr_utility.set_location('issues in copying hr data on hier',30);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'post_pull_process',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => p_effective_date);
         raise;
   end;
   for scl_rec in csr_scl loop
      hr_utility.set_location('scale cer id is '||scl_rec.copy_entity_result_id,20);
      scl_writeback(p_copy_entity_txn_id => p_copy_entity_txn_id,
                    p_scale_id           => scl_rec.information1,
                    p_scale_cer_id       => scl_rec.copy_entity_result_id);
   end loop;
   PQH_PROCESS_BATCH_LOG.END_LOG;
end post_pull_process;
procedure cep_to_stage(p_cep_cer_id         in number,
                       p_copy_entity_txn_id in number) is
begin
   hr_utility.set_location('inside cep_to_stage ',10);
   update ben_copy_entity_results
   set gs_parent_entity_result_id     = parent_entity_result_id,
       gs_mirror_src_entity_result_id = mirror_src_entity_result_id
   where copy_entity_txn_id = p_copy_entity_txn_id
   and copy_entity_result_id = p_cep_cer_id
   and gs_parent_entity_result_id is null;
   hr_utility.set_location('cep_to_stage done',50);
exception
   when others then
      hr_utility.set_location('issues in updating cep row',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'cep_to_stage',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end cep_to_stage;
procedure epa_to_stage(p_epa_cer_id         in number,
                       p_copy_entity_txn_id in number) is
begin
   hr_utility.set_location('inside epa_to_stage ',10);
   update ben_copy_entity_results
   set gs_parent_entity_result_id     = parent_entity_result_id,
       gs_mirror_src_entity_result_id = mirror_src_entity_result_id
   where copy_entity_txn_id = p_copy_entity_txn_id
   and copy_entity_result_id = p_epa_cer_id
   and gs_parent_entity_result_id is null;
   hr_utility.set_location('epa_to_stage done',50);
exception
   when others then
      hr_utility.set_location('issues in updating epa row',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'epa_to_stage',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end epa_to_stage;
procedure elp_to_stage(p_elp_cer_id         in number,
                       p_copy_entity_txn_id in number,
                       p_effective_date     in date,
                       p_elpro_id           in number,
                       p_business_group_id in number) is
Cursor Cs_Cep is
Select Cep.Result_Type_cd
  From Ben_Copy_Entity_results ELP,
       Ben_Copy_Entity_Results CEP
 Where Elp.Copy_Entity_Txn_Id    = p_Copy_Entity_Txn_Id
   and Elp.Copy_Entity_Result_id = p_Elp_Cer_Id
   and Cep.Copy_Entity_Txn_Id    = Elp.Copy_Entity_Txn_id
   and Cep.Copy_Entity_Result_id = Elp.Mirror_Src_Entity_result_id
   and Elp.information1 is not null;

   L_Result_type_Cd  Ben_Copy_Entity_Results.Result_type_Cd%TYPE;
begin

    Open Cs_Cep;
   Fetch Cs_Cep into l_Result_type_Cd;
   Close cs_Cep;

   hr_utility.set_location('inside elp_to_stage ',10);
   begin
      hr_utility.set_location('updating crit rows ',15);
      update ben_copy_entity_results
      set gs_parent_entity_result_id = parent_entity_result_id,
          gs_mirror_src_entity_result_id = mirror_src_entity_result_id,
          information101 = information1,
          information1 = null
      where copy_entity_txn_id = p_copy_entity_txn_id
      and parent_entity_result_id = p_elp_cer_id;
   exception
      when others then
         hr_utility.set_location('issues in updating criteria rows ',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'elp_to_stage',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
         raise;
   end;
   begin
      hr_utility.set_location('updating elp row ',15);
      update ben_copy_entity_results
      set gs_parent_entity_result_id     = parent_entity_result_id,
          gs_mirror_src_entity_result_id = mirror_src_entity_result_id,
          Result_type_cd                 = Nvl(l_Result_type_Cd, result_type_Cd)
      where copy_entity_txn_id = p_copy_entity_txn_id
      and copy_entity_result_id = p_elp_cer_id;

      update ben_copy_entity_results
      set result_type_cd = 'NO DISPLAY'
      where copy_entity_txn_id = p_copy_entity_txn_id
      and copy_entity_result_id = p_elp_cer_id
      and table_alias = 'ELP'
      and p_Effective_Date not between information2 and information3;

      pqh_gsp_prgrules.nullify_elp_rec (
       p_copy_entity_result_id => p_elp_cer_id
      ,p_copy_entity_txn_id => p_copy_entity_txn_id
   );
   exception
      when others then
         hr_utility.set_location('issues in updating criteria rows ',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'elp_to_stage2',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
         raise;
   end;

   hr_utility.set_location('elp_to_stage done',50);

end elp_to_stage;
function get_ep_id(p_prtn_elig_prfl_id in number,
                   p_effective_date    in date) return number is
   cursor csr_elp is
   select eligy_prfl_id
   from ben_prtn_elig_prfl_f
   where p_effective_date between effective_start_date and effective_end_date
   and prtn_elig_prfl_id = p_prtn_elig_prfl_id;
   l_ep_id number;
begin
   hr_utility.set_location('getting EP for PEP'||p_prtn_elig_prfl_id,10);
   for i in csr_elp loop
       l_ep_id := i.eligy_prfl_id;
   end loop;
   return l_ep_id;
exception
   when others then
      hr_utility.set_location('issues in pulling EP for PEP',20);
      raise;
end;
function get_co_std_rate(p_plan_id        in number default null,
                         p_opt_id         in number default null,
                         p_effective_date in date,
                         p_pay_rule_id       out nocopy number) return number is
   l_abr_id number;
begin
   if p_plan_id is null and p_opt_id is null then
      hr_utility.set_location('both plan and option passed is null',10);
      return 0;
   elsif p_plan_id is not null and p_opt_id is not null then
      hr_utility.set_location('both plan and option are passed ',20);
      return 0;
   elsif p_plan_id is not null and p_opt_id is null then
      begin
         select acty_base_rt_id,pay_rate_grade_rule_id
         into l_abr_id,p_pay_rule_id
         from ben_acty_base_rt_f
         where p_effective_date between effective_start_date and effective_end_date
         and   pl_id = p_plan_id
         and   acty_typ_cd ='GSPSA'; -- we are interested only in this type
      exception
         when no_data_found then
            hr_utility.set_location('no pl rate defined '||p_plan_id,30);
         when others then
            hr_utility.set_location('issues in getting rate ',40);
            PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
            (P_MASTER_TXN_ID   => g_master_txn_id,
             P_TXN_ID          => g_txn_id,
             p_context         => 'get_co_for_abr_other',
             P_MODULE_CD       => 'PQH_GSP_BENSTG',
             P_MESSAGE_TYPE_CD => 'E',
             P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
             p_effective_date  => trunc(sysdate));
            raise;
      end;
      hr_utility.set_location('rate id is '||l_abr_id,50);
      return l_abr_id;
   elsif p_plan_id is null and p_opt_id is not null then
      begin
         select acty_base_rt_id,pay_rate_grade_rule_id
         into l_abr_id,p_pay_rule_id
         from ben_acty_base_rt_f
         where p_effective_date between effective_start_date and effective_end_date
         and   opt_id = p_opt_id
         and   acty_typ_cd ='GSPSA'; -- we are interested only in this type
      exception
         when no_data_found then
            hr_utility.set_location('no opt rate defined '||p_opt_id,30);
         when others then
            hr_utility.set_location('issues in getting rate ',40);
            PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
            (P_MASTER_TXN_ID   => g_master_txn_id,
             P_TXN_ID          => g_txn_id,
             p_context         => 'get_co_for_abr_other2',
             P_MODULE_CD       => 'PQH_GSP_BENSTG',
             P_MESSAGE_TYPE_CD => 'E',
             P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
             p_effective_date  => trunc(sysdate));
            raise;
      end;
      hr_utility.set_location('rate id is '||l_abr_id,50);
      return l_abr_id;
   end if;
end get_co_std_rate;
function get_scl_pay_rate(p_scale_id    in number) return number is
   l_pay_rate_id    number;
begin
   hr_utility.set_location('scale id is '||p_scale_id,10);
   -- if the pay rate doesn't exist with this name, no value will be set.
   select rate.rate_id
   into l_pay_rate_id
   from pay_rates rate, per_parent_spines scale
   where rate.name = scale.name
     and rate.rate_type ='SP'
     and rate.parent_spine_id = p_scale_id
     and scale.parent_spine_id = p_scale_id;
   hr_utility.set_location('rate is '||l_pay_rate_id,20);
   return l_pay_rate_id;
exception
   when no_data_found then
      hr_utility.set_location('no rate is defined '||p_scale_id,30);
      null;
   when others then
      hr_utility.set_location('issues in pulling scl pay rate'||p_scale_id,40);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_scl_pay_rate_other',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
end get_scl_pay_rate;
procedure get_step_details(p_grade_spine_id in number,
                           p_point_id       in number,
                           p_effective_date in date,
                           p_step_id        out nocopy number,
                           p_step_ovn       out nocopy number,
                           p_step_name      out nocopy number) is
begin
   hr_utility.set_location('grade scale id is '||p_grade_spine_id,1);
   hr_utility.set_location('point id is '||p_point_id,2);
   select step_id,sequence,object_version_number
   into p_step_id, p_step_name,p_step_ovn
   from per_spinal_point_steps_f
   where grade_spine_id = p_grade_spine_id
   and   spinal_point_id = p_point_id
   and   p_effective_date between effective_start_date and effective_end_date;
exception
   when no_data_found then
      hr_utility.set_location('grade scale does not have point '||p_grade_spine_id,20);
      hr_utility.set_location('point '||p_point_id,30);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_step_details_no_data',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
   when others then
      hr_utility.set_location('issues in selected step',40);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_step_details_other',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
end get_step_details;
procedure get_grade_scale_details(p_grade_id       in number,
                                  p_scale_id       in number,
                                  p_effective_date in date,
                                  p_ceiling_step_id out nocopy number,
                                  p_grade_spine_id  out nocopy number,
                                  p_starting_step out nocopy number) is
begin
   hr_utility.set_location('grade id is '||p_grade_id,1);
   hr_utility.set_location('scale id is '||p_scale_id,2);
   select ceiling_step_id,grade_spine_id,starting_step
   into p_ceiling_step_id,p_grade_spine_id,p_starting_step
   from per_grade_spines_f
   where grade_id = p_grade_id
   and parent_spine_id = p_scale_id
   and p_effective_date between effective_start_date and effective_end_date;
   hr_utility.set_location('grade scale id is '||p_grade_spine_id,10);
exception
   when no_data_found then
      hr_utility.set_location('grade scale combination does not exist '||p_grade_id,20);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_scale_details_no_data',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
   when others then
      hr_utility.set_location('issues in selected grade_spine',30);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_scale_details_other',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
end;
procedure get_point_details(p_point_id in number,
                            p_scale_id     out nocopy number,
                            p_point_seq    out nocopy number,
                            p_point_ovn    out nocopy number,
                            p_spinal_point out nocopy varchar2) is
begin
   hr_utility.set_location('point is '||p_point_id,1);
   select parent_spine_id,sequence,spinal_point,object_version_number
   into p_scale_id, p_point_seq, p_spinal_point,p_point_ovn
   from per_spinal_points
   where spinal_point_id = p_point_id;
   hr_utility.set_location('scale id is '||p_scale_id,2);
exception
   when no_data_found then
      hr_utility.set_location('point does not exist',20);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_point_details_no_data',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
   when others then
      hr_utility.set_location('issue in pulling point ',30);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_point_details_other',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
end get_point_details;
function get_point_for_step(p_step_id        in number,
                            p_effective_date in date) return number is
l_spinal_point_id number;
begin
   select spinal_point_id
   into l_spinal_point_id
   from per_spinal_point_steps_f
   where step_id = p_step_id
   and p_effective_date between effective_start_date and effective_end_date;
   hr_utility.set_location('spinal point id is'||l_spinal_point_id,10);
   return l_spinal_point_id;
exception
   when no_data_found then
      hr_utility.set_location('invalid step '||p_step_id,15);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_point_for_step_no_data',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
   when others then
      hr_utility.set_location('issues in selecting step',20);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'get_point_for_step_other',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => trunc(sysdate));
      raise;
end get_point_for_step;
function get_point_for_opt(p_option_id      in number,
                           p_effective_date in date) return number is
l_spinal_point_id number;
begin
   hr_utility.set_location('opt id is'||p_option_id,10);
   hr_utility.set_location('effdate is'||to_char(p_effective_date,'DD-MM-RRRRy'),10);
   select mapping_table_pk_id
   into l_spinal_point_id
   from ben_opt_f
   where opt_id = p_option_id
   and p_effective_date between effective_start_date and effective_end_date
   and mapping_table_name ='PER_SPINAL_POINTS';
   hr_utility.set_location('spinal point id is'||l_spinal_point_id,10);
   return l_spinal_point_id;
exception
   when no_data_found then
      hr_utility.set_location('selected option is not linked to SP'||p_option_id,15);
      return l_spinal_point_id;
   when others then
      hr_utility.set_location('issues in selecting point',20);
      raise;
end get_point_for_opt;
function get_opt_for_point(p_point_id       in number,
                           p_effective_date in date) return number is
l_opt_id number;
begin
   hr_utility.set_location('pt id is'||p_point_id,10);
   hr_utility.set_location('effdt is'||to_char(p_effective_date,'DD-MM-RRRR'),20);
   select opt_id
   into l_opt_id
   from ben_opt_f
   where mapping_table_pk_id = p_point_id
   and p_effective_date between effective_start_date and effective_end_date
   and mapping_table_name ='PER_SPINAL_POINTS';
   hr_utility.set_location('opt id is'||l_opt_id,30);
   return l_opt_id;
exception
   when no_data_found then
      hr_utility.set_location('option is not linked to point'||p_point_id,15);
      return l_opt_id;
   when others then
      hr_utility.set_location('issues in selecting option',20);
      raise;
end get_opt_for_point;
function get_grade_for_plan(p_plan_id        in number,
                            p_effective_date in date) return number is
   l_grade_id number;
begin
   select mapping_table_pk_id
   into l_grade_id
   from ben_pl_f
   where pl_id = p_plan_id
   and p_effective_date between effective_start_date and effective_end_date
   and mapping_table_name ='PER_GRADES';
   hr_utility.set_location('grade id is'||l_grade_id,10);
   return l_grade_id;
exception
   when no_data_found then
      hr_utility.set_location('selected plan is not linked to grade'||p_plan_id,15);
      return l_grade_id;
   when others then
      hr_utility.set_location('issues in selecting grade',20);
      raise;
end get_grade_for_plan;
function get_plan_for_grade(p_grade_id       in number,
                            p_effective_date in date) return number is
   l_pl_id number;
begin
   select pl_id
   into l_pl_id
   from ben_pl_f
   where mapping_table_pk_id = p_grade_id
   and p_effective_date between effective_start_date and effective_end_date
   and mapping_table_name ='PER_GRADES';
   hr_utility.set_location('plan id is'||l_pl_id,10);
   return l_pl_id;
exception
   when no_data_found then
      hr_utility.set_location('grade is not linked to plan'||p_grade_id,15);
      return l_pl_id;
   when others then
      hr_utility.set_location('issues in selecting plan',20);
      raise;
end get_plan_for_grade;
function get_oipl_for_step(p_step_id in number,
                           p_effective_date in date) return number is
   l_oipl_id number;
   l_pl_id number;
   l_opt_id number;
   l_point_id number;
   l_grade_id number;
   l_grade_spine_id number;
begin
   begin
      -- for a grade there can be only one spine
      select gs.grade_id,sps.spinal_point_id
      into l_grade_id, l_point_id
      from per_spinal_point_steps_f sps, per_grade_spines_f gs
      where sps.grade_spine_id = gs.grade_spine_id
      and p_effective_date between sps.effective_start_date and sps.effective_end_date
      and p_effective_date between gs.effective_start_date and gs.effective_end_date
      and sps.step_id = p_step_id;
   exception
      when no_data_found then
         hr_utility.set_location('invalid step '||p_step_id,20);
         raise;
      when others then
         hr_utility.set_location('issues in selecting step detail'||p_step_id,30);
         raise;
   end;
   hr_utility.set_location('grade is '||l_grade_id,10);
   hr_utility.set_location('point is '||l_point_id,15);
   l_pl_id := get_plan_for_grade(p_grade_id       => l_grade_id,
                                 p_effective_date => p_effective_date);
   hr_utility.set_location('plan is '||l_pl_id,10);
   l_opt_id := get_opt_for_point(p_point_id => l_point_id,
                                 p_effective_date => p_effective_date);
   hr_utility.set_location('option is '||l_opt_id,20);
   if l_pl_id is not null and l_opt_id is not null then
      begin
         select oipl_id
         into l_oipl_id
         from ben_oipl_f
         where pl_id = l_pl_id
         and opt_id = l_opt_id
         and p_effective_date between effective_start_date and effective_end_date;
         hr_utility.set_location('oipl is '||l_oipl_id,30);
         return l_oipl_id;
      exception
         when no_data_found then
            hr_utility.set_location('invalid oipl for pl'||l_pl_id,100);
            raise;
         when others then
            hr_utility.set_location('issues in selecting oipl detail',120);
            raise;
      end;
   else
      hr_utility.set_location('either plan or opt is null',150);
      return null;
   end if;
end get_oipl_for_step;
function get_step_for_oipl(p_oipl_id in number,
                           p_effective_date in date) return number is
   l_step_id number;
   l_pl_id number;
   l_opt_id number;
   l_point_id number;
   l_grade_id number;
   l_grade_spine_id number;
begin
   begin
      select pl_id,opt_id
      into l_pl_id,l_opt_id
      from ben_oipl_f
      where oipl_id = p_oipl_id
      and p_effective_date between effective_start_date and effective_end_date;
   exception
      when no_data_found then
         hr_utility.set_location('invalid oipl '||p_oipl_id,100);
         raise;
      when others then
         hr_utility.set_location('issues in selecting oipl detail'||p_oipl_id,120);
         raise;
   end;
   hr_utility.set_location('plan is '||l_pl_id,10);
   hr_utility.set_location('option is '||l_opt_id,20);
   l_grade_id := get_grade_for_plan(p_plan_id        => l_pl_id,
                                    p_effective_date => p_effective_date);
   hr_utility.set_location('grade is '||l_grade_id,30);
   l_point_id := get_point_for_opt(p_option_id      => l_opt_id,
                                   p_effective_date => p_effective_date);
   hr_utility.set_location('point is '||l_point_id,40);
   if l_grade_id is not null and l_point_id is not null then
      begin
         -- for a grade there can be only one spine
         select step_id
         into l_step_id
         from per_spinal_point_steps_f sps, per_grade_spines_f gs
         where sps.grade_spine_id = gs.grade_spine_id
         and p_effective_date between sps.effective_start_date and sps.effective_end_date
         and p_effective_date between gs.effective_start_date and gs.effective_end_date
         and gs.grade_id = l_grade_id
         and sps.spinal_point_id = l_point_id;
         hr_utility.set_location('step is '||l_step_id,60);
         return l_step_id;
      exception
         when no_data_found then
            hr_utility.set_location('invalid grade step comb ',60);
            raise;
         when others then
            hr_utility.set_location('issues in selecting step ',80);
            raise;
      end;
   else
      hr_utility.set_location('grade or point is null ',100);
      return null;
   end if;
end get_step_for_oipl;
procedure get_grade_for_plip(p_plip_id        in number,
                             p_effective_date in date,
                             p_plan_id           out nocopy number,
                             p_grade_id          out nocopy number) is
begin
   begin
      select pl_id
      into p_plan_id
      from ben_plip_f
      where plip_id = p_plip_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('plan is '||p_plan_id,10);
   exception
      when no_data_found then
         hr_utility.set_location('plip does not exist '||p_plip_id,10);
      when others then
         hr_utility.set_location('issues in selected plip',20);
         raise;
   end;
   if p_plan_id is not null then
      p_grade_id := get_grade_for_plan(p_plan_id        => p_plan_id,
                                       p_effective_date => p_effective_date);
      hr_utility.set_location('grade id is'||p_grade_id,40);
   end if;
end get_grade_for_plip;
procedure get_table_route_details(p_table_alias    in varchar2,
                                  p_table_route_id out nocopy number ,
                                  p_table_name     out nocopy varchar2 ) is
begin
   select table_route_id, substr(display_name,1,30)
   into p_table_route_id, p_table_name
   from pqh_table_route_vl
   where table_alias = p_table_alias;
   hr_utility.set_location('table_route name is '||p_table_name,10);
exception
   when no_data_found then
      hr_utility.set_location('no table_route is defined for this alias'||p_table_alias,10);
      null;
   when others then
      hr_utility.set_location('issues in pulling table_route details ',20);
      raise;
end get_table_route_details;
procedure update_gsp_control_rec(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
   l_grd_exists varchar2(30) := 'N';
   l_step_exists varchar2(30) := 'N';
   l_rate_exists varchar2(30) := 'N';
   l_rule_exists varchar2(30) := 'N';
   l_cpd_exists varchar2(30) := 'N';
   l_cdd_exists varchar2(30) := 'N';
   l_plip_row number;
   l_oipl_row number;
   l_rate_row number;
   l_rule_row number;
   l_ctrl_rec_cer_id number;
   l_ctrl_rec_ovn number;
begin
   hr_utility.set_location('bus area is'||p_business_area,10);
   hr_utility.set_location('cet is'||p_copy_entity_txn_id,10);
   select count(*) into l_plip_row
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias ='CPP'
   and Result_type_Cd = 'DISPLAY'
   and information104 ='LINK';  -- plip record is linked as well

   hr_utility.set_location('grade in GL'||l_plip_row,10);

   select count(*) into l_oipl_row
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias ='COP'
   and   Result_Type_Cd = 'DISPLAY';
   hr_utility.set_location('steps'||l_oipl_row,20);

   select count(*) into l_rate_row
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias = 'ABR'
   and   Result_Type_Cd = 'DISPLAY';
   hr_utility.set_location('rates'||l_rate_row,30);

   select count(*) into l_rule_row
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias ='CEP'
   and   Result_Type_Cd = 'DISPLAY';
   hr_utility.set_location('rules'||l_rule_row,40);

   if l_plip_row > 0 then
      l_grd_exists := 'Y';
   end if;
   if l_grd_exists = 'Y' then
      if l_oipl_row > 0 then
         l_step_exists := 'Y';
      end if;
      if l_rate_row > 0 then
      l_rate_exists := 'Y';
      end if;
      if l_rule_row > 0 then
         l_rule_exists := 'Y';
      end if;
   end if;
   if p_business_area = 'PQH_CORPS_TASK_LIST' then
      l_cpd_exists := pqh_cpd_hr_to_stage.check_cpd_row(p_copy_entity_txn_id);
      l_cdd_exists := pqh_cpd_hr_to_stage.check_cdd_row(p_copy_entity_txn_id);
   else
      l_cpd_exists := '';
      l_cdd_exists := '';
   end if;
   hr_utility.set_location('bus area is'||p_business_area,101);
   hr_utility.set_location('cet is'||p_copy_entity_txn_id,101);
   begin
      select copy_entity_result_id
      into l_ctrl_rec_cer_id
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = p_business_area;
      hr_utility.set_location('ctrl_rec_cer is'||l_ctrl_rec_cer_id,50);
   exception
      when no_data_found then
         hr_utility.set_location('no control rec exists',60);
         raise;
      when others then
         hr_utility.set_location('issues in updating control rec ',70);
         raise;
   end;

   begin
      update ben_copy_entity_results
      set information100    = 'Y'
      ,information101    = 'Y'
      ,information102    = l_grd_exists
      ,information103    = l_step_exists
      ,information104    = l_rate_exists
      ,information105    = l_rule_exists
      ,information106    = l_grd_exists -- review is enabled only when grade is enabled
      ,information107    = l_cpd_exists
      ,information108    = l_cdd_exists
      where copy_entity_result_id = l_ctrl_rec_cer_id;
   exception
      when others then
         hr_utility.set_location('issues in updating control rec ',80);
         raise;
   end;
end update_gsp_control_rec;
procedure create_gsp_control_rec(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
   l_table_route_id number;
   l_table_route_name varchar2(30);
   l_ctrl_rec_cer_id number;
   l_ctrl_rec_ovn number;
   l_table_alias varchar2(30);
begin
   if p_business_area in ('PQH_GSP_TASK_LIST','PQH_CORPS_TASK_LIST') then
      l_table_alias := p_business_area;
   end if;
   get_table_route_details(p_table_alias    => l_table_alias,
                           p_table_route_id => l_table_route_id,
                           p_table_name     => l_table_route_name);
   -- create a row for the control record with the values of flags for this txn.
   ben_copy_entity_results_api.create_copy_entity_results
      (p_effective_date        => p_effective_date
      ,p_copy_entity_txn_id    => p_copy_entity_txn_id
      ,p_result_type_cd        => 'DISPLAY'
      ,p_table_name            => l_table_route_name
      ,p_table_alias           => l_table_alias
      ,p_table_route_id        => l_table_route_id
      ,p_copy_entity_result_id => l_ctrl_rec_cer_id
      ,p_object_version_number => l_ctrl_rec_ovn);
   update_gsp_control_rec(p_copy_entity_txn_id => p_copy_entity_txn_id,
                          p_effective_date     => p_effective_date,
                          p_business_area      => p_business_area);
exception
   when others then
      hr_utility.set_location('issues in creating control rec ',10);
      raise;
end create_gsp_control_rec;

procedure create_gsp_control_rec(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                 p_gl_exists          in varchar2,
                                 p_sal_exists         in varchar2,
                                 p_grd_exists         in varchar2,
                                 p_step_exists        in varchar2,
                                 p_rate_exists        in varchar2,
                                 p_rule_exists        in varchar2) is
   l_table_route_id number;
   l_table_route_name varchar2(30);
   l_ctrl_rec_cer_id number;
   l_ctrl_rec_ovn number;
   l_table_alias varchar2(30);
begin
-- this is override way of creating control rec for use with GL and salary page
   if p_business_area in ('PQH_GSP_TASK_LIST','PQH_CORPS_TASK_LIST') then
      l_table_alias := p_business_area;
   end if;
   get_table_route_details(p_table_alias    => l_table_alias,
                           p_table_route_id => l_table_route_id,
                           p_table_name     => l_table_route_name);
   -- create a row for the control record with the values of flags for this txn.
   ben_copy_entity_results_api.create_copy_entity_results
      (p_effective_date                 => p_effective_date
      ,p_copy_entity_txn_id             => p_copy_entity_txn_id
      ,p_result_type_cd                 => 'DISPLAY'
      ,p_table_name                     => l_table_route_name
      ,p_table_alias                    => l_table_alias
      ,p_table_route_id                 => l_table_route_id
      ,p_information100                 => p_gl_exists
      ,p_information101                 => p_sal_exists
      ,p_information102                 => p_grd_exists
      ,p_information103                 => p_step_exists
      ,p_information104                 => p_rate_exists
      ,p_information105                 => p_rule_exists
      ,p_information106                 => p_grd_exists -- review is enabled only when grade is enabled
      ,p_copy_entity_result_id          => l_ctrl_rec_cer_id
      ,p_object_version_number          => l_ctrl_rec_ovn);
exception
   when others then
      hr_utility.set_location('issues in creating control rec ',10);
      raise;
end create_gsp_control_rec;
function get_bg_grd_pay_rate(p_business_group_id in number) return number is
   l_pay_rate_name pay_rates.name%type;
   l_pay_rate_id number;
begin
   -- for a grade there can be many pay rates, we have to find that pay rate which is
   -- having name based on lookup code
   l_pay_rate_name := hr_general.decode_lookup(p_lookup_type => 'PQH_GSP_GEN_NAME',
                                               p_lookup_code => 'GRADE_RATEGSP');
   if l_pay_rate_name is not null then
      hr_utility.set_location('pay rate name'||l_pay_rate_name,10);
      hr_utility.set_location('bg id is '||p_business_group_id,15);
      -- if the pay rate doesn't exist with this name, no value will be set.
      begin
         select rate_id
         into l_pay_rate_id
         from pay_rates
         where name = l_pay_rate_name
           and rate_type ='G'
           and business_group_id = p_business_group_id;
         hr_utility.set_location('rate is '||l_pay_rate_id,20);
         return l_pay_rate_id;
      exception
         when no_data_found then
            hr_utility.set_location('no rate is defined for this BG'||p_business_group_id,30);
            null;
         when others then
            hr_utility.set_location('issues in pulling grd pay rate'||p_business_group_id,40);
            raise;
      end;
   else
      hr_utility.set_location('pay rate is not defined ',100);
   end if;
end get_bg_grd_pay_rate;
procedure get_grade_details(p_grade_id in number,
                            p_date_from   out nocopy date,
                            p_date_to     out nocopy date,
                            p_short_name  out nocopy varchar2,
                            p_grade_name  out nocopy varchar2,
                            p_grd_ovn     out nocopy number,
                            p_grade_definition_id out nocopy number) is
begin
   hr_utility.set_location('grade id is'||p_grade_id,20);
   -- get the grade info in local variables
   select date_from, date_to, short_name, name,
          grade_definition_id, object_version_number
   into p_date_from,p_date_to,p_short_name,p_grade_name,
        p_grade_definition_id,p_grd_ovn
   from per_grades
   where grade_id = p_grade_id;
   hr_utility.set_location('grade name'||p_grade_name,20);
exception
   when no_data_found then
      hr_utility.set_location('grade doesnot exist '||p_grade_id,35);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'get_grade_details_no_data',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
   when others then
      hr_utility.set_location('issue in pulling grade details ',120);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'get_grade_details_others',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end get_grade_details;
procedure get_grd_rate_values(p_grade_id          in number,
                              p_effective_date    in date,
                              p_grd_value          out nocopy number,
                              p_grd_min            out nocopy number,
                              p_grd_mid            out nocopy number,
                              p_grd_max            out nocopy number) is
-- this procedure takes the benefit route of finding the rate value for an grade
   l_plan_id number;
   l_pay_rule_id number;
   l_abr_id number;
   l_message_text varchar2(2000);
begin
   hr_utility.set_location('grade passed is '||p_grade_id,10);
   hr_utility.set_location('effective date passed is '||to_char(p_effective_date,'DD-MM-RRRR'),20);
   l_message_text := 'grade passed is '||p_grade_id
                     ||' effective date passed is '||to_char(p_effective_date,'DD-MM-RRRR');
   l_plan_id := get_plan_for_grade(p_grade_id => p_grade_id,
                                   p_effective_date => p_effective_date);
   hr_utility.set_location('plan is '||l_plan_id,30);
   if l_plan_id is not null then
      l_abr_id := get_co_std_rate(p_plan_id => l_Plan_id,
                                  p_effective_date => p_effective_date,
                                  p_pay_rule_id    => l_pay_rule_id);
   end if;
   if l_pay_rule_id is not null then
      hr_utility.set_location('Rate passed is '||l_pay_rule_id,40);
      begin
         select value,minimum,mid_value,maximum
         into p_grd_value,p_grd_min,p_grd_mid,p_grd_max
         from pay_grade_rules_f
         where grade_rule_id = l_pay_rule_id
         and   grade_or_spinal_point_id = p_grade_id
         and   p_effective_date between effective_start_date and effective_end_date
         and   rate_type ='G';
      exception
         when no_data_found then
            hr_utility.set_location('Grade doesnot have a standard rate'||p_grade_id,100);
            null;
         when others then
            hr_utility.set_location('some issues in rate pull',120);
            raise;
      end;
   else
      hr_utility.set_location('no rate defined or issues in getting pay rule ',140);
   end if;
exception
   when others then
   PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
   (P_MASTER_TXN_ID   => g_master_txn_id,
   P_TXN_ID          => g_txn_id,
   p_context         => 'get_grd_rate_values',
   P_MODULE_CD       => 'PQH_GSP_BENSTG',
   P_MESSAGE_TYPE_CD => 'E',
   P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
   p_effective_date  => trunc(sysdate));
   raise;
end get_grd_rate_values;
procedure get_grd_rate_values(p_grade_id          in number,
                              p_business_group_id in number,
                              p_effective_date    in date,
                              p_grd_value          out nocopy number,
                              p_grd_min            out nocopy number,
                              p_grd_mid            out nocopy number,
                              p_grd_max            out nocopy number) is
-- this procedure takes the hr route of finding the rate value for an grade
-- only issue in this is pay rate name is assumed to be fixed based on lookup value
   l_grd_pay_rate_id number;
begin
   hr_utility.set_location('grade passed is '||p_grade_id,10);
   hr_utility.set_location('effective date passed is '||to_char(p_effective_date,'DD-MM-RRRR'),20);
   l_grd_pay_rate_id := get_bg_grd_pay_rate(p_business_group_id => p_business_group_id);
   if l_grd_pay_rate_id is not null then
      hr_utility.set_location('Rate passed is '||l_grd_pay_rate_id,40);
      begin
         select value,minimum,mid_value,maximum
         into p_grd_value,p_grd_min,p_grd_mid,p_grd_max
         from pay_grade_rules_f
         where rate_id = l_grd_pay_rate_id
         and   grade_or_spinal_point_id = p_grade_id
         and   p_effective_date between effective_start_date and effective_end_date
         and   rate_type ='G';
      exception
         when no_data_found then
            hr_utility.set_location('Grade doesnot have a standard rate'||p_grade_id,100);
            null;
         when others then
            hr_utility.set_location('some issues in rate pull',120);
            raise;
      end;
   else
      hr_utility.set_location('issue in getting bg grd pay rate ',120);
   end if;
exception
   when others then
   PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
   (P_MASTER_TXN_ID   => g_master_txn_id,
   P_TXN_ID          => g_txn_id,
   p_context         => 'get_grd_rate_values',
   P_MODULE_CD       => 'PQH_GSP_BENSTG',
   P_MESSAGE_TYPE_CD => 'E',
   P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
   p_effective_date  => trunc(sysdate));
   raise;
end get_grd_rate_values;
procedure get_point_rate_values(p_effective_date in date,
                                p_opt_id         in number,
                                p_point_id       in number,
                                p_point_value    out nocopy number) is
-- this procedure takes the benefit route of finding the rate value for an option
   l_pay_rule_id number;
   l_option_id number;
   l_abr_id number;
begin
   hr_utility.set_location('option is '||p_opt_id,10);
   if p_opt_id is not null then
      hr_utility.set_location('going for rates',35);
      l_abr_id := get_co_std_rate(p_opt_id         => p_opt_id,
                                  p_effective_date => p_effective_date,
                                  p_pay_rule_id    => l_pay_rule_id);
   end if;
   if l_pay_rule_id is not null then
      hr_utility.set_location('Rate passed is '||l_pay_rule_id,40);
      begin
         select value
         into p_point_value
         from pay_grade_rules_f
         where grade_rule_id = l_pay_rule_id
         and   grade_or_spinal_point_id = p_point_id
         and   p_effective_date between effective_start_date and effective_end_date
         and   rate_type ='SP';
      exception
         when no_data_found then
            hr_utility.set_location('Point doesnot have a standard rate'||p_point_id,100);
            null;
         when others then
            hr_utility.set_location('some issues in rate pull',120);
            raise;
      end;
   else
      hr_utility.set_location('issue in getting pay rate ',130);
   end if;
exception
   when others then
   PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
   (P_MASTER_TXN_ID   => g_master_txn_id,
   P_TXN_ID          => g_txn_id,
   p_context         => 'get_point_rate_values',
   P_MODULE_CD       => 'PQH_GSP_BENSTG',
   P_MESSAGE_TYPE_CD => 'E',
   P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
   p_effective_date  => trunc(sysdate));
   raise;
end get_point_rate_values;
procedure get_point_rate_values(p_effective_date in date,
                                p_point_id       in number,
                                p_point_value    out nocopy number) is
-- this procedure takes the benefit route of finding the rate value for an option
   l_pay_rule_id number;
   l_option_id number;
   l_abr_id number;
begin
   hr_utility.set_location('point passed is '||p_point_id,10);
   hr_utility.set_location('effective date passed is '||to_char(p_effective_date,'DD-MM-RRRR'),20);
   l_option_id := get_opt_for_point(p_point_id => p_point_id,
                                    p_effective_date => p_effective_date);
   hr_utility.set_location('option is '||l_option_id,30);
   get_point_rate_values(p_effective_date => p_effective_date,
                         p_opt_id         => l_option_id,
                         p_point_id       => p_point_id,
                         p_point_value    => p_point_value);
end get_point_rate_values;
procedure get_point_rate_values(p_scale_id       in number,
                                p_point_id       in number,
                                p_effective_date in date,
                                p_point_value    out nocopy number) is
-- this procedure takes the hr route of finding the rate value for an grade
-- only issue in this is pay rate name is assumed to be fixed based on scale name
   l_scl_pay_rate_id number;
begin
   hr_utility.set_location('scale passed is '||p_scale_id,10);
   hr_utility.set_location('effective date passed is '||to_char(p_effective_date,'DD-MM-RRRR'),20);
   l_scl_pay_rate_id := get_scl_pay_rate(p_scale_id => p_scale_id);
   if l_scl_pay_rate_id is not null then
      hr_utility.set_location('Rate passed is '||l_scl_pay_rate_id,40);
      begin
         select value
         into p_point_value
         from pay_grade_rules_f
         where rate_id = l_scl_pay_rate_id
         and   grade_or_spinal_point_id = p_point_id
         and   p_effective_date between effective_start_date and effective_end_date
         and   rate_type ='SP';
      exception
         when no_data_found then
            hr_utility.set_location('Point doesnot have a standard rate'||p_point_id,100);
            null;
         when others then
            hr_utility.set_location('some issues in rate pull',120);
            raise;
      end;
   else
      hr_utility.set_location('issue in getting scl pay rate ',130);
   end if;
exception
   when others then
   PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
   (P_MASTER_TXN_ID   => g_master_txn_id,
   P_TXN_ID          => g_txn_id,
   p_context         => 'get_point_rate_values',
   P_MODULE_CD       => 'PQH_GSP_BENSTG',
   P_MESSAGE_TYPE_CD => 'E',
   P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
   p_effective_date  => trunc(sysdate));
   raise;
end get_point_rate_values;
procedure get_step_all_details(p_point_id          in number,
                               p_grade_id          in number,
                               p_option_id         in number,
                               p_effective_date    in date,
                               p_point_name     out nocopy varchar2,
                               p_step_name      out nocopy varchar2,
                               p_step_id        out nocopy number,
                               p_step_ovn       out nocopy number,
                               p_grade_spine_id out nocopy number,
                               p_ceiling_flag   out nocopy varchar2,
                               p_point_value    out nocopy number,
                               p_scale_id       out nocopy number) is
   l_point_seq number;
   l_point_ovn number;
   l_ceiling_step_id number;
   l_starting_step number;
begin
   hr_utility.set_location('point id is'||p_point_id,10);
   if p_point_id is not null then
      get_point_details(p_point_id => p_point_id,
                        p_scale_id => p_scale_id,
                        p_point_seq => l_point_seq,
                        p_point_ovn => l_point_ovn,
                        p_spinal_point => p_point_name);
      hr_utility.set_location('scale id is'||p_scale_id,20);
      get_point_rate_values(p_effective_date => p_effective_date,
                            p_opt_id    => p_option_id,
                            p_point_id  => p_point_id,
                            p_point_value => p_point_value);
      hr_utility.set_location('point value is'||p_point_value,30);
   end if;
   if p_grade_id is not null and p_scale_id is not null then
      get_grade_scale_details(p_grade_id        => p_grade_id,
                              p_scale_id        => p_scale_id,
                              p_effective_date  => p_effective_date,
                              p_ceiling_step_id => l_ceiling_step_id,
                              p_grade_spine_id  => p_grade_spine_id,
                              p_starting_step   => l_starting_step);

      hr_utility.set_location('grade spine id is'||p_grade_spine_id,40);
   end if;
   if p_grade_spine_id is not null then
      get_step_details(p_grade_spine_id => p_grade_spine_id,
                       p_point_id       => p_point_id,
                       p_effective_date => p_effective_date,
                       p_step_id        => p_step_id,
                       p_step_ovn       => p_step_ovn,
                       p_step_name      => p_step_name) ;
      hr_utility.set_location('step id is'||p_step_id,50);
      if l_ceiling_step_id = p_step_id then
         p_ceiling_flag := 'Y';
      else
         p_ceiling_flag := 'N';
      end if;
   end if;
exception
   when others then
   PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
   (P_MASTER_TXN_ID   => g_master_txn_id,
   P_TXN_ID          => g_txn_id,
   p_context         => 'get_step_all_details',
   P_MODULE_CD       => 'PQH_GSP_BENSTG',
   P_MESSAGE_TYPE_CD => 'E',
   P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
   p_effective_date  => trunc(sysdate));
   raise;
end get_step_all_details;
procedure get_step_details_for_oipl(p_oipl_id        in number,
                                    p_effective_date in date,
                                    p_point_id       out nocopy number,
                                    p_point_name     out nocopy varchar2,
                                    p_step_name      out nocopy varchar2,
                                    p_step_id        in out nocopy number,
                                    p_step_ovn       out nocopy number,
                                    p_grade_id       out nocopy number,
                                    p_grade_spine_id out nocopy number,
                                    p_ceiling_flag   out nocopy varchar2,
                                    p_point_value    out nocopy number,
                                    p_scale_id       out nocopy number) is
   l_option_id number;
   l_plan_id number;
begin
-- because oipl is only in ben, we will pick plan and option and use that to get the details
   if p_step_id is null and p_oipl_id is not null then
      hr_utility.set_location('oipl_id is '||p_oipl_id,10);
      begin
         select opt_id,pl_id
         into l_option_id,l_plan_id
         from ben_oipl_f
         where oipl_id = p_oipl_id
         and p_effective_date between effective_start_date and effective_end_date;
         hr_utility.set_location('option is '||l_option_id,10);
         hr_utility.set_location('plan is '||l_plan_id,15);
      exception
         when no_data_found then
            hr_utility.set_location('oipl does not exist '||p_oipl_id,18);
            raise;
         when others then
            hr_utility.set_location('issues in selected oipl',20);
            raise;
      end;
      -- get point for option
      p_point_id := get_point_for_opt(p_option_id => l_option_id,
                                      p_effective_date => p_effective_date);
      hr_utility.set_location('spinal_point_id is'||p_point_id,40);
   -- get grade for plan
      p_grade_id := get_grade_for_plan(p_plan_id => l_plan_id,
                                       p_effective_date => p_effective_date);
      hr_utility.set_location('grade id is'||p_grade_id,50);
   elsif p_step_id is not null then
      hr_utility.set_location('step_id is '||p_step_id,10);
      begin
         select sps.spinal_point_id,gs.grade_id, gs.grade_spine_id
         into p_point_id,p_grade_id,p_grade_spine_id
         from per_spinal_point_steps_f sps, per_grade_spines_f gs
         where sps.step_id = p_step_id
         and sps.grade_spine_id = gs.grade_spine_id
         and p_effective_date between sps.effective_start_date and sps.effective_end_date
         and p_effective_date between gs.effective_start_date and gs.effective_end_date;
         hr_utility.set_location('point is '||p_point_id,10);
         hr_utility.set_location('grade is '||p_grade_id,15);
      exception
         when no_data_found then
            hr_utility.set_location('step does not exist '||p_step_id,18);
            raise;
         when others then
            hr_utility.set_location('issues in selected step',20);
            raise;
      end;
   else
      hr_utility.set_location('oipl id is null and step id is null ',10);
   end if;
   if p_point_id is not null and p_grade_id is not null then
      get_step_all_details(p_point_id       => p_point_id,
                           p_effective_date => p_effective_date,
                           p_grade_id       => p_grade_id,
                           p_option_id      => l_option_id,
                           p_point_name     => p_point_name,
                           p_step_name      => p_step_name,
                           p_step_id        => p_step_id,
                           p_step_ovn       => p_step_ovn,
                           p_grade_spine_id => p_grade_spine_id,
                           p_ceiling_flag   => p_ceiling_flag,
                           p_point_value    => p_point_value,
                           p_scale_id       => p_scale_id);
      hr_utility.set_location('details pulled',60);
   end if;
end get_step_details_for_oipl;
procedure get_co_for_abr(p_abr_id         in number,
                         p_effective_date in date,
                         p_plan_id           out nocopy number,
                         p_option_id         out nocopy number,
                         p_pay_rule_id       out nocopy number) is
begin
   select pl_id, opt_id, pay_rate_grade_rule_id
   into p_plan_id, p_option_id,p_pay_rule_id
   from ben_acty_base_rt_f
   where acty_base_rt_id = p_abr_id
   and p_effective_date between effective_start_date and effective_end_date;
   hr_utility.set_location('rate is for plan'||p_plan_id,1);
   hr_utility.set_location('rate is for opt'||p_option_id,2);
exception
   when no_data_found then
      hr_utility.set_location('no data exists '||p_abr_id,10);
      raise;
   when others then
      hr_utility.set_location('issues in pulling txn data ',20);
      raise;
end get_co_for_abr;
procedure get_grd_pay_rate_values(p_grade_id       in number,
                                  p_pay_rule_id    in number,
                                  p_effective_date in date,
                                  p_grd_value   out nocopy number,
                                  p_grd_min     out nocopy number,
                                  p_grd_mid     out nocopy number,
                                  p_grd_max     out nocopy number) is
begin
   select maximum, mid_value,minimum,value
   into p_grd_max,p_grd_mid, p_grd_min,p_grd_value
   from pay_grade_rules_f
   where grade_rule_id = p_pay_rule_id
   and rate_type ='G'
   and grade_or_spinal_point_id = p_grade_id
   and p_effective_date between effective_start_date and effective_end_date;
   hr_utility.set_location('grade value is '||p_grd_value,10);
exception
   when no_data_found then
      hr_utility.set_location('no rule exists '||p_pay_rule_id,20);
      hr_utility.set_location('as of this date'||to_char(p_effective_date,'DD-MM-RRRR'),30);
      raise;
   when others then
      hr_utility.set_location('issues in pulling grade rate data ',40);
      raise;
end get_grd_pay_rate_values;
procedure get_point_pay_rate_values(p_point_id       in number,
                                    p_pay_rule_id    in number,
                                    p_effective_date in date,
                                    p_point_value       out nocopy number) is
begin
   select value
   into p_point_value
   from pay_grade_rules_f
   where grade_rule_id = p_pay_rule_id
   and rate_type ='SP'
   and grade_or_spinal_point_id = p_point_id
   and p_effective_date between effective_start_date and effective_end_date;
   hr_utility.set_location('point value is '||p_point_value,10);
exception
   when no_data_found then
      hr_utility.set_location('no rule exists '||p_pay_rule_id,20);
      hr_utility.set_location('as of this date'||to_char(p_effective_date,'DD-MM-RRRR'),30);
      raise;
   when others then
      hr_utility.set_location('issues in pulling point rate data ',40);
      raise;
end get_point_pay_rate_values;
procedure pgm_on_stage(p_pgm_id        in number,
                       p_pgm_cer_id    in number,
                       p_copy_entity_txn_id in number) is
   l_sal_upd_flag varchar2(30);
   l_sal_update_cd varchar2(30);
   l_dflt_step_cd varchar2(30);
   l_enrt_cd varchar2(30);
   l_business_group_id number;
   l_ler_id number;
   l_rate_st_dt varchar2(30) := null;
   Cursor csr_ler_id(p_business_group_id in number)
    is
    select ler_id
    from ben_ler_f
    where business_Group_id = p_business_group_id
    and typ_cd = 'GSP'
    and lf_evt_oper_cd ='SYNC';
   Cursor csr_rate_st_dt (p_ler_id in number)
   is
   select information17
   from ben_copy_entity_results
   where table_alias = 'LEN'
   and information257 = p_ler_id
   and copy_entity_txn_id = p_copy_entity_txn_id;
begin
   hr_utility.set_location('inside pgm update ',10);
   begin
      select information16,information14,information4
      into l_sal_update_cd,l_dflt_step_cd,l_business_group_id
      from ben_copy_entity_results
      where copy_entity_result_id = p_pgm_cer_id;
      open csr_ler_id(l_business_group_id);
      fetch csr_ler_id into l_ler_id;
      if csr_ler_id%FOUND then
        open csr_rate_st_dt(l_ler_id);
        fetch csr_rate_st_dt into l_rate_st_dt;
        close csr_rate_st_dt;
      end if;
      close csr_ler_id;
   exception
      when others then
         hr_utility.set_location('issues in updating pgm ',20);
         raise;
   end;
   if nvl(l_sal_update_cd,'NO_UPDATE') = 'NO_UPDATE' then
      l_sal_upd_flag := 'N';
      l_sal_update_cd   := '';
   elsif l_sal_update_cd in ('SALARY_ELEMENT','SALARY_BASIS') then
      l_sal_upd_flag := 'Y';
   else
      hr_utility.set_location('invalid sal upd ',30);
   end if;
   if l_dflt_step_cd in ('PQH_GSP_GP','PQH_GSP_SP','PQH_GSP_NP') then
      l_enrt_cd := l_dflt_step_cd;
      l_dflt_step_cd := '';
   else
      l_enrt_cd := 'PQH_GSP_GSP';
   end if;
   hr_utility.set_location('prog_style is '||l_enrt_cd,35);
   begin
      update ben_copy_entity_results
      set information_category = 'GRADE_LADDER',
          information16 = l_sal_upd_flag,
          information51 = l_enrt_cd,
          information14 = l_dflt_step_cd,
          information71 = l_sal_update_cd,
          information53 = l_rate_st_dt,
          dml_operation = 'UPDATE'
      where copy_entity_result_id = p_pgm_cer_id;
   exception
      when others then
         hr_utility.set_location('issues in updating pgm ',40);
         raise;
   end;
   hr_utility.set_location('done pgm update ',50);
end pgm_on_stage;
procedure hrate_to_stage(p_abr_cer_id         in number,
                         p_copy_entity_txn_id in number,
                         p_effective_date     in date,
                         p_abr_id             in number,
                         p_parent_cer_id      in number) is
   l_plan_id number;
   l_option_id number;
   l_pay_rule_id number;
   l_grade_id number;
   l_point_id number;
   l_pl_cer_id number;
   l_opt_cer_id number;
begin
   hr_utility.set_location('inside standard rate ',10);
   get_co_for_abr(p_abr_id         => p_abr_id,
                  p_effective_date => p_effective_date,
                  p_plan_id        => l_plan_id,
                  p_option_id      => l_option_id,
                  p_pay_rule_id    => l_pay_rule_id);
   hr_utility.set_location('comp object selected ',20);
   if l_plan_id is not null then
      hr_utility.set_location('its plan '||l_plan_id,30);
      l_pl_cer_id := is_pl_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                         p_pl_id              => l_plan_id);
      hr_utility.set_location('pl cer is '||l_pl_cer_id,35);
      l_grade_id := get_grade_for_plan(p_plan_id        => l_plan_id,
                                       p_effective_date => p_effective_date);
      hr_utility.set_location('grade is '||l_grade_id,40);
      if l_grade_id is not null and p_abr_id is not null then
         pqh_gsp_rates.create_grade_hrrate
           (p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_effective_date     => p_effective_date,
            p_abr_id             => p_abr_id,
            p_abr_cer_id         => p_abr_cer_id,
            p_pay_rule_id        => l_pay_rule_id,
            p_grade_id           => l_grade_id);
         hr_utility.set_location('grade hrrate created ',45);
      end if;
   elsif l_option_id is not null then
      hr_utility.set_location('its point '||l_option_id,50);
      l_opt_cer_id := is_option_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                              p_opt_id             => l_option_id);
      hr_utility.set_location('opt cer is '||l_opt_cer_id,55);
      l_point_id := get_point_for_opt(p_option_id      => l_option_id,
                                      p_effective_date => p_effective_date);
      hr_utility.set_location('point is '||l_point_id,60);
      if l_point_id is not null and p_abr_id is not null then
         pqh_gsp_rates.create_point_hrrate
           (p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_effective_date     => p_effective_date,
            p_abr_id             => p_abr_id,
            p_abr_cer_id         => p_abr_cer_id,
            p_pay_rule_id        => l_pay_rule_id,
            p_point_id           => l_point_id);
         hr_utility.set_location('point hrrate created ',70);
      end if;
   end if;
   if l_pl_cer_id is null and l_opt_cer_id is null then
      hr_utility.set_location('rate is for something else',100);
   else
      begin
         update ben_copy_entity_results
         set information277 = l_pl_cer_id,
             information278 = l_opt_cer_id,
             gs_mirror_src_entity_result_id = mirror_src_entity_result_id
         where copy_entity_result_id = p_abr_cer_id;
      exception
         when others then
            hr_utility.set_location('issue in update abr with co cer',120);
            PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
            (P_MASTER_TXN_ID   => g_master_txn_id,
             P_TXN_ID          => g_txn_id,
             p_context         => 'hrate_to_stage',
             P_MODULE_CD       => 'PQH_GSP_BENSTG',
             P_MESSAGE_TYPE_CD => 'E',
             P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
             p_effective_date  => p_effective_date);
            raise;
      end;
   end if;
end hrate_to_stage;
procedure pre_pull_process(p_copy_entity_txn_id in number,
                           p_start_cer_id       in number default null,
                           p_effective_date     in date,
                           p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                           p_business_group_id  in number) is
   cursor csr_grd_scales is
      select gs.parent_spine_id scale_id,gs.grade_id grade_id
      from   ben_copy_entity_results cer, per_grade_spines_f gs
      where  copy_entity_txn_id = p_copy_entity_txn_id
        and cer.information294 = gs.grade_id
        and  table_alias = 'PLN'
        and p_effective_date between gs.effective_start_date and gs.effective_end_date
        and copy_entity_result_id > nvl(p_start_cer_id,0);
   l_scale_cer_id number;
begin
   hr_utility.set_location('inside pre-process ',10);
   hr_utility.set_location('bus_area is '||p_business_area,10);
   for i in csr_grd_scales loop
      hr_utility.set_location('copying scale for grade'||i.grade_id,20);
      populate_scale_hierarchy(p_copy_entity_txn_id => p_copy_entity_txn_id,
                               p_effective_date     => p_effective_date,
                               p_business_group_id  => p_business_group_id,
                               p_business_area      => p_business_area,
                               p_scale_id           => i.scale_id,
                               p_mode               => 'BAREBONE',
                               p_scale_cer_id       => l_scale_cer_id);
   end loop;
   hr_utility.set_location('done pre-process ',40);
end pre_pull_process;

procedure pgi_to_stage(p_pgm_id          in number,
                       p_copy_entity_txn_id in number) is

l_copy_entity_result_id number;
l_ovn number;
l_old_flag varchar2(1) := 'Y';
cursor c1 is
      SELECT pgm_extra_info_id,pgi_information1,pgi_information2,pgi_information3,pgi_information4
      FROM ben_pgm_extra_info
      where information_type ='PQH_GSP_EXTRA_INFO'
      and pgm_id = p_pgm_id;
begin
   hr_utility.set_location('pgm id is'||p_pgm_id,10);
   if p_pgm_id is not null then
   for i in c1 loop
     l_old_flag := 'N';
     BEN_COPY_ENTITY_RESULTS_API.CREATE_COPY_ENTITY_RESULTS(
             p_copy_entity_result_id                  => l_copy_entity_result_id
            ,p_copy_entity_txn_id                    => p_copy_entity_txn_id
            ,p_result_type_cd                        => 'DISPLAY'
            ,p_information_category                  => 'PQH_GSP_EXTRA_INFO'
            ,p_information11                         => i.pgi_information1
            ,p_information12                         => i.pgi_information2
            ,p_information13                         => i.pgi_information3
            ,p_information14                         => i.pgi_information4
            ,p_information174                         => i.pgm_extra_info_id
            ,p_table_name                            => 'BEN_PGM_EXTRA_INFO'
            ,p_table_alias                           => 'PGI'
            ,p_object_version_number                 => l_ovn
            ,p_effective_date                        => to_date('1900/01/01', 'RRRR/MM/DD')
            ,p_dml_operation                         => 'UPDATE'
           );
   end loop;
    if l_old_flag = 'Y' then
      BEN_COPY_ENTITY_RESULTS_API.CREATE_COPY_ENTITY_RESULTS(
             p_copy_entity_result_id                  => l_copy_entity_result_id
            ,p_copy_entity_txn_id                    => p_copy_entity_txn_id
            ,p_result_type_cd                        => 'DISPLAY'
            ,p_information_category                  => 'PQH_GSP_EXTRA_INFO'
            ,p_information11                         => 'N'
            ,p_information12                         => 'N'
            ,p_information13                         => 'GL'
            ,p_information14                         => 'AVG'
            ,p_information174                         => null
            ,p_table_name                            => 'BEN_PGM_EXTRA_INFO'
            ,p_table_alias                           => 'PGI'
            ,p_object_version_number                 => l_ovn
            ,p_effective_date                        => to_date('1900/01/01', 'RRRR/MM/DD')
            ,p_dml_operation                         => 'UPDATE'
           );
     end if;
   end if;
exception
   when no_data_found then
      hr_utility.set_location('no extra info ',10);
   when others then
      hr_utility.set_location('issues is selecting pgm extra info',10);
      raise;
end pgi_to_stage;

procedure hr_to_stage(p_copy_entity_txn_id in number,
                      p_start_cer_id       in number default null,
                      p_effective_date     in date,
                      p_business_group_id  in number,
                      p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
-- this procedure will be the callable routine and will be starting after
-- ben_to_stage has copied the data to staging table.
-- in this procedure we will traverse the hierarchy and find out what all is pulled
-- in and add HR data corresponding to it for GSP pages to work.
-- for transaction control record is to be created after all the records have been processed
-- for plan call grade_to_stage
-- for a option point_to_stage
-- for a oipl step_to_stage
-- for a plip scale_to_stage
-- for a standard rate hrate_to_stage
-- for a variable rate vrate_to_stage
-- we also have to update gs_parent_entity_result_id so that hierarchy can be used
-- except eligibility, rest of the hierarchy is same
   l_proc varchar2(61) := 'hr_to_stage' ;
   cursor csr_txn_cer is
      select copy_entity_result_id,table_alias,information1,information5,information253,
             result_type_cd,parent_entity_result_id,information261,mirror_src_entity_result_id
      from   ben_copy_entity_results
      where  copy_entity_txn_id = p_copy_entity_txn_id
        and ((table_alias in ('PGM','PLN','OPT','CPP','COP','EPA','CEP') and result_type_cd ='DISPLAY')
             or table_alias in ('ABR','AVR','ELP','VPF','VEP'))
        and copy_entity_result_id > nvl(p_start_cer_id,0)
      order by copy_entity_result_id;
   l_effective_date date;
   l_status varchar2(30);
   l_context varchar2(30);
   l_grd_exists varchar2(10) := 'N';
   l_step_exists varchar2(10) := 'N';
   l_rule_exists varchar2(10) := 'N';
   l_rate_exists varchar2(10) := 'N';
   l_grade_id number;
   l_plan_id number;
   l_pl_cer_id number;
   l_pgm_id number;
   l_pgm_cer_id number;
begin
-- for all the pln rows get the scale attached and populate it to staging area
   hr_utility.set_location('start cer is'||p_start_cer_id,5);
   pre_pull_process(p_copy_entity_txn_id => p_copy_entity_txn_id,
                    p_start_cer_id       => p_start_cer_id,
                    p_effective_date     => p_effective_date,
                    p_business_area      => p_business_area,
                    p_business_group_id  => p_business_group_id);
   for txn_cer_rec in csr_txn_cer loop
      hr_utility.set_location('inside cer loop'||txn_cer_rec.copy_entity_result_id,10);
      begin
      if txn_cer_rec.table_alias ='PLN' then
         -- it's a plan row, grade is mapped to plan
         hr_utility.set_location('its plan row ',20);
         l_grade_id := get_grade_for_plan(p_plan_id  => txn_cer_rec.information1,
                                          p_effective_date => p_effective_date);
         grade_to_pl_stage(p_grade_id       => l_grade_id,
                           p_pl_cer_id      => txn_cer_rec.copy_entity_result_id,
                           p_effective_date => p_effective_date);
         hr_utility.set_location('plan row updated',22);
      elsif txn_cer_rec.table_alias ='PGM' then
         hr_utility.set_location('its PGM row ',25);
         pgm_on_stage(p_pgm_id        => txn_cer_rec.information1,
                      p_pgm_cer_id    => txn_cer_rec.copy_entity_result_id,
		      p_copy_entity_txn_id =>p_copy_entity_txn_id);
         hr_utility.set_location('PGM row updated',28);
         l_pgm_id := txn_cer_rec.information1;
         l_pgm_cer_id := txn_cer_rec.copy_entity_result_id;
	  pgi_to_stage(p_pgm_id         => l_pgm_id,
                       p_copy_entity_txn_id => p_copy_entity_txn_id);
        hr_utility.set_location('PGI row updated',28);
      elsif txn_cer_rec.table_alias ='CPP' and txn_cer_rec.information1 is not null then
         -- it's a plip row
         hr_utility.set_location('its plip row ',30);
         get_grade_for_plip(p_plip_id        => txn_cer_rec.information1,
                            p_effective_date => p_effective_date,
                            p_plan_id        => l_plan_id,
                            p_grade_id       => l_grade_id);
         hr_utility.set_location('grade is '||l_grade_id,32);
         hr_utility.set_location('plan is '||l_plan_id,34);
         if l_plan_id is not null then
            l_pl_cer_id := is_pl_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                               p_pl_id              => l_plan_id);
            hr_utility.set_location('pl cer is'||l_pl_cer_id,10);
         end if;
         grade_to_plip_stage(p_grade_id       => l_grade_id,
                             p_plip_cer_id    => txn_cer_rec.copy_entity_result_id,
                             p_pl_cer_id      => l_pl_cer_id,
                             p_parent_cer_id  => txn_cer_rec.parent_entity_result_id,
                             p_mirror_ser_id  => txn_cer_rec.mirror_src_entity_result_id,
                             p_effective_date => p_effective_date,
                             p_business_area  => p_business_area);
         hr_utility.set_location('plip rec updated ',38);
      elsif txn_cer_rec.table_alias ='OPT' then
         -- it's a option row
         hr_utility.set_location('its option row ',40);
         point_to_opt_stage(p_copy_entity_txn_id => p_copy_entity_txn_id,
                            p_option_id          => txn_cer_rec.information1,
                            p_opt_cer_id         => txn_cer_rec.copy_entity_result_id,
                            p_effective_date     => p_effective_date,
                            p_business_area      => p_business_area,
                            p_business_group_id  => p_business_group_id);
         hr_utility.set_location('option row updated',42);
      elsif txn_cer_rec.table_alias ='COP' then
         -- it's a OIPL row
         hr_utility.set_location('its oipl row ',50);
         step_to_oipl_stage(p_copy_entity_txn_id => p_copy_entity_txn_id,
                            p_oipl_cer_id        => txn_cer_rec.copy_entity_result_id,
                            p_oipl_id            => txn_cer_rec.information1,
                            p_step_id            => txn_cer_rec.information253,
                            p_parent_cer_id      => txn_cer_rec.parent_entity_result_id,
                            p_effective_date     => p_effective_date,
                            p_business_area      => p_business_area);
         hr_utility.set_location('oipl row updated',52);
      elsif txn_cer_rec.table_alias ='ABR' then
         -- it's a Rate row
         hr_utility.set_location('its ABR row ',60);
         hrate_to_stage(p_abr_cer_id         => txn_cer_rec.copy_entity_result_id,
                        p_effective_date     => p_effective_date,
                        p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_abr_id             => txn_cer_rec.information1,
                        p_parent_cer_id      => txn_cer_rec.parent_entity_result_id);
         hr_utility.set_location('ABR row updated',62);
      elsif txn_cer_rec.table_alias ='VPF' then
         -- it's a variable rate row
         hr_utility.set_location('its VPF row ',70);
         vpf_to_stage(p_vpf_cer_id         => txn_cer_rec.copy_entity_result_id,
                      p_copy_entity_txn_id => p_copy_entity_txn_id,
                      p_effective_date     => p_effective_date,
                      p_result_type_cd     => txn_cer_rec.result_type_cd);
      elsif txn_cer_rec.table_alias ='ELP' then
         -- it's a eligibility profile row
         hr_utility.set_location('its ELP row ',80);
         elp_to_stage(p_elp_cer_id         => txn_cer_rec.copy_entity_result_id,
                      p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_effective_date    => p_effective_date,
                       p_elpro_id           => txn_cer_rec.information1,
                       p_business_group_id => p_business_group_id);
         hr_utility.set_location('ELP row updated',85);
      elsif txn_cer_rec.table_alias ='EPA' then
         hr_utility.set_location('its EPA row ',90);
         epa_to_stage(p_epa_cer_id         => txn_cer_rec.copy_entity_result_id,
                      p_copy_entity_txn_id => p_copy_entity_txn_id);
         hr_utility.set_location('Epa row updated',100);
      elsif txn_cer_rec.table_alias ='CEP' then
         hr_utility.set_location('its cep row ',110);
         cep_to_stage(p_cep_cer_id         => txn_cer_rec.copy_entity_result_id,
                      p_copy_entity_txn_id => p_copy_entity_txn_id);
         hr_utility.set_location('cep row updated',115);
      end if;
      exception
         when others then
            hr_utility.set_location('error encountered, row being skipped',420);
      end;
   end loop;
   hr_utility.set_location('done reading all rows ',120);
   if p_business_area = 'PQH_CORPS_TASK_LIST' and l_pgm_id is not null then
      pqh_cpd_hr_to_stage.corps_to_stage(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                         p_pgm_id             => l_pgm_id,
                                         p_effective_date     => p_effective_date,
                                         p_pgm_cer_id         => l_pgm_cer_id);
   end if;
   if p_start_cer_id is null then
      hr_utility.set_location('going for ctrlrec create',125);
      create_gsp_control_rec(p_copy_entity_txn_id => p_copy_entity_txn_id,
                             p_effective_date     => p_effective_date,
                             p_business_area      => p_business_area);
      hr_utility.set_location('done creating control row ',130);
   end if;
end hr_to_stage;
procedure point_to_opt_stage(p_copy_entity_txn_id in number,
                             p_option_id          in number,
                             p_opt_cer_id         in number,
                             p_effective_date     in date,
                             p_business_group_id  in number,
                             p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST') is
l_proc varchar2(61) :='point_to_opt_stage';
l_scale_id number;
l_scale_cer_id number;
l_point_id number;
l_point_seq number;
l_point_ovn number;
l_spinal_point per_spinal_points.spinal_point%type;
l_information_category varchar2(30);
l_information1 varchar2(150);
l_information2 varchar2(150);
l_information3 varchar2(150);
l_information4 varchar2(150);
l_information5 varchar2(150);
begin
   hr_utility.set_location('option is '||p_option_id,1);
   l_point_id := get_point_for_opt(p_option_id => p_option_id,
                                   p_effective_date => p_effective_date);
   hr_utility.set_location('point for option is '||l_point_id,10);
   if l_point_id is not null then
      get_point_details(p_point_id     => l_point_id,
                        p_scale_id     => l_scale_id,
                        p_point_seq    => l_point_seq,
                        p_point_ovn    => l_point_ovn,
                        p_spinal_point => l_spinal_point);
      hr_utility.set_location('point is '||l_spinal_point,20);
      hr_utility.set_location('bus_area is '||p_business_area,20);
      if p_business_area ='PQH_CORPS_TASK_LIST' then
         pqh_cpd_hr_to_stage.get_point_details(p_point_id         => l_point_id,
                                               p_information_category => l_information_category,
                                               p_information1     => l_information1,
                                               p_information2     => l_information2,
                                               p_information3     => l_information3,
                                               p_information4     => l_information4,
                                               p_information5     => l_information5);
      end if;
      if l_scale_id is not null then
         -- create scale if it doesnot exist in staging area.
         l_scale_cer_id := is_scale_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                                  p_scale_id           => l_scale_id);
         if l_scale_cer_id is null then
            hr_utility.set_location('scale not in stage,copy it',10);
            scale_to_stage(p_scale_id           => l_scale_id,
                           p_business_group_id  => p_business_group_id,
                           p_copy_entity_txn_id => p_copy_entity_txn_id,
                           p_effective_date     => p_effective_date,
                           p_business_area      => p_business_area,
                           p_scale_cer_id       => l_scale_cer_id);
         else
            hr_utility.set_location('scale is already in staging area ',15);
         end if;
         hr_utility.set_location('scale cer id is '||l_scale_cer_id,20);
      end if;
   end if;
   if p_opt_cer_id is not null then
      begin
         update ben_copy_entity_results set
                information98  = nvl(l_spinal_point,information98),
                information253 = nvl(l_point_seq,information253),
                information254 = nvl(l_point_ovn,information254),
                information255 = nvl(l_scale_id,information255),
                information256 = nvl(l_scale_cer_id,information256),
                information173 = nvl(l_information1,information173),
                information175 = nvl(l_information2,information175),
                information179 = nvl(l_information3,information179),
                information181 = nvl(l_information4,information181),
                information182 = nvl(l_information5,information182),
                information101 = nvl(l_information_category,information101)
         where copy_entity_result_id = p_opt_cer_id;
      exception
         when others then
            hr_utility.set_location('some issue in updating option row '||l_proc,120);
      end;
   else
      hr_utility.set_location('opt_cer_id is '||p_opt_cer_id,130);
   end if;
end point_to_opt_stage;
Procedure grade_to_pl_stage(p_grade_id       in number,
                            p_pl_cer_id      in number,
                            p_effective_date in date) is
--
-- this routine will be getting called when the data is to be loaded into staging area
-- ben routine will be calling this routine.
-- Data will be written into ben_copy_entity_results row provided for this purpose
--
l_proc varchar2(61) :='Grade_to_stage';
l_date_from date;
l_date_to date;
l_short_name per_grades.short_name%type;
l_grade_name per_grades.name%type;
l_grade_definition_id number;
l_grd_ovn number;
begin
   hr_utility.set_location('inside'||l_proc,10);
   if p_grade_id is not null then
      get_grade_details(p_grade_id            => p_grade_id,
                        p_date_from           => l_date_from,
                        p_date_to             => l_date_to,
                        p_short_name          => l_short_name,
                        p_grade_name          => l_grade_name,
                        p_grd_ovn             => l_grd_ovn,
                        p_grade_definition_id => l_grade_definition_id);
      hr_utility.set_location('grd name is'||substr(l_grade_name,1,40),20);
   end if;
   if p_pl_cer_id is not null then
   -- update plan row with Grade data
      begin
      -- These mappings have been taken from hrben_to_stage document ben_pl_f addition columns section.
         update ben_copy_entity_results set
                information5   = nvl(l_grade_name,information5), -- plan name is overridden by Grade Name
                information102 = nvl(l_short_name,information102),
                information221 = nvl(l_grade_definition_id,information221),
                information222 = nvl(l_grd_ovn,information222),
                information307 = nvl(l_date_from,information307),
                information308 = nvl(l_date_to,information308),
                information223 = nvl(p_grade_id,information223),
                gs_mirror_src_entity_result_id = nvl(gs_mirror_src_entity_result_id,
                                                     mirror_src_entity_result_id)
         where copy_entity_result_id = p_pl_cer_id;
      exception
         when others then
            hr_utility.set_location('some issue in updating Plan row '||l_proc,120);
      end;
   else
      hr_utility.set_location('pl_cer_id is '||p_pl_cer_id,130);
   end if;
   hr_utility.set_location('leaving '||l_proc,420);
end grade_to_pl_stage;
procedure get_grd_scale_details(p_grade_id in number,
                                p_effective_date     in date,
                                p_scale_id          out nocopy number,
                                p_ceiling_step_id   out nocopy number,
                                p_grade_spine_ovn   out nocopy number,
                                p_grade_spine_id    out nocopy number,
                                p_scale_ovn         out nocopy number,
                                p_scale_name        out nocopy varchar2,
                                p_starting_step     out nocopy number) is
begin
   -- get the scale which this grade is linked to
   hr_utility.set_location('grade id is '||p_grade_id,10);
   hr_utility.set_location('effdt is '||to_char(p_effective_date,'DD-MM-RRRR'),12);
   select psp.parent_spine_id,psp.name,gsp.ceiling_step_id,gsp.grade_spine_id,
          gsp.object_version_number,psp.object_version_number,gsp.starting_step
   into   p_scale_id,p_scale_name, p_ceiling_step_id,p_grade_spine_id,p_grade_spine_ovn,p_scale_ovn,p_starting_step
   from per_grade_spines_f gsp, per_parent_spines psp
   where gsp.grade_id = p_grade_id
   and   psp.parent_spine_id = gsp.parent_spine_id
   and   p_effective_date between gsp.effective_start_date and gsp.effective_end_date;
   hr_utility.set_location('scale name is '||p_scale_name,40);
exception
   when no_data_found then
      hr_utility.set_location('no scale is linked to grade'||p_grade_id,40);
      null;
   when others then
      hr_utility.set_location('issues in getting scale '||p_grade_id,40);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'get_grade_scl_details_others',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end get_grd_scale_details;
Procedure grade_to_plip_stage(p_grade_id       in number,
                              p_plip_cer_id    in number,
                              p_pl_cer_id      in number,
                              p_parent_cer_id  in number,
                              p_mirror_ser_id  in number,
                              p_effective_date in date,
                              p_business_area  in varchar2 default 'PQH_GSP_TASK_LIST') is
--
-- this routine will be getting called when the data is to be loaded into staging area
-- ben routine will be calling this routine.
-- Data will be written into ben_copy_entity_results row provided for this purpose
--
l_proc varchar2(61) :='grade_to_plip_stage';
l_date_from date;
l_date_to date;
l_short_name per_grades.short_name%type;
l_grade_name per_grades.name%type;
l_grade_definition_id number;
l_grd_ovn number;

l_scale_id number;
l_scale_ovn number;
l_scale_name per_parent_spines.name%type;
l_ceiling_step_id number;
l_grd_value number;
l_grd_min number;
l_grd_mid number;
l_grd_max number;
l_grade_spine_ovn number;
l_grade_spine_id number;
l_message_text varchar2(2000);
l_perc_quota number;
l_population_cd varchar2(150);
l_comb_grades varchar2(2000);
l_max_speed_quota number;
l_avg_speed_quota number;
l_corps_definition_id number;
l_cet_id number;
l_starting_step number;
l_corps_extra_info_id number;
begin
   hr_utility.set_location('inside'||l_proc,10);
   l_message_text := 'inside grade_to_plip'
                  ||' grade id is '||p_grade_id
                  ||' plip_cer_id is '||p_plip_cer_id;
   if p_grade_id is not null then
      get_grade_details(p_grade_id            => p_grade_id,
                        p_date_from           => l_date_from,
                        p_date_to             => l_date_to,
                        p_short_name          => l_short_name,
                        p_grade_name          => l_grade_name,
                        p_grd_ovn             => l_grd_ovn,
                        p_grade_definition_id => l_grade_definition_id);
      hr_utility.set_location('grade name is'||l_grade_name,20);
      -- get the scale data corresponding to the grade
      get_grd_scale_details(p_grade_id        => p_grade_id,
                            p_effective_date  => p_effective_date,
                            p_scale_id        => l_scale_id,
                            p_grade_spine_ovn => l_grade_spine_ovn,
                            p_grade_spine_id  => l_grade_spine_id ,
                            p_scale_ovn       => l_scale_ovn,
                            p_ceiling_step_id => l_ceiling_step_id,
                            p_scale_name      => l_scale_name,
                            p_starting_step   => l_starting_step);
      hr_utility.set_location('scale name is'||l_scale_name,30);
      hr_utility.set_location('starting step is'||l_starting_step,370);
      get_grd_rate_values(p_grade_id          => p_grade_id,
                          p_effective_date    => p_effective_date,
                          p_grd_value         => l_grd_value,
                          p_grd_min           => l_grd_min,
                          p_grd_mid           => l_grd_mid,
                          p_grd_max           => l_grd_max);
      hr_utility.set_location('grade value is'||l_grd_value,40);
      if p_business_area ='PQH_CORPS_TASK_LIST' then
         hr_utility.set_location('getting quota for plip',40);
         pqh_cpd_hr_to_stage.get_corp(p_pgm_cer_id => p_parent_cer_id,
                                      p_corps_id   => l_corps_definition_id,
                                      p_cet_id     => l_cet_id);
         hr_utility.set_location('corps is '||l_corps_definition_id,40);
         hr_utility.set_location('cet is '||l_cet_id,40);
         if l_corps_definition_id >0 AND l_cet_id >0 THEN
         	pqh_cpd_hr_to_stage.get_grd_quota(p_pgm_cer_id          => p_parent_cer_id,
                                           p_grade_id            => p_grade_id,
                                           p_corps_definition_id => l_corps_definition_id,
                                           p_cet_id              => l_cet_id,
                                           p_perc_quota          => l_perc_quota,
                                           p_population_cd       => l_population_cd,
                                           p_comb_grade          => l_comb_grades,
                                           p_max_speed_quota     => l_max_speed_quota,
                                           p_avg_speed_quota     => l_avg_speed_quota,
                                           p_corps_extra_info_id => l_corps_extra_info_id);
	end if;
      end if;
   end if;
   if p_plip_cer_id is not null then
      begin
         hr_utility.set_location('going for update ',40);
      hr_utility.set_location('starting step is'||l_starting_step,370);
         update ben_copy_entity_results set
                information5   = nvl(l_grade_name,information5), -- plip name is same as plan name and overridden
                information306 = nvl(l_date_from,information306),
                information307 = nvl(l_date_to,information307),
                information253 = nvl(p_grade_id,information253),
                information252 = nvl(p_pl_cer_id,information252),
                information255 = nvl(l_scale_id,information255),
                information280 = nvl(l_grade_spine_id,information280),
                information98  = nvl(l_scale_name,information98),
                information12  = nvl(l_short_name,information12),
                information259 = nvl(l_ceiling_step_id,information259),
                information298 = nvl(l_grd_value,information298),
                information287 = l_perc_quota,
                information99  = l_population_cd,
                information219 = l_comb_grades,
                information288 = l_max_speed_quota,
                information289 = l_avg_speed_quota,
                information290 = l_corps_extra_info_id,
                information291 = l_corps_definition_id,
                information228 = l_starting_step,
                information104 = 'LINK',
                gs_parent_entity_result_id = nvl(gs_parent_entity_result_id,p_parent_cer_id),
                gs_mirror_src_entity_result_id = nvl(gs_mirror_src_entity_result_id,p_mirror_ser_id),
                information281 = l_grade_spine_ovn
         where copy_entity_result_id = p_plip_cer_id;
      exception
         when others then
            hr_utility.set_location('some issue in updating Plip row '||l_proc,120);
      end;
   else
      hr_utility.set_location('plip_cer_id is '||p_plip_cer_id,130);
      hr_utility.set_location('grade_name is '||l_grade_name,140);
      hr_utility.set_location('starting step is'||l_starting_step,370);
   end if;

   hr_utility.set_location('leaving '||l_proc,420);
exception
   when others then
      hr_utility.set_location('some issues in geting grd dtl '||l_proc,120);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'grade_to_plip_stage',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end grade_to_plip_stage;
procedure step_to_oipl_stage(p_copy_entity_txn_id in number,
                             p_oipl_id            in number,
                             p_step_id            in number,
                             p_oipl_cer_id        in number,
                             p_parent_cer_id      in number,
                             p_effective_date     in date,
                             p_business_area      in varchar2) is
   l_proc varchar2(61) :='step_to_stage';
   l_point_id number;
   l_point_cer_id number;
   l_point_name per_spinal_points.spinal_point%type;
   l_step_id number;
   l_step_ovn number;
   l_step_name number;
   l_grade_id number;
   l_grade_spine_id number;
   l_scale_id number;
   l_scale_cer_id number;
   l_point_value number;
   l_ceiling_flag varchar2(10);
begin
   hr_utility.set_location('inside '||l_proc,10);
   l_step_id := p_step_id;
   if p_oipl_id is not null or l_step_id is not null then
      get_step_details_for_oipl(p_oipl_id        => p_oipl_id,
                                p_effective_date => p_effective_date,
                                p_point_id       => l_point_id,
                                p_point_name     => l_point_name,
                                p_step_name      => l_step_name,
                                p_step_id        => l_step_id,
                                p_step_ovn       => l_step_ovn,
                                p_grade_id       => l_grade_id,
                                p_grade_spine_id => l_grade_spine_id,
                                p_ceiling_flag   => l_ceiling_flag,
                                p_point_value    => l_point_value,
                                p_scale_id       => l_scale_id) ;
   end if;
   if l_scale_id is not null then
      l_scale_cer_id := is_scale_exists_in_txn
                       (p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_scale_id           => l_scale_id);
   end if;
   if l_point_id is not null then
      l_point_cer_id := is_point_exists_in_txn
                       (p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_point_id           => l_point_id);
   end if;
   if p_oipl_cer_id is not null then
      hr_utility.set_location('going for update '||l_proc,20);
      begin
         update ben_copy_entity_results set
                information253 = nvl(l_step_id, information253),
                information255 = nvl(l_grade_spine_id,information255),
                information256 = nvl(l_point_id,information256),
                information262 = nvl(l_point_cer_id,information262),
                information98  = nvl(l_ceiling_flag, information98),
                information99  = nvl(l_point_name, information99),
                information5   = nvl(l_point_name, information5),
                information263 = nvl(l_step_name, information263),
                information298 = nvl(l_point_value, information298),
                information260 = nvl(l_scale_id,information260),
                information259 = nvl(l_scale_cer_id,information259),
                information104 = 'LINK',
                gs_parent_entity_result_id = nvl(gs_parent_entity_result_id,p_parent_cer_id)
         where copy_entity_result_id = p_oipl_cer_id;
      exception
         when others then
            hr_utility.set_location('some issue in updating oipl row '||l_proc,120);
      end;
   else
      hr_utility.set_location('oipl_cer_id is '||p_oipl_cer_id,130);
   end if;
   if p_business_area = 'PQH_CORPS_TASK_LIST' and l_step_id is not null then
      pqh_cpd_hr_to_stage.pull_career_path(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                           p_step_id            => l_step_id,
                                           p_effective_date     => p_effective_date,
                                           p_grade_id           => l_grade_id);
   end if;
exception
   when others then
      hr_utility.set_location('some issues in geting grd dtl '||l_proc,120);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'step_to_oipl_stage',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end step_to_oipl_stage;
function is_hrrate_for_abr_exists(p_copy_entity_txn_id in number,
                                  p_abr_id             in number) return boolean is
   l_exists boolean := false;
   l_check varchar2(30);
begin
   select 'x'
   into l_check
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='HRRATE'
   and information299 = p_abr_id;
   if sql%found then
      l_exists := true;
   else
      l_exists := false;
   end if;
   return l_exists;
exception
   when no_data_found then
      hr_utility.set_location('no row for hrrate for abr in stage',10);
      return false;
   when too_many_rows then
      hr_utility.set_location('rows for hrrate for abr',20);
      return true;
   when others then
      hr_utility.set_location('issues is checking hrrate for abr',30);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'is_hrrate_for_abr_exists',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end is_hrrate_for_abr_exists;
procedure create_hrrate_row(p_copy_entity_txn_id in number,
                            p_effective_date     in date,
                            p_start_date         in date,
                            p_business_group_id  in number,
                            p_abr_cer_id         in number,
                            p_grade_cer_id       in number,
                            p_grd_value          in number,
                            p_grd_min_value      in number,
                            p_grd_mid_value      in number,
                            p_grd_max_value      in number,
                            p_dml_oper           in varchar2,
                            p_hrrate_cer_id      out nocopy number) is
   l_eot date := to_date('31/12/4712','DD/MM/RRRR');
   l_hrr_tr_id number;
   l_hrr_tr_name varchar2(30);
   l_pay_rate_id number;
   l_hrr_cer_ovn number;
   l_hrr_cer_id number;
   l_continue boolean := TRUE;
begin
   get_table_route_details(p_table_alias    => 'HRRATE',
                           p_table_route_id => l_hrr_tr_id,
                           p_table_name     => l_hrr_tr_name);
   hr_utility.set_location('hrrate tr name'||l_hrr_tr_name,20);
   if l_hrr_tr_name is null then
      hr_utility.set_location('hrrate tr name'||l_hrr_tr_name,45);
      l_continue := FALSE;
   end if;
   if p_copy_entity_txn_id is null then
      hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
      l_continue := FALSE;
   end if;
   if p_abr_cer_id is null then
      hr_utility.set_location('abr cer is '||p_abr_cer_id,50);
      l_continue := FALSE;
   end if;
   if l_continue then
      l_hrr_cer_id := is_hrr_exists(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                    p_grade_cer_id       => p_grade_cer_id,
                                    p_hrr_esd            => p_start_date);
      if l_hrr_cer_id is not null then
         p_hrrate_cer_id := l_hrr_cer_id;
         l_continue := FALSE;
      end if;
   end if;
   if l_continue then
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
         ,p_dml_operation          => 'INSERT'
         ,p_datetrack_mode         => 'CORRECTION'
         ,p_information2           => p_start_date
         ,p_information3           => l_eot
         ,p_information4           => p_business_group_id
         ,p_information277         => p_grade_cer_id
         ,p_information293         => l_pay_rate_id
         ,p_information294         => p_grd_min_value
         ,p_information288         => p_grd_min_value
         ,p_information295         => p_grd_max_value
         ,p_information289         => p_grd_max_value
         ,p_information296         => p_grd_mid_value
         ,p_information290         => p_grd_mid_value
         ,p_information297         => p_grd_value
         ,p_information287         => p_grd_value
         ,p_information300         => p_abr_cer_id
         ,p_copy_entity_result_id  => p_hrrate_cer_id
         ,p_object_version_number  => l_hrr_cer_ovn);
      exception
         when others then
            hr_utility.set_location('some issue in creating hrrate row ',120);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'create_hrrate_row_grd',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => p_effective_date);
            raise;
      end;
   end if;
end create_hrrate_row;

procedure create_hrrate_row(p_copy_entity_txn_id in number,
                            p_effective_date     in date,
                            p_start_date         in date,
                            p_business_group_id  in number,
                            p_abr_cer_id         in number,
                            p_point_cer_id       in number,
                            p_point_value        in number,
                            p_dml_oper           in varchar2,
                            p_hrrate_cer_id      out nocopy number) is
   l_eot date := to_date('31/12/4712','DD/MM/RRRR');
   l_hrr_tr_id number;
   l_hrr_tr_name varchar2(30);
   l_pay_rate_id number;
   l_hrr_cer_ovn number;
   l_hrr_cer_id number;
   l_continue boolean := TRUE;
begin
   get_table_route_details(p_table_alias    => 'HRRATE',
                           p_table_route_id => l_hrr_tr_id,
                           p_table_name     => l_hrr_tr_name);
   hr_utility.set_location('hrrate tr name'||l_hrr_tr_name,20);
   if l_hrr_tr_name is null then
      hr_utility.set_location('hrrate tr name'||l_hrr_tr_name,45);
      l_continue := FALSE;
   end if;
   if p_copy_entity_txn_id is null then
      hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
      l_continue := FALSE;
   end if;
   if p_abr_cer_id is null then
      hr_utility.set_location('abr cer is '||p_abr_cer_id,50);
      l_continue := FALSE;
   end if;
   if l_continue then
      l_hrr_cer_id := is_hrr_exists(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                    p_point_cer_id       => p_point_cer_id,
                                    p_hrr_esd            => p_start_date);
      if l_hrr_cer_id is not null then
         p_hrrate_cer_id := l_hrr_cer_id;
         l_continue := FALSE;
      end if;
   end if;
   if l_continue then
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
         ,p_dml_operation          => 'INSERT'
         ,p_datetrack_mode         => 'CORRECTION'
         ,p_information2           => p_start_date
         ,p_information3           => l_eot
         ,p_information4           => p_business_group_id
         ,p_information278         => p_point_cer_id
         ,p_information293         => l_pay_rate_id
         ,p_information297         => p_point_value
         ,p_information287         => p_point_value
         ,p_information300         => p_abr_cer_id
         ,p_copy_entity_result_id  => p_hrrate_cer_id
         ,p_object_version_number  => l_hrr_cer_ovn);
      exception
         when others then
            hr_utility.set_location('some issue in creating hrrate row ',120);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'create_hrrate_row_pnt',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => p_effective_date);
            raise;
      end;
   end if;
end create_hrrate_row;
procedure create_abr_row(p_copy_entity_txn_id in number,
                         p_start_date         in date,
                         p_pl_cer_id          in number default null,
                         p_opt_cer_id         in number default null,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_abr_cer_id         out nocopy number,
                         p_create_hrr         in varchar2 default 'N',
                         p_dml_oper           in varchar2) is
   l_eot date := to_date('31/12/4712','DD/MM/RRRR');
   l_abr_tr_id number;
   l_abr_tr_name varchar2(30);
   l_abr_cer_ovn number;
   l_hrr_cer_id number;
   l_continue boolean := TRUE;
begin
   if p_pl_cer_id is null and p_opt_cer_id is null then
      hr_utility.set_location('pl or opt cer is reqd',55);
      l_continue := FALSE;
   else
      p_abr_cer_id := get_abr_cer(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                  p_pl_cer_id          => p_pl_cer_id,
                                  p_opt_cer_id         => p_opt_cer_id,
                                  p_effective_date     => p_effective_date);
   end if;
   if p_abr_cer_id is null then
      get_table_route_details(p_table_alias    => 'ABR',
                              p_table_route_id => l_abr_tr_id,
                              p_table_name     => l_abr_tr_name);
      hr_utility.set_location('abr tr name'||l_abr_tr_name,20);
      if l_abr_tr_name is null then
         hr_utility.set_location('abr tr name'||l_abr_tr_name,45);
         l_continue := FALSE;
      end if;
      if p_copy_entity_txn_id is null then
         hr_utility.set_location('CET is '||p_copy_entity_txn_id,50);
         l_continue := FALSE;
      end if;
   else
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
         ,p_table_name             => l_abr_tr_name
         ,p_table_alias            => 'ABR'
         ,p_table_route_id         => l_abr_tr_id
         ,p_dml_operation          => 'INSERT'
         ,p_information2           => p_start_date
         ,p_information3           => l_eot
         ,p_information4           => p_business_group_id
         ,p_information277         => p_pl_cer_id
         ,p_information278         => p_opt_cer_id
         ,p_copy_entity_result_id  => p_abr_cer_id
         ,p_object_version_number  => l_abr_cer_ovn);
      exception
         when others then
            hr_utility.set_location('some issue in creating abr row ',120);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'create_abr_row',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => sqlerrm,
          p_effective_date  => p_effective_date);
            raise;
      end;
   end if;
   if p_abr_cer_id is not null and p_create_hrr = 'Y' then
      if p_pl_cer_id is not null then
         create_hrrate_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                           p_effective_date     => p_effective_date,
                           p_start_date         => p_start_date,
                           p_business_group_id  => p_business_group_id,
                           p_abr_cer_id         => p_abr_cer_id,
                           p_grade_cer_id       => p_pl_cer_id,
                           p_grd_value          => 0,
                           p_grd_min_value      => '',
                           p_grd_mid_value      => '',
                           p_grd_max_value      => '',
                           p_dml_oper           => 'INSERT',
                           p_hrrate_cer_id      => l_hrr_cer_id);
      elsif p_opt_cer_id is not null then
         create_hrrate_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                           p_effective_date     => p_effective_date,
                           p_start_date         => p_start_date,
                           p_business_group_id  => p_business_group_id,
                           p_abr_cer_id         => p_abr_cer_id,
                           p_point_cer_id       => p_opt_cer_id,
                           p_point_value        => 0,
                           p_dml_oper           => 'INSERT',
                           p_hrrate_cer_id      => l_hrr_cer_id);
      end if;
   end if;
end create_abr_row;
Procedure scale_to_stage(p_scale_id           in number,
                         p_business_group_id  in number,
                         p_copy_entity_txn_id in number,
                         p_effective_date     in date,
                         p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                         p_scale_cer_id          out nocopy number) is
--
-- this routine will be getting called when the scale is selected for update or for attaching.
-- Data will be written into ben_copy_entity_results row provided for this purpose
--
l_proc varchar2(61) :='Scale_to_stage';
l_scale_name per_parent_spines.name%type;
l_scale_ovn number;
l_increment_frequency per_parent_spines.increment_frequency%type;
l_bg number;
l_increment_period per_parent_spines.increment_period%type;
l_scl_tr_id number;
l_scl_tr_name ben_copy_entity_results.table_name%type;
l_scl_cer_ovn number;
l_information_category varchar2(30);
l_information1 varchar2(150);
l_information2 varchar2(150);
begin
   hr_utility.set_location('inside'||l_proc,10);
   hr_utility.set_location('bus_area is'||p_business_area,10);
   begin
      -- get the scale info in local variables
      select name, increment_frequency,business_group_id, increment_period,object_version_number
      into l_scale_name,l_increment_frequency,l_bg,l_increment_period,l_scale_ovn
      from per_parent_spines
      where parent_spine_id = p_scale_id
      and business_group_id = p_business_group_id;
      hr_utility.set_location('scale name'||l_scale_name,20);
   exception
      when others then
         hr_utility.set_location('scale doesnot exist '||p_scale_id,35);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'scale_to_stage',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => sqlerrm,
          p_effective_date  => p_effective_date);
         raise;
   end;
   if l_scale_name is not null then
      -- get the table route id and table alias
      get_table_route_details(p_table_alias    => 'SCALE',
                              p_table_route_id => l_scl_tr_id,
                              p_table_name     => l_scl_tr_name);
      hr_utility.set_location('scale tr name'||l_scl_tr_name,50);
   else
      hr_utility.set_location('no scale table route exists',55);
   end if;
   if p_business_area ='PQH_CORPS_TASK_LIST' then
      pqh_cpd_hr_to_stage.get_scale_ddf_det(p_scale_id             => p_scale_id,
                                            p_information_category => l_information_category,
                                            p_information1         => l_information1,
                                            p_information2         => l_information2);
   end if;
   if p_copy_entity_txn_id is not null and
      l_scale_name is not null and
      l_scl_tr_name is not null then
   -- create scale row in staging area
      begin
      -- These mappings have been taken from hrben_to_stage document
      -- call to create ben_cer is made here using api.
         ben_copy_entity_results_api.create_copy_entity_results
         (p_effective_date         => p_effective_date
         ,p_copy_entity_txn_id     => p_copy_entity_txn_id
         ,p_result_type_cd         => 'DISPLAY'
         ,p_table_name             => l_scl_tr_name
         ,p_table_alias            => 'SCALE'
         ,p_table_route_id         => l_scl_tr_id
         ,p_information1           => p_scale_id
         ,p_information4           => l_bg
         ,p_information5           => l_scale_name
         ,p_information254         => l_scale_ovn
         ,p_information253         => l_increment_frequency
         ,p_information98          => l_scale_name
         ,p_information99          => l_increment_period
         ,p_information101         => l_information_category
         ,p_information112         => l_information1
         ,p_information113         => l_information2
         ,p_copy_entity_result_id  => p_scale_cer_id
         ,p_object_version_number  => l_scl_cer_ovn);
      exception
         when others then
            hr_utility.set_location('some issue in creating scale row '||l_proc,120);
            raise;
      end;
   else
      hr_utility.set_location('p_copy_entity_txn_id is '||p_copy_entity_txn_id,130);
      hr_utility.set_location('l_scale_name is '||l_scale_name,140);
      hr_utility.set_location('l_scl_tr_name is '||l_scl_tr_name,140);
   end if;
end Scale_to_stage;
function get_current_max_cer(p_copy_entity_txn_id in number) return number is
   l_max_cer_id number;
begin
   select max(copy_entity_result_id)
   into l_max_cer_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id;
   hr_utility.set_location('max cer is'||l_max_cer_id,10);
   return l_max_cer_id;
exception
   when others then
      hr_utility.set_location('issue in getting max cer',40);
      raise;
end get_current_max_cer;
procedure update_txn_table_route(p_copy_entity_txn_id in number) is
   cursor tr is select table_route_id,display_name,table_alias
   from pqh_table_route
   where from_clause ='OAB';
begin
   for i in tr loop
      update ben_copy_entity_results
      set table_alias = nvl(table_alias,i.table_alias)
      , table_name = nvl(table_name,substr(i.display_name,1,30))
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_route_id = i.table_route_id;
   end loop;
end update_txn_table_route;
procedure create_txn_user(p_copy_entity_txn_id  in number,
                          p_user_id             in number,
                          p_replacement_type_cd in varchar2,
                          p_business_area       in varchar2 default 'PQH_GSP_TASK_LIST') is
   l_cea_ovn number;
   l_cea_id number;
begin
   hr_utility.set_location('creating txn user',10);
   pqh_copy_entity_attribs_api.create_copy_entity_attrib
                               (p_copy_entity_attrib_id => l_cea_id,
                                p_copy_entity_txn_id    => p_copy_entity_txn_id,
                                p_information_category  => 'PQH_GSP_TXN',
                                p_information1          => 'UGL',
                                p_row_type_cd           => 'GSP',
                                p_information7          => p_user_id,
                                p_information8          => p_replacement_type_cd,
                                p_information9          => p_business_area,
                                p_object_version_number => l_cea_ovn,
                                p_effective_date        => trunc(sysdate));
   hr_utility.set_location('cea '||l_cea_id,20);
exception
   when others then
      hr_utility.set_location('issues in creating txn user',30);
      raise;
end create_txn_user;
procedure update_or_view_GL(p_calling_mode       in varchar2,
                            p_action_type        in varchar2 default 'REFRESH',
                            p_pgm_id             in number,
                            p_pgm_name           in varchar2,
                            p_effective_date     in date,
                            p_business_group_id  in number,
                            p_user_id            in number,
                            p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                            p_copy_entity_txn_id out nocopy number ) is
   cursor csr_txns is select txn.copy_entity_txn_id
                from pqh_copy_entity_txns txn, ben_copy_entity_results cer
                where txn.context_business_group_id = p_business_group_id
                and   txn.status ='VIEW'
                and   txn.context ='GSP'
                and   cer.copy_entity_txn_id = txn.copy_entity_txn_id
                and   cer.information1 = p_pgm_id
                and   cer.table_alias = 'PGM';
   l_cet_id number;
   l_cet_ovn number;
   l_txn_name varchar2(100);
begin
   if p_calling_mode ='U' then
      hr_utility.set_location('calling for update with'||p_pgm_name,10);
      update_GL(p_pgm_id             => p_pgm_id,
                p_pgm_name           => p_pgm_name,
                p_effective_date     => p_effective_date,
                p_business_group_id  => p_business_group_id,
                p_action_type        => p_action_type,
                p_user_id            => p_user_id,
                p_business_area      => p_business_area,
                p_copy_entity_txn_id => p_copy_entity_txn_id);
   elsif p_calling_mode ='V' then
      hr_utility.set_location('calling for view',15);
      open csr_txns;
      fetch csr_txns into l_cet_id;
      if csr_txns%found then
         --close csr_txns;
         hr_utility.set_location('deleting details',20);
         --pqh_gsp_utility.del_gl_details_from_stage(p_pqh_copy_entity_txn_id => l_cet_id);
        pqh_gsp_utility.delete_transaction(p_pqh_copy_entity_txn_id =>l_cet_id);

      end if;
         close csr_txns;
         l_txn_name := pqh_gsp_utility.gen_txn_display_name
                                      (p_program_name => p_pgm_name,
                                       p_mode         => 'V');
         hr_utility.set_location('starting cet row ',30);
         start_gsp_txn(p_copy_entity_txn_id    => l_cet_id
                      ,p_business_group_id     => p_business_group_id
                      ,p_name                  => p_pgm_name
                      ,p_effective_date        => p_effective_date
                      ,p_status                => 'VIEW'
                      ,p_object_version_number => l_cet_ovn);
--      end if;
      hr_utility.set_location('populating pgm hier for cet '||l_cet_id,40);
      PQH_GSP_PROCESS_LOG.START_LOG
      (P_TXN_ID    => p_pgm_id,
      P_TXN_NAME  => p_pgm_name,
      P_MODULE_CD => 'PQH_GSP_BENSTG');
      g_master_txn_id := p_pgm_id;
      g_txn_id := p_pgm_id;
      populate_pgm_hierarchy(p_copy_entity_txn_id => l_cet_id,
                             p_effective_date     => p_effective_date,
                             p_business_group_id  => p_business_group_id,
                             p_business_area      => p_business_area,
                             p_pgm_id             => p_pgm_id);
      hr_utility.set_location('done populating pgm hier ',50);
      p_copy_entity_txn_id := l_cet_id;
   else
      hr_utility.set_location('invalid mode passed '||p_calling_mode,100);
   end if;
end update_or_view_gl;
procedure update_GL(p_pgm_id             in number,
                    p_action_type        in varchar2 default 'REFRESH',
                    p_pgm_name           in varchar2,
                    p_effective_date     in date,
                    p_business_group_id  in number,
                    p_user_id            in number,
                    p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                    p_copy_entity_txn_id out nocopy number ) is
   cursor csr_txns is select txn.copy_entity_txn_id
                from pqh_copy_entity_txns txn, ben_copy_entity_results cer,
                     pqh_copy_entity_attribs attr
                where txn.context_business_group_id = p_business_group_id
                and   attr.copy_entity_txn_id = txn.copy_entity_txn_id
--changes for bug no 6030246 starts here
--                and   attr.information7 = p_user_id
                and   attr.information7 = to_char(p_user_id)
--changes for bug no 6030246 ends here
                and   txn.status ='SFL'
                and   txn.context ='GSP'
                and   cer.copy_entity_txn_id = txn.copy_entity_txn_id
                and   cer.information1 = p_pgm_id
                and   cer.table_alias = 'PGM';

   l_rec_found boolean := FALSE;
   l_user_name fnd_user.user_name%type;
   l_txn_name pqh_copy_entity_txns.display_name%type;
   l_cet_ovn number;
   l_copy_entity_txn_id number;
begin
-- when Grade ladder is selected for Update following things are to be done
-- 1) check all the rows in staging area having this pgm in staging area
-- 2) if this pgm is in staging area open for update then
-- 3) get the user who has it
-- 4) if not then create a cet row.
-- 5) call populate_pgm_hierarchy
   hr_utility.set_location('inside update '||p_pgm_id,10);
   for txn_rec in csr_txns loop
       l_rec_found := TRUE;
       hr_utility.set_location('inside loop',15);
       l_copy_entity_txn_id := txn_rec.copy_entity_txn_id;
   end loop;
   if l_copy_entity_txn_id is not null then
      hr_utility.set_location('stage has data',16);
      if p_action_type ='REFRESH' then
         hr_utility.set_location('staging data to be refreshed',18);
         pqh_gsp_utility.delete_transaction(p_pqh_copy_entity_txn_id => l_copy_entity_txn_id);
         l_rec_found := FALSE;
      elsif p_action_type ='CONTINUE' then
         hr_utility.set_location('staging data to be used',18);
         p_copy_entity_txn_id := l_copy_entity_txn_id;
      else
         hr_utility.set_location('cet_id will be going null ',19);
      end if;
   else
      hr_utility.set_location('nothing in staging',18);
   end if;
   if not l_rec_found then
      -- create txn_name
      l_txn_name := pqh_gsp_utility.gen_txn_display_name
                                    (p_program_name => p_pgm_name,
                                     p_mode         => 'U');
      -- create txn
      start_gsp_txn(p_copy_entity_txn_id    => l_copy_entity_txn_id
                   ,p_business_group_id     => p_business_group_id
                   ,p_name                  => l_txn_name
                   ,p_effective_date        => p_effective_date
                   ,p_status                => 'SFL'
                   ,p_business_area         => p_business_area
                   ,p_object_version_number => l_cet_ovn);
      p_copy_entity_txn_id := l_copy_entity_txn_id;
      PQH_GSP_PROCESS_LOG.START_LOG
      (P_TXN_ID    => p_copy_entity_txn_id,
      P_TXN_NAME  => p_pgm_name,
      P_MODULE_CD => 'PQH_GSP_BENSTG');
      g_master_txn_id := p_copy_entity_txn_id;
      g_txn_id        := p_copy_entity_txn_id;
      -- populate hierarchy
      populate_pgm_hierarchy(p_copy_entity_txn_id => l_copy_entity_txn_id,
                             p_effective_date     => p_effective_date,
                             p_business_group_id  => p_business_group_id,
                             p_business_area      => p_business_area,
                             p_pgm_id             => p_pgm_id);
      -- create txn user row
      create_txn_user(p_copy_entity_txn_id  => l_copy_entity_txn_id,
                      p_user_id             => p_user_id,
                      p_replacement_type_cd => 'UPD',
                      p_business_area       => p_business_area);
   end if;
end update_GL;
procedure start_gsp_txn(p_copy_entity_txn_id    out nocopy number
                       ,p_business_group_id     in number
                       ,p_name                  in varchar2
                       ,p_effective_date        in date
                       ,p_status                in varchar2
                       ,p_business_area         in varchar2 default 'PQH_GSP_TASK_LIST'
                       ,p_object_version_number out nocopy number) is
   l_gsp_txn_cat number;
   l_error boolean := TRUE;
begin
   if p_status in ('VIEW','SFL') then
      l_error := FALSE;
   else
      hr_utility.set_location('invalid status passed',10);
      l_error := TRUE;
   end if;
   if not l_error then
      select transaction_category_id
      into l_gsp_txn_cat
      from pqh_transaction_categories
      where short_name ='PQHGSP'
      and business_group_id is null;
   end if;
   if l_gsp_txn_cat is not null then
      begin
         pqh_copy_entity_txns_api.create_COPY_ENTITY_TXN
           (p_copy_entity_txn_id             => p_copy_entity_txn_id
           ,p_transaction_category_id        => l_gsp_txn_cat
           ,p_context_business_group_id      => p_business_group_id
           ,p_context                        => 'GSP'
           ,p_action_date                    => p_effective_date
           ,p_src_effective_date             => p_effective_date
           ,p_number_of_copies               => 1
           ,p_display_name                   => p_name
           ,p_replacement_type_cd            => 'NONE'
           ,p_start_with                     => p_business_area
           ,p_status                         => p_status
           ,p_object_version_number          => p_object_version_number
           ,p_effective_date                 => p_effective_date
           ) ;
       exception
          when others then
             hr_utility.set_location('issues in creating CET row',100);
             raise;
       end;
   end if;
end start_gsp_txn;
procedure populate_pgm_hierarchy(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_group_id  in number,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                 p_pgm_id             in number) is
   l_copy_entity_result_id number;
   l_cer_ovn number;
begin
   begin
      BEN_PLAN_DESIGN_TXNS_API.create_plan_design_result
       (p_copy_entity_result_id => l_copy_entity_result_id
       ,p_copy_entity_txn_id    => p_copy_entity_txn_id
       ,p_pgm_id                => p_pgm_id
       ,p_business_group_id     => p_business_group_id
       ,p_number_of_copies      => 1
       ,p_object_version_number => l_cer_ovn
       ,p_effective_date        => p_effective_date
       ,p_no_dup_rslt           => 'Y'
       ) ;
   exception
      when others then
         hr_utility.set_location('issues in copying pgm hier',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'populate_pgm_hierarchy',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => p_effective_date);
         raise;
   end;
   post_pull_process(p_copy_entity_txn_id => p_copy_entity_txn_id,
                     p_effective_date     => p_effective_date,
                     p_business_group_id  => p_business_group_id,
                     p_business_area      => p_business_area);
end populate_pgm_hierarchy;
function is_scale_exists_in_txn(p_copy_entity_txn_id in number,
                                p_scale_id           in number) return number is
   l_scl_cer_id number;
   cursor csr_scale is
   select copy_entity_result_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='SCALE'
   and information1 = p_scale_id;
begin
   hr_utility.set_location('checking scale'||p_scale_id,10);
   for i in csr_scale loop
      l_scl_cer_id := i.copy_entity_result_id;
   end loop;
   return l_scl_cer_id;
exception
   when others then
      hr_utility.set_location('issues in checking scale ',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'is_scale_exists_in_txn',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end is_scale_exists_in_txn;
function is_grd_exists_in_txn(p_copy_entity_txn_id in number,
                              p_grd_id              in number) return number is
   l_grd_cer_id number;
   cursor csr_grd is
   select copy_entity_result_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='PLN'
   and information223 = p_grd_id;
begin
   hr_utility.set_location('checking grd'||p_grd_id,10);
   for i in csr_grd loop
      l_grd_cer_id := i.copy_entity_result_id;
   end loop;
   return l_grd_cer_id;
exception
   when others then
      hr_utility.set_location('issues in finding grade ',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'is_grd_exists_in_txn',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end is_grd_exists_in_txn;
function is_plip_exists_in_txn(p_copy_entity_txn_id in number,
                               p_pl_cer_id          in number,
                               p_grade_id           in number) return number is
   l_plip_cer_id number;
begin
   hr_utility.set_location('pl_cer'||p_pl_cer_id,10);
   hr_utility.set_location('grd'||p_grade_id,15);
   if p_grade_id is not null then
      select copy_entity_result_id
      into l_plip_cer_id
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='CPP'
      and information253 = p_grade_id;
   else
      select copy_entity_result_id
      into l_plip_cer_id
      from ben_copy_entity_results
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias ='CPP'
      and information252 = p_pl_cer_id;
   end if;
   hr_utility.set_location('plip_cer'||l_plip_cer_id,20);
   return l_plip_cer_id;
exception
   when no_data_found then
      hr_utility.set_location('issues in finding plip ',30);
      return l_plip_cer_id;
   when others then
      hr_utility.set_location('issues in finding plip ',30);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'is_plip_exists_in_txn',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end is_plip_exists_in_txn;
function is_pl_exists_in_txn(p_copy_entity_txn_id in number,
                             p_pl_id              in number) return number is
   l_pl_cer_id number;
   cursor csr_pln is
   select copy_entity_result_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='PLN'
   and information1 = p_pl_id;
begin
   hr_utility.set_location('checking pl'||p_pl_id,10);
   for i in csr_pln loop
      l_pl_cer_id := i.copy_entity_result_id;
   end loop;
   return l_pl_cer_id;
exception
   when others then
      hr_utility.set_location('issues in finding plan ',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'is_pl_exists_in_txn',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end is_pl_exists_in_txn;
function is_ep_exists_in_txn(p_copy_entity_txn_id in number,
                             p_start_cer          in number,
                             p_ep_id              in number) return number is
   l_ep_cer_id number;
   cursor csr_epn is
   select copy_entity_result_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='ELP'
   and copy_entity_result_id > p_start_cer
   and (information1 = p_ep_id OR information101 = p_ep_id) ;
begin
   hr_utility.set_location('checking EP'||p_ep_id,10);
   for i in csr_epn loop
      l_ep_cer_id := i.copy_entity_result_id;
   end loop;
   return l_ep_cer_id;
exception
   when others then
      hr_utility.set_location('issues in finding EP ',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'is_ep_exists_in_txn',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end is_ep_exists_in_txn;
function is_option_exists_in_txn(p_copy_entity_txn_id in number,
                                 p_opt_id             in number) return number is
   l_opt_cer_id number;
   cursor csr_opt is
   select copy_entity_result_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='OPT'
   and information1 = p_opt_id;
begin
   for i in csr_opt loop
       l_opt_cer_id := i.copy_entity_result_id;
   end loop;
   return l_opt_cer_id;
exception
   when others then
      hr_utility.set_location('issues in copying opt hier',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'is_opt_exists_in_txn',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end is_option_exists_in_txn;
function is_point_exists_in_txn(p_copy_entity_txn_id in number,
                                p_point_id           in number) return number is
   l_pt_cer_id number;
   cursor csr_opt is
   select copy_entity_result_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='OPT'
   and information257 = p_point_id;
begin
   for i in csr_opt loop
       l_pt_cer_id := i.copy_entity_result_id;
   end loop;
   return l_pt_cer_id;
exception
   when others then
      hr_utility.set_location('issues in finding point ',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'is_pnt_exists_in_txn',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end is_point_exists_in_txn;
function is_step_exists_in_txn(p_copy_entity_txn_id in number,
                               p_step_id            in number,
                               p_option_id          in number,
                               p_pl_id              in number) return number is
   l_oipl_cer_id number;
   cursor csr_oipl is
   select copy_entity_result_id
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and table_alias ='COP'
   and information253 = p_step_id;
begin
   if p_option_id is not null and p_pl_id is not null then
      begin
         hr_utility.set_location('checking oipl ofr opt '||p_option_id,10);
         hr_utility.set_location('checking oipl for pl '||p_pl_id,12);
         select copy_entity_result_id
         into l_oipl_cer_id
         from ben_copy_entity_results
         where copy_entity_txn_id = p_copy_entity_txn_id
         and table_alias ='COP'
         and information247 = p_option_id
         and information261 = p_pl_id;
     exception
         when no_data_found then
            hr_utility.set_location('oipl doesnot exist',20);
            return l_oipl_cer_id;
         when others then
            hr_utility.set_location('issues in finding point ',20);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'is_step_exists_in_txn',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
            raise;
     end;
   else
      hr_utility.set_location('checking oipl ofr step '||p_step_id,30);
      for i in csr_oipl loop
          l_oipl_cer_id := i.copy_entity_result_id;
      end loop;
   end if;
   return l_oipl_cer_id;
exception
   when others then
      hr_utility.set_location('issues in finding oipl ',40);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'is_step_exists_in_txn2',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => trunc(sysdate));
      raise;
end is_step_exists_in_txn;
procedure populate_opt_hierarchy(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_group_id  in number,
                                 p_opt_id             in number,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                 p_opt_cer_id         out nocopy number) is
   l_copy_entity_result_id number;
   l_cer_ovn number;
   l_start_cer number;
begin
   p_opt_cer_id := is_option_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                           p_opt_id             => p_opt_id);
   hr_utility.set_location('opt cer is'||p_opt_cer_id,10);
   if p_opt_cer_id is null then
      hr_utility.set_location('opt not in staging area, going for copy ',15);
      l_start_cer:= get_current_max_cer(p_copy_entity_txn_id );
      begin
         ben_plan_design_plan_module.create_opt_result
         (p_copy_entity_result_id     => l_copy_entity_result_id
          ,p_copy_entity_txn_id       => p_copy_entity_txn_id
          ,p_opt_id                   => p_opt_id
          ,p_business_group_id        => p_business_group_id
          ,p_number_of_copies         => 1
          ,p_object_version_number    => l_cer_ovn
          ,p_effective_date           => p_effective_date
          ,p_parent_entity_result_id  => l_copy_entity_result_id
          ,p_no_dup_rslt              => 'Y'
         );
         hr_utility.set_location('copied opt hier',20);
      exception
         when others then
            hr_utility.set_location('issues in copying opt hier',25);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'populate_opt_hierarchy',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => p_effective_date);
            raise;
      end;
      post_pull_process(p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_start_cer          => l_start_cer,
                        p_effective_date     => p_effective_date,
                        p_business_group_id  => p_business_group_id,
                        p_business_area      => p_business_area);
      p_opt_cer_id := is_option_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                              p_opt_id             => p_opt_id);
      if p_opt_cer_id is null then
         hr_utility.set_location('issues in copying option',50);
      else
         hr_utility.set_location('opt cer is'||p_opt_cer_id,55);
      end if;
   else
      hr_utility.set_location('opt exists and cer is'||p_opt_cer_id,65);
   end if;
end populate_opt_hierarchy;
procedure populate_grd_hierarchy(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_group_id  in number,
                                 p_grade_id           in number,
                                 p_grade_name         in varchar2,
                                 p_pgm_cer_id         in number,
                                 p_in_pl_cer_id       in number,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                 p_out_pl_cer_id      out nocopy number,
                                 p_plip_cer_id        out nocopy number,
                                 p_scale_cer_id       out nocopy number) is
   cursor csr_grd_scale is
      select parent_spine_id
      from per_grade_spines_f
      where p_effective_date between effective_start_date and effective_end_date
      and grade_id = p_grade_id;
   cursor csr_grd_steps is
      select sps.step_id,sps.spinal_point_id,sps.object_version_number,gs.grade_spine_id
      from per_spinal_point_steps_f sps, per_grade_spines_f gs
      where p_effective_date between sps.effective_start_date and sps.effective_end_date
      and gs.grade_spine_id = sps.grade_spine_id
      and p_effective_date between gs.effective_start_date and gs.effective_end_date
      and gs.grade_id = p_grade_id;
   l_pl_cer_ovn number;
   l_grade_scale_id number;
   l_pl_id number;
   l_oipl_cer_id number;
   l_opt_cer_id number;
   l_start_cer number;
   l_option_id number;
   l_plip_cer_ovn number;
begin
   hr_utility.set_location('populating grade'||p_grade_id,10);
   PQH_GSP_PROCESS_LOG.START_LOG
     (P_TXN_ID    => Nvl(p_grade_id,p_in_pl_cer_id) ,
      P_TXN_NAME  => p_grade_name,
      P_MODULE_CD => 'PQH_GSP_BENSTG');
   g_master_txn_id := Nvl(p_grade_id, P_in_Pl_Cer_id);
   g_txn_id        := Nvl(p_grade_id, P_In_Pl_Cer_Id);
   l_start_cer:= get_current_max_cer(p_copy_entity_txn_id );
   if p_grade_id is not null then
      l_pl_id := get_plan_for_grade(p_grade_id       => p_grade_id,
                                    p_effective_date => p_effective_date);
   end if;
   -- check for plip existence
   p_plip_cer_id := is_plip_exists_in_txn
                      (p_copy_entity_txn_id => p_copy_entity_txn_id,
                       p_pl_cer_id          => p_in_pl_cer_id,
                       p_grade_id           => p_grade_id);
   if p_plip_cer_id is null then
      create_plip_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                      p_effective_date     => p_effective_date,
                      p_business_group_id  => p_business_group_id,
                      p_grade_id           => p_grade_id,
                      p_pgm_cer_id         => p_pgm_cer_id,
                      p_grade_name         => p_grade_name,
                      p_pl_cer_id          => p_in_pl_cer_id,
                      p_plip_cer_id        => p_plip_cer_id,
                      p_plip_cer_ovn       => l_plip_cer_ovn);
   end if;
   if l_pl_id is not null then
      hr_utility.set_location('grade is linked to plan'||l_pl_id,20);
      populate_pl_hierarchy(p_copy_entity_txn_id => p_copy_entity_txn_id,
                            p_effective_date     => p_effective_date,
                            p_business_group_id  => p_business_group_id,
                            p_plip_cer_id        => p_plip_cer_id,
                            p_pl_id              => l_pl_id,
                            p_mode               => 'BAREBONE',
                            p_business_area      => p_business_area,
                            p_pl_cer_id          => p_out_pl_cer_id);
      hr_utility.set_location('pl hier populated '||p_out_pl_cer_id,30);
   else
      hr_utility.set_location('grade not linked ',40);
      if p_grade_id is not null then
         p_out_pl_cer_id := is_grd_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                                 p_grd_id             => p_grade_id);
         if p_out_pl_cer_id is null then
            hr_utility.set_location('grade not in stage'||p_grade_id,42);
            create_plan_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                            p_effective_date     => p_effective_date,
                            p_business_group_id  => p_business_group_id,
                            p_grade_id           => p_grade_id,
                            p_plip_cer_id        => p_plip_cer_id,
                            p_dml_operation      => 'COPIED',
                            p_pl_cer_id          => p_out_pl_cer_id,
                            p_pl_cer_ovn         => l_pl_cer_ovn);
            hr_utility.set_location('plan row created for grade'||p_out_pl_cer_id,45);
         else
            hr_utility.set_location('pl cer is'||p_out_pl_cer_id,48);
         end if;
      else
         hr_utility.set_location('pl cer is updating with plip'||p_in_pl_cer_id,48);
         begin
            update ben_copy_entity_results
            set gs_mirror_src_entity_result_id = p_plip_cer_id,
                mirror_src_entity_result_id = p_plip_cer_id,
                information104 = ''
            where copy_entity_result_id = p_in_pl_cer_id;
         exception
            when others then
               hr_utility.set_location('pl cer is'||p_in_pl_cer_id,48);
               raise;
         end;
      end if;
   end if;
   if p_grade_id is not null then
      hr_utility.set_location('going for grade details update on plip ',49);
      grade_to_plip_stage(p_grade_id       => p_grade_id,
                          p_plip_cer_id    => p_plip_cer_id,
                          p_pl_cer_id      => p_out_pl_cer_id,
                          p_parent_cer_id  => p_pgm_cer_id,
                          p_mirror_ser_id  => p_pgm_cer_id,
                          p_effective_date => p_effective_date,
                          p_business_area  => p_business_area);
      hr_utility.set_location('plip updated with Grade ',50);
      hr_utility.set_location('going for grade components ',50);
      for i in csr_grd_scale loop
         -- copy the attached scale to stage
         l_grade_scale_id := i.parent_spine_id;
         populate_scale_hierarchy(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                  p_effective_date     => p_effective_date,
                                  p_business_group_id  => p_business_group_id,
                                  p_scale_id           => i.parent_spine_id,
                                  p_mode               => 'BAREBONE',
                                  p_business_area      => p_business_area,
                                  p_scale_cer_id       => p_scale_cer_id);
      end loop;
      hr_utility.set_location('scale populated if any'||p_scale_cer_id,55);
   -- now plan and options are in staging area, we have to check whether oipl exists in stage
   -- or not corresponding to the step in HR
      if l_grade_scale_id is not null then
         for grd_step in csr_grd_steps loop
            hr_utility.set_location('point passed is '||grd_step.spinal_point_id,22);
            l_option_id := get_opt_for_point(p_point_id       => grd_step.spinal_point_id,
                                             p_effective_date => p_effective_date);
            hr_utility.set_location('option is '||l_option_id,30);
            hr_utility.set_location('creating step of Grade '||grd_step.step_id,60);
            l_oipl_cer_id := is_step_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                                   p_step_id            => grd_step.step_id,
                                                   p_option_id          => l_option_id,
                                                   p_pl_id              => l_pl_id);
            if l_oipl_cer_id is null then
               hr_utility.set_location('step doesnot exist, create it',70);
               l_opt_cer_id := is_point_exists_in_txn
                              (p_copy_entity_txn_id => p_copy_entity_txn_id,
                               p_point_id           => grd_step.spinal_point_id);
               hr_utility.set_location('opt cer is '||l_opt_cer_id,35);
               create_oipl_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                               p_effective_date     => p_effective_date,
                               p_business_group_id  => p_business_group_id,
                               p_grade_id           => p_grade_id,
                               p_plip_cer_id        => p_plip_cer_id,
                               p_point_id           => grd_step.spinal_point_id,
                               p_point_cer_id       => l_opt_cer_id,
                               p_scale_cer_id       => p_scale_cer_id,
                               p_option_id          => l_option_id,
                               p_dml_operation      => 'COPIED',
                               p_oipl_cer_id        => l_oipl_cer_id);
               hr_utility.set_location('oipl row created'||l_oipl_cer_id,80);
            else
               hr_utility.set_location('oipl row exists'||l_oipl_cer_id,80);
            end if;
         end loop;
      else
         hr_utility.set_location('scale not there ',90);
      end if;
   else
      -- grade and components are all in staging
      hr_utility.set_location('grade in stage ',90);
   end if;
   post_pull_process(p_copy_entity_txn_id => p_copy_entity_txn_id,
                     p_start_cer          => l_start_cer,
                     p_effective_date     => p_effective_date,
                     p_business_group_id  => p_business_group_id,
                     p_business_area      => p_business_area);
end populate_grd_hierarchy;
procedure create_oipl_row(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_business_group_id  in number,
                          p_grade_id           in number,
                          p_plip_cer_id        in number,
                          p_point_id           in number,
                          p_point_cer_id       in number,
                          p_option_id          in number,
                          p_scale_cer_id       in number,
                          p_dml_operation      in varchar2 default 'INSERT',
                          p_oipl_cer_id        out nocopy  number) is
   l_cop_tr_id number;
   l_cop_tr_name varchar2(80);
   l_oipl_cer_ovn number;
   l_plip_cer_id  number;
   l_point_name per_spinal_points.spinal_point%type;
   l_step_id number;
   l_step_ovn number;
   l_step_name number;
   l_grade_spine_id number;
   l_ceiling_flag varchar2(30);
   l_point_value number;
   l_scale_id number;
begin
   get_table_route_details(p_table_alias    => 'COP',
                           p_table_route_id => l_cop_tr_id,
                           p_table_name     => l_cop_tr_name);
   get_step_all_details(p_point_id       => p_point_id,
                        p_grade_id       => p_grade_id,
                        p_effective_date => p_effective_date,
                        p_option_id      => p_option_id,
                        p_point_name     => l_point_name,
                        p_step_name      => l_step_name,
                        p_step_id        => l_step_id,
                        p_step_ovn       => l_step_ovn,
                        p_grade_spine_id => l_grade_spine_id,
                        p_ceiling_flag   => l_ceiling_flag,
                        p_point_value    => l_point_value,
                        p_scale_id       => l_scale_id);
   begin
      ben_copy_entity_results_api.create_copy_entity_results(
         p_effective_date              => p_effective_date
         ,p_copy_entity_txn_id         => p_copy_entity_txn_id
         ,p_gs_parent_entity_result_id => p_plip_cer_id
         ,p_parent_entity_result_id    => p_plip_cer_id
         ,p_result_type_cd             => 'DISPLAY'
         ,p_table_name                 => l_cop_tr_name
         ,p_table_route_id             => l_cop_tr_id
         ,p_table_alias                => 'COP'
         ,p_dml_operation              => p_dml_operation
         -- ,p_information1            => p_oipl_id         -- new ben object
         ,p_information2               => p_effective_date
         ,p_information4               => p_business_group_id
         ,p_information253             => l_step_id
         ,p_information104             => 'LINK'
         ,p_information254             => l_step_ovn
         ,p_information255             => l_grade_spine_id
         ,p_information256             => p_point_id
         ,p_information98              => l_ceiling_flag
         ,p_information99              => l_point_name
         ,p_information262             => p_point_cer_id
         ,p_information263             => l_step_name
         ,p_information298             => l_point_value
         ,p_information259             => p_scale_cer_id
         ,p_information260             => l_scale_id
         ,p_copy_entity_result_id      => p_oipl_cer_id
         ,p_object_version_number      => l_oipl_cer_ovn);
       if l_ceiling_flag = 'Y' then
          update ben_copy_entity_results
          set information262 = p_oipl_cer_id,
              information259 = l_step_id
          where copy_entity_result_id = p_plip_cer_id;
       end if;
   exception
      when others then
         hr_utility.set_location('issue in creation oipl cer '||p_point_id,400);
         raise;
   end;
exception
   when others then
      hr_utility.set_location('issue in oipl cer '||p_point_id,420);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'create_oipl_row',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => p_effective_date);
      raise;
end create_oipl_row;
procedure copy_pl_hierarchy(p_copy_entity_txn_id in number,
                            p_pl_id              in number,
                            p_bg_id              in number,
                            p_effective_date     in date,
                            p_pl_cer_id          out nocopy number,
                            p_pl_cer_ovn         out nocopy number) is
   l_pl_cer_id number;
begin
   hr_utility.set_location('copying pl hier'||p_pl_id,10);
   ben_plan_design_plan_module.create_plan_result
   (p_copy_entity_result_id     => l_pl_cer_id
    ,p_copy_entity_txn_id       => p_copy_entity_txn_id
    ,p_pl_id                    => p_pl_id
    ,p_business_group_id        => p_bg_id
    ,p_number_of_copies         => 1
    ,p_object_version_number    => p_pl_cer_ovn
    ,p_effective_date           => p_effective_date
    ,p_no_dup_rslt              => 'Y'
   );
   hr_utility.set_location('copied pl hier'||l_pl_cer_id,20);
   p_pl_cer_id := l_pl_cer_id;
exception
   when others then
      hr_utility.set_location('issues in copying pl hier',25);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'copy_pl_hierarchy',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => p_effective_date);
      raise;
end copy_pl_hierarchy;
procedure populate_pl_hierarchy(p_copy_entity_txn_id in number,
                                p_effective_date     in date,
                                p_business_group_id  in number,
                                p_plip_cer_id        in number,
                                p_pl_id              in number,
                                p_mode               in varchar2 default 'COMPLETE',
                                p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                p_pl_cer_id          out nocopy number) is
   l_cer_ovn number;
   l_start_cer number;
begin
   p_pl_cer_id := is_pl_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                      p_pl_id              => p_pl_id);
   hr_utility.set_location('pl cer is'||p_pl_cer_id,10);
   if p_pl_cer_id is null then
      hr_utility.set_location('pl not in staging area, going for copy ',15);
      l_start_cer:= get_current_max_cer(p_copy_entity_txn_id );
      copy_pl_hierarchy(p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_pl_id              => p_pl_id,
                        p_bg_id              => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_pl_cer_id          => p_pl_cer_id,
                        p_pl_cer_ovn         => l_cer_ovn);
      hr_utility.set_location('pl cer id is'||p_pl_cer_id,16);
      hr_utility.set_location('plip cer id is'||p_plip_cer_id,17);
      if p_pl_cer_id is not null then
         begin
            update ben_copy_entity_results
            set gs_mirror_src_entity_result_id = p_plip_cer_id,
                mirror_src_entity_result_id = p_plip_cer_id
            where copy_entity_result_id = p_pl_cer_id;
         exception
            when others then
               hr_utility.set_location('pl update had issues ',18);
               raise;
         end;
         hr_utility.set_location('changing parent to plip',19);
         change_parent_plip(p_copy_entity_txn_id => p_copy_entity_txn_id,
                            p_plip_cer_id        => p_plip_cer_id,
                            p_pl_cer_id          => p_pl_cer_id);
         hr_utility.set_location('parent plip done',20);
      else
         hr_utility.set_location('Issue in copy ',30);
      end if;
      if p_mode = 'COMPLETE' then
         post_pull_process(p_copy_entity_txn_id => p_copy_entity_txn_id,
                           p_start_cer          => l_start_cer,
                           p_effective_date     => p_effective_date,
                           p_business_group_id  => p_business_group_id,
                           p_business_area      => p_business_area);
         p_pl_cer_id := is_pl_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                            p_pl_id              => p_pl_id);
      end if;
      if p_pl_cer_id is null then
         hr_utility.set_location('issues in copying plan',50);
      else
         hr_utility.set_location('pl cer is'||p_pl_cer_id,55);
      end if;
   else
      hr_utility.set_location('plan exists ',100);
   end if;
end populate_pl_hierarchy;
procedure populate_ep_hierarchy(p_copy_entity_txn_id in number,
                                p_effective_date     in date,
                                p_business_group_id  in number,
                                p_ep_id              in number,
                                p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                p_ep_cer_id          out nocopy number) is
   l_copy_entity_result_id number;
   l_cer_ovn number;
   l_start_cer number;
   l_parent_cer_id number;
begin
-- a elig-prof can be in system more than once, hence not having the check of existence
   PQH_GSP_PROCESS_LOG.START_LOG
   (P_TXN_ID    => p_ep_id,
   P_TXN_NAME  => 'ELP_id : '||p_ep_id,
   P_MODULE_CD => 'PQH_GSP_BENSTG');
   g_master_txn_id := p_ep_id;
   g_txn_id        := p_ep_id;
   hr_utility.set_location('ep id is'||p_ep_id,10);
   l_start_cer:= get_current_max_cer(p_copy_entity_txn_id );
   begin
      ben_plan_design_elpro_module.create_elig_prfl_results
       (p_copy_entity_txn_id          => p_copy_entity_txn_id
       ,p_mirror_src_entity_result_id => l_parent_cer_id
       ,p_parent_entity_result_id     => l_parent_cer_id
       ,p_mndtry_flag                 => ''
       ,p_eligy_prfl_id               => p_ep_id
       ,p_business_group_id           => p_business_group_id
       ,p_number_of_copies            => 1
       ,p_object_version_number       => l_cer_ovn
       ,p_effective_date              => p_effective_date
      );
      hr_utility.set_location('copied ep hier',20);

      BEN_PDW_COPY_BEN_TO_STG.populate_extra_mapping_ELP(
                        p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_effective_date => p_effective_date,
                        p_elig_prfl_id =>p_ep_id
                        );
      hr_utility.set_location('Done with the mapping',25);
/*
   exception
      when others then
         hr_utility.set_location('issues in copying ep hier',25);
         PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
         (P_MASTER_TXN_ID   => g_master_txn_id,
          P_TXN_ID          => g_txn_id,
          p_context         => 'copy_ep_hierarchy',
          P_MODULE_CD       => 'PQH_GSP_BENSTG',
          P_MESSAGE_TYPE_CD => 'E',
          P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
          p_effective_date  => p_effective_date);
         raise;
         */
   end;

p_ep_cer_id := is_ep_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                      p_start_cer          => l_start_cer,
                                      p_ep_id             => p_ep_id);

   post_pull_process(p_copy_entity_txn_id => p_copy_entity_txn_id,
                     p_start_cer          => l_start_cer,
                     p_effective_date     => p_effective_date,
                     p_business_group_id  => p_business_group_id,
                     p_business_area      => p_business_area);

   if p_ep_cer_id is null then
      hr_utility.set_location('issues in copying ep',50);
   else
      hr_utility.set_location('ep cer is'||p_ep_cer_id,55);
   end if;

-- For elp/child_records which have future records , pdw needs the
-- attribute FUTURE_DATA_EXISTS properly set so that they can properly
-- set the datetrack_mode and dml_operation
-- The following code is copied from BEN_PDW_COPY_BEN_TO_STG.mark_future_data_exists

    update ben_copy_entity_results a
            set future_data_exists ='Y'
            where a.copy_entity_txn_id = p_copy_entity_txn_id
            and a.future_data_exists is null
            and a.information3 < to_date('4712/12/31','YYYY/MM/DD')
            and exists
            ( select 'Y' from ben_copy_entity_results b
              where b.copy_entity_txn_id = a.copy_entity_txn_id
              and b.table_alias = a.table_alias
              and b.information1 = a.information1
              and b.information2 = a.information3+1);
    hr_utility.set_location('Updated bcer records for future_data_exists flag',25);

end populate_ep_hierarchy;

procedure create_plan_row(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_business_group_id  in number,
                          p_grade_id           in number,
                          p_plip_cer_id        in number,
                          p_dml_operation      in varchar2 default 'INSERT',
                          p_pl_cer_id          out nocopy number,
                          p_pl_cer_ovn         out nocopy number) is
   l_pln_tr_id number;
   l_pln_tr_name varchar2(80);
   l_date_from date;
   l_date_to date;
   l_short_name per_grades.short_name%type;
   l_grade_name per_grades.name%type;
   l_grade_definition_id number;
   l_grd_ovn number;
begin
   get_table_route_details(p_table_alias    => 'PLN',
                           p_table_route_id => l_pln_tr_id,
                           p_table_name     => l_pln_tr_name);
   if p_grade_id is not null then
      get_grade_details(p_grade_id            => p_grade_id,
                        p_date_from           => l_date_from,
                        p_date_to             => l_date_to,
                        p_short_name          => l_short_name,
                        p_grade_name          => l_grade_name,
                        p_grd_ovn             => l_grd_ovn,
                        p_grade_definition_id => l_grade_definition_id);
   end if;
   begin
      ben_copy_entity_results_api.create_copy_entity_results(
         p_effective_date                  => p_effective_date
         ,p_copy_entity_txn_id             => p_copy_entity_txn_id
         ,p_gs_mr_src_entity_result_id     => p_plip_cer_id
         ,p_mirror_src_entity_result_id    => p_plip_cer_id
         ,p_result_type_cd                 => 'DISPLAY'
         ,p_table_name                     => l_pln_tr_name
         ,p_table_route_id                 => l_pln_tr_id
         ,p_table_alias                    => 'PLN'
         ,p_dml_operation                  => p_dml_operation
         ,p_information2                   => p_effective_date
         ,p_information4                   => p_business_group_id
         ,p_information5                   => l_grade_name
         ,p_information170                 => l_grade_name
         ,p_information221                 => l_grade_definition_id
         ,p_information307                 => l_date_from
         ,p_information308                 => l_date_to
         ,p_information222                 => l_grd_ovn
         ,p_information223                 => p_grade_id
         ,p_information141                 => 'PER_GRADES'
         ,p_information294                 => p_grade_id
         ,p_information102                 => l_short_name
         ,p_copy_entity_result_id          => p_pl_cer_id
         ,p_object_version_number          => p_pl_cer_ovn);
   exception
      when others then
         hr_utility.set_location('issue in creation pln cer '||p_grade_id,400);
         raise;
   end;
exception
   when others then
      hr_utility.set_location('issue in pln cer '||p_grade_id,420);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'create_plan_row',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => p_effective_date);
      raise;
end create_plan_row;
procedure create_option_row(p_copy_entity_txn_id in number,
                            p_effective_date     in date,
                            p_business_group_id  in number,
                            p_scale_id           in number,
                            p_scale_cer_id       in number,
                            p_point_id           in number,
                            p_dml_operation      in varchar2 default 'INSERT',
                            p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                            p_opt_cer_id         out nocopy number,
                            p_opt_cer_ovn        out nocopy number) is
   l_opt_tr_id number;
   l_opt_tr_name varchar2(80);
   l_scale_id number;
   l_point_seq number;
   l_point_ovn number;
   l_spinal_point per_spinal_points.spinal_point%type;
   l_information_category varchar2(30);
   l_information1 varchar2(150);
   l_information2 varchar2(150);
   l_information3 varchar2(150);
   l_information4 varchar2(150);
   l_information5 varchar2(150);
begin
   get_table_route_details(p_table_alias    => 'OPT',
                           p_table_route_id => l_opt_tr_id,
                           p_table_name     => l_opt_tr_name);
   if p_point_id is not null then
      get_point_details(p_point_id     => p_point_id,
                        p_scale_id     => l_scale_id,
                        p_point_seq    => l_point_seq,
                        p_point_ovn    => l_point_ovn,
                        p_spinal_point => l_spinal_point);
      if p_business_area = 'PQH_CORPS_TASK_LIST' then
         pqh_cpd_hr_to_stage.get_point_details(p_point_id             => p_point_id,
                                               p_information_category => l_information_category,
                                               p_information1         => l_information1,
                                               p_information2         => l_information2,
                                               p_information3         => l_information3,
                                               p_information4         => l_information4,
                                               p_information5         => l_information5);
      end if;
   end if;
   begin
      ben_copy_entity_results_api.create_copy_entity_results(
         p_effective_date              => p_effective_date
         ,p_copy_entity_txn_id         => p_copy_entity_txn_id
         ,p_result_type_cd             => 'DISPLAY'
         ,p_table_name                 => l_opt_tr_name
         ,p_table_route_id             => l_opt_tr_id
         ,p_table_alias                => 'OPT'
         ,p_dml_operation              => p_dml_operation
         -- ,p_information1          => p_option_id       -- new ben object
         ,p_information2               => p_effective_date
         ,p_information4               => p_business_group_id
         ,p_information5               => l_spinal_point
         ,p_information98              => l_spinal_point
         ,p_information253             => l_point_seq
         ,p_information254             => l_point_ovn
         ,p_information255             => l_scale_id
         ,p_information256             => p_scale_cer_id
         ,p_information257             => p_point_id
         ,p_information141             => 'PER_SPINAL_POINTS'
         ,p_information173             => l_information1
         ,p_information175             => l_information2
         ,p_information179             => l_information3
         ,p_information181             => l_information4
         ,p_information182             => l_information5
         ,p_information101             => l_information_category
         ,p_copy_entity_result_id      => p_opt_cer_id
         ,p_object_version_number      => p_opt_cer_ovn);
   exception
      when others then
         hr_utility.set_location('issue in creation opt cer '||p_point_id,400);
         raise;
   end;
   if p_business_area = 'PQH_CORPS_TASK_LIST' then
      pqh_gsp_utility.update_frps_point_rate(p_point_cer_id       => p_opt_cer_id,
                                             p_copy_entity_txn_id => p_copy_entity_txn_id,
                                             p_business_group_id  => p_business_group_id,
                                             p_salary_rate        => l_information2,
                                             p_gross_index        => l_information1,
                                             p_effective_date     => p_effective_date);
   end if;
exception
   when others then
      hr_utility.set_location('issue in opt cer '||p_point_id,420);
      PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
      (P_MASTER_TXN_ID   => g_master_txn_id,
       P_TXN_ID          => g_txn_id,
       p_context         => 'create_opt_row',
       P_MODULE_CD       => 'PQH_GSP_BENSTG',
       P_MESSAGE_TYPE_CD => 'E',
       P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
       p_effective_date  => p_effective_date);
      raise;
end create_option_row;
procedure populate_scale_hierarchy(p_copy_entity_txn_id in number,
                                   p_effective_date     in date,
                                   p_business_group_id  in number,
                                   p_scale_id           in number,
                                   p_mode               in varchar2 default 'COMPLETE',
                                   p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                   p_scale_cer_id       out nocopy number) is
   l_cer_ovn number;
   l_option_id number;
   l_opt_cer_id number;
   l_parent_opt_cer_id number;
   l_start_cer number;
--bug 6277443 changing the cursor to improve performance

   cursor csr_scale_points is
      select spinal_point_id
      from   per_spinal_points
      where parent_spine_id = p_scale_id
  	and not exists (select 1 from
	ben_copy_entity_results
	where copy_entity_txn_id = p_copy_entity_txn_id
	and table_alias ='OPT'
	and information257 = spinal_point_id) ;
--bug 6277443
begin
   if p_scale_id is not null then
      l_start_cer:= get_current_max_cer(p_copy_entity_txn_id );
      -- create scale if it doesnot exist in staging area.
      p_scale_cer_id := is_scale_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                               p_scale_id           => p_scale_id);
     If g_txn_id is NULL Then
        PQH_GSP_PROCESS_LOG.START_LOG
         (P_TXN_ID    => P_Scale_id,
         P_TXN_NAME   => 'SCALE',
         P_MODULE_CD  => 'PQH_GSP_BENSTG');
         g_master_txn_id := P_Scale_id;
         g_txn_id        := P_Scale_id;
      End If;
      if p_scale_cer_id is null then
         hr_utility.set_location('scale not in stage,copy it',10);
         scale_to_stage(p_scale_id           => p_scale_id,
                        p_business_group_id  => p_business_group_id,
                        p_business_area      => p_business_area,
                        p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_effective_date     => p_effective_date,
                        p_scale_cer_id       => p_scale_cer_id);
      else
         hr_utility.set_location('scale is already in staging area ',15);
      end if;
      for i in csr_scale_points loop
         begin
         hr_utility.set_location('point passed is '||i.spinal_point_id,22);
         l_option_id := get_opt_for_point(p_point_id => i.spinal_point_id,
                                          p_effective_date => p_effective_date);
         hr_utility.set_location('option is '||l_option_id,30);
         l_opt_cer_id := is_point_exists_in_txn
                           (p_copy_entity_txn_id => p_copy_entity_txn_id,
                            p_point_id           => i.spinal_point_id);
         if l_opt_cer_id is null and l_option_id is not null then
            hr_utility.set_location('opt is linked to point but doesnot exist in txn',37);
            begin
               hr_utility.set_location('calling opt hier copy ',38);
               ben_plan_design_plan_module.create_opt_result
               (p_copy_entity_result_id     => l_opt_cer_id
                ,p_copy_entity_txn_id       => p_copy_entity_txn_id
                ,p_opt_id                   => l_option_id
                ,p_business_group_id        => p_business_group_id
                ,p_number_of_copies         => 1
                ,p_object_version_number    => l_cer_ovn
                ,p_effective_date           => p_effective_date
                ,p_parent_entity_result_id  => l_parent_opt_cer_id
               );
               hr_utility.set_location('opt hier copy done',39);
            exception
               when others then
                  hr_utility.set_location('issues in copying opt hier',40);
                  PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
                  (P_MASTER_TXN_ID   => g_master_txn_id,
                   P_TXN_ID          => g_txn_id,
                   p_context         => 'populate_scale_hierarchy',
                   P_MODULE_CD       => 'PQH_GSP_BENSTG',
                   P_MESSAGE_TYPE_CD => 'E',
                   P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
                   p_effective_date  => p_effective_date);
                  raise;
            end;
         elsif l_option_id is null and l_opt_cer_id is null then
            hr_utility.set_location('point is not mapped,create option row ',25);
            create_option_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                              p_effective_date     => p_effective_date,
                              p_business_group_id  => p_business_group_id,
                              p_scale_id           => p_scale_id,
                              p_scale_cer_id       => p_scale_cer_id,
                              p_point_id           => i.spinal_point_id,
                              p_opt_cer_id         => l_opt_cer_id,
                              p_dml_operation      => 'COPIED',
                              p_business_area      => p_business_area,
                              p_opt_cer_ovn        => l_cer_ovn);
            hr_utility.set_location('option created '||l_opt_cer_id,35);
         else
            hr_utility.set_location('option exists in staging '||l_opt_cer_id,35);
         end if;
      exception
         when others then
            hr_utility.set_location('issues in getting opt ',25);
            PQH_GSP_PROCESS_LOG.LOG_PROCESS_DTLS
            (P_MASTER_TXN_ID   => g_master_txn_id,
            P_TXN_ID          => g_txn_id,
            p_context         => 'populate_scale_hierarchy',
            P_MODULE_CD       => 'PQH_GSP_BENSTG',
            P_MESSAGE_TYPE_CD => 'E',
            P_MESSAGE_TEXT    => Nvl(fnd_Message.Get,sqlerrm),
            p_effective_date  => p_effective_date);
            raise;
      end;
   end loop;
   if p_mode = 'COMPLETE' then
      post_pull_process(p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_start_cer          => l_start_cer,
                        p_effective_date     => p_effective_date,
                        p_business_group_id  => p_business_group_id,
                        p_business_area      => p_business_area);
   end if;
 else
    hr_utility.set_location('scale id passed is null',25);
 end if;
end populate_scale_hierarchy;
procedure pull_payrate(p_copy_entity_txn_id in number,
                       p_payrate_id         in number,
                       p_effective_date     in date) is
   cursor csr_grd_rt is
   select * from pay_grade_rules_f
   where rate_id = p_payrate_id
   and p_effective_date between effective_start_date and effective_end_date;
   l_hrr_cer_id number;
   l_abr_cer_id number;
   l_opt_cer_id number;
   l_pl_cer_id number;
   l_grade_id number;
   l_point_id number;
   l_sot date ;
   l_grd_st_dt date;
begin
-- start the process_log for rate pull
   If g_txn_id is NULL Then
      PQH_GSP_PROCESS_LOG.START_LOG
      (P_TXN_ID    => p_payrate_id,
      P_TXN_NAME   => 'pull_pay_rate',
      P_MODULE_CD  => 'PQH_GSP_BENSTG');
      g_master_txn_id := P_payrate_id;
      g_txn_id        := P_payrate_id;
   End If;
-- get the child rows corresponding to the pay rate.
-- if the pay rate is Grade then we may have to create rows for ABR/ HRRATE for plan
-- in case of scale, it will be for the point associated.
-- if new rates are created then plip and oipl rows should be updated to show standard rate
   for grd_rt in csr_grd_rt loop
       l_sot := pqh_gsp_utility.get_gsp_plntyp_str_date(grd_rt.business_group_id,p_copy_entity_txn_id);
       if grd_rt.rate_type = 'G' then
          l_grade_id := grd_rt.grade_or_spinal_point_id;
          hr_utility.set_location('grade id is '||l_grade_id,13);
          -- check grade is part of grade ladder or not
          -- if rate is not defined then we create abr and hrrate rows.
          l_pl_cer_id := is_grd_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                              p_grd_id             => l_grade_id);
          if l_pl_cer_id is not null then
             hr_utility.set_location('pl_cer_id id is '||l_pl_cer_id,14);
             l_hrr_cer_id := is_hrr_exists(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                           p_grade_cer_id       => l_pl_cer_id,
                                           p_hrr_esd            => p_effective_date);
             if l_hrr_cer_id is not null then
                hr_utility.set_location('rate for grade exists',12);
             else
                hr_utility.set_location('rate for grade doesnot exist, have to create',12);
                l_grd_st_dt := get_grd_start_date(p_grade_cer_id => l_pl_cer_id);
                hr_utility.set_location('grd_st_dt is '||to_char(l_grd_st_dt,'DD/MM/RRRR'),12);
                create_abr_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                               p_start_date         => l_grd_st_dt,
                               p_pl_cer_id          => l_pl_cer_id,
                               p_business_group_id  => grd_rt.business_group_id,
                               p_effective_date     => p_effective_date,
                               p_abr_cer_id         => l_abr_cer_id,
                               p_create_hrr         => 'N',
                               p_dml_oper           => 'INSERT');
                hr_utility.set_location('abr_cer_id is '||l_abr_cer_id,16);
                create_hrrate_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                  p_effective_date     => p_effective_date,
                                  p_start_date         => l_grd_st_dt,
                                  p_business_group_id  => grd_rt.business_group_id,
                                  p_abr_cer_id         => l_abr_cer_id,
                                  p_grade_cer_id       => l_pl_cer_id,
                                  p_grd_value          => grd_rt.value,
                                  p_grd_min_value      => grd_rt.minimum,
                                  p_grd_mid_value      => grd_rt.mid_value,
                                  p_grd_max_value      => grd_rt.maximum,
                                  p_dml_oper           => 'INSERT',
                                  p_hrrate_cer_id      => l_hrr_cer_id);
                hr_utility.set_location('hrr_cer_id is '||l_hrr_cer_id,17);
             end if;
          else
             hr_utility.set_location('grade is not in GL',11);
          end if;
       elsif grd_rt.rate_type = 'SP' then
          l_point_id := grd_rt.grade_or_spinal_point_id;
          hr_utility.set_location('point id is '||l_point_id,13);
          -- check point is part of grade ladder or not
          -- if rate is not defined then we create abr and hrrate rows.
          l_opt_cer_id := is_point_exists_in_txn(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                                p_point_id           => l_point_id);
          if l_opt_cer_id is not null then
             hr_utility.set_location('pl_cer_id id is '||l_pl_cer_id,14);
             l_hrr_cer_id := is_hrr_exists(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                           p_point_cer_id       => l_opt_cer_id,
                                           p_hrr_esd            => p_effective_date);
             if l_hrr_cer_id is not null then
                hr_utility.set_location('rate for point exists',12);
             else
                hr_utility.set_location('rate for point doesnot exist, have to create',12);
                create_abr_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                               p_start_date         => l_sot,
                               p_opt_cer_id         => l_opt_cer_id,
                               p_business_group_id  => grd_rt.business_group_id,
                               p_effective_date     => p_effective_date,
                               p_abr_cer_id         => l_abr_cer_id,
                               p_create_hrr         => 'N',
                               p_dml_oper           => 'INSERT');
                hr_utility.set_location('abr_cer_id is '||l_abr_cer_id,16);
                create_hrrate_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                  p_effective_date     => p_effective_date,
                                  p_start_date         => l_sot,
                                  p_business_group_id  => grd_rt.business_group_id,
                                  p_abr_cer_id         => l_abr_cer_id,
                                  p_point_cer_id       => l_opt_cer_id,
                                  p_point_value        => grd_rt.value,
                                  p_dml_oper           => 'INSERT',
                                  p_hrrate_cer_id      => l_hrr_cer_id);
                hr_utility.set_location('hrr_cer_id is '||l_hrr_cer_id,17);
             end if;
          else
             hr_utility.set_location('grade is not in GL',11);
          end if;
       else
          hr_utility.set_location('invalid rate type'||grd_rt.rate_type,10);
       end if;
   end loop;
   PQH_PROCESS_BATCH_LOG.END_LOG;
end pull_payrate;
procedure create_frps_point_rate(p_point_cer_id       in number,
                                 p_copy_entity_txn_id in number,
                                 p_business_group_id  in number,
                                 p_point_value        in number,
                                 p_effective_date     in date) is
   l_sot date := pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
   l_abr_cer_id number;
   l_hrr_cer_id number;
begin
   if p_point_cer_id is not null then
      create_abr_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                     p_start_date         => l_sot,
                     p_opt_cer_id         => p_point_cer_id,
                     p_business_group_id  => p_business_group_id,
                     p_effective_date     => p_effective_date,
                     p_abr_cer_id         => l_abr_cer_id,
                     p_create_hrr         => 'N',
                     p_dml_oper           => 'INSERT');
      hr_utility.set_location('abr_cer_id is '||l_abr_cer_id,16);
      create_hrrate_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_effective_date     => p_effective_date,
                        p_start_date         => l_sot,
                        p_business_group_id  => p_business_group_id,
                        p_abr_cer_id         => l_abr_cer_id,
                        p_point_cer_id       => p_point_cer_id,
                        p_point_value        => p_point_value,
                        p_dml_oper           => 'INSERT',
                        p_hrrate_cer_id      => l_hrr_cer_id);
      hr_utility.set_location('hrr_cer_id is '||l_hrr_cer_id,17);
   end if;
end create_frps_point_rate;
procedure update_frps_point_rate(p_point_cer_id       in number,
                                 p_copy_entity_txn_id in number,
                                 p_business_group_id  in number,
                                 p_point_value        in number,
                                 p_effective_date     in date) is
   l_hrr_cer_id number;
begin
   l_hrr_cer_id := is_hrr_exists(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                 p_point_cer_id       => p_point_cer_id,
                                 p_hrr_esd            => p_effective_date);
   if l_hrr_cer_id is null then
      create_frps_point_rate(p_point_cer_id       => p_point_cer_id,
                             p_copy_entity_txn_id => p_copy_entity_txn_id,
                             p_business_group_id  => p_business_group_id,
                             p_point_value        => p_point_value,
                             p_effective_date     => p_effective_date);
   else
      pqh_gsp_rates.update_point_hrrate(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                        p_rt_effective_date  => p_effective_date,
                                        p_gl_effective_date  => p_effective_date,
                                        p_business_group_id  => p_business_group_id,
                                        p_hrrate_cer_id      => l_hrr_cer_id,
                                        p_point_cer_id       => p_point_cer_id,
                                        p_point_value        => p_point_value,
                                        p_datetrack_mode     => 'UPDATE_REPLACE');
   end if;
end update_frps_point_rate;
procedure create_payrate(p_copy_entity_txn_id in number,
                       p_effective_date     in date,
                       p_business_group_id in number) is

    Cursor csr_pgm_details
    is
    select information70 calc_method,information51 prog_style
    from ben_copy_entity_results
    where copy_entity_txn_id = p_copy_entity_txn_id
    and table_alias = 'PGM'
    and result_type_cd = 'DISPLAY';

    Cursor csr_grd_details
    is
    select copy_entity_result_id
    from ben_copy_entity_results
    where  copy_entity_txn_id = p_copy_entity_txn_id
    AND table_alias = 'PLN'
    AND result_type_cd ='DISPLAY';

    Cursor csr_opt_details
    is
    select copy_entity_result_id
    from ben_copy_entity_results
    where  copy_entity_txn_id = p_copy_entity_txn_id
    AND table_alias = 'OPT';

    l_calc_method varchar2(240);
    l_prog_style varchar2(240);


   l_grade_cer_id number;
   l_point_cer_id number;




   l_hrr_cer_id number;
   l_abr_cer_id number;
   l_opt_cer_id number;
   l_grade_id number;
   l_point_id number;
   l_sot date := pqh_gsp_utility.get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
   l_grd_st_dt date;
begin

    OPEN csr_pgm_details;
    FETCH csr_pgm_details into l_calc_method,l_prog_style;
    CLOSE csr_pgm_details;

    IF l_calc_method = 'RULE' THEN
        IF l_prog_style = 'PQH_GSP_GP' THEN
       for i in csr_grd_details loop
        l_grade_cer_id := i.copy_entity_result_id;
          if l_grade_cer_id is not null then
             hr_utility.set_location('grd_cer_id id is '||l_grade_cer_id,14);
             l_hrr_cer_id := is_hrr_exists(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                           p_grade_cer_id       => l_grade_cer_id,
                                           p_hrr_esd            => p_effective_date);
             if l_hrr_cer_id is not null then
                hr_utility.set_location('rate for grade exists',12);
             else
                hr_utility.set_location('rate for grade doesnot exist, have to create',12);
                l_grd_st_dt := get_grd_start_date(p_grade_cer_id => l_grade_cer_id);
                hr_utility.set_location('grd_st_dt is '||to_char(l_grd_st_dt,'DD/MM/RRRR'),12);
                create_abr_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                               p_start_date         => l_grd_st_dt,
                               p_pl_cer_id          => l_grade_cer_id,
                               p_business_group_id  => p_business_group_id ,
                               p_effective_date     => p_effective_date,
                               p_abr_cer_id         => l_abr_cer_id,
                               p_create_hrr         => 'N',
                               p_dml_oper           => 'INSERT');
                hr_utility.set_location('abr_cer_id is '||l_abr_cer_id,16);
                create_hrrate_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                  p_effective_date     => p_effective_date,
                                  p_start_date         => l_grd_st_dt,
                                  p_business_group_id  => p_business_group_id,
                                  p_abr_cer_id         => l_abr_cer_id,
                                  p_grade_cer_id       => l_grade_cer_id,
                                  p_grd_value          => 0,
                                  p_grd_min_value      => 0,
                                  p_grd_mid_value      => 0,
                                  p_grd_max_value      => 0,
                                  p_dml_oper           => 'INSERT',
                                  p_hrrate_cer_id      => l_hrr_cer_id);
                hr_utility.set_location('hrr_cer_id is '||l_hrr_cer_id,17);
             end if;
          else
             hr_utility.set_location('grade is not in GL',11);
          end if;
        end loop;
        ELSE
    for i in csr_opt_details loop
        l_opt_cer_id := i.copy_entity_result_id;
             hr_utility.set_location('opt_cer_id id is '||l_opt_cer_id,14);
             l_hrr_cer_id := is_hrr_exists(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                           p_point_cer_id       => l_opt_cer_id,
                                           p_hrr_esd            => p_effective_date);
             if l_hrr_cer_id is not null then
                hr_utility.set_location('rate for point exists',12);
             else
                hr_utility.set_location('rate for point doesnot exist, have to create',12);
                create_abr_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                               p_start_date         => l_sot,
                               p_opt_cer_id         => l_opt_cer_id,
                               p_business_group_id  => p_business_group_id,
                               p_effective_date     => p_effective_date,
                               p_abr_cer_id         => l_abr_cer_id,
                               p_create_hrr         => 'N',
                               p_dml_oper           => 'INSERT');
                hr_utility.set_location('abr_cer_id is '||l_abr_cer_id,16);
                create_hrrate_row(p_copy_entity_txn_id => p_copy_entity_txn_id,
                                  p_effective_date     => p_effective_date,
                                  p_start_date         => l_sot,
                                  p_business_group_id  => p_business_group_id,
                                  p_abr_cer_id         => l_abr_cer_id,
                                  p_point_cer_id       => l_opt_cer_id,
                                  p_point_value        => 0,
                                  p_dml_oper           => 'INSERT',
                                  p_hrrate_cer_id      => l_hrr_cer_id);
                hr_utility.set_location('hrr_cer_id is '||l_hrr_cer_id,17);
             end if;
       end loop;
    END IF;
END IF;
end create_payrate;
function get_plip_for_pgm_plan(p_pgm_id        in number,
                                p_plan_id       in number,
                                p_effective_date in date
                               ) return number is
l_plip_id number;
begin
   begin
      select plip_id
      into l_plip_id
      from ben_plip_f
      where pgm_id = p_pgm_id
      and  pl_id = p_plan_id
      and p_effective_date between effective_start_date and effective_end_date;
      hr_utility.set_location('plip is '||l_plip_id,10);
   exception
      when no_data_found then
         hr_utility.set_location('plip does not exist '||l_plip_id,10);
      when others then
         hr_utility.set_location('issues in selected plip',20);
         raise;
   end;
  return l_plip_id;
end get_plip_for_pgm_plan;
end pqh_gsp_hr_to_stage;

/
