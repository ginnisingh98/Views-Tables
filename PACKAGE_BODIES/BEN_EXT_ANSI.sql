--------------------------------------------------------
--  DDL for Package Body BEN_EXT_ANSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_ANSI" as
/* $Header: benxansi.pkb 120.2 2006/07/18 18:43:36 tjesumic ship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
--
g_package  varchar2(33)	:= '  ben_ext_ansi.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< main >----------------------------------------------|
-- ----------------------------------------------------------------------------

--
Procedure main(
                             p_person_id          in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_ext_crit_prfl_id   in number,
                             p_business_group_id  in number,
                             p_effective_date     in date
                            ) IS
--
  l_proc               varchar2(72) := g_package||'main';
--
  l_ansi_subscriber_flag varchar2(1);
  l_include varchar2(1);
--
   cursor c_enrt_rslt is
      select rslt.pl_id,
             rslt.enrt_cvg_strt_dt,
             rslt.enrt_cvg_thru_dt,
             rslt.sspndd_flag,
             rslt.prtt_enrt_rslt_stat_cd,
             rslt.enrt_mthd_cd,
             rslt.pgm_id,
             rslt.pl_typ_id,
             rslt.per_in_ler_id,
             rslt.prtt_enrt_rslt_id,
             rslt.last_update_date,
             pil.ler_id,
             pil.per_in_ler_stat_cd,
             pil.lf_evt_ocrd_dt,
             pil.ntfn_dt
      from ben_prtt_enrt_rslt_f rslt,
           ben_per_in_ler pil
      where rslt.person_id = p_person_id
  AND pil.per_in_ler_id(+) = rslt.per_in_ler_id
  and p_effective_date between rslt.effective_start_date
         and rslt.effective_end_date;
--
  cursor c_dpnt_of_distinct_participant is
  select distinct rslt.person_id
  FROM   ben_prtt_enrt_rslt_f rslt,
         ben_elig_cvrd_dpnt_f dpnt
  WHERE  rslt.prtt_enrt_rslt_id = dpnt.prtt_enrt_rslt_id
  AND    dpnt.dpnt_person_id = p_person_id
  --AND    p_effective_date between rslt.enrt_cvg_strt_dt
  --       and rslt.enrt_cvg_thru_dt
  -- when the person and dpnt coverd fonm, person extracted not the dpnt
  AND    p_effective_date between rslt.effective_start_date
         and rslt.effective_end_date
  AND    p_effective_date between dpnt.effective_start_date
              and dpnt.effective_end_date;

  cursor c_cvrd_dpnt(p_prtt_person_id in number, p_dpnt_person_id in number) is
  SELECT rslt.pl_id,
         rslt.sspndd_flag,
         dpnt.cvg_strt_dt,
         dpnt.cvg_thru_dt,
         rslt.prtt_enrt_rslt_stat_cd,
         rslt.enrt_mthd_cd,
         rslt.pgm_id,
         rslt.pl_typ_id,
         rslt.per_in_ler_id,
         rslt.prtt_enrt_rslt_id,
         rslt.last_update_date,
         pil.ler_id,
         pil.per_in_ler_stat_cd,
         pil.lf_evt_ocrd_dt,
         pil.ntfn_dt
  FROM   ben_prtt_enrt_rslt_f rslt,
         ben_elig_cvrd_dpnt_f dpnt,
         ben_per_in_ler pil
  WHERE  rslt.prtt_enrt_rslt_id = dpnt.prtt_enrt_rslt_id
  and    rslt.per_in_ler_id = pil.per_in_ler_id(+)
  AND    dpnt.dpnt_person_id = p_dpnt_person_id
  and    rslt.person_id = p_prtt_person_id
  --AND    p_effective_date between rslt.enrt_cvg_strt_dt
  --       and rslt.enrt_cvg_thru_dt
  AND    p_effective_date between rslt.effective_start_date
         and rslt.effective_end_date
  AND    p_effective_date between dpnt.effective_start_date
              and dpnt.effective_end_date;

  --
  cursor c_get_contact_info (p_person_id number,p_dpnt_person_id number,p_effective_date date) is
     select c.contact_type,
        p.national_identifier,
        p.first_name,
        p.last_name,
        c.SEQUENCE_NUMBER
   from
        per_contact_relationships      c,
        per_all_people_f               p
   where
        c.contact_person_id = p_dpnt_person_id
    and c.person_id = p_person_id
    and c.person_id = p.person_id
    and p_effective_date between nvl(p.effective_start_date, p_effective_date)
                            and nvl(p.effective_end_date, p_effective_date)
    and p_effective_date between nvl(c.date_Start,p_effective_date)
                            and nvl(c.date_end ,p_effective_date)
    order by c.sequence_number, decode(c.contact_type,'EMRG',2,1)  ;
    l_rollback boolean ;
    l_dpnt_cvg_thru_dt  date ;


   cursor c_get_contact_info2 (p_person_id number,p_dpnt_person_id number,p_effective_date date) is
     select c.contact_type,
        p.national_identifier,
        p.first_name,
        p.last_name,
        c.SEQUENCE_NUMBER
   from
        per_contact_relationships      c,
        per_all_people_f               p
   where
        c.contact_person_id = p_dpnt_person_id
    and c.person_id = p_person_id
    and c.person_id = p.person_id
    and p_effective_date between nvl(p.effective_start_date, p_effective_date)
                            and nvl(p.effective_end_date, p_effective_date)
    and p_effective_date >=  nvl(c.date_Start,p_effective_date)
    order by c.sequence_number, decode(c.contact_type,'EMRG',2,1),c.date_end desc  ;


--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
  --
  --  new way of determining if this person is a participant (aka subscriber);
      l_include := 'N';
      for enrt in c_enrt_rslt loop
          ben_ext_evaluate_inclusion.evaluate_benefit_incl
               (p_pl_id    => enrt.pl_id,
                p_sspndd_flag => enrt.sspndd_flag,
                p_enrt_cvg_strt_dt => enrt.enrt_cvg_strt_dt,
                p_enrt_cvg_thru_dt => enrt.enrt_cvg_thru_dt,
                p_prtt_enrt_rslt_stat_cd => enrt.prtt_enrt_rslt_stat_cd,
                p_enrt_mthd_cd     => enrt.enrt_mthd_cd,
                p_pgm_id =>  enrt.pgm_id,
                p_pl_typ_id    =>  enrt.pl_typ_id,
                p_last_update_date => enrt.last_update_date,
                p_ler_id    => enrt.ler_id,
                p_ntfn_dt      => enrt.ntfn_dt,
                p_lf_evt_ocrd_dt  => enrt.lf_evt_ocrd_dt,
                p_per_in_ler_stat_cd  => enrt.per_in_ler_stat_cd,
                p_per_in_ler_id    => enrt.per_in_ler_id,
                p_prtt_enrt_rslt_id => enrt.prtt_enrt_rslt_id,
                p_effective_date => p_effective_date,
                p_include => l_include);
        --
        if l_include = 'Y' then -- l_include means they met inclusion criteria.
          exit;
        end if;
      --
      end loop;
      --
       if l_include = 'Y' then
         ben_ext_person.g_part_type := 'P'; -- Participant (aka Subscriber)
         ben_ext_person.g_per_rlshp_type := '18'; -- 18 is 'Self'
         ben_ext_person.g_part_ssn :=
                 ben_ext_person.g_national_identifier;  --this is the reference ssn
         ben_ext_person.g_part_first_name :=
                 ben_ext_person.g_first_name;  --this is the reference first name
         ben_ext_person.g_part_last_name :=
                 ben_ext_person.g_last_name;  --this is the reference last name
         --
         if ben_extract.g_per_lvl = 'Y' THEN
           --
           --  Process Person Level Records
           --
           ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                 p_ext_file_id       => p_ext_file_id,
                                 p_data_typ_cd       => p_data_typ_cd,
                                 p_ext_typ_cd        => p_ext_typ_cd,
                                 p_rcd_typ_cd        => 'D',
                                 p_low_lvl_cd        => 'P',
                                 p_person_id         => p_person_id,
                                 p_chg_evt_cd        => ben_ext_person.g_chg_evt_cd,
                                 p_business_group_id => p_business_group_id,
                                 p_effective_date    => p_effective_date
                                 );
         --
         end if;
         --
         -- Process Enrollment Level Records
         --
         IF ben_ext_person.g_part_type = 'P' AND ben_extract.g_enrt_lvl = 'Y' then
          --
          -- create enrollment extract rows
          -- =========================================
           ben_ext_enrt.main(
                             p_person_id          => p_person_id,
                             p_ext_rslt_id        => p_ext_rslt_id,
                             p_ext_file_id        => p_ext_file_id,
                             p_data_typ_cd        => p_data_typ_cd,
                             p_ext_typ_cd         => p_ext_typ_cd,
                             p_chg_evt_cd         => ben_ext_person.g_chg_evt_cd,
                             p_business_group_id  => p_business_group_id,
                             p_effective_date     => p_effective_date);
           --
         end if;
         --
       end if;  -- l_include = 'Y'
       --
       -- create eligibility extract rows
       -- =========================================
       if ben_extract.g_elig_lvl = 'Y' then
         --
         ben_ext_elig.main(
                          p_person_id         => p_person_id,
                                                         -- p_per_in_ler_id     => ben_ext_person.g_per_in_ler_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_chg_evt_cd        => ben_ext_person.g_chg_evt_cd,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => p_effective_date
                         );
         --
         --
       end if;
       --
       --
       -- remember a person can be both a subsciber of one plan and a dependent of another!
       --
       hr_utility.set_location (' try as dpnt ' , 99 ) ;
       ben_ext_person.g_part_type := 'D'; -- Dependent
       -- remember a person can be a dpnt for two diff subscribers.
       for i in c_dpnt_of_distinct_participant loop
         --
         hr_utility.set_location (' dpnt loop ' , 99 ) ;
         --  now loop through each of their enrollments and see if they are included.
         --
         l_include := 'N';
         for j in c_cvrd_dpnt(i.person_id,p_person_id) loop
             --
           ben_ext_evaluate_inclusion.evaluate_benefit_incl
               (p_pl_id    => j.pl_id,
                p_sspndd_flag => j.sspndd_flag,
                p_enrt_cvg_strt_dt => j.cvg_strt_dt,
                p_enrt_cvg_thru_dt => j.cvg_thru_dt,
                p_prtt_enrt_rslt_stat_cd => j.prtt_enrt_rslt_stat_cd,
                p_enrt_mthd_cd     => j.enrt_mthd_cd,
                p_pgm_id =>  j.pgm_id,
                p_pl_typ_id    =>  j.pl_typ_id,
                p_last_update_date => j.last_update_date,
                p_ler_id    => j.ler_id,
                p_ntfn_dt      => j.ntfn_dt,
                p_lf_evt_ocrd_dt  => j.lf_evt_ocrd_dt,
                p_per_in_ler_stat_cd  => j.per_in_ler_stat_cd,
                p_per_in_ler_id    => j.per_in_ler_id,
                p_prtt_enrt_rslt_id => j.prtt_enrt_rslt_id,
                p_effective_date => p_effective_date,
                p_include => l_include);
           --
           l_dpnt_cvg_thru_dt  := j.cvg_thru_dt ;

           hr_utility.set_location (' dpnt cvg thryu dat  ' || l_dpnt_cvg_thru_dt   , 99 ) ;
           hr_utility.set_location (' dpnt include ' || l_include  , 99 ) ;
           if l_include = 'Y' then -- l_include means they met inclusion criteria.
             exit;  -- out of j loop.
           end if;
           --
         end loop;   -- j
         --
         -- this will retreive the relationship between the two people.
         --
         if l_include = 'Y' then
           --
           open c_get_contact_info(i.person_id, p_person_id, p_effective_date);
           fetch c_get_contact_info into ben_ext_person.g_per_rlshp_type,
                                         ben_ext_person.g_part_ssn,
                                         ben_ext_person.g_part_first_name,
                                         ben_ext_person.g_part_last_name,
                                         ben_ext_person.g_dpnt_contact_seq_num;

           --- 5264053 if the contact relationship end dated then
           --- get the contact latest  information
           if c_get_contact_info%notfound  then
              --if l_dpnt_cvg_thru_dt is not null and l_dpnt_cvg_thru_dt <> hr_api.g_eot then
              open c_get_contact_info2(i.person_id, p_person_id,p_effective_date);
              fetch c_get_contact_info2 into ben_ext_person.g_per_rlshp_type,
                                         ben_ext_person.g_part_ssn,
                                         ben_ext_person.g_part_first_name,
                                         ben_ext_person.g_part_last_name,
                                         ben_ext_person.g_dpnt_contact_seq_num;
              close c_get_contact_info2;
              --end if ;
           end if ;


           close c_get_contact_info;
           --
           if ben_extract.g_per_lvl = 'Y' THEN
             --
             --  Process Person Level Records
             --
             ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                 p_ext_file_id       => p_ext_file_id,
                                 p_data_typ_cd       => p_data_typ_cd,
                                 p_ext_typ_cd        => p_ext_typ_cd,
                                 p_rcd_typ_cd        => 'D',
                                 p_low_lvl_cd        => 'P',
                                 p_person_id         => p_person_id,
                                 p_chg_evt_cd        => ben_ext_person.g_chg_evt_cd,
                                 p_business_group_id => p_business_group_id,
                                 p_effective_date    => p_effective_date
                                 );
             --
           end if;
           --
           -- Process Enrollment Level Records
           --
           if ben_ext_person.g_part_type = 'D'  and ben_extract.g_enrt_lvl = 'Y' then
             --
             ben_ext_enrt_spcl.main(
                             p_dpnt_person_id     => p_person_id,
                             p_prtt_person_id     => i.person_id,
                             p_ext_rslt_id        => p_ext_rslt_id,
                             p_ext_file_id        => p_ext_file_id,
                             p_data_typ_cd        => p_data_typ_cd,
                             p_ext_typ_cd         => p_ext_typ_cd,
                             p_chg_evt_cd         => ben_ext_person.g_chg_evt_cd,
                             p_business_group_id  => p_business_group_id,
                             p_effective_date     => p_effective_date
                             );
           --
           end if;  -- part type
           --
         end if;  -- l_include = 'Y'
         --
       end loop; -- i


        -- validate the mandatory for low level in sequenc
       FOR i in ben_extract.gtt_rcd_rqd_vals_seq.first .. ben_extract.gtt_rcd_rqd_vals_seq.last LOOP
           --
           If NOT ben_extract.gtt_rcd_rqd_vals_seq(i).rcd_found THEN
              hr_utility.set_location('Mandatory failed '||ben_extract.gtt_rcd_rqd_vals_seq(i).low_lvl_cd || '  '||
                                                             ben_extract.gtt_rcd_rqd_vals_seq(i).seq_num , 15);
              l_rollback := TRUE;        -- raise required_error;
           end if ;

           if ben_extract.gtt_rcd_rqd_vals_seq(1).low_lvl_cd <> 'NOREQDRCD' then
              ben_extract.gtt_rcd_rqd_vals_seq(i).rcd_found := false ;
           end if ;
       END LOOP;
       --

       if  l_rollback then
           hr_utility.set_location(' record not found ' || l_proc, 15) ;
           raise ben_ext_person.required_error ;
       end if ;

       --
  hr_utility.set_location('Exiting'||l_proc, 15);
--
End main;
--
--
END ben_ext_ansi;

/
