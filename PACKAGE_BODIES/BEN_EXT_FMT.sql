--------------------------------------------------------
--  DDL for Package Body BEN_EXT_FMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_FMT" as
/* $Header: benxfrmt.pkb 120.21 2007/09/05 02:25:53 tjesumic ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33)	:= '  ben_ext_fmt.';  -- Global package name
g_val_def valtabtyp := valtabtyp(null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null
                                 );

g_rqd_elmt_is_present     varchar2(1);

TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_varchar2_30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_varchar2_600 IS TABLE OF VARCHAR2(600) INDEX BY BINARY_INTEGER;


-- ------------------------------------------------------------------
-- |------------------------< get_pay_balance  >----------------|
-- ------------------------------------------------------------------

function get_pay_balance ( p_defined_balance_id  in number
                          ,p_assignment_id       in number
                          ,p_effective_date      in date
                          ,p_business_group_id   in number
                          )
         return varchar2 is


  cursor c_leg is
  select LEGISLATION_CODE
  from per_business_groups_perf
  where business_group_id = p_business_group_id
  ;



  l_LEGISLATION_CODE  per_business_groups.LEGISLATION_CODE%type ;
  l_proc  varchar2(72) := g_package||'get_pay_balance';
  l_rslt_elmt varchar2(300) ;

begin

    hr_utility.set_location('Entering:'||l_proc, 5);


    open c_leg ;
    fetch c_leg into l_LEGISLATION_CODE ;
    close c_leg ;


     l_rslt_elmt :=  ben_ext_payroll_balance.Get_Balance_Value
                         (p_business_group_id  => p_business_group_id
                         ,p_assignment_id      => p_assignment_id
                         ,p_effective_date     => p_effective_date
                         ,p_legislation_code   => l_LEGISLATION_CODE
                         ,p_defined_balance_id => p_defined_balance_id
                        )  ;

    hr_utility.set_location(' Exiting: ' ||  l_rslt_elmt || '  : ' ||l_proc, 15);
    return l_rslt_elmt ;
end ;



-- ------------------------------------------------------------------
-- |------------------------< get_name >----------------|
-- ------------------------------------------------------------------
-- Fix for Bug 3870480
Function get_name(p_val_id number) Return Varchar2 Is
--
  l_proc  varchar2(72) := g_package||'sprs_or_incl';
  val_name varchar2(250);
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  select user_name into val_name
     from fnd_user
      where user_id = p_val_id;

  hr_utility.set_location(' Exiting:'||l_proc, 15);
  return val_name;
  --
  --
Exception
  When NO_DATA_FOUND Then
  --
  hr_utility.set_location(' Exiting:'||l_proc, 999);
  --
  return null;
End get_name;
--

--
-- ----------------------------------------------------------------------------
-- |---------< get_error_msg >---------------------------------------------|
-- ----------------------------------------------------------------------------
--
function get_error_msg(p_err_no         in number ,
                       p_err_name       in varchar2 ,
                       p_token1         in varchar2 default null,
                       p_token2         in varchar2 default null ) return varchar2 IS
 l_err_message fnd_new_messages.message_text%type ;
 l_proc               varchar2(72) := g_package||'get_error_msg';
begin

  hr_utility.set_location('Entering'||l_proc, 5);
  hr_utility.set_location('Error'||substr(p_err_name,1,100), 99.99);
  fnd_message.set_name('BEN',p_err_name);
  if P_err_no in ( 91888,92065,91924,91887,92313,92312,92678,92679  )
     and p_token1 is not null   then
     fnd_message.set_token('DATA' , p_token1 ) ;
  end if ;
  -- because the token name is required
  -- that si hard coded as per the error number
  -- if any new error calls this then the totken is to be added here
  --     fnd_message.set_token('FIELD','p_prvs_stat_cd');
  --    fnd_message.set_token('TYPE','BEN_PER_IN_LER_STAT_CD');
  l_err_message  := fnd_message.get ;
  hr_utility.set_location('message'||substr(l_err_message,1,100), 99.99);
  hr_utility.set_location('Exiting'||l_proc, 5);
  return (l_err_message) ;

end ;


--
-- ----------------------------------------------------------------------------
-- |---------< decode_setup >---------------------------------------------|
-- ----------------------------------------------------------------------------
--
function decode_setup(p_ext_data_elmt_typ        in varchar2,
                           p_name                in varchar2,
                           p_id                  in varchar2) return varchar2 IS
--
  l_proc               varchar2(72) := g_package||'decode_setup';
  l_val                ben_ext_rslt_dtl.val_01%type ;
--
begin
--
  --
  hr_utility.set_location('Entering'||l_proc, 5);
  --
  if p_ext_data_elmt_typ = 'F' then
    l_val := p_name;
  else
    l_val := p_id;
  end if;
  return(l_val);
  --
  hr_utility.set_location('Exiting:'||l_proc, 15);
  --
end decode_setup;
--


-- ------------------------------------------------------------------
-- |------------------------< apply_decode >------------------------|
-- ------------------------------------------------------------------
--  This function substitute data element value with the decoded
--  value defined in the extract layout.  This function will
--  return the decoded value if found.  Otherwise, it would return
--  the default value if provided.
--
Function apply_decode(p_value              varchar2,
                      p_ext_data_elmt_id   number,
                      p_default            varchar2,
                      p_short_name        varchar2 default null
                     ) Return Varchar2 Is
--
  l_proc            varchar2(72) := g_package||'apply_decode';
  l_dcd_val         ben_ext_data_elmt_decd.dcd_val%type ;
  l_err_message     varchar2(2000) ;

--
cursor c1 is
  select dcd_val
    from ben_ext_data_elmt_decd
    where
         ext_data_elmt_id = p_ext_data_elmt_id
     and val = nvl(p_value, ' ');
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('code for decode ' ||p_value||'  '|| p_ext_data_elmt_id ,936);
  --
  hr_utility.set_location('MONSTER defa '||p_default ,10);

  if p_value is not null then
  --
    open c1;
    fetch c1 into l_dcd_val;
    --
    if c1%found then
      --
      close c1;
      --
      if upper(l_dcd_val) <> 'NULL' then
      --
         return(l_dcd_val);
      --
      else
      --
         return(null);
      --
      end if;
      --
    else
      --
      close c1;
      --
      if p_default is not null then
        --
        if upper(p_default) <> 'NULL' then
          --
          return(p_default);
          --
        else
          --
          return(null);
          --
        end if;
        --
      else
        --
        -- warning -- could not find decoded value and default was not
        -- specified.  So just return the database value and warn.
        --
       IF p_short_name = 'PRLSHP' and p_value =  '18'  THEN
          -- whne the person relationshp type is 18 dont raise warning
          -- the default not defined to return 18 , this is a hard coded value
          null ;
       else
          if ben_ext_person.g_business_group_id is not null then
            l_err_message := get_error_msg(91888,'BEN_91888_EXT_INVALID_DCD',g_elmt_name );
            ben_ext_util.write_err
           (p_ext_rslt_id => ben_extract.g_ext_rslt_id,
            p_err_num  => 91888,
            p_err_name => l_err_message,
            p_typ_cd   => 'W',
            p_person_id => ben_ext_person.g_person_id,
            p_business_group_id => ben_ext_person.g_business_group_id);
          end if;
       end if  ;
        --
        return(p_value);
        --
      end if;
    --
    end if;
  --
  else
    --
    if p_default is not null and upper(p_default) <> 'NULL' then
       --
       hr_utility.set_location(' retunr defaul :'||p_default, 15);
       return(p_default);
       --
    else
       --
       return(null);
       --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Exiting:'||l_proc, 15);
--
End apply_decode;

--
-- ----------------------------------------------------------------------------
-- |---------< get_element_value >---------------------------------------------|
-- ----------------------------------------------------------------------------
--

function get_element_value
                         (
                           p_seq_num                number
                         , p_ext_data_elmt_id       number
                         , p_data_elmt_typ_cd       varchar2
                         , p_name                   varchar2
                         , p_frmt_mask_cd           varchar2
                         , p_dflt_val               varchar2
                         , p_short_name             varchar2
                         , p_two_char_substr        varchar2
                         , p_one_char_substr        varchar2
                         , p_lookup_type            varchar2
                         , p_frmt_mask_lookup_cd    varchar2 default null
                           ) return varchar2 IS
--
 l_proc               varchar2(72) := g_package||'get_element_value';
 l_lookup_type varchar2(30) := p_lookup_type  ;
 l_number                       varchar2(1);
 l_max_len                      integer ;
--
 l_rslt_elmt          varchar2(4000) ;

begin
    hr_utility.set_location('Entering'||l_proc, 5);

     if p_one_char_substr = 'A' then
            --
           if p_two_char_substr in ('AC','AP') then
              --
              IF p_short_name = 'ACNITMCMDT' THEN
                --
                l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_actn_cmpltd_date, p_frmt_mask_cd);
                --
              ELSIF p_short_name = 'ACNITMDDT' THEN
                --
                l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_actn_due_date, p_frmt_mask_cd);
                --
              ELSIF p_short_name = 'ACNITMDES' THEN
                --
                l_rslt_elmt := ben_ext_person.g_actn_description;
                --
              ELSIF p_short_name = 'ACNITMNM' THEN
                --
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_actn_name,
                 to_char(ben_ext_person.g_actn_type_id));
                --
              ELSIF p_short_name = 'ACNITMRQFG' THEN
                --
                l_rslt_elmt := ben_ext_person.g_actn_required_flag;
	        --
                -- Run Result
                --
              ELSIF p_short_name = 'ACNITMTYP' THEN
                --
                l_rslt_elmt := ben_ext_person.g_actn_type;
                --
              ELSIF p_short_name = 'APPNUM' THEN
                --
                l_rslt_elmt := ben_ext_person.g_applicant_number;
                --
              end if;
              --
           elsif p_two_char_substr = 'AS' then
              --
              IF p_short_name = 'ASGFLX01' THEN
                l_rslt_elmt := ben_ext_person.g_asg_attr_1;
              ELSIF p_short_name = 'ASGFLX02' THEN
                l_rslt_elmt := ben_ext_person.g_asg_attr_2;
              ELSIF p_short_name = 'ASGFLX03' THEN
                l_rslt_elmt := ben_ext_person.g_asg_attr_3;
              ELSIF p_short_name = 'ASGFLX04' THEN
                l_rslt_elmt := ben_ext_person.g_asg_attr_4;
              ELSIF p_short_name = 'ASGFLX05' THEN
                l_rslt_elmt := ben_ext_person.g_asg_attr_5;
              ELSIF p_short_name = 'ASGFLX06' THEN
                l_rslt_elmt := ben_ext_person.g_asg_attr_6;
              ELSIF p_short_name = 'ASGFLX07' THEN
                l_rslt_elmt := ben_ext_person.g_asg_attr_7;
              ELSIF p_short_name = 'ASGFLX08' THEN
                l_rslt_elmt := ben_ext_person.g_asg_attr_8;
              ELSIF p_short_name = 'ASGFLX09' THEN
                l_rslt_elmt := ben_ext_person.g_asg_attr_9;
              ELSIF p_short_name = 'ASGFLX10' THEN
                l_rslt_elmt := ben_ext_person.g_asg_attr_10;
              ELSIF p_short_name = 'ASGGRP' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_people_group,
                 to_char(ben_ext_person.g_people_group_id));
              ELSIF p_short_name = 'ASGHSAL' THEN
                l_rslt_elmt := ben_ext_person.g_hourly_salaried_code;
              ELSIF p_short_name = 'ASGJOB' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_job,
                 to_char(ben_ext_person.g_job_id));
              ELSIF p_short_name = 'ASGLUN' THEN
                l_rslt_elmt := ben_ext_person.g_labour_union_member_flag;
              ELSIF p_short_name = 'ASGMNG' THEN
                l_rslt_elmt := ben_ext_person.g_manager_flag;
              ELSIF p_short_name = 'ASGPAY' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_payroll,
                 to_char(ben_ext_person.g_payroll_id));
              ELSIF p_short_name = 'ASGPYBS' THEN
                l_rslt_elmt := ben_ext_person.g_pay_basis_type ;

              ELSIF p_short_name = 'ASGPBSS' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_pay_basis, to_char(ben_ext_person.g_pay_basis_id));

              ELSIF p_short_name = 'ASGPOS' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_position,
                 to_char(ben_ext_person.g_position_id));
              ELSIF p_short_name = 'ASGTITL' THEN
                l_rslt_elmt := ben_ext_person.g_asg_title;
              END IF;
              --
           end if;
            --
      elsif p_one_char_substr = 'B' then
            --
           if p_two_char_substr in ('BA','BC') then
              IF p_short_name = 'BAMTDSGD' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_bnf_amt_dsgd,p_frmt_mask_cd);
              ELSIF p_short_name = 'BAMTUOM' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_amt_uom;
              ELSIF p_short_name = 'BCONSQNM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_bnf_contact_seq_num, p_frmt_mask_cd);
              END IF;
           elsif p_two_char_substr in ('BD','BE','BF') then
              IF p_short_name = 'BDOB' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_bnf_date_of_birth, p_frmt_mask_cd);
              ELSIF p_short_name = 'BDOD' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_bnf_date_of_death, p_frmt_mask_cd);
              ELSIF p_short_name = 'BDSBCD' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_disabled_flag;
              ELSIF p_short_name = 'BEMADR' THEN
                l_rslt_elmt := substr(ben_ext_person.g_bnf_email_address,1,600);
              ELSIF p_short_name = 'BFLNM' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_fl_nm;
              ELSIF p_short_name = 'BFSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_fst_nm;
              ELSIF p_short_name = 'BFXNUM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_bnf_fax,p_frmt_mask_cd);
              END IF;
           elsif p_two_char_substr in ('BG','BK','BL','BM','BN') then
              IF p_short_name = 'BGENDR' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_gender;
              ELSIF p_short_name = 'BKNASNM' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_known_as;
              ELSIF p_short_name = 'BLANG' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_language;
              ELSIF p_short_name = 'BLSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_lst_nm;
              ELSIF p_short_name = 'BMBNUM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_bnf_mobile,p_frmt_mask_cd);
              --
              -- change log information
              --
              ELSIF p_short_name = 'BMIDNM' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_mid_nm;
              ELSIF p_short_name = 'BMRSTS' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_marital_status;
              ELSIF p_short_name = 'BNATION' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_nationality;
              ELSIF p_short_name = 'BNGRP' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_benefit_group,
                 to_char(ben_ext_person.g_benefit_group_id));
              END IF;
           elsif p_two_char_substr = 'BP' then
              IF p_short_name = 'BPCTDSGD' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_bnf_pct_dsgd,p_frmt_mask_cd);
              ELSIF p_short_name = 'BPHNHM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_bnf_home_phone, p_frmt_mask_cd);
              ELSIF p_short_name = 'BPHNWR' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_bnf_work_phone, p_frmt_mask_cd);
              ELSIF p_short_name = 'BPRADCITY' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_prim_city;
              ELSIF p_short_name = 'BPRADCNT' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_prim_country;
              ELSIF p_short_name = 'BPRADEFDT' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_bnf_prim_effect_date, p_frmt_mask_cd);
              ELSIF p_short_name = 'BPRADLN1' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_prim_address1;
              ELSIF p_short_name = 'BPRADLN2' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_prim_address2;
              ELSIF p_short_name = 'BPRADLN3' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_prim_address3;
              ELSIF p_short_name = 'BPRADPCD' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_prim_postal_code;
              ELSIF p_short_name = 'BPRADRG' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_prim_region;
              ELSIF p_short_name = 'BPRADST' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_prim_state;
              ELSIF p_short_name = 'BPRENMADJ' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_pre_nm_adjunct;
              ELSIF p_short_name = 'BPRMYCNT' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_prmy_cont;
              ELSIF p_short_name = 'BPRVLSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_prv_lst_nm;
              ELSIF p_short_name = 'BPREFIX' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_prefix;
              END IF;
           elsif p_two_char_substr in ('BR','BS') then
              IF p_short_name = 'BRLSHP' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_rlshp;
              ELSIF p_short_name = 'BSGRP' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                   ben_extract.g_business_group_name,
                   to_char(ben_ext_person.g_business_group_id));
                --
              ELSIF p_short_name = 'BSHRFL' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_shared_resd_flag;
              ELSIF p_short_name = 'BSSN' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_bnf_ssn,p_frmt_mask_cd);
              ELSIF p_short_name = 'BSTUSTS' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_student_status;
              ELSIF p_short_name = 'BSUF' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_suffix;
              END IF;
           elsif p_two_char_substr = 'BT' then
              IF p_short_name = 'BTOBUSG' THEN
                l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_bnf_tobacco_usage, p_frmt_mask_cd);
              ELSIF p_short_name = 'BTTL' THEN
                l_rslt_elmt := ben_ext_person.g_bnf_title;
              END IF;
           end if;
      elsif p_one_char_substr = 'C' then
           if p_two_char_substr = 'CB' then
              IF p_short_name =    'CBRADNM' then
                 l_rslt_elmt :=  ben_ext_person.g_elig_cobra_admin_name ;
              ELSIF p_short_name = 'CBRADORG' then
                 l_rslt_elmt :=  ben_ext_person.g_elig_cobra_admin_org_name ;
              ELSIF p_short_name = 'CBRADAD1' then
                 l_rslt_elmt :=  ben_ext_person.g_elig_cobra_admin_addr1 ;
              ELSIF p_short_name = 'CBRADAD2' then
                 l_rslt_elmt :=  ben_ext_person.g_elig_cobra_admin_addr2 ;
              ELSIF p_short_name = 'CBRADAD3' then
                 l_rslt_elmt :=  ben_ext_person.g_elig_cobra_admin_addr3 ;
              ELSIF p_short_name = 'CBRADCTY' then
                 l_rslt_elmt :=  ben_ext_person.g_elig_cobra_admin_city ;
              ELSIF p_short_name = 'CBRADST' then
                 l_rslt_elmt :=  ben_ext_person.g_elig_cobra_admin_state ;
              ELSIF p_short_name = 'CBRACNT' then
                 l_rslt_elmt :=  ben_ext_person.g_elig_cobra_admin_country ;
              ELSIF p_short_name = 'CBRAPH' then
                 l_rslt_elmt :=  ben_ext_person.g_elig_cobra_admin_phone ;
              ELSIF p_short_name = 'CBRAZIP' then
                 l_rslt_elmt :=  ben_ext_person.g_elig_cobra_admin_zip ;
              end if ;

           ELSIF p_two_char_substr = 'CH' then
              IF p_short_name = 'CHGACTDT' THEN
                l_rslt_elmt := apply_format_mask
                  (ben_ext_person.g_chg_actl_dt,p_frmt_mask_cd);
              ELSIF p_short_name = 'CHGCD' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_evt_cd;
              ELSIF p_short_name = 'CHGDT' THEN
                 l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_chg_eff_dt,p_frmt_mask_cd);
              ELSIF p_short_name = 'CHGEVNEW1' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_new_val1;
              ELSIF p_short_name = 'CHGEVNEW2' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_new_val2;
              ELSIF p_short_name = 'CHGEVNEW3' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_new_val3;
              ELSIF p_short_name = 'CHGEVNEW4' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_new_val4;
              ELSIF p_short_name = 'CHGEVNEW5' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_new_val5;
              ELSIF p_short_name = 'CHGEVNEW6' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_new_val6;
              ELSIF p_short_name = 'CHGEVOLD1' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_old_val1;
              ELSIF p_short_name = 'CHGEVOLD2' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_old_val2;
              ELSIF p_short_name = 'CHGEVOLD3' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_old_val3;
              ELSIF p_short_name = 'CHGEVOLD4' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_old_val4;
              ELSIF p_short_name = 'CHGEVOLD5' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_old_val5;
              ELSIF p_short_name = 'CHGEVOLD6' THEN
                 l_rslt_elmt := ben_ext_person.g_chg_old_val6;
              ELSIF p_short_name = 'CHGPTBLNM' THEN
                  l_rslt_elmt := ben_ext_person.g_chg_pay_table;
              ELSIF p_short_name = 'CHGPCLNM' THEN
                  l_rslt_elmt := ben_ext_person.g_chg_pay_column;
              ELSIF p_short_name = 'CHGPMOD' THEN
                  l_rslt_elmt := ben_ext_person.g_chg_pay_mode;

              END IF;
           elsif p_two_char_substr = 'CI' then
              IF p_short_name = 'CINSPRQD' THEN
                l_rslt_elmt := ben_ext_person.g_cm_inspn_rqd_flag;
              END IF;
           elsif p_two_char_substr = 'CM' then
              IF p_short_name = 'CMAD1' THEN
                l_rslt_elmt := ben_ext_person.g_cm_addr_line1;
              ELSIF p_short_name = 'CMAD2' THEN
                l_rslt_elmt := ben_ext_person.g_cm_addr_line2;
              ELSIF p_short_name = 'CMAD3' THEN
                l_rslt_elmt := ben_ext_person.g_cm_addr_line3;
              ELSIF p_short_name = 'CMCNTY' THEN  -- Fix for Bug 2593220
                l_rslt_elmt := nvl(hr_general.DECODE_FND_COMM_LOOKUP(l_lookup_type,
                                   ben_ext_person.g_cm_county),
                                   ben_ext_person.g_cm_county);
                --l_rslt_elmt := ben_ext_person.g_cm_county;  -- End of Fix, Bug 2593220
              ELSIF p_short_name = 'CMCRY' THEN
                l_rslt_elmt := ben_ext_person.g_cm_country;
              ELSIF p_short_name = 'CMCTY' THEN
                l_rslt_elmt := ben_ext_person.g_cm_city;
              ELSIF p_short_name = 'CMDLVTXT' THEN
                l_rslt_elmt := ben_ext_person.g_cm_dlvry_instn_txt;
              ELSIF p_short_name = 'CMEFFDT' THEN
                l_rslt_elmt := apply_format_mask
                  (ben_ext_person.g_cm_eff_dt,p_frmt_mask_cd);
              ELSIF p_short_name = 'CMKIT' THEN
                l_rslt_elmt := ben_ext_person.g_cm_kit;
              ELSIF p_short_name = 'CMLEND' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_cm_lf_evt_ntfn_dt, p_frmt_mask_cd);
                --
                --  Eligibility
                --
              ELSIF p_short_name = 'CMLENM' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_cm_lf_evt,
                 to_char(ben_ext_person.g_cm_lf_evt_id));
              ELSIF p_short_name = 'CMLEOD' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_cm_lf_evt_ocrd_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'CMLEST' THEN
                l_rslt_elmt := ben_ext_person.g_cm_lf_evt_stat;
              ELSIF p_short_name = 'CMREG3' THEN
                l_rslt_elmt := ben_ext_person.g_cm_region_3;
              ELSIF p_short_name = 'CMSHRTNM' THEN
                l_rslt_elmt := ben_ext_person.g_cm_short_name;
              ELSIF p_short_name = 'CMSTA' THEN
                l_rslt_elmt := ben_ext_person.g_cm_state;
              ELSIF p_short_name = 'CMTBSNTDT' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_cm_to_be_sent_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'CMTRGR' THEN
                l_rslt_elmt := ben_ext_person.g_cm_trgr_proc_name;
              ELSIF p_short_name = 'CMTRGRDT' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_cm_trgr_proc_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'CMTYP' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_cm_type,
                 to_char(ben_ext_person.g_cm_type_id));
              ELSIF p_short_name = 'CMZIP' THEN
                l_rslt_elmt := ben_ext_person.g_cm_postal_code;
              END IF;
           elsif p_two_char_substr = 'CO' then
              IF p_short_name = 'COBEFL' THEN
                l_rslt_elmt := ben_ext_person.g_contact_is_bnfcry_flag;
              ELSIF p_short_name = 'COCDFL' THEN
                l_rslt_elmt := ben_ext_person.g_contact_is_cvrd_dpnt_flag;
              ELSIF p_short_name = 'COCONSQNM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_contact_seq_num, p_frmt_mask_cd);
              ELSIF p_short_name = 'CODOB' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_contact_date_of_birth, p_frmt_mask_cd);
              ELSIF p_short_name = 'CODOD' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_contact_date_of_death, p_frmt_mask_cd);
              ELSIF p_short_name = 'CODSBL' THEN
                l_rslt_elmt := ben_ext_person.g_contact_disabled_flag;
              ELSIF p_short_name = 'COEDFL' THEN
                l_rslt_elmt := ben_ext_person.g_contact_is_elig_dpnt_flag;
              ELSIF p_short_name = 'COEMADR' THEN
                l_rslt_elmt := substr(ben_ext_person.g_contact_email_address,1,600) ;
              ELSIF p_short_name = 'COENDT' THEN
                l_rslt_elmt := apply_format_mask(ben_ext_person.g_contact_end_date, p_frmt_mask_cd);
              ELSIF p_short_name = 'COENLER' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_contact_end_life_evt,
                 to_char(ben_ext_person.g_contact_end_ler_id));
              ELSIF p_short_name = 'COFSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_contact_first_name;
              ELSIF p_short_name = 'COFULNM' THEN
                l_rslt_elmt := ben_ext_person.g_contact_full_name;
              ELSIF p_short_name = 'COFXNUM' THEN
                l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_contact_fax,p_frmt_mask_cd);
              ELSIF p_short_name = 'COKNASNM' THEN
                l_rslt_elmt := ben_ext_person.g_contact_known_as;
              ELSIF p_short_name = 'COLANG' THEN
                l_rslt_elmt := ben_ext_person.g_contact_language;
              ELSIF p_short_name = 'COLSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_contact_last_name;
              ELSIF p_short_name = 'COMBNUM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_contact_mobile, p_frmt_mask_cd);
              ELSIF p_short_name = 'COMIDNM' THEN
                l_rslt_elmt := ben_ext_person.g_contact_middle_names;
              ELSIF p_short_name = 'COMRTL' THEN
                l_rslt_elmt := ben_ext_person.g_contact_marital_status;
              ELSIF p_short_name = 'CONATID' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_contact_national_ident, p_frmt_mask_cd);
              ELSIF p_short_name = 'CONATION' THEN
                l_rslt_elmt := ben_ext_person.g_contact_nationality;
              ELSIF p_short_name = 'CONMSFX' THEN
                l_rslt_elmt := ben_ext_person.g_contact_suffix;
              ELSIF p_short_name = 'CONMPREFIX' THEN
                l_rslt_elmt := ben_ext_person.g_contact_prefix;
              ELSIF p_short_name = 'COPERSFL' THEN
                l_rslt_elmt := ben_ext_person.g_contact_personal_flag;
              ELSIF p_short_name = 'COPHNHM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_contact_home_phone, p_frmt_mask_cd);
              ELSIF p_short_name = 'COPHNWR' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_contact_work_phone, p_frmt_mask_cd);
              ELSIF p_short_name = 'COPLSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_contact_prev_last_name;
              ELSIF p_short_name = 'COPRADCITY' THEN
                l_rslt_elmt := ben_ext_person.g_contact_prim_city;
              ELSIF p_short_name = 'COPRADCNT' THEN
                l_rslt_elmt := ben_ext_person.g_contact_prim_country;
              ELSIF p_short_name = 'COPRADEFDT' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_contact_prim_effect_date, p_frmt_mask_cd);
              ELSIF p_short_name = 'COPRADLN1' THEN
                l_rslt_elmt := ben_ext_person.g_contact_prim_address1;
              ELSIF p_short_name = 'COPRADLN2' THEN
                l_rslt_elmt := ben_ext_person.g_contact_prim_address2;
              ELSIF p_short_name = 'COPRADLN3' THEN
                l_rslt_elmt := ben_ext_person.g_contact_prim_address3;
              ELSIF p_short_name = 'COPRADPCD' THEN
                l_rslt_elmt := ben_ext_person.g_contact_prim_postal_code;
              ELSIF p_short_name = 'COPRADRG' THEN
                l_rslt_elmt := ben_ext_person.g_contact_prim_region;
              ELSIF p_short_name = 'COPRADST' THEN
                l_rslt_elmt := ben_ext_person.g_contact_prim_state;
              ELSIF p_short_name = 'COPRMFL' THEN
                l_rslt_elmt := ben_ext_person.g_contact_prmy_contact_flag;
              ELSIF p_short_name = 'COPRNMAD' THEN
                l_rslt_elmt := ben_ext_person.g_contact_pre_name_adjunct;
              ELSIF p_short_name = 'COPYRFL' THEN
                l_rslt_elmt := ben_ext_person.g_contact_pymts_rcpnt_flag;
              ELSIF p_short_name = 'CORLSHP' THEN
                 l_rslt_elmt := ben_ext_person.g_contact_rlshp_type;
              ELSIF p_short_name = 'COSEX' THEN
                l_rslt_elmt := ben_ext_person.g_contact_sex;
              ELSIF p_short_name = 'COSHRFL' THEN
                l_rslt_elmt := ben_ext_person.g_contact_shared_resd_flag;
              ELSIF p_short_name = 'COSTDNT' THEN
                l_rslt_elmt := ben_ext_person.g_contact_student_status;
              ELSIF p_short_name = 'COSTDT' THEN
                l_rslt_elmt := ben_ext_person.g_contact_start_date;
              ELSIF p_short_name = 'COSTLER' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                   ben_ext_person.g_contact_start_life_evt,
                   to_char(ben_ext_person.g_contact_start_ler_id));
              ELSIF p_short_name = 'COTITLE' THEN
                l_rslt_elmt := ben_ext_person.g_contact_title;
              ELSIF p_short_name = 'COTOBUSG' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_contact_tobacco_usage, p_frmt_mask_cd);
              END IF;
           elsif p_two_char_substr = 'CV' then
              IF p_short_name = 'CVGST' THEN
                l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_enrt_cvg_strt_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'CVGTH' THEN
                --
                IF ben_ext_person.g_enrt_cvg_thru_dt =
                  to_date('31/12/4712','DD/MM/YYYY') THEN
                  --
                  l_rslt_elmt := null;
                  --
                ELSE
                  --
                  l_rslt_elmt := apply_format_mask
                  (ben_ext_person.g_enrt_cvg_thru_dt, p_frmt_mask_cd);
                  --
                END IF;

              END IF;
           elsif p_two_char_substr = 'CW' then
                 --- CWB Elements
                 hr_utility.set_location(' cwb extract  ' || p_two_char_substr  || ' /' || p_short_name  , 99 );
                 IF p_short_name = 'CWBLEN'  then
                     l_rslt_elmt := ben_ext_person.g_CWB_Life_Event_Name ;
                 ELSIF p_short_name = 'CWBLEOD' then
                      l_rslt_elmt := apply_format_mask (ben_ext_person.g_CWB_Life_Event_Occurred_Date,p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPGN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_PEOPLE_GROUP_name ;
                 ELSIF p_short_name = 'CWBPGS1' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_PEOPLE_GROUP_SEGMENT1 ;
                 ELSIF p_short_name = 'CWBPGS2' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_PEOPLE_GROUP_SEGMENT2 ;
                 ELSIF p_short_name = 'CWBPGS3' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_PEOPLE_GROUP_SEGMENT3 ;
                 ELSIF p_short_name = 'CWBPGS4' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_PEOPLE_GROUP_SEGMENT4 ;
                 ELSIF p_short_name = 'CWBPGS5' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_PEOPLE_GROUP_SEGMENT5 ;
                 ELSIF p_short_name = 'CWBPGS6' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_PEOPLE_GROUP_SEGMENT6 ;
                 ELSIF p_short_name = 'CWBPGS7' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_PEOPLE_GROUP_SEGMENT7 ;
                 ELSIF p_short_name = 'CWBPGS8' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_PEOPLE_GROUP_SEGMENT8 ;
                 ELSIF p_short_name = 'CWBPGS9' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_PEOPLE_GROUP_SEGMENT9 ;
                 ELSIF p_short_name = 'CWBPGS10' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_PEOPLE_GROUP_SEGMENT10 ;
                 ELSIF p_short_name = 'CWBPS' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_new_Perf_rating ;
                 ELSIF p_short_name = 'CWBPASD' then
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Person_ADJUSTED_SVC_DATE,p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBPAA1' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE1  ;
                 ELSIF p_short_name = 'CWBPAA2' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE2  ;
                 ELSIF p_short_name = 'CWBPAA3' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE3  ;
                 ELSIF p_short_name = 'CWBPAA4' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE4  ;
                 ELSIF p_short_name = 'CWBPAA5' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE5  ;
                 ELSIF p_short_name = 'CWBPAA6' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE6  ;
                 ELSIF p_short_name = 'CWBPAA7' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE7  ;
                 ELSIF p_short_name = 'CWBPAA8' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE8  ;
                 ELSIF p_short_name = 'CWBPAA9' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE9  ;
                 ELSIF p_short_name = 'CWBPAA10' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE10  ;
                 ELSIF p_short_name = 'CWBPAA11' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE11  ;
                 ELSIF p_short_name = 'CWBPAA12' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE12  ;
                 ELSIF p_short_name = 'CWBPAA13' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE13  ;
                 ELSIF p_short_name = 'CWBPAA14' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE14  ;
                 ELSIF p_short_name = 'CWBPAA15' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE15  ;
                 ELSIF p_short_name = 'CWBPAA16' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE16  ;
                 ELSIF p_short_name = 'CWBPAA17' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE17  ;
                 ELSIF p_short_name = 'CWBPAA18' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE18  ;
                 ELSIF p_short_name = 'CWBPAA19' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE19  ;
                 ELSIF p_short_name = 'CWBPAA20' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE20  ;
                 ELSIF p_short_name = 'CWBPAA21' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE21  ;
                 ELSIF p_short_name = 'CWBPAA22' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE22  ;
                 ELSIF p_short_name = 'CWBPAA23' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE23  ;
                 ELSIF p_short_name = 'CWBPAA24' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE24  ;
                 ELSIF p_short_name = 'CWBPAA25' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE25  ;
                 ELSIF p_short_name = 'CWBPAA26' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE26  ;
                 ELSIF p_short_name = 'CWBPAA27' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE27  ;
                 ELSIF p_short_name = 'CWBPAA28' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE28  ;
                 ELSIF p_short_name = 'CWBPAA29' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE29  ;
                 ELSIF p_short_name = 'CWBPAA30' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Assg_ATTRIBUTE30  ;
                 ELSIF p_short_name = 'CWBPBS' then
                      l_rslt_elmt := apply_format_mask(ben_ext_person.g_CWB_Person_BASE_SALARY , p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPBSF' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_BASE_SALARY_FREQ  ;
                 ELSIF p_short_name = 'CWBPBN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Brief_Name  ;
                 ELSIF p_short_name = 'CWBPBGN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_BG_Name  ;
                 ELSIF p_short_name = 'CWBPCN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Custom_Name  ;
                 ELSIF p_short_name = 'CWBPCS1' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT1  ;
                 ELSIF p_short_name = 'CWBPCS2' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT2  ;
                 ELSIF p_short_name = 'CWBPCS3' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT3  ;
                 ELSIF p_short_name = 'CWBPCS4' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT4  ;
                 ELSIF p_short_name = 'CWBPCS5' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT5  ;
                 ELSIF p_short_name = 'CWBPCS6' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT6  ;
                 ELSIF p_short_name = 'CWBPCS7' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT7  ;
                 ELSIF p_short_name = 'CWBPCS8' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT8  ;
                 ELSIF p_short_name = 'CWBPCS9' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT9  ;
                 ELSIF p_short_name = 'CWBPCS10' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT10  ;
                 ELSIF p_short_name = 'CWBPCS11' then
                      l_rslt_elmt := apply_format_mask(ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT11 , p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPCS12' then
                      l_rslt_elmt := apply_format_mask(ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT12 , p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPCS13' then
                      l_rslt_elmt := apply_format_mask(ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT13 , p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPCS14' then
                      l_rslt_elmt := apply_format_mask(ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT14 , p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPCS15' then
                      l_rslt_elmt := apply_format_mask(ben_ext_person.g_CWB_Person_CUSTOM_SEGMENT15 , p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPEA' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_EMAIL_DDRESS  ;
                 ELSIF p_short_name = 'CWBPEC' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_EMPloyee_CATEGORY   ;
                 ELSIF p_short_name = 'CWBPEN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_EMPLOYEE_NUMBER  ;
                 ELSIF p_short_name = 'CWBPFR' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_FEEDBACK_RATING  ;
                 ELSIF p_short_name = 'CWBPF' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_FREQUENCY  ;
                 ELSIF p_short_name = 'CWBPFN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_FULL_NAME  ;
                      hr_utility.set_location(' cwbfn ' || ben_ext_person.g_CWB_Person_FULL_NAME , 99 );
                 ELSIF p_short_name = 'CWBPGAF' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_GRADE_ANN_FACTOR  ;
                 ELSIF p_short_name = 'CWBPGC' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Grade_COMPARATIO  ;
                 ELSIF p_short_name = 'CWBPGMXV' then
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Person_Grade_MAX_VAL , p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPGMP' then
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Person_Grade_MID_POINT, p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPGMNV' then
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Person_Grade_MIN_VAL , p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPGRDN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_GRADE_name  ;
                 ELSIF p_short_name = 'CWBPGQ' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Grade_QUARTILE  ;
                 ELSIF p_short_name = 'CWBPIA1' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE1  ;
                 ELSIF p_short_name = 'CWBPIA2' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE2  ;
                 ELSIF p_short_name = 'CWBPIA3' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE3  ;
                 ELSIF p_short_name = 'CWBPIA4' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE4  ;
                 ELSIF p_short_name = 'CWBPIA5' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE5  ;
                 ELSIF p_short_name = 'CWBPIA6' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE6  ;
                 ELSIF p_short_name = 'CWBPIA7' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE7  ;
                 ELSIF p_short_name = 'CWBPIA8' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE8  ;
                 ELSIF p_short_name = 'CWBPIA9' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE9  ;
                 ELSIF p_short_name = 'CWBPIA10' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE10  ;
                 ELSIF p_short_name = 'CWBPIA11' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE11  ;
                 ELSIF p_short_name = 'CWBPIA12' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE12  ;
                 ELSIF p_short_name = 'CWBPIA13' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE13  ;
                 ELSIF p_short_name = 'CWBPIA14' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE14  ;
                 ELSIF p_short_name = 'CWBPIA15' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE15  ;
                 ELSIF p_short_name = 'CWBPIA16' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE16  ;
                 ELSIF p_short_name = 'CWBPIA17' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE17  ;
                 ELSIF p_short_name = 'CWBPIA18' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE18  ;
                 ELSIF p_short_name = 'CWBPIA19' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE19  ;
                 ELSIF p_short_name = 'CWBPIA20' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE20  ;
                 ELSIF p_short_name = 'CWBPIA21' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE21  ;
                 ELSIF p_short_name = 'CWBPIA22' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE22  ;
                 ELSIF p_short_name = 'CWBPIA23' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE23  ;
                 ELSIF p_short_name = 'CWBPIA24' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE24  ;
                 ELSIF p_short_name = 'CWBPIA25' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE25  ;
                 ELSIF p_short_name = 'CWBPIA26' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE26  ;
                 ELSIF p_short_name = 'CWBPIA27' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE27  ;
                 ELSIF p_short_name = 'CWBPIA28' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE28  ;
                 ELSIF p_short_name = 'CWBPIA29' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE29  ;
                 ELSIF p_short_name = 'CWBPIA30' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_Info_ATTRIBUTE30  ;
                 ELSIF p_short_name = 'CWBPJN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_JOB_name  ;
                 ELSIF p_short_name = 'CWBPLG' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_LEGISLATION  ;
                 ELSIF p_short_name = 'CWBPLOC' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_LOCATION  ;
                 ELSIF p_short_name = 'CWBPNH' then
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Person_NORMAL_HOURS , p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPON' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_ORG_name  ;
                 ELSIF p_short_name = 'CWBPOSD' then
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Person_ORIG_START_DATE , p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPPAF' then
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Person_PAY_ANNUL_FACTOR , p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBPPR' then
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Person_PAY_RATE ;   ---- ?????????
                 ELSIF p_short_name = 'CWBPPN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_PAYROLL_NAME  ;
                 ELSIF p_short_name = 'CWBPPRTN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_PERF_RATING  ;
                 ELSIF p_short_name = 'CWBPPRD' then
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Person_PERF_RATING_DATE, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBPPRT' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Persom_PERF_RATING_TYPE  ;
                 ELSIF p_short_name = 'CWBPP' then
                      l_rslt_elmt :=  ben_ext_person. g_CWB_Person_POSITION  ;
                 ELSIF p_short_name = 'CWBPPPS' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_POST_PROCESS_Stat  ;
                 ELSIF p_short_name = 'CWBPSD' then
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Person_START_DATE, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBPST' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_STATUS_TYPE  ;
                 ELSIF p_short_name = 'CWBPSBN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_SUP_BRIEF_NAME  ;
                 ELSIF p_short_name = 'CWBPSCN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_SUP_CUSTOM_NAME  ;
                 ELSIF p_short_name = 'CWBPSFN' then
                      l_rslt_elmt :=  ben_ext_person.g_CWB_Person_SUP_FULL_NAME  ;
                 ELSIF p_short_name = 'CWBPYE' then
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Person_YEARS_EMPLOYED, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBPYIG' then
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Person_YEARS_IN_GRADE, p_frmt_mask_cd)  ;
                 ELSIF p_short_name = 'CWBPYIJ' then
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Person_YEARS_IN_JOB, p_frmt_mask_cd)  ;
                 ELSIF p_short_name = 'CWBPYIP' then
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Person_YEARS_IN_POS, p_frmt_mask_cd)  ;
                 ELSIF p_short_name = 'CWBPSTAT' then
                      l_rslt_elmt :=   ben_ext_person.g_CWB_new_Postion_name ;
                 --- cwb groups
                 ELSIF p_short_name = 'CWBB'  THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Budget_PL_ID  ;
                 ELSIF p_short_name = 'CWBBACS'  THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Budget_Access   ;
                 ELSIF p_short_name = 'CWBBAPRL'  THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Budget_Approval   ;
                 ELSIF p_short_name = 'CWBBAD'  THEN
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Budget_Approval_Date, p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBBDBV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Budget_Dist_Budget_Value, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBBDD'  THEN
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Budget_Due_Date, p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBBGON'  THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Budget_Group_Option_Name ;
                 ELSIF p_short_name = 'CWBBGPN'  THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Budget_Group_Plan_Name  ;
                 ELSIF p_short_name = 'CWBBLUB'  THEN
                        l_rslt_elmt :=
                     decode_setup(p_data_elmt_typ_cd,
                                                  get_name(ben_ext_person.g_CWB_Budget_Last_Updt_By),
                                                                  ben_ext_person.g_CWB_Budget_Last_Updt_By);
                 ELSIF p_short_name = 'CWBBLUD'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Budget_Last_Updt_dt, p_frmt_mask_cd);
                 ELSIF p_short_name = 'CWBBP'  THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Budget_Population ;
                 ELSIF p_short_name = 'CWBBRMXV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Budget_Resv_Max_Value, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBBRMNV'  THEN
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Budget_Resv_Min_Value, p_frmt_mask_cd)  ;
                 ELSIF p_short_name = 'CWBBRV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Budget_Resv_Value , p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBBRVLUB'  THEN
                           l_rslt_elmt :=
                     decode_setup(p_data_elmt_typ_cd,
                                                  get_name(ben_ext_person.g_CWB_Budget_Resv_Val_Updt_By),
                                                                  ben_ext_person.g_CWB_Budget_Resv_Val_Updt_By);
                 ELSIF p_short_name = 'CWBBRVLUD'  THEN
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Budget_Resv_Val_Updt_dt, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBBSD'  THEN
                      l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_CWB_Budget_Submit_date , p_frmt_mask_cd)    ;
                 ELSIF p_short_name = 'CWBBSN'  THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Budget_Submit_Name ;
                 ELSIF p_short_name = 'CWBBWBV'  THEN
                      l_rslt_elmt :=    apply_format_mask(ben_ext_person.g_CWB_Budget_WS_Budget_Value, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBDBID'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Dist_Budget_Issue_date, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBDBIV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Dist_Budget_Issue_Value, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBDBMNV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Dist_Budget_Max_Value, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBDBMXV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Dist_Budget_Max_Value, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBDBVLUB'  THEN
                             l_rslt_elmt :=
                     decode_setup(p_data_elmt_typ_cd,
                                                  get_name(ben_ext_person.g_CWB_Dist_Budget_Val_Updt_By),
                                                                  ben_ext_person.g_CWB_Dist_Budget_Val_Updt_By);
                 ELSIF p_short_name = 'CWBDBVLUD'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Dist_Budget_Val_Updt_dt, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBWBID'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_WS_Budget_Issue_Date, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBWBIV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_WS_Budget_Max_Value, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBWBMXV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_WS_Budget_Max_Value, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBWBMNV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_WS_Budget_Min_Value, p_frmt_mask_cd) ;
                 ELSIF p_short_name = 'CWBWBVLUB'  THEN
                                 l_rslt_elmt :=
                     decode_setup(p_data_elmt_typ_cd,
                                                  get_name(ben_ext_person.g_CWB_WS_Budget_Val_Updt_By),
                                                                  ben_ext_person.g_CWB_WS_Budget_Val_Updt_By);
                 ELSIF p_short_name = 'CWBWBVLUD'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_WS_Budget_Val_Updt_dt, p_frmt_mask_cd) ;
                 -- cwb  rates
                ELSIF p_short_name = 'CWBAEF' THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Awrd_Elig_Flag ;
                ELSIF p_short_name  = 'CWBAESV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Awrd_Elig_Salary_Value, p_frmt_mask_cd) ;
                ELSIF p_short_name  = 'CWBAGON'  THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Awrd_Group_Option_Name ;
                ELSIF p_short_name  = 'CWBAGPN'  THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Awrd_Group_Plan_Name ;
                ELSIF p_short_name  = 'CWBAMV1'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Awrd_Misc_Value1, p_frmt_mask_cd) ;
                ELSIF p_short_name  = 'CWBAMV2'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Awrd_Misc_Value2, p_frmt_mask_cd) ;
                ELSIF p_short_name  = 'CWBAMV3'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Awrd_Misc_Value3, p_frmt_mask_cd) ;
                ELSIF p_short_name  = 'CWBAON'   THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Awrd_Option_Name ;
                ELSIF p_short_name  = 'CWBAOCV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Awrd_Other_Comp_Value, p_frmt_mask_cd) ;
                ELSIF p_short_name  = 'CWBAPN'   THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Awrd_Plan_Name  ;
                ELSIF p_short_name  = 'CWBARV'   THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Awrd_Recorded_Value, p_frmt_mask_cd) ;
                ELSIF p_short_name  = 'CWBASSV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Awrd_Stated_Salary_Value, p_frmt_mask_cd) ;
                ELSIF p_short_name  = 'CWBATCV'  THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Awrd_Total_Comp_Value, p_frmt_mask_cd) ;
                ELSIF p_short_name  = 'CWBAWMXV' THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Awrd_WS_Maximum_Value, p_frmt_mask_cd) ;
                ELSIF p_short_name  = 'CWBAWMNV' THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Awrd_WS_Minimum_Value, p_frmt_mask_cd) ;
                ELSIF p_short_name  = 'CWBAWV'   THEN
                      l_rslt_elmt :=   apply_format_mask(ben_ext_person.g_CWB_Awrd_WS_Value, p_frmt_mask_cd) ;
                ELSIF p_short_name  = 'CWBNCR'   THEN
                      l_rslt_elmt :=   ben_ext_person.g_cwb_nw_chg_reason ;
                ELSIF p_short_name  = 'CWBRDGS'   THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_new_Grade_name ;
                ELSIF p_short_name  = 'CWBGRPS'   THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_new_Group_name ;
                ELSIF p_short_name  = 'CWBJS'   THEN
                      l_rslt_elmt :=   ben_ext_person.g_CWB_new_Job_name ;
                ELSIF p_short_name  = 'CWBPILST'  then
                      l_rslt_elmt :=   ben_ext_person.g_CWB_Life_Event_status ;
                ELSIF p_short_name  = 'CWBGPLN'  then
                       l_rslt_elmt :=   ben_ext_person.g_cwb_group_plan_name ;
                END IF ;
                --- EOF cwb


           end if;
      elsif p_one_char_substr = 'D' then
           if p_two_char_substr in ('DA','DB','DC') then
              IF p_short_name = 'DATVRFDT' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_data_verification_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'DCONSQNM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_dpnt_contact_seq_num, p_frmt_mask_cd);
              ELSIF p_short_name = 'DCVID' THEN
                l_rslt_elmt := apply_format_mask(ben_ext_person.g_dpnt_cvrd_dpnt_id,p_frmt_mask_cd) ;
              ELSIF p_short_name = 'DCVGST' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_dpnt_cvg_strt_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'DCVGTH' THEN
                --
                  IF ben_ext_person.g_dpnt_cvg_thru_dt =
                     to_date('31/12/4712','DD/MM/YYYY') THEN
                     l_rslt_elmt := null;
                  ELSE
                     l_rslt_elmt := apply_format_mask
                     (ben_ext_person.g_dpnt_cvg_thru_dt, p_frmt_mask_cd);
                  END IF;
                  --
              END IF ;
           elsif p_two_char_substr in ('DD','DE') then
              IF p_short_name = 'DDOB' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_dpnt_date_of_birth, p_frmt_mask_cd);
              ELSIF p_short_name = 'DDOD' THEN
                 l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_dpnt_date_of_death, p_frmt_mask_cd);
              ELSIF p_short_name = 'DDSBL' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_disabled_flag;
              ELSIF p_short_name = 'DEMADR' THEN
                l_rslt_elmt := substr(ben_ext_person.g_dpnt_email_address,1,600);
              END IF;
           elsif p_two_char_substr in ('DF','DK','DL','DM') then
              IF p_short_name = 'DFSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_first_name;
              ELSIF p_short_name = 'DFULNM' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_full_name;
              ELSIF p_short_name = 'DFXNUM' THEN
                l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_dpnt_fax,p_frmt_mask_cd);
              ELSIF p_short_name = 'DKNASNM' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_known_as;
              ELSIF p_short_name = 'DLANG' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_language;
              ELSIF p_short_name = 'DLSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_last_name;
              ELSIF p_short_name = 'DMBNUM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_dpnt_mobile,p_frmt_mask_cd);
              ELSIF p_short_name = 'DMIDNM' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_middle_names;
              ELSIF p_short_name = 'DMRTL' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_marital_status;
              END IF;
           elsif p_two_char_substr in ('DN','DO') then
              IF p_short_name = 'DNATID' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_dpnt_national_identifier, p_frmt_mask_cd);
              ELSIF p_short_name = 'DNATION' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_nationality;
              ELSIF p_short_name = 'DNMSFX' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_suffix;
              ELSIF p_short_name = 'DNMPREFIX' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_prefix;
              ELSIF p_short_name = 'DOB' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_date_of_birth, p_frmt_mask_cd);
              ELSIF p_short_name = 'DOD' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_date_of_death, p_frmt_mask_cd);
              END IF;
           elsif p_two_char_substr = 'DP' then
              IF p_short_name = 'DPHNHM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_dpnt_home_phone, p_frmt_mask_cd);
              ELSIF p_short_name = 'DPHNWR' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_dpnt_work_phone, p_frmt_mask_cd);
              ELSIF p_short_name = 'DPLSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_prev_last_name;
              ELSIF p_short_name = 'DPPREND' THEN
                --
                IF ben_ext_person.g_dpnt_ppr_end_dt =
                  to_date('31/12/4712','DD/MM/YYYY') THEN
                  l_rslt_elmt := null;
                ELSE
                   l_rslt_elmt := apply_format_mask
                      (ben_ext_person.g_dpnt_ppr_end_dt, p_frmt_mask_cd);
                END IF;
                --
              ELSIF p_short_name = 'DPPRIDENT' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_ppr_ident;
              ELSIF p_short_name = 'DPPRNAME' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_ppr_name;
              ELSIF p_short_name = 'DPPRSTRT' THEN
                  l_rslt_elmt := apply_format_mask
                     (ben_ext_person.g_dpnt_ppr_strt_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'DPPRTYP' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_ppr_typ;
              ELSIF p_short_name = 'DPRADCITY' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_prim_city;
              ELSIF p_short_name = 'DPRADCNT' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_prim_country;
              ELSIF p_short_name = 'DPRADEFDT' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_dpnt_prim_effect_date, p_frmt_mask_cd);
              ELSIF p_short_name = 'DPRADLN1' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_prim_address1;
              ELSIF p_short_name = 'DPRADLN2' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_prim_address2;
              ELSIF p_short_name = 'DPRADLN3' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_prim_address3;
              ELSIF p_short_name = 'DPRADPCD' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_prim_postal_code;
              ELSIF p_short_name = 'DPRADRG' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_prim_region;
              ELSIF p_short_name = 'DPRADST' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_prim_state;
              ELSIF p_short_name = 'DPRNMAD' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_pre_name_adjunct;
              END IF;
           elsif p_two_char_substr in ('DR','DS','DT') then
              IF p_short_name = 'DRLSHP' THEN
                 l_rslt_elmt := ben_ext_person.g_dpnt_rlshp_type;
              ELSIF p_short_name = 'DSBL' THEN
                l_rslt_elmt := ben_ext_person.g_registered_disabled_flag;
              ELSIF p_short_name = 'DSEX' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_sex;
              ELSIF p_short_name = 'DSHRFL' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_shared_resd_flag;
              ELSIF p_short_name = 'DSTDNT' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_student_status;
              ELSIF p_short_name = 'DTITLE' THEN
                l_rslt_elmt := ben_ext_person.g_dpnt_title;
              ELSIF p_short_name = 'DTOBUSG' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_dpnt_tobacco_usage, p_frmt_mask_cd);
              END IF;
           end if;
      elsif p_one_char_substr = 'E' then
           if p_two_char_substr in ('EA','EC') then
              IF p_short_name = 'EAGE' THEN
                 l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_elig_age_val, p_frmt_mask_cd);
              ELSIF p_short_name = 'EAGELOS' THEN
                 l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_elig_cmbn_age_n_los, p_frmt_mask_cd);
              ELSIF p_short_name = 'EAGEUOM' THEN
                 l_rslt_elmt := ben_ext_person.g_elig_age_uom;
              ELSIF p_short_name = 'ECMPAMT' THEN
                 l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_elig_comp_amt, p_frmt_mask_cd);
              ELSIF p_short_name = 'ECMPUOM' THEN
                 l_rslt_elmt := ben_ext_person.g_elig_comp_amt_uom;
              ELSIF p_short_name = 'ECVGAMT' THEN
                 l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_elig_cvg_amt, p_frmt_mask_cd);
              END IF;
           elsif p_two_char_substr = 'ED' then
              IF p_short_name = 'EDCONSQNM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_elig_dpnt_contact_seq_num,p_frmt_mask_cd);
              ELSIF p_short_name = 'EDCRDT' THEN
                 l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_elig_dpnt_create_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDID' THEN
                l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_elig_dpnt_id, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDDOB' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_elig_dpnt_date_of_birth, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDDOD' THEN
                 l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_elig_dpnt_date_of_death, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDDSBL' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_disabled_flag;
              ELSIF p_short_name = 'EDELGST' THEN
                 l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_elig_dpnt_elig_strt_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDELGTH' THEN
                IF ben_ext_person.g_elig_dpnt_elig_thru_dt =
                  to_date('31/12/4712', 'DD/MM/YYYY') THEN
                  l_rslt_elmt := null;
                ELSE
                  l_rslt_elmt := apply_format_mask
                  (ben_ext_person.g_elig_dpnt_elig_thru_dt, p_frmt_mask_cd);
                END IF;
              ELSIF p_short_name = 'EDEMADR' THEN
                l_rslt_elmt := substr(ben_ext_person.g_elig_dpnt_email_address,1,600) ;
              ELSIF p_short_name = 'EDFLTAMT' THEN
                 l_rslt_elmt := apply_format_mask
                 (ben_ext_person.g_elig_dflt_amt, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDFSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_first_name;
              ELSIF p_short_name = 'EDFULNM' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_full_name;
              ELSIF p_short_name = 'EDFXNUM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_elig_dpnt_fax, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDKNASNM' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_known_as;
              ELSIF p_short_name = 'EDLANG' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_language;
              ELSIF p_short_name = 'EDLSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_last_name;
              ELSIF p_short_name = 'EDMBNUM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_elig_dpnt_mobile, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDMIDNM' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_middle_names;
              ELSIF p_short_name = 'EDMRTL' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_marital_status;
              ELSIF p_short_name = 'EDNATID' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_elig_dpnt_national_ident, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDNATION' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_nationality;
              ELSIF p_short_name = 'EDNMSFX' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_suffix;
              ELSIF p_short_name = 'EDORDT' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_elig_dpnt_ovrdn_thru_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDORF' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_ovrdn_flag;
              ELSIF p_short_name = 'EDPHNHM' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_elig_dpnt_home_phone, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDPHNWR' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_elig_dpnt_work_phone, p_frmt_mask_cd);
              ELSIF p_short_name = 'EDPLSTNM' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_prev_last_name;
              ELSIF p_short_name = 'EDPRADCITY' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_prim_city;
              ELSIF p_short_name = 'EDPRADCNT' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_prim_country;
              ELSIF p_short_name = 'EDPRADEFDT' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_elig_dpnt_prim_effect_date,p_frmt_mask_cd);
              ELSIF p_short_name = 'EDPRADLN1' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_prim_address1;
              ELSIF p_short_name = 'EDPRADLN2' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_prim_address2;
              ELSIF p_short_name = 'EDPRADLN3' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_prim_address3;
              ELSIF p_short_name = 'EDPRADPCD' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_prim_postal_code;
              ELSIF p_short_name = 'EDPRADRG' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_prim_region;
              ELSIF p_short_name = 'EDPRADST' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_prim_state;
              ELSIF p_short_name = 'EDPRNMAD' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_pre_name_adjunct;
              ELSIF p_short_name = 'EDRLSHP' THEN
                 l_rslt_elmt := ben_ext_person.g_elig_dpnt_rlshp_type;
              ELSIF p_short_name = 'EDSEX' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_sex;
              ELSIF p_short_name = 'EDSHRFL' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_shared_resd_flag;
              ELSIF p_short_name = 'EDSTDNT' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_student_status;
              ELSIF p_short_name = 'EDTITLE' THEN
                l_rslt_elmt := ben_ext_person.g_elig_dpnt_title;
              ELSIF p_short_name = 'EDTOBUSG' THEN
                l_rslt_elmt := apply_format_mask
                (ben_ext_person.g_elig_dpnt_tobacco_usage, p_frmt_mask_cd);
              END IF;
           elsif p_two_char_substr = 'EE' then
              IF p_short_name = 'EEDFLTDT' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_dflt_enrt_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'EELCMDDT' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_elec_made_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'EEMPAFTTAX' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_ee_after_tax_cost, p_frmt_mask_cd);
              ELSIF p_short_name = 'EEMPPRETAX' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_ee_pre_tax_cost, p_frmt_mask_cd);
              ELSIF p_short_name = 'EEMPTOTCST' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_ee_ttl_cost, p_frmt_mask_cd);
              ELSIF p_short_name = 'EEPRTOTCST' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_er_ttl_cost, p_frmt_mask_cd);
              ELSIF p_short_name = 'EESTDT' THEN
               l_rslt_elmt :=
                 apply_format_mask(ben_ext_person.g_elig_enrt_strt_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'EETHRUDT' THEN
               l_rslt_elmt :=
                 apply_format_mask(ben_ext_person.g_elig_enrt_end_dt, p_frmt_mask_cd);
              END IF;
           elsif p_two_char_substr = 'EF' then
              IF p_short_name = 'EFFDT' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_extract.g_effective_date,p_frmt_mask_cd);
              ELSIF p_short_name = 'EFLX01' THEN
                l_rslt_elmt := ben_ext_person.g_elig_flex_01;
              ELSIF p_short_name = 'EFLX02' THEN
                l_rslt_elmt := ben_ext_person.g_elig_flex_02;
              ELSIF p_short_name = 'EFLX03' THEN
                l_rslt_elmt := ben_ext_person.g_elig_flex_03;
              ELSIF p_short_name = 'EFLX04' THEN
                l_rslt_elmt := ben_ext_person.g_elig_flex_04;
              ELSIF p_short_name = 'EFLX05' THEN
                l_rslt_elmt := ben_ext_person.g_elig_flex_05;
              ELSIF p_short_name = 'EFLX06' THEN
                l_rslt_elmt := ben_ext_person.g_elig_flex_06;
              ELSIF p_short_name = 'EFLX07' THEN
                l_rslt_elmt := ben_ext_person.g_elig_flex_07;
              ELSIF p_short_name = 'EFLX08' THEN
                l_rslt_elmt := ben_ext_person.g_elig_flex_08;
              ELSIF p_short_name = 'EFLX09' THEN
                l_rslt_elmt := ben_ext_person.g_elig_flex_09;
              ELSIF p_short_name = 'EFLX10' THEN
                l_rslt_elmt := ben_ext_person.g_elig_flex_10;
              END IF;
           elsif p_two_char_substr in ('EH','EI') then
              IF p_short_name = 'EHRSWKD' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_hrs_wkd, p_frmt_mask_cd);
              ELSIF p_short_name = 'EINCRAMT' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_incr_amt, p_frmt_mask_cd);
              END IF;
           elsif p_two_char_substr = 'EL' then
              IF p_short_name = 'ELCVAO' THEN
                 l_rslt_elmt := ben_ext_person.g_elig_cvg_onl_flg;
              ELSIF p_short_name = 'ELCVBT' THEN
                 l_rslt_elmt := ben_ext_person.g_elig_cvg_bnft_typ;
              ELSIF p_short_name = 'ELCVBU' THEN
                 l_rslt_elmt := ben_ext_person.g_elig_cvg_bnft_uom;
              ELSIF p_short_name = 'ELCVCM' THEN
                 l_rslt_elmt := ben_ext_person.g_elig_cvg_calc_mthd;
              ELSIF p_short_name = 'ELCVDA' THEN
                 l_rslt_elmt :=
                    apply_format_mask(ben_ext_person.g_elig_cvg_dfl_amt, p_frmt_mask_cd);
              ELSIF p_short_name = 'ELCVDF' THEN
                 l_rslt_elmt := ben_ext_person.g_elig_cvg_dfl_flg;
              ELSIF p_short_name = 'ELCVIN' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_cvg_inc_amt, p_frmt_mask_cd);
              ELSIF p_short_name = 'ELCVMN' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_cvg_min_amt, p_frmt_mask_cd);
              ELSIF p_short_name = 'ELCVMX' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_cvg_max_amt, p_frmt_mask_cd);
              ELSIF p_short_name = 'ELCVOR' THEN
                 l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_cvg_seq_no, p_frmt_mask_cd);
              ELSIF p_short_name = 'ELDSC' THEN
                 l_rslt_elmt := ben_ext_person.g_element_description;
              ELSIF p_short_name = 'ELECS' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                   ben_ext_person.g_element_entry_costing,
                   to_char(ben_ext_person.g_element_entry_costing_id));
              ELSIF p_short_name = 'ELEED' THEN
                 if ben_ext_person.g_element_entry_eff_end_date = hr_api.g_eot then
                    l_rslt_elmt := null ;
                 else
                    l_rslt_elmt := apply_format_mask(ben_ext_person.g_element_entry_eff_end_date,
                                   p_frmt_mask_cd);
                 end if ;
              ELSIF p_short_name = 'ELEID' THEN
                 l_rslt_elmt :=
                    apply_format_mask(ben_ext_person.g_element_entry_id, p_frmt_mask_cd);
              ELSIF p_short_name = 'ELENM' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                   ben_ext_person.g_elig_lfevt_name,
                   to_char(ben_ext_person.g_elig_ler_id));
              ELSIF p_short_name = 'ELENTDT' THEN
                l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_lfevt_note_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'ELEOCRDT' THEN
                  l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_lfevt_ocrd_dt, p_frmt_mask_cd);
              ELSIF p_short_name = 'ELERS' THEN
                  l_rslt_elmt := ben_ext_person.g_element_entry_reason;
              ELSIF p_short_name = 'ELESD' THEN
                  l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_element_entry_eff_start_date,p_frmt_mask_cd);
              ELSIF p_short_name = 'ELVESDT' THEN
                  l_rslt_elmt := apply_format_mask(ben_ext_person.g_element_eev_eff_strt_date,p_frmt_mask_cd);
                   hr_utility.set_location('eeveffdate '||ben_ext_person.g_element_eev_eff_strt_date  ,99);

               ELSIF p_short_name = 'ELVEEDT' THEN
                    if ben_ext_person.g_element_eev_eff_end_date = hr_api.g_eot then
                       l_rslt_elmt := null ;
                    else
                        l_rslt_elmt := apply_format_mask(ben_ext_person.g_element_eev_eff_end_date,p_frmt_mask_cd);
                     end if ;
                   hr_utility.set_location('eeveffdate '||ben_ext_person.g_element_eev_eff_end_date  ,99);
                ELSIF p_short_name = 'ELESTS' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_lfevt_status;
                ELSIF p_short_name = 'ELEVL' THEN
                  -- checking whether numeric formating applicable
                  l_number := 'Y';
                  -- begin bug# 2247340
                  -- the modification made above as part of 2197144 doesn't check for negative number
                  DECLARE
                  	 ln_is_number number;
                  BEGIN
                     ln_is_number := to_number(ben_ext_person.g_element_entry_value);
                     l_number := 'Y' ;
                  EXCEPTION
                     when value_error then
                      l_number := 'N';
                  END;
                  -- end bug# 2247340


                  -- if the value is a pure number then
                  if l_number = 'Y' then
                    -- call numeric formatting
                    l_rslt_elmt := apply_format_mask(to_number(ben_ext_person.g_element_entry_value), p_frmt_mask_cd);
                  else
                    -- else do not format, just pass the value
                    l_rslt_elmt := ben_ext_person.g_element_entry_value;
                  end if;

                ELSIF p_short_name = 'ELICU' THEN
                   l_rslt_elmt := ben_ext_person.g_element_input_currency_code;
                ELSIF p_short_name = 'ELIVNM' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                     ben_ext_person.g_element_input_value_name,
                     to_char(ben_ext_person.g_element_input_value_id));
                ELSIF p_short_name = 'ELIVSQ' THEN
                   l_rslt_elmt :=
                     apply_format_mask(ben_ext_person.g_element_input_value_sequence,p_frmt_mask_cd);
                ELSIF p_short_name = 'ELIVUN' THEN
                   l_rslt_elmt := ben_ext_person.g_element_input_value_units;
                ELSIF p_short_name = 'ELNM' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                     ben_ext_person.g_element_name,
                     to_char(ben_ext_person.g_element_id));
                ELSIF p_short_name = 'ELOCU' THEN
                   l_rslt_elmt := ben_ext_person.g_element_output_currency_code;
                ELSIF p_short_name = 'ELOS' THEN
                   l_rslt_elmt :=
                     apply_format_mask(ben_ext_person.g_elig_los_val, p_frmt_mask_cd);
                ELSIF p_short_name = 'ELOSUOM' THEN
                   l_rslt_elmt := ben_ext_person.g_elig_los_uom;
                ELSIF p_short_name = 'ELPCL' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                     ben_ext_person.g_element_classification_name,
                     to_char(ben_ext_person.g_element_classification_id));
                ELSIF p_short_name = 'ELPTY' THEN
                   l_rslt_elmt := ben_ext_person.g_element_processing_type;
                ELSIF p_short_name = 'ELRNM' THEN
                   l_rslt_elmt := ben_ext_person.g_element_reporting_name;
                ELSIF p_short_name = 'ELSRL' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                     ben_ext_person.g_element_skip_rule,
                     to_char(ben_ext_person.g_element_skip_rule_id));
                END IF;
            elsif p_two_char_substr = 'EM' then
                IF p_short_name = 'EMAXAMT' THEN
                   l_rslt_elmt :=
                     apply_format_mask(ben_ext_person.g_elig_max_amt, p_frmt_mask_cd);
                ELSIF p_short_name = 'EMINAMT' THEN
                   l_rslt_elmt :=
                     apply_format_mask(ben_ext_person.g_elig_min_amt, p_frmt_mask_cd);
                ELSIF p_short_name = 'EMPBU' THEN
                  l_rslt_elmt := ben_ext_person.g_employee_barg_unit;
                ELSIF p_short_name = 'EMPCATG' THEN
                  l_rslt_elmt := ben_ext_person.g_employee_category;
                ELSIF p_short_name = 'EMPGR' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                     ben_ext_person.g_employee_grade,
                     to_char(ben_ext_person.g_employee_grade_id));
                ELSIF p_short_name = 'EMPLOC' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                     ben_ext_person.g_location_code,
                     to_char(ben_ext_person.g_location_id));

                ELSIF p_short_name = 'EMPLOCADR1' then
                      l_rslt_elmt := ben_ext_person.g_location_addr1;
                ELSIF p_short_name = 'EMPLOCADR2' then
                      l_rslt_elmt := ben_ext_person.g_location_addr2;
                ELSIF p_short_name = 'EMPLOCADR3' then
                      l_rslt_elmt := ben_ext_person.g_location_addr3;
                ELSIF p_short_name = 'EMPLOCTWN' then
                      l_rslt_elmt := ben_ext_person.g_location_city;
                ELSIF p_short_name = 'EMPLOCNTRY' then
                      l_rslt_elmt := ben_ext_person.g_location_country;
                ELSIF p_short_name = 'EMPLOZIP' then
                      l_rslt_elmt := ben_ext_person.g_location_zip;
                ELSIF p_short_name = 'EMPLOCRG1' then
                      l_rslt_elmt := ben_ext_person.g_location_region1;
                ELSIF p_short_name = 'EMPLOCRG2' then
                      l_rslt_elmt := ben_ext_person.g_location_region2;
                ELSIF p_short_name = 'EMPLOCRG3' then
                      l_rslt_elmt := ben_ext_person.g_location_region3;
                ELSIF p_short_name = 'EMPNO' THEN
                  l_rslt_elmt := ben_ext_person.g_employee_number;
                ELSIF p_short_name = 'EMPORG' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                     ben_ext_person.g_employee_organization,
                    to_char(ben_ext_person.g_employee_organization_id));

               --- organization addr 1
               ELSIF p_short_name = 'EMPORADDL1' THEN
                  l_rslt_elmt := ben_ext_person.g_org_location_addr1;
               ELSIF p_short_name = 'EMPORADDL2' THEN
                  l_rslt_elmt := ben_ext_person.g_org_location_addr2;
               ELSIF p_short_name = 'EMPORADDL3' THEN
                  l_rslt_elmt := ben_ext_person.g_org_location_addr3;
               ELSIF p_short_name = 'EMPORADDCTY' THEN
                  l_rslt_elmt := ben_ext_person.g_org_location_city;
               ELSIF p_short_name = 'EMPORADDCNT' THEN
                  l_rslt_elmt := ben_ext_person.g_org_location_country;
               ELSIF p_short_name = 'EMPORADDZIP' THEN
                  l_rslt_elmt := ben_ext_person.g_org_location_zip;
               ELSIF p_short_name = 'EMPORADDRG1' THEN
                  l_rslt_elmt := ben_ext_person.g_org_location_region1;
               ELSIF p_short_name = 'EMPORADDRG2' THEN
                  l_rslt_elmt := ben_ext_person.g_org_location_region2;
               ELSIF p_short_name = 'EMPORADDRG3' THEN
                  l_rslt_elmt := ben_ext_person.g_org_location_region3;
               ELSIF p_short_name = 'EMPORADDPH' THEN
                  l_rslt_elmt := ben_ext_person.g_org_location_phone;
                ---
                ELSIF p_short_name = 'EMPST' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                     ben_ext_person.g_employee_status,
                     to_char(ben_ext_person.g_employee_status_id));
                ELSIF p_short_name = 'EMPASID' then
                     l_rslt_elmt := ben_ext_person.g_assignment_id ;
                ELSIF p_short_name = 'EMPASTY' then
                      hr_utility.set_location(' EMPASTY ' || ben_ext_person.g_asg_type, 99 );
                     l_rslt_elmt := ben_ext_person.g_asg_type;
                end if;
             elsif p_two_char_substr = 'EN' then
                IF p_short_name = 'ENDDT' THEN
                   l_rslt_elmt := apply_format_mask(ben_extract.g_ext_end_dt,p_frmt_mask_cd);
                end if;
            elsif p_two_char_substr = 'EO' then
                IF p_short_name = 'EOIPFLX01' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_in_pl_flex_01;
                ELSIF p_short_name = 'EOIPFLX02' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_in_pl_flex_02;
                ELSIF p_short_name = 'EOIPFLX03' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_in_pl_flex_03;
                ELSIF p_short_name = 'EOIPFLX04' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_in_pl_flex_04;
                ELSIF p_short_name = 'EOIPFLX05' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_in_pl_flex_05;
                ELSIF p_short_name = 'EOIPFLX06' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_in_pl_flex_06;
                ELSIF p_short_name = 'EOIPFLX07' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_in_pl_flex_07;
                ELSIF p_short_name = 'EOIPFLX08' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_in_pl_flex_08;
                ELSIF p_short_name = 'EOIPFLX09' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_in_pl_flex_09;
                ELSIF p_short_name = 'EOIPFLX10' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_in_pl_flex_10;
                ELSIF p_short_name = 'EOIPSQNUM' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_elig_oip_seq_num, p_frmt_mask_cd);
                ELSIF p_short_name = 'EOPTFLX01' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_flex_01;
                ELSIF p_short_name = 'EOPTFLX02' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_flex_02;
                ELSIF p_short_name = 'EOPTFLX03' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_flex_03;
                ELSIF p_short_name = 'EOPTFLX04' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_flex_04;
                ELSIF p_short_name = 'EOPTFLX05' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_flex_05;
                ELSIF p_short_name = 'EOPTFLX06' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_flex_06;
                ELSIF p_short_name = 'EOPTFLX07' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_flex_07;
                ELSIF p_short_name = 'EOPTFLX08' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_flex_08;
                ELSIF p_short_name = 'EOPTFLX09' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_flex_09;
                ELSIF p_short_name = 'EOPTFLX10' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_opt_in_pl_flex_10;
                ELSIF p_short_name = 'EOPTNM' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                     ben_ext_person.g_elig_opt_name,
                     to_char(ben_ext_person.g_elig_opt_id));
                ELSIF p_short_name = 'EOPTSEQ' THEN
                   l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_opt_ord_no, p_frmt_mask_cd);
                -- 2732104
                ELSIF p_short_name = 'EOPTFDNM'   then
                  l_rslt_elmt := ben_ext_person.g_elig_opt_fd_name ;
                ELSIF p_short_name = 'EOPTFDCD'   then
                      l_rslt_elmt :=  ben_ext_person.g_elig_opt_fd_code;
                ELSIF p_short_name = 'EOTPFDNM' then
                      l_rslt_elmt :=  ben_ext_person.g_elig_pl_typ_fd_name	;
                ELSIF p_short_name = 'EOTPFDCD' then
                      l_rslt_elmt :=  ben_ext_person.g_elig_pl_typ_fd_code	;
                ELSIF p_short_name = 'EOOPFDNM' then
                      l_rslt_elmt :=   ben_ext_person.g_elig_opt_pl_fd_name;
                ELSIF p_short_name = 'EOOPFDCD' then
                      l_rslt_elmt :=   ben_ext_person.g_elig_opt_pl_fd_code	;
                ELSIF p_short_name = 'EOPPFDNM' then
                       l_rslt_elmt :=  ben_ext_person.g_elig_pl_pgm_fd_name	;
                ELSIF p_short_name = 'EOPPFDCD' then
                       l_rslt_elmt :=  ben_ext_person.g_elig_pl_pgm_fd_code	;
                ELSIF p_short_name = 'EOYPFDNM' then
                       l_rslt_elmt :=  ben_ext_person.g_elig_pl_typ_pgm_fd_name;
                ELSIF p_short_name = 'EOYPFDCD' then
                   l_rslt_elmt := ben_ext_person.g_elig_pl_typ_pgm_fd_code;
                END IF;

            elsif p_two_char_substr = 'EP' then
                IF p_short_name = 'EPCTFLTM' THEN
                   l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_pct_fl_tm, p_frmt_mask_cd);
                --
                -- Eligible Dependents
                --
                ELSIF p_short_name = 'EPGMFLX01' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pgm_flex_01;
                ELSIF p_short_name = 'EPGMFLX02' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pgm_flex_02;
                ELSIF p_short_name = 'EPGMFLX03' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pgm_flex_03;
                ELSIF p_short_name = 'EPGMFLX04' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pgm_flex_04;
                ELSIF p_short_name = 'EPGMFLX05' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pgm_flex_05;
                ELSIF p_short_name = 'EPGMFLX06' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pgm_flex_06;
                ELSIF p_short_name = 'EPGMFLX07' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pgm_flex_07;
                ELSIF p_short_name = 'EPGMFLX08' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pgm_flex_08;
                ELSIF p_short_name = 'EPGMFLX09' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pgm_flex_09;
                ELSIF p_short_name = 'EPGMFLX10' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pgm_flex_10;
                ELSIF p_short_name = 'EPIPFLX01' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pl_in_pgm_flex_01;
                ELSIF p_short_name = 'EPIPFLX02' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pl_in_pgm_flex_02;
                ELSIF p_short_name = 'EPIPFLX03' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pl_in_pgm_flex_03;
                ELSIF p_short_name = 'EPIPFLX04' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pl_in_pgm_flex_04;
                ELSIF p_short_name = 'EPIPFLX05' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pl_in_pgm_flex_05;
                ELSIF p_short_name = 'EPIPFLX06' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pl_in_pgm_flex_06;
                ELSIF p_short_name = 'EPIPFLX07' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pl_in_pgm_flex_07;
                ELSIF p_short_name = 'EPIPFLX08' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pl_in_pgm_flex_08;
                ELSIF p_short_name = 'EPIPFLX09' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pl_in_pgm_flex_09;
                ELSIF p_short_name = 'EPIPFLX10' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_pl_in_pgm_flex_10;
                ELSIF p_short_name = 'EPIPSQNUM' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_elig_pip_seq_num, p_frmt_mask_cd);
                ELSIF p_short_name = 'EPLFLX01' THEN
                   l_rslt_elmt := ben_ext_person.g_elig_plan_flex_01;
                ELSIF p_short_name = 'EPLFLX02' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_plan_flex_02;
                ELSIF p_short_name = 'EPLFLX03' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_plan_flex_03;
                ELSIF p_short_name = 'EPLFLX04' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_plan_flex_04;
                ELSIF p_short_name = 'EPLFLX05' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_plan_flex_05;
                ELSIF p_short_name = 'EPLFLX06' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_plan_flex_06;
                ELSIF p_short_name = 'EPLFLX07' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_plan_flex_07;
                ELSIF p_short_name = 'EPLFLX08' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_plan_flex_08;
                ELSIF p_short_name = 'EPLFLX09' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_plan_flex_09;
                ELSIF p_short_name = 'EPLFLX10' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_plan_flex_10;
                ELSIF p_short_name = 'EPLNM' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                    ben_ext_person.g_elig_pl_name,to_char(ben_ext_person.g_elig_pl_id));
                ELSIF p_short_name = 'EPLSEQ' THEN
                   l_rslt_elmt :=
                     apply_format_mask(ben_ext_person.g_elig_pl_ord_no, p_frmt_mask_cd);
                ELSIF p_short_name = 'EPLSQNUM' THEN
                  l_rslt_elmt :=
                    apply_format_mask(ben_ext_person.g_elig_pl_seq_num, p_frmt_mask_cd);
                ELSIF p_short_name = 'EPLTFLX01' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_ptp_flex_01;
                ELSIF p_short_name = 'EPLTFLX02' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_ptp_flex_02;
                ELSIF p_short_name = 'EPLTFLX03' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_ptp_flex_03;
                ELSIF p_short_name = 'EPLTFLX04' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_ptp_flex_04;
                ELSIF p_short_name = 'EPLTFLX05' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_ptp_flex_05;
                ELSIF p_short_name = 'EPLTFLX06' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_ptp_flex_06;
                ELSIF p_short_name = 'EPLTFLX07' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_ptp_flex_07;
                ELSIF p_short_name = 'EPLTFLX08' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_ptp_flex_08;
                ELSIF p_short_name = 'EPLTFLX09' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_ptp_flex_09;
                ELSIF p_short_name = 'EPLTFLX10' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_ptp_flex_10;
                ELSIF p_short_name = 'EPLTYPNM' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                     ben_ext_person.g_elig_pl_typ_name,to_char(ben_ext_person.g_elig_pl_typ_id));
                  l_rslt_elmt := ben_ext_person.g_elig_pl_typ_name;
                ELSIF p_short_name = 'EPLYRENDT' THEN
                  l_rslt_elmt :=
                    apply_format_mask(ben_ext_person.g_elig_pl_yr_enddt, p_frmt_mask_cd);
                ELSIF p_short_name = 'EPLYRSTDT' THEN
                  l_rslt_elmt :=
                    apply_format_mask(ben_ext_person.g_elig_pl_yr_strdt, p_frmt_mask_cd);
                ELSIF p_short_name = 'EPRGNM' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                     ben_ext_person.g_elig_program_name ,to_char(ben_ext_person.g_elig_program_id));
                ELSIF p_short_name = 'EPTPSQNUM' THEN
                  l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_ptp_seq_num, p_frmt_mask_cd);
                    ----2559743
                ELSIF p_short_name = 'EPLFDNM' then
                           l_rslt_elmt :=    ben_ext_person.g_elig_pl_fd_name ;
                ELSIF p_short_name = 'EPLFDCD'   then
                           l_rslt_elmt :=    ben_ext_person.g_elig_pl_fd_code ;
                ELSIF p_short_name = 'EPRFDNM'   then
                       l_rslt_elmt :=    ben_ext_person.g_elig_pgm_fd_name;
                ELSIF p_short_name = 'EPRFDCD'   then
                       l_rslt_elmt :=   ben_ext_person.g_elig_pgm_fd_code ;
                    ----
                END IF;

            elsif p_two_char_substr in ('ER','ET','EU') then
                IF p_short_name = 'EREETOTDS' THEN
                   l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_ee_ttl_distribution, p_frmt_mask_cd);
                ELSIF p_short_name = 'ERERTOTDS' THEN
                   l_rslt_elmt :=
                    apply_format_mask(ben_ext_person.g_elig_er_ttl_distribution, p_frmt_mask_cd);
                ELSIF p_short_name = 'ERPGRPNM' THEN
                  l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                      ben_ext_person.g_elig_rpt_group_name,to_char(ben_ext_person.g_elig_rpt_group_id));
                ELSIF p_short_name = 'ERTOTORT' THEN
                   l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_elig_ttl_other_rate, p_frmt_mask_cd);
                --- CWB  2832419
                --Eligible Rate - CWB Distribution Budget
                ELSIF p_short_name = 'ERCWBDSBD' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_dst_bdgt , p_frmt_mask_cd);
                --Eligible Rate - CWB Misc Rate 1
                ELSIF p_short_name = 'ERCWBMSR1' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_misc_rate_1 , p_frmt_mask_cd);
                --ligible Rate - CWB Eligible Salary
                ELSIF p_short_name = 'ERCWBELSL' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_elig_salary , p_frmt_mask_cd);
                --Eligible Rate - CWB Misc Rate 2
                ELSIF p_short_name = 'ERCWBMSR2' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_misc_rate_2 , p_frmt_mask_cd);
                --Eligible Rate - CWB Grant Price
                ELSIF p_short_name = 'ERCWBGRPR' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_grant_price , p_frmt_mask_cd);
                --Eligible Rate - CWB Other Salary
                ELSIF p_short_name = 'ERCWBOTSL' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_other_salary , p_frmt_mask_cd);
                --Eligible Rate - CWB Reserve
                ELSIF p_short_name = 'ERCWBRSRV' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_reserve , p_frmt_mask_cd);
                --Eligible Rate - CWB Recommended Amount
                ELSIF p_short_name = 'ERCWBRCAM' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_recomond_amt  , p_frmt_mask_cd);
                --Eligible Rate - CWB Stated Salary
                ELSIF p_short_name = 'ERCWBSTSL' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_stated_salary , p_frmt_mask_cd);
                --Eligible Rate - CWB Total Compensation
                ELSIF p_short_name = 'ERCWBTTCM' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_tot_compensation  , p_frmt_mask_cd);
                --Eligible Rate - CWB Worksheet Budget
                ELSIF p_short_name = 'ERCWBWSBD' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_worksheet_bdgt , p_frmt_mask_cd);
                --Eligible Rate - CWB Worksheet Amount
                ELSIF p_short_name = 'ERCWBWSAM' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_elig_salary , p_frmt_mask_cd);
                --Eligible Rate - CWB Misc Rate 3
                ELSIF p_short_name = 'ERCWBMSR3' THEN
                      l_rslt_elmt :=
                      apply_format_mask(ben_ext_person.g_elig_ee_cwb_misc_rate_3  , p_frmt_mask_cd);
                ELSIF p_short_name = 'ETOTPRAMT' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_elig_total_premium_amt, p_frmt_mask_cd);
                ELSIF p_short_name = 'ETOTPRUOM' THEN
                  l_rslt_elmt := ben_ext_person.g_elig_total_premium_uom;
                ELSIF p_short_name = 'EUOM' tHEN
                   l_rslt_elmt := ben_ext_person.g_elig_uom;
                END IF;
            end if;
            --
            -- Payroll
            --
      elsif p_one_char_substr = 'F' then
            IF p_short_name = 'FILLER' THEN
              l_rslt_elmt := null;
            ELSIF p_short_name = 'FSTNM' THEN
              l_rslt_elmt := ben_ext_person.g_first_name;
            ELSIF p_short_name = 'FULNM' THEN
              l_rslt_elmt := ben_ext_person.g_full_name;
            end if;
      elsif p_one_char_substr = 'L' then
            IF p_short_name = 'LERFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_ler_attr_1;
            ELSIF p_short_name = 'LERFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_ler_attr_2;
            ELSIF p_short_name = 'LERFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_ler_attr_3;
            ELSIF p_short_name = 'LERFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_ler_attr_4;
            ELSIF p_short_name = 'LERFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_ler_attr_5;
            ELSIF p_short_name = 'LERFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_ler_attr_6;
            ELSIF p_short_name = 'LERFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_ler_attr_7;
            ELSIF p_short_name = 'LERFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_ler_attr_8;
            ELSIF p_short_name = 'LERFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_ler_attr_9;
            ELSIF p_short_name = 'LERFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_ler_attr_10;
            ELSIF p_short_name = 'LSTNM' THEN
              l_rslt_elmt := ben_ext_person.g_last_name;
            end if;
     elsif p_one_char_substr = 'M' then
            IF p_short_name = 'MIDNM' THEN
              l_rslt_elmt := ben_ext_person.g_middle_names;
            ELSIF p_short_name = 'MLAD1' THEN
              l_rslt_elmt := ben_ext_person.g_mail_address_line_1;
            ELSIF p_short_name = 'MLAD2' THEN
              l_rslt_elmt := ben_ext_person.g_mail_address_line_2;
            ELSIF p_short_name = 'MLAD3' THEN
              l_rslt_elmt := ben_ext_person.g_mail_address_line_3;
            ELSIF p_short_name = 'MLADRDT' THEN
              l_rslt_elmt :=
              apply_format_mask(ben_ext_person.g_mail_address_date, p_frmt_mask_cd);
            --
            ELSIF p_short_name = 'MLCNTY' THEN -- Fix for Bug 2593220
              l_rslt_elmt := nvl(hr_general.DECODE_FND_COMM_LOOKUP(l_lookup_type,
                                 ben_ext_person.g_mail_county),
                                 ben_ext_person.g_mail_county);
              --l_rslt_elmt := ben_ext_person.g_mail_county;   -- End of fix, Bug 2593220
            ELSIF p_short_name = 'MLCRY' THEN
              l_rslt_elmt := ben_ext_person.g_mail_country;
            ELSIF p_short_name = 'MLCTY' THEN
              l_rslt_elmt := ben_ext_person.g_mail_city;
            ELSIF p_short_name = 'MLREG3' THEN
              l_rslt_elmt := ben_ext_person.g_mail_region_3;
            ELSIF p_short_name = 'MLSTA' THEN
              l_rslt_elmt := ben_ext_person.g_mail_state;
            ELSIF p_short_name = 'MLZIP' THEN
              l_rslt_elmt := ben_ext_person.g_mail_postal_code;
            ELSIF p_short_name = 'MRTL' THEN
              l_rslt_elmt := ben_ext_person.g_marital_status;
            end if;
      elsif p_one_char_substr = 'N' then
            IF p_short_name = 'NATID' THEN
              l_rslt_elmt :=
              apply_format_mask(ben_ext_person.g_national_identifier, p_frmt_mask_cd);
            ELSIF p_short_name = 'NMSFX' THEN
              l_rslt_elmt := ben_ext_person.g_suffix;
            ELSIF p_short_name = 'NMPREFIX' THEN
              l_rslt_elmt := ben_ext_person.g_prefix;
            end if;

     elsif p_one_char_substr = 'O' then

            IF p_short_name = 'OIPLFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_oipl_attr_1;
            ELSIF p_short_name = 'OIPLFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_oipl_attr_2;
            ELSIF p_short_name = 'OIPLFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_oipl_attr_3;
            ELSIF p_short_name = 'OIPLFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_oipl_attr_4;
            ELSIF p_short_name = 'OIPLFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_oipl_attr_5;
            ELSIF p_short_name = 'OIPLFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_oipl_attr_6;
            ELSIF p_short_name = 'OIPLFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_oipl_attr_7;
            ELSIF p_short_name = 'OIPLFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_oipl_attr_8;
            ELSIF p_short_name = 'OIPLFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_oipl_attr_9;
            ELSIF p_short_name = 'OIPLFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_oipl_attr_10;
            ELSIF p_short_name = 'OTL_TC_START_DATE' THEN
              l_rslt_elmt := apply_format_mask
               (hxc_ext_timecard.OTL_TC_START_DATE, p_frmt_mask_cd);
            ELSIF p_short_name = 'OTL_TC_END_DATE' THEN
              l_rslt_elmt := apply_format_mask
               (hxc_ext_timecard.OTL_TC_END_DATE, p_frmt_mask_cd);
            ELSIF p_short_name = 'OTL_TC_STATUS' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_TC_STATUS;
            ELSIF p_short_name = 'OTL_TC_COMMENTS' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_TC_COMMENTS;
            ELSIF p_short_name = 'OTL_TC_DELTED' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_TC_DELTED;
            ELSIF p_short_name = 'OTL_DAY' THEN
              l_rslt_elmt := apply_format_mask
               (hxc_ext_timecard.OTL_DAY, p_frmt_mask_cd);
            ELSIF p_short_name = 'OTL_DAY_COMMENTS' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_DAY_COMMENTS;
            ELSIF p_short_name = 'OTL_MEASURE' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_MEASURE;
            ELSIF p_short_name = 'OTL_DAY_START' THEN
              l_rslt_elmt := apply_format_mask
               (hxc_ext_timecard.OTL_DAY_START, p_frmt_mask_cd);
            ELSIF p_short_name = 'OTL_DAY_STOP' THEN
              l_rslt_elmt := apply_format_mask
               (hxc_ext_timecard.OTL_DAY_STOP, p_frmt_mask_cd);
            ELSIF p_short_name = 'OTL_PA_SYS_LINK_FUNCN' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_PA_SYS_LINK_FUNCN;
            ELSIF p_short_name = 'OTL_PA_BILLABLE_FLAG' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_PA_BILLABLE_FLAG;
            ELSIF p_short_name = 'OTL_PA_TASK' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_PA_TASK;
            ELSIF p_short_name = 'OTL_PA_PROJECT' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_PA_PROJECT;
            ELSIF p_short_name = 'OTL_PA_EXPENDITURE_TYPE' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_PA_EXPENDITURE_TYPE;
            ELSIF p_short_name = 'OTL_PA_EXPENDITURE_COMMENT' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_PA_EXPENDITURE_COMMENT;
            ELSIF p_short_name = 'OTL_PAY_ELEMENT_NAME' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_PAY_ELEMENT_NAME;
            ELSIF p_short_name = 'OTL_PAY_COST_CENTRE' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_PAY_COST_CENTRE;
            ELSIF p_short_name = 'OTL_PO_NUMBER' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_PO_NUMBER;
            ELSIF p_short_name = 'OTL_PO_LINE_ID' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_PO_LINE_ID;
            ELSIF p_short_name = 'OTL_PO_PRICE_TYPE' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_PO_PRICE_TYPE;
            ELSIF p_short_name = 'OTL_ALIAS_ELEMENTS_EXP_SLF' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_ALIAS_ELEMENTS_EXP_SLF;
            ELSIF p_short_name = 'OTL_ALIAS_EXPENDITURE_ELEMENTS' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_ALIAS_EXPENDITURE_ELEMENTS;
            ELSIF p_short_name = 'OTL_ALIAS_EXPENDITURE_TYPES' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_ALIAS_EXPENDITURE_TYPES;
            ELSIF p_short_name = 'OTL_ALIAS_LOCATIONS' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_ALIAS_LOCATIONS;
            ELSIF p_short_name = 'OTL_ALIAS_PAYROLL_ELEMENTS' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_ALIAS_PAYROLL_ELEMENTS;
            ELSIF p_short_name = 'OTL_ALIAS_PROJECTS' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_ALIAS_PROJECTS;
            ELSIF p_short_name = 'OTL_ALIAS_TASKS' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_ALIAS_TASKS;
            ELSIF p_short_name = 'OTL_ALIAS_RATE_TYPE_EXP_SLF' THEN
              l_rslt_elmt := hxc_ext_timecard.OTL_ALIAS_RATE_TYPE_EXP_SLF;
            END IF;

      elsif p_one_char_substr = 'P' then
         if p_two_char_substr = 'PA' then
            IF p_short_name = 'PABCRTBY' THEN
              l_rslt_elmt :=                              -- Fix for Bug 3870480
			         decode_setup(p_data_elmt_typ_cd,
				                  get_name(ben_ext_person.g_abs_created_by),
							      ben_ext_person.g_abs_created_by);
            ELSIF p_short_name = 'PABCRTDT' THEN
              l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_abs_creation_date, p_frmt_mask_cd);
            --
            -- Flex Credit
            --
            ELSIF p_short_name = 'PABLSTUPBY' THEN       -- Fix for Bug 3870480
              l_rslt_elmt :=
                     decode_setup(p_data_elmt_typ_cd,
				                  get_name(ben_ext_person.g_abs_last_updated_by),
								  ben_ext_person.g_abs_last_updated_by);
            ELSIF p_short_name = 'PABLSTUPDT' THEN
              l_rslt_elmt :=
                 apply_format_mask(ben_ext_person.g_abs_last_update_date, p_frmt_mask_cd);
            ELSIF p_short_name = 'PABLSTUPLG' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_abs_last_update_login, p_frmt_mask_cd);

            ELSIF p_short_name = 'PABSCAT' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                    ben_ext_person.g_abs_category_name,ben_ext_person.g_abs_category);
                    ---bug1374208 l_rslt_elmt:=apply_format_mask(ben_ext_person.g_abs_category,p_frmt_mask_cd);
            ELSIF p_short_name = 'PABSDRN' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_abs_duration,p_frmt_mask_cd);
            ELSIF p_short_name = 'PABSENDT' THEN
              l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_abs_end_dt,p_frmt_mask_cd);
            ELSIF p_short_name = 'PABSFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_abs_flex_01;
            ELSIF p_short_name = 'PABSFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_abs_flex_02;
            ELSIF p_short_name = 'PABSFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_abs_flex_03;
            ELSIF p_short_name = 'PABSFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_abs_flex_04;
            ELSIF p_short_name = 'PABSFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_abs_flex_05;
            ELSIF p_short_name = 'PABSFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_abs_flex_06;
            ELSIF p_short_name = 'PABSFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_abs_flex_07;
            ELSIF p_short_name = 'PABSFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_abs_flex_08;
            ELSIF p_short_name = 'PABSFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_abs_flex_09;
            ELSIF p_short_name = 'PABSFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_abs_flex_10;
            ELSIF p_short_name = 'PABSRSN' THEN

                --
                -- bug 2841958, If the element type code is 'D' the reason code should
                -- be sent to decode_setup and not abs_reason_id, as abs_reason_id would
                -- result in the default value to be extracted for all people
                --
                -- l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                --  ben_ext_person.g_abs_reason_name,to_char(ben_ext_person.g_abs_reason));

                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                ben_ext_person.g_abs_reason_name,ben_ext_person.g_abs_reason_cd);

                -- end of bug 2841958

                --bug 1374208 l_rslt_elmt := apply_format_mask(ben_ext_person.g_abs_reason,p_frmt_mask_cd);
            ELSIF p_short_name = 'PABSSTDT' THEN
              l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_abs_start_dt,p_frmt_mask_cd);
            ELSIF p_short_name = 'PABSTYP' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_abs_type_name,to_char(ben_ext_person.g_abs_type));
                  --  1374208l  l_rslt_elmt := apply_format_mask(ben_ext_person.g_abs_type,p_frmt_mask_cd);
            ELSIF p_short_name = 'PACRTBY' THEN
              l_rslt_elmt :=                             -- Fix for Bug 3870480
                         decode_setup(p_data_elmt_typ_cd,
					                  get_name(ben_ext_person.g_asg_created_by),
									  ben_ext_person.g_asg_created_by);
            ELSIF p_short_name = 'PACRTDT' THEN
              l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_asg_creation_date, p_frmt_mask_cd);
            --
            ELSIF p_short_name = 'PADOT' THEN
              l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_actual_term_date, p_frmt_mask_cd);
            ELSIF p_short_name = 'PALCFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_alc_flex_01;
            ELSIF p_short_name = 'PALCFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_alc_flex_02;
            ELSIF p_short_name = 'PALCFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_alc_flex_03;
            ELSIF p_short_name = 'PALCFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_alc_flex_04;
            ELSIF p_short_name = 'PALCFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_alc_flex_05;
            ELSIF p_short_name = 'PALCFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_alc_flex_06;
            ELSIF p_short_name = 'PALCFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_alc_flex_07;
            ELSIF p_short_name = 'PALCFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_alc_flex_08;
            ELSIF p_short_name = 'PALCFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_alc_flex_09;
            ELSIF p_short_name = 'PALCFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_alc_flex_10;
            ELSIF p_short_name = 'PALSTUPBY' THEN
              l_rslt_elmt :=                       -- Fix for Bug 3870480
                     decode_setup(p_data_elmt_typ_cd,
				                  get_name(ben_ext_person.g_asg_last_updated_by),
								  ben_ext_person.g_asg_last_updated_by);
            ELSIF p_short_name = 'PALSTUPDT' THEN
              l_rslt_elmt :=
                apply_format_mask(ben_ext_person.g_asg_last_update_date, p_frmt_mask_cd);
            ELSIF p_short_name = 'PALSTUPLG' THEN
                 l_rslt_elmt :=
                apply_format_mask(ben_ext_person.g_asg_last_update_login, p_frmt_mask_cd);

            ELSIF p_short_name = 'PARTFNM' THEN
              l_rslt_elmt :=
                apply_format_mask(ben_ext_person.g_part_first_name, p_frmt_mask_cd);
            ELSIF p_short_name = 'PARTLNM' THEN
              l_rslt_elmt :=
                apply_format_mask(ben_ext_person.g_part_last_name, p_frmt_mask_cd);
                --
                -- ASG
            ELSIF p_short_name = 'PARTSSN' THEN
              l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_part_ssn,p_frmt_mask_cd);
            ELSIF p_short_name = 'PASVCD' THEN
              l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_adjusted_svc_date, p_frmt_mask_cd);
            END IF;
         elsif p_two_char_substr = 'PB' then
            IF p_short_name = 'PBNBDC' THEN
              l_rslt_elmt :=
                 apply_format_mask(ben_ext_person.g_benefit_bal_dfncntrbn, p_frmt_mask_cd);
            ELSIF p_short_name = 'PBNBPS' THEN
              l_rslt_elmt :=
                 apply_format_mask(ben_ext_person.g_benefit_bal_pension, p_frmt_mask_cd);
            ELSIF p_short_name = 'PBNBSL' THEN
              l_rslt_elmt :=
                 apply_format_mask(ben_ext_person.g_benefit_bal_sickleave, p_frmt_mask_cd);
            ELSIF p_short_name = 'PBNBVC' THEN
              l_rslt_elmt :=
                 apply_format_mask(ben_ext_person.g_benefit_bal_vacation, p_frmt_mask_cd);
            ELSIF p_short_name = 'PBNBWN' THEN
              l_rslt_elmt :=
                 apply_format_mask(ben_ext_person.g_benefit_bal_wellness, p_frmt_mask_cd);
            ELSIF p_short_name = 'PBNGFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_bng_flex_01;
            ELSIF p_short_name = 'PBNGFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_bng_flex_02;
            ELSIF p_short_name = 'PBNGFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_bng_flex_03;
            ELSIF p_short_name = 'PBNGFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_bng_flex_04;
            ELSIF p_short_name = 'PBNGFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_bng_flex_05;
            ELSIF p_short_name = 'PBNGFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_bng_flex_06;
            ELSIF p_short_name = 'PBNGFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_bng_flex_07;
            ELSIF p_short_name = 'PBNGFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_bng_flex_08;
            ELSIF p_short_name = 'PBNGFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_bng_flex_09;
            ELSIF p_short_name = 'PBNGFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_bng_flex_10;
            ELSIF p_short_name = 'PBNORDNM' THEN
              l_rslt_elmt :=
                apply_format_mask(ben_ext_person.g_enrt_benefit_order_num, p_frmt_mask_cd);
            ELSIF p_short_name = 'PBNSTCD' THEN
              l_rslt_elmt := ben_ext_person.g_bnft_stat_cd;
            ELSIF p_short_name = 'PBASSAL' then
               l_rslt_elmt := apply_format_mask(ben_ext_person.g_base_salary, p_frmt_mask_cd);
            ELSIF p_short_name = 'PBSGRP' THEN
                l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                   ben_extract.g_proc_business_group_name,
                   to_char( ben_extract.g_proc_business_group_id));
                --

            end if;
         elsif p_two_char_substr = 'PC' then
            IF p_short_name = 'PCBRAENDT' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_cbra_end_dt,p_frmt_mask_cd);
     	      --  Communication
	      --
            ELSIF p_short_name = 'PCBRAENM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_cbra_ler_name,
                 to_char(ben_ext_person.g_cbra_ler_id));
            ELSIF p_short_name = 'PCBRASTDT' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_cbra_strt_dt,
p_frmt_mask_cd);
            ELSIF p_short_name = 'PCO' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_payroll_costing,
                 to_char(ben_ext_person.g_payroll_costing_id));
            ELSIF p_short_name = 'PCRTBY' THEN
              l_rslt_elmt :=                      -- Fix for Bug 3870480
			         decode_setup(p_data_elmt_typ_cd,
    		   	                  get_name(ben_ext_person.g_created_by),
								  ben_ext_person.g_created_by);
            ELSIF p_short_name = 'PCRTDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_creation_date, p_frmt_mask_cd);
            --
            ELSIF p_short_name = 'PCS' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_payroll_consolidation_set,
                 to_char(ben_ext_person.g_payroll_consolidation_set_id));
            ELSIF p_short_name = 'PCVGAMT' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_enrt_cvg_amt,
p_frmt_mask_cd);
            --
            end if;
            elsif p_two_char_substr = 'PE' then
            IF p_short_name = 'PEC' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_uom;
            ELSIF p_short_name = 'PEEAFTRTX' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_ee_after_tax_cost, p_frmt_mask_cd);
            ELSIF p_short_name = 'PEEPRETX' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_ee_pre_tax_cost, p_frmt_mask_cd);
            ELSIF p_short_name = 'PEETTL' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_ee_ttl_cost,
p_frmt_mask_cd);
            ELSIF p_short_name = 'PEICVG' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_int_cvg_amt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PEIOPTNM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_enrt_int_opt_name,
                 to_char(ben_ext_person.g_enrt_int_opt_id));
            ELSIF p_short_name = 'PEIPLNM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_enrt_int_pl_name,
                 to_char(ben_ext_person.g_enrt_int_pl_id));
            ELSIF p_short_name = 'PELCMDDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_elec_made_dt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PENRMTHD' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_method;
            ELSIF p_short_name = 'PENROVFG' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_ovrd_flag;
            ELSIF p_short_name = 'PENROVRSN' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_ovrd_reason;
            ELSIF p_short_name = 'PENROVTDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_ovrd_thru_dt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PENRRSDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_rslt_effct_strdt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PENRSPDFG' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_suspended_flag;
            ELSIF p_short_name = 'PERADJ' THEN
              l_rslt_elmt := ben_ext_person.g_pre_name_adjunct;
            ELSIF p_short_name = 'PEREML' THEN
              l_rslt_elmt := substr(ben_ext_person.g_email_address,1,600) ;
            ELSIF p_short_name = 'PERFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_per_attr_1;
            ELSIF p_short_name = 'PERFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_per_attr_2;
            ELSIF p_short_name = 'PERFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_per_attr_3;
            ELSIF p_short_name = 'PERFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_per_attr_4;
            ELSIF p_short_name = 'PERFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_per_attr_5;
            ELSIF p_short_name = 'PERFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_per_attr_6;
            ELSIF p_short_name = 'PERFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_per_attr_7;
            ELSIF p_short_name = 'PERFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_per_attr_8;
            ELSIF p_short_name = 'PERFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_per_attr_9;
            ELSIF p_short_name = 'PERFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_per_attr_10;
            ELSIF p_short_name = 'PERKNWN' THEN
              l_rslt_elmt := ben_ext_person.g_known_as;
            ELSIF p_short_name = 'PERLNG' THEN
              l_rslt_elmt := ben_ext_person.g_correspondence_language;
            ELSIF p_short_name = 'PERMSTP' THEN
              l_rslt_elmt := ben_ext_person.g_mailstop;
            ELSIF p_short_name = 'PERNTL' THEN
              l_rslt_elmt := ben_ext_person.g_nationality;
            ELSIF p_short_name = 'PEROHD' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_original_date_of_hire, p_frmt_mask_cd);
            ELSIF p_short_name = 'PERPDOB' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_previous_dob,
p_frmt_mask_cd);
            --
            ELSIF p_short_name = 'PERPSEX' THEN
                  l_rslt_elmt := ben_ext_person.g_previous_sex;
            -- extract dates and bus group
            --
            ELSIF p_short_name = 'PERPFST' THEN
              l_rslt_elmt := ben_ext_person.g_previous_first_name;
            ELSIF p_short_name = 'PERPLN' THEN
              l_rslt_elmt := ben_ext_person.g_previous_last_name;
            ELSIF p_short_name = 'PERPMID' THEN
              l_rslt_elmt := ben_ext_person.g_previous_middle_name;
            ELSIF p_short_name = 'PERPSSN' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_previous_ssn,
p_frmt_mask_cd);
            ELSIF p_short_name = 'PERPSUF' THEN
              l_rslt_elmt := ben_ext_person.g_previous_suffix;
            ELSIF p_short_name = 'PERPPRE' THEN
              l_rslt_elmt := ben_ext_person.g_previous_prefix;
            ELSIF p_short_name = 'PERTBC' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_uses_tobacco_flag, p_frmt_mask_cd);
            --
            ELSIF p_short_name = 'PERTTL' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_er_ttl_cost,
p_frmt_mask_cd);
            ELSIF p_short_name = 'PEROPMED' THEN
               l_rslt_elmt := ben_ext_person.g_per_information10 ;
            ELSIF p_short_name = 'PERETHORG' THEN
               l_rslt_elmt :=  ben_ext_person.g_per_information1 ;
            ELSIF p_short_name = 'PEVEEATC' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_pev_ee_after_tax_contr, p_frmt_mask_cd);
            ELSIF p_short_name = 'PEVEEPTC' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_pev_ee_pre_tax_contr, p_frmt_mask_cd);
            ELSIF p_short_name = 'PEVEETOTC' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_pev_ee_ttl_contr, p_frmt_mask_cd);
            ELSIF p_short_name = 'PEVEETOTD' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_pev_ee_ttl_distribution, p_frmt_mask_cd);
            ELSIF p_short_name = 'PEVERTOTC' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_pev_er_ttl_contr, p_frmt_mask_cd);
            ELSIF p_short_name = 'PEVERTOTD' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_pev_er_ttl_distribution, p_frmt_mask_cd);
            ELSIF p_short_name = 'PEVTOTOR' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_pev_ttl_other_rate, p_frmt_mask_cd);
            --
            -- Absence
            --
            ELSIF p_short_name = 'PERTYPE' THEN
               --
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                ben_ext_person.g_person_types ,
                to_char(ben_ext_person.g_person_type_id ));
            --
            ELSIF p_short_name = 'PERSHLNM' THEN

              l_rslt_elmt :=  ben_ext_person.g_ESTABLISHMENT_name ;
            --   cwb changes
            --Enrollment Rate - CWB Distribution Budget
            ELSIF p_short_name = 'PECWBDSBD' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_er_cwb_dst_bdgt     , p_frmt_mask_cd);
            --Enrollment Rate - CWB Misc Rate 1
            ELSIF p_short_name = 'PECWBMSR1' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_er_cwb_misc_rate_1, p_frmt_mask_cd);
            --Enrollment Rate - CWB Eligible Salary
            ELSIF p_short_name = 'PECWBELSL' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_er_cwb_elig_salary, p_frmt_mask_cd);
            --nrollment Rate - CWB Misc Rate 2
            ELSIF p_short_name = 'PECWBMSR2' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_er_cwb_misc_rate_2, p_frmt_mask_cd);
            --Enrollment Rate - CWB Grant Price
            ELSIF p_short_name = 'PECWBGRPR' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_er_cwb_grant_price   , p_frmt_mask_cd);
            --Enrollment Rate - CWB Other Salary
            ELSIF p_short_name = 'PECWBOTSL' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_er_cwb_other_salary , p_frmt_mask_cd);
            --Enrollment Rate - CWB Reserve
            ELSIF p_short_name = 'PECWBRSRV' THEN
                   l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_er_cwb_reserve , p_frmt_mask_cd);
            --Enrollment Rate - CWB Recommended Amount
            ELSIF p_short_name = 'PECWBRCAM' THEN
                  l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_er_cwb_recomond_amt  , p_frmt_mask_cd);
            --Enrollment Rate - CWB Stated Salary
            ELSIF p_short_name = 'PECWBSTSL' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_er_cwb_stated_salary , p_frmt_mask_cd);
            --Enrollment Rate - CWB Total Compensation
            ELSIF p_short_name = 'PECWBTTCM' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_er_cwb_tot_compensation , p_frmt_mask_cd);
            --Enrollment Rate - CWB Worksheet Budget
            ELSIF p_short_name = 'PECWBWSBD' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_er_cwb_worksheet_bdgt , p_frmt_mask_cd);
            --Enrollment Rate - CWB Worksheet Amount
            ELSIF p_short_name = 'PECWBWSAM' THEN
                  hr_utility.set_location(' Worksheet Amount ' || ben_ext_person.g_er_cwb_worksheet_amt,991);
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_er_cwb_worksheet_amt , p_frmt_mask_cd);
            --Enrollment Rate - CWB Misc Rate 3
            ELSIF p_short_name = 'PECWBMSR3' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_er_cwb_misc_rate_3 , p_frmt_mask_cd);
            --Enrollment Rate - Reimbursement
            ELSIF p_short_name = 'PEREIMBRS' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_pev_er_reimbursement , p_frmt_mask_cd);
            --Enrollment Rate - Forfeited
            ELSIF p_short_name = 'PEFORFEIT' THEN
                  l_rslt_elmt :=
                  apply_format_mask(ben_ext_person.g_pev_er_forfeited , p_frmt_mask_cd);


            end if;

            elsif p_two_char_substr = 'PF' then
            IF p_short_name = 'PFLXAMT' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_flex_amt,
p_frmt_mask_cd);
            ELSIF p_short_name = 'PFLXCMBOPT' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_flex_cmbn_ptip_opt_name,
                 to_char(ben_ext_person.g_flex_cmbn_ptip_opt_id));
            ELSIF p_short_name = 'PFLXCMBPLN' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_flex_cmbn_plip_name,
                 to_char(ben_ext_person.g_flex_cmbn_plip_id));
            ELSIF p_short_name = 'PFLXCMBPLT' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_flex_cmbn_ptip_name,
                 to_char(ben_ext_person.g_flex_cmbn_ptip_id));
            ELSIF p_short_name = 'PFLXCREXC' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_flex_credit_excess, p_frmt_mask_cd);
            ELSIF p_short_name = 'PFLXCRFRT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_flex_credit_forfited, p_frmt_mask_cd);
            ELSIF p_short_name = 'PFLXCRPRV' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_flex_credit_provided, p_frmt_mask_cd);
            ELSIF p_short_name = 'PFLXCRUSD' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_flex_credit_used, p_frmt_mask_cd);
            ELSIF p_short_name = 'PFLXCUR' THEN
              l_rslt_elmt := ben_ext_person.g_flex_currency;
            ELSIF p_short_name = 'PFLXOPT' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_flex_opt_name,
                 to_char(ben_ext_person.g_flex_opt_id));
            ELSIF p_short_name = 'PFLXPGM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_flex_pgm_name,
                 to_char(ben_ext_person.g_flex_pgm_id));
            ELSIF p_short_name = 'PFLXPLN' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_flex_pl_name,
                 to_char(ben_ext_person.g_flex_pl_id));
            ELSIF p_short_name = 'PFLXPLTYP' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_flex_pl_typ_name,
                 to_char(ben_ext_person.g_flex_pl_typ_id));
            ELSIF p_short_name = 'PFLXPOOL' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_flex_bnft_pool_name,
                 to_char(ben_ext_person.g_flex_bnft_pool_id));
            --
            -- Covered Dependents
            --
            end if;
            elsif p_two_char_substr = 'PG' then
            IF p_short_name = 'PGMFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_pgm_attr_1;
            ELSIF p_short_name = 'PGMFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_pgm_attr_2;
            ELSIF p_short_name = 'PGMFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_pgm_attr_3;
            ELSIF p_short_name = 'PGMFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_pgm_attr_4;
            ELSIF p_short_name = 'PGMFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_pgm_attr_5;
            ELSIF p_short_name = 'PGMFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_pgm_attr_6;
            ELSIF p_short_name = 'PGMFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_pgm_attr_7;
            ELSIF p_short_name = 'PGMFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_pgm_attr_8;
            ELSIF p_short_name = 'PGMFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_pgm_attr_9;
            ELSIF p_short_name = 'PGMFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_pgm_attr_10;
            ELSIF p_short_name = 'PGRDFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_grd_flex_01;
            ELSIF p_short_name = 'PGRDFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_grd_flex_02;
            ELSIF p_short_name = 'PGRDFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_grd_flex_03;
            ELSIF p_short_name = 'PGRDFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_grd_flex_04;
            ELSIF p_short_name = 'PGRDFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_grd_flex_05;
            ELSIF p_short_name = 'PGRDFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_grd_flex_06;
            ELSIF p_short_name = 'PGRDFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_grd_flex_07;
            ELSIF p_short_name = 'PGRDFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_grd_flex_08;
            ELSIF p_short_name = 'PGRDFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_grd_flex_09;
            ELSIF p_short_name = 'PGRDFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_grd_flex_10;
            end if;
            elsif p_two_char_substr = 'PI' then
            IF p_short_name = 'PINCOVFG' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_intrcovg_flag;
            end if;
            elsif p_two_char_substr = 'PJ' then
            IF p_short_name = 'PJOBFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_job_flex_01;
            ELSIF p_short_name = 'PJOBFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_job_flex_02;
            ELSIF p_short_name = 'PJOBFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_job_flex_03;
            ELSIF p_short_name = 'PJOBFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_job_flex_04;
            ELSIF p_short_name = 'PJOBFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_job_flex_05;
            ELSIF p_short_name = 'PJOBFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_job_flex_06;
            ELSIF p_short_name = 'PJOBFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_job_flex_07;
            ELSIF p_short_name = 'PJOBFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_job_flex_08;
            ELSIF p_short_name = 'PJOBFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_job_flex_09;
            ELSIF p_short_name = 'PJOBFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_job_flex_10;
            end if;
            elsif p_two_char_substr = 'PL' then
            IF p_short_name = 'PLDOH' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_last_hire_date, p_frmt_mask_cd);
            ELSIF p_short_name = 'PLENM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_enrt_lfevt_name,
                 to_char(ben_ext_person.g_enrt_ler_id));
            ELSIF p_short_name = 'PLENTDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_lfevt_note_dt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PLEOCRDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_lfevt_ocrd_dt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PLERDT' THEN
               l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_lf_evt_ocrd_dt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PLERNM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_ler_name,
                 to_char(ben_ext_person.g_ler_id));
            ELSIF p_short_name = 'PLESTS' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_lfevt_status;
            ELSIF p_short_name = 'PLFEVNTDT' THEN
               l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_lf_evt_note_dt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PLFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_pl_attr_1;
            ELSIF p_short_name = 'PLFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_pl_attr_2;
            ELSIF p_short_name = 'PLFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_pl_attr_3;
            ELSIF p_short_name = 'PLFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_pl_attr_4;
            ELSIF p_short_name = 'PLFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_pl_attr_5;
            ELSIF p_short_name = 'PLFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_pl_attr_6;
            ELSIF p_short_name = 'PLFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_pl_attr_7;
            ELSIF p_short_name = 'PLFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_pl_attr_8;
            ELSIF p_short_name = 'PLFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_pl_attr_9;
            ELSIF p_short_name = 'PLFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_pl_attr_10;
            ELSIF p_short_name = 'PLIPFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_plip_attr_1;
            ELSIF p_short_name = 'PLIPFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_plip_attr_2;
            ELSIF p_short_name = 'PLIPFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_plip_attr_3;
            ELSIF p_short_name = 'PLIPFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_plip_attr_4;
            ELSIF p_short_name = 'PLIPFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_plip_attr_5;
            ELSIF p_short_name = 'PLIPFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_plip_attr_6;
            ELSIF p_short_name = 'PLIPFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_plip_attr_7;
            ELSIF p_short_name = 'PLIPFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_plip_attr_8;
            ELSIF p_short_name = 'PLIPFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_plip_attr_9;
            ELSIF p_short_name = 'PLIPFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_plip_attr_10;
            ELSIF p_short_name = 'PLSTUPBY' THEN
              l_rslt_elmt :=                     -- Fix for Bug 3870480
                     decode_setup(p_data_elmt_typ_cd,
				                  get_name(ben_ext_person.g_last_updated_by),
				                  ben_ext_person.g_last_updated_by);
            ELSIF p_short_name = 'PLSTUPDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_last_update_date, p_frmt_mask_cd);
            ELSIF p_short_name = 'PLSTUPLG' THEN
                  l_rslt_elmt :=
                            apply_format_mask(ben_ext_person.g_last_update_login, p_frmt_mask_cd);
            ELSIF p_short_name = 'PLTYPFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_ptp_attr_1;
            ELSIF p_short_name = 'PLTYPFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_ptp_attr_2;
            ELSIF p_short_name = 'PLTYPFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_ptp_attr_3;
            ELSIF p_short_name = 'PLTYPFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_ptp_attr_4;
            ELSIF p_short_name = 'PLTYPFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_ptp_attr_5;
            ELSIF p_short_name = 'PLTYPFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_ptp_attr_6;
            ELSIF p_short_name = 'PLTYPFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_ptp_attr_7;
            ELSIF p_short_name = 'PLTYPFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_ptp_attr_8;
            ELSIF p_short_name = 'PLTYPFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_ptp_attr_9;
            ELSIF p_short_name = 'PLTYPFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_ptp_attr_10;
            end if;
            elsif p_two_char_substr = 'PM'  then
              IF p_short_name = 'PMTPRAMT' THEN
                 hr_utility.set_location(' pm ' || p_short_name ,5382 );
                 l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_mntot_prem_amt, p_frmt_mask_cd);
              ELSIF p_short_name = 'PMTPRCRT' THEN
                 hr_utility.set_location(' pm ' || p_short_name ,5382 );
                 l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_mntot_prem_cramt, p_frmt_mask_cd);
              end if ;
            --

            elsif p_two_char_substr = 'PN'  then
            IF p_short_name = 'PNMLHR' THEN
                  l_rslt_elmt := apply_format_mask(ben_ext_person.g_asg_normal_hours, p_frmt_mask_cd);
            ELSIF p_short_name = 'PNMLFRQ' THEN
                  l_rslt_elmt := ben_ext_person.g_asg_frequency;
            ELSIF p_short_name = 'PNMLFTM' THEN
                   l_rslt_elmt := ben_ext_person.g_asg_time_normal_finish;
            ELSIF p_short_name = 'PNMLSTM' THEN
                   l_rslt_elmt := ben_ext_person.g_asg_time_normal_start;
            end if;
            --- tilak: the decode supports for null value and  default values
            --- so it is neccessery to call the apply_decode for null element
            /*
            if p_data_elmt_typ_cd = 'D'  then
               l_rslt_elmt := apply_decode
                                 (p_value            => l_rslt_elmt,
                                  p_ext_data_elmt_id => p_ext_data_elmt_id,
                                  p_default          => p_dflt_val,
                                  p_short_name       => p_short_name);
            end if;
            */

            elsif p_two_char_substr = 'PO' then
            IF p_short_name = 'POCSTDT' THEN
              l_rslt_elmt :=
                    apply_format_mask(ben_ext_person.g_enrt_orgcovg_strdt, p_frmt_mask_cd);
            ELSIF p_short_name = 'POCSTDTP' THEN
              l_rslt_elmt :=
                    apply_format_mask(ben_ext_person.g_enrt_prt_orgcovg_strdt, p_frmt_mask_cd);
            ELSIF p_short_name = 'POFNUM' THEN
              l_rslt_elmt := ben_ext_person.g_office_number;
            --

            ELSIF p_short_name = 'POIPSQNUM' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_oip_seq_num, p_frmt_mask_cd);
            ELSIF p_short_name = 'POPTFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_opt_attr_1;
            ELSIF p_short_name = 'POPTFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_opt_attr_2;
            ELSIF p_short_name = 'POPTFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_opt_attr_3;
            ELSIF p_short_name = 'POPTFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_opt_attr_4;
            ELSIF p_short_name = 'POPTFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_opt_attr_5;
            ELSIF p_short_name = 'POPTFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_opt_attr_6;
            ELSIF p_short_name = 'POPTFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_opt_attr_7;
            ELSIF p_short_name = 'POPTFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_opt_attr_8;
            ELSIF p_short_name = 'POPTFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_opt_attr_9;
            ELSIF p_short_name = 'POPTFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_opt_attr_10;
            ELSIF p_short_name = 'POPTNM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_enrt_opt_name,
                 to_char(ben_ext_person.g_enrt_opt_id));
            ELSIF p_short_name = 'POSFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_prs_flex_01;
            ELSIF p_short_name = 'POSFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_prs_flex_02;
            ELSIF p_short_name = 'POSFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_prs_flex_03;
            ELSIF p_short_name = 'POSFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_prs_flex_04;
            ELSIF p_short_name = 'POSFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_prs_flex_05;
            ELSIF p_short_name = 'POSFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_prs_flex_06;
            ELSIF p_short_name = 'POSFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_prs_flex_07;
            ELSIF p_short_name = 'POSFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_prs_flex_08;
            ELSIF p_short_name = 'POSFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_prs_flex_09;
            ELSIF p_short_name = 'POSFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_prs_flex_10;
            --
            -- RSLT
            --
            ELSIF p_short_name = 'POPTFDNM'   then
                   l_rslt_elmt := ben_ext_person.g_enrt_opt_fd_name ;
            ELSIF p_short_name = 'POPTFDCD'  then
                   l_rslt_elmt := ben_ext_person.g_enrt_opt_fd_code ;
            end if;
            elsif p_two_char_substr = 'PP' then
            IF p_short_name = 'PPACRTBY' THEN
              l_rslt_elmt :=                     -- Fix for Bug 3870480
                     decode_setup(p_data_elmt_typ_cd,
				                  get_name(ben_ext_person.g_addr_created_by),
								  ben_ext_person.g_addr_created_by);
            ELSIF p_short_name = 'PPACRTDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_addr_creation_date, p_frmt_mask_cd);
            --
            ELSIF p_short_name = 'PPALSTUPBY' THEN
              l_rslt_elmt :=                    -- Fix for Bug 3870480
                     decode_setup(p_data_elmt_typ_cd,
				                  get_name(ben_ext_person.g_addr_last_updated_by),
								  ben_ext_person.g_addr_last_updated_by);
            ELSIF p_short_name = 'PPALSTUPDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_addr_last_update_date, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPALSTUPLG' THEN
                  l_rslt_elmt :=
                       apply_format_mask(ben_ext_person.g_addr_last_update_login, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPBSFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_pbs_flex_01;
            ELSIF p_short_name = 'PPBSFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_pbs_flex_02;
            ELSIF p_short_name = 'PPBSFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_pbs_flex_03;
            ELSIF p_short_name = 'PPBSFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_pbs_flex_04;
            ELSIF p_short_name = 'PPBSFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_pbs_flex_05;
            ELSIF p_short_name = 'PPBSFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_pbs_flex_06;
            ELSIF p_short_name = 'PPBSFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_pbs_flex_07;
            ELSIF p_short_name = 'PPBSFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_pbs_flex_08;
            ELSIF p_short_name = 'PPBSFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_pbs_flex_09;
            ELSIF p_short_name = 'PPBSFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_pbs_flex_10;
            ELSIF p_short_name = 'PPGMNM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_enrt_pgm_name,
                 to_char(ben_ext_person.g_enrt_pgm_id));
            ELSIF p_short_name = 'PPHFX' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_phone_fax,
p_frmt_mask_cd);
            ELSIF p_short_name = 'PPHHM' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_phone_home,
p_frmt_mask_cd);
            ELSIF p_short_name = 'PPHMB' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_phone_mobile,
p_frmt_mask_cd);
            ELSIF p_short_name = 'PPHWK' THEN
              l_rslt_elmt := apply_format_mask(ben_ext_person.g_phone_work,
p_frmt_mask_cd);
            ELSIF p_short_name = 'PPIPSQNUM' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_pip_seq_num, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPLCY' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_plcy_r_grp;
            ELSIF p_short_name = 'PPLNM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_enrt_pl_name,
                 to_char(ben_ext_person.g_enrt_pl_id));
            ELSIF p_short_name = 'PPLSQNUM' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_pl_seq_num, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPLYRENDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_pl_yr_enddt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPLYRSTDT' THEN
               l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_pl_yr_strdt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPLYRSTDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_pl_yr_strdt, p_frmt_mask_cd);
            ---2559743
            ELSIF p_short_name = 'PPLFDNM'    then
                     l_rslt_elmt := ben_ext_person.g_enrt_pl_fd_name ;
            ELSIF p_short_name = 'PPLFDCD'   then
                      l_rslt_elmt := ben_ext_person.g_enrt_pl_fd_code ;
            ELSIF p_short_name = 'PPPLCPY'   then      -- cobra plan payment days
                  l_rslt_elmt := ben_ext_person.g_elig_cobra_payment_dys;
            --
            ELSIF p_short_name = 'PPOSFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_pos_flex_01;
            ELSIF p_short_name = 'PPOSFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_pos_flex_02;
            ELSIF p_short_name = 'PPOSFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_pos_flex_03;
            ELSIF p_short_name = 'PPOSFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_pos_flex_04;
            ELSIF p_short_name = 'PPOSFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_pos_flex_05;
            ELSIF p_short_name = 'PPOSFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_pos_flex_06;
            ELSIF p_short_name = 'PPOSFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_pos_flex_07;
            ELSIF p_short_name = 'PPOSFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_pos_flex_08;
            ELSIF p_short_name = 'PPOSFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_pos_flex_09;
            ELSIF p_short_name = 'PPOSFLX10' THEN
                  l_rslt_elmt := ben_ext_person.g_pos_flex_10;
            ELSIF p_short_name = 'PPOPFDNM' then
		  l_rslt_elmt := ben_ext_person.g_enrt_opt_pl_fd_name	  ;
            ELSIF p_short_name = 'PPOPFDCD' then
                  l_rslt_elmt := ben_ext_person.g_enrt_opt_pl_fd_code	  ;
            ELSIF p_short_name = 'PPPPFDNM' then
                  l_rslt_elmt := ben_ext_person.g_enrt_pl_pgm_fd_name	  ;
            ELSIF p_short_name = 'PPPPFDCD' then
                  l_rslt_elmt := ben_ext_person.g_enrt_pl_pgm_fd_code	  ;
            ELSIF p_short_name = 'PPYPFDNM' then
                  l_rslt_elmt := ben_ext_person.g_enrt_pl_typ_pgm_fd_name ;
            ELSIF p_short_name = 'PPYPFDCD' then
                  l_rslt_elmt := ben_ext_person.g_enrt_pl_typ_pgm_fd_code ;
            ELSIF p_short_name = 'PPPRNUM' THEN
               l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_payroll_period_number, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPRFDNM'  then
                      l_rslt_elmt := ben_ext_person.g_enrt_pgm_fd_name ;
            ELSIF p_short_name = 'PPRFDCD' then
                      l_rslt_elmt := ben_ext_person.g_enrt_pgm_fd_code ;
            ELSIF p_short_name = 'PPREND' THEN
              --
              IF ben_ext_person.g_ppr_end_dt = to_date('31/12/4712','DD/MM/YYYY') THEN
                l_rslt_elmt := null;
              ELSE
                l_rslt_elmt := apply_format_mask
                      (ben_ext_person.g_ppr_end_dt, p_frmt_mask_cd);
              END IF;
              --
            ELSIF p_short_name = 'PPRENDT' THEN
               l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_payroll_period_enddt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPRIDENT' THEN
              l_rslt_elmt := ben_ext_person.g_ppr_ident;
            ELSIF p_short_name = 'PPRLFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_prl_flex_01;
            ELSIF p_short_name = 'PPRLFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_prl_flex_02;
            ELSIF p_short_name = 'PPRLFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_prl_flex_03;
            ELSIF p_short_name = 'PPRLFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_prl_flex_04;
            ELSIF p_short_name = 'PPRLFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_prl_flex_05;
            ELSIF p_short_name = 'PPRLFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_prl_flex_06;
            ELSIF p_short_name = 'PPRLFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_prl_flex_07;
            ELSIF p_short_name = 'PPRLFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_prl_flex_08;
            ELSIF p_short_name = 'PPRLFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_prl_flex_09;
            ELSIF p_short_name = 'PPRLFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_prl_flex_10;
            ELSIF p_short_name = 'PPRNAME' THEN
              l_rslt_elmt := ben_ext_person.g_ppr_name;
            ELSIF p_short_name = 'PPRSTDT' THEN
               l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_payroll_period_strtdt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPRSTRT' THEN
                  l_rslt_elmt := apply_format_mask
                     (ben_ext_person.g_ppr_strt_dt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPRTYP' THEN
              l_rslt_elmt := ben_ext_person.g_ppr_typ;
            ELSIF p_short_name = 'PPSCRTBY' THEN
              l_rslt_elmt :=                   -- Fix for Bug 3870480
                     decode_setup(p_data_elmt_typ_cd,
				                  get_name(ben_ext_person.g_pos_created_by),
								  ben_ext_person.g_pos_created_by);
            ELSIF p_short_name = 'PPSCRTDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_pos_creation_date, p_frmt_mask_cd);
            --
            --  Cobra
            ELSIF p_short_name = 'PPSLSTUPBY' THEN
              l_rslt_elmt :=                      -- Fix for Bug 3870480
                     decode_setup(p_data_elmt_typ_cd,
				                  get_name(ben_ext_person.g_pos_last_updated_by),
								  ben_ext_person.g_pos_last_updated_by);
            ELSIF p_short_name = 'PPSLSTUPDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_pos_last_update_date, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPSLSTUPLG' THEN
                  l_rslt_elmt :=
                   apply_format_mask(ben_ext_person.g_pos_last_update_login, p_frmt_mask_cd);
            ELSIF p_short_name = 'PPT' THEN
               l_rslt_elmt := ben_ext_person.g_payroll_period_type;
            ELSIF p_short_name = 'PPTPNM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_enrt_pl_typ_name,
                 to_char(ben_ext_person.g_enrt_pl_typ_id));
            ELSIF p_short_name = 'PPTPSQNUM' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_enrt_ptp_seq_num, p_frmt_mask_cd);
              ---2559743
            ELSIF p_short_name = 'PPTPFDNM'   then
                   l_rslt_elmt := ben_ext_person.g_enrt_pl_typ_fd_name ;
            ELSIF p_short_name = 'PPTPFDCD'   then
                   l_rslt_elmt := ben_ext_person.g_enrt_pl_typ_fd_code ;
              ---2559743
            end if;
            elsif p_two_char_substr = 'PR' then
            IF p_short_name = 'PRMMOCAFX1' THEN
              l_rslt_elmt := ben_ext_person.g_prem_mn_costalloc_flex_01;
            ELSIF p_short_name = 'PRMMOCAFX2' THEN
              l_rslt_elmt := ben_ext_person.g_prem_mn_costalloc_flex_02;
            ELSIF p_short_name = 'PRMMOCAFX3' THEN
              l_rslt_elmt := ben_ext_person.g_prem_mn_costalloc_flex_03;
            ELSIF p_short_name = 'PRMMOCAFLX' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_prem_mn_costalloc_id, p_frmt_mask_cd);
            ELSIF p_short_name = 'PRMMOCANM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_prem_mn_costalloc_name,
                 to_char(ben_ext_person.g_prem_mn_costalloc_id));
            ELSIF p_short_name = 'PRMMOAMT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_prem_mn_amt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PRMMAADJ' THEN
              l_rslt_elmt := ben_ext_person.g_prem_mn_mnl_adj;
            ELSIF p_short_name = 'PRMMACRADJ' THEN
              l_rslt_elmt := ben_ext_person.g_prem_mn_cr_mnl_adj;
            ELSIF p_short_name = 'PRMMOCRT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_prem_mn_cramt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PRMMOUOM' THEN
              l_rslt_elmt := ben_ext_person.g_prem_mn_uom;
            ELSIF p_short_name = 'PRMTYP' THEN
              l_rslt_elmt := ben_ext_person.g_prem_type;
            ELSIF p_short_name = 'PRMYEAR' THEN
              l_rslt_elmt := ben_ext_person.g_prem_year;
              hr_utility.set_location(' year  ' ||  ben_ext_person.g_prem_year  , 5484);
            ELSIF p_short_name = 'PRMMNTH' THEN
               hr_utility.set_location(' month ' ||    ben_ext_person.g_prem_month , 119);
              l_rslt_elmt := ben_ext_person.g_prem_month;
            ELSIF p_short_name = 'PRMLUPDT' THEN
                Begin                             -- to_date removed in 115.149
                  l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_prem_last_upd_date,
                                   p_frmt_mask_cd);
               exception
                  when others then
                  l_rslt_elmt := ben_ext_person.g_prem_last_upd_date;
               end  ;
              hr_utility.set_location(' updated date  ' ||    ben_ext_person.g_prem_last_upd_date , 119);
            ELSIF p_short_name = 'PRAD1' THEN
              l_rslt_elmt := ben_ext_person.g_prim_address_line_1;
            ELSIF p_short_name = 'PRAD2' THEN
              l_rslt_elmt := ben_ext_person.g_prim_address_line_2;
            ELSIF p_short_name = 'PRAD3' THEN
              l_rslt_elmt := ben_ext_person.g_prim_address_line_3;
            ELSIF p_short_name = 'PRADRDT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_prim_address_date, p_frmt_mask_cd);
            ELSIF p_short_name = 'PRADSVA' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_prim_addr_service_area,
                 to_char(ben_ext_person.g_prim_addr_sva_id));
            ELSIF p_short_name = 'PRCNTY' THEN -- Fix for Bug 2593220
              -- For UK Legislation, the County code is stored in the
              -- Region_1 column of per_addresses instead of County name.
              -- So we need to get the County name from fnd_common_lookups, for lookup_type 'GB_COUNTY'

              l_rslt_elmt := nvl(hr_general.DECODE_FND_COMM_LOOKUP(l_lookup_type,
                                 ben_ext_person.g_prim_county),
                                 ben_ext_person.g_prim_county);
              --l_rslt_elmt := ben_ext_person.g_prim_county; -- End of Fix, Bug 2593220
            ELSIF p_short_name = 'PRCRY' THEN
              l_rslt_elmt := ben_ext_person.g_prim_country;
            ELSIF p_short_name = 'PRCTY' THEN
              l_rslt_elmt := ben_ext_person.g_prim_city;
            ELSIF p_short_name = 'PREETOTDS' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_ee_ttl_distribution, p_frmt_mask_cd);
            ELSIF p_short_name = 'PRERTOTDS' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_er_ttl_distribution, p_frmt_mask_cd);
            ELSIF p_short_name = 'PRLSHP' THEN
              l_rslt_elmt := ben_ext_person.g_per_rlshp_type;
            ELSIF p_short_name = 'PRPGRPNM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_enrt_rpt_group_name,
                 to_char(ben_ext_person.g_enrt_rpt_group_id));
            ELSIF p_short_name = 'PRREG3' THEN
              l_rslt_elmt := ben_ext_person.g_prim_region_3;
            ELSIF p_short_name = 'PRSID' THEN
              l_rslt_elmt := apply_format_mask( ben_ext_person.g_Person_ID,p_frmt_mask_cd) ;
            ELSIF p_short_name = 'PRSTA' THEN
              l_rslt_elmt := ben_ext_person.g_prim_state;
            ELSIF p_short_name = 'PRSTAPR' THEN    -- ansi state
              l_rslt_elmt := ben_ext_person.g_prim_state_ansi;
            ELSIF p_short_name = 'PRTOTORT' THEN
              l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_ttl_other_rate, p_frmt_mask_cd);
            ---fix from fido
            ELSIF p_short_name = 'PRSEQ' THEN
                l_rslt_elmt := apply_format_mask(ben_ext_person.g_dpnt_contact_seq_num,p_frmt_mask_cd);
            ----
            ELSIF p_short_name = 'PRTYP' THEN
              l_rslt_elmt := ben_ext_person.g_part_type;
            ELSIF p_short_name = 'PRZIP' THEN
              l_rslt_elmt := ben_ext_person.g_prim_postal_code;
             -- Participation Rate - Reimbursement
            ELSIF p_short_name = 'PRREIMBRS' THEN
                hr_utility.set_location(' PRREIMBRS '|| ben_ext_person.g_er_reimbursement,937);
                  l_rslt_elmt :=
                 apply_format_mask(ben_ext_person.g_er_reimbursement , p_frmt_mask_cd);

            end if;
            elsif p_two_char_substr = 'PS' then
            IF p_short_name = 'PSTSCD' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_status_cd;
            elsIF p_short_name = 'PSUPFLNM' THEN
              l_rslt_elmt := ben_ext_person.g_sup_full_name;
              --hr_utility.set_location('sup name '|| l_rslt_elmt,937);
            elsif p_short_name = 'PSUPEMNO' THEN
              l_rslt_elmt := ben_ext_person.g_sup_employee_number;

            end if;
            elsif p_two_char_substr = 'PT' then
            IF p_short_name = 'PTERMRS' THEN
              l_rslt_elmt := ben_ext_person.g_term_reason;
	    --
            -- Flex Fields
            --
            ELSIF p_short_name = 'PTOTPRAMT' THEN
              l_rslt_elmt :=
              apply_format_mask(ben_ext_person.g_enrt_total_premium_amt, p_frmt_mask_cd);
            ELSIF p_short_name = 'PTOTPRUOM' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_total_premium_uom;
            end if;
            end if;
      elsif p_one_char_substr = 'R' then


            if p_two_char_substr = 'RE' then
               -- this element does not have any values
               -- this is used to just link the record in writing
               IF p_short_name = 'RECLINKS' THEN
                  l_rslt_elmt := NULL;
               END IF  ;

            ELSIF  p_two_char_substr = 'RS' then
            IF p_short_name = 'RSLTFLX01' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_attr_1;
            ELSIF p_short_name = 'RSLTFLX02' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_attr_2;
            ELSIF p_short_name = 'RSLTFLX03' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_attr_3;
            ELSIF p_short_name = 'RSLTFLX04' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_attr_4;
            ELSIF p_short_name = 'RSLTFLX05' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_attr_5;
            ELSIF p_short_name = 'RSLTFLX06' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_attr_6;
            ELSIF p_short_name = 'RSLTFLX07' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_attr_7;
            ELSIF p_short_name = 'RSLTFLX08' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_attr_8;
            ELSIF p_short_name = 'RSLTFLX09' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_attr_9;
            ELSIF p_short_name = 'RSLTFLX10' THEN
              l_rslt_elmt := ben_ext_person.g_enrt_attr_10;
            end if;
            elsif p_two_char_substr = 'RU' then
            IF p_short_name = 'RUNDT' THEN
               l_rslt_elmt := apply_format_mask(ben_extract.g_run_date,
p_frmt_mask_cd);
            ELSIF p_short_name = 'RUNPPEDT' then
                  l_rslt_elmt := apply_format_mask(ben_ext_person.g_runrslt_last_pay_date,
p_frmt_mask_cd);

            ELSIF p_short_name = 'RUNELDESC' THEN
               l_rslt_elmt := ben_ext_person.g_runrslt_element_description;
            ELSIF p_short_name = 'RUNELINCUR' THEN
               l_rslt_elmt := ben_ext_person.g_runrslt_input_currency;
            ELSIF p_short_name = 'RUNELNM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_runrslt_element_name,
                 to_char(ben_ext_person.g_runrslt_element_id));
            ELSIF p_short_name = 'RUNELOUCUR' THEN
               l_rslt_elmt := ben_ext_person.g_runrslt_output_currency;
            ELSIF p_short_name = 'RUNELPRCLS' THEN
               l_rslt_elmt := ben_ext_person.g_runrslt_classification;
            ELSIF p_short_name = 'RUNELPRTYP' THEN
               l_rslt_elmt := ben_ext_person.g_runrslt_processing_type;
            ELSIF p_short_name = 'RUNELRPNM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_runrslt_reporting_name,
                 to_char(ben_ext_person.g_runrslt_classification_id));
            ELSIF p_short_name = 'RUNELSKPRL' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_runrslt_skip_rule,
                 to_char(ben_ext_person.g_runrslt_skip_rule_id));
            ELSIF p_short_name = 'RUNENTTYP' THEN
               l_rslt_elmt := ben_ext_person.g_runrslt_entry_type;
            ELSIF p_short_name = 'RUNIDNT' THEN
               l_rslt_elmt := ben_ext_person.g_runrslt_identifier;
            ELSIF p_short_name = 'RUNINVLNM' THEN
              l_rslt_elmt := decode_setup(p_data_elmt_typ_cd,
                 ben_ext_person.g_runrslt_input_value_name,
                 to_char(ben_ext_person.g_runrslt_input_value_id));
            ELSIF p_short_name = 'RUNINVLSQ' THEN
               l_rslt_elmt :=
apply_format_mask(ben_ext_person.g_runrslt_input_value_sequence,
p_frmt_mask_cd);
            ELSIF p_short_name = 'RUNINVLUNT' THEN
               l_rslt_elmt := ben_ext_person.g_runrslt_input_value_units;
            ELSIF p_short_name = 'RUNJURCD' THEN
               L_rslt_elmt := ben_ext_person.g_runrslt_jurisdiction_code;
            ELSIF p_short_name = 'RUNSRCTYP' THEN
               l_rslt_elmt := ben_ext_person.g_runrslt_source_type;
            ELSIF p_short_name = 'RUNSTAT' THEN
               l_rslt_elmt := ben_ext_person.g_runrslt_status;
            ELSIF p_short_name = 'RUNVALCHR' THEN
               -- run result value in characted format
               hr_utility.set_location (' character for run result ',98 );
               Begin
                  l_rslt_elmt :=  apply_format_mask(ben_ext_person.g_runrslt_value,
                                   p_frmt_mask_cd);
               exception
                  when others then
                  l_rslt_elmt := ben_ext_person.g_runrslt_value;
               end ;

            ELSIF p_short_name = 'RUNVALDT' THEN
               --l_rslt_elmt := ben_ext_person.g_runrslt_value;
               -- to_date raise any error then sent the value as it is
               hr_utility.set_location (' date  for run result ',98 );
               Begin          -- to_date removed in 115.149
                  l_rslt_elmt :=  apply_format_mask(fnd_date.chardate_to_date(ben_ext_person.g_runrslt_value ),
                                   p_frmt_mask_cd);
               exception
                  when others then
                  l_rslt_elmt := ben_ext_person.g_runrslt_value;
               end ;
            ELSIF p_short_name = 'RUNVAL' THEN
               --l_rslt_elmt := ben_ext_person.g_runrslt_value;
               -- to_number raise any error then sent the value as it is
               hr_utility.set_location (' number  for run result ',98 );
               Begin
                  l_rslt_elmt :=  apply_format_mask(to_number(ben_ext_person.g_runrslt_value),
                                   p_frmt_mask_cd);
               exception
                  when others then
                  l_rslt_elmt := ben_ext_person.g_runrslt_value;
               end ;
            end if;
           end if ;
      elsif p_one_char_substr = 'S' then
            IF p_short_name = 'SEX' THEN
              hr_utility.set_location('sex  '||ben_ext_person.g_sex,936);
              l_rslt_elmt := ben_ext_person.g_sex;
            ELSIF p_short_name = 'STDNT' THEN
              l_rslt_elmt := ben_ext_person.g_student_status;
            ELSIF p_short_name = 'STRTDT' THEN
               l_rslt_elmt := apply_format_mask(ben_extract.g_ext_strt_dt,
                              p_frmt_mask_cd);
            end if;
      elsif p_one_char_substr = 'T' then
            IF p_short_name = 'TITLE' THEN
              l_rslt_elmt := ben_ext_person.g_title;
            --
            end if;
      ELSE
            --
              ben_ext_person.g_elmt_name := g_elmt_name ;
              ben_ext_person.g_err_num   := 91924;
              ben_ext_person.g_err_name  := 'BEN_91924_EXT_INV_FLD';
              --raise ben_ext_person.detail_error;
              g_rqd_elmt_is_present := 'N' ;
              return null ;
            --
      END IF;
            --

      --- tilak: the decode supports for null value and  default values
      --- so it is neccessery to call the apply_decode for null element
      if p_data_elmt_typ_cd = 'D' /*and l_rslt_elmt is not null*/ then

          l_rslt_elmt := apply_decode
                             (p_value            => l_rslt_elmt,
                              p_ext_data_elmt_id => p_ext_data_elmt_id,
                              p_default          => p_dflt_val,
                               p_short_name       => p_short_name);

      end if;

      --since the name like lower /upper can be translated so the code is
      -- passsed as param not the meaning  like other format  parameters
      if substr(p_frmt_mask_lookup_cd,1,1) = 'C' then
          l_rslt_elmt := apply_format_Function(l_rslt_elmt,p_frmt_mask_lookup_cd);
      end if;
      --

      hr_utility.set_location(' Exiting:'||l_proc, 15);
      return l_rslt_elmt ;
end get_element_value ;


--
-- ----------------------------------------------------------------------------
-- |---------< Calculate_formula >---------------------------------------------|
-- ----------------------------------------------------------------------------


Function Calculate_formula ( p_person_id         in  number  ,
                             p_data_elmt_rl      in  number  ,
                             p_ext_per_bg_id     in  number  ,
                             p_String_val        in  varchar2,
                             p_frmt_mask_lookup_cd in varchar2,
                             p_frmt_mask_cd      in varchar2 ,
                             p_business_group_id in number   ,
                             p_effective_date in date ) return varchar2 is

  l_proc               varchar2(72) := g_package||'process_ext_recs';
  l_jurisdiction_code   varchar2(30);
  l_outputs             ff_exec.outputs_t;
  l_rslt_elmt               ben_ext_rslt_dtl.val_01%type  := null;
  l_rslt_elmt_fmt           ben_ext_rslt_dtl.val_01%type  := null;

  -- data element is a rule:

  cursor c_rule_type(p_rule_id ff_formulas_f.formula_id%type) is
    select formula_type_id
    from   ff_formulas_f
    where  formula_id = p_rule_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;


  l_rule_type  c_rule_type%rowtype;

  cursor c_asg is
    select asg.assignment_id,asg.organization_id,loc.region_2
    from   per_all_assignments_f asg,hr_locations_all loc
    where  asg.person_id = p_person_id
    and    (asg.primary_flag = 'Y' OR  asg.assignment_type = 'A')
    and    asg.assignment_id = nvl(ben_ext_person.g_assignment_id,asg.assignment_id)  --1969853
    and    asg.location_id = loc.location_id(+)
    and    ben_ext_person.g_person_ext_dt
           between asg.effective_start_date
           and     asg.effective_end_date;
  --
  l_asg      c_asg%rowtype;


Begin
  --
  hr_utility.set_location('Entering'||l_proc , 5) ;

  hr_utility.set_location(' Rule537:'||p_data_elmt_rl, 39);
  open  c_rule_type(p_data_elmt_rl);
  fetch c_rule_type into l_rule_type;
  close c_rule_type;
  --
  hr_utility.set_location(' Rule537:'||l_rule_type.formula_type_id, 39);
  open c_asg;
  fetch c_asg into l_asg;
  close c_asg;
   --
  if l_rule_type.formula_type_id = -413 then      -- Person Level rule
     -- Call formula initialise routine
     -- assignment condition is removed, with this conidtion dpnt can not be called for the formula
     -- user need formula to get person level data for dpnt
     --if l_asg.assignment_id is not null then
     l_outputs := benutils.formula
                        (p_formula_id         => p_data_elmt_rl,
                         p_effective_date     => ben_ext_person.g_person_ext_dt,
                         p_assignment_id      => l_asg.assignment_id,
                         p_organization_id    => l_asg.organization_id,
                         p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                         p_jurisdiction_code  => l_jurisdiction_code,
                         p_per_cm_id          => ben_ext_person.g_per_cm_id
                         ,p_param1             => 'EXT_DFN_ID'
                         ,p_param1_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                         ,p_param2             => 'EXT_RSLT_ID'
                         ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                         ,p_param3             => 'EXT_PERSON_ID'
                         ,p_param3_value       => to_char(nvl(ben_ext_person.g_person_id, -1))
                         ,p_param4             => 'EXT_PROCESS_BUSINESS_GROUP'
                         ,p_param4_value       =>  to_char(p_business_group_id)
                         ,p_param5             => 'EXT_USER_VALUE'
                         ,p_param5_value       =>  p_String_Val
                         ); --optional
                --
                l_rslt_elmt := l_outputs(l_outputs.first).value;
                --
              --else
                --
              --  l_rslt_elmt := null;
                 --
              --end if;
              --
  elsif l_rule_type.formula_type_id = -531 then  -- Enrollment Level rule
     -- Call formula initialise routine
     hr_utility.set_location('g_enrt_prtt_enrt_rslt_id' ||ben_ext_person.g_enrt_prtt_enrt_rslt_id, 886) ;
     l_outputs := benutils.formula
                                (p_formula_id         => p_data_elmt_rl,
                                 p_effective_date     => ben_ext_person.g_benefits_ext_dt,
                                 p_assignment_id      => l_asg.assignment_id,
                                 p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                                 p_pl_id              => ben_ext_person.g_enrt_pl_id,
                                 p_opt_id             => ben_ext_person.g_enrt_opt_id,
                                 p_ler_id             => ben_ext_person.g_enrt_ler_id
                                 --RChase pass extract definition id as input value
                                 ,p_param1             => 'EXT_DFN_ID'
                                 ,p_param1_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                                 ,p_param2             => 'EXT_RSLT_ID'
                                 ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                                 /* Start of Changes for WWBUG: 1828349:  addition   */
                                 ,p_param3             => 'PRTT_ENRT_RSLT_ID'
                                 ,p_param3_value       => to_char(nvl(ben_ext_person.g_enrt_prtt_enrt_rslt_id, -1))
                                 /* for the ansi dpnt person id is necessary 3419446 */
                                 ,p_param4             => 'PRTT_ENRT_PERSON_ID'
                                 ,p_param4_value       => to_char(nvl(ben_ext_person.g_person_id, -1))
                                 ,p_param5             => 'EXT_PROCESS_BUSINESS_GROUP'
                                 ,p_param5_value       =>  to_char(p_business_group_id)
                                 ,p_param6             => 'EXT_USER_VALUE'
                                 ,p_param6_value       =>  p_String_Val
                                 );
 				 /* End of Changes for WWBUG: 1828349:  addition   */

              --
              l_rslt_elmt := l_outputs(l_outputs.first).value;
              --
  elsif l_rule_type.formula_type_id = -536 then  -- Eligible Level Rule
     -- Call formula initialise routine
     l_outputs := benutils.formula
                                (p_formula_id         => p_data_elmt_rl,
                                 p_effective_date     => ben_ext_person.g_benefits_ext_dt,
                                 p_assignment_id      => l_asg.assignment_id,
                                 p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                                 p_elig_per_elctbl_chc_id => ben_ext_person.g_elig_per_elctbl_chc_id
                                 --RChase pass extract definition id as input value
                                 ,p_param1             => 'EXT_DFN_ID'
                                 ,p_param1_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                                 ,p_param2             => 'EXT_RSLT_ID'
                                 ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                                 ,p_param3             => 'EXT_PROCESS_BUSINESS_GROUP'
                                 ,p_param3_value       =>  to_char(p_business_group_id)
                                 ,p_param4             => 'EXT_USER_VALUE'
                                 ,p_param4_value       =>  p_String_Val
                                 );
              --
              l_rslt_elmt := l_outputs(l_outputs.first).value;
              --
  elsif l_rule_type.formula_type_id = -537 then  -- Premium Level Rule
     hr_utility.set_location(' Rule537:'||l_proc, 35);
     -- Call formula initialise routine
     l_outputs := benutils.formula
                                (p_formula_id         => p_data_elmt_rl,
                                 p_effective_date     => ben_ext_person.g_benefits_ext_dt,
                                 p_assignment_id      => l_asg.assignment_id,
                                 p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                                 p_param1             => 'PRTT_PREM_BY_MO_ID',
                                 p_param1_value       => to_char(ben_ext_person.g_prtt_prem_by_mo_id),
                                 p_param2             => 'ACTL_PREM_ID',
                                 p_param2_value       => to_char(ben_ext_person.g_prem_actl_prem_id)
                                 ,p_param3             => 'EXT_DFN_ID'
                                 ,p_param3_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                                 ,p_param4             => 'EXT_RSLT_ID'
                                 ,p_param4_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                                 ,p_param5             => 'EXT_PROCESS_BUSINESS_GROUP'
                                 ,p_param5_value       =>  to_char(p_business_group_id)
                                 ,p_param6             => 'EXT_USER_VALUE'
                                 ,p_param6_value       =>  p_String_Val
                                 );
              --
              l_rslt_elmt := l_outputs(l_outputs.first).value;
              --
  elsif l_rule_type.formula_type_id = -538 then  -- Dependnt Level Rule
     -- Call formula initialise routine
     l_outputs := benutils.formula
                                (p_formula_id         => p_data_elmt_rl,
                                 p_effective_date     => ben_ext_person.g_benefits_ext_dt,
                                 p_assignment_id      => l_asg.assignment_id,
                                 p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                                 p_param1             => 'ELIG_CVRD_DPNT_ID',
                                 p_param1_value       => to_char(ben_ext_person.g_dpnt_cvrd_dpnt_id)
                                 ,p_param2             => 'EXT_DFN_ID'
                                 ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                                 ,p_param3             => 'EXT_RSLT_ID'
                                 ,p_param3_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                                 ,p_param4             => 'EXT_PROCESS_BUSINESS_GROUP'
                                 ,p_param4_value       =>  to_char(p_business_group_id)
                                 ,p_param5             => 'EXT_USER_VALUE'
                                 ,p_param5_value       =>  p_String_Val
                                 );
              --
              l_rslt_elmt := l_outputs(l_outputs.first).value;
              --
  elsif l_rule_type.formula_type_id = -539 then  -- Action Item Level Rule
     -- Call formula initialise routine
     l_outputs := benutils.formula
                                (p_formula_id         => p_data_elmt_rl,
                                 p_effective_date     => ben_ext_person.g_benefits_ext_dt,
                                 p_assignment_id      => l_asg.assignment_id,
                                 p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                                 p_prtt_enrt_actn_id  => ben_ext_person.g_actn_prtt_enrt_actn_id
                                 ,p_param1             => 'EXT_DFN_ID'
                                 ,p_param1_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                                 ,p_param2             => 'EXT_RSLT_ID'
                                 ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                                 ,p_param3             => 'EXT_PROCESS_BUSINESS_GROUP'
                                 ,p_param3_value       =>  to_char(p_business_group_id)
                                 ,p_param4             => 'EXT_USER_VALUE'
                                 ,p_param4_value       =>  p_string_Val
                                );
              --
              l_rslt_elmt := l_outputs(l_outputs.first).value;
              --
  elsif l_rule_type.formula_type_id = -540 then  -- Beneficiary level Rule
     -- Call formula initialise routine
     l_outputs := benutils.formula
                                (p_formula_id         => p_data_elmt_rl,
                                 p_effective_date     => ben_ext_person.g_benefits_ext_dt,
                                 p_assignment_id      => l_asg.assignment_id,
                                 p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                                 p_param1             => 'PL_BNF_ID',
                                 p_param1_value       => to_char(ben_ext_person.g_bnf_pl_bnf_id)
                                 ,p_param2             => 'EXT_DFN_ID'
                                 ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                                 ,p_param3             => 'EXT_RSLT_ID'
                                 ,p_param3_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                                 ,p_param4             => 'EXT_PROCESS_BUSINESS_GROUP'
                                 ,p_param4_value       =>  to_char(p_business_group_id)
                                 ,p_param5             => 'EXT_USER_VALUE'
                                 ,p_param5_value       =>  p_String_Val
                                );
              --
              l_rslt_elmt := l_outputs(l_outputs.first).value;
              --
  elsif l_rule_type.formula_type_id = -541 then  -- Flex credit level Rule
     -- Call formula initialise routine
     l_outputs := benutils.formula
                                (p_formula_id         => p_data_elmt_rl,
                                 p_effective_date     => ben_ext_person.g_benefits_ext_dt,
                                 p_assignment_id      => l_asg.assignment_id,
                                 p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                                 p_param1             => 'BNFT_PRVDR_POOL_ID',
                                 p_param1_value       => to_char(ben_ext_person.g_flex_bnft_pool_id)
                                 --RChase pass extract definition id as input value
                                 ,p_param2             => 'EXT_DFN_ID'
                                 ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                                 ,p_param3             => 'EXT_RSLT_ID'
                                 ,p_param3_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                                 ,p_param4             => 'EXT_PROCESS_BUSINESS_GROUP'
                                 ,p_param4_value       =>  to_char(p_business_group_id)
                                 ,p_param5             => 'EXT_USER_VALUE'
                                 ,p_param5_value       =>  p_String_Val
                                );
              --
              l_rslt_elmt := l_outputs(l_outputs.first).value;
              --
  elsif l_rule_type.formula_type_id = -542 then  -- payroll level Rule
     -- Call formula initialise routine
     l_outputs := benutils.formula
                                (p_formula_id         => p_data_elmt_rl,
                                 p_effective_date     => ben_ext_person.g_benefits_ext_dt,
                                 p_assignment_id      => l_asg.assignment_id,
                                 p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                                 p_param1             => 'ELEMENT_ENTRY_VALUE_ID',
                                 p_param1_value       => to_char(ben_ext_person.g_element_entry_value_id)
                                 --RChase pass extract definition id as input value
                                 ,p_param2             => 'EXT_DFN_ID'
                                 ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                                 ,p_param3             => 'EXT_RSLT_ID'
                                 ,p_param3_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                                 ,p_param4             => 'EXT_PROCESS_BUSINESS_GROUP'
                                 ,p_param4_value       =>  to_char(p_business_group_id)
                                 ,p_param5             => 'EXT_USER_VALUE'
                                 ,p_param5_value       =>  p_String_Val
                                );
              --
              l_rslt_elmt := l_outputs(l_outputs.first).value;
              --
  elsif l_rule_type.formula_type_id = -543 then  -- runresult level Rule
     -- Call formula initialise routine
     l_outputs := benutils.formula
                                (p_formula_id         => p_data_elmt_rl,
                                 p_effective_date     => ben_ext_person.g_benefits_ext_dt,
                                 p_assignment_id      => l_asg.assignment_id,
                                 p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                                 p_param1             => 'RUN_RESULT_ID',
                                 p_param1_value       => to_char(ben_ext_person.g_runrslt_identifier)
                                 --RChase pass extract definition id as input value
                                 ,p_param2             => 'EXT_DFN_ID'
                                 ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                                 ,p_param3             => 'EXT_RSLT_ID'
                                 ,p_param3_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                                 ---bug : 1724999
                                 ,p_param4             => 'INPUT_VALUE_ID'
                                 ,p_param4_value       => to_char(nvl(ben_ext_person.g_runrslt_input_value_id,-1))
                                 ,p_param5             => 'RESULT_VALUE'
                                 ,p_param5_value       => ben_ext_person.g_runrslt_value
                                 ,p_param6             => 'EXT_PROCESS_BUSINESS_GROUP'
                                 ,p_param6_value       =>  to_char(p_business_group_id)
                                 ,p_param7             => 'EXT_USER_VALUE'
                                 ,p_param7_value       =>  p_String_Val
                                 );
              --
              l_rslt_elmt := l_outputs(l_outputs.first).value;
              --
  elsif l_rule_type.formula_type_id = -544 then  -- contact level Rule
     -- Call formula initialise routine
     l_outputs := benutils.formula
                                (p_formula_id         => p_data_elmt_rl,
                                 p_effective_date     => ben_ext_person.g_benefits_ext_dt,
                                 p_assignment_id      => l_asg.assignment_id,
                                 p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                                 p_param1             => 'CONTACT_RELATIONSHIP_ID',
                                 p_param1_value       => to_char(ben_ext_person.g_contact_rlshp_id)
                                 --RChase pass extract definition id as input value
                                 ,p_param2             => 'EXT_DFN_ID'
                                 ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                                 ,p_param3             => 'EXT_RSLT_ID'
                                 ,p_param3_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                                 ,p_param4             => 'EXT_PROCESS_BUSINESS_GROUP'
                                 ,p_param4_value       =>  to_char(p_business_group_id)
                                 ,p_param5             => 'EXT_USER_VALUE'
                                 ,p_param5_value       =>  p_String_Val
                                );
              --
              l_rslt_elmt := l_outputs(l_outputs.first).value;
              --
  elsif l_rule_type.formula_type_id = -545 then  -- elig dpnt level Rule
     -- Call formula initialise routine
     l_outputs := benutils.formula
                                (p_formula_id         => p_data_elmt_rl,
                                 p_effective_date     => ben_ext_person.g_benefits_ext_dt,
                                 p_assignment_id      => l_asg.assignment_id,
                                 p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id),
                                 p_param1             => 'ELIG_DPNT_ID',
                                 p_param1_value       => to_char(ben_ext_person.g_elig_dpnt_id)
                                 --RChase pass extract definition id as input value
                                 ,p_param2             => 'EXT_DFN_ID'
                                 ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                                 ,p_param3             => 'EXT_RSLT_ID'
                                 ,p_param3_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                                 ,p_param4             => 'EXT_PROCESS_BUSINESS_GROUP'
                                 ,p_param4_value       =>  to_char(p_business_group_id)
                                 ,p_param5             => 'EXT_USER_VALUE'
                                 ,p_param5_value       =>  p_String_Val
                               );
              --
              l_rslt_elmt := l_outputs(l_outputs.first).value;

  elsif  l_rule_type.formula_type_id = -546 then    -- subheader level rule
     l_outputs := benutils.formula
                        (p_formula_id         => p_data_elmt_rl,
                         p_effective_date     => p_effective_date ,
                         p_business_group_id  => nvl(p_ext_per_bg_id,p_business_group_id)
                         ,p_param1             => 'EXT_DFN_ID'
                         ,p_param1_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                         ,p_param2             => 'EXT_RSLT_ID'
                         ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                         ,p_param3             => 'EXT_GROUP_VALUE_01'
                         ,p_param3_value       =>  ben_ext_person.g_group_elmt_value1
                         ,p_param4             => 'EXT_PROCESS_BUSINESS_GROUP'
                         ,p_param4_value       =>  to_char(p_business_group_id)
                         ,p_param5             => 'EXT_USER_VALUE'
                         ,p_param5_value       =>  p_String_Val
                        );

              l_rslt_elmt := l_outputs(l_outputs.first).value;

              --
  end if;

  -- format mask handling
  begin
     if substr(p_frmt_mask_lookup_cd,1,1) = 'N' then
        l_rslt_elmt_fmt := apply_format_mask(to_number(l_rslt_elmt), p_frmt_mask_cd);
        l_rslt_elmt := l_rslt_elmt_fmt;
     end if;
     if substr(p_frmt_mask_lookup_cd,1,1) = 'D' then
        l_rslt_elmt_fmt := apply_format_mask(fnd_date.canonical_to_date(l_rslt_elmt), p_frmt_mask_cd);
        l_rslt_elmt := l_rslt_elmt_fmt;
     end if ;
  exception  -- incase l_rslt_elmt is not valid for formatting, just don't format it.
     when others then
        null;
  end;
  --
  hr_utility.set_location('Exiting '||l_proc || ' with ' || l_rslt_elmt, 5) ;
  Return l_rslt_elmt ;


end Calculate_formula;


--
-- ----------------------------------------------------------------------------
-- |---------< Calcualte_calc_value >---------------------------------------------|
-- ----------------------------------------------------------------------------

function  Calculate_calc_value
                               (p_firtst_value   in number
                               ,p_second_value   in number
                               ,p_calc           in varchar2 ) return number  is
l_value  number ;
l_proc               varchar2(72) := g_package||'Calculate_calc_value';
l_err_message        varchar2(2000) := 'Zero Divide Error' ;
begin
  hr_utility.set_location('Entering'||l_proc, 5) ;
  hr_utility.set_location('p_firtst_value'||p_firtst_value, 5) ;
  hr_utility.set_location('p_second_value'||p_second_value, 5) ;
  hr_utility.set_location('p_calc '||p_calc , 5) ;

 if  p_calc  = 'ADD' then

    l_value :=  nvl(p_firtst_value,0)+ nvl(p_second_value,0) ;
 elsif p_calc  = 'SUB' then

    l_value :=  nvl(p_firtst_value,0)- nvl(p_second_value,0) ;

 elsif p_calc  = 'MLT' then
    if p_firtst_value is not null and p_second_value is not null then
       l_value :=  p_firtst_value* p_second_value ;
    elsif p_firtst_value is  null and p_second_value is  null then
       l_value := null ;
    else
       l_value :=  nvl(p_firtst_value,1)* nvl(p_second_value,1) ;
    end if ;

 elsif p_calc  = 'DIV' then

     if p_firtst_value is not null and p_second_value is not null then
       if p_second_value <>   0 then
         l_value :=  p_firtst_value/p_second_value ;
       else
           ben_ext_util.write_err
           (p_err_num => 92065
           ,p_err_name => l_err_message
           ,p_typ_cd => 'W'
           ,p_person_id => g_person_id
           ,p_request_id => ben_extract.g_request_id
           ,p_ext_rslt_id => ben_extract.g_ext_rslt_id
           ,p_business_group_id => ben_ext_person.g_business_group_id
           );
      --

          l_value := null ;
       end if ;
    elsif p_firtst_value is  null and p_second_value is  null then
        l_value := null ;
    elsif  p_firtst_value is not null then
        l_value :=  p_firtst_value ;
    else
        l_value := null ;
    end if ;
 end if ;

 hr_utility.set_location(' Exiting' ||l_value ||' :'||l_proc, 15);
 return l_value ;
end Calculate_calc_value ;


--
-- ----------------------------------------------------------------------------
-- |---------< get_calc_value >---------------------------------------------|
-- ----------------------------------------------------------------------------
function get_calc_value
                         (
                           p_seq_num              in  number
                         , p_ext_data_elmt_id     in  number
                         , p_data_elmt_typ_cd     in  varchar2
                         , p_name                 in  varchar2
                         , p_frmt_mask_cd         in  varchar2
                         , p_dflt_val             in  varchar2
                         , p_short_name           in  varchar2
                         , p_two_char_substr      in  varchar2
                         , p_one_char_substr      in  varchar2
                         , p_lookup_type          in  varchar2
                         , p_calc                 in  varchar2
                         , p_person_id            in  varchar2 default null
                         , p_ext_per_bg_id        in  number
                         , p_effective_date       in  date
                         , p_business_group_id    in  number
                         , p_frmt_mask_lookup_cd  in varchar2
                         , p_Ext_rcd_id           in number ) return varchar2 IS
--
 l_proc               varchar2(72) := g_package||'get_calc_value';
 l_lookup_type varchar2(30) := p_lookup_type  ;
 l_number                       varchar2(1);
 l_max_len                      integer ;
--
 l_rslt_elmt          varchar2(4000) ;
 l_rslt_calc          varchar2(4000) ;
 Cursor c_calc_elmt is
 select ewc.seq_num
       , xel.ext_data_elmt_id
       , xel.data_elmt_typ_cd
       , xel.data_elmt_rl
       , xel.name
       , xel.string_val
       , xel.dflt_val
       , xel.max_length_num
       , xel.frmt_mask_cd
       , xel.defined_balance_id
       , efl.short_name
       , substr(efl.short_name,1,2) two_char_substr
       , substr(efl.short_name,1,1) one_char_substr
 from ben_Ext_where_clause ewc,
      ben_Ext_data_elmt    xel,
      ben_ext_fld          efl
 where ewc.ext_data_elmt_id = p_ext_data_elmt_id
   and xel.ext_data_elmt_id = ewc.cond_ext_data_elmt_id
   and xel.ext_fld_id       = efl.ext_fld_id (+)  ;


 l_seq_num  ben_ext_data_elmt_in_rcd.seq_num%Type ;

 cursor c_seq (p_ext_rcd_id in number  ,
               p_ext_data_elmt_id in number) is
 select a.seq_num
 from ben_ext_data_elmt_in_rcd a
 where a.ext_rcd_id = p_ext_rcd_id
   and a.ext_data_elmt_id = p_ext_data_elmt_id ;

begin

    hr_utility.set_location('Entering'||l_proc, 5);
    for elmt in c_calc_elmt Loop

        open c_seq (p_ext_rcd_id , elmt.ext_data_elmt_id) ;
        fetch c_seq into l_seq_num ;
        close c_seq ;
        l_rslt_calc := null ;
        hr_utility.set_location (' sequence number ' || l_seq_num , 99) ;

        if nvl(p_seq_num,-1) > nvl(l_seq_num,0) and  g_val_tab(l_seq_num) is not null then
           l_rslt_calc  := g_val_tab(l_seq_num) ;
           hr_utility.set_location (' element inprev  calc val ' || g_val_tab(l_seq_num) , 99) ;

        else
           if elmt.data_elmt_typ_cd in ('F', 'D') then
               l_rslt_calc := get_element_value(
                                p_seq_num                 => elmt.seq_num
                              , p_ext_data_elmt_id        => elmt.ext_data_elmt_id
                              , p_data_elmt_typ_cd        => elmt.data_elmt_typ_cd
                              , p_name                    => elmt.name
                              , p_frmt_mask_cd            => null
                              , p_dflt_val                => elmt.dflt_val
                              , p_short_name              => elmt.short_name
                              , p_two_char_substr         => elmt.two_char_substr
                              , p_one_char_substr         => elmt.one_char_substr
                              , p_lookup_type             => p_lookup_type
                              );
            elsif elmt.data_elmt_typ_cd = 'R'then
                l_rslt_calc :=  Calculate_formula
                                   ( p_person_id           => p_person_id ,
                                     p_data_elmt_rl        => elmt.data_elmt_rl ,
                                     p_ext_per_bg_id       => p_ext_per_bg_id  ,
                                     p_String_val          => elmt.string_val,
                                     p_frmt_mask_lookup_cd => p_frmt_mask_lookup_cd,
                                     p_frmt_mask_cd        => elmt.frmt_mask_cd ,
                                     p_business_group_id   => p_business_group_id   ,
                                     p_effective_date      => p_effective_date ) ;
            elsif elmt.data_elmt_typ_cd = 'P'then

               if  ben_Ext_person.g_assignment_id is not  null then

                   l_rslt_calc := get_pay_balance(
                                           p_defined_balance_id   =>  elmt.defined_balance_id
                                          ,p_assignment_id        =>  ben_Ext_person.g_assignment_id
                                          ,p_effective_date       =>  p_effective_date
                                          ,p_business_group_id    =>  nvl(p_ext_per_bg_id,p_business_group_id)
                                          ) ;

               else
                  l_rslt_calc := null ;
               end if ;
               hr_utility.set_location (' element  val ' || l_rslt_calc  , 99) ;
           end if ;
         end if ;
         --- check for the number

         Begin
            l_rslt_calc := to_number(l_rslt_calc) ;
         exception
            when value_error then
               l_rslt_calc := null ;
         end ;

         if  l_rslt_elmt is null  then
             l_rslt_elmt := l_rslt_calc ;
             hr_utility.set_location(' first calc value :  '||l_rslt_elmt, 15);

         else
            if l_rslt_calc is not null then
               hr_utility.set_location(' firs and sec  calc value :  '||l_rslt_elmt || '  '|| l_rslt_calc , 15);
               l_rslt_elmt := Calculate_calc_value
                               (p_firtst_value   => to_number(l_rslt_elmt)
                               ,p_second_value   => l_rslt_calc
                               ,p_calc           => p_calc ) ;

               hr_utility.set_location(' return calcaulated alue :  '|| l_rslt_elmt , 15);

            end if ;
         end if ;

    end loop ;
    l_rslt_elmt := apply_format_mask(to_number(l_rslt_elmt), p_frmt_mask_cd);

   hr_utility.set_location(' Exiting:'||l_proc, 15);
   return l_rslt_elmt ;
end get_calc_value ;





--
-- ----------------------------------------------------------------------------
-- |---------< process_ext_recs >---------------------------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will process detail extract records of the given level.
-- For each record of the given level it will format it's data elements as
-- required and create a row in ben_ext_rslt_dtl with all the formatted values.
--
Procedure process_ext_recs(p_ext_rslt_id         in number,
                           p_ext_file_id         in number,
                           p_data_typ_cd         in varchar2,              -- F, C
                           p_ext_typ_cd          in varchar2,
                           p_rcd_typ_cd          in varchar2,              -- D S only
                           p_low_lvl_cd          in varchar2 default null, -- P, E, D
                           p_person_id           in number   default null,
                           p_chg_evt_cd          in varchar2 default null,
                           p_business_group_id   in number,
                           p_ext_per_bg_id       in number   default null ,
                           p_effective_date      in date
                           ) IS
--
  l_proc               varchar2(72) := g_package||'process_ext_recs';
--
  l_ext_rcd_id              number(15) := null;
  l_ext_rcd_in_file_id      number(15) := null;
  l_rslt_elmt               ben_ext_rslt_dtl.val_01%type  := null;
  l_rslt_elmt_fmt           ben_ext_rslt_dtl.val_01%type  := null;
--
  l_ext_rslt_dtl_id         number(15);
  l_object_version_number   number(15);
--
  l_trans_num               number(15);
--
  l_write_rcd               varchar2(1);
  l_dummy                   varchar2(1);
--
  l_prmy_sort_val           ben_ext_rslt_dtl.prmy_sort_val%type;
  l_scnd_sort_val           ben_ext_rslt_dtl.scnd_sort_val%type;
  l_thrd_sort_val           ben_ext_rslt_dtl.thrd_sort_val%type;
  l_exclude_this_rcd_flag   boolean := false;
  l_exclude_flag            boolean := false;
  l_lookup_type varchar2(30) := null; --Bug 2593220
--

   l_frmt_mask_cd               hr_lookups.meaning%type ;
   l_two_char_substr            varchar2(2) ;
   l_one_char_substr            varchar2(1) ;


   l_ext_data_elmt_in_rcd_id_va  t_number ;
   l_seq_num_va                  t_number ;
   l_sprs_cd_va                  t_varchar2_30  ;
   l_strt_pos_va                 t_number  ;
   l_dlmtr_val_va                t_varchar2_30  ;
   l_rqd_flag_va                 t_varchar2_30  ;
   l_ext_data_elmt_id_va         t_number ;
   l_data_elmt_typ_cd_va         t_varchar2_30 ;
   l_data_elmt_rl_va             t_number ;
   l_name_va                     t_varchar2_600  ;
   l_frmt_mask_lookup_cd_va      t_varchar2_30  ;
   l_string_val_va               t_varchar2_600  ;
   l_dflt_val_va                 t_varchar2_600  ;
   l_max_length_num_va           t_number ;
   l_just_cd_va                  t_varchar2_30  ;
   l_short_name_va               t_varchar2_30  ;
   l_ttl_fnctn_cd_va             t_varchar2_30  ;
   l_defined_balance_id_va       t_number  ;

  cursor rcd_elmt_c  is
     select  /*+ index(b) index(c) */
            a.ext_data_elmt_in_rcd_id
           , a.seq_num
           , a.sprs_cd
           , a.strt_pos
           , a.dlmtr_val
           , a.rqd_flag
           , b.ext_data_elmt_id
           , b.data_elmt_typ_cd
           , b.data_elmt_rl
           , b.name
           , b.frmt_mask_cd frmt_mask_lookup_cd
           , b.string_val
           , b.dflt_val
           , b.max_length_num
           , b.just_cd
           , c.short_name
           , ttl_fnctn_cd
           , defined_balance_id
    from
         ben_ext_fld                 c,
         ben_ext_data_elmt           b,
         ben_ext_data_elmt_in_rcd    a
    where
         a.ext_data_elmt_id = b.ext_data_elmt_id
    and  a.ext_rcd_id = l_ext_rcd_id
    and  b.ext_fld_id = c.ext_fld_id (+)
    order by a.seq_num;

    elmt  rcd_elmt_c%rowtype ;
  --
  --
  cursor c_rcd_in_file_flag(p_rcd_in_id  number ) is
  select rqd_flag , chg_rcd_upd_flag
  from ben_Ext_rcd_in_file
  where ext_rcd_in_file_id = p_rcd_in_id ;

  --

  l_rcd_rqd_flag        varchar2(1);
  l_chg_rcd_upd_flag    varchar2(1);
  l_ext_chg_rcd_mode    varchar2(1);
  --
  l_dummy_start_date             date;
  l_dummy_end_date               date;
  l_number                       varchar2(1);
  l_loop_count		         number := 0;
  l_jurisdiction_code            varchar2(30);
  l_max_len                      integer ;
  l_rollback                     boolean ;
--
-- Bug fix 2197144
  l_decimal_counter		 number := 0;
  l_ext_per_bg_id                number ;
--
begin
--

  hr_utility.set_location('Entering'||l_proc, 5);
  --
  g_person_id      := p_person_id;

  -- when subheader process the bg id is passed as parameter
  -- whne the detail record processed  this parameter is not
  -- passed
  l_ext_per_bg_id  := p_ext_per_bg_id  ;
  if p_rcd_typ_cd = 'D'  then
     l_ext_per_bg_id := ben_ext_person.g_business_group_id ;
  end if ;



     hr_utility.set_location('person_id '||g_person_id  , 5);
  -- Check for required record present
  --
  /*
  -- Check for required record

    FOR i IN
      ben_extract.gtt_rcd_rqd_vals.FIRST .. ben_extract.gtt_rcd_rqd_vals.LAST
    LOOP
    --
      IF ben_extract.gtt_rcd_rqd_vals(i).low_lvl_cd = p_low_lvl_cd
        OR ben_extract.gtt_rcd_rqd_vals(i).low_lvl_cd = 'NOREQDRCD'
      THEN
        ben_extract.gtt_rcd_rqd_vals(i).rcd_found := TRUE;
      END IF;
  --
  END LOOP;
  */

  -- For UK Legislation, set the lookup type as GB_COUNTY to
  -- get the County Name from fnd_common_lookups , Bug 2593220

  if nvl(hr_api.return_legislation_code(p_business_group_id),'NVL') = 'GB' then
    l_lookup_type := 'GB_COUNTY';
  end if;

  --
  -- assign transaction number
  --
  l_trans_num := ben_ext_person.g_trans_num;
  --
  -- This loop will be executed for each record in the extract definition
  -- of a given record type (Detail) and of a given level
  -- (Personal, Enrollment, Dependent), if applicable.
  --
  --
  --hr_utility.set_location(' format max ' || ben_extract.gtt_rcd_typ_vals.last,99);

  FOR i IN ben_extract.gtt_rcd_typ_vals.first .. ben_extract.gtt_rcd_typ_vals.last LOOP
    --
  --
  --hr_utility.set_location(' low level  ' ||ben_extract.gtt_rcd_typ_vals(i).low_lvl_cd,99);
    IF ben_extract.gtt_rcd_typ_vals(i).rcd_type_cd = p_rcd_typ_cd
    AND nvl(ben_extract.gtt_rcd_typ_vals(i).low_lvl_cd,' ') = nvl(p_low_lvl_cd, ' ')
    THEN

      l_write_rcd := 'Y';
      g_rqd_elmt_is_present := 'Y';
      --
      -- check record include/suppress condition
      --
      l_ext_rcd_id         := ben_extract.gtt_rcd_typ_vals(i).ext_rcd_id;
      l_ext_rcd_in_file_id := ben_extract.gtt_rcd_typ_vals(i).ext_rcd_in_file_id ;
      -- get the rqd flag in record level
      --  if the element is rquire and null skip the record
      --  if the record is rqd and null skipp the person
      open c_rcd_in_file_flag(ben_extract.gtt_rcd_typ_vals(i).ext_rcd_in_file_id) ;
      fetch c_rcd_in_file_flag into l_rcd_rqd_flag ,l_chg_rcd_upd_flag ;
      close c_rcd_in_file_flag ;
      -- Initialize array
      --

      hr_utility.set_location('l_rcd_rqd_flag'|| l_rcd_rqd_flag,10);
      g_val_tab := g_val_def;
      --
      open rcd_elmt_c ;
      fetch rcd_elmt_c bulk collect into
               l_ext_data_elmt_in_rcd_id_va   ,
               l_seq_num_va              ,
               l_sprs_cd_va               ,
               l_strt_pos_va              ,
               l_dlmtr_val_va             ,
               l_rqd_flag_va              ,
               l_ext_data_elmt_id_va     ,
               l_data_elmt_typ_cd_va     ,
               l_data_elmt_rl_va         ,
               l_name_va                  ,
               l_frmt_mask_lookup_cd_va   ,
               l_string_val_va            ,
               l_dflt_val_va              ,
               l_max_length_num_va       ,
               l_just_cd_va               ,
               l_short_name_va            ,
               l_ttl_fnctn_cd_va          ,
               l_defined_balance_id_va    ;
      close rcd_elmt_c ;

      for i  IN  1  .. l_ext_data_elmt_in_rcd_id_va.count
      LOOP

         l_frmt_mask_cd     := null ;
         l_two_char_substr  := null ;
         l_one_char_substr  := null ;
         elmt := null ;


         elmt.ext_data_elmt_in_rcd_id :=  l_ext_data_elmt_in_rcd_id_va(i)   ;
         elmt.seq_num                 :=  l_seq_num_va(i)              ;
         elmt.sprs_cd                 :=  l_sprs_cd_va(i)              ;
         elmt.strt_pos                :=  l_strt_pos_va(i)             ;
         elmt.dlmtr_val               :=  l_dlmtr_val_va(i)            ;
         elmt.rqd_flag                :=  l_rqd_flag_va(i)             ;
         elmt.ext_data_elmt_id        :=  l_ext_data_elmt_id_va(i)     ;
         elmt.data_elmt_typ_cd        :=  l_data_elmt_typ_cd_va(i)     ;
         elmt.data_elmt_rl            :=  l_data_elmt_rl_va(i)         ;
         elmt.name                    :=  l_name_va(i)                 ;
         elmt.frmt_mask_lookup_cd     :=  l_frmt_mask_lookup_cd_va(i)  ;
         elmt.string_val              :=  l_string_val_va(i)           ;
         elmt.dflt_val                :=  l_dflt_val_va(i)             ;
         elmt.max_length_num          :=  l_max_length_num_va(i)       ;
         elmt.just_cd                 :=  l_just_cd_va(i)              ;
         elmt.short_name              :=  l_short_name_va(i)           ;
         elmt.ttl_fnctn_cd            :=  l_ttl_fnctn_cd_va(i)         ;
         elmt.defined_balance_id      :=  l_defined_balance_id_va(i)   ;

         if elmt.frmt_mask_lookup_cd is not null then
           l_frmt_mask_cd := hr_general.decode_lookup('BEN_EXT_FRMT_MASK',
                                      elmt.frmt_mask_lookup_cd ) ;
         end if ;

         if  elmt.short_name is not null then
             l_two_char_substr := substr(elmt.short_name,1,2) ;
             l_one_char_substr := substr(elmt.short_name,1,1) ;

         end if ;

         if g_debug then
             hr_utility.set_location('short name '||elmt.short_name,90);
             hr_utility.set_location(' defined_balance_id '||elmt.defined_balance_id,90);
             hr_utility.set_location(' ttl_fnctn_cd '||elmt.ttl_fnctn_cd,90);
             hr_utility.set_location(' one_char_substr '||l_one_char_substr,90);
             hr_utility.set_location(' two_char_substr '||l_two_char_substr,90);
             hr_utility.set_location(' name '||elmt.name,90);
             hr_utility.set_location(' dflt_val '||elmt.dflt_val,90);
             hr_utility.set_location(' frmt_mask_lookup_cd '||elmt.frmt_mask_lookup_cd,90);
             hr_utility.set_location(' frmt_mask_cd '||l_frmt_mask_cd,90);
             hr_utility.set_location(' seq_num '||elmt.seq_num,90);
             hr_utility.set_location(' seq_num '||elmt.seq_num,90);


         end if ;
        --
        l_rslt_elmt := null;
        --
        -- check field include/suppress condition
        --
        g_elmt_name := elmt.name ;
        hr_utility.set_location('ELEMENT '||elmt.short_name,10);
        hr_utility.set_location('Type Code '||elmt.data_elmt_typ_cd,10);

        IF elmt.data_elmt_typ_cd in ('F','D') THEN
          --
          -- data element is a field:
             l_rslt_elmt := get_element_value(
                               p_seq_num                 => elmt.seq_num
                              , p_ext_data_elmt_id        => elmt.ext_data_elmt_id
                              , p_data_elmt_typ_cd        => elmt.data_elmt_typ_cd
                              , p_name                    => elmt.name
                              , p_frmt_mask_cd            => l_frmt_mask_cd
                              , p_dflt_val                => elmt.dflt_val
                              , p_short_name              => elmt.short_name
                              , p_two_char_substr         => l_two_char_substr
                              , p_one_char_substr         => l_one_char_substr
                              , p_lookup_type             => l_lookup_type
                              , p_frmt_mask_lookup_cd     => elmt.frmt_mask_lookup_cd  );
             --- if the requird lement is not null and return value is null exit
             if g_rqd_elmt_is_present = 'N' and l_rslt_elmt is  null then
                exit ;
             end if ;

            --- decide the grouping element subhead
            if ben_ext_thread.g_ext_group_elmt1 is not null then
               hr_utility.set_location(' GROUP ' || ben_ext_thread.g_ext_group_elmt1 || ' / ' ||elmt.short_name , 99 ) ;
               if ben_ext_thread.g_ext_group_elmt1 = elmt.short_name then
                  ben_ext_person.g_group_elmt_value1  :=  l_rslt_elmt ;
               end if ;
               if ben_ext_thread.g_ext_group_elmt2 is not null then
                  if ben_ext_thread.g_ext_group_elmt2 = elmt.short_name then
                     ben_ext_person.g_group_elmt_value2  :=  l_rslt_elmt ;
                  end if ;
               else
                  if p_rcd_typ_cd = 'S' then
                     ben_ext_person.g_group_elmt_value2  := '   ' ;
                  else
                      ben_ext_person.g_group_elmt_value2  :=  null ;
                  end if ;
               end if ;
               hr_utility.set_location(' GROUP  value ' || ben_ext_person.g_group_elmt_value1  , 99 ) ;
            else
               if p_rcd_typ_cd = 'S' then
                  ben_ext_person.g_group_elmt_value1  :=  '   ' ;
                  ben_ext_person.g_group_elmt_value2  :=  '   ' ;
               else
                  ben_ext_person.g_group_elmt_value1  :=  null ;
                  ben_ext_person.g_group_elmt_value2  :=  null ;
               end if ;
            end if ;

            --
            if  p_rcd_typ_cd <> 'S' and ben_ext_person.g_group_elmt_value1 =  '   '  then
                 ben_ext_person.g_group_elmt_value1 := null;
                 ben_ext_person.g_group_elmt_value2 := null;
            end if ;
            if  p_rcd_typ_cd <> 'S' and ben_ext_person.g_group_elmt_value2 =  '   '  then
                 ben_ext_person.g_group_elmt_value2 := null;
            end if ;
            --- eof subhead



          ELSIF elmt.data_elmt_typ_cd  ='C' THEN
          --
          -- data element is a calcualtion:
             l_rslt_elmt := get_calc_value(
                                p_seq_num                 => elmt.seq_num
                              , p_ext_data_elmt_id        => elmt.ext_data_elmt_id
                              , p_data_elmt_typ_cd        => elmt.data_elmt_typ_cd
                              , p_name                    => elmt.name
                              , p_frmt_mask_cd            => l_frmt_mask_cd
                              , p_dflt_val                => elmt.dflt_val
                              , p_short_name              => elmt.short_name
                              , p_two_char_substr         => l_two_char_substr
                              , p_one_char_substr         => l_one_char_substr
                              , p_lookup_type             => l_lookup_type
                              , p_calc                    => elmt.ttl_fnctn_cd
                              , p_person_id               => p_person_id
                              , p_ext_per_bg_id           => l_ext_per_bg_id
                              , p_effective_date          => p_effective_date
                              , p_business_group_id       => p_business_group_id
                              , p_frmt_mask_lookup_cd     => elmt.frmt_mask_lookup_cd
                              , p_ext_rcd_id              => l_ext_rcd_id
                              );
             --- if the requird lement is not null and return value is null exit
             if g_rqd_elmt_is_present = 'N' and l_rslt_elmt is  null then
                exit ;
             end if ;

          --
          ELSIF elmt.data_elmt_typ_cd = 'R' THEN
          --

               l_rslt_elmt :=  Calculate_formula
                                   ( p_person_id           => p_person_id ,
                                     p_data_elmt_rl        => elmt.data_elmt_rl ,
                                     p_ext_per_bg_id       => l_ext_per_bg_id  ,
                                     p_String_val          => elmt.string_val,
                                     p_frmt_mask_lookup_cd => elmt.frmt_mask_lookup_cd,
                                     p_frmt_mask_cd        => l_frmt_mask_cd ,
                                     p_business_group_id   => p_business_group_id   ,
                                     p_effective_date      => p_effective_date ) ;



          ELSIF elmt.data_elmt_typ_cd = 'S' THEN
            --
            -- data element is a string:
            -- ---------------------------------------------------------
            l_rslt_elmt := elmt.string_val;
            ---if the max Lenght defined , sixe the string as per
            --- the max_string , the function down use the max lengh
            --- use the min of lenght and max lenght so format here only
            if   elmt.max_length_num is not null then
                l_rslt_elmt := rpad(nvl(l_rslt_elmt,' '),elmt.max_length_num);
                hr_utility.set_location(' string max lenght '|| l_rslt_elmt,100 );
            end if ;

          ELSIF elmt.data_elmt_typ_cd = 'P' THEN
            -- payroll balance
            hr_utility.set_location(' payroll balance id  '|| elmt.defined_balance_id  ,100 );
            -- l_rslt_elmt :=  '00.00';
            -- format mask handlinga
            if  ben_Ext_person.g_assignment_id is not  null then
                l_rslt_elmt := get_pay_balance(
                                           p_defined_balance_id   =>  elmt.defined_balance_id
                                          ,p_assignment_id        =>  ben_Ext_person.g_assignment_id
                                          ,p_effective_date       =>  p_effective_date
                                          ,p_business_group_id    =>  nvl(l_ext_per_bg_id,p_business_group_id)
                                          ) ;

                begin
                  if substr(elmt.frmt_mask_lookup_cd,1,1) = 'N' then
                     l_rslt_elmt_fmt := apply_format_mask(to_number(l_rslt_elmt), l_frmt_mask_cd);
                     l_rslt_elmt := l_rslt_elmt_fmt;
                  end if;
                  if substr(elmt.frmt_mask_lookup_cd,1,1) = 'D' then
                     l_rslt_elmt_fmt:=apply_format_mask(fnd_date.canonical_to_date(l_rslt_elmt),l_frmt_mask_cd);
                     l_rslt_elmt := l_rslt_elmt_fmt;
                  end if ;
                exception  -- incase l_rslt_elmt is not valid for formatting, just don't format it.
                  when others then
                    null;
                end;
            end if ;
            hr_utility.set_location(' payroll balance '|| l_rslt_elmt,100 );

          END IF;
            --
            -- if resulting data element (field) is null, substitute it with
            -- default value
            --
          IF elmt.data_elmt_typ_cd in ('F','R' ,'P' ) and l_rslt_elmt is null then
            --
            l_rslt_elmt := elmt.dflt_val;
            --
          END IF;

          ---
          --
          -- truncate data element
          --
          IF elmt.max_length_num is not null THEN
            --
            l_max_len := least (length(l_rslt_elmt),elmt.max_length_num) ;
            -- numbers should always trunc from the left
            if substr(elmt.frmt_mask_lookup_cd,1,1) = 'N' then
              l_rslt_elmt := SUBSTR(l_rslt_elmt, -l_max_len);
            else  -- everything else truncs from the right.
              l_rslt_elmt := SUBSTR(l_rslt_elmt, 1, elmt.max_length_num);
            end if;
            hr_utility.set_location(' after  max lenght '|| l_rslt_elmt,100 );
            --
          END IF;
          --
          --
          -- if data element is mandatory, but l_rslt_elmt is null then
          -- exit the procedure, raise detail error
          -- exit the record not the person
          IF elmt.rqd_flag = 'Y' and (l_rslt_elmt is null) then
            --
            ben_ext_person.g_elmt_name := g_elmt_name ;
            ben_ext_person.g_err_num := 91887;
            ben_ext_person.g_err_name := 'BEN_91887_EXT_RQD_DATA_ELMT';
            -- raise ben_ext_person.detail_error;
            g_rqd_elmt_is_present := 'N' ;
            exit ;
            --
          END IF;
          --
        g_val_tab(elmt.seq_num) := l_rslt_elmt;
        --
        --
        if p_data_typ_cd = 'C' then  -- changes only extract
          --
          ben_ext_adv_conditions.chg_evt_incl
             (p_ext_data_elmt_in_rcd_id => elmt.ext_data_elmt_in_rcd_id,
              p_data_elmt_seq_num => elmt.seq_num,
              p_chg_evt_cd => p_chg_evt_cd,
              p_exclude_flag => l_exclude_flag);
          --
          if l_exclude_flag = true then
             g_val_tab(elmt.seq_num) := null;
          end if;
          --
        end if;
        --
      END LOOP;
      --
      if g_rqd_elmt_is_present = 'Y' then
         ben_ext_adv_conditions.data_elmt_in_rcd
           (p_ext_rcd_id => l_ext_rcd_id,
            p_exclude_this_rcd_flag => l_exclude_this_rcd_flag);
         --
         if l_exclude_this_rcd_flag = true then
            l_write_rcd := 'N';
         end if;
           --
         if l_write_rcd = 'Y' then
           ben_ext_adv_conditions.rcd_in_file
              (p_ext_rcd_in_file_id => ben_extract.gtt_rcd_typ_vals(i).ext_rcd_in_file_id,
               p_sprs_cd => ben_extract.gtt_rcd_typ_vals(i).sprs_cd,
               p_exclude_this_rcd_flag => l_exclude_this_rcd_flag);
           --
           if l_exclude_this_rcd_flag = true then
           l_write_rcd := 'N';
           end if;
           --
         end if;
         --
         if l_write_rcd = 'Y' and p_data_typ_cd = 'C' then -- changes only extract
           ben_ext_adv_conditions.chg_evt_incl
                (p_ext_rcd_in_file_id => ben_extract.gtt_rcd_typ_vals(i).ext_rcd_in_file_id,
                 p_rcd_seq_num => ben_extract.gtt_rcd_typ_vals(i).seq_num,
                 p_chg_evt_cd => p_chg_evt_cd,
                 p_exclude_flag => l_exclude_flag);
           --
           if l_exclude_flag = true then
              l_write_rcd := 'N';
           end if;
         end if;
         -- mandatory validation moved from the prevent duplication
         if l_write_rcd = 'Y' then
            -- check the mandatroy in seq and low level
            -- prevent duplication should not have any effect on
            -- required flag validation prevent is valdiated because the record is found

            FOR rci IN
               ben_extract.gtt_rcd_rqd_vals_seq.FIRST .. ben_extract.gtt_rcd_rqd_vals_seq.LAST
               LOOP
               --
               IF (   ben_extract.gtt_rcd_rqd_vals_seq(rci).low_lvl_cd = p_low_lvl_cd
                  and ben_extract.gtt_rcd_rqd_vals_seq(rci).seq_num    = ben_extract.gtt_rcd_typ_vals(i).seq_num
                  )
                  OR ben_extract.gtt_rcd_rqd_vals_seq(rci).low_lvl_cd = 'NOREQDRCD'
                  THEN
                  hr_utility.set_location('mandatory found' || p_low_lvl_cd , 99 );
                  hr_utility.set_location('mandatory found' || ben_extract.gtt_rcd_typ_vals(i).seq_num , 99 );
                  ben_extract.gtt_rcd_rqd_vals_seq(rci).rcd_found := TRUE;
               END IF;
            END LOOP ;

         end if ;
         --

         if l_write_rcd = 'Y' then
           ben_ext_adv_conditions.prevent_duplicates
             (p_ext_rslt_id => p_ext_rslt_id,
              p_person_id => p_person_id,
              p_any_or_all_cd => ben_extract.gtt_rcd_typ_vals(i).any_or_all_cd,
              p_ext_rcd_id => l_ext_rcd_id,
              p_exclude_this_rcd_flag => l_exclude_this_rcd_flag);
           --
           if l_exclude_this_rcd_flag = true then
              l_write_rcd := 'N';
           end if;
           --
         end if;
         --
         if l_write_rcd = 'Y' then


            --
             -- the following sort routine populates the l_..._sort_val fields
             --
             ben_ext_sort.main
                               (p_ext_rcd_in_file_id         => ben_extract.gtt_rcd_typ_vals(i).ext_rcd_in_file_id,
                                p_sort1_data_elmt_in_rcd_id  => ben_extract.gtt_rcd_typ_vals(i).sort1,
                                p_sort2_data_elmt_in_rcd_id  => ben_extract.gtt_rcd_typ_vals(i).sort2,
                                p_sort3_data_elmt_in_rcd_id  => ben_extract.gtt_rcd_typ_vals(i).sort3,
                                p_sort4_data_elmt_in_rcd_id  => ben_extract.gtt_rcd_typ_vals(i).sort4,
                                p_rcd_seq_num                => ben_extract.gtt_rcd_typ_vals(i).seq_num,
                                p_low_lvl_cd                 => p_low_lvl_cd,
	                        p_prmy_sort_val              => l_prmy_sort_val,
                                p_scnd_sort_val              => l_scnd_sort_val,
                                p_thrd_sort_val              => l_thrd_sort_val);


            --- if the record is sub header send  space as sorting vale
            if  p_rcd_typ_cd = 'S'  then
                l_prmy_sort_val := '   '  ;
                --l_scnd_sort_val := '   '  ;
            end if ;

            --
            hr_utility.set_location( ' l_chg_rcd_upd_flag ' || p_data_typ_cd || ' / ' || l_chg_rcd_upd_flag, 99 ) ;
            l_ext_chg_rcd_mode := 'C' ;
            if  p_data_typ_cd  = 'C'  and  l_chg_rcd_upd_flag = 'Y'  then
               -- of the record to be sonsoldated for change event extract

                ben_ext_adv_conditions.chg_rcd_merge
                         (p_ext_rslt_dtl_id            =>  l_ext_rslt_dtl_id
                         ,p_ext_rslt_id                =>  p_ext_rslt_id
                         ,p_ext_rcd_id                 =>  l_ext_rcd_id
                         ,p_person_id                  =>  p_person_id
                         ,p_business_group_id          =>  p_business_group_id
                         ,p_val_01                     =>  g_val_tab(1)
                         ,p_val_02                     =>  g_val_tab(2)
                         ,p_val_03                     =>  g_val_tab(3)
                         ,p_val_04                     =>  g_val_tab(4)
                         ,p_val_05                     =>  g_val_tab(5)
                         ,p_val_06                     =>  g_val_tab(6)
                         ,p_val_07                     =>  g_val_tab(7)
                         ,p_val_08                     =>  g_val_tab(8)
                         ,p_val_09                     =>  g_val_tab(9)
                         ,p_val_10                     =>  g_val_tab(10)
                         ,p_val_11                     =>  g_val_tab(11)
                         ,p_val_12                     =>  g_val_tab(12)
                         ,p_val_13                     =>  g_val_tab(13)
                         ,p_val_14                     =>  g_val_tab(14)
                         ,p_val_15                     =>  g_val_tab(15)
                         ,p_val_16                     =>  g_val_tab(16)
                         ,p_val_17                     =>  g_val_tab(17)
                         ,p_val_18                     =>  g_val_tab(18)
                         ,p_val_19                     =>  g_val_tab(19)
                         ,p_val_20                     =>  g_val_tab(20)
                         ,p_val_21                     =>  g_val_tab(21)
                         ,p_val_22                     =>  g_val_tab(22)
                         ,p_val_23                     =>  g_val_tab(23)
                         ,p_val_24                     =>  g_val_tab(24)
                         ,p_val_25                     =>  g_val_tab(25)
                         ,p_val_26                     =>  g_val_tab(26)
                         ,p_val_27                     =>  g_val_tab(27)
                         ,p_val_28                     =>  g_val_tab(28)
                         ,p_val_29                     =>  g_val_tab(29)
                         ,p_val_30                     =>  g_val_tab(30)
                         ,p_val_31                     =>  g_val_tab(31)
                         ,p_val_32                     =>  g_val_tab(32)
                         ,p_val_33                     =>  g_val_tab(33)
                         ,p_val_34                     =>  g_val_tab(34)
                         ,p_val_35                     =>  g_val_tab(35)
                         ,p_val_36                     =>  g_val_tab(36)
                         ,p_val_37                     =>  g_val_tab(37)
                         ,p_val_38                     =>  g_val_tab(38)
                         ,p_val_39                     =>  g_val_tab(39)
                         ,p_val_40                     =>  g_val_tab(40)
                         ,p_val_41                     =>  g_val_tab(41)
                         ,p_val_42                     =>  g_val_tab(42)
                         ,p_val_43                     =>  g_val_tab(43)
                         ,p_val_44                     =>  g_val_tab(44)
                         ,p_val_45                     =>  g_val_tab(45)
                         ,p_val_46                     =>  g_val_tab(46)
                         ,p_val_47                     =>  g_val_tab(47)
                         ,p_val_48                     =>  g_val_tab(48)
                         ,p_val_49                     =>  g_val_tab(49)
                         ,p_val_50                     =>  g_val_tab(50)
                         ,p_val_51                     =>  g_val_tab(51)
                         ,p_val_52                     =>  g_val_tab(52)
                         ,p_val_53                     =>  g_val_tab(53)
                         ,p_val_54                     =>  g_val_tab(54)
                         ,p_val_55                     =>  g_val_tab(55)
                         ,p_val_56                     =>  g_val_tab(56)
                         ,p_val_57                     =>  g_val_tab(57)
                         ,p_val_58                     =>  g_val_tab(58)
                         ,p_val_59                     =>  g_val_tab(59)
                         ,p_val_60                     =>  g_val_tab(60)
                         ,p_val_61                     =>  g_val_tab(61)
                         ,p_val_62                     =>  g_val_tab(62)
                         ,p_val_63                     =>  g_val_tab(63)
                         ,p_val_64                     =>  g_val_tab(64)
                         ,p_val_65                     =>  g_val_tab(65)
                         ,p_val_66                     =>  g_val_tab(66)
                         ,p_val_67                     =>  g_val_tab(67)
                         ,p_val_68                     =>  g_val_tab(68)
                         ,p_val_69                     =>  g_val_tab(69)
                         ,p_val_70                     =>  g_val_tab(70)
                         ,p_val_71                     =>  g_val_tab(71)
                         ,p_val_72                     =>  g_val_tab(72)
                         ,p_val_73                     =>  g_val_tab(73)
                         ,p_val_74                     =>  g_val_tab(74)
                         ,p_val_75                     =>  g_val_tab(75)
                         ,p_val_76                     =>  g_val_tab(76)
                         ,p_val_77                     =>  g_val_tab(77)
                         ,p_val_78                     =>  g_val_tab(78)
                         ,p_val_79                     =>  g_val_tab(79)
                         ,p_val_80                     =>  g_val_tab(80)
                         ,p_val_81                     =>  g_val_tab(81)
                         ,p_val_82                     =>  g_val_tab(82)
                         ,p_val_83                     =>  g_val_tab(83)
                         ,p_val_84                     =>  g_val_tab(84)
                         ,p_val_85                     =>  g_val_tab(85)
                         ,p_val_86                     =>  g_val_tab(86)
                         ,p_val_87                     =>  g_val_tab(87)
                         ,p_val_88                     =>  g_val_tab(88)
                         ,p_val_89                     =>  g_val_tab(89)
                         ,p_val_90                     =>  g_val_tab(90)
                         ,p_val_91                     =>  g_val_tab(91)
                         ,p_val_92                     =>  g_val_tab(92)
                         ,p_val_93                     =>  g_val_tab(93)
                         ,p_val_94                     =>  g_val_tab(94)
                         ,p_val_95                     =>  g_val_tab(95)
                         ,p_val_96                     =>  g_val_tab(96)
                         ,p_val_97                     =>  g_val_tab(97)
                         ,p_val_98                     =>  g_val_tab(98)
                         ,p_val_99                     =>  g_val_tab(99)
                         ,p_val_100                    =>  g_val_tab(100)
                         ,p_val_101                    =>  g_val_tab(101)
                         ,p_val_102                    =>  g_val_tab(102)
                         ,p_val_103                    =>  g_val_tab(103)
                         ,p_val_104                    =>  g_val_tab(104)
                         ,p_val_105                    =>  g_val_tab(105)
                         ,p_val_106                    =>  g_val_tab(106)
                         ,p_val_107                    =>  g_val_tab(107)
                         ,p_val_108                    =>  g_val_tab(108)
                         ,p_val_109                    =>  g_val_tab(109)
                         ,p_val_110                    =>  g_val_tab(110)
                         ,p_val_111                    =>  g_val_tab(111)
                         ,p_val_112                    =>  g_val_tab(112)
                         ,p_val_113                    =>  g_val_tab(113)
                         ,p_val_114                    =>  g_val_tab(114)
                         ,p_val_115                    =>  g_val_tab(115)
                         ,p_val_116                    =>  g_val_tab(116)
                         ,p_val_117                    =>  g_val_tab(117)
                         ,p_val_118                    =>  g_val_tab(118)
                         ,p_val_119                    =>  g_val_tab(119)
                         ,p_val_120                    =>  g_val_tab(120)
                         ,p_val_121                    =>  g_val_tab(121)
                         ,p_val_122                    =>  g_val_tab(122)
                         ,p_val_123                    =>  g_val_tab(123)
                         ,p_val_124                    =>  g_val_tab(124)
                         ,p_val_125                    => g_val_tab(125)
                         ,p_val_126                    =>  g_val_tab(126)
                         ,p_val_127                    =>  g_val_tab(127)
                         ,p_val_128                    =>  g_val_tab(128)
                         ,p_val_129                    =>  g_val_tab(129)
                         ,p_val_130                    =>  g_val_tab(130)
                         ,p_val_131                    =>  g_val_tab(131)
                         ,p_val_132                    =>  g_val_tab(132)
                         ,p_val_133                    =>  g_val_tab(133)
                         ,p_val_134                    =>  g_val_tab(134)
                         ,p_val_135                    =>  g_val_tab(135)
                         ,p_val_136                    =>  g_val_tab(136)
                         ,p_val_137                    =>  g_val_tab(137)
                         ,p_val_138                    =>  g_val_tab(138)
                         ,p_val_139                    =>  g_val_tab(139)
                         ,p_val_140                    =>  g_val_tab(140)
                         ,p_val_141                    =>  g_val_tab(141)
                         ,p_val_142                    =>  g_val_tab(142)
                         ,p_val_143                    =>  g_val_tab(143)
                         ,p_val_144                    =>  g_val_tab(144)
                         ,p_val_145                    =>  g_val_tab(145)
                         ,p_val_146                    =>  g_val_tab(146)
                         ,p_val_147                    =>  g_val_tab(147)
                         ,p_val_148                    =>  g_val_tab(148)
                         ,p_val_149                    =>  g_val_tab(149)
                         ,p_val_150                    =>  g_val_tab(150)
                         ,p_val_151                    =>  g_val_tab(151)
                         ,p_val_152                    =>  g_val_tab(152)
                         ,p_val_153                    =>  g_val_tab(153)
                         ,p_val_154                    =>  g_val_tab(154)
                         ,p_val_155                    =>  g_val_tab(155)
                         ,p_val_156                    =>  g_val_tab(156)
                         ,p_val_157                    =>  g_val_tab(157)
                         ,p_val_158                    =>  g_val_tab(158)
                         ,p_val_159                    =>  g_val_tab(159)
                         ,p_val_160                    =>  g_val_tab(160)
                         ,p_val_161                    =>  g_val_tab(161)
                         ,p_val_162                    =>  g_val_tab(162)
                         ,p_val_163                    =>  g_val_tab(163)
                         ,p_val_164                    =>  g_val_tab(164)
                         ,p_val_165                    =>  g_val_tab(165)
                         ,p_val_166                    =>  g_val_tab(166)
                         ,p_val_167                    =>  g_val_tab(167)
                         ,p_val_168                    =>  g_val_tab(168)
                         ,p_val_169                    => g_val_tab(169)
                         ,p_val_170                    =>  g_val_tab(170)
                         ,p_val_171                    =>  g_val_tab(171)
                         ,p_val_172                    =>  g_val_tab(172)
                         ,p_val_173                    =>  g_val_tab(173)
                         ,p_val_174                    =>  g_val_tab(174)
                         ,p_val_175                    =>  g_val_tab(175)
                         ,p_val_176                    =>  g_val_tab(176)
                         ,p_val_177                    =>  g_val_tab(177)
                         ,p_val_178                    =>  g_val_tab(178)
                         ,p_val_179                    =>  g_val_tab(179)
                         ,p_val_180                    =>  g_val_tab(180)
                         ,p_val_181                    =>  g_val_tab(181)
                         ,p_val_182                    =>  g_val_tab(182)
                         ,p_val_183                    =>  g_val_tab(183)
                         ,p_val_184                    =>  g_val_tab(184)
                         ,p_val_185                    =>  g_val_tab(185)
                         ,p_val_186                    =>  g_val_tab(186)
                         ,p_val_187                    =>  g_val_tab(187)
                         ,p_val_188                    =>  g_val_tab(188)
                         ,p_val_189                    =>  g_val_tab(189)
                         ,p_val_190                    =>  g_val_tab(190)
                         ,p_val_191                    =>  g_val_tab(191)
                         ,p_val_192                    =>  g_val_tab(192)
                         ,p_val_193                    =>  g_val_tab(193)
                         ,p_val_194                    =>  g_val_tab(194)
                         ,p_val_195                    => g_val_tab(195)
                         ,p_val_196                    =>  g_val_tab(196)
                         ,p_val_197                    =>  g_val_tab(197)
                         ,p_val_198                    =>  g_val_tab(198)
                         ,p_val_199                    =>  g_val_tab(199)
                         ,p_val_200                    =>  g_val_tab(200)
                         ,p_val_201                    =>  g_val_tab(201)
                         ,p_val_202                    =>  g_val_tab(202)
                         ,p_val_203                    =>  g_val_tab(203)
                         ,p_val_204                    =>  g_val_tab(204)
                         ,p_val_205                    =>  g_val_tab(205)
                         ,p_val_206                    =>  g_val_tab(206)
                         ,p_val_207                    =>  g_val_tab(207)
                         ,p_val_208                    =>  g_val_tab(208)
                         ,p_val_209                    =>  g_val_tab(209)
                         ,p_val_210                    =>  g_val_tab(210)
                         ,p_val_211                    =>  g_val_tab(211)
                         ,p_val_212                    =>  g_val_tab(212)
                         ,p_val_213                    =>  g_val_tab(213)
                         ,p_val_214                    =>  g_val_tab(214)
                         ,p_val_215                    =>  g_val_tab(215)
                         ,p_val_216                    =>  g_val_tab(216)
                         ,p_val_217                    =>  g_val_tab(217)
                         ,p_val_218                    =>  g_val_tab(218)
                         ,p_val_219                    =>  g_val_tab(219)
                         ,p_val_220                    =>  g_val_tab(220)
                         ,p_val_221                    =>  g_val_tab(221)
                         ,p_val_222                    =>  g_val_tab(222)
                         ,p_val_223                    =>  g_val_tab(223)
                         ,p_val_224                    =>  g_val_tab(224)
                         ,p_val_225                    =>  g_val_tab(225)
                         ,p_val_226                    =>  g_val_tab(226)
                         ,p_val_227                    =>  g_val_tab(227)
                         ,p_val_228                    =>  g_val_tab(228)
                         ,p_val_229                    =>  g_val_tab(229)
                         ,p_val_230                    =>  g_val_tab(230)
                         ,p_val_231                    =>  g_val_tab(231)
                         ,p_val_232                    =>  g_val_tab(232)
                         ,p_val_233                    =>  g_val_tab(233)
                         ,p_val_234                    =>  g_val_tab(234)
                         ,p_val_235                    =>  g_val_tab(235)
                         ,p_val_236                    =>  g_val_tab(236)
                         ,p_val_237                    =>  g_val_tab(237)
                         ,p_val_238                    =>  g_val_tab(238)
                         ,p_val_239                    =>  g_val_tab(239)
                         ,p_val_240                    =>  g_val_tab(240)
                         ,p_val_241                    =>  g_val_tab(241)
                         ,p_val_242                    =>  g_val_tab(242)
                         ,p_val_243                    =>  g_val_tab(243)
                         ,p_val_244                    =>  g_val_tab(244)
                         ,p_val_245                    =>  g_val_tab(245)
                         ,p_val_246                    =>  g_val_tab(246)
                         ,p_val_247                    =>  g_val_tab(247)
                         ,p_val_248                    =>  g_val_tab(248)
                         ,p_val_249                    =>  g_val_tab(249)
                         ,p_val_250                    =>  g_val_tab(250)
                         ,p_val_251                    =>  g_val_tab(251)
                         ,p_val_252                    =>  g_val_tab(252)
                         ,p_val_253                    =>  g_val_tab(253)
                         ,p_val_254                    =>  g_val_tab(254)
                         ,p_val_255                    =>  g_val_tab(255)
                         ,p_val_256                    =>  g_val_tab(256)
                         ,p_val_257                    =>  g_val_tab(257)
                         ,p_val_258                    =>  g_val_tab(258)
                         ,p_val_259                    =>  g_val_tab(259)
                         ,p_val_260                    =>  g_val_tab(260)
                         ,p_val_261                    =>  g_val_tab(261)
                         ,p_val_262                    =>  g_val_tab(262)
                         ,p_val_263                    =>  g_val_tab(263)
                         ,p_val_264                    =>  g_val_tab(264)
                         ,p_val_265                    =>  g_val_tab(265)
                         ,p_val_266                    =>  g_val_tab(266)
                         ,p_val_267                    =>  g_val_tab(267)
                         ,p_val_268                    =>  g_val_tab(268)
                         ,p_val_269                    =>  g_val_tab(269)
                         ,p_val_270                    =>  g_val_tab(270)
                         ,p_val_271                    =>  g_val_tab(271)
                         ,p_val_272                    =>  g_val_tab(272)
                         ,p_val_273                    =>  g_val_tab(273)
                         ,p_val_274                    =>  g_val_tab(274)
                         ,p_val_275                    =>  g_val_tab(275)
                         ,p_val_276                    =>  g_val_tab(276)
                         ,p_val_277                    =>  g_val_tab(277)
                         ,p_val_278                    =>  g_val_tab(278)
                         ,p_val_279                    =>  g_val_tab(279)
                         ,p_val_280                    =>  g_val_tab(280)
                         ,p_val_281                    =>  g_val_tab(281)
                         ,p_val_282                    =>  g_val_tab(282)
                         ,p_val_283                    =>  g_val_tab(283)
                         ,p_val_284                    =>  g_val_tab(284)
                         ,p_val_285                    =>  g_val_tab(285)
                         ,p_val_286                    =>  g_val_tab(286)
                         ,p_val_287                    =>  g_val_tab(287)
                         ,p_val_288                    =>  g_val_tab(288)
                         ,p_val_289                    =>  g_val_tab(289)
                         ,p_val_290                    =>  g_val_tab(290)
                         ,p_val_291                    =>  g_val_tab(291)
                         ,p_val_292                    =>  g_val_tab(292)
                         ,p_val_293                    =>  g_val_tab(293)
                         ,p_val_294                    =>  g_val_tab(294)
                         ,p_val_295                    =>  g_val_tab(295)
                         ,p_val_296                    =>  g_val_tab(296)
                         ,p_val_297                    =>  g_val_tab(297)
                         ,p_val_298                    =>  g_val_tab(298)
                         ,p_val_299                    =>  g_val_tab(299)
                         ,p_val_300                    =>  g_val_tab(300)
                         ,p_object_version_number      =>  l_object_version_number
                         ,p_ext_chg_rcd_mode           =>  l_ext_chg_rcd_mode
                         ,p_ext_rcd_in_file_id         =>  l_ext_rcd_in_file_id
                        );
               hr_utility.set_location(' Mode ' || l_ext_chg_rcd_mode,99 ) ;
            end if ;

            -- if change extract and update flag defined and mode is update then
            if  p_data_typ_cd  = 'C'  and  l_chg_rcd_upd_flag = 'Y'  and  l_ext_chg_rcd_mode = 'U' then

                  ben_ext_rslt_dtl_api.update_ext_rslt_dtl
                                (p_validate                   =>  false
                                ,p_ext_rslt_dtl_id            =>  l_ext_rslt_dtl_id
                                ,p_ext_rslt_id                =>  p_ext_rslt_id
                                ,p_ext_rcd_id                 =>  l_ext_rcd_id
                                ,p_person_id                  =>  p_person_id
                                ,p_business_group_id          =>  p_business_group_id
                                ,p_val_01                     =>  g_val_tab(1)
                                ,p_val_02                     =>  g_val_tab(2)
                                ,p_val_03                     =>  g_val_tab(3)
                                ,p_val_04                     =>  g_val_tab(4)
                                ,p_val_05                     =>  g_val_tab(5)
                                ,p_val_06                     =>  g_val_tab(6)
                                ,p_val_07                     =>  g_val_tab(7)
                                ,p_val_08                     =>  g_val_tab(8)
                                ,p_val_09                     =>  g_val_tab(9)
                                ,p_val_10                     =>  g_val_tab(10)
                                ,p_val_11                     =>  g_val_tab(11)
                                ,p_val_12                     =>  g_val_tab(12)
                                ,p_val_13                     =>  g_val_tab(13)
                                ,p_val_14                     =>  g_val_tab(14)
                                ,p_val_15                     =>  g_val_tab(15)
                                ,p_val_16                     =>  g_val_tab(16)
                                ,p_val_17                     =>  g_val_tab(17)
                                ,p_val_18                     =>  g_val_tab(18)
                                ,p_val_19                     =>  g_val_tab(19)
                                ,p_val_20                     =>  g_val_tab(20)
                                ,p_val_21                     =>  g_val_tab(21)
                                ,p_val_22                     =>  g_val_tab(22)
                                ,p_val_23                     =>  g_val_tab(23)
                                ,p_val_24                     =>  g_val_tab(24)
                                ,p_val_25                     =>  g_val_tab(25)
                                ,p_val_26                     =>  g_val_tab(26)
                                ,p_val_27                     =>  g_val_tab(27)
                                ,p_val_28                     =>  g_val_tab(28)
                                ,p_val_29                     =>  g_val_tab(29)
                                ,p_val_30                     =>  g_val_tab(30)
                                ,p_val_31                     =>  g_val_tab(31)
                                ,p_val_32                     =>  g_val_tab(32)
                                ,p_val_33                     =>  g_val_tab(33)
                                ,p_val_34                     =>  g_val_tab(34)
                                ,p_val_35                     =>  g_val_tab(35)
                                ,p_val_36                     =>  g_val_tab(36)
                                ,p_val_37                     =>  g_val_tab(37)
                                ,p_val_38                     =>  g_val_tab(38)
                                ,p_val_39                     =>  g_val_tab(39)
                                ,p_val_40                     =>  g_val_tab(40)
                                ,p_val_41                     =>  g_val_tab(41)
                                ,p_val_42                     =>  g_val_tab(42)
                                ,p_val_43                     =>  g_val_tab(43)
                                ,p_val_44                     =>  g_val_tab(44)
                                ,p_val_45                     =>  g_val_tab(45)
                                ,p_val_46                     =>  g_val_tab(46)
                                ,p_val_47                     =>  g_val_tab(47)
                                ,p_val_48                     =>  g_val_tab(48)
                                ,p_val_49                     =>  g_val_tab(49)
                                ,p_val_50                     =>  g_val_tab(50)
                                ,p_val_51                     =>  g_val_tab(51)
                                ,p_val_52                     =>  g_val_tab(52)
                                ,p_val_53                     =>  g_val_tab(53)
                                ,p_val_54                     =>  g_val_tab(54)
                                ,p_val_55                     =>  g_val_tab(55)
                                ,p_val_56                     =>  g_val_tab(56)
                                ,p_val_57                     =>  g_val_tab(57)
                                ,p_val_58                     =>  g_val_tab(58)
                                ,p_val_59                     =>  g_val_tab(59)
                                ,p_val_60                     =>  g_val_tab(60)
                                ,p_val_61                     =>  g_val_tab(61)
                                ,p_val_62                     =>  g_val_tab(62)
                                ,p_val_63                     =>  g_val_tab(63)
                                ,p_val_64                     =>  g_val_tab(64)
                                ,p_val_65                     =>  g_val_tab(65)
                                ,p_val_66                     =>  g_val_tab(66)
                                ,p_val_67                     =>  g_val_tab(67)
                                ,p_val_68                     =>  g_val_tab(68)
                                ,p_val_69                     =>  g_val_tab(69)
                                ,p_val_70                     =>  g_val_tab(70)
                                ,p_val_71                     =>  g_val_tab(71)
                                ,p_val_72                     =>  g_val_tab(72)
                                ,p_val_73                     =>  g_val_tab(73)
                                ,p_val_74                     =>  g_val_tab(74)
                                ,p_val_75                     =>  g_val_tab(75)
                                ,p_val_76                     =>  g_val_tab(76)
                                ,p_val_77                     =>  g_val_tab(77)
                                ,p_val_78                     =>  g_val_tab(78)
                                ,p_val_79                     =>  g_val_tab(79)
                                ,p_val_80                     =>  g_val_tab(80)
                                ,p_val_81                     =>  g_val_tab(81)
                                ,p_val_82                     =>  g_val_tab(82)
                                ,p_val_83                     =>  g_val_tab(83)
                                ,p_val_84                     =>  g_val_tab(84)
                                ,p_val_85                     =>  g_val_tab(85)
                                ,p_val_86                     =>  g_val_tab(86)
                                ,p_val_87                     =>  g_val_tab(87)
                                ,p_val_88                     =>  g_val_tab(88)
                                ,p_val_89                     =>  g_val_tab(89)
                                ,p_val_90                     =>  g_val_tab(90)
                                ,p_val_91                     =>  g_val_tab(91)
                                ,p_val_92                     =>  g_val_tab(92)
                                ,p_val_93                     =>  g_val_tab(93)
                                ,p_val_94                     =>  g_val_tab(94)
                                ,p_val_95                     =>  g_val_tab(95)
                                ,p_val_96                     =>  g_val_tab(96)
                                ,p_val_97                     =>  g_val_tab(97)
                                ,p_val_98                     =>  g_val_tab(98)
                                ,p_val_99                     =>  g_val_tab(99)
                                ,p_val_100                    =>  g_val_tab(100)
                                ,p_val_101                    =>  g_val_tab(101)
                                ,p_val_102                    =>  g_val_tab(102)
                                ,p_val_103                    =>  g_val_tab(103)
                                ,p_val_104                    =>  g_val_tab(104)
                                ,p_val_105                    =>  g_val_tab(105)
                                ,p_val_106                    =>  g_val_tab(106)
                                ,p_val_107                    =>  g_val_tab(107)
                                ,p_val_108                    =>  g_val_tab(108)
                                ,p_val_109                    =>  g_val_tab(109)
                                ,p_val_110                    =>  g_val_tab(110)
                                ,p_val_111                    =>  g_val_tab(111)
                                ,p_val_112                    =>  g_val_tab(112)
                                ,p_val_113                    =>  g_val_tab(113)
                                ,p_val_114                    =>  g_val_tab(114)
                                ,p_val_115                    =>  g_val_tab(115)
                                ,p_val_116                    =>  g_val_tab(116)
                                ,p_val_117                    =>  g_val_tab(117)
                                ,p_val_118                    =>  g_val_tab(118)
                                ,p_val_119                    =>  g_val_tab(119)
                                ,p_val_120                    =>  g_val_tab(120)
                                ,p_val_121                    =>  g_val_tab(121)
                                ,p_val_122                    =>  g_val_tab(122)
                                ,p_val_123                    =>  g_val_tab(123)
                                ,p_val_124                    =>  g_val_tab(124)
                                ,p_val_125                    => g_val_tab(125)
                                ,p_val_126                    =>  g_val_tab(126)
                                ,p_val_127                    =>  g_val_tab(127)
                                ,p_val_128                    =>  g_val_tab(128)
                                ,p_val_129                    =>  g_val_tab(129)
                                ,p_val_130                    =>  g_val_tab(130)
                                ,p_val_131                    =>  g_val_tab(131)
                                ,p_val_132                    =>  g_val_tab(132)
                                ,p_val_133                    =>  g_val_tab(133)
                                ,p_val_134                    =>  g_val_tab(134)
                                ,p_val_135                    =>  g_val_tab(135)
                                ,p_val_136                    =>  g_val_tab(136)
                                ,p_val_137                    =>  g_val_tab(137)
                                ,p_val_138                    =>  g_val_tab(138)
                                ,p_val_139                    =>  g_val_tab(139)
                                ,p_val_140                    =>  g_val_tab(140)
                                ,p_val_141                    =>  g_val_tab(141)
                                ,p_val_142                    =>  g_val_tab(142)
                                ,p_val_143                    =>  g_val_tab(143)
                                ,p_val_144                    =>  g_val_tab(144)
                                ,p_val_145                    =>  g_val_tab(145)
                                ,p_val_146                    =>  g_val_tab(146)
                                ,p_val_147                    =>  g_val_tab(147)
                                ,p_val_148                    =>  g_val_tab(148)
                                ,p_val_149                    =>  g_val_tab(149)
                                ,p_val_150                    =>  g_val_tab(150)
                                ,p_val_151                    =>  g_val_tab(151)
                                ,p_val_152                    =>  g_val_tab(152)
                                ,p_val_153                    =>  g_val_tab(153)
                                ,p_val_154                    =>  g_val_tab(154)
                                ,p_val_155                    =>  g_val_tab(155)
                                ,p_val_156                    =>  g_val_tab(156)
                                ,p_val_157                    =>  g_val_tab(157)
                                ,p_val_158                    =>  g_val_tab(158)
                                ,p_val_159                    =>  g_val_tab(159)
                                ,p_val_160                    =>  g_val_tab(160)
                                ,p_val_161                    =>  g_val_tab(161)
                                ,p_val_162                    =>  g_val_tab(162)
                                ,p_val_163                    =>  g_val_tab(163)
                                ,p_val_164                    =>  g_val_tab(164)
                                ,p_val_165                    =>  g_val_tab(165)
                                ,p_val_166                    =>  g_val_tab(166)
                                ,p_val_167                    =>  g_val_tab(167)
                                ,p_val_168                    =>  g_val_tab(168)
                                ,p_val_169                    => g_val_tab(169)
                                ,p_val_170                    =>  g_val_tab(170)
                                ,p_val_171                    =>  g_val_tab(171)
                                ,p_val_172                    =>  g_val_tab(172)
                                ,p_val_173                    =>  g_val_tab(173)
                                ,p_val_174                    =>  g_val_tab(174)
                                ,p_val_175                    =>  g_val_tab(175)
                                ,p_val_176                    =>  g_val_tab(176)
                                ,p_val_177                    =>  g_val_tab(177)
                                ,p_val_178                    =>  g_val_tab(178)
                                ,p_val_179                    =>  g_val_tab(179)
                                ,p_val_180                    =>  g_val_tab(180)
                                ,p_val_181                    =>  g_val_tab(181)
                                ,p_val_182                    =>  g_val_tab(182)
                                ,p_val_183                    =>  g_val_tab(183)
                                ,p_val_184                    =>  g_val_tab(184)
                                ,p_val_185                    =>  g_val_tab(185)
                                ,p_val_186                    =>  g_val_tab(186)
                                ,p_val_187                    =>  g_val_tab(187)
                                ,p_val_188                    =>  g_val_tab(188)
                                ,p_val_189                    =>  g_val_tab(189)
                                ,p_val_190                    =>  g_val_tab(190)
                                ,p_val_191                    =>  g_val_tab(191)
                                ,p_val_192                    =>  g_val_tab(192)
                                ,p_val_193                    =>  g_val_tab(193)
                                ,p_val_194                    =>  g_val_tab(194)
                                ,p_val_195                    => g_val_tab(195)
                                ,p_val_196                    =>  g_val_tab(196)
                                ,p_val_197                    =>  g_val_tab(197)
                                ,p_val_198                    =>  g_val_tab(198)
                                ,p_val_199                    =>  g_val_tab(199)
                                ,p_val_200                    =>  g_val_tab(200)
                                ,p_val_201                    =>  g_val_tab(201)
                                ,p_val_202                    =>  g_val_tab(202)
                                ,p_val_203                    =>  g_val_tab(203)
                                ,p_val_204                    =>  g_val_tab(204)
                                ,p_val_205                    =>  g_val_tab(205)
                                ,p_val_206                    =>  g_val_tab(206)
                                ,p_val_207                    =>  g_val_tab(207)
                                ,p_val_208                    =>  g_val_tab(208)
                                ,p_val_209                    =>  g_val_tab(209)
                                ,p_val_210                    =>  g_val_tab(210)
                                ,p_val_211                    =>  g_val_tab(211)
                                ,p_val_212                    =>  g_val_tab(212)
                                ,p_val_213                    =>  g_val_tab(213)
                                ,p_val_214                    =>  g_val_tab(214)
                                ,p_val_215                    =>  g_val_tab(215)
                                ,p_val_216                    =>  g_val_tab(216)
                                ,p_val_217                    =>  g_val_tab(217)
                                ,p_val_218                    =>  g_val_tab(218)
                                ,p_val_219                    =>  g_val_tab(219)
                                ,p_val_220                    =>  g_val_tab(220)
                                ,p_val_221                    =>  g_val_tab(221)
                                ,p_val_222                    =>  g_val_tab(222)
                                ,p_val_223                    =>  g_val_tab(223)
                                ,p_val_224                    =>  g_val_tab(224)
                                ,p_val_225                    =>  g_val_tab(225)
                                ,p_val_226                    =>  g_val_tab(226)
                                ,p_val_227                    =>  g_val_tab(227)
                                ,p_val_228                    =>  g_val_tab(228)
                                ,p_val_229                    =>  g_val_tab(229)
                                ,p_val_230                    =>  g_val_tab(230)
                                ,p_val_231                    =>  g_val_tab(231)
                                ,p_val_232                    =>  g_val_tab(232)
                                ,p_val_233                    =>  g_val_tab(233)
                                ,p_val_234                    =>  g_val_tab(234)
                                ,p_val_235                    =>  g_val_tab(235)
                                ,p_val_236                    =>  g_val_tab(236)
                                ,p_val_237                    =>  g_val_tab(237)
                                ,p_val_238                    =>  g_val_tab(238)
                                ,p_val_239                    =>  g_val_tab(239)
                                ,p_val_240                    =>  g_val_tab(240)
                                ,p_val_241                    =>  g_val_tab(241)
                                ,p_val_242                    =>  g_val_tab(242)
                                ,p_val_243                    =>  g_val_tab(243)
                                ,p_val_244                    =>  g_val_tab(244)
                                ,p_val_245                    =>  g_val_tab(245)
                                ,p_val_246                    =>  g_val_tab(246)
                                ,p_val_247                    =>  g_val_tab(247)
                                ,p_val_248                    =>  g_val_tab(248)
                                ,p_val_249                    =>  g_val_tab(249)
                                ,p_val_250                    =>  g_val_tab(250)
                                ,p_val_251                    =>  g_val_tab(251)
                                ,p_val_252                    =>  g_val_tab(252)
                                ,p_val_253                    =>  g_val_tab(253)
                                ,p_val_254                    =>  g_val_tab(254)
                                ,p_val_255                    =>  g_val_tab(255)
                                ,p_val_256                    =>  g_val_tab(256)
                                ,p_val_257                    =>  g_val_tab(257)
                                ,p_val_258                    =>  g_val_tab(258)
                                ,p_val_259                    =>  g_val_tab(259)
                                ,p_val_260                    =>  g_val_tab(260)
                                ,p_val_261                    =>  g_val_tab(261)
                                ,p_val_262                    =>  g_val_tab(262)
                                ,p_val_263                    =>  g_val_tab(263)
                                ,p_val_264                    =>  g_val_tab(264)
                                ,p_val_265                    =>  g_val_tab(265)
                                ,p_val_266                    =>  g_val_tab(266)
                                ,p_val_267                    =>  g_val_tab(267)
                                ,p_val_268                    =>  g_val_tab(268)
                                ,p_val_269                    =>  g_val_tab(269)
                                ,p_val_270                    =>  g_val_tab(270)
                                ,p_val_271                    =>  g_val_tab(271)
                                ,p_val_272                    =>  g_val_tab(272)
                                ,p_val_273                    =>  g_val_tab(273)
                                ,p_val_274                    =>  g_val_tab(274)
                                ,p_val_275                    =>  g_val_tab(275)
                                ,p_val_276                    =>  g_val_tab(276)
                                ,p_val_277                    =>  g_val_tab(277)
                                ,p_val_278                    =>  g_val_tab(278)
                                ,p_val_279                    =>  g_val_tab(279)
                                ,p_val_280                    =>  g_val_tab(280)
                                ,p_val_281                    =>  g_val_tab(281)
                                ,p_val_282                    =>  g_val_tab(282)
                                ,p_val_283                    =>  g_val_tab(283)
                                ,p_val_284                    =>  g_val_tab(284)
                                ,p_val_285                    =>  g_val_tab(285)
                                ,p_val_286                    =>  g_val_tab(286)
                                ,p_val_287                    =>  g_val_tab(287)
                                ,p_val_288                    =>  g_val_tab(288)
                                ,p_val_289                    =>  g_val_tab(289)
                                ,p_val_290                    =>  g_val_tab(290)
                                ,p_val_291                    =>  g_val_tab(291)
                                ,p_val_292                    =>  g_val_tab(292)
                                ,p_val_293                    =>  g_val_tab(293)
                                ,p_val_294                    =>  g_val_tab(294)
                                ,p_val_295                    =>  g_val_tab(295)
                                ,p_val_296                    =>  g_val_tab(296)
                                ,p_val_297                    =>  g_val_tab(297)
                                ,p_val_298                    =>  g_val_tab(298)
                                ,p_val_299                    =>  g_val_tab(299)
                                ,p_val_300                    =>  g_val_tab(300)
                                ,p_group_val_01               =>  ben_ext_person.g_group_elmt_value1
                                ,p_group_val_02               =>  ben_ext_person.g_group_elmt_value2
                                ,p_ext_rcd_in_file_id         =>  l_ext_rcd_in_file_id
                                ,p_object_version_number      =>  l_object_version_number
                               );

            else
                 -- allwasy create for non chang eextract
                 ben_ext_rslt_dtl_api.create_ext_rslt_dtl
                                (p_validate                   =>  false
                                ,p_ext_rslt_dtl_id            =>  l_ext_rslt_dtl_id
                                ,p_prmy_sort_val              =>  l_prmy_sort_val
                                ,p_scnd_sort_val              =>  l_scnd_sort_val
                                ,p_thrd_sort_val              =>  l_thrd_sort_val
                                ,p_trans_seq_num              =>  l_trans_num
                                ,p_rcrd_seq_num               =>  ben_ext_person.g_rcd_seq
                                ,p_ext_rslt_id                =>  p_ext_rslt_id
                                ,p_ext_rcd_id                 =>  l_ext_rcd_id
                                ,p_person_id                  =>  p_person_id
                                ,p_business_group_id          =>  p_business_group_id
                                ,p_val_01                     =>  g_val_tab(1)
                                ,p_val_02                     =>  g_val_tab(2)
                                ,p_val_03                     =>  g_val_tab(3)
                                ,p_val_04                     =>  g_val_tab(4)
                                ,p_val_05                     =>  g_val_tab(5)
                                ,p_val_06                     =>  g_val_tab(6)
                                ,p_val_07                     =>  g_val_tab(7)
                                ,p_val_08                     =>  g_val_tab(8)
                                ,p_val_09                     =>  g_val_tab(9)
                                ,p_val_10                     =>  g_val_tab(10)
                                ,p_val_11                     =>  g_val_tab(11)
                                ,p_val_12                     =>  g_val_tab(12)
                                ,p_val_13                     =>  g_val_tab(13)
                                ,p_val_14                     =>  g_val_tab(14)
                                ,p_val_15                     =>  g_val_tab(15)
                                ,p_val_16                     =>  g_val_tab(16)
                                ,p_val_17                     =>  g_val_tab(17)
                                ,p_val_18                     =>  g_val_tab(18)
                                ,p_val_19                     =>  g_val_tab(19)
                                ,p_val_20                     =>  g_val_tab(20)
                                ,p_val_21                     =>  g_val_tab(21)
                                ,p_val_22                     =>  g_val_tab(22)
                                ,p_val_23                     =>  g_val_tab(23)
                                ,p_val_24                     =>  g_val_tab(24)
                                ,p_val_25                     =>  g_val_tab(25)
                                ,p_val_26                     =>  g_val_tab(26)
                                ,p_val_27                     =>  g_val_tab(27)
                                ,p_val_28                     =>  g_val_tab(28)
                                ,p_val_29                     =>  g_val_tab(29)
                                ,p_val_30                     =>  g_val_tab(30)
                                ,p_val_31                     =>  g_val_tab(31)
                                ,p_val_32                     =>  g_val_tab(32)
                                ,p_val_33                     =>  g_val_tab(33)
                                ,p_val_34                     =>  g_val_tab(34)
                                ,p_val_35                     =>  g_val_tab(35)
                                ,p_val_36                     =>  g_val_tab(36)
                                ,p_val_37                     =>  g_val_tab(37)
                                ,p_val_38                     =>  g_val_tab(38)
                                ,p_val_39                     =>  g_val_tab(39)
                                ,p_val_40                     =>  g_val_tab(40)
                                ,p_val_41                     =>  g_val_tab(41)
                                ,p_val_42                     =>  g_val_tab(42)
                                ,p_val_43                     =>  g_val_tab(43)
                                ,p_val_44                     =>  g_val_tab(44)
                                ,p_val_45                     =>  g_val_tab(45)
                                ,p_val_46                     =>  g_val_tab(46)
                                ,p_val_47                     =>  g_val_tab(47)
                                ,p_val_48                     =>  g_val_tab(48)
                                ,p_val_49                     =>  g_val_tab(49)
                                ,p_val_50                     =>  g_val_tab(50)
                                ,p_val_51                     =>  g_val_tab(51)
                                ,p_val_52                     =>  g_val_tab(52)
                                ,p_val_53                     =>  g_val_tab(53)
                                ,p_val_54                     =>  g_val_tab(54)
                                ,p_val_55                     =>  g_val_tab(55)
                                ,p_val_56                     =>  g_val_tab(56)
                                ,p_val_57                     =>  g_val_tab(57)
                                ,p_val_58                     =>  g_val_tab(58)
                                ,p_val_59                     =>  g_val_tab(59)
                                ,p_val_60                     =>  g_val_tab(60)
                                ,p_val_61                     =>  g_val_tab(61)
                                ,p_val_62                     =>  g_val_tab(62)
                                ,p_val_63                     =>  g_val_tab(63)
                                ,p_val_64                     =>  g_val_tab(64)
                                ,p_val_65                     =>  g_val_tab(65)
                                ,p_val_66                     =>  g_val_tab(66)
                                ,p_val_67                     =>  g_val_tab(67)
                                ,p_val_68                     =>  g_val_tab(68)
                                ,p_val_69                     =>  g_val_tab(69)
                                ,p_val_70                     =>  g_val_tab(70)
                                ,p_val_71                     =>  g_val_tab(71)
                                ,p_val_72                     =>  g_val_tab(72)
                                ,p_val_73                     =>  g_val_tab(73)
                                ,p_val_74                     =>  g_val_tab(74)
                                ,p_val_75                     =>  g_val_tab(75)
                                ,p_val_76                     =>  g_val_tab(76)
                                ,p_val_77                     =>  g_val_tab(77)
                                ,p_val_78                     =>  g_val_tab(78)
                                ,p_val_79                     =>  g_val_tab(79)
                                ,p_val_80                     =>  g_val_tab(80)
                                ,p_val_81                     =>  g_val_tab(81)
                                ,p_val_82                     =>  g_val_tab(82)
                                ,p_val_83                     =>  g_val_tab(83)
                                ,p_val_84                     =>  g_val_tab(84)
                                ,p_val_85                     =>  g_val_tab(85)
                                ,p_val_86                     =>  g_val_tab(86)
                                ,p_val_87                     =>  g_val_tab(87)
                                ,p_val_88                     =>  g_val_tab(88)
                                ,p_val_89                     =>  g_val_tab(89)
                                ,p_val_90                     =>  g_val_tab(90)
                                ,p_val_91                     =>  g_val_tab(91)
                                ,p_val_92                     =>  g_val_tab(92)
                                ,p_val_93                     =>  g_val_tab(93)
                                ,p_val_94                     =>  g_val_tab(94)
                                ,p_val_95                     =>  g_val_tab(95)
                                ,p_val_96                     =>  g_val_tab(96)
                                ,p_val_97                     =>  g_val_tab(97)
                                ,p_val_98                     =>  g_val_tab(98)
                                ,p_val_99                     =>  g_val_tab(99)
                                ,p_val_100                    =>  g_val_tab(100)
                                ,p_val_101                    =>  g_val_tab(101)
                                ,p_val_102                    =>  g_val_tab(102)
                                ,p_val_103                    =>  g_val_tab(103)
                                ,p_val_104                    =>  g_val_tab(104)
                                ,p_val_105                    =>  g_val_tab(105)
                                ,p_val_106                    =>  g_val_tab(106)
                                ,p_val_107                    =>  g_val_tab(107)
                                ,p_val_108                    =>  g_val_tab(108)
                                ,p_val_109                    =>  g_val_tab(109)
                                ,p_val_110                    =>  g_val_tab(110)
                                ,p_val_111                    =>  g_val_tab(111)
                                ,p_val_112                    =>  g_val_tab(112)
                                ,p_val_113                    =>  g_val_tab(113)
                                ,p_val_114                    =>  g_val_tab(114)
                                ,p_val_115                    =>  g_val_tab(115)
                                ,p_val_116                    =>  g_val_tab(116)
                                ,p_val_117                    =>  g_val_tab(117)
                                ,p_val_118                    =>  g_val_tab(118)
                                ,p_val_119                    =>  g_val_tab(119)
                                ,p_val_120                    =>  g_val_tab(120)
                                ,p_val_121                    =>  g_val_tab(121)
                                ,p_val_122                    =>  g_val_tab(122)
                                ,p_val_123                    =>  g_val_tab(123)
                                ,p_val_124                    =>  g_val_tab(124)
                                ,p_val_125                    => g_val_tab(125)
                                ,p_val_126                    =>  g_val_tab(126)
                                ,p_val_127                    =>  g_val_tab(127)
                                ,p_val_128                    =>  g_val_tab(128)
                                ,p_val_129                    =>  g_val_tab(129)
                                ,p_val_130                    =>  g_val_tab(130)
                                ,p_val_131                    =>  g_val_tab(131)
                                ,p_val_132                    =>  g_val_tab(132)
                                ,p_val_133                    =>  g_val_tab(133)
                                ,p_val_134                    =>  g_val_tab(134)
                                ,p_val_135                    =>  g_val_tab(135)
                                ,p_val_136                    =>  g_val_tab(136)
                                ,p_val_137                    =>  g_val_tab(137)
                                ,p_val_138                    =>  g_val_tab(138)
                                ,p_val_139                    =>  g_val_tab(139)
                                ,p_val_140                    =>  g_val_tab(140)
                                ,p_val_141                    =>  g_val_tab(141)
                                ,p_val_142                    =>  g_val_tab(142)
                                ,p_val_143                    =>  g_val_tab(143)
                                ,p_val_144                    =>  g_val_tab(144)
                                ,p_val_145                    =>  g_val_tab(145)
                                ,p_val_146                    =>  g_val_tab(146)
                                ,p_val_147                    =>  g_val_tab(147)
                                ,p_val_148                    =>  g_val_tab(148)
                                ,p_val_149                    =>  g_val_tab(149)
                                ,p_val_150                    =>  g_val_tab(150)
                                ,p_val_151                    =>  g_val_tab(151)
                                ,p_val_152                    =>  g_val_tab(152)
                                ,p_val_153                    =>  g_val_tab(153)
                                ,p_val_154                    =>  g_val_tab(154)
                                ,p_val_155                    =>  g_val_tab(155)
                                ,p_val_156                    =>  g_val_tab(156)
                                ,p_val_157                    =>  g_val_tab(157)
                                ,p_val_158                    =>  g_val_tab(158)
                                ,p_val_159                    =>  g_val_tab(159)
                                ,p_val_160                    =>  g_val_tab(160)
                                ,p_val_161                    =>  g_val_tab(161)
                                ,p_val_162                    =>  g_val_tab(162)
                                ,p_val_163                    =>  g_val_tab(163)
                                ,p_val_164                    =>  g_val_tab(164)
                                ,p_val_165                    =>  g_val_tab(165)
                                ,p_val_166                    =>  g_val_tab(166)
                                ,p_val_167                    =>  g_val_tab(167)
                                ,p_val_168                    =>  g_val_tab(168)
                                ,p_val_169                    => g_val_tab(169)
                                ,p_val_170                    =>  g_val_tab(170)
                                ,p_val_171                    =>  g_val_tab(171)
                                ,p_val_172                    =>  g_val_tab(172)
                                ,p_val_173                    =>  g_val_tab(173)
                                ,p_val_174                    =>  g_val_tab(174)
                                ,p_val_175                    =>  g_val_tab(175)
                                ,p_val_176                    =>  g_val_tab(176)
                                ,p_val_177                    =>  g_val_tab(177)
                                ,p_val_178                    =>  g_val_tab(178)
                                ,p_val_179                    =>  g_val_tab(179)
                                ,p_val_180                    =>  g_val_tab(180)
                                ,p_val_181                    =>  g_val_tab(181)
                                ,p_val_182                    =>  g_val_tab(182)
                                ,p_val_183                    =>  g_val_tab(183)
                                ,p_val_184                    =>  g_val_tab(184)
                                ,p_val_185                    =>  g_val_tab(185)
                                ,p_val_186                    =>  g_val_tab(186)
                                ,p_val_187                    =>  g_val_tab(187)
                                ,p_val_188                    =>  g_val_tab(188)
                                ,p_val_189                    =>  g_val_tab(189)
                                ,p_val_190                    =>  g_val_tab(190)
                                ,p_val_191                    =>  g_val_tab(191)
                                ,p_val_192                    =>  g_val_tab(192)
                                ,p_val_193                    =>  g_val_tab(193)
                                ,p_val_194                    =>  g_val_tab(194)
                                ,p_val_195                    => g_val_tab(195)
                                ,p_val_196                    =>  g_val_tab(196)
                                ,p_val_197                    =>  g_val_tab(197)
                                ,p_val_198                    =>  g_val_tab(198)
                                ,p_val_199                    =>  g_val_tab(199)
                                ,p_val_200                    =>  g_val_tab(200)
                                ,p_val_201                    =>  g_val_tab(201)
                                ,p_val_202                    =>  g_val_tab(202)
                                ,p_val_203                    =>  g_val_tab(203)
                                ,p_val_204                    =>  g_val_tab(204)
                                ,p_val_205                    =>  g_val_tab(205)
                                ,p_val_206                    =>  g_val_tab(206)
                                ,p_val_207                    =>  g_val_tab(207)
                                ,p_val_208                    =>  g_val_tab(208)
                                ,p_val_209                    =>  g_val_tab(209)
                                ,p_val_210                    =>  g_val_tab(210)
                                ,p_val_211                    =>  g_val_tab(211)
                                ,p_val_212                    =>  g_val_tab(212)
                                ,p_val_213                    =>  g_val_tab(213)
                                ,p_val_214                    =>  g_val_tab(214)
                                ,p_val_215                    =>  g_val_tab(215)
                                ,p_val_216                    =>  g_val_tab(216)
                                ,p_val_217                    =>  g_val_tab(217)
                                ,p_val_218                    =>  g_val_tab(218)
                                ,p_val_219                    =>  g_val_tab(219)
                                ,p_val_220                    =>  g_val_tab(220)
                                ,p_val_221                    =>  g_val_tab(221)
                                ,p_val_222                    =>  g_val_tab(222)
                                ,p_val_223                    =>  g_val_tab(223)
                                ,p_val_224                    =>  g_val_tab(224)
                                ,p_val_225                    =>  g_val_tab(225)
                                ,p_val_226                    =>  g_val_tab(226)
                                ,p_val_227                    =>  g_val_tab(227)
                                ,p_val_228                    =>  g_val_tab(228)
                                ,p_val_229                    =>  g_val_tab(229)
                                ,p_val_230                    =>  g_val_tab(230)
                                ,p_val_231                    =>  g_val_tab(231)
                                ,p_val_232                    =>  g_val_tab(232)
                                ,p_val_233                    =>  g_val_tab(233)
                                ,p_val_234                    =>  g_val_tab(234)
                                ,p_val_235                    =>  g_val_tab(235)
                                ,p_val_236                    =>  g_val_tab(236)
                                ,p_val_237                    =>  g_val_tab(237)
                                ,p_val_238                    =>  g_val_tab(238)
                                ,p_val_239                    =>  g_val_tab(239)
                                ,p_val_240                    =>  g_val_tab(240)
                                ,p_val_241                    =>  g_val_tab(241)
                                ,p_val_242                    =>  g_val_tab(242)
                                ,p_val_243                    =>  g_val_tab(243)
                                ,p_val_244                    =>  g_val_tab(244)
                                ,p_val_245                    =>  g_val_tab(245)
                                ,p_val_246                    =>  g_val_tab(246)
                                ,p_val_247                    =>  g_val_tab(247)
                                ,p_val_248                    =>  g_val_tab(248)
                                ,p_val_249                    =>  g_val_tab(249)
                                ,p_val_250                    =>  g_val_tab(250)
                                ,p_val_251                    =>  g_val_tab(251)
                                ,p_val_252                    =>  g_val_tab(252)
                                ,p_val_253                    =>  g_val_tab(253)
                                ,p_val_254                    =>  g_val_tab(254)
                                ,p_val_255                    =>  g_val_tab(255)
                                ,p_val_256                    =>  g_val_tab(256)
                                ,p_val_257                    =>  g_val_tab(257)
                                ,p_val_258                    =>  g_val_tab(258)
                                ,p_val_259                    =>  g_val_tab(259)
                                ,p_val_260                    =>  g_val_tab(260)
                                ,p_val_261                    =>  g_val_tab(261)
                                ,p_val_262                    =>  g_val_tab(262)
                                ,p_val_263                    =>  g_val_tab(263)
                                ,p_val_264                    =>  g_val_tab(264)
                                ,p_val_265                    =>  g_val_tab(265)
                                ,p_val_266                    =>  g_val_tab(266)
                                ,p_val_267                    =>  g_val_tab(267)
                                ,p_val_268                    =>  g_val_tab(268)
                                ,p_val_269                    =>  g_val_tab(269)
                                ,p_val_270                    =>  g_val_tab(270)
                                ,p_val_271                    =>  g_val_tab(271)
                                ,p_val_272                    =>  g_val_tab(272)
                                ,p_val_273                    =>  g_val_tab(273)
                                ,p_val_274                    =>  g_val_tab(274)
                                ,p_val_275                    =>  g_val_tab(275)
                                ,p_val_276                    =>  g_val_tab(276)
                                ,p_val_277                    =>  g_val_tab(277)
                                ,p_val_278                    =>  g_val_tab(278)
                                ,p_val_279                    =>  g_val_tab(279)
                                ,p_val_280                    =>  g_val_tab(280)
                                ,p_val_281                    =>  g_val_tab(281)
                                ,p_val_282                    =>  g_val_tab(282)
                                ,p_val_283                    =>  g_val_tab(283)
                                ,p_val_284                    =>  g_val_tab(284)
                                ,p_val_285                    =>  g_val_tab(285)
                                ,p_val_286                    =>  g_val_tab(286)
                                ,p_val_287                    =>  g_val_tab(287)
                                ,p_val_288                    =>  g_val_tab(288)
                                ,p_val_289                    =>  g_val_tab(289)
                                ,p_val_290                    =>  g_val_tab(290)
                                ,p_val_291                    =>  g_val_tab(291)
                                ,p_val_292                    =>  g_val_tab(292)
                                ,p_val_293                    =>  g_val_tab(293)
                                ,p_val_294                    =>  g_val_tab(294)
                                ,p_val_295                    =>  g_val_tab(295)
                                ,p_val_296                    =>  g_val_tab(296)
                                ,p_val_297                    =>  g_val_tab(297)
                                ,p_val_298                    =>  g_val_tab(298)
                                ,p_val_299                    =>  g_val_tab(299)
                                ,p_val_300                    =>  g_val_tab(300)
                                ,p_group_val_01               =>  ben_ext_person.g_group_elmt_value1
                                ,p_group_val_02               =>  ben_ext_person.g_group_elmt_value2
                                ,p_program_id                 =>  fnd_global.conc_program_id
                                ,p_program_update_date        =>  sysdate
                                ,p_request_id                 =>  nvl(ben_extract.g_request_id,fnd_global.conc_request_id)
                                ,p_object_version_number      =>  l_object_version_number
                                ,p_ext_per_bg_id              =>  l_ext_per_bg_id
                                ,p_ext_rcd_in_file_id         =>  l_ext_rcd_in_file_id
                               );
               end if ;
             --
              -- This is set to true because we want the ben_per_cm_prvdd to be updated
              -- only when some detail is written.
              -- bug 1386266
              --
              ben_ext_person.g_detail_extracted:=true;
              --
              --
           end if;  --write record = 'Y'
     /* madatory validated down   Else
         hr_utility.set_location(' Element not found ', 15);
          --- If the element is mandatory and null  and the record is mandatory
          --- skip the person
          if nvl(l_rcd_rqd_flag,'N') = 'Y' then
            hr_utility.set_location(' record not found ', 15) ;
             raise ben_ext_person.detail_error ;
          end if ;
      */
      end if ;

       --
  END IF;
    --
END LOOP;

--
  hr_utility.set_location(' Exiting:'||l_proc, 15);
--
end process_ext_recs;
--
--  The following three functions are overloaded.
--  They will return a result string for a date, number or varchar data element
--  that is formatted according to the format mask specified.
--  These procedures do not validate the format mask.  Such validation should
--  happen in the API.
-- ----------------------------------------------------------------------------
-- |------------------------< apply_format_mask for date >--------------------|
-- ----------------------------------------------------------------------------
Function apply_format_mask(p_value date, p_format_mask varchar2
                           )Return Varchar2 Is
--
  l_proc 	  varchar2(72) := g_package||'apply_format_mask';
  l_fmt_date      ben_ext_rslt_Dtl.val_01%type  := null;

--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_value is null then
    return p_value;
  end if;

  --
  if p_format_mask is not null then
    --
    l_fmt_date := to_char(p_value, p_format_mask);
    --
  else
    --
    l_fmt_date := to_char(p_value);
    --
  end if;
  --
  return (l_fmt_date);
  --
  hr_utility.set_location(' Exiting:'||l_proc, 15);
--
End apply_format_mask;
--
-- ----------------------------------------------------------------------------
-- |------------------------< apply_format_mask for number >------------------|
-- ----------------------------------------------------------------------------
Function apply_format_mask(p_value number, p_format_mask varchar2
                           ) Return Varchar2 Is
--
  l_proc 	  varchar2(72) := g_package||'apply_format_mask';
  l_fmt_num       ben_ext_rslt_Dtl.val_01%type := null;
  l_cd_strt       varchar2(1);
  l_str_value     varchar2(100);
  l_format        varchar2(100);
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if p_value is null then
    return p_value;
  end if;
  --
  if p_format_mask is not null then
  --
      hr_utility.set_location('format :'||p_format_mask, 10);
      hr_utility.set_location('value  :'||p_value , 10);
  -- Check for special format
  --
    if substr(p_format_mask,length(p_format_mask),1) in ('{','}') then
    -- check the first char of the code
       select substr(lookup_code,1,1) into l_cd_strt
       from hr_lookups
       where lookup_type = 'BEN_EXT_FRMT_MASK'
       and   meaning = p_format_mask;

       if l_cd_strt = 'N' then

          --- convert the number as per the format
          l_format := substr(p_format_mask,1, length(p_format_mask)-1) ;
          hr_utility.set_location('l_format :'||l_format , 10);

          l_str_value  := to_char(p_value,l_format);

          hr_utility.set_location('Formated number :'||l_str_value , 10);

          -- as per the bug 5387355 , The Last digit of the  number has to be changed
          -- if the number is +  then  1 to 9 changes as  A to I and 0 chages as {
          -- if the number is -  then  1 to 9 changes as  J to R and 0 chages as }
          -- as per the bug 5526107  the format changes takes place only if the number is negetive
          -- We have two requirement, 1 changes the format for every number
          --  2 changes the format only for nevetive number
          -- if the format mask  end with { then the first case is taken care
          -- if the format mask  end with } then the second case is taken care
          /*
           if substr(p_format_mask,length(p_format_mask),1) = '}' then
             if substr(l_str_value ,length(l_str_value),1) = '0' then
                l_fmt_num := '}';
             else
                l_fmt_num := substr(l_str_value,length(l_str_value),1);
             end if;
           else
          */
          ---
          l_fmt_num := '' ;
          if p_value >= 0  then
             -- Positive value changes only for { format mask
             if substr(p_format_mask,length(p_format_mask),1) = '{' then
                select decode(substr(l_str_value,length(l_str_value),1),
                      '1','A','2','B','3','C','4','D','5','E','6','F','7','G','8','H','9','I','0','{')
                      into l_fmt_num from dual;
             else
               l_fmt_num := substr(l_str_value,-1) ;
             End if ;
          else
             -- change the number as positive
             l_str_value  := to_char(abs(p_value),l_format);
             select decode(substr(l_str_value,length(l_str_value),1),
                        '1','J','2','K','3','L','4','M','5','N','6','O','7','P','8','Q','9','R','0','}')
                        into l_fmt_num from dual;
          end if;

          hr_utility.set_location('non Formated value  :'||l_str_value  , 10);
          hr_utility.set_location('non Formated value  :'|| (length(l_str_value)-1)   , 10);

          l_fmt_num := substr(l_str_value ,1, (length(l_str_value)-1) )||l_fmt_num;

          hr_utility.set_location('Formated value  :'||l_fmt_num  , 10);

       end if;
    else   --- for {} formats
      --
      l_fmt_num := to_char(p_value, p_format_mask);
      --
    end if;
  --
  else
    --
    l_fmt_num := to_char(p_value);
    --
  end if;
  --
  return (rtrim(ltrim(l_fmt_num)));
  --
  hr_utility.set_location(' Exiting:'||l_proc, 10);
--
End apply_format_mask;
--
-- ----------------------------------------------------------------------------
-- |------------------------< apply_format_mask for string >------------------|
-- ----------------------------------------------------------------------------
Function apply_format_mask(p_value varchar2, p_format_mask varchar2
                      ) Return Varchar2 Is
--
  l_proc 	    varchar2(72) := g_package||'apply_format_mask';
  l_fmt_string      ben_ext_rslt_Dtl.val_01%type  := null;
  l_value_stripped  ben_ext_rslt_Dtl.val_01%type  := null;
  l_length          number;
  l_err_message varchar2(2000) ;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 15);
  hr_utility.set_location('value :'||p_value||' - ' || p_format_mask, 15);
  --
  if p_value is null then
    return p_value;
  end if;
  --
  --error message taken in advance so it is not called every time
  l_err_message := get_error_msg(92065,'BEN_92065_EXT_FRMT_INVALID',g_elmt_name );
  --
  if p_format_mask is not null then
    --
    hr_utility.set_location('format mask :' || p_format_mask, 16);
    l_value_stripped := translate(p_value,
                        '1234567890 !@#$%^&*()-_+={}|:"<>?,./;''[]\`~',
                        '1234567890');
    --
    l_length := length(l_value_stripped);
    --
    if p_format_mask  = '999999999' then
      --
      -- can be used for SSN
      --
      if l_length > 9 then
      --
        l_fmt_string := p_value;
      --
        ben_ext_util.write_err
        (p_err_num => 92065
        ,p_err_name => l_err_message
        ,p_typ_cd => 'W'
        ,p_person_id => g_person_id
        ,p_request_id => ben_extract.g_request_id
        ,p_ext_rslt_id => ben_extract.g_ext_rslt_id
        ,p_business_group_id => ben_ext_person.g_business_group_id
        );
      --
      else
        l_fmt_string := l_value_stripped;
      end if;
      --
    elsif p_format_mask  = '999-99-9999' then
      --
      -- can be used for SSN
      --
      if l_length = 9 then
      --
        l_fmt_string := SUBSTR(l_value_stripped, 1, 3) || '-'
                        || SUBSTR(l_value_stripped, 4, 2) || '-'
                        || SUBSTR(l_value_stripped, 6);
      --
      else
      --
        l_fmt_string := p_value;
      --
        ben_ext_util.write_err
        (p_err_num => 92065
        ,p_err_name => l_err_message
        ,p_typ_cd => 'W'
        ,p_person_id => g_person_id
        ,p_request_id => ben_extract.g_request_id
        ,p_ext_rslt_id => ben_extract.g_ext_rslt_id
        ,p_business_group_id => ben_ext_person.g_business_group_id
        );
      --
      end if;
      --
    elsif p_format_mask  = '9999999999' then
      --
      -- can be used for PHONE
      --
      if l_length > 10 then
      --
        l_fmt_string := p_value;
      --
        ben_ext_util.write_err
        (p_err_num => 92065
        ,p_err_name =>l_err_message
        ,p_typ_cd => 'W'
        ,p_person_id => g_person_id
        ,p_request_id => ben_extract.g_request_id
        ,p_ext_rslt_id => ben_extract.g_ext_rslt_id
        ,p_business_group_id => ben_ext_person.g_business_group_id
        );
      --
      else
        l_fmt_string := l_value_stripped;
      end if;
      --
    elsif p_format_mask  = '999999999999999' then
      --
      -- can be used for PHONE
      --
      if l_length > 15 then
      --
        l_fmt_string := p_value;
      --
        ben_ext_util.write_err
        (p_err_num => 92065
        ,p_err_name => l_err_message
        ,p_typ_cd => 'W'
        ,p_person_id => g_person_id
        ,p_request_id => ben_extract.g_request_id
        ,p_ext_rslt_id => ben_extract.g_ext_rslt_id
        ,p_business_group_id => ben_ext_person.g_business_group_id
        );
      --
      else
        l_fmt_string := l_value_stripped;
      end if;
      --
    elsif p_format_mask = '(999)999-9999' then
      --
      if l_length = 7 then
        l_fmt_string := '(   )'
                        || SUBSTR(l_value_stripped, 1, 3) || '-'
                        || SUBSTR(l_value_stripped, 4);
      elsif l_length = 10 then
        l_fmt_string := '(' || SUBSTR(l_value_stripped, 1, 3) || ')'
                        || SUBSTR(l_value_stripped, 4, 3) || '-'
                        || SUBSTR(l_value_stripped, 7);
      else
        l_fmt_string := p_value;
      --
        ben_ext_util.write_err
        (p_err_num => 92065
        ,p_err_name => l_err_message
        ,p_typ_cd => 'W'
        ,p_person_id => g_person_id
        ,p_request_id => ben_extract.g_request_id
        ,p_ext_rslt_id => ben_extract.g_ext_rslt_id
        ,p_business_group_id => ben_ext_person.g_business_group_id
        );
      --
      end if;
    --
    elsif p_format_mask = '999-999-9999' then
      --
      if l_length = 7 then
        l_fmt_string := SUBSTR(l_value_stripped, 1, 3) || '-'
                        || SUBSTR(l_value_stripped, 4);
      elsif l_length = 10 then
        l_fmt_string := SUBSTR(l_value_stripped, 1, 3) || '-'
                        || SUBSTR(l_value_stripped, 4, 3) || '-'
                        || SUBSTR(l_value_stripped, 7);
      else
        l_fmt_string := p_value;
      --
        ben_ext_util.write_err
        (p_err_num => 92065
        ,p_err_name => l_err_message
        ,p_typ_cd => 'W'
        ,p_person_id => g_person_id
        ,p_request_id => ben_extract.g_request_id
        ,p_ext_rslt_id => ben_extract.g_ext_rslt_id
        ,p_business_group_id => ben_ext_person.g_business_group_id
        );
      --
      end if;
    --
     elsif p_format_mask = '+1 999 999 9999' then
      --
      if l_length = 10 then
        l_fmt_string := '+1 '||SUBSTR(l_value_stripped, 1, 3) || ' '
                        || SUBSTR(l_value_stripped, 4, 3) || ' '
                        || SUBSTR(l_value_stripped, 7);
      else
        l_fmt_string := p_value;
      --
        ben_ext_util.write_err
        (p_err_num => 92065
        ,p_err_name => l_err_message
        ,p_typ_cd => 'W'
        ,p_person_id => g_person_id
        ,p_request_id => ben_extract.g_request_id
        ,p_ext_rslt_id => ben_extract.g_ext_rslt_id
        ,p_business_group_id => ben_ext_person.g_business_group_id
        );
      --
      end if;
    --

    else
      l_fmt_string := p_value;
    end if;
    --
  else
    --
    l_fmt_string := p_value;
    --
    hr_utility.set_location('value :' || l_fmt_string, 16);
  end if;
  --
  return (rtrim(ltrim(l_fmt_string)));
  --
  hr_utility.set_location(' Exiting:'||l_proc, 15);
--
End apply_format_mask;

-- ------------------------------------------------------------------
-- |------------------------< apply_format_function >----------------|
-- ------------------------------------------------------------------

Function apply_format_function(p_value varchar2, p_format_mask varchar2
                      ) Return Varchar2 Is
--
  l_proc            varchar2(72) := g_package||'apply_format_function';
  l_fmt_string      ben_ext_rslt_Dtl.val_01%type  := null;
  l_err_message varchar2(2000) ;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 15);
  hr_utility.set_location('value :'||p_value||' - ' || p_format_mask, 15);
  --
  if p_value is null then
    return p_value;
  end if;
  --
  --error message taken in advance so it is not called every time
  l_err_message := get_error_msg(92065,'BEN_92065_EXT_FRMT_INVALID',g_elmt_name );
  --

  l_fmt_string := p_value;
  if p_format_mask is not null then
    --
     if  p_format_mask = 'CUPPER' then
        l_fmt_string := Upper(p_value) ;
     elsif  p_format_mask = 'CLOWER' then
        l_fmt_string := Lower(p_value) ;
     elsif  p_format_mask = 'CINITCAP' then
        l_fmt_string := InitCap(p_value) ;
     elsif p_format_mask = 'CALPHANO' then
        l_fmt_string :=  translate(p_value,
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~`!@#$%^&*()_-+={[}]|\;:''"<,>.?/',
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789');

     else
      --
      ben_ext_util.write_err
        (p_err_num => 92065
        ,p_err_name => l_err_message
        ,p_typ_cd => 'W'
        ,p_person_id => g_person_id
        ,p_request_id => ben_extract.g_request_id
        ,p_ext_rslt_id => ben_extract.g_ext_rslt_id
        ,p_business_group_id => ben_ext_person.g_business_group_id
        );
      --
      end if;
  end if ;
  hr_utility.set_location(' Exiting:'||l_proc, 15);
  return l_fmt_string ;
end apply_format_function ;


--
-- ------------------------------------------------------------------
-- |------------------------< sprs_or_incl >------------------------|
-- ------------------------------------------------------------------
--  This function will check record or data element include condition
--  based on the change event being processed.  This function will
--  return 'I' - include, if the condition is satisfied or
--         'S' - suppress, otherwise.
--
Function sprs_or_incl(p_ext_rcd_in_file_id       number,
                      p_ext_data_elmt_in_rcd_id  number,
                      p_chg_evt_cd               varchar2
                      ) Return Varchar2 Is
--
  l_proc          varchar2(72) := g_package||'sprs_or_incl';
  l_sprs_or_incl  varchar2(1) := 'S';
  l_dummy         varchar2(1);
--
cursor incl_rcd_c is
  select null
    from ben_ext_incl_chg
   where ext_rcd_in_file_id = p_ext_rcd_in_file_id
     and chg_evt_cd = p_chg_evt_cd
     ;
--
cursor incl_elmt_c is
  select null
   from ben_ext_incl_chg
  where ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id
    and chg_evt_cd = p_chg_evt_cd
    ;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_ext_rcd_in_file_id is not null then
    --
    open incl_rcd_c;
    fetch incl_rcd_c into l_dummy;
    if incl_rcd_c%found then
       l_sprs_or_incl := 'I';
    end if;
    close incl_rcd_c;
    --
  elsif p_ext_data_elmt_in_rcd_id is not null then
     --
    open incl_elmt_c;
    fetch incl_elmt_c into l_dummy;
    if incl_elmt_c%found then
       l_sprs_or_incl := 'I';
    end if;
    close incl_elmt_c;
    --
  end if;
  --
  return (l_sprs_or_incl);
  --
  hr_utility.set_location(' Exiting:'||l_proc, 15);
--
End sprs_or_incl;
--
--
--
end ben_ext_fmt;

/
