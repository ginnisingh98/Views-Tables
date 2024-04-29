--------------------------------------------------------
--  DDL for Package GHR_CORR_CANC_SF52
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CORR_CANC_SF52" AUTHID CURRENT_USER as
/* $Header: ghcorcan.pkh 120.0.12010000.3 2009/02/23 12:41:39 vmididho ship $ */
        sf52_corr_rec     ghr_pa_requests%rowtype;
        l_date_result     date;
        l_number_result   number;
        l_varchar2_result varchar2(2000);
	Procedure Correction_SF52
           ( p_sf52_data		in	ghr_pa_requests%rowtype,
	     p_process_type		in	varchar2 default 'CURRENT',
             p_capped_other_pay         in      number   default NULL);
	Procedure Cancel_Appt_SF52	( p_sf52_data		in out nocopy ghr_pa_requests%rowtype);
	Procedure Cancel_Correction_SF52 ( p_sf52_data		in out nocopy ghr_pa_requests%rowtype);
	Procedure Cancel_Other_Family_Sf52 ( p_sf52_data	in out nocopy ghr_pa_requests%rowtype);
	Procedure cancel_term_SF52 ( p_sf52_data	in out nocopy ghr_pa_requests%rowtype);
	Procedure update_eleentval(p_hist_pre	in	ghr_pa_history%rowtype) ;
	Procedure build_corrected_sf52(p_pa_request_id		in number,
						 p_noa_code_correct	in varchar2,
						 p_sf52_data_result in out nocopy ghr_pa_requests%rowtype,
                                  p_called_from in varchar2 default NULL);
	Procedure Cancel_Routine (p_sf52_data in out nocopy ghr_pa_requests%rowtype);
        Procedure populate_corrected_sf52(p_pa_request_id     in number,
                                          p_noa_code_correct  in varchar2);
        Function  get_date_column(p_value in varchar2) return date;
        Function  get_number_column(p_value in varchar2) return number;
        Function  get_varchar2_column(p_value in varchar2) return varchar2;

        Procedure get_sf52_to_details_for_ia
         (p_pa_request_id in ghr_pa_requests.pa_request_id%type,
          p_retro_eff_date in ghr_pa_requests.effective_date%type,
          p_sf52_ia_rec in out nocopy ghr_pa_requests%rowtype) ;

PROCEDURE posn_not_active
(p_position_id         in number
,p_effective_date      in date
,p_posn_eff_start_date OUT NOCOPY date
,p_posn_eff_end_date   OUT NOCOPY date
,p_prior_posn_ovn      OUT NOCOPY number);

--6850492
procedure apply_dual_correction(p_sf52_data in ghr_pa_requests%rowtype,
                                p_sf52_data_result in out nocopy ghr_pa_requests%rowtype,
				p_retro_action_exists in varchar2); --added the parameter for 8264475
--6850492


End;

/
