--------------------------------------------------------
--  DDL for Package GHR_WGI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_WGI_PKG" AUTHID CURRENT_USER AS
/* $Header: ghwgipro.pkh 120.1.12010000.1 2008/07/28 10:41:42 appldev ship $ */

PROCEDURE GHR_WGI_PROCESS
           (
            errbuf		     out nocopy  varchar2,
	    retcode		     out nocopy  number,
            p_personnel_office_id  in
              ghr_pa_requests.personnel_office_id%TYPE default null,
            p_pay_plan             in
              ghr_pay_plans.pay_plan%TYPE default null
           );
--
--
Procedure GHR_WGI_EMP 	(
            p_effective_date       in  date default trunc(sysdate),
		p_frequency            in  number default 90,
		p_log_flag             in  char default 'N',
		p_errbuf               OUT nocopy varchar2,
		p_retcode              OUT nocopy number,
            p_personnel_office_id  in
                 ghr_pa_requests.personnel_office_id%TYPE default null,
            p_pay_plan             in  ghr_pay_plans.pay_plan%TYPE
                                        default null
	);
--
--
procedure create_ghr_errorlog(
	p_program_name           in	ghr_process_log.program_name%type,
	p_log_text               in	ghr_process_log.log_text%type,
	p_message_name           in	ghr_process_log.message_name%type,
	p_log_date               in	ghr_process_log.log_date%type);
--
procedure get_noa_code_desc (
	p_code		       in	ghr_nature_of_actions.code%type,
	p_effective_date		 in   date default sysdate,
	p_nature_of_action_id	 out nocopy ghr_nature_of_actions.nature_of_action_id%type,
	p_description		 out nocopy ghr_nature_of_actions.description%type);
--
function Get_fnd_lookup_meaning (
					  p_lookup_type in hr_lookups.lookup_type%TYPE,
					  p_lookup_code in hr_lookups.lookup_code%TYPE,
					  p_effective_date in   date default sysdate )
		return hr_lookups.meaning%TYPE ;

--
-- Check assignment id
--
function check_assignment_prd
             	(p_pay_rate_determinant	in   ghr_pa_requests.pay_rate_determinant%TYPE
  	       	)    return boolean;
----
-- Verify person in PA requests
--
function person_in_pa_requests(p_person_id      in ghr_pa_requests.person_id%TYPE,
                               p_effective_date in ghr_pa_requests.effective_date%TYPE,
                               p_first_noa_code in ghr_pa_requests.first_noa_code%TYPE,
   					 p_days           in number )
		return boolean;
--
function check_pay_plan( p_pay_plan  in  VARCHAR2)
		return boolean;
--
-- This record structure will keep all the in parameters that are passed to the
-- WGI Custom Hook
  TYPE wgi_in_rec_type IS RECORD
	                  (     person_id		per_people_f.person_id%type
				     ,assignment_id	per_assignments.assignment_id%type
				     ,position_id		per_assignments.position_id%type
                             ,effective_date	ghr_pa_requests.effective_date%type
                        );
--
-- This record structure will keep all the out parameters that are passed from the
-- WGI Custom Hook
  TYPE wgi_out_rec_type IS RECORD
	                  (
				     process_person BOOLEAN
                        );
 --
 --
procedure derive_legal_auth_cd_remarks
                (
                   p_first_noa_code        in       ghr_pa_requests.first_noa_code%TYPE,
                   p_pay_rate_determinant  in       ghr_pa_requests.pay_rate_determinant%TYPE,
                   p_from_pay_plan         in       ghr_pa_requests.from_pay_plan%TYPE,
                   p_grade_or_level        in       ghr_pa_requests.from_grade_or_level%TYPE,
                   p_step_or_rate          in       ghr_pa_requests.from_step_or_rate%TYPE,
                   p_retained_pay_plan     in       ghr_pa_requests.from_pay_plan%TYPE        default null,
                   p_retained_grade_or_level in     ghr_pa_requests.from_grade_or_level%TYPE  default null,
                   p_retained_step_or_rate in       ghr_pa_requests.from_step_or_rate%TYPE    default null,
                   -- Bug#5204589
                   p_temp_step             in       ghr_pa_requests.from_step_or_rate%TYPE    default null,
                   p_effective_date        in       ghr_pa_requests.effective_date%TYPE,
                   p_first_action_la_code1 in out nocopy ghr_pa_requests.first_action_la_code1%TYPE,
                   p_first_action_la_desc1 in out nocopy ghr_pa_requests.first_action_la_desc1%TYPE,
                   p_first_action_la_code2 in out nocopy ghr_pa_requests.first_action_la_code2%TYPE,
                   p_first_action_la_desc2 in out nocopy ghr_pa_requests.first_action_la_desc2%TYPE,
                   p_remark_id1               out nocopy ghr_pa_remarks.remark_id%TYPE,
                   p_remark_desc1             out nocopy ghr_pa_remarks.description%type,
                   p_remark1_info1            out nocopy ghr_pa_remarks.remark_code_information1%TYPE,
                   p_remark1_info2            out nocopy ghr_pa_remarks.remark_code_information2%TYPE,
                   p_remark1_info3            out nocopy ghr_pa_remarks.remark_code_information3%TYPE,
                   p_remark_id2               out nocopy ghr_pa_remarks.remark_id%TYPE,
                   p_remark_desc2             out nocopy ghr_pa_remarks.description%type,
                   p_remark2_info1            out nocopy ghr_pa_remarks.remark_code_information1%TYPE,
                   p_remark2_info2            out nocopy ghr_pa_remarks.remark_code_information2%TYPE,
                   p_remark2_info3            out nocopy ghr_pa_remarks.remark_code_information3%TYPE
                   );

 --
function CheckIfFWPayPlan( p_from_pay_plan		 in   ghr_pa_requests.from_pay_plan%TYPE
				 )
   return boolean;
--
--
function CheckPayPlanParm (
                             p_in_pay_plan    in   ghr_pa_requests.from_pay_plan%TYPE
                            ,p_from_pay_plan  in   ghr_pa_requests.from_pay_plan%TYPE
                          )
                  return boolean;
--
--
function CheckPOIParm (
                             p_in_personnel_office_id  in out NOCOPY ghr_pa_requests.personnel_office_id%TYPE
                            ,p_position_id             in   per_assignments.position_id%TYPE
                            ,p_effective_date          in   ghr_pa_requests.effective_date%TYPE
                       )
   return boolean ;
--
--
function CheckIfMaxPayPlan( p_from_pay_plan	in   ghr_pa_requests.from_pay_plan%TYPE
                           ,p_from_step_or_rate in   ghr_pa_requests.from_step_or_rate%TYPE
				 )
   return boolean ;
--
--

FUNCTION ret_wgi_pay_date (
	   p_assignment_id   IN   per_all_assignments_f.assignment_id%type,
	   p_effective_date    IN   per_all_assignments_f.effective_start_date%type ,
	   p_frequency             IN              NUMBER
	)
RETURN VARCHAR2;

end GHR_WGI_PKG;


/
