--------------------------------------------------------
--  DDL for Package Body BEN_DM_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_DELETE" AS
/* $Header: benfdmpmdel.pkb 120.1 2006/06/13 15:23:29 nkkrishn noship $ */

procedure main(
 errbuf                 out nocopy  varchar2,
 retcode                out nocopy  number ,
 p_migration_id         in   number ,
 p_concurrent_process   in   varchar2 default 'Y',
 p_last_migration_date  in   varchar2,
 p_process_number       in   number ,
 p_dir_name             in   varchar2,
 p_file_name            in   varchar2,
 p_delimiter            in   varchar2,
 p_business_group_id    in   number default null) is

l_no_of_threads           number;
l_person_id               number;

cursor c1 is
select distinct per.person_id, dif.group_order
  from ben_dm_phase_items itm,
       ben_dm_phases  phs,
       ben_dm_input_file dif,
       per_all_people_f per,
       per_business_groups bg
 where phs.migration_id = p_migration_id
   and phs.phase_id     = itm.phase_id
   and phs.phase_name   = 'UP' --use UP phase for now
   and mod(itm.phase_item_id,l_no_of_threads) + 1 = p_process_number
--added check for person records only
   and dif.person_type = 'P'
   and dif.group_order = itm.group_order
   and per.national_identifier = nvl(dif.target_national_identifier,dif.source_national_identifier)
   and bg.name = dif.target_business_group_name
   and per.business_group_id = bg.business_group_id;

--New Cursor to identify dependent records to be deleted for each person
--being migrated
cursor c2(p_group_order varchar2
         ,p_person_id    number) is
select distinct per.person_id
  from ben_dm_phase_items itm,
       ben_dm_phases  phs,
       ben_dm_input_file dif,
       per_all_people_f per,
       per_business_groups bg,
       per_contact_relationships pcr
 where phs.migration_id = p_migration_id
   and phs.phase_id     = itm.phase_id
   and phs.phase_name   = 'UP' --use UP phase for now
   and mod(itm.phase_item_id,l_no_of_threads) + 1 = p_process_number
   and dif.person_type = 'D'
   and dif.group_order = p_group_order
   and dif.group_order = itm.group_order
   and per.national_identifier = nvl(dif.target_national_identifier,dif.source_national_identifier)
   and per.person_id = pcr.contact_person_id
   and pcr.person_id = p_person_id
   and bg.name = dif.target_business_group_name
   and per.business_group_id = bg.business_group_id;

Type personRec is Record
(person_id           number,
 group_order         number);
Type personTab is Table of personRec index by binary_integer;

l_person_rec      personTab;

begin

 l_no_of_threads := ben_dm_utility.number_of_threads(p_business_group_id);
 if l_no_of_threads is null then
    l_no_of_threads := 3 ;
 end  if ;
 open c1;
 fetch c1 bulk collect into l_person_rec;
 close c1;
 if l_person_rec.count > 0 then
 --Delete the person and dependent records from the target business group
 for i in 1..l_person_rec.count
   loop
     --Delete all dependents of the person
     open c2(l_person_rec(i).group_order, l_person_rec(i).person_id);
     loop
       fetch c2 into l_person_id;
       if c2%notfound then
          exit;
       end if;
       delete_person(l_person_id);
       commit;
     end loop;
     --Delete the person record
     delete_person(p_person_id   =>  l_person_rec(i).person_id);
     close c2;
   end loop;
 commit;
 end if;
end main;

procedure delete_person(p_person_id number) is
begin

hr_general.g_data_migrator_mode := 'Y';

delete from ben_le_clsn_n_rstr
where per_in_ler_id in (select per_in_ler_id from ben_per_in_ler
where person_id =p_person_id);

delete from ben_per_bnfts_bal_f where person_id = p_person_id;

delete from ben_cbr_per_in_ler cpl where cpl.cbr_quald_bnf_id in
(select cbf.cbr_quald_bnf_id from ben_cbr_quald_bnf cbf where cbf.quald_bnf_person_id = p_person_id);

delete from ben_cbr_quald_bnf where quald_bnf_person_id = p_person_id;

delete from ben_prmry_care_prvdr_f pcp
where pcp.prtt_enrt_rslt_id in
(select pen.prtt_enrt_rslt_id
   from ben_prtt_enrt_rslt_f pen
  where pen.person_id = p_person_id);

delete from ben_prmry_care_prvdr_f pcp
where pcp.elig_cvrd_dpnt_id in
(select egd.elig_cvrd_dpnt_id
   from ben_elig_cvrd_dpnt_f egd,
        ben_prtt_enrt_rslt_f pen
  where pen.person_id = p_person_id
    and egd.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id);

delete from ben_enrt_rt
where elig_per_elctbl_chc_id in
(select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc
where per_in_ler_id in (select per_in_ler_id from ben_per_in_ler
where person_id =p_person_id));

delete from ben_enrt_prem
where elig_per_elctbl_chc_id in
(select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc
where per_in_ler_id in (select per_in_ler_id from ben_per_in_ler
where person_id =p_person_id));

delete from ben_enrt_rt
where enrt_bnft_id in
(select enrt_bnft_id from ben_enrt_bnft
where elig_per_elctbl_chc_id in
(select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc
where per_in_ler_id in (select per_in_ler_id from ben_per_in_ler
where person_id =p_person_id)));

delete from BEN_ELCTBL_CHC_CTFN
where elig_per_elctbl_chc_id in
(select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc
where per_in_ler_id in (select per_in_ler_id from ben_per_in_ler
where person_id =p_person_id));

delete from BEN_ELCTBL_CHC_CTFN
where enrt_bnft_id in
(select enrt_bnft_id from ben_enrt_bnft
where elig_per_elctbl_chc_id in
(select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc
where per_in_ler_id in (select per_in_ler_id from ben_per_in_ler
where person_id =p_person_id)));

delete from ben_enrt_bnft
where elig_per_elctbl_chc_id in
(select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc
where per_in_ler_id in (select per_in_ler_id from ben_per_in_ler
where person_id =p_person_id));

delete from ben_elig_per_elctbl_chc
where per_in_ler_id in (select per_in_ler_id from ben_per_in_ler
where person_id =p_person_id);

delete from ben_pil_elctbl_chc_popl
where per_in_ler_id in (select per_in_ler_id from ben_per_in_ler
where person_id =p_person_id);

delete from PAY_ELEMENT_ENTRY_VALUES_F
where element_entry_id
in (select element_entry_id
from pay_element_entries_f
where assignment_id in
(select assignment_id
from per_all_assignments_f
where person_id =p_person_id));

delete from PAY_ELEMENT_ENTRIES_F
where assignment_id in
(select assignment_id
from per_all_assignments_f
where person_id =p_person_id);

delete from ben_prtt_prem_f
where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f where person_id =p_person_id);
delete from ben_prtt_rt_val where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f where person_id =p_person_id);

delete from ben_bnft_prvdd_ldgr_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f where person_id =p_person_id);

delete from ben_prtt_enrt_actn_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f where person_id =p_person_id);

delete from ben_prtt_enrt_actn_f where elig_cvrd_dpnt_id in
(select elig_cvrd_dpnt_id from ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f where person_id =p_person_id));

delete from ben_prtt_enrt_actn_f where pl_bnf_id in
(select pl_bnf_id from ben_pl_bnf_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f where person_id =p_person_id));

delete from ben_prtt_enrt_ctfn_prvdd_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f where person_id =p_person_id);

delete from ben_cvrd_dpnt_ctfn_prvdd_f where elig_cvrd_dpnt_id in
(select elig_cvrd_dpnt_id from ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f where person_id =p_person_id));

delete from ben_elig_cvrd_dpnt_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f where person_id =p_person_id);

delete from ben_elig_dpnt where per_in_ler_id in
(select per_in_ler_id from ben_per_in_ler where person_id =p_person_id);

delete from ben_pl_bnf_ctfn_prvdd_f where pl_bnf_id in
(select pl_bnf_id from ben_pl_bnf_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f where person_id =p_person_id));

delete from ben_pl_bnf_f where prtt_enrt_rslt_id in
(select prtt_enrt_rslt_id from ben_prtt_enrt_rslt_f where person_id =p_person_id);

delete from ben_prtt_enrt_rslt_f where person_id =p_person_id;

delete from ben_per_cm_prvdd_f where per_cm_id in
(select per_cm_id from ben_per_cm_f where person_id =p_person_id);

delete from ben_per_cm_trgr_f where per_cm_id in
(select per_cm_id from ben_per_cm_f where person_id =p_person_id);

delete from ben_per_cm_usg_f where per_cm_id in
(select per_cm_id from ben_per_cm_f where person_id =p_person_id);

delete from ben_per_cm_f where person_id =p_person_id;

delete from ben_per_in_ler where person_id =p_person_id;

delete from ben_ptnl_ler_for_per where person_id =p_person_id;

delete from ben_elig_per_opt_f where elig_per_id in
(select elig_per_id from ben_elig_per_f where person_id =p_person_id);

delete from ben_elig_per_f where person_id =p_person_id;

-- delete from extrat
delete from ben_ext_rslt_dtl      where person_id=p_person_id;
delete from ben_ext_rslt_err      where person_id=p_person_id;
delete from ben_ext_chg_evt_log   where person_id=p_person_id;
--

delete from per_addresses where person_id=p_person_id;
delete from per_assignment_extra_info  where assignment_id in
(select assignment_id from per_all_assignments_f where person_id=p_person_id);


delete from per_all_assignments_f where person_id=p_person_id;
delete from per_person_type_usages_f where person_id=p_person_id;
delete from per_periods_of_service where person_id=p_person_id;
delete from per_contact_relationships where person_id=p_person_id;
delete from per_absence_attendances where person_id=p_person_id;
delete from per_all_people_f where person_id=p_person_id;

hr_general.g_data_migrator_mode := 'N';

exception
  when others then
       rollback;
       raise;
end delete_person;

end ben_dm_delete;

/
