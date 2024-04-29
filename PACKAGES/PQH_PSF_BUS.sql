--------------------------------------------------------
--  DDL for Package PQH_PSF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PSF_BUS" AUTHID CURRENT_USER as
/* $Header: pqpsfbus.pkh 120.1.12010000.1 2008/07/28 13:04:29 appldev ship $ */
--
--  ---------------------------------------------------------------------------
--  |-----------------<   POSITION_CONTROL_ENABLED    >---------------------|
--  ---------------------------------------------------------------------------
--
function POSITION_CONTROL_ENABLED(P_ORGANIZATION_ID NUMBER default null,
                                  p_effective_date in date default sysdate,
                                  p_assignment_id number default null) RETURN VARCHAR2;
--
--  ---------------------------------------------------------------------------
--  |-----------------<   hr_psf_bus_insert_validate    >---------------------|
--  ---------------------------------------------------------------------------
--
procedure hr_psf_bus_insert_validate(p_rec 			 in hr_psf_shd.g_rec_type
	 ,p_effective_date	       in date
--     ,p_datetrack_mode	       in varchar2
    );
--
--  ---------------------------------------------------------------------------
--  |-----------------<   hr_psf_bus_update_validate    >---------------------|
--  ---------------------------------------------------------------------------
--
procedure hr_psf_bus_update_validate(p_rec in hr_psf_shd.g_rec_type
      ,p_effective_date	       in date
      ,p_validation_start_date in date
      ,p_validation_end_date    in date
      ,p_datetrack_mode	       in varchar2
      );
--
--  ---------------------------------------------------------------------------
--  |-----------------<   per_asg_bus_insert_validate    >--------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_asg_bus_insert_validate(p_rec 	per_asg_shd.g_rec_type, p_effective_date date );
--
--  ---------------------------------------------------------------------------
--  |-----------------<   per_asg_bus_update_validate    >--------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_asg_bus_update_validate(p_rec 	per_asg_shd.g_rec_type
      ,p_effective_date	       in date
      ,p_validation_start_date in date
      ,p_validation_end_date    in date
      ,p_datetrack_mode	       in varchar2
      );
--
--  ---------------------------------------------------------------------------
--  |-----------------<   per_asg_bus_delete_validate    >--------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_asg_bus_delete_validate(p_rec     per_asg_shd.g_rec_type
      ,p_effective_date        in date
      ,p_validation_start_date in date
      ,p_validation_end_date    in date
      ,p_datetrack_mode        in varchar2 );
--
--  ---------------------------------------------------------------------------
--  |----------------------<   per_abv_insert_validate    >-------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_abv_insert_validate(
		p_assignment_id number,
		p_value number,
		p_unit varchar2,
		p_effective_date date);
--
--  ---------------------------------------------------------------------------
--  |----------------------<   per_abv_update_validate    >-------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_abv_update_validate(
		p_abv_id number,
		p_assignment_id number,
		p_value number,
		p_unit varchar2,
		p_effective_date date,
		p_validation_start_date date,
		p_validation_end_date  date,
		p_datetrack_mode    varchar2);
--
--  ---------------------------------------------------------------------------
--  |----------------------<   funded_status    >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the funded_status of the position.
--
function funded_status
         (p_position_id       in number) return varchar2;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   sum_assignment_fte    >------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the funded_status of the position.
--
function sum_assignment_fte
         (p_position_id       in number, p_effective_date  in date) return number;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   sum_assignment_fte    >------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the funded_status of the position.
--
function sum_assignment_fte
         (p_position_id       in number, p_effective_date  in date, p_assignment_id in number) return number;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------<   default_assignment_fte    >----------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the sum_assignment_fte of the position.
--
function default_assignment_fte
         (p_organization_id       in number) return number;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   assignment_fte    >----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the funded_status of the position.
--
function assignment_fte
         (p_assignment_id       in number) return number;
--
--
--  ---------------------------------------------------------------------------
--  |------------------------<   future approved actions    >-----------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the future approved actions of the position.
--
function future_approved_actions
         (p_position_id       in number) return varchar2;
--
--
--  ---------------------------------------------------------------------------
--  |------------------------<   open_status    >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the funded_status of the position.
--
function open_status
         (p_position_id       in number, p_effective_date  in date) return varchar2;
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  overlap_period   >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the overlap_period of the position.
--
procedure overlap_period
         (p_position_id       in number, p_overlap_period out nocopy number,
                p_start_date out nocopy date, p_end_date out nocopy date);
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<  reserved_status   >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the reserved_status of the position.
--
procedure reserved_status
         (p_position_id       in number, p_reserved_status out nocopy varchar2,
                p_start_date out nocopy date, p_end_date out nocopy date, p_person_id out nocopy number, p_fte_reserved out nocopy number);
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   review_status    >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the funded_status of the position.
--
function review_status
         (p_position_id       in number) return varchar2;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   vacancy_status    >----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the funded_status of the position.
--
function vacancy_status
         (p_position_id       in number, p_effective_date in date) return varchar2;
--
function permit_extended_pay(p_position_id varchar2) return boolean;
--
function permit_extended_pay_poi(p_rec in pe_poi_shd.g_rec_type) return boolean;
--
function chk_seasonal_dates( p_position_id number,  p_seasonal_flag varchar2, p_assignment_start_date date)
return boolean;
--
function chk_seasonal(p_position_id number) return boolean;
--
function chk_seasonal_poi(p_position_id number) return boolean;
--
function chk_overlap_poi(p_position_id number) return boolean;
--
function pos_assignments_exists(p_position_id number) return boolean;
--
function chk_overlap(p_position_id number) return boolean;
--
function chk_amendment_info(
amendment_date date,
amendment_recommendation varchar2,
amendment_ref_number varchar2) return boolean;
--
--
function no_assignments(p_position_id number) return number;
--
function no_assignments(p_position_id number, p_effective_date date) return number;
--
function max_persons(p_position_id number) return number;
--
function proposed_date_for_layoff(p_position_id number) return date;
--
function fte_capacity(p_position_id number) return number;
--
function position_type(p_position_id number) return varchar2;
--
function grade(p_position_id number) return number;
--
function work_period_type_cd(p_position_id number) return varchar2;
--
function chk_work_pay_term_dates(p_work_period_type_cd    hr_all_positions_f.work_period_type_cd%type
                                ,p_work_term_end_day_cd   hr_all_positions_f.work_term_end_day_cd%type
                                ,p_work_term_end_month_cd hr_all_positions_f.work_term_end_month_cd%type
                                ,p_pay_term_end_day_cd    hr_all_positions_f.pay_term_end_day_cd%type
                                ,p_pay_term_end_month_cd  hr_all_positions_f.pay_term_end_month_cd%type
                                ,p_term_start_day_cd      hr_all_positions_f.term_start_day_cd%type
                                ,p_term_start_month_cd    hr_all_positions_f.term_start_month_cd%type
                                ) return boolean;
--
function chk_position_job_grade(p_position_grade_id number, p_job_id number) return boolean;
--
function chk_overlap_dates
         (p_position_id  in number, p_overlap_period  number, p_assignment_start_date date) return boolean;
--
function chk_reserved(p_position_id number) return boolean;
--
function position_min_asg_dt(p_position_id  number) return date;
--
function position_max_asg_dt(p_position_id  number) return date;
--
function chk_earliest_hire_date(p_position_id  number, p_earliest_hire_date date)
return boolean;
--
function chk_prop_date_for_layoff(p_position_id  number, p_proposed_date_for_layoff date)
return boolean;
--
function GET_SYSTEM_SHARED_TYPE(p_availability_status_id number)
return varchar2;
--
function budgeted_fte (p_position_id in number,
                              p_effective_date in date) return number;

function get_budgeted_fte( p_position_id 	 in number default null
		          ,p_job_id         	 in number default null
		          ,p_grade_id    	 in number default null
		          ,p_organization_id     in number default null
		          ,p_budget_entity       in varchar2
		          ,p_start_date          in date default sysdate
		          ,p_end_date            in date default sysdate
	   	          ,p_unit_of_measure     in varchar2
	   	          ,p_business_group_id   in number
	   	          ,p_budgeted_fte_date   out nocopy date
		         ) return number;

function budgeted_fte( p_position_id 	     in number default null
		      ,p_job_id      	     in number default null
		      ,p_grade_id    	     in number default null
		      ,p_organization_id     in number default null
		      ,p_budget_entity       in varchar2
		      ,p_effective_date      in date default sysdate
	   	      ,p_unit_of_measure     in varchar2
	   	      ,p_business_group_id   in number
		      ) return number;
--
function person_fte
         (p_person_id in number,
          p_position_id  in number,
          p_effective_date  in date,
          p_ex_assignment_id number) return number;
--
function assignment_fte(
          p_assignment_id number,
          p_effective_date date) return number;
--
function available_fte(
          p_person_id number,
          p_position_id number,
          p_effective_date date) return number;
--
--
--
function budgeted_money (
          p_position_id in number,
          p_effective_date in date) return number;
--
--
--
function get_pos_actuals_commitment(
                      p_position_id                  in number,
                      p_effective_date              in date,
                      p_ex_assignment_id            in number default -1
                      ) return number;
--
--
function get_asg_actuals_commitment(
                      p_assignment_id              in number,
                      p_effective_date             in date) return number;
--
function chk_pos_budget(
                      p_position_id  in number,
                      p_effective_date in date) return boolean;
--
function chk_pos_budget(
                      p_position_id  in number,
                      p_effective_date in date,
                      p_ex_assignment_id number) return boolean;
--
--
--
function nonreserved_asg_fte(
                      p_position_id number,
                      p_effective_date date,
                      p_ex_position_extra_info_id number  default -1,
                      p_ex_person_id number  default -1 ) return number;
--
function pos_reserved_fte(
                      p_position_id number,
                      p_effective_date date,
                      p_ex_position_extra_info_id number default -1)
                      return number;
--
function poei_reserved_fte(
                      p_position_extra_info_id number) return number;
--
function person_asg_fte(
                      p_person_id in number,
                      p_position_id  in number,
                      p_effective_date  in date,
                      p_ex_assignment_id number default -1) return number;
--
procedure pqh_poei_validate(
                      p_position_id number,
                      p_position_extra_info_id number,
                      p_person_id number,
                      p_start_date date,
                      p_end_date date,
                      p_poei_fte number);
--
function position_fte(
                      p_position_id number,
                      p_effective_date date) return number;
--
function chk_reserved_fte(
                      p_assignment_id number,
                      p_person_id number,
                      p_position_id number,
                      p_position_type varchar2,
                      p_effective_date date,
                      p_default_asg_fte number default null)
return boolean;
--
function chk_future_reserved_fte(
    p_assignment_id number,
    p_person_id number,
    p_position_id number,
    p_position_type varchar2,
    p_validation_start_date date,
    p_validation_end_date date,
    p_default_asg_fte number default null)
return date;
--
procedure chk_pos_fte_sum_asg_fte(
   p_assignment_id number,
   p_position_id number,
   p_effective_date date,
   p_default_asg_fte number default null,
   p_position_type out nocopy varchar2,
   p_organization_id out nocopy number,
   p_budgeted_fte out nocopy number,
   p_realloc_fte out nocopy number,
   p_position_fte out nocopy number,
   p_total_asg_fte out nocopy number);
--
procedure chk_future_pos_asg_fte(
    p_assignment_id number,
    p_position_id number,
    p_validation_start_date date,
    p_validation_end_date date,
    p_default_asg_fte number default null);
--
--
procedure CHK_ABV_FTE_GT_POS_BGT_FTE
(p_assignment_id number,
 p_position_id number,
 p_effective_date date,
 p_default_asg_fte number default null,
 p_bgt_lt_abv_fte out nocopy boolean
);
--
function get_position_fte(p_position_id number, p_effective_date date)
         return number;
--
procedure reserved_error(p_assignment_id number, p_person_id number,
                         p_position_id number, p_effective_start_date date,
                         p_organization_id number,
                         p_default_asg_fte number default 0);
--
function get_pc_topnode (p_business_group_id in number default null,
                         p_effective_date    in date default null) return number ;
--
function get_pc_str_version (p_business_group_id in number default null,
                             p_effective_date    in date default null) return number ;
--
procedure chk_position_budget(
p_assignment_id    in number,
p_element_type_id  in number default null,
p_input_value_id   in number default null,
p_effective_date   in date,
p_called_from      in varchar2, /* valid values 'ASG' or 'SAL' */
p_old_position_id  in number default null,
p_new_position_id  in number default null
);
--
end	PQH_PSF_BUS;

/
