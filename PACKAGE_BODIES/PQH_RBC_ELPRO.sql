--------------------------------------------------------
--  DDL for Package Body PQH_RBC_ELPRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RBC_ELPRO" as
/* $Header: pqrbcelp.pkb 120.0 2005/10/06 14:52 srajakum noship $ */

g_package  Varchar2(30) := 'pqh_rbc_stage_to_rbc';

 procedure get_criteria_details (p_short_code in varchar2,
                                 p_business_group_id in number,
                                 p_criteria_id out nocopy number,
                                 P_CRIT_COL1_DATATYPE out nocopy varchar2,
                                 p_CRITERIA_TYPE OUT nocopy VARCHAR2,
                                 p_ALLOW_RANGE_VALIDATION_FLAG out nocopy varchar2,
                                 p_CRIT_COL1_VAL_TYPE_CD out nocopy varchar2,
                                 P_CRIT_COL2_DATATYPE out nocopy varchar2,
                                 p_ALLOW_RANGE_VALIDATION_FLAG2 out nocopy varchar2,
                                 p_CRIT_COL2_VAL_TYPE_CD out nocopy varchar2
                                ) is
 Begin

 Select ELIGY_CRITERIA_ID, CRIT_COL1_DATATYPE,
        CRITERIA_TYPE, ALLOW_RANGE_VALIDATION_FLAG,
        CRIT_COL1_VAL_TYPE_CD,CRIT_COL2_DATATYPE,
        ALLOW_RANGE_VALIDATION_FLAG2,CRIT_COL2_VAL_TYPE_CD
 into   p_criteria_id, P_CRIT_COL1_DATATYPE,
        p_CRITERIA_TYPE, p_ALLOW_RANGE_VALIDATION_FLAG,
        p_CRIT_COL1_VAL_TYPE_CD, P_CRIT_COL2_DATATYPE,
        p_ALLOW_RANGE_VALIDATION_FLAG2,p_CRIT_COL2_VAL_TYPE_CD
 from   ben_eligy_criteria
 where  short_code = p_short_code
 and    business_group_id = p_business_group_id;


 exception
   when no_data_found then
    begin
      hr_utility.set_location('Criteria details not found for the short_code '||p_short_code||' For business group '||p_business_group_id, 20);
      Select ELIGY_CRITERIA_ID, CRIT_COL1_DATATYPE,
        CRITERIA_TYPE, ALLOW_RANGE_VALIDATION_FLAG,
        CRIT_COL1_VAL_TYPE_CD,CRIT_COL2_DATATYPE,
        ALLOW_RANGE_VALIDATION_FLAG2,CRIT_COL2_VAL_TYPE_CD
      into   p_criteria_id, P_CRIT_COL1_DATATYPE,
        p_CRITERIA_TYPE, p_ALLOW_RANGE_VALIDATION_FLAG,
        p_CRIT_COL1_VAL_TYPE_CD, P_CRIT_COL2_DATATYPE,
        p_ALLOW_RANGE_VALIDATION_FLAG2,p_CRIT_COL2_VAL_TYPE_CD
      from   ben_eligy_criteria
      where  short_code = p_short_code
      and    business_group_id is null;
     end;
   when too_many_rows then
      hr_utility.set_location('More than one row found for the short_code '||p_short_code, 20);
      raise;
   when others then
       hr_utility.set_location('Issue in getting details for the short_code '||p_short_code, 20);
      raise;
 End get_criteria_details;


procedure create_elpro(p_name              in varchar2,
                       p_description       in varchar2,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_elig_prfl_id      out nocopy number) is

l_proc             varchar2(61) := g_package||'create_elpro';
l_elp_id           number;
l_effective_start_date date;
l_effective_end_date date;
l_elp_ovn  number;

Begin

hr_utility.set_location('inside '||l_proc,10);

   BEN_ELIGY_PROFILE_API.CREATE_ELIGY_PROFILE(
             P_EFFECTIVE_DATE                  => p_effective_date
             ,P_BUSINESS_GROUP_ID              => p_business_group_id
             ,P_ASMT_TO_USE_CD                 => 'ANY'
             ,P_BNFT_CAGR_PRTN_CD              => 'BNFT'
             ,P_DESCRIPTION                    => p_description
             ,P_ELIGY_PRFL_ID                  => l_elp_id
             ,P_NAME                           => p_name
             ,P_STAT_CD                        => 'A'
             ,P_EFFECTIVE_START_DATE           => l_effective_start_date
             ,P_EFFECTIVE_END_DATE             => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER          => l_elp_ovn
             );

hr_utility.set_location('Leaving '||l_proc,10);

p_elig_prfl_id := l_elp_id;

End create_elpro;


procedure create_criteria (p_criteria_code              in varchar2,
                           p_char_value1       in varchar2 default null,
                           p_char_value2       in varchar2 default null,
                           p_char_value3       in varchar2 default null,
                           p_char_value4       in varchar2 default null,
                           p_number_value1     in number default null,
                           p_number_value2     in number default null,
                           p_number_value3     in number default null,
                           p_number_value4     in number default null,
                           p_date_value1       in date default null,
                           p_date_value2       in date default null,
                           p_date_value3       in date default null,
                           p_date_value4       in date default null,
                           p_business_group_id in number default null,
                           p_effective_date    in date,
                           p_elig_prfl_id      in number
                           ) is

l_proc             varchar2(61) := g_package||'create_criteria';
l_elp_id           number;
l_effective_start_date date;
l_effective_end_date date;
l_crit_ovn  number;
l_criteria_id number;
l_CRIT_COL1_DATATYPE varchar2(80);
l_CRITERIA_TYPE  VARCHAR2(80);
l_ALLOW_RANGE_VALIDATION_FLAG varchar2(1);
l_CRIT_COL1_VAL_TYPE_CD varchar2(80);
l_crit_values_id  number;
l_criteria_value1 varchar2(80);
l_criteria_value2 varchar2(80);
l_criteria_value3 varchar2(80);
l_criteria_value4 varchar2(80);
l_ALLOW_RANGE_VALIDATION_FLAG2 varchar2(1);
l_CRIT_COL2_VAL_TYPE_CD varchar2(80);
l_CRIT_COL2_DATATYPE varchar2(80);
l_criteria_typ_id number;
Begin

hr_utility.set_location('inside '||l_proc,10);

-- get_criteria_details
get_criteria_details (p_short_code                  => p_criteria_code,
                      p_business_group_id           => p_business_group_id,
                      p_criteria_id                 => l_criteria_typ_id,
                      P_CRIT_COL1_DATATYPE          => l_CRIT_COL1_DATATYPE,
                      p_CRITERIA_TYPE               => l_CRITERIA_TYPE,
                      p_ALLOW_RANGE_VALIDATION_FLAG => l_ALLOW_RANGE_VALIDATION_FLAG,
                      p_CRIT_COL1_VAL_TYPE_CD       => l_CRIT_COL1_VAL_TYPE_CD,
                      P_CRIT_COL2_DATATYPE          => l_CRIT_COL2_DATATYPE,
                      p_ALLOW_RANGE_VALIDATION_FLAG2 => l_ALLOW_RANGE_VALIDATION_FLAG2,
                      p_CRIT_COL2_VAL_TYPE_CD       => l_CRIT_COL2_VAL_TYPE_CD
                     );
if l_CRITERIA_TYPE = 'USER' then
-- User defined criteria
hr_utility.set_location('User defined criteria ',10);

ben_eligy_crit_values_api.create_eligy_crit_values
                         (
                          p_eligy_crit_values_id   => l_crit_values_id
                         ,p_eligy_prfl_id          => p_elig_prfl_id
                         ,p_eligy_criteria_id      => l_criteria_typ_id
                         ,p_effective_start_date   => l_effective_start_date
                         ,p_effective_end_date     => l_effective_end_date
                         ,p_number_value1          => p_number_value1
                         ,p_number_value2          => p_number_value2
                         ,p_char_value1            => p_char_value1
                         ,p_char_value2            => p_char_value2
                         ,p_date_value1            => p_date_value1
                         ,p_date_value2            => p_date_value2
                         ,p_business_group_id      => p_business_group_id
                         ,p_object_version_number  => l_crit_ovn
                         ,p_effective_date         => p_effective_date
                         ,p_char_value3            => p_char_value3
                         ,p_char_value4            => p_char_value4
                         ,p_number_value3          => p_number_value3
                         ,p_number_value4          => p_number_value4
                         ,p_date_value3            => p_date_value3
                         ,p_date_value4            => p_date_value4
                         );

elsif l_CRITERIA_TYPE = 'STD' then
hr_utility.set_location('Standard criteria ',10);


 if  l_CRIT_COL1_VAL_TYPE_CD is not null then
   if  l_CRIT_COL1_DATATYPE = 'N' then
       l_criteria_value1 := to_char(p_number_value1);
       l_criteria_value2 := to_char(p_number_value2);
   elsif l_CRIT_COL1_DATATYPE = 'C' then
       l_criteria_value1 := p_char_value1;
       l_criteria_value2 := p_char_value2;
   elsif l_CRIT_COL1_DATATYPE = 'D' then
       l_criteria_value1 := to_char(p_date_value1,'dd-mm-yyyy');
       l_criteria_value2 := to_char(p_date_value2,'dd-mm-yyyy');
   end if;
end if;

if  l_CRIT_COL2_VAL_TYPE_CD is not null then
   if  l_CRIT_COL2_DATATYPE = 'N' then
       l_criteria_value3 := to_char(p_number_value3);
       l_criteria_value4 := to_char(p_number_value4);
   elsif l_CRIT_COL2_DATATYPE = 'C' then
       l_criteria_value3 := p_char_value3;
       l_criteria_value4 := p_char_value4;
   elsif l_CRIT_COL2_DATATYPE = 'D' then
       l_criteria_value3 := to_char(p_date_value3,'dd-mm-yyyy');
       l_criteria_value4 := to_char(p_date_value4,'dd-mm-yyyy');
   end if;
end if;


   if p_criteria_code = 'EAN' then
       ben_ELIG_ASNT_SET_PRTE_api.create_ELIG_ASNT_SET_PRTE
                                 (p_elig_asnt_set_prte_id      => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_assignment_set_id          => l_criteria_value1
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date
                                 );
   elsif p_criteria_code = 'EAP' then
      ben_ELIG_AGE_PRTE_api.create_ELIG_AGE_PRTE
                      (p_elig_age_prte_id               => l_criteria_id
                      ,p_effective_start_date           => l_effective_start_date
                      ,p_effective_end_date             => l_effective_end_date
                      ,p_business_group_id              => p_business_group_id
                      ,p_age_fctr_id                    => to_number(l_criteria_value1)
                      ,p_eligy_prfl_id                  => p_elig_prfl_id
                      ,p_excld_flag                 => 'N'
                      ,p_object_version_number          => l_crit_ovn
                      ,p_effective_date                 => p_effective_date
                      );
   elsif p_criteria_code = 'EBN' then
     ben_ELIG_BENFTS_GRP_PRTE_api.create_ELIG_BENFTS_GRP_PRTE
                              (p_elig_benfts_grp_prte_id        => l_criteria_id
                              ,p_effective_start_date           => l_effective_start_date
                              ,p_effective_end_date             => l_effective_end_date
                              ,p_benfts_grp_id                  => to_number(l_criteria_value1)
                              ,p_eligy_prfl_id                  => p_elig_prfl_id
                              ,p_excld_flag                 => 'N'
                              ,p_business_group_id              => p_business_group_id
                              ,p_object_version_number          => l_crit_ovn
                              ,p_effective_date                 => p_effective_date
                             );
   elsif p_criteria_code = 'EBU' then
     ben_ELIG_BRGNG_UNIT_PRTE_api.create_ELIG_BRGNG_UNIT_PRTE
                                 (p_elig_brgng_unit_prte_id        => l_criteria_id
                                 ,p_effective_start_date           => l_effective_start_date
                                 ,p_effective_end_date             => l_effective_end_date
                                 ,p_brgng_unit_cd                  => l_criteria_value1
                                 ,p_eligy_prfl_id                  => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id              => p_business_group_id
                                 ,p_object_version_number          => l_crit_ovn
                                 ,p_effective_date                 => p_effective_date);
    elsif p_criteria_code = 'ECL' then
     ben_ELIG_COMP_LVL_PRTE_api.create_ELIG_COMP_LVL_PRTE
                                 (p_elig_comp_lvl_prte_id        => l_criteria_id
                                 ,p_effective_start_date           => l_effective_start_date
                                 ,p_effective_end_date             => l_effective_end_date
                                 ,p_comp_lvl_fctr_id               => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id                  => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id              => p_business_group_id
                                 ,p_object_version_number          => l_crit_ovn
                                 ,p_effective_date                 => p_effective_date);
    elsif p_criteria_code = 'ECP' then
     ben_ELIG_CMBN_AGE_LOS_api.create_ELIG_CMBN_AGE_LOS
                                 (p_elig_cmbn_age_los_prte_id      => l_criteria_id
                                 ,p_effective_start_date           => l_effective_start_date
                                 ,p_effective_end_date             => l_effective_end_date
                                 ,p_cmbn_age_los_fctr_id           => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id                  => p_elig_prfl_id
                                 ,p_excld_flag                     => 'N'
                                 ,p_mndtry_flag                    => 'N'
                                 ,p_business_group_id              => p_business_group_id
                                 ,p_object_version_number          => l_crit_ovn
                                 ,p_effective_date                 => p_effective_date);
   elsif p_criteria_code = 'ECY' then
     ben_ELIG_COMPTNCY_PRTE_api.create_ELIG_COMPTNCY_PRTE
                                 (p_ELIG_COMPTNCY_PRTE_id      => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_competence_id              => to_number(l_criteria_value1)
                                 ,p_rating_level_id            => to_number(l_criteria_value3)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
    elsif p_criteria_code = 'EDB' then
     ben_ELIG_DSBLD_PRTE_api.create_ELIG_DSBLD_PRTE
                                 (p_elig_dsbld_prte_id      => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_dsbld_cd                   => l_criteria_value1
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'EES' then
     ben_ELIG_EE_STAT_PRTE_api.create_ELIG_EE_STAT_PRTE
                                 (p_elig_ee_stat_prte_id      => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_assignment_status_type_id  => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'EFP' then
     ben_ELIG_FL_TM_PT_TM_PRTE_api.create_ELIG_FL_TM_PT_TM_PRTE
                                 (p_elig_fl_tm_pt_tm_prte_id   =>  l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_fl_tm_pt_tm_cd             => l_criteria_value1
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'EGN' then
     ben_elig_gndr_prte_api.create_elig_gndr_prte
                                 (p_elig_gndr_prte_id          =>  l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_sex                        => l_criteria_value1
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'EHS' then
     ben_ELIG_HRLY_SLRD_PRTE_api.create_ELIG_HRLY_SLRD_PRTE
                                 (p_elig_hrly_slrd_prte_id     =>  l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_hrly_slrd_cd               => l_criteria_value1
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'EHW' then
     ben_ELIG_HRS_WKD_PRTE_api.create_ELIG_HRS_WKD_PRTE
                                 (p_elig_hrs_wkd_prte_id       =>  l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_hrs_wkd_in_perd_fctr_id    => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'EJP' then
     ben_ELIGY_JOB_PRTE_api.create_ELIGY_JOB_PRTE
                                 (p_elig_job_prte_id           =>  l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_job_id                     => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'ELN' then
     ben_ELIG_LGL_ENTY_PRTE_api.create_ELIG_LGL_ENTY_PRTE
                                 (p_elig_lgl_enty_prte_id      =>  l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_organization_id            => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'ELR' then
     ben_ELIG_LOA_RSN_PRTE_api.create_ELIG_LOA_RSN_PRTE
                                 (p_elig_loa_rsn_prte_id      =>  l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_absence_attendance_type_id => to_number(l_criteria_value1)
                                 ,p_abs_attendance_reason_id   => to_number(l_criteria_value3)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
    elsif p_criteria_code = 'ELS' then
     ben_ELIG_LOS_PRTE_api.create_ELIG_LOS_PRTE
                                 (p_elig_los_prte_id           =>  l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_los_fctr_id                => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
    elsif p_criteria_code = 'ELV' then
     ben_ELIG_LVG_RSN_PRTE_api.create_ELIG_LVG_RSN_PRTE
                                 (p_elig_lvg_rsn_prte_id       => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_lvg_rsn_cd                 => l_criteria_value1
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
      elsif p_criteria_code = 'EOM' then
     ben_ELIG_OPTD_MDCR_PRTE_api.create_ELIG_OPTD_MDCR_PRTE
                                 (p_elig_optd_mdcr_prte_id     => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_optd_mdcr_flag             => l_criteria_value1
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_exlcd_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'EOU' then
     ben_ELIG_ORG_UNIT_PRTE_api.create_ELIG_ORG_UNIT_PRTE
                                 (p_elig_org_unit_prte_id      => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_organization_id            => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
    elsif p_criteria_code = 'EPB' then
     ben_ELIG_PY_BSS_PRTE_api.create_ELIG_PY_BSS_PRTE
                                 (p_elig_py_bss_prte_id        => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_pay_basis_id               => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
    elsif p_criteria_code = 'EPF' then
     ben_ELIG_PCT_FL_TM_PRTE_api.create_ELIG_PCT_FL_TM_PRTE
                                 (p_elig_pct_fl_tm_prte_id    => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_pct_fl_tm_fctr_id          => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'EPS' then
     ben_ELIG_PSTN_PRTE_api.create_ELIG_PSTN_PRTE
                                 (p_ELIG_PSTN_PRTE_id          => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_position_id                => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'EPT' then
     ben_ELIG_PER_TYP_PRTE_api.create_ELIG_PER_TYP_PRTE
                                 (p_elig_per_typ_prte_id       => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_person_type_id             => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'EPY' then
     ben_ELIG_PYRL_PRTE_api.create_ELIG_PYRL_PRTE
                                 (p_elig_pyrl_prte_id       => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_payroll_id                 => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
    elsif p_criteria_code = 'EPZ' then
     ben_ELIG_PSTL_CD_RNG_PRTE_api.create_ELIG_PSTL_CD_RNG_PRTE
                                 (p_elig_pstl_cd_r_rng_prte_id => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_pstl_zip_rng_id            => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     elsif p_criteria_code = 'EQG' then
     ben_ELIG_QUA_IN_GR_PRTE_api.create_ELIG_QUA_IN_GR_PRTE
                                 (p_ELIG_QUA_IN_GR_PRTE_id     => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_quar_in_grade_cd           => l_criteria_value1
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
      elsif p_criteria_code = 'EQT' then
     ben_elig_qual_titl_prte_api.create_elig_qual_titl_prte
                                 (p_elig_qual_titl_prte_id     => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_title                      => l_criteria_value3
                                 ,p_qualification_type_id      => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
      elsif p_criteria_code = 'ERG' then
     ben_ELIG_PERF_RTNG_PRTE_api.create_ELIG_PERF_RTNG_PRTE
                                 (p_ELIG_PERF_RTNG_PRTE_id     => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_event_type                 => l_criteria_value1
                                 ,p_perf_rtng_cd               => l_criteria_value3
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
       elsif p_criteria_code = 'ESA' then
     ben_elig_svc_area_prte_api.create_elig_svc_area_prte
                                 (p_elig_svc_area_prte_id     => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_svc_area_id                => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
      elsif p_criteria_code = 'ETU' then
     ben_ELIG_TBCO_USE_PRTE_api.create_ELIG_TBCO_USE_PRTE
                                 (p_elig_tbco_use_prte_id     => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_uses_tbco_flag             => l_criteria_value1
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
       elsif p_criteria_code = 'EWL' then
     ben_ELIG_WK_LOC_PRTE_api.create_ELIG_WK_LOC_PRTE
                                 (p_elig_wk_loc_prte_id     => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_location_id                => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
       elsif p_criteria_code = 'EPF' then
     ben_ELIG_PCT_FL_TM_PRTE_api.create_ELIG_PCT_FL_TM_PRTE
                                 (p_elig_pct_fl_tm_prte_id     => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_pct_fl_tm_fctr_id          => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
       elsif p_criteria_code = 'EGR' then
     ben_ELIG_GRD_PRTE_api.create_ELIG_GRD_PRTE
                                 (p_elig_grd_prte_id     => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_grade_id                   => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
       elsif p_criteria_code = 'ELU' then
     ben_ELIG_LBR_MMBR_PRTE_api.create_ELIG_LBR_MMBR_PRTE
                                 (p_elig_lbr_mmbr_prte_id     => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_lbr_mmbr_flag              => l_criteria_value1
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
      elsif p_criteria_code = 'EPG' then
      ben_ELIG_PPL_GRP_PRTE_api.create_ELIG_PPL_GRP_PRTE
                                 (p_elig_ppl_grp_prte_id     => l_criteria_id
                                 ,p_effective_start_date       => l_effective_start_date
                                 ,p_effective_end_date         => l_effective_end_date
                                 ,p_people_group_id            => to_number(l_criteria_value1)
                                 ,p_eligy_prfl_id              => p_elig_prfl_id
                                 ,p_excld_flag                 => 'N'
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_object_version_number      => l_crit_ovn
                                 ,p_effective_date             => p_effective_date);
     end if;
else
hr_utility.set_location('Not a valid criteria type ',10);


End if;



hr_utility.set_location('Leaving '||l_proc,10);

-- p_elig_prfl_id := l_elp_id;

End create_criteria;



end PQH_RBC_ELPRO;

/
