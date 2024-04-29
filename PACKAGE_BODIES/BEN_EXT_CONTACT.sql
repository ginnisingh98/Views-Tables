--------------------------------------------------------
--  DDL for Package Body BEN_EXT_CONTACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_CONTACT" as
/* $Header: benxcnct.pkb 120.0 2005/05/28 09:38:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ext_contact.';  -- Global package name
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
    ben_ext_person.g_contact_rlshp_id            := null;
    ben_ext_person.g_contact_rlshp_type          := null;
    ben_ext_person.g_contact_seq_num             := null;
    ben_ext_person.g_contact_national_ident      := null;
    ben_ext_person.g_contact_last_name           := null;
    ben_ext_person.g_contact_first_name          := null;
    ben_ext_person.g_contact_middle_names        := null;
    ben_ext_person.g_contact_full_name           := null;
    ben_ext_person.g_contact_suffix              := null;
    ben_ext_person.g_contact_prefix              := null;
    ben_ext_person.g_contact_title               := null;
    ben_ext_person.g_contact_date_of_birth       := null;
    ben_ext_person.g_contact_marital_status      := null;
    ben_ext_person.g_contact_sex                 := null;
    ben_ext_person.g_contact_disabled_flag       := null;
    ben_ext_person.g_contact_student_status      := null;
    ben_ext_person.g_contact_date_of_death       := null;
    ben_ext_person.g_contact_language            := null;
    ben_ext_person.g_contact_nationality         := null;
    ben_ext_person.g_contact_email_address       := null;
    ben_ext_person.g_contact_known_as            := null;
    ben_ext_person.g_contact_pre_name_adjunct    := null;
    ben_ext_person.g_contact_tobacco_usage       := null;
    ben_ext_person.g_contact_prev_last_name      := null;
    ben_ext_person.g_contact_prim_address1       := null;
    ben_ext_person.g_contact_prim_address2       := null;
    ben_ext_person.g_contact_prim_address3       := null;
    ben_ext_person.g_contact_prim_city           := null;
    ben_ext_person.g_contact_prim_state          := null;
    ben_ext_person.g_contact_prim_postal_code    := null;
    ben_ext_person.g_contact_prim_country        := null;
    ben_ext_person.g_contact_prim_effect_date    := null;
    ben_ext_person.g_contact_prim_region         := null;
    ben_ext_person.g_contact_home_phone          := null;
    ben_ext_person.g_contact_work_phone          := null;
    ben_ext_person.g_contact_fax                 := null;
    ben_ext_person.g_contact_mobile              := null;
    ben_ext_person.g_contact_prmy_contact_flag   := null;
    ben_ext_person.g_contact_shared_resd_flag    := null;
    ben_ext_person.g_contact_personal_flag       := null;
    ben_ext_person.g_contact_pymts_rcpnt_flag    := null;
    ben_ext_person.g_contact_start_date          := null;
    ben_ext_person.g_contact_end_date            := null;
    ben_ext_person.g_contact_start_life_evt      := null;
    ben_ext_person.g_contact_start_ler_id        := null;
    ben_ext_person.g_contact_end_life_evt        := null;
    ben_ext_person.g_contact_end_ler_id          := null;
    ben_ext_person.g_contact_is_elig_dpnt_flag   := null;
    ben_ext_person.g_contact_is_cvrd_dpnt_flag   := null;
    ben_ext_person.g_contact_is_bnfcry_flag      := null;
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
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date) is
   --
   l_proc             varchar2(72) := g_package||'main';
   --
  cursor c_contact is
    select
             b.contact_relationship_id
           , b.contact_person_id
           , b.contact_type
           , b.sequence_number
           , b.PRIMARY_CONTACT_FLAG
           , b.RLTD_PER_RSDS_W_DSGNTR_FLAG
           , b.PERSONAL_FLAG
           , b.THIRD_PARTY_PAY_FLAG
           , b.DATE_START
           , b.DATE_END
           , b.start_life_reason_id
           , b.end_life_reason_id
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
           , c.pre_name_adjunct  prefix
           , c.title
           , c.date_of_death
           , c.known_as
           , c.pre_name_adjunct
           , c.uses_tobacco_flag
           , c.previous_last_name
       from
            per_contact_relationships      b,
            per_all_people_f               c
       where
            c.person_id = b.contact_person_id
        and b.person_id = p_person_id
        and p_effective_date between c.effective_start_date
                                 and c.effective_end_date
      ;

--
cursor prim_address_c(p_contact_person_id number) is
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
          a.person_id = p_contact_person_id
      and p_effective_date between nvl(a.date_from, p_effective_date)
                              and nvl(a.date_to, p_effective_date)
      and a.primary_flag = 'Y'
      ;
--
    cursor prim_rltd_address_c(p_contact_person_id number)  is
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
          r.contact_person_id = p_contact_person_id
      and r.person_id = p_person_id
      and r.person_id = a.person_id
      and p_effective_date between nvl(a.date_from, p_effective_date)
                              and nvl(a.date_to, p_effective_date)
      and a.primary_flag = 'Y'
      and r.rltd_per_rsds_w_dsgntr_flag = 'Y'
      ;
   --
cursor ext_phone_c (p_contact_person_id number) is
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
   where  p.person_id = p_contact_person_id
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
    -- Return 'Y' if the contact is currently an eligible dependent in any
    -- Comp object for the related person.
    --
    cursor c_elig_dpnt (p_contact_person_id number) is
      select 'Y'
      from ben_elig_dpnt egd,
           ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
      where egd.dpnt_person_id = p_contact_person_id
      and   pil.person_id = p_person_id
      and   pil.per_in_ler_id = epe.per_in_ler_id
      and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
      and   epe.elig_per_elctbl_chc_id =  egd.elig_per_elctbl_chc_id
      and   p_effective_date between egd.elig_strt_dt and egd.elig_thru_dt;
    --
    -- Return 'Y' if the contact is currently a covered dependent in any
    -- Comp object for the related person.
    --
    cursor c_cvrd_dpnt (p_contact_person_id number) is
      select 'Y'
      from ben_elig_cvrd_dpnt_f pdp,
           ben_prtt_enrt_rslt_f pen
      where pdp.dpnt_person_id = p_contact_person_id
      and   pen.person_id = p_person_id
      and   pen.prtt_enrt_rslt_stat_cd not in ('VOIDD','BCKDT')
      and   pen.sspndd_flag = 'N'
      and   pen.prtt_enrt_rslt_id = pdp.prtt_enrt_rslt_id
      and   p_effective_date between pdp.cvg_strt_dt and pdp.cvg_thru_dt
      and   p_effective_date between pdp.effective_start_date and pdp.effective_end_date
      and   p_effective_date between pen.effective_start_date and pen.effective_end_date;
    --
    -- Return 'Y' if the contact is currently a beneficiary in any
    -- Comp object for the related person.
    --
    cursor c_beneficiary (p_contact_person_id number) is
      select 'Y'
      from ben_pl_bnf_f pbn,
           ben_prtt_enrt_rslt_f pen
      where pbn.bnf_person_id = p_contact_person_id
      and   pen.person_id = p_person_id
      and   pen.prtt_enrt_rslt_stat_cd not in ('VOIDD','BCKDT')
      and   pen.sspndd_flag = 'N'
      and   pen.prtt_enrt_rslt_id = pbn.prtt_enrt_rslt_id
      and   p_effective_date between pbn.dsgn_strt_dt and pbn.dsgn_thru_dt
      and   p_effective_date between pbn.effective_start_date and pbn.effective_end_date
      and   p_effective_date between pen.effective_start_date and pen.effective_end_date;

    cursor c_start_ler (p_start_life_reason_id number) is
      select name
      from ben_ler_f ler
      where ler_id = p_start_life_reason_id
      and   p_effective_date between ler.effective_start_date and ler.effective_end_date;

    cursor c_end_ler (p_end_life_reason_id number) is
      select name
      from ben_ler_f ler
      where ler_id = p_end_life_reason_id
      and   p_effective_date between ler.effective_start_date and ler.effective_end_date;

 --
 BEGIN
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
   FOR contact IN c_contact LOOP
            --
            initialize_globals;
            --
            -- fetch dependent information into globals
            --
            ben_ext_person.g_contact_rlshp_id            := contact.contact_relationship_id;
            ben_ext_person.g_contact_rlshp_type          := contact.contact_type;
            ben_ext_person.g_contact_seq_num             := contact.sequence_number;
            ben_ext_person.g_contact_prmy_contact_flag   := contact.PRIMARY_CONTACT_FLAG;
            ben_ext_person.g_contact_shared_resd_flag    := contact.RLTD_PER_RSDS_W_DSGNTR_FLAG;
            ben_ext_person.g_contact_personal_flag       := contact.PERSONAL_FLAG;
            ben_ext_person.g_contact_pymts_rcpnt_flag    := contact.THIRD_PARTY_PAY_FLAG;
            ben_ext_person.g_contact_start_date          := contact.DATE_START;
            ben_ext_person.g_contact_end_date            := contact.DATE_END;
            ben_ext_person.g_contact_national_ident      := contact.national_identifier;
            ben_ext_person.g_contact_last_name           := contact.last_name;
            ben_ext_person.g_contact_first_name          := contact.first_name;
            ben_ext_person.g_contact_middle_names        := contact.middle_names;
            ben_ext_person.g_contact_full_name           := contact.full_name;
            ben_ext_person.g_contact_suffix              := contact.suffix;
            ben_ext_person.g_contact_prefix              := contact.prefix;
            ben_ext_person.g_contact_title               := contact.title;
            ben_ext_person.g_contact_date_of_birth       := contact.date_of_birth;
            ben_ext_person.g_contact_marital_status      := contact.marital_status;
            ben_ext_person.g_contact_sex                 := contact.sex;
            ben_ext_person.g_contact_disabled_flag       := contact.registered_disabled_flag;
            ben_ext_person.g_contact_student_status      := contact.student_status;
            ben_ext_person.g_contact_date_of_death       := contact.date_of_death;
            ben_ext_person.g_contact_language            := contact.correspondence_language;
            ben_ext_person.g_contact_nationality         := contact.nationality;
            ben_ext_person.g_contact_email_address       := contact.email_address;
            ben_ext_person.g_contact_known_as            := contact.known_as;
            ben_ext_person.g_contact_pre_name_adjunct    := contact.pre_name_adjunct;
            ben_ext_person.g_contact_tobacco_usage       := contact.uses_tobacco_flag;
            ben_ext_person.g_contact_prev_last_name      := contact.previous_last_name;
            ben_ext_person.g_contact_start_ler_id        := contact.start_life_reason_id;
            ben_ext_person.g_contact_end_ler_id          := contact.end_life_reason_id;
         --
         -- retrieve dependent address info if required
            if ben_extract.g_coa_csr = 'Y' then
              open prim_address_c (contact.contact_person_id);
              fetch prim_address_c into ben_ext_person.g_contact_prim_address1
                                       ,ben_ext_person.g_contact_prim_address2
                                       ,ben_ext_person.g_contact_prim_address3
                                       ,ben_ext_person.g_contact_prim_city
                                       ,ben_ext_person.g_contact_prim_state
                                       ,ben_ext_person.g_contact_prim_postal_code
                                       ,ben_ext_person.g_contact_prim_country
                                       ,ben_ext_person.g_contact_prim_effect_date
                                       ,ben_ext_person.g_contact_prim_region;
                 if prim_address_c%notfound then
                   open prim_rltd_address_c(contact.contact_person_id);
                   fetch prim_rltd_address_c into ben_ext_person.g_contact_prim_address1
                                         , ben_ext_person.g_contact_prim_address2
                                         , ben_ext_person.g_contact_prim_address3
                                         , ben_ext_person.g_contact_prim_city
                                         , ben_ext_person.g_contact_prim_state
                                         , ben_ext_person.g_contact_prim_postal_code
                                         , ben_ext_person.g_contact_prim_country
                                         , ben_ext_person.g_contact_prim_effect_date
                                         , ben_ext_person.g_contact_prim_region;
                   close prim_rltd_address_c;
		     end if;
              close prim_address_c;
            end if;
         --
         -- retrieve dependent phone numbers if required
            if ben_extract.g_cop_csr = 'Y' then
              open ext_phone_c(contact.contact_person_id);
              fetch ext_phone_c into ben_ext_person.g_contact_home_phone
                                    ,ben_ext_person.g_contact_work_phone
                                    ,ben_ext_person.g_contact_fax
                                    ,ben_ext_person.g_contact_mobile;
              close ext_phone_c;
            end if;

         -- retrieve eligible dependent flag
            if ben_extract.g_coed_csr = 'Y' then
              ben_ext_person.g_contact_is_elig_dpnt_flag := 'N';
              open c_elig_dpnt(contact.contact_person_id);
              fetch c_elig_dpnt into ben_ext_person.g_contact_is_elig_dpnt_flag;
              close c_elig_dpnt;
            end if;

         -- retrieve covered dependent flag
            if ben_extract.g_cocd_csr = 'Y' then
              ben_ext_person.g_contact_is_cvrd_dpnt_flag := 'N';
              open c_cvrd_dpnt(contact.contact_person_id);
              fetch c_cvrd_dpnt into ben_ext_person.g_contact_is_cvrd_dpnt_flag;
              close c_cvrd_dpnt;
            end if;

         -- retrieve beneficiary flag
            if ben_extract.g_cob_csr = 'Y' then
              ben_ext_person.g_contact_is_bnfcry_flag := 'N';
              open c_beneficiary(contact.contact_person_id);
              fetch c_beneficiary into ben_ext_person.g_contact_is_bnfcry_flag;
              close c_beneficiary;
            end if;
         --
         -- retrieve life reason start
            if ben_extract.g_cosl_csr = 'Y' then
              open c_start_ler(contact.start_life_reason_id);
              fetch c_start_ler into ben_ext_person.g_contact_start_life_evt;
              close c_start_ler;
            end if;
         --
         -- retrieve life reason end
            if ben_extract.g_coel_csr = 'Y' then
              open c_end_ler(contact.end_life_reason_id);
              fetch c_end_ler into ben_ext_person.g_contact_end_life_evt;
              close c_end_ler;
            end if;
            -- format and write
            --
            ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                         p_ext_file_id       => p_ext_file_id,
                                         p_data_typ_cd       => p_data_typ_cd,
                                         p_ext_typ_cd        => p_ext_typ_cd,
                                         p_rcd_typ_cd        => 'D',
                                         p_low_lvl_cd        => 'CO',--contact
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
