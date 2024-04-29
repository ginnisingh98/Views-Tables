--------------------------------------------------------
--  DDL for Package Body BEN_EXT_DPNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_DPNT" as
/* $Header: benxdpnt.pkb 120.1 2007/10/16 23:18:59 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ext_dpnt.';  -- Global package name
--
-- procedure to initialize the globals - May, 99
-- ----------------------------------------------------------------------------
-- |---------------------< initialize_globals >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE initialize_globals IS
  --
  l_proc             varchar2(72) := g_package||'initialize_globals';
  --
Begin
--
  --
  hr_utility.set_location('Entering'||l_proc, 5);
  --
    --
    ben_ext_person.g_dpnt_cvrd_dpnt_id        := null;
    ben_ext_person.g_dpnt_cvg_strt_dt         := null;
    ben_ext_person.g_dpnt_cvg_thru_dt         := null;
    ben_ext_person.g_dpnt_rlshp_type          := null;
    ben_ext_person.g_dpnt_contact_seq_num     := null;
    ben_ext_person.g_dpnt_shared_resd_flag    := null;
    ben_ext_person.g_dpnt_national_identifier := null;
    ben_ext_person.g_dpnt_last_name           := null;
    ben_ext_person.g_dpnt_first_name          := null;
    ben_ext_person.g_dpnt_middle_names        := null;
    ben_ext_person.g_dpnt_full_name           := null;
    ben_ext_person.g_dpnt_suffix              := null;
    ben_ext_person.g_dpnt_prefix              := null;
    ben_ext_person.g_dpnt_title               := null;
    ben_ext_person.g_dpnt_date_of_birth       := null;
    ben_ext_person.g_dpnt_marital_status      := null;
    ben_ext_person.g_dpnt_sex                 := null;
    ben_ext_person.g_dpnt_disabled_flag       := null;
    ben_ext_person.g_dpnt_student_status      := null;
    ben_ext_person.g_dpnt_date_of_death       := null;
    ben_ext_person.g_dpnt_language            := null;
    ben_ext_person.g_dpnt_nationality         := null;
    ben_ext_person.g_dpnt_email_address       := null;
    ben_ext_person.g_dpnt_known_as            := null;
    ben_ext_person.g_dpnt_known_as            := null;
    ben_ext_person.g_dpnt_pre_name_adjunct    := null;
    ben_ext_person.g_dpnt_tobacco_usage       := null;
    ben_ext_person.g_dpnt_prev_last_name      := null;
    ben_ext_person.g_dpnt_prim_address1       := null;
    ben_ext_person.g_dpnt_prim_address2       := null;
    ben_ext_person.g_dpnt_prim_address3       := null;
    ben_ext_person.g_dpnt_prim_city           := null;
    ben_ext_person.g_dpnt_prim_state          := null;
    ben_ext_person.g_dpnt_prim_postal_code    := null;
    ben_ext_person.g_dpnt_prim_country        := null;
    ben_ext_person.g_dpnt_prim_effect_date    := null;
    ben_ext_person.g_dpnt_prim_region         := null;
    ben_ext_person.g_dpnt_home_phone          := null;
    ben_ext_person.g_dpnt_work_phone          := null;
    ben_ext_person.g_dpnt_fax                 := null;
    ben_ext_person.g_dpnt_mobile              := null;
    ben_ext_person.g_dpnt_ppr_name            := null;
    ben_ext_person.g_dpnt_ppr_ident           := null;
    ben_ext_person.g_dpnt_ppr_typ             := null;
    ben_ext_person.g_dpnt_ppr_strt_dt         := null;
    ben_ext_person.g_dpnt_ppr_end_dt          := null;
    --
  --
  hr_utility.set_location('Exiting'||l_proc, 15);
  --
End initialize_globals;
--
-- ----------------------------------------------------------------------------
-- |---------------------< main >---------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE main
    (                        p_person_id          in number,
                             p_prtt_enrt_rslt_id  in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date) is
   --
   l_proc             varchar2(72) := g_package||'main';
   l_include          varchar2(1) ;
   --
  cursor c_dpnt (l_prtt_enrt_rslt_id number) is
    select
             a.elig_cvrd_dpnt_id
           , a.cvg_strt_dt
           , a.cvg_thru_dt
           , a.dpnt_person_id
           , a.per_in_ler_id
           , a.prtt_enrt_rslt_id
           , a.last_update_date
           , b.contact_type
           , b.sequence_number
           , b.rltd_per_rsds_w_dsgntr_flag
           , c.last_name
           , c.correspondence_language
           , c.date_of_birth
           , c.email_address
           , c.first_name
           , c.full_name
           , c.marital_status
           , c.middle_names
           , c.nationality
           , c.national_identifier
           , c.registered_disabled_flag
           , c.sex
           , c.student_status
           , c.suffix
           , c.pre_name_adjunct prefix
           , c.title
           , c.date_of_death
           , c.known_as
           , c.pre_name_adjunct
           , c.uses_tobacco_flag
           , c.previous_last_name
       from ben_elig_cvrd_dpnt_f           a,
            per_contact_relationships      b,
            per_all_people_f               c
       where
            a.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
        and a.cvg_pndg_flag = 'N'
    --  remarked for bug 1394604
    --    and p_effective_date between a.cvg_strt_dt
    --                             and a.cvg_thru_dt
    --    and a.cvg_thru_dt <= a.effective_end_date
        --
        and a.dpnt_person_id = b.contact_person_id
        and b.person_id = p_person_id
        --
        and c.person_id = a.dpnt_person_id
        and p_effective_date between c.effective_start_date
                                 and c.effective_end_date
        and p_effective_date between a.effective_start_date
                                 and a.effective_end_date
        and p_effective_date between nvl(b.date_Start,p_effective_date)
                                 and nvl(b.date_end ,p_effective_date)
      ;


  cursor c_pil (p_per_in_ler_id number) is
  select pil.PER_IN_LER_STAT_CD,
        pil.LF_EVT_OCRD_DT,
        pil.NTFN_DT,
        pil.LER_ID
   from ben_per_in_ler pil
   where pil.per_in_ler_id = p_per_in_ler_id ;

   l_per_in_ler_stat_cd ben_per_in_ler.PER_IN_LER_STAT_CD%Type ;
   l_LF_EVT_OCRD_DT     ben_per_in_ler.LF_EVT_OCRD_DT%type ;
   l_NTFN_DT            ben_per_in_ler.NTFN_DT%type ;
   l_ler_id             ben_per_in_ler.ler_id%type ;




--
cursor prim_address_c(p_dpnt_person_id number) is
    select
         a.address_line1
       , a.address_line2
       , a.address_line3
       , a.town_or_city
       , a.region_2
       , a.postal_code
       , a.country
       , a.date_from
       , a.region_3
    from per_addresses  a
    where
          a.person_id = p_dpnt_person_id
      and p_effective_date between nvl(a.date_from, p_effective_date)
                              and nvl(a.date_to, p_effective_date)
      and a.primary_flag = 'Y'
      ;
--
    cursor prim_rltd_address_c(p_dpnt_person_id number)  is
    select
         a.address_line1
       , a.address_line2
       , a.address_line3
       , a.town_or_city
       , a.region_2
       , a.postal_code
       , a.country
       , a.date_from
       , a.region_3
    from per_addresses  a,
         per_contact_relationships r
    where
          r.contact_person_id = p_dpnt_person_id
      and r.person_id = p_person_id
      and r.person_id = a.person_id
      and p_effective_date between nvl(a.date_from, p_effective_date)
                              and nvl(a.date_to, p_effective_date)
      and a.primary_flag = 'Y'
      and r.rltd_per_rsds_w_dsgntr_flag = 'Y'
      /* Start of Changes for WWBUG: 1856611: addition	*/
      and p_effective_date between r.date_start
                           and nvl(r.date_end,hr_api.g_eot)
      /* End of Changes for WWBUG: 1856611: addition	*/
      ;
   --
cursor ext_phone_c(p_dpnt_person_id number) is
   select
          h.phone_number  phone_home
        , w.phone_number  phone_work
        , f.phone_number  phone_fax
        , m.phone_number  phone_mobile
    from  per_all_people_f  p
        , per_phones        h
        , per_phones        w
        , per_phones        f
        , per_phones        m
   where  p.person_id = p_dpnt_person_id
     and  p_effective_date between nvl(p.effective_start_date, p_effective_date)
                              and nvl(p.effective_end_date, p_effective_date)
     and  h.parent_id (+) = p.person_id
     and  w.parent_id (+) = p.person_id
     and  f.parent_id (+) = p.person_id
     and  m.parent_id (+) = p.person_id
     and  h.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  w.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  f.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  m.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  h.phone_type (+) = 'H1'
     and  w.phone_type (+) = 'W1'
     and  f.phone_type (+) = 'WF'
     and  m.phone_type (+) = 'M'
     and  p_effective_date between nvl(h.date_from, p_effective_date)
                              and nvl(h.date_to, p_effective_date)
     and  p_effective_date between nvl(w.date_from, p_effective_date)
                              and nvl(w.date_to, p_effective_date)
     and  p_effective_date between nvl(f.date_from, p_effective_date)
                              and nvl(f.date_to, p_effective_date)
     and  p_effective_date between nvl(m.date_from, p_effective_date)
                              and nvl(m.date_to, p_effective_date)
     ;

--
  cursor c_dpnt_prmry_care_prvdr(p_elig_cvrd_dpnt_id  number) is
  SELECT name
        ,ext_ident
        ,prmry_care_prvdr_typ_cd
        ,effective_start_date
        ,effective_end_date
  FROM   ben_prmry_care_prvdr_f ppr
  WHERE  ppr.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
  AND    p_effective_date between ppr.effective_start_date
         and ppr.effective_end_date;
 --
 --
 BEGIN
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   hr_utility.set_location('before loop', 604);
   --
   FOR dpnt IN c_dpnt(p_prtt_enrt_rslt_id) LOOP
            --
            hr_utility.set_location('internal  loop', 604);
            -- initialize the globals - May, 99
            initialize_globals;
            --validationg the  coverage date
            --if it is change  event and for the dependent then
            --extract only the dependent
            hr_utility.set_location('param ' || ben_ext_person.g_chg_prmtr_06 ,88);
            hr_utility.set_location('dependent ' || dpnt.dpnt_person_id ,88);
            hr_utility.set_location('rslt ' || ben_ext_person.g_chg_prmtr_06 ,88);
            hr_utility.set_location('prm rslt ' || p_prtt_enrt_rslt_id ,88);


            --- get the pil info from ecdpnt per in ler id
            open c_pil (dpnt.per_in_ler_id) ;
            fetch c_pil into
                  l_per_in_ler_stat_cd,
                  l_LF_EVT_OCRD_DT,
                  l_NTFN_DT ,
                  l_ler_id ;
             close c_pil ;



            ben_ext_evaluate_inclusion.evaluate_benefit_incl(
               p_enrt_cvg_strt_dt => dpnt.cvg_strt_dt,
               p_enrt_cvg_thru_dt => dpnt.cvg_thru_dt,
               p_pl_id                  => ben_ext_person.g_enrt_pl_id ,
               p_sspndd_flag            => ben_ext_person.g_enrt_suspended_flag,
               p_prtt_enrt_rslt_stat_cd => ben_ext_person.g_enrt_status_cd,
               p_enrt_mthd_cd           => ben_ext_person.g_enrt_method,
               p_pgm_id                 => ben_ext_person.g_enrt_pgm_id ,
               p_pl_typ_id              => ben_ext_person.g_enrt_pl_typ_id,
               p_last_update_date       => dpnt.last_update_date,
               p_ler_id                 => nvl(l_ler_id,ben_ext_person.g_enrt_ler_id),
               p_ntfn_dt                => nvl(l_NTFN_DT,ben_ext_person.g_enrt_lfevt_note_dt),
               p_lf_evt_ocrd_dt         => nvl(l_LF_EVT_OCRD_DT,ben_ext_person.g_enrt_lfevt_ocrd_dt) ,
               p_per_in_ler_stat_cd     => nvl(l_per_in_ler_stat_cd,ben_ext_person.g_enrt_lfevt_status),
               p_per_in_ler_id          => dpnt.per_in_ler_id,
               p_prtt_enrt_rslt_id      => dpnt.prtt_enrt_rslt_id,
               p_effective_date         => p_effective_date,
               p_dpnt_id                => dpnt.dpnt_person_id,
               p_include                => l_include);

           hr_utility.set_location('inclide '||l_include , 604);

           IF l_include = 'Y' THEN
               --
               hr_utility.set_location(' internal loo include  '||dpnt.full_name ,604);
               -- fetch dependent information into globals
               --
               --RCHASE - Bug#6669 - Must initialize the g_dpnt_cvrd_dpnt_id cache entry
               ben_ext_person.g_dpnt_cvrd_dpnt_id        := dpnt.elig_cvrd_dpnt_id;
               --RCHASE - End
               ben_ext_person.g_dpnt_cvg_strt_dt         := dpnt.cvg_strt_dt;
               ben_ext_person.g_dpnt_cvg_thru_dt         := dpnt.cvg_thru_dt;
               ben_ext_person.g_dpnt_rlshp_type          := dpnt.contact_type;
               ben_ext_person.g_dpnt_contact_seq_num     := dpnt.sequence_number;
               ben_ext_person.g_dpnt_shared_resd_flag    := dpnt.rltd_per_rsds_w_dsgntr_flag;
               ben_ext_person.g_dpnt_national_identifier := dpnt.national_identifier;
               ben_ext_person.g_dpnt_last_name           := dpnt.last_name;
               ben_ext_person.g_dpnt_first_name          := dpnt.first_name;
               ben_ext_person.g_dpnt_middle_names        := dpnt.middle_names;
               ben_ext_person.g_dpnt_full_name           := dpnt.full_name;
               ben_ext_person.g_dpnt_suffix              := dpnt.suffix;
               ben_ext_person.g_dpnt_prefix              := dpnt.prefix;
               ben_ext_person.g_dpnt_title               := dpnt.title;
               ben_ext_person.g_dpnt_date_of_birth       := dpnt.date_of_birth;
               ben_ext_person.g_dpnt_marital_status      := dpnt.marital_status;
               ben_ext_person.g_dpnt_sex                 := dpnt.sex;
               ben_ext_person.g_dpnt_disabled_flag       := dpnt.registered_disabled_flag;
               ben_ext_person.g_dpnt_student_status      := dpnt.student_status;
               ben_ext_person.g_dpnt_date_of_death       := dpnt.date_of_death;
               ben_ext_person.g_dpnt_language            := dpnt.correspondence_language;
               ben_ext_person.g_dpnt_nationality         := dpnt.nationality;
               ben_ext_person.g_dpnt_email_address       := dpnt.email_address;
               ben_ext_person.g_dpnt_known_as            := dpnt.known_as;
               ben_ext_person.g_dpnt_pre_name_adjunct    := dpnt.pre_name_adjunct;
               ben_ext_person.g_dpnt_tobacco_usage       := dpnt.uses_tobacco_flag;
               ben_ext_person.g_dpnt_prev_last_name      := dpnt.previous_last_name;
      --   end if ;
         --
         -- retrieve dependent address info if required
            if ben_extract.g_da_csr = 'Y' then
              open prim_address_c(dpnt.dpnt_person_id);
              fetch prim_address_c into ben_ext_person.g_dpnt_prim_address1
                                       ,ben_ext_person.g_dpnt_prim_address2
                                       ,ben_ext_person.g_dpnt_prim_address3
                                       ,ben_ext_person.g_dpnt_prim_city
                                       ,ben_ext_person.g_dpnt_prim_state
                                       ,ben_ext_person.g_dpnt_prim_postal_code
                                       ,ben_ext_person.g_dpnt_prim_country
                                       ,ben_ext_person.g_dpnt_prim_effect_date
                                       ,ben_ext_person.g_dpnt_prim_region;
                 if prim_address_c%notfound then
                   open prim_rltd_address_c(dpnt.dpnt_person_id);
                   fetch prim_rltd_address_c into ben_ext_person.g_dpnt_prim_address1
                                         , ben_ext_person.g_dpnt_prim_address2
                                         , ben_ext_person.g_dpnt_prim_address3
                                         , ben_ext_person.g_dpnt_prim_city
                                         , ben_ext_person.g_dpnt_prim_state
                                         , ben_ext_person.g_dpnt_prim_postal_code
                                         , ben_ext_person.g_dpnt_prim_country
                                         , ben_ext_person.g_dpnt_prim_effect_date
                                         , ben_ext_person.g_dpnt_prim_region;
                   close prim_rltd_address_c;
		     end if;
              close prim_address_c;
            end if;
         --
         -- retrieve dependent phone numbers if required
            if ben_extract.g_dp_csr = 'Y' then
              open ext_phone_c(dpnt.dpnt_person_id);
              fetch ext_phone_c into ben_ext_person.g_dpnt_home_phone
                                    ,ben_ext_person.g_dpnt_work_phone
                                    ,ben_ext_person.g_dpnt_fax
                                    ,ben_ext_person.g_dpnt_mobile;
              close ext_phone_c;
            end if;
         --
         -- retrieve dependent primary care provider info if required
            if ben_extract.g_dpcp_csr = 'Y' then
              open c_dpnt_prmry_care_prvdr(dpnt.elig_cvrd_dpnt_id);
              fetch c_dpnt_prmry_care_prvdr into ben_ext_person.g_dpnt_ppr_name
                                              ,ben_ext_person.g_dpnt_ppr_ident
                                              ,ben_ext_person.g_dpnt_ppr_typ
                                              ,ben_ext_person.g_dpnt_ppr_strt_dt
                                              ,ben_ext_person.g_dpnt_ppr_end_dt;
              close c_dpnt_prmry_care_prvdr;
            end if;
            --
            -- format and write
            --
            ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                         p_ext_file_id       => p_ext_file_id,
                                         p_data_typ_cd       => p_data_typ_cd,
                                         p_ext_typ_cd        => p_ext_typ_cd,
                                         p_rcd_typ_cd        => 'D',
                                         p_low_lvl_cd        => 'D',
                                         p_person_id         => p_person_id,
                                         p_chg_evt_cd        => p_chg_evt_cd,
                                         p_business_group_id => p_business_group_id,
                                         p_effective_date    => p_effective_date
                                        );
        end if ;
     --
   END LOOP;
   --
   hr_utility.set_location('Exiting'||l_proc, 15);

 END; -- main
--
END; -- package

/
