--------------------------------------------------------
--  DDL for Package PAY_US_EMP_DT_TAX_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_EMP_DT_TAX_VAL" AUTHID CURRENT_USER AS
/* $Header: pyusdtvl.pkh 120.0.12000000.1 2007/01/18 02:19:46 appldev noship $ */

function  check_work_override (  p_assignment_id  in number,
                                 p_session_date  date,
                                 p_state_code in varchar2,
                                 p_county_code in varchar2,
                                 p_city_code   in varchar2
                               )return varchar2;


function  check_resi_override (  p_assignment_id  in number,
                                 p_session_date  date,
                                 p_state_code in varchar2,
                                 p_county_code in varchar2,
                                 p_city_code   in varchar2
                                )return varchar2;



function check_payroll_run (  p_assignment_id        in number,
                              p_new_location_code    in varchar2,
                              p_new_location_id      in number,
                              p_session_date         in date,
			      p_effective_start_date in date,
			      p_effective_end_date   in date,
                              p_mode                 in varchar2) return varchar2;


  procedure check_in_work_location ( p_assignment_id in number,
                                     p_state_code    in varchar2,
                                     p_county_code   in varchar2,
                                     p_city_code     in varchar2,
                                     p_ret_code      in out NOCOPY number,
                                     p_ret_text      in out NOCOPY varchar2);

 procedure check_in_res_addr ( p_assignment_id in number,
                               p_state_code    in varchar2,
                               p_county_code   in varchar2,
                               p_city_code     in varchar2,
                               p_ret_code      in out NOCOPY number,
                               p_ret_text      in out NOCOPY varchar2);

 procedure payroll_check_for_purge ( p_assignment_id in number,
                                     p_state_code    in varchar2,
                                     p_county_code   in varchar2,
                                     p_city_code     in varchar2,
                                     p_ret_code      in out NOCOPY number,
                                     p_ret_text      in out NOCOPY varchar2);

 procedure check_school_district ( p_assignment in number,
                                   p_start_date in date,
                                   p_end_date   in date,
                                   p_mode       in varchar2,
                                   p_rowid      in varchar2);


 function check_locations (p_assignment_id        in number,
                           p_effective_start_date in date,
                           p_business_group_id    in number) return boolean;


 procedure get_res_codes (p_assignment_id         in number,
                          p_session_date          in date,
                          p_res_state_code        out NOCOPY varchar2,
                          p_res_county_code       out NOCOPY varchar2,
                          p_res_city_code         out NOCOPY varchar2,
                          p_res_state_name        out NOCOPY varchar2,
                          p_res_county_name       out NOCOPY varchar2,
                          p_res_city_name         out NOCOPY varchar2);

 procedure get_work_codes (p_assignment_id         in number,
                           p_session_date          in date,
                           p_work_state_code       out NOCOPY varchar2,
                           p_work_county_code      out NOCOPY varchar2,
                           p_work_city_code        out NOCOPY varchar2,
                           p_work_state_name       out NOCOPY varchar2,
                           p_work_county_name      out NOCOPY varchar2,
                           p_work_city_name        out NOCOPY varchar2);

procedure check_jurisdiction_exists (p_assignment_id        in number,
                                     p_jurisdiction_code    in varchar2,
                                     p_ret_code             in out NOCOPY number,
                                     p_ret_text             in out NOCOPY varchar2);


procedure check_delete_tax_row ( p_assignment_id in number,
                             p_state_code    in varchar2,
                             p_county_code   in varchar2,
                             p_city_code     in varchar2);


procedure  get_all_work_codes (p_assignment_id         in number,
                           p_session_date          in date,
                           p_work_state_code       in out NOCOPY varchar2,
                           p_work_county_code      in out NOCOPY varchar2,
                           p_work_city_code        in out NOCOPY varchar2,
                           p_work_state_name       in out NOCOPY varchar2,
                           p_work_county_name      in out NOCOPY varchar2,
                           p_work_city_name        in out NOCOPY varchar2,
                           p_work1_state_code      in out NOCOPY varchar2,
                           p_work1_county_code     in out NOCOPY varchar2,
                           p_work1_city_code       in out NOCOPY varchar2,
                           p_work1_state_name      in out NOCOPY varchar2,
                           p_work1_county_name     in out NOCOPY varchar2,
                           p_work1_city_name       in out NOCOPY varchar2,
                           p_work2_state_code      in out NOCOPY varchar2,
                           p_work2_county_code     in out NOCOPY varchar2,
                           p_work2_city_code       in out NOCOPY varchar2,
                           p_work2_state_name      in out NOCOPY varchar2,
                           p_work2_county_name     in out NOCOPY varchar2,
                           p_work2_city_name       in out NOCOPY varchar2,
                           p_work3_state_code      in out NOCOPY varchar2,
                           p_work3_county_code     in out NOCOPY varchar2,
                           p_work3_city_code       in out NOCOPY varchar2,
                           p_work3_state_name      in out NOCOPY varchar2,
                           p_work3_county_name     in out NOCOPY varchar2,
                           p_work3_city_name       in out NOCOPY varchar2,
                           p_sui_state_code        in out NOCOPY varchar2,
                           p_loc_city              in out NOCOPY varchar2);

procedure  get_orig_res_codes (p_assignment_id         in number,
                          p_session_date          in date,
                          p_res_state_code        out NOCOPY varchar2,
                          p_res_county_code       out NOCOPY varchar2,
                          p_res_city_code         out NOCOPY varchar2,
                          p_res_state_name        out NOCOPY varchar2,
                          p_res_county_name       out NOCOPY varchar2,
                          p_res_city_name         out NOCOPY varchar2);

end pay_us_emp_dt_tax_val;

 

/
