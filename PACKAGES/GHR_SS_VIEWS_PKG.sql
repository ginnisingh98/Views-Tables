--------------------------------------------------------
--  DDL for Package GHR_SS_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SS_VIEWS_PKG" AUTHID CURRENT_USER AS
/* $Header: ghssview.pkh 120.3.12010000.4 2008/11/03 08:52:28 managarw ship $ */
--
g_package       constant varchar2(33) := '  GHR_SS_VIEWS_PKG.';


--
function get_people_ei_id_ason_date(
                p_person_id in number,
                p_information_type in varchar2,
        	p_effective_date in date
               ) return number ;
--

function get_ele_value_ason_date (
                            p_ele_name in  varchar2,
			    p_input_name in  varchar2,
			    p_asg_id     in  number,
			    p_eff_date   in  date,
			    P_BUSINESS_GROUP_ID in Number
			  ) return varchar2 ;
--
function get_latest_pa_req_id (
                           p_person_id in number,
        		   p_effective_date	in date
			  ) return number;
--
Function get_latest_perf_rating(P_person_id in number,
                                p_effective_date in Date) return varchar2;

--
Function retrieve_element_curr_code (p_element_name      in     pay_element_types_f.element_name%type,
                                     p_assignment_id     in     pay_element_entries_f.assignment_id%type,
				     p_business_group_id in     per_all_assignments_f.business_group_id%type,
                                     p_effective_date    in     date ) return varchar2;
--
function get_loc_pay_area_percentage (p_location_id  in number,
                                      p_effective_date    in     date ) return varchar2;
--

function get_ele_entry_value_ason_date (p_element_entry_id     IN     NUMBER,
                                        p_input_value_name     IN     VARCHAR2,
                                        p_effective_date       IN     DATE ) return varchar2 ;
--
FUNCTION check_if_awards_exists  (p_assignment_id  IN NUMBER,
                                  p_effective_date    IN   DATE )  RETURN VARCHAR2 ;
--
FUNCTION check_if_bonus_exists  (p_assignment_id  IN NUMBER,
                                 p_effective_date    IN   DATE ) RETURN VARCHAR2;
--
function get_history_id(p_assignment_type  in varchar2,
                        p_person_id        in number,
                        p_information_type in varchar2,
                        p_effective_date   in date
                       ) return number;
--
     function get_assignment_ei_id_ason_date( p_asg_id in number,
                                              p_information_type in varchar2,
        	                              p_effective_date in date
                                            ) return number ;
--

     function get_position_ei_id_ason_date( p_position_id in number,
                                            p_information_type in varchar2,
        	                            p_effective_date in date
                                           ) return number ;
--

Function get_rating_of_record(P_person_id      in number) return varchar2;
--
Function get_assignment_start_date(p_person_id in number) return date;

Function get_assignment_end_date(p_person_id in number) return date;
--
END ghr_ss_views_pkg;
--

/
