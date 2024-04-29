--------------------------------------------------------
--  DDL for Package BEN_BATCH_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_REPORTING" AUTHID CURRENT_USER as
/* $Header: benrepor.pkh 120.0 2005/05/28 09:26:12 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Batch Reporting
Purpose
	This package is used to perform reporting for batch processes.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        07 Oct 98        G Perry    115.0      Created.
        14 Nov 99        G Perry    115.2      Added parameter to
                                               run certain activity report
                                               based on mode. Also added
                                               temporal events procedure.
        12 May 00        jcarpent   115.2      Changed parameters to
                                               summary (127645/4424)
        27 Dec 02        rpillay    115.5      NOCOPY changes
        27 Dec 02        rpillay    115.6      Fixed GSCC errors
	15 Jun 04        hmani      115.7      Added six more params
	                                       to temporal_life_events - Bug 3690166
*/
-----------------------------------------------------------------------
procedure standard_header
          (p_concurrent_request_id      in  number,
           p_concurrent_program_name    out nocopy varchar2,
           p_process_date               out nocopy date,
           p_mode                       out nocopy varchar2,
           p_derivable_factors          out nocopy varchar2,
           p_validate                   out nocopy varchar2,
           p_person                     out nocopy varchar2,
           p_person_type                out nocopy varchar2,
           p_program                    out nocopy varchar2,
           p_business_group             out nocopy varchar2,
           p_plan                       out nocopy varchar2,
           p_popl_enrt_typ_cycl         out nocopy varchar2,
           p_plans_not_in_programs      out nocopy varchar2,
           p_just_programs              out nocopy varchar2,
           p_comp_object_selection_rule out nocopy varchar2,
           p_person_selection_rule      out nocopy varchar2,
           p_life_event_reason          out nocopy varchar2,
           p_organization               out nocopy varchar2,
           p_postal_zip_range           out nocopy varchar2,
           p_reporting_group            out nocopy varchar2,
           p_plan_type                  out nocopy varchar2,
           p_option                     out nocopy varchar2,
           p_eligibility_profile        out nocopy varchar2,
           p_variable_rate_profile      out nocopy varchar2,
           p_legal_entity               out nocopy varchar2,
           p_payroll                    out nocopy varchar2,
           p_status                     out nocopy varchar2);
-----------------------------------------------------------------------
procedure process_information
          (p_concurrent_request_id       in  number,
           p_start_date                 out nocopy varchar2,
           p_end_date                   out nocopy varchar2,
           p_start_time                 out nocopy varchar2,
           p_end_time                   out nocopy varchar2,
           p_elapsed_time               out nocopy varchar2,
           p_persons_selected           out nocopy varchar2,
           p_persons_processed          out nocopy varchar2,
           p_persons_unprocessed        out nocopy varchar2,
           p_persons_processed_succ     out nocopy varchar2,
           p_persons_errored            out nocopy varchar2);
-----------------------------------------------------------------------
procedure activity_summary_by_action
          (p_concurrent_request_id      in  number,
           p_without_active_life_event  out nocopy varchar2,
           p_with_active_life_event     out nocopy varchar2,
           p_no_life_event_created      out nocopy varchar2,
           p_life_event_open_and_closed out nocopy varchar2,
           p_life_event_created         out nocopy varchar2,
           p_life_event_still_active    out nocopy varchar2,
           p_life_event_closed          out nocopy varchar2,
           p_life_event_replaced        out nocopy varchar2,
           p_life_event_dsgn_only       out nocopy varchar2,
           p_life_event_choices         out nocopy varchar2,
           p_life_event_no_effect       out nocopy varchar2,
           p_life_event_rt_pr_chg       out nocopy varchar2);
-----------------------------------------------------------------------------------------------
-- Procedure activity_summary_by_action is overloaded as two more parameters for life
-- event collapsed, life event collision  added
procedure activity_summary_by_action
		(p_concurrent_request_id      in  number,
        	 p_without_active_life_event  out nocopy varchar2,
	         p_with_active_life_event     out nocopy varchar2,
	         p_no_life_event_created      out nocopy varchar2,
	         p_life_event_open_and_closed out nocopy varchar2,
	    	 p_life_event_created         out nocopy varchar2,
		 p_life_event_still_active    out nocopy varchar2,
	         p_life_event_closed          out nocopy varchar2,
	         p_life_event_replaced        out nocopy varchar2,
	         p_life_event_dsgn_only       out nocopy varchar2,
	         p_life_event_choices         out nocopy varchar2,
		 p_life_event_no_effect       out nocopy varchar2,
	         p_life_event_rt_pr_chg       out nocopy varchar2,
		 p_life_event_collapsed       out nocopy varchar2,
		 p_life_event_collision       out nocopy varchar2);

------------------------------------------------------------------------------------------------
procedure temporal_life_events
          (p_concurrent_request_id      in  number,
           p_age_changed                out nocopy varchar2,
           p_los_changed                out nocopy varchar2,
           p_comb_age_los_changed       out nocopy varchar2,
           p_pft_changed                out nocopy varchar2,
           p_comp_lvl_changed           out nocopy varchar2,
           p_hrs_wkd_changed            out nocopy varchar2,
	   p_loss_of_eligibility        out nocopy varchar2,
	   p_late_payment               out nocopy varchar2,
	   p_max_enrollment_rchd        out nocopy varchar2,
	   p_period_enroll_changed      out nocopy varchar2,
	   p_voulntary_end_cvg          out nocopy varchar2,
	   p_waiting_satisfied          out nocopy varchar2,
           p_persons_no_potential       out nocopy varchar2,
           p_persons_with_potential     out nocopy varchar2,
           p_number_of_events_created   out nocopy varchar2);
-----------------------------------------------------------------------
procedure batch_reports
          (p_concurrent_request_id      in  number,
           p_mode                       in  varchar2 default 'S',
           p_report_type                in  varchar2);
-----------------------------------------------------------------------
procedure submit_request
          (errbuf                       out nocopy varchar2,
           retcode                      out nocopy number,
           p_program_name               in  varchar2,
           p_concurrent_request_id      in  number);
-----------------------------------------------------------------------
type letotal_rec is record (
  ler_name	ben_ler_f.name%type,
  new_closed_cd varchar2(1), -- 'N' or 'C'
  total         number
);
type le_total is table of letotal_rec index by binary_integer;
-----------------------------------------------------------------------
procedure event_summary(
  p_concurrent_request_id in number,
  p_life_event_totals     out nocopy ben_batch_reporting.le_total
);
-----------------------------------------------------------------------
end ben_batch_reporting;

 

/
