--------------------------------------------------------
--  DDL for Package Body BEN_EXT_ELIG_DPNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_ELIG_DPNT" as
/* $Header: benxeldp.pkb 120.2 2007/07/16 23:46:52 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ext_elig_dpnt.';  -- Global package name


TYPE t_number       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_varchar2_30  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_varchar2_600 IS TABLE OF VARCHAR2(600) INDEX BY BINARY_INTEGER;
TYPE t_date         IS TABLE OF Date  INDEX BY BINARY_INTEGER;

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
    ben_ext_person.g_elig_dpnt_elig_strt_dt        := null;
    ben_ext_person.g_elig_dpnt_elig_thru_dt        := null;
    ben_ext_person.g_elig_dpnt_create_dt           := null;
    ben_ext_person.g_elig_dpnt_ovrdn_flag          := null;
    ben_ext_person.g_elig_dpnt_ovrdn_thru_dt       := null;
    ben_ext_person.g_elig_dpnt_rlshp_type          := null;
    ben_ext_person.g_elig_dpnt_contact_seq_num     := null;
    ben_ext_person.g_elig_dpnt_shared_resd_flag    := null;
    ben_ext_person.g_elig_dpnt_national_ident      := null;
    ben_ext_person.g_elig_dpnt_last_name           := null;
    ben_ext_person.g_elig_dpnt_first_name          := null;
    ben_ext_person.g_elig_dpnt_middle_names        := null;
    ben_ext_person.g_elig_dpnt_full_name           := null;
    ben_ext_person.g_elig_dpnt_suffix              := null;
    ben_ext_person.g_elig_dpnt_title               := null;
    ben_ext_person.g_elig_dpnt_date_of_birth       := null;
    ben_ext_person.g_elig_dpnt_marital_status      := null;
    ben_ext_person.g_elig_dpnt_sex                 := null;
    ben_ext_person.g_elig_dpnt_disabled_flag       := null;
    ben_ext_person.g_elig_dpnt_student_status      := null;
    ben_ext_person.g_elig_dpnt_date_of_death       := null;
    ben_ext_person.g_elig_dpnt_language            := null;
    ben_ext_person.g_elig_dpnt_nationality         := null;
    ben_ext_person.g_elig_dpnt_email_address       := null;
    ben_ext_person.g_elig_dpnt_known_as            := null;
    ben_ext_person.g_elig_dpnt_pre_name_adjunct    := null;
    ben_ext_person.g_elig_dpnt_tobacco_usage       := null;
    ben_ext_person.g_elig_dpnt_prev_last_name      := null;
    ben_ext_person.g_elig_dpnt_prim_address1       := null;
    ben_ext_person.g_elig_dpnt_prim_address2       := null;
    ben_ext_person.g_elig_dpnt_prim_address3       := null;
    ben_ext_person.g_elig_dpnt_prim_city           := null;
    ben_ext_person.g_elig_dpnt_prim_state          := null;
    ben_ext_person.g_elig_dpnt_prim_postal_code    := null;
    ben_ext_person.g_elig_dpnt_prim_country        := null;
    ben_ext_person.g_elig_dpnt_prim_effect_date    := null;
    ben_ext_person.g_elig_dpnt_prim_region         := null;
    ben_ext_person.g_elig_dpnt_home_phone          := null;
    ben_ext_person.g_elig_dpnt_work_phone          := null;
    ben_ext_person.g_elig_dpnt_fax                 := null;
    ben_ext_person.g_elig_dpnt_mobile              := null;
    ben_ext_person.g_elig_dpnt_id                  := null;
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
                             p_elig_per_elctbl_chc_id  in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date) is
   --
   l_proc             varchar2(72) := g_package||'main';
   -- Declare bulk bind variable
   l_dpel_create_dt_va                    t_date         ;
   l_dpel_elig_cvrd_dpnt_id_va            t_number       ;
   l_dpel_elig_strt_dt_va                 t_date         ;
   l_dpel_elig_thru_dt_va                 t_date         ;
   l_dpel_ovrdn_flag_va                   t_varchar2_30  ;
   l_dpel_ovrdn_thru_dt_va                t_date         ;
   l_dpel_dpnt_person_id_va               t_number       ;
   l_dpel_elig_dpnt_id_va                 t_number       ;
   l_dpel_contact_type_va                 t_varchar2_30  ;
   l_dpel_sequence_number_va              t_number       ;
   l_dpel_rltd_per_dsgntr_flag_va         t_varchar2_30  ;
   l_dpel_last_name_va                    t_varchar2_600 ;
   l_dpel_correspondence_lang_va          t_varchar2_600 ;
   l_dpel_date_of_birth_va                t_date         ;
   l_dpel_email_address_va                t_varchar2_600 ;
   l_dpel_first_name_va                   t_varchar2_600 ;
   l_dpel_full_name_va                    t_varchar2_600 ;
   l_dpel_marital_status_va               t_varchar2_30  ;
   l_dpel_middle_names_va                 t_varchar2_600 ;
   l_dpel_nationality_va                  t_varchar2_600 ;
   l_dpel_national_identifier_va          t_varchar2_30  ;
   l_dpel_disabled_flag_va                t_varchar2_30  ;
   l_dpel_sex_va                          t_varchar2_30  ;
   l_dpel_student_status_va               t_varchar2_30  ;
   l_dpel_suffix_va                       t_varchar2_30  ;
   l_dpel_title_va                        t_varchar2_30  ;
   l_dpel_date_of_death_va                t_date         ;
   l_dpel_known_as_va                     t_varchar2_600 ;
   l_dpel_pre_name_adjunct_va             t_varchar2_30  ;
   l_dpel_uses_tobacco_flag_va            t_varchar2_30  ;
   l_dpel_previous_last_name_va           t_varchar2_600 ;
   --

  --
  cursor c_dpnt (l_elig_per_elctbl_chc_id number) is
    select
             a.create_dt
           , a.elig_cvrd_dpnt_id
           , a.elig_strt_dt
           , a.elig_thru_dt
           , a.ovrdn_flag
           , a.ovrdn_thru_dt
           , a.dpnt_person_id
           , a.elig_dpnt_id
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
           , c.title
           , c.date_of_death
           , c.known_as
           , c.pre_name_adjunct
           , c.uses_tobacco_flag
           , c.previous_last_name
       from ben_elig_dpnt           a,
            per_contact_relationships      b,
            per_all_people_f               c
       where
            a.elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id
        and a.dpnt_inelig_flag = 'N'
        and a.dpnt_person_id = b.contact_person_id
        and b.person_id = p_person_id
        and c.person_id = a.dpnt_person_id
        and p_effective_date between c.effective_start_date
                                 and c.effective_end_date
        and p_effective_date between b.date_start
                                 and nvl( b.date_end,p_effective_date)
      ;

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
      ;
   --
cursor ext_phone_c (p_dpnt_person_id number) is
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
 BEGIN
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
   --FOR dpnt IN c_dpnt(p_elig_per_elctbl_chc_id) LOOP
   open c_dpnt(p_elig_per_elctbl_chc_id) ;
   fetch c_dpnt bulk collect into
      l_dpel_create_dt_va              ,
      l_dpel_elig_cvrd_dpnt_id_va      ,
      l_dpel_elig_strt_dt_va           ,
      l_dpel_elig_thru_dt_va           ,
      l_dpel_ovrdn_flag_va             ,
      l_dpel_ovrdn_thru_dt_va          ,
      l_dpel_dpnt_person_id_va         ,
      l_dpel_elig_dpnt_id_va           ,
      l_dpel_contact_type_va           ,
      l_dpel_sequence_number_va        ,
      l_dpel_rltd_per_dsgntr_flag_va   ,
      l_dpel_last_name_va              ,
      l_dpel_correspondence_lang_va    ,
      l_dpel_date_of_birth_va          ,
      l_dpel_email_address_va          ,
      l_dpel_first_name_va             ,
      l_dpel_full_name_va              ,
      l_dpel_marital_status_va         ,
      l_dpel_middle_names_va           ,
      l_dpel_nationality_va            ,
      l_dpel_national_identifier_va    ,
      l_dpel_disabled_flag_va          ,
      l_dpel_sex_va                    ,
      l_dpel_student_status_va         ,
      l_dpel_suffix_va                 ,
      l_dpel_title_va                  ,
      l_dpel_date_of_death_va          ,
      l_dpel_known_as_va               ,
      l_dpel_pre_name_adjunct_va       ,
      l_dpel_uses_tobacco_flag_va      ,
      l_dpel_previous_last_name_va     ;

   close c_dpnt ;
   --
   for i  in 1 .. l_dpel_elig_dpnt_id_va.count
   Loop

       initialize_globals;
       --
       -- fetch dependent information into globals
       --
       ben_ext_person.g_elig_dpnt_id                  := l_dpel_elig_dpnt_id_va(i) ;
       ben_ext_person.g_elig_dpnt_create_dt           := l_dpel_create_dt_va(i) ;
       ben_ext_person.g_elig_dpnt_elig_strt_dt        := l_dpel_elig_strt_dt_va(i) ;
       ben_ext_person.g_elig_dpnt_elig_thru_dt        := l_dpel_elig_thru_dt_va(i) ;
       ben_ext_person.g_elig_dpnt_ovrdn_flag          := l_dpel_ovrdn_flag_va(i) ;
       ben_ext_person.g_elig_dpnt_ovrdn_thru_dt       := l_dpel_ovrdn_thru_dt_va(i) ;
       ben_ext_person.g_elig_dpnt_rlshp_type          := l_dpel_contact_type_va(i) ;
       ben_ext_person.g_elig_dpnt_contact_seq_num     := l_dpel_sequence_number_va(i) ;
       ben_ext_person.g_elig_dpnt_shared_resd_flag    := l_dpel_rltd_per_dsgntr_flag_va(i) ;
       ben_ext_person.g_elig_dpnt_national_ident      := l_dpel_national_identifier_va(i) ;
       ben_ext_person.g_elig_dpnt_last_name           := l_dpel_last_name_va(i) ;
       ben_ext_person.g_elig_dpnt_first_name          := l_dpel_first_name_va(i) ;
       ben_ext_person.g_elig_dpnt_middle_names        := l_dpel_middle_names_va(i) ;
       ben_ext_person.g_elig_dpnt_full_name           := l_dpel_full_name_va(i) ;
       ben_ext_person.g_elig_dpnt_suffix              := l_dpel_suffix_va(i) ;
       ben_ext_person.g_elig_dpnt_title               := l_dpel_title_va(i) ;
       ben_ext_person.g_elig_dpnt_date_of_birth       := l_dpel_date_of_birth_va(i) ;
       ben_ext_person.g_elig_dpnt_marital_status      := l_dpel_marital_status_va(i) ;
       ben_ext_person.g_elig_dpnt_sex                 := l_dpel_sex_va(i) ;
       ben_ext_person.g_elig_dpnt_disabled_flag       := l_dpel_disabled_flag_va(i) ;
       ben_ext_person.g_elig_dpnt_student_status      := l_dpel_student_status_va(i) ;
       ben_ext_person.g_elig_dpnt_date_of_death       := l_dpel_date_of_death_va(i) ;
       ben_ext_person.g_elig_dpnt_language            := l_dpel_correspondence_lang_va(i) ;
       ben_ext_person.g_elig_dpnt_nationality         := l_dpel_nationality_va(i) ;
       ben_ext_person.g_elig_dpnt_email_address       := l_dpel_email_address_va(i) ;
       ben_ext_person.g_elig_dpnt_known_as            := l_dpel_known_as_va(i) ;
       ben_ext_person.g_elig_dpnt_pre_name_adjunct    := l_dpel_pre_name_adjunct_va(i) ;
       ben_ext_person.g_elig_dpnt_tobacco_usage       := l_dpel_uses_tobacco_flag_va(i) ;
       ben_ext_person.g_elig_dpnt_prev_last_name      := l_dpel_previous_last_name_va(i) ;
       --
       -- retrieve dependent address info if required
       if ben_extract.g_eda_csr = 'Y' then
          open prim_address_c (l_dpel_dpnt_person_id_va(i));
          fetch prim_address_c into ben_ext_person.g_elig_dpnt_prim_address1
                ,ben_ext_person.g_elig_dpnt_prim_address2
                ,ben_ext_person.g_elig_dpnt_prim_address3
                ,ben_ext_person.g_elig_dpnt_prim_city
                ,ben_ext_person.g_elig_dpnt_prim_state
                ,ben_ext_person.g_elig_dpnt_prim_postal_code
                ,ben_ext_person.g_elig_dpnt_prim_country
                ,ben_ext_person.g_elig_dpnt_prim_effect_date
                ,ben_ext_person.g_elig_dpnt_prim_region;
          if prim_address_c%notfound then
             open prim_rltd_address_c(l_dpel_dpnt_person_id_va(i));
             fetch prim_rltd_address_c into ben_ext_person.g_elig_dpnt_prim_address1
                 , ben_ext_person.g_elig_dpnt_prim_address2
                 , ben_ext_person.g_elig_dpnt_prim_address3
                 , ben_ext_person.g_elig_dpnt_prim_city
                 , ben_ext_person.g_elig_dpnt_prim_state
                 , ben_ext_person.g_elig_dpnt_prim_postal_code
                 , ben_ext_person.g_elig_dpnt_prim_country
                 , ben_ext_person.g_elig_dpnt_prim_effect_date
                 , ben_ext_person.g_elig_dpnt_prim_region;
             close prim_rltd_address_c;
	  end if;
          close prim_address_c;
       end if;
         --
         -- retrieve dependent phone numbers if required
       if ben_extract.g_edp_csr = 'Y' then
          open ext_phone_c(l_dpel_dpnt_person_id_va(i));
          fetch ext_phone_c into ben_ext_person.g_elig_dpnt_home_phone
                                    ,ben_ext_person.g_elig_dpnt_work_phone
                                    ,ben_ext_person.g_elig_dpnt_fax
                                    ,ben_ext_person.g_elig_dpnt_mobile;
          close ext_phone_c;
       end if;
       --
       -- format and write
       --
       ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                        p_ext_file_id       => p_ext_file_id,
                                         p_data_typ_cd       => p_data_typ_cd,
                                         p_ext_typ_cd        => p_ext_typ_cd,
                                         p_rcd_typ_cd        => 'D',
                                         p_low_lvl_cd        => 'ED',--eligible dependent
                                         p_person_id         => p_person_id,
                                         p_chg_evt_cd        => p_chg_evt_cd,
                                         p_business_group_id => p_business_group_id,
                                         p_effective_date    => p_effective_date
                                        );
     --
   END LOOP;
   --
   hr_utility.set_location('Exiting'||l_proc, 15);

 END; -- main
--
END; -- package

/
