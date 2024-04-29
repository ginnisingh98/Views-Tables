--------------------------------------------------------
--  DDL for Package GHR_PROCESS_SF52
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PROCESS_SF52" AUTHID CURRENT_USER as
/* $Header: ghproc52.pkh 120.0.12010000.5 2009/02/25 11:11:54 utokachi ship $ */

        g_total_pay_check                       varchar2(1) :=  'Y';
        g_prd            ghr_pa_requests.pay_rate_determinant%type := NULL;
        g_step_or_rate   ghr_pa_requests.to_step_or_rate%type := NULL;
        e_refresh EXCEPTION; -- Bug# 5634990

	g_dual_prior_ws  ghr_pa_requests.work_schedule%type := NULL;   --8267598
	g_dual_first_noac ghr_pa_requests.first_noa_code%type := NULL;  --8264475
	g_dual_second_noac ghr_pa_requests.first_noa_code%type := NULL;	--8264475
    g_dual_prior_prd ghr_pa_requests.pay_rate_determinant%type := NULL;	--8268353
	g_dual_action_yn   varchar2(1) := 'Y'; 	 --8264475

	PROCEDURE refresh_pa_request(
		p_person_id			in	per_people_f.person_id%type,
		p_effective_date		in	date,
		p_from_only			in	boolean	default	FALSE,
		p_derive_to_cols		in	boolean	default 	FALSE,
--            p_altered_pa_request_id in    number      default     NULL,
--            p_noa_id_corrected       in    number      default     NULL,
		p_sf52_data		in out 	nocopy ghr_pa_requests%rowtype);
--		p_from_location_id	out	nocopy hr_locations.location_id%type


	Procedure Process_SF52 	(
		p_sf52_data		in out	nocopy ghr_pa_requests%rowtype,
		p_process_type		in	varchar2	default 'CURRENT',
		p_validate		in	Boolean	default FALSE,
                p_capped_other_pay      in      Number  default NULL);
	Procedure assign_new_rg (
		p_action_num	         in  number,
--		p_altered_pa_request_id  in  number      default     NULL,
--		p_noa_id_corrected       in  number      default     NULL,
		p_pa_req 		 in out nocopy ghr_pa_requests%rowtype);
	Procedure copy_2ndNoa_to_1stNoa (p_pa_req		  in out nocopy	ghr_pa_requests%rowtype);
	Procedure	null_2ndNoa_cols	(p_pa_req	  in out nocopy	ghr_pa_requests%rowtype);

	Procedure Fetch_Extra_Info(
		p_pa_request_id	in	number,
		p_noa_id	in	number,
		p_agency_ei	in	boolean	default False,
		p_sf52_ei_data	out nocopy ghr_pa_request_extra_info%rowtype,
		p_result	out nocopy	varchar2);

	Procedure get_Family_code (
		p_noa_id		in 	number,
		p_noa_family_code	out nocopy	varchar2);

	Procedure Proc_Futr_Act(
		errbuf         out nocopy     varchar2,
		retcode        out  nocopy   number,
                p_poi          in     ghr_pois.personnel_office_id%type);

	Procedure Route_Intervn_Future_Actions(
		p_person_id		in	number,
		p_effective_date	in	date
            );

      Procedure Route_Intervn_act_pend_today(
    		p_person_id		in	number,
	  	p_effective_date	in	date
            );

	Procedure get_par_ap_apue_fields(
		p_pa_req_in			in	ghr_pa_requests%rowtype,
		p_first_noa_id		in	ghr_pa_requests.first_noa_id%type,
		p_second_noa_id		in	ghr_pa_requests.second_noa_id%type,
		p_pa_req_out		out nocopy	ghr_pa_requests%rowtype);

	Procedure derive_to_columns(p_sf52_data	in out nocopy	ghr_pa_requests%rowtype);
	Procedure Redo_Pay_calc ( p_sf52_rec	in out nocopy	ghr_pa_requests%rowtype,
                                  p_capped_other_pay in out nocopy number );

	Procedure refresh_req_shadow (
		p_sf52_data	in out nocopy ghr_pa_requests%rowtype,
		p_shadow_data   out nocopy ghr_pa_request_shadow%rowtype,
		p_process_type	in	varchar2 default 'CURRENT');

	Procedure create_shadow_row ( p_sf52_data	in	ghr_pa_requests%rowtype);
	Procedure create_shadow_row ( p_shadow_data	in	ghr_pa_request_shadow%rowtype);
	Procedure Update_rfrs_values( p_sf52_data   in out nocopy ghr_pa_requests%rowtype,
				      p_shadow_data in     ghr_pa_request_shadow%rowtype);
procedure print_sf52(p_proc VARCHAR2, p_pa_request_rec GHR_PA_REQUESTS%ROWTYPE);

--8267598
procedure reinit_dual_var;


End;

/
