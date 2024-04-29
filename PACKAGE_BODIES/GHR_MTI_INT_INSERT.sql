--------------------------------------------------------
--  DDL for Package Body GHR_MTI_INT_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MTI_INT_INSERT" AS
/* $Header: ghrmtins.pkb 120.1.12010000.2 2009/08/07 09:42:44 utokachi ship $ */

procedure main_convert(
                p_transfer_name                 IN varchar2,
                p_process_date                  IN date,
                p_effective_date                IN date,
                p_source                        IN varchar2,
                p_status                        IN varchar2,
                p_person_id                     IN OUT NOCOPY number,
                p_inter_bg_transfer             IN varchar2,
                p_date_of_birth                 IN date,
                p_effective_end_date            IN date,
                p_effective_start_date          IN date,
                p_first_name                    IN varchar2,
                p_full_name                     IN varchar2,
                p_last_name                     IN varchar2,
                p_marital_status                IN varchar2,
                p_middle_names                  IN varchar2,
                p_national_identifier           IN varchar2,
                p_nationality                   IN varchar2,
                p_rehire_reason                 IN varchar2,
                p_sex                           IN varchar2,
                p_start_date                    IN date,
                p_title                         IN varchar2,
                p_work_telephone                IN varchar2,
                p_citizenship                   IN varchar2,
                p_veterans_preference           IN varchar2,
                p_veterans_preference_for_RIF   IN varchar2,
                p_veterans_status               IN varchar2,
                p_appointment_type              IN varchar2,
                p_type_of_employment            IN varchar2,
                p_race_or_national_origin       IN varchar2,
                p_agency_code_transfer_from     IN varchar2,
                p_orig_appointment_auth_code_1  IN varchar2,
		p_orig_appt_auth_code_1_desc	IN varchar2,--Bug# 8724192
                p_orig_appointment_auth_code_2  IN varchar2,
		p_orig_appt_auth_code_2_desc	IN varchar2,--Bug# 8724192
                p_handicap_code                 IN varchar2,
                p_service_comp_date             IN date,
		-- Bug 2412656 Added FERS Coverage
		p_fers_coverage                 IN VARCHAR2,
                p_previous_retirement_coverage  IN varchar2,
                p_frozen_service                IN varchar2,
                p_Creditable_Military_Service   IN varchar2,
                p_flsa_category                 IN varchar2,
                p_bargaining_unit_status        IN varchar2,
                p_functional_class              IN varchar2,
                p_position_working_title        IN varchar2,
                p_supervisory_status            IN varchar2,
                p_position_occupied             IN varchar2,
                p_appropriation_code1           IN varchar2,
                p_appropriation_code2           IN varchar2,
                p_total_salary                  IN number,
                p_basic_salary_rate             IN number,
                p_locality_adjustment           IN number,
                p_adjusted_basic_pay            IN number,
                p_other_pay                     IN number,
                p_fegli                         IN varchar2,
                p_retirement_plan               IN varchar2,
                p_retention_allowance           IN number,
                p_staffing_differential         IN number,
                p_supervisory_differential      IN number,
                p_wgi_date_due                  IN date,
                p_fegli_desc                    IN varchar2,
                p_retirement_plan_desc          IN varchar2,
                p_au_overtime                   IN number,
                p_availability_pay              IN number,
                p_auo_premium_pay_indicator     IN varchar2,
                p_ap_premium_pay_indicator      IN varchar2,
                p_to_position_id                IN number,
                p_from_grade_or_level           IN varchar2,
                p_from_pay_plan                 IN varchar2,
                p_from_position_title           IN varchar2,
                p_from_position_seq_num         IN number,
                p_duty_station_code             IN varchar2,
                p_duty_station_desc             IN varchar2,
                p_from_step_or_rate             IN varchar2,
                p_tenure                        IN varchar2,
                p_annuitant_indicator           IN varchar2,
                p_pay_rate_determinant          IN varchar2,
                p_work_schedule                 IN varchar2,
                p_part_time_hours               IN number,
                p_date_arrivd_personnel_office  IN date,
                p_non_disclosure_agmt_status    IN varchar2,
                p_part_time_indicator           IN varchar2,
                p_qualif_standards_waiver       IN varchar2,
                p_education_level               IN varchar2,
                p_academic_discipline           IN varchar2,
                p_year_degree_attained          IN varchar2,
		-- Changes 4093771
	        p_to_total_salary               IN number,
                p_to_basic_salary_rate          IN number,
                p_to_adjusted_basic_pay         IN number,
		-- End Changes 4093771
		--Begin Bug# 8724192
		p_assignment_nte_start_date	IN date,
		p_assignment_nte		IN date
		--end Bug# 8724192
		) is

cursor cur_pid is
select ghr_interface_2_s.nextval nvalue from dual;

l_person_id              number;
l_assignment_id          number;
l_position_id            number;
l_action                 varchar2(30);
l_person_id_nc           number; --For NOCOPY Changes

begin
       l_person_id_nc      := p_person_id ; --NOCOPY Changes
       if p_person_id is null then
                 l_action := 'INSERT';
                 for cur_pid_rec in cur_pid
                     loop
                          l_person_id     := cur_pid_rec.nvalue;
                          l_assignment_id := l_person_id;
                          l_position_id   := l_person_id;
                          exit;
                     end loop;
       else
                 l_action := 'UPDATE';
                 l_person_id := p_person_id;
       end if;

p_person_id := l_person_id;

if l_action = 'INSERT' then
      map_mtv_to_assign_f(
                  p_transfer_name          => p_transfer_name,
                  p_effective_date         => p_effective_date,
                  p_assignment_id          => l_assignment_id );

      map_mtv_to_position(
                  p_transfer_name          => p_transfer_name,
                  p_person_id              => l_person_id,
                  p_effective_date         => p_effective_date,
                  p_position_id            => l_position_id );
end if;

map_mtv_to_people_f(
p_transfer_name                  =>   p_transfer_name,
p_inter_bg_transfer              =>   p_inter_bg_transfer,
p_effective_date                 =>   p_effective_date,
p_person_id                      =>   l_person_id,
p_date_of_birth                  =>   p_date_of_birth,
p_effective_end_date             =>   p_effective_end_date,
p_effective_start_date           =>   p_effective_start_date,
p_first_name                     =>   p_first_name,
p_full_name                      =>   p_full_name,
p_last_name                      =>   p_last_name,
p_marital_status                 =>   p_marital_status,
p_middle_names                   =>   p_middle_names,
p_national_identifier            =>   p_national_identifier,
p_nationality                    =>   p_nationality,
p_rehire_reason                  =>   p_rehire_reason,
p_sex                            =>   p_sex,
p_start_date                     =>   p_start_date,
p_title                          =>   p_title,
p_work_telephone                 =>   p_work_telephone,
p_action                         =>   l_action );

map_mtv_to_people_ei1(
p_transfer_name                  =>   p_transfer_name,
p_effective_date                 =>   p_effective_date,
p_person_id                      =>   l_person_id,
p_citizenship                    =>   p_citizenship,
p_veterans_preference            =>   p_veterans_preference,
p_veterans_preference_for_RIF    =>   p_veterans_preference_for_RIF,
p_veterans_status                =>   p_veterans_status,
p_action                         =>   l_action );

map_mtv_to_people_ei2(
p_transfer_name                  =>   p_transfer_name,
p_effective_date                 =>   p_effective_date,
p_person_id                      =>   l_person_id,
p_appointment_type               =>   p_appointment_type,
p_type_of_employment             =>   p_type_of_employment,
p_race_or_national_origin        =>   p_race_or_national_origin,
-- p_agency_code_transfer_from      =>   p_agency_code_transfer_from,
p_orig_appointment_auth_code_1   =>   p_orig_appointment_auth_code_1,
p_orig_appt_auth_code_1_desc	 =>   p_orig_appt_auth_code_1_desc, --Bug# 8724192
p_orig_appointment_auth_code_2   =>   p_orig_appointment_auth_code_2,
p_orig_appt_auth_code_2_desc	 =>   p_orig_appt_auth_code_2_desc, --Bug# 8724192
p_handicap_code                  =>   p_handicap_code,
p_action                         =>   l_action );

map_mtv_to_people_ei3(
p_transfer_name                  =>   p_transfer_name,
p_effective_date                 =>   p_effective_date,
p_person_id                      =>   l_person_id,
p_service_comp_date              =>   p_service_comp_date,
p_action                         =>   l_action );

-- Bug 2412656 Added FERS Coverage
map_mtv_to_people_ei4(
p_transfer_name                  =>   p_transfer_name,
p_effective_date                 =>   p_effective_date,
p_person_id                      =>   l_person_id,
p_fers_coverage                  =>   p_fers_coverage,
p_previous_retirement_coverage   =>   p_previous_retirement_coverage,
p_frozen_service                 =>   p_frozen_service,
p_action                         =>   l_action );

map_mtv_to_people_ei5(
p_transfer_name                  =>   p_transfer_name,
p_effective_date                 =>   p_effective_date,
p_person_id                      =>   l_person_id,
p_creditable_military_service    =>   p_creditable_military_service,
p_action                         =>   l_action );

map_mtv_to_position_ei1(
p_transfer_name                  =>   p_transfer_name,
p_person_id                      =>   l_person_id,
p_effective_date                 =>   p_effective_date,
p_flsa_category                  =>   p_flsa_category,
p_bargaining_unit_status         =>   p_bargaining_unit_status,
p_functional_class               =>   p_functional_class,
p_position_working_title         =>   p_position_working_title,
p_supervisory_status             =>   p_supervisory_status,
p_action                         =>   l_action );

map_mtv_to_position_ei2(
p_transfer_name                  =>   p_transfer_name,
p_person_id                      =>   l_person_id,
p_effective_date                 =>   p_effective_date,
p_position_occupied              =>   p_position_occupied,
p_appropriation_code1            =>   p_appropriation_code1,
p_appropriation_code2            =>   p_appropriation_code2,
p_action                         =>   l_action );

map_mtv_to_element_entries(
p_transfer_name                  =>   p_transfer_name,
p_person_id                      =>   l_person_id,
p_effective_date                 =>   p_effective_date,
p_total_salary                   =>   p_total_salary,
p_basic_salary_rate              =>   p_basic_salary_rate,
p_locality_adjustment            =>   p_locality_adjustment,
p_adjusted_basic_pay             =>   p_adjusted_basic_pay,
p_other_pay                      =>   p_other_pay,
p_fegli                          =>   p_fegli,
p_retirement_plan                =>   p_retirement_plan,
p_retention_allowance            =>   p_retention_allowance,
p_staffing_differential          =>   p_staffing_differential,
p_supervisory_differential       =>   p_supervisory_differential,
p_wgi_date_due                   =>   p_wgi_date_due,
p_fegli_desc                     =>   p_fegli_desc,
p_retirement_plan_desc           =>   p_retirement_plan_desc,
p_au_overtime                    =>   p_au_overtime,
p_availability_pay               =>   p_availability_pay,
p_auo_premium_pay_indicator      =>   p_auo_premium_pay_indicator,
p_ap_premium_pay_indicator       =>   p_ap_premium_pay_indicator,
-- Changes 4093771
p_to_total_salary                =>   p_to_total_salary,
p_to_basic_salary_rate           =>   p_to_basic_salary_rate ,
p_to_adjusted_basic_pay          =>   p_to_adjusted_basic_pay ,
-- End Changes 4093771
p_action                         =>   l_action );

map_mtv_to_misc(
p_transfer_name                  =>   p_transfer_name,
p_person_id                      =>   l_person_id,
p_effective_date                 =>   p_effective_date,
p_to_position_id                 =>   p_to_position_id,
p_from_grade_or_level            =>   p_from_grade_or_level,
p_from_pay_plan                  =>   p_from_pay_plan,
p_from_position_title            =>   p_from_position_title,
p_from_position_seq_num          =>   p_from_position_seq_num ,
p_duty_station_code              =>   p_duty_station_code,
p_duty_station_desc              =>   p_duty_station_desc,
--VSM
p_from_agency_code               =>   p_agency_code_transfer_from,
p_action                         =>   l_action );

map_mtv_to_assign_ei1(
p_transfer_name                  =>   p_transfer_name,
p_person_id                      =>   l_person_id,
p_effective_date                 =>   p_effective_date,
p_from_step_or_rate              =>   p_from_step_or_rate,
p_tenure                         =>   p_tenure,
p_annuitant_indicator            =>   p_annuitant_indicator,
p_pay_rate_determinant           =>   p_pay_rate_determinant,
p_work_schedule                  =>   p_work_schedule,
p_part_time_hours                =>   p_part_time_hours,
p_action                         =>   l_action );

map_mtv_to_assign_ei2(
p_transfer_name                  =>   p_transfer_name,
p_person_id                      =>   l_person_id,
p_effective_date                 =>   p_effective_date,
p_date_arrivd_personnel_office   =>   p_date_arrivd_personnel_office,
p_non_disclosure_agmt_status     =>   p_non_disclosure_agmt_status,
p_part_time_indicator            =>   p_part_time_indicator,
p_qualif_standards_waiver        =>   p_qualif_standards_waiver,
p_action                         =>   l_action );

--Begin Bug# 8724192
map_mtv_to_assign_ei3(
p_transfer_name                  =>   p_transfer_name,
p_person_id                      =>   l_person_id,
p_effective_date                 =>   p_effective_date,
p_assignment_nte_start_date      =>   p_assignment_nte_start_date,
p_assignment_nte		 =>   p_assignment_nte,
p_action                         =>   l_action );
--End Bug# 8724192

map_mtv_to_special_info(
p_transfer_name                  =>   p_transfer_name,
p_effective_date                 =>   p_effective_date,
p_person_id                      =>   l_person_id,
p_education_level                =>   p_education_level,
p_academic_discipline            =>   p_academic_discipline,
p_year_degree_attained           =>   p_year_degree_attained,
p_action                         =>   l_action );

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters


       p_person_id         :=l_person_id_nc;
   RAISE;

end;

procedure map_mtv_to_people_f(
		p_transfer_name		IN varchar2,
		p_inter_bg_transfer	IN varchar2,
		p_effective_date	IN date,
                p_person_id             IN number,
                p_date_of_birth         IN date,
                p_effective_end_date    IN date,
                p_effective_start_date  IN date,
                p_first_name            IN varchar2,
                p_full_name             IN varchar2,
                p_last_name             IN varchar2,
                p_marital_status        IN varchar2,
                p_middle_names          IN varchar2,
                p_national_identifier   IN varchar2,
                p_nationality           IN varchar2,
                p_rehire_reason         IN varchar2,
                p_sex                   IN varchar2,
                p_start_date            IN date,
                p_title                 IN varchar2,
                p_work_telephone        IN varchar2,
                p_action                IN varchar2 )  is

l_people_f_rec           per_all_people_f%ROWTYPE;

begin
    l_people_f_rec.PERSON_ID                   := p_person_id;
    l_people_f_rec.EFFECTIVE_START_DATE        := p_effective_start_date;
    l_people_f_rec.EFFECTIVE_END_DATE          := p_effective_end_date;
    l_people_f_rec.LAST_NAME                   := p_last_name;
    l_people_f_rec.START_DATE                  := p_start_date;
    l_people_f_rec.DATE_OF_BIRTH               := p_date_of_birth;
    l_people_f_rec.FIRST_NAME                  := p_first_name;
    l_people_f_rec.FULL_NAME                   := p_full_name;
    l_people_f_rec.MARITAL_STATUS              := p_marital_status;
    l_people_f_rec.MIDDLE_NAMES                := p_middle_names;
    l_people_f_rec.NATIONALITY                 := p_nationality;
    l_people_f_rec.NATIONAL_IDENTIFIER         := p_national_identifier;
    l_people_f_rec.SEX                         := p_sex;
    l_people_f_rec.TITLE                       := p_title;
    l_people_f_rec.WORK_TELEPHONE              := p_work_telephone;
    l_people_f_rec.REHIRE_REASON               := p_rehire_reason;

    if p_action = 'INSERT' then
       ghr_mto_int.insert_people_f
            ( p_transfer_name        =>   p_transfer_name,
              p_inter_bg_transfer    =>   p_inter_bg_transfer,
              p_effective_date       =>   p_effective_date,
              ppf                    =>   l_people_f_rec);
    else
       ghr_mto_int.update_people_f
            ( p_transfer_name        =>   p_transfer_name,
              p_inter_bg_transfer    =>   p_inter_bg_transfer,
              p_effective_date       =>   p_effective_date,
              ppf                    =>   l_people_f_rec);
    end if;
end;

procedure map_mtv_to_people_ei1(
                p_transfer_name                 IN varchar2,
                p_effective_date                IN date,
                p_person_id                     IN number,
                p_citizenship                   IN varchar2,
                p_veterans_preference           IN varchar2,
                p_veterans_preference_for_RIF   IN varchar2,
                p_veterans_status               IN varchar2,
                p_action                        IN varchar2  ) is

l_people_ei1_rec      per_people_extra_info%ROWTYPE;

begin
    l_people_ei1_rec.person_id                := p_person_id;
    l_people_ei1_rec.INFORMATION_TYPE         := 'GHR_US_PER_SF52';
    l_people_ei1_rec.PEI_INFORMATION_CATEGORY := 'GHR_US_PER_SF52';
    l_people_ei1_rec.PEI_INFORMATION3         := p_citizenship;
    l_people_ei1_rec.PEI_INFORMATION4         := p_veterans_preference;
    l_people_ei1_rec.PEI_INFORMATION5         := p_veterans_preference_for_RIF;
    l_people_ei1_rec.PEI_INFORMATION6         := p_veterans_status;

    if p_action = 'INSERT' then
       ghr_mto_int.insert_people_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              pp_ei                  =>   l_people_ei1_rec);
    else
       ghr_mto_int.update_people_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              pp_ei                  =>   l_people_ei1_rec);
    end if;
end;

procedure map_mtv_to_people_ei2(
                p_transfer_name                  IN varchar2,
                p_effective_date                 IN date,
                p_person_id                      IN number,
                p_appointment_type               IN varchar2,
                p_type_of_employment             IN varchar2,
                p_race_or_national_origin        IN varchar2,
--                p_agency_code_transfer_from      IN varchar2,
                p_orig_appointment_auth_code_1   IN varchar2,
		p_orig_appt_auth_code_1_desc	 IN varchar2, --Bug# 8724192
                p_orig_appointment_auth_code_2   IN varchar2,
		p_orig_appt_auth_code_2_desc	 IN varchar2, --Bug# 8724192
                p_handicap_code                  IN varchar2,
                p_action                         IN varchar2  ) is

l_people_ei2_rec      per_people_extra_info%ROWTYPE;

begin
    l_people_ei2_rec.person_id                := p_person_id;
    l_people_ei2_rec.INFORMATION_TYPE         := 'GHR_US_PER_GROUP1';
    l_people_ei2_rec.PEI_INFORMATION_CATEGORY := 'GHR_US_PER_GROUP1';
    l_people_ei2_rec.PEI_INFORMATION3         := p_appointment_type;
    l_people_ei2_rec.PEI_INFORMATION4         := p_type_of_employment;
    l_people_ei2_rec.PEI_INFORMATION5         := p_race_or_national_origin;
--    l_people_ei2_rec.PEI_INFORMATION7         := p_agency_code_transfer_from;
    l_people_ei2_rec.PEI_INFORMATION8         := p_orig_appointment_auth_code_1;
    l_people_ei2_rec.PEI_INFORMATION9         := p_orig_appointment_auth_code_2;
    l_people_ei2_rec.PEI_INFORMATION11        := p_handicap_code;
    l_people_ei2_rec.PEI_INFORMATION22        := p_orig_appt_auth_code_1_desc;--Bug# 8724192
    l_people_ei2_rec.PEI_INFORMATION23        := p_orig_appt_auth_code_2_desc;--Bug# 8724192

    if p_action = 'INSERT' then
       ghr_mto_int.insert_people_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              pp_ei                  =>   l_people_ei2_rec);
    else
       ghr_mto_int.update_people_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              pp_ei                  =>   l_people_ei2_rec);
    end if;
end;

procedure map_mtv_to_people_ei3(
                p_transfer_name                  IN varchar2,
                p_effective_date                 IN date,
                p_person_id                      IN number,
                p_service_comp_date              IN date,
                p_action                IN varchar2      )  is

l_people_ei3_rec      per_people_extra_info%ROWTYPE;

begin
    l_people_ei3_rec.person_id                := p_person_id;
    l_people_ei3_rec.INFORMATION_TYPE         := 'GHR_US_PER_SCD_INFORMATION';
    l_people_ei3_rec.PEI_INFORMATION_CATEGORY := 'GHR_US_PER_SCD_INFORMATION';
----l_people_ei3_rec.PEI_INFORMATION3         := to_char(p_service_comp_date, 'DD-MON-YYYY');
    l_people_ei3_rec.PEI_INFORMATION3         := fnd_date.date_to_canonical(p_service_comp_date);

    if p_action = 'INSERT' then
       ghr_mto_int.insert_people_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              pp_ei                  =>   l_people_ei3_rec);
    else
       ghr_mto_int.update_people_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              pp_ei                  =>   l_people_ei3_rec);
    end if;
end;

procedure map_mtv_to_people_ei4(
                p_transfer_name                  IN varchar2,
                p_effective_date                 IN date,
                p_person_id                      IN number,
		p_fers_coverage                  IN VARCHAR2,
                p_Previous_Retirement_Coverage   IN varchar2,
                p_Frozen_Service                 IN varchar2,
                p_action                         IN varchar2  ) is

l_people_ei4_rec      per_people_extra_info%ROWTYPE;

begin
    l_people_ei4_rec.person_id                := p_person_id;
    l_people_ei4_rec.INFORMATION_TYPE         := 'GHR_US_PER_SEPARATE_RETIRE';
    l_people_ei4_rec.PEI_INFORMATION_CATEGORY := 'GHR_US_PER_SEPARATE_RETIRE';
    -- Bug 2412656 Added FERS Coverage
    l_people_ei4_rec.PEI_INFORMATION3         := p_fers_coverage;
    l_people_ei4_rec.PEI_INFORMATION4         := p_Previous_Retirement_Coverage;
    l_people_ei4_rec.PEI_INFORMATION5         := p_Frozen_Service;

    if p_action = 'INSERT' then
       ghr_mto_int.insert_people_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              pp_ei                  =>   l_people_ei4_rec);
    else
       ghr_mto_int.update_people_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              pp_ei                  =>   l_people_ei4_rec);
    end if;
end;

procedure map_mtv_to_people_ei5(
                p_transfer_name                  IN varchar2,
                p_effective_date                 IN date,
                p_person_id                      IN number,
                p_Creditable_Military_Service    IN varchar2,
                p_action                IN varchar2  ) is

l_people_ei5_rec      per_people_extra_info%ROWTYPE;

begin
   l_people_ei5_rec.person_id                := p_person_id;
   l_people_ei5_rec.INFORMATION_TYPE         := 'GHR_US_PER_UNIFORMED_SERVICES';
   l_people_ei5_rec.PEI_INFORMATION_CATEGORY := 'GHR_US_PER_UNIFORMED_SERVICES';
   l_people_ei5_rec.PEI_INFORMATION5         := p_Creditable_Military_Service;

    if p_action = 'INSERT' then
       ghr_mto_int.insert_people_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              pp_ei                  =>   l_people_ei5_rec);
    else
       ghr_mto_int.update_people_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              pp_ei                  =>   l_people_ei5_rec);
    end if;
end;

procedure map_mtv_to_position_ei1(
                p_transfer_name                  IN varchar2,
                p_person_id                      IN number,
                p_effective_date                 IN date,
                p_flsa_category                  IN varchar2,
                p_bargaining_unit_status         IN varchar2,
                p_functional_class               IN varchar2,
                p_position_working_title         IN varchar2,
                p_supervisory_status             IN varchar2,
                p_action                         IN varchar2  ) is

l_position_ei1_rec      per_position_extra_info%ROWTYPE;

begin
   l_position_ei1_rec.INFORMATION_TYPE         := 'GHR_US_POS_GRP1';
   l_position_ei1_rec.POEI_INFORMATION_CATEGORY:= 'GHR_US_POS_GRP1';
   l_position_ei1_rec.POEI_INFORMATION7        := p_flsa_category;
   l_position_ei1_rec.POEI_INFORMATION8        := p_bargaining_unit_status;
   l_position_ei1_rec.POEI_INFORMATION11       := p_functional_class;
   l_position_ei1_rec.POEI_INFORMATION12       := p_position_working_title;
   l_position_ei1_rec.POEI_INFORMATION16       := p_supervisory_status;

    if p_action = 'INSERT' then
       l_position_ei1_rec.POSITION_ID          := p_person_id;
       ghr_mto_int.insert_position_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_pos_ei               =>   l_position_ei1_rec);
    else
       ghr_mto_int.update_position_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_pos_ei               =>   l_position_ei1_rec);
    end if;
end;

procedure map_mtv_to_position_ei2(
                p_transfer_name                  IN varchar2,
                p_person_id                      IN number,
                p_effective_date                 IN date,
                p_position_occupied              IN varchar2,
                p_appropriation_code1            IN varchar2,
                p_appropriation_code2            IN varchar2,
                p_action                         IN varchar2  ) is

l_position_ei2_rec      per_position_extra_info%ROWTYPE;

begin
   l_position_ei2_rec.INFORMATION_TYPE         := 'GHR_US_POS_GRP2';
   l_position_ei2_rec.POEI_INFORMATION_CATEGORY:= 'GHR_US_POS_GRP2';
   l_position_ei2_rec.POEI_INFORMATION3        := p_position_occupied;
   l_position_ei2_rec.POEI_INFORMATION13       := p_appropriation_code1;
   l_position_ei2_rec.POEI_INFORMATION14       := p_appropriation_code2;

    if p_action = 'INSERT' then
       l_position_ei2_rec.POSITION_ID          := p_person_id;
       ghr_mto_int.insert_position_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_pos_ei               =>   l_position_ei2_rec);
    else
       ghr_mto_int.update_position_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_pos_ei               =>   l_position_ei2_rec);
    end if;
end;

procedure map_mtv_to_element_entries(
                p_transfer_name                 IN varchar2,
                p_person_id                     IN number,
                p_effective_date                IN date,
                p_total_salary                  IN number,
                p_basic_salary_rate             IN number,
                p_locality_adjustment           IN number,
                p_adjusted_basic_pay            IN number,
                p_other_pay                     IN number,
                p_fegli                         IN varchar2,
                p_retirement_plan               IN varchar2,
                p_retention_allowance           IN number,
                p_staffing_differential         IN number,
                p_supervisory_differential      IN number,
                p_wgi_date_due                  IN date,
                p_fegli_desc                    IN varchar2,
                p_retirement_plan_desc          IN varchar2,
                p_au_overtime                   IN number,
                p_availability_pay              IN number,
                p_auo_premium_pay_indicator     IN varchar2,
                p_ap_premium_pay_indicator      IN varchar2,
		p_to_total_salary               IN number,
		p_to_basic_salary_rate          IN number,
		p_to_adjusted_basic_pay         IN number,
                p_action                        IN varchar2   ) is

l_ghr_mt_ele_rec       ghr_mt_element_entries_v%ROWTYPE;

begin
    l_ghr_mt_ele_rec.total_salary              := p_total_salary;
    l_ghr_mt_ele_rec.salary                    := p_basic_salary_rate;
    l_ghr_mt_ele_rec.locality_adjustment       := p_locality_adjustment;
    l_ghr_mt_ele_rec.adjusted_pay              := p_adjusted_basic_pay;
    l_ghr_mt_ele_rec.other_pay                 := p_other_pay;
    l_ghr_mt_ele_rec.fegli                     := p_fegli;
    l_ghr_mt_ele_rec.retirement_plan           := p_retirement_plan;
    l_ghr_mt_ele_rec.retention_allowance       := p_retention_allowance;
    l_ghr_mt_ele_rec.staffing_differential     := p_staffing_differential;
    l_ghr_mt_ele_rec.supervisory_differential  := p_supervisory_differential;
--  l_ghr_mt_ele_rec.wgi_date_due              := to_char(p_wgi_date_due, 'DD-MON-YYYY');
    l_ghr_mt_ele_rec.wgi_date_due              := fnd_date.date_to_canonical(p_wgi_date_due);
    l_ghr_mt_ele_rec.fegli_meaning             := p_fegli_desc;
    l_ghr_mt_ele_rec.retirement_plan_meaning   := p_retirement_plan_desc;
    l_ghr_mt_ele_rec.auo_amount                := p_au_overtime;
    -- Bug#4151183 Assigned wrong values to AUO Prem. Pay Ind and AP Amount. Assigned Correct values now.
    l_ghr_mt_ele_rec.auo_premium_pay_ind       := p_auo_premium_pay_indicator;
    l_ghr_mt_ele_rec.ap_amount                 := p_availability_pay;
    -- Bug#4151183 End of Fix
    l_ghr_mt_ele_rec.ap_premium_pay_ind        := p_ap_premium_pay_indicator;

    -- Changes 4093771
    l_ghr_mt_ele_rec.to_basic_salary_rate := p_to_basic_salary_rate;
    l_ghr_mt_ele_rec.to_total_salary := p_to_total_salary;
    l_ghr_mt_ele_rec.to_adjusted_basic_pay := p_to_adjusted_basic_pay;
    -- End changes 4093771

    if p_action = 'INSERT' then
       ghr_mto_int.insert_element_entries
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_element              =>   l_ghr_mt_ele_rec);
    else
       ghr_mto_int.update_element_entries
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_element              =>   l_ghr_mt_ele_rec);
    end if;
end;

procedure  map_mtv_to_misc(
                p_transfer_name                 IN varchar2,
                p_person_id                     IN number,
                p_effective_date                IN date,
                p_to_position_id                IN number,
                p_from_grade_or_level           IN varchar2,
                p_from_pay_plan                 IN varchar2,
                p_from_position_title           IN varchar2,
                p_from_position_seq_num         IN number,
                p_duty_station_code             IN varchar2,
                p_duty_station_desc             IN varchar2,
		p_from_agency_code		IN varchar2,
                p_action                        IN varchar2 ) is

l_ghr_mt_misc_rec       ghr_mt_misc_v%ROWTYPE;

begin

    l_ghr_mt_misc_rec.to_position_id            := p_to_position_id;
    l_ghr_mt_misc_rec.from_grade_or_level       := p_from_grade_or_level;
    l_ghr_mt_misc_rec.from_pay_plan             := p_from_pay_plan;
    l_ghr_mt_misc_rec.from_position_title       := p_from_position_title;
    l_ghr_mt_misc_rec.from_position_seq_num     := p_from_position_seq_num;
    l_ghr_mt_misc_rec.duty_station_code         := p_duty_station_code;
    l_ghr_mt_misc_rec.duty_station_desc         := p_duty_station_desc;
    l_ghr_mt_misc_rec.from_agency_code		:= p_from_agency_code;

    if p_action = 'INSERT' then
       ghr_mto_int.insert_misc
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_misc                 =>   l_ghr_mt_misc_rec);
    else
       ghr_mto_int.update_misc
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_misc                 =>   l_ghr_mt_misc_rec);
    end if;
end;


procedure map_mtv_to_assign_ei1(
                p_transfer_name                 IN varchar2,
                p_person_id                     IN number,
                p_effective_date                IN date,
                p_from_step_or_rate             IN varchar2,
                p_tenure                        IN varchar2,
                p_annuitant_indicator           IN varchar2,
                p_pay_rate_determinant          IN varchar2,
                p_work_schedule                 IN varchar2,
                p_part_time_hours               IN number,
                p_action                        IN varchar2   ) is

l_assign_ei1_rec        per_assignment_extra_info%ROWTYPE;

begin
    l_assign_ei1_rec.INFORMATION_TYPE          := 'GHR_US_ASG_SF52';
    l_assign_ei1_rec.AEI_INFORMATION_CATEGORY  := 'GHR_US_ASG_SF52';
    l_assign_ei1_rec.AEI_INFORMATION3          := p_from_step_or_rate;
    l_assign_ei1_rec.AEI_INFORMATION4          := p_tenure;
    l_assign_ei1_rec.AEI_INFORMATION5          := p_annuitant_indicator;
    l_assign_ei1_rec.AEI_INFORMATION6          := p_pay_rate_determinant;
    l_assign_ei1_rec.AEI_INFORMATION7          := p_work_schedule;
    l_assign_ei1_rec.AEI_INFORMATION8          := p_part_time_hours;

    if p_action = 'INSERT' then
       l_assign_ei1_rec.ASSIGNMENT_ID          := p_person_id;
       ghr_mto_int.insert_assignment_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_a_ei                 =>   l_assign_ei1_rec);
    else
       ghr_mto_int.update_assignment_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_a_ei                 =>   l_assign_ei1_rec);
    end if;
end;

procedure map_mtv_to_assign_ei2(
                p_transfer_name                 IN varchar2,
                p_person_id                     IN number,
                p_effective_date                IN date,
                p_date_arrivd_personnel_office  IN date,
                p_non_disclosure_agmt_status    IN varchar2,
                p_part_time_indicator           IN varchar2,
                p_qualif_standards_waiver       IN varchar2,
                p_action                        IN varchar2  ) is

l_assign_ei2_rec        per_assignment_extra_info%ROWTYPE;

begin
    l_assign_ei2_rec.INFORMATION_TYPE          := 'GHR_US_ASG_NON_SF52';
    l_assign_ei2_rec.AEI_INFORMATION_CATEGORY  := 'GHR_US_ASG_NON_SF52';
 -- l_assign_ei2_rec.AEI_INFORMATION3         :=  to_char(p_date_arrivd_personnel_office, 'DD-MON-YYYY');
    l_assign_ei2_rec.AEI_INFORMATION3         :=  fnd_date.date_to_canonical(p_date_arrivd_personnel_office);
    l_assign_ei2_rec.AEI_INFORMATION6          := p_non_disclosure_agmt_status;
    l_assign_ei2_rec.AEI_INFORMATION8          := p_part_time_indicator;
    l_assign_ei2_rec.AEI_INFORMATION9          := p_qualif_standards_waiver;

    if p_action = 'INSERT' then
       l_assign_ei2_rec.ASSIGNMENT_ID          := p_person_id;
       ghr_mto_int.insert_assignment_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_a_ei                 =>   l_assign_ei2_rec);
    else
       ghr_mto_int.update_assignment_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_a_ei                 =>   l_assign_ei2_rec);
    end if;
end;

--Begin Bug# 8724192
procedure map_mtv_to_assign_ei3(
                p_transfer_name                 IN varchar2,
                p_person_id                     IN number,
                p_effective_date                IN date,
                p_assignment_nte_start_date	IN date,
		p_assignment_nte		IN date,
                p_action                        IN varchar2  ) is

l_assign_ei3_rec        per_assignment_extra_info%ROWTYPE;

begin
    l_assign_ei3_rec.INFORMATION_TYPE          := 'GHR_US_ASG_NTE_DATES';
    l_assign_ei3_rec.AEI_INFORMATION_CATEGORY  := 'GHR_US_ASG_NTE_DATES';
    l_assign_ei3_rec.AEI_INFORMATION3         :=  fnd_date.date_to_canonical(p_assignment_nte_start_date);
    l_assign_ei3_rec.AEI_INFORMATION4         :=  fnd_date.date_to_canonical(p_assignment_nte);

    if p_action = 'INSERT' then
       l_assign_ei3_rec.ASSIGNMENT_ID          := p_person_id;
       ghr_mto_int.insert_assignment_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_a_ei                 =>   l_assign_ei3_rec);
    else
       ghr_mto_int.update_assignment_ei
            ( p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_a_ei                 =>   l_assign_ei3_rec);
    end if;
end;
--End Bug# 8724192
procedure map_mtv_to_special_info(
                p_transfer_name                 IN varchar2,
                p_effective_date                IN date,
                p_person_id                     IN number,
                p_education_level               IN varchar2,
                p_academic_discipline           IN varchar2,
                p_year_degree_attained          IN varchar2,
                p_action                IN varchar2  ) is

l_flex_name    varchar2(150) := 'US Fed Education';
l_si           ghr_api.special_information_type;

begin

     l_si.SEGMENT1 := p_education_level;
     l_si.SEGMENT2 := p_academic_discipline;
     l_si.SEGMENT3 := p_year_degree_attained;

   if p_action = 'INSERT' then
      ghr_mto_int.insert_special_info(
              p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              p_person_id            =>   p_person_id,
              p_flex_name            =>   l_flex_name,
              p_si                   =>   l_si );
   end if;
   if p_education_level      is not null or
      p_academic_discipline  is not null or
      p_year_degree_attained is not null then
      ghr_mto_int.update_special_info(
              p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              p_person_id            =>   p_person_id,
              p_flex_name            =>   l_flex_name,
              p_si                   =>   l_si );

   end if;

end;

procedure map_mtv_to_assign_f(
                p_transfer_name                 IN varchar2,
                p_effective_date                IN date,
                p_assignment_id                 IN number) is

l_assign_f_rec        per_all_assignments_f%ROWTYPE;

begin
    l_assign_f_rec.ASSIGNMENT_ID               := p_assignment_id;
    l_assign_f_rec.PERSON_ID                   := p_assignment_id;

      ghr_mto_int.insert_assignment_f(
              p_transfer_name        =>   p_transfer_name,
              p_effective_date       =>   p_effective_date,
              p_a                    =>   l_assign_f_rec );
end;

procedure map_mtv_to_position(
                p_transfer_name                 IN varchar2,
                p_person_id                     IN number,
                p_effective_date                IN date,
                p_position_id                   IN number) is

l_position_rec        hr_all_positions_f%ROWTYPE;

begin
    l_position_rec.position_id                 := p_position_id;

      ghr_mto_int.insert_position(
              p_transfer_name        =>   p_transfer_name,
              p_person_id            =>   p_person_id,
              p_effective_date       =>   p_effective_date,
              p_pos                  =>   l_position_rec);
end;

Procedure Update_Process_Flag(
	p_transfer_name 		in      varchar2,
	p_include_error			in	varchar2,
	p_override_prev_selection	in	varchar2,
	p_value				in      varchar2) is

Begin
 update ghr_mt_people_f_v
 set mt_status = p_value
 where mt_name = p_transfer_name
 and nvl(mt_Status, ' ') in (' ', decode(p_include_error, 'Y', 'E', ' '),
 decode(p_override_prev_selection, 'Y', decode(p_value, 'Y', 'N', 'Y'), ' '));
 commit;
End;

function Submit_MTI_Request (
                             P_DESCRIPTION	IN VARCHAR2,
                             P_ARGUMENT1	IN VARCHAR2,
                             P_ARGUMENT2	IN VARCHAR2)
   RETURN NUMBER IS
BEGIN
	return (fnd_request.submit_request(
		 APPLICATION    => 'GHR'
		,PROGRAM        => 'SUBMIT_MASS_TRANSFER_IN'
		,DESCRIPTION    => p_description
		,START_TIME     => SYSDATE
		,SUB_REQUEST    => FALSE
		,ARGUMENT1      => p_argument1
		,ARGUMENT2      => p_argument2
	 ));

end;

FUNCTION get_lookup_meaning(
                p_lookup_type    hr_lookups.lookup_type%TYPE
                ,p_lookup_code    hr_lookups.lookup_code%TYPE)
RETURN VARCHAR2 IS

l_ret_val hr_lookups.meaning%TYPE := NULL;

CURSOR cur_loc IS
  SELECT loc.meaning
  FROM   hr_lookups loc
  WHERE
  loc.lookup_type    = p_lookup_type
  AND    loc.lookup_code    = p_lookup_code;

BEGIN
  FOR cur_loc_rec IN cur_loc LOOP
    l_ret_val :=  cur_loc_rec.meaning;
  END LOOP;

  RETURN(l_ret_val);

end;

Procedure set_process_flag(
  p_mt_name       in varchar2,
  p_mt_person_id  in number,
  p_mt_status     in varchar2) is
Begin

  update ghr_mt_people_f_v
    set mt_status = p_mt_status
    where mt_name = p_mt_name and
          mt_person_id = p_mt_person_id;

end set_process_flag;

end ghr_mti_int_insert;

/
