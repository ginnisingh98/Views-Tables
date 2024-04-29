--------------------------------------------------------
--  DDL for Package GHR_MASS_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MASS_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: ghmasact.pkh 120.0.12000000.1 2007/03/27 10:11:56 managarw noship $ */

-- create the record types here
type duty_station_rec_type is record
(duty_station_id       ghr_duty_stations_v.duty_station_id%type,
 duty_station_code     ghr_duty_stations_v.duty_station_code%type,
 duty_station_desc     ghr_duty_stations_v.duty_station_desc%type
);

type emp_rec_type is record
(person_id             per_people_f.person_id%type,
 first_name            per_people_f.first_name%type,
 last_name             per_people_f.last_name%type,
 middle_names          per_people_f.middle_names%type,
 date_of_birth         per_people_f.date_of_birth%type,
 national_identifier   per_people_f.national_identifier%type,
 assignment_id         per_assignments_f.assignment_id%type
 );

procedure get_noa_id_desc
(
 p_noa_code	       in	ghr_nature_of_actions.code%type,
 p_effective_date	 in   date default trunc(sysdate),
 p_noa_id	       out nocopy  ghr_nature_of_actions.nature_of_action_id%type,
 p_noa_desc	       out nocopy  ghr_nature_of_actions.description%type
 );
procedure get_remark_id_desc
(
 p_remark_code	 in	ghr_nature_of_actions.code%type,
 p_effective_date	 in   date default trunc(sysdate),
 p_remark_id	 out nocopy  ghr_nature_of_actions.nature_of_action_id%type,
 p_remark_desc	 out nocopy  ghr_nature_of_actions.description%type
);

procedure emp_rec_to_sf52_rec
(p_emp_rec         in      ghr_mass_actions_pkg.emp_rec_type,
 p_sf52_rec        in out nocopy  ghr_pa_requests%rowtype
) ;

procedure asg_sf52_rec_to_sf52_rec
(p_asg_sf52_rec    in      ghr_api.asg_sf52_type,
 p_sf52_rec        in out nocopy  ghr_pa_requests%rowtype
);

procedure pos_grp1_rec_to_sf52_rec
(p_pos_grp1_rec    in      ghr_api.pos_grp1_type,
 p_sf52_rec        in out nocopy  ghr_pa_requests%rowtype
);

procedure pay_calc_rec_to_sf52_rec
(p_pay_calc_rec  in      ghr_pay_calc.pay_calc_out_rec_type,
 p_sf52_rec      in out nocopy  ghr_pa_requests%rowtype
);

procedure duty_station_rec_to_sf52_rec
(p_duty_station_rec         in      ghr_mass_actions_pkg.duty_station_rec_type,
 p_sf52_rec                 in out nocopy  ghr_pa_requests%rowtype
);

procedure replace_insertion_values
(p_desc                in varchar2,
 p_information1        in varchar2 default null,
 p_information2        in varchar2 default null,
 p_information3        in varchar2 default null,
 p_information4        in varchar2 default null,
 p_information5        in varchar2 default null,
 p_desc_out            out nocopy varchar2
);

Procedure get_personnel_off_groupbox
(p_position_id         in       ghr_pa_requests.from_position_id%type,
 p_effective_date      in       date default trunc(sysdate),
 p_groupbox_id         out nocopy      ghr_groupboxes.groupbox_id%type,
 p_routing_group_id    out nocopy      ghr_routing_groups.routing_group_id%type
);

Procedure get_personnel_officer_name
(p_personnel_office_id  in  ghr_pa_requests.personnel_office_id%TYPE,
 p_person_full_name     out nocopy varchar2,
 p_approving_off_work_title out nocopy varchar2);


end ghr_mass_actions_pkg;


 

/
