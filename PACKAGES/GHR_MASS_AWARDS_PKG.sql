--------------------------------------------------------
--  DDL for Package GHR_MASS_AWARDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MASS_AWARDS_PKG" AUTHID CURRENT_USER AS
/* $Header: ghrmarpa.pkh 120.1.12000000.1 2007/01/18 14:14:43 appldev noship $ */


type first_lac1_record is record
( first_action_la_code1    ghr_pa_requests.first_action_la_code1%type,
  first_action_la_desc1    ghr_pa_requests.first_action_la_desc1%type,
  first_lac1_information1  ghr_pa_requests.first_lac1_information1%type,
  first_lac1_information2  ghr_pa_requests.first_lac1_information2%type,
  first_lac1_information3  ghr_pa_requests.first_lac1_information3%type,
  first_lac1_information4  ghr_pa_requests.first_lac1_information4%type,
  first_lac1_information5  ghr_pa_requests.first_lac1_information5%type);

type first_lac2_record is record
( first_action_la_code2    ghr_pa_requests.first_action_la_code2%type,
  first_action_la_desc2    ghr_pa_requests.first_action_la_desc2%type,
  first_lac2_information1  ghr_pa_requests.first_lac2_information1%type,
  first_lac2_information2  ghr_pa_requests.first_lac2_information2%type,
  first_lac2_information3  ghr_pa_requests.first_lac2_information3%type,
  first_lac2_information4  ghr_pa_requests.first_lac2_information4%type,
  first_lac2_information5  ghr_pa_requests.first_lac2_information5%type);

PROCEDURE get_noa_code_desc
(
 p_noa_id              in   ghr_nature_of_actions.nature_of_action_id%type,
 p_effective_date      in   date default trunc(sysdate),
 p_noa_code            out nocopy   ghr_nature_of_actions.code%type,
 p_noa_desc            out nocopy   ghr_nature_of_actions.description%type
 );

FUNCTION get_noa_id (
     p_mass_award_id     in      ghr_mass_awards.mass_award_id%type)
    RETURN NUMBER;

PROCEDURE get_business_group(p_person_id         in number,
                             p_effective_date    in date,
                             p_business_group_id in out nocopy  number);

--Bug#3804067 Added new parameter p_mass_action_comments
PROCEDURE get_pa_request_id_ovn
(
 p_mass_award_id         in      ghr_mass_awards.mass_award_id%TYPE,
 p_effective_date        in      date,
 p_person_id             in      per_people_f.person_id%TYPE,
 p_pa_request_id         out nocopy      ghr_pa_requests.pa_request_id%TYPE,
 p_pa_notification_id    out nocopy      ghr_pa_requests.pa_notification_id%TYPE,
 p_rpa_type              out nocopy      ghr_pa_requests.rpa_type%TYPE,
 p_mass_action_sel_flag  out nocopy      ghr_pa_requests.mass_action_select_flag%TYPE,
 p_mass_action_comments  out nocopy     ghr_pa_requests.mass_action_comments%TYPE,
 p_object_version_number out nocopy      ghr_pa_requests.object_version_number%TYPE
);

PROCEDURE get_award_details
(
 p_mass_award_id             in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type                  in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date            in      date,
 p_person_id                 in      ghr_pa_requests.person_id%TYPE,
 p_award_amount              out nocopy      ghr_pa_requests.award_amount%TYPE,
 p_award_uom                 out nocopy      ghr_pa_requests.award_uom%TYPE,
 p_award_percentage          out nocopy      ghr_pa_requests.award_percentage%TYPE,
 p_award_agency              out nocopy      ghr_pa_request_extra_info.rei_information3%type,
 p_award_type                out nocopy      ghr_pa_request_extra_info.rei_information4%type,
 p_group_award               out nocopy      ghr_pa_request_extra_info.rei_information6%type,
 p_tangible_benefit_dollars  out nocopy      ghr_pa_request_extra_info.rei_information7%type,
 p_date_award_earned         out nocopy      ghr_pa_request_extra_info.rei_information9%type,
 p_appropriation_code        out nocopy      ghr_pa_request_extra_info.rei_information10%type

);

PROCEDURE get_award_lac
(
 p_mass_award_id             in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type                  in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date            in      date,
 p_first_lac1_record         out nocopy      first_lac1_record,
 p_first_lac2_record         out nocopy      first_lac2_record
);


PROCEDURE get_award_details_shadow
(
 p_pa_request_id             in      ghr_pa_request_ei_shadow.pa_request_id%type,
 p_award_amount              out nocopy      ghr_pa_requests.award_amount%TYPE,
 p_award_uom                 out nocopy      ghr_pa_requests.award_uom%TYPE,
 p_award_percentage          out nocopy      ghr_pa_requests.award_percentage%TYPE,
 p_award_agency              out nocopy      ghr_pa_request_extra_info.rei_information3%type,
 p_award_type                out nocopy      ghr_pa_request_extra_info.rei_information4%type,
 p_group_award               out nocopy      ghr_pa_request_extra_info.rei_information6%type,
 p_tangible_benefit_dollars  out nocopy      ghr_pa_request_extra_info.rei_information7%type,
 p_date_award_earned         out nocopy      ghr_pa_request_extra_info.rei_information9%type,
 p_appropriation_code        out nocopy      ghr_pa_request_extra_info.rei_information10%type
);
---- Fetch Remarks and Legal Authority codes.

PROCEDURE main_awards
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_action_type       in      varchar2,
 p_errbuf            out nocopy      varchar2, --\___  error log
 p_status            out nocopy      varchar2, --||
 p_retcode           out nocopy      number,    --/     in conc. manager.
 p_maxcheck         out nocopy number
);

PROCEDURE upd_elig_flag_bef_selection
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type          in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date    in      date
);

Procedure marpa_process
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_action_type       in      VARCHAR2,
 p_rpa_type          in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date    in      date,
 p_person_id         in      per_people_f.person_id%TYPE,
 p_pa_request_rec    in out nocopy   ghr_pa_requests%rowtype ,
 p_log_text          out nocopy      varchar2,
 p_maxcheck         out nocopy number
);

PROCEDURE build_rpa_for_mass_awards
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_action_type       in      varchar2,
 p_rpa_type          in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date    in      date,
 p_person_id         in      per_people_f.person_id%TYPE,
 p_assignment_id     in      per_assignments_f.assignment_id%TYPE,
 p_position_id       in      hr_positions_f.position_id%TYPE,
 p_grade_id          in      number,
 p_location_id       in      hr_locations.location_id%TYPE,
 p_job_id            in      number,
 p_errbuf            out nocopy      varchar2, --\  error log
 p_status            out nocopy      varchar2, --||
 p_retcode           out nocopy      number,
 p_maxcheck         out nocopy number --/  in conc. manager.
);

PROCEDURE refresh_award_details
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type          in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date    in      date,
 p_person_id         in      per_people_f.person_id%TYPE,
 p_pa_request_id     in      ghr_pa_requests.pa_request_id%type
);

PROCEDURE del_elig_flag_aft_selection
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type          in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date    in      date
);

Procedure set_ei
(p_shadow       in out nocopy  varchar2,
 p_template     in     varchar2,
 p_person       in out nocopy  varchar2,
 p_refresh_flag in     varchar2 default 'Y');

Procedure create_shadow_row ( p_rpa_data in  ghr_pa_requests%rowtype);

Procedure update_shadow_row ( p_rpa_data in  ghr_pa_requests%rowtype,
                              p_result   out nocopy  Boolean );
Procedure create_remarks
(p_mass_award_id             in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type                  in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date            in      date,
 p_pa_request_id             in      ghr_pa_requests.pa_request_id%type
);

Procedure mass_awards_error_handling
 (p_pa_request_id             in      ghr_pa_requests.pa_request_id%type,
  p_object_version_number     in      ghr_pa_requests.object_version_number%type,
  p_error                     in      varchar2 default null,
  p_result                    out nocopy      boolean
  );

PROCEDURE check_award_amount
  (p_noa_code  ghr_pa_requests.first_noa_code%TYPE,
  	p_effective_date ghr_pa_requests.effective_date%TYPE,
	p_award_amount NUMBER,
	p_from_pay_plan ghr_pa_requests.from_pay_plan%TYPE,
	p_from_basic_pay_pa ghr_pa_requests.from_basic_pay%TYPE,
	p_to_position_id ghr_pa_requests.to_position_id%TYPE,
	p_comments OUT NOCOPY varchar2,
	p_error_flg OUT NOCOPY BOOLEAN
	) ;

END GHR_MASS_AWARDS_PKG;

 

/
