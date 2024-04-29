--------------------------------------------------------
--  DDL for Package Body BEN_EXT_BNF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_BNF" AS
/* $Header: benxbenf.pkb 120.0 2005/05/28 09:38:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ext_bnf.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< init_detl_globals >-----------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure init_detl_globals IS
--
  l_proc               varchar2(72) := g_package||'init_detl_globals';
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
   --
    ben_ext_person.g_bnf_pl_bnf_id                  := null;
    ben_ext_person.g_bnf_ssn                        := null;
    ben_ext_person.g_bnf_lst_nm                     := null;
    ben_ext_person.g_bnf_fst_nm                     := null;
    ben_ext_person.g_bnf_mid_nm                     := null;
    ben_ext_person.g_bnf_fl_nm                      := null;
    ben_ext_person.g_bnf_suffix                     := null;
    ben_ext_person.g_bnf_prefix                     := null;
    ben_ext_person.g_bnf_title                      := null;
    ben_ext_person.g_bnf_prv_lst_nm                 := null;
    ben_ext_person.g_bnf_pre_nm_adjunct             := null;
    ben_ext_person.g_bnf_prmy_cont                  := null;
    ben_ext_person.g_bnf_pct_dsgd                   := null;
    ben_ext_person.g_bnf_amt_dsgd                   := null;
    ben_ext_person.g_bnf_amt_uom                    := null;
    ben_ext_person.g_bnf_rlshp                      := null;
    ben_ext_person.g_bnf_contact_seq_num            := null;
    ben_ext_person.g_bnf_shared_resd_flag           := null;
    ben_ext_person.g_bnf_email_address              := null;
    ben_ext_person.g_bnf_known_as                   := null;
    ben_ext_person.g_bnf_nationality                := null;
    ben_ext_person.g_bnf_tobacco_usage              := null;
    ben_ext_person.g_bnf_gender                     := null;
    ben_ext_person.g_bnf_date_of_birth              := null;
    ben_ext_person.g_bnf_marital_status             := null;
    ben_ext_person.g_bnf_disabled_flag              := null;
    ben_ext_person.g_bnf_student_status             := null;
    ben_ext_person.g_bnf_date_of_death              := null;
    ben_ext_person.g_bnf_language                   := null;
    ben_ext_person.g_bnf_prim_address1              := null;
    ben_ext_person.g_bnf_prim_address2              := null;
    ben_ext_person.g_bnf_prim_address3              := null;
    ben_ext_person.g_bnf_prim_city                  := null;
    ben_ext_person.g_bnf_prim_state                 := null;
    ben_ext_person.g_bnf_prim_postal_code           := null;
    ben_ext_person.g_bnf_prim_country               := null;
    ben_ext_person.g_bnf_prim_effect_date           := null;
    ben_ext_person.g_bnf_prim_region                := null;
    ben_ext_person.g_bnf_home_phone                 := null;
    ben_ext_person.g_bnf_work_phone                 := null;
    ben_ext_person.g_bnf_fax                        := null;
    ben_ext_person.g_bnf_mobile            	    := null;

  --
  hr_utility.set_location('Exiting'||l_proc, 15);
  --
End init_detl_globals;
--
-- ----------------------------------------------------------------------------
-- |--------------< main >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
--
   Procedure main
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
   l_relatated_true   varchar2(1) := 'N' ;
   l_proc             varchar2(72) := g_package||'main';
   --
  cursor c_bnfcry (l_prtt_enrt_rslt_id number) is
    select
             b.contact_type             bnf_rlshp
           , b.sequence_number          bnf_contact_seq_num
           , b.rltd_per_rsds_w_dsgntr_flag
           , b.contact_person_id       bnf_person_id
           , c.last_name                bnf_lst_nm
           , c.first_name               bnf_fst_nm
           , c.full_name                bnf_fl_nm
           , c.middle_names             bnf_mid_nm
           , c.national_identifier      bnf_ssn
           , c.suffix                   bnf_suffix
           , c.pre_name_adjunct         bnf_prefix
           , c.title                    bnf_title
           , c.previous_last_name       bnf_prv_lst_nm
           , c.pre_name_adjunct         bnf_pre_nm_adjunct
           , c.email_address            bnf_email
           , c.known_as                 bnf_known_as
           , c.nationality              bnf_nationality
           , c.uses_tobacco_flag        bnf_tobacco_usage
           , c.sex                      bnf_gender
           , c.date_of_birth            bnf_dob
           , c.marital_status           bnf_marital_status
           , c.registered_disabled_flag bnf_disabled_flag
           , c.student_status           bnf_student_status
           , c.date_of_death            bnf_dod
           , c.correspondence_language  bnf_language
           , a.prmry_cntngnt_cd         bnf_prmy_cont
           , a.pct_dsgd_num             bnf_pct_dsgd
           , a.amt_dsgd_val             bnf_amt_dsgd
           , a.amt_dsgd_uom             bnf_amt_uom
           , a.pl_bnf_id                pl_bnf_id
       from ben_pl_bnf_f           a,
            ben_per_in_ler pil,
            per_contact_relationships      b,
            per_all_people_f               c
       where
            a.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
        and a.bnf_person_id = b.contact_person_id
        and b.person_id = p_person_id
        and c.person_id = a.bnf_person_id
        and p_effective_date between nvl(a.dsgn_strt_dt, p_effective_date)
                                 and nvl(a.dsgn_thru_dt, p_effective_date)
        and p_effective_date between nvl(a.effective_start_date, p_effective_date)
                                 and nvl(a.effective_end_date, p_effective_date)
        and p_effective_date between nvl(c.effective_start_date, p_effective_date)
                             and nvl(c.effective_end_date, p_effective_date)
        and    pil.per_in_ler_id=a.per_in_ler_id
      -- and    pil.business_group_id+0=a.business_group_id
        and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')

    ;

   --
   --

    cursor prim_address_c (c_person_id number) is
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
          a.person_id = c_person_id
      and p_effective_date between nvl(a.date_from, p_effective_date)
                              and nvl(a.date_to, p_effective_date)
      and a.primary_flag = 'Y'
      ;
--
    cursor prim_rltd_address_c(c_person_id number)  is
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
          r.contact_person_id = c_person_id
      and r.person_id = a.person_id
      and p_effective_date between nvl(a.date_from, p_effective_date)
                              and nvl(a.date_to, p_effective_date)
      and a.primary_flag = 'Y'
      and r.rltd_per_rsds_w_dsgntr_flag = 'Y'
      ;
   --
   --
   cursor ext_phone_c (c_person_id number)  is
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
   where  p.person_id = c_person_id
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
 cursor ext_related_phone_c (c_person_id number)  is
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
        , per_contact_relationships r
    where r.contact_person_id = c_person_id
     and  p.person_id = r.person_id
     and  r.rltd_per_rsds_w_dsgntr_flag = 'Y'
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

   Begin
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
   init_detl_globals;
   --
    FOR bnfcry IN c_bnfcry(p_prtt_enrt_rslt_id) LOOP
       -- assign beneficiary info to global variables
       --
    		ben_ext_person.g_bnf_ssn               := bnfcry.bnf_ssn;
    		ben_ext_person.g_bnf_lst_nm            := bnfcry.bnf_lst_nm;
   	 	ben_ext_person.g_bnf_fst_nm            := bnfcry.bnf_fst_nm;
    		ben_ext_person.g_bnf_mid_nm            := bnfcry.bnf_mid_nm;
    		ben_ext_person.g_bnf_fl_nm             := bnfcry.bnf_fl_nm;
    		ben_ext_person.g_bnf_suffix            := bnfcry.bnf_suffix;
    		ben_ext_person.g_bnf_prefix            := bnfcry.bnf_prefix;
    		ben_ext_person.g_bnf_title             := bnfcry.bnf_title;
    		ben_ext_person.g_bnf_prv_lst_nm        := bnfcry.bnf_prv_lst_nm;
    		ben_ext_person.g_bnf_pre_nm_adjunct    := bnfcry.bnf_pre_nm_adjunct;
    		ben_ext_person.g_bnf_email_address     := bnfcry.bnf_email;
    		ben_ext_person.g_bnf_known_as          := bnfcry.bnf_known_as;
    		ben_ext_person.g_bnf_nationality       := bnfcry.bnf_nationality;
    		ben_ext_person.g_bnf_tobacco_usage     := bnfcry.bnf_tobacco_usage;
    		ben_ext_person.g_bnf_gender            := bnfcry.bnf_gender;
    		ben_ext_person.g_bnf_date_of_birth     := bnfcry.bnf_dob;
    		ben_ext_person.g_bnf_marital_status    := bnfcry.bnf_marital_status;
    		ben_ext_person.g_bnf_disabled_flag     := bnfcry.bnf_disabled_flag;
    		ben_ext_person.g_bnf_student_status    := bnfcry.bnf_student_status;
    		ben_ext_person.g_bnf_date_of_death     := bnfcry.bnf_dod;
    		ben_ext_person.g_bnf_language          := bnfcry.bnf_language;
    		ben_ext_person.g_bnf_prmy_cont         := bnfcry.bnf_prmy_cont;
    		ben_ext_person.g_bnf_pct_dsgd          := bnfcry.bnf_pct_dsgd;
    		ben_ext_person.g_bnf_amt_dsgd          := bnfcry.bnf_amt_dsgd;
    		ben_ext_person.g_bnf_amt_uom           := bnfcry.bnf_amt_uom;
    		ben_ext_person.g_bnf_rlshp             := bnfcry.bnf_rlshp;
    		ben_ext_person.g_bnf_contact_seq_num   := bnfcry.bnf_contact_seq_num;
                ben_ext_person.g_bnf_shared_resd_flag    := bnfcry.rltd_per_rsds_w_dsgntr_flag;
                ben_ext_person.g_bnf_pl_bnf_id         := bnfcry.pl_bnf_id;

       --
                hr_utility.set_location('Beneficiary id ' || bnfcry.bnf_person_id,178);
       --
       --      retrieve beneficiary address if required
               l_relatated_true := 'N' ;
               if ben_extract.g_ba_csr = 'Y' then
                 open prim_address_c(bnfcry.bnf_person_id);
                 fetch prim_address_c into ben_ext_person.g_bnf_prim_address1
                                         , ben_ext_person.g_bnf_prim_address2
                                         , ben_ext_person.g_bnf_prim_address3
                                         , ben_ext_person.g_bnf_prim_city
                                         , ben_ext_person.g_bnf_prim_state
                                         , ben_ext_person.g_bnf_prim_postal_code
                                         , ben_ext_person.g_bnf_prim_country
                                         , ben_ext_person.g_bnf_prim_effect_date
                                         , ben_ext_person.g_bnf_prim_region;
                 if prim_address_c%notfound then
                   open prim_rltd_address_c(bnfcry.bnf_person_id);
                   fetch prim_rltd_address_c into ben_ext_person.g_bnf_prim_address1
                                         , ben_ext_person.g_bnf_prim_address2
                                         , ben_ext_person.g_bnf_prim_address3
                                         , ben_ext_person.g_bnf_prim_city
                                         , ben_ext_person.g_bnf_prim_state
                                         , ben_ext_person.g_bnf_prim_postal_code
                                         , ben_ext_person.g_bnf_prim_country
                                         , ben_ext_person.g_bnf_prim_effect_date
                                         , ben_ext_person.g_bnf_prim_region;
                   close prim_rltd_address_c;
                   l_relatated_true := 'Y' ;
		 end if;
                 close prim_address_c;
               end if;
       --
       --      retrieve beneficiary phone numbers if required

               if ben_extract.g_bp_csr = 'Y' then
                  if l_relatated_true = 'N' then
                     open ext_phone_c(bnfcry.bnf_person_id);
                     fetch ext_phone_c into ben_ext_person.g_bnf_home_phone
                                      , ben_ext_person.g_bnf_work_phone
                                      , ben_ext_person.g_bnf_fax
                                      , ben_ext_person.g_bnf_mobile;
                      close ext_phone_c;
                  else

                     open ext_related_phone_c(bnfcry.bnf_person_id);
                     fetch ext_related_phone_c into ben_ext_person.g_bnf_home_phone
                                      , ben_ext_person.g_bnf_work_phone
                                      , ben_ext_person.g_bnf_fax
                                      , ben_ext_person.g_bnf_mobile;
                      hr_utility.set_location('sec_ph'|| ben_ext_person.g_bnf_home_phone,178);
                      close ext_related_phone_c;
                  end if ;
               end if ;
       --
       --
       -- format and write
       --
    ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                    p_ext_file_id       => p_ext_file_id,
                                    p_data_typ_cd       => p_data_typ_cd,
                                    p_ext_typ_cd        => p_ext_typ_cd,
                                    p_rcd_typ_cd        => 'D',  --detail
                                    p_low_lvl_cd        => 'B',  --beneficiary?
                                    p_person_id         => p_person_id,
                                    p_chg_evt_cd        => p_chg_evt_cd,
                                    p_business_group_id => p_business_group_id,
                                    p_effective_date    => p_effective_date
                                    );
     --
   END LOOP;
   --
   hr_utility.set_location('Exiting'||l_proc, 15);
   --
 END;  --main
--
END; -- package

/
