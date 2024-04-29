--------------------------------------------------------
--  DDL for Package BEN_RECN_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RECN_REP" AUTHID CURRENT_USER as
/* $Header: bercnrep.pkh 120.0 2005/05/28 11:36:13 appldev noship $ */
/* ===========================================================================
 * Name:
 *   ben_recn_rep
 * Purpose:
 *   This package writes the Reconciliation of Premium to Element Entries
 *   Report in  CSV format. There are procedures in this package which
 *   can be used to write to a file.
 * History:
 *   Date        Who       Version  What?
 *   ----------- --------- -------  -----------------------------------------
 *   20-Jan-2003 vsethi    115.0    Created.
 *   22-Jan-2003 vsethi    115.1    Modified after unit testing
 *   07-Feb-2003 vsethi    115.2    Removed the p_run_date and p_mon_year parameters
 *   19-Feb-2003 vsethi    115.3    2791345 - For person enrolled in multiple options
 *				    premium is not displayed for the second record.
 *
 *   18-May-2004 rpgupta   115.4    3608119 - Added param p_run_date_end to
 *                                  get_rate_val and get_element_val
 *   08-Jun-2004 rpgupta   115.5    3608119 - Added param p_run_date_end to
 *                                  get_prtt_rate_val
 *
 * ===========================================================================
 */
--
-- Types declaration.
--
--
g_log_file_name varchar2(100);
--
Type g_report_cols_rec is record
  (col1                        varchar2(400)
   ,col2                       varchar2(400)
   ,col3                       varchar2(400)
   ,col4                       varchar2(240)
   ,col5                       varchar2(240)
   ,col6                       varchar2(240)
   ,col7                       varchar2(240)
   ,col8                       varchar2(240)
   ,col9                       varchar2(240)
   ,col10                      varchar2(240)
   ,col11                      varchar2(240)
   ,col12                      varchar2(240)
   ,col13                      varchar2(240)
   ,col14                      varchar2(240)
   ,col15                      varchar2(240)
   ,col16                      varchar2(240)
   ,col17                      varchar2(240)
   ,col18                      varchar2(240)
   ,col19                      varchar2(240)
   ,col20                      varchar2(240)
  );

type g_report_array is varray(1000000) of g_report_cols_rec;

--
-- Functions and Prcedures.
--

--
-- ============================================================================
--                     << open_log_file >>
-- Opens file p_log_file_name or a fnd log file in write mode
-- ============================================================================
--
procedure open_log_file(p_log_file_name  in out nocopy varchar2 ) ;

--
--
-- ============================================================================
--                     << print_report >>
-- Prints a line in the file that has been opened by the report
-- ============================================================================
--
procedure put_line(p_message  in varchar2);

--
-- ============================================================================
--                     << print_report >>
-- Closes the file that has been opened by the report
-- ============================================================================
--
procedure close_log_file;

--
-- ============================================================================
--                     << print_report >>
-- Procedure to write the contents of array to a file in CSV format. If p_close_file
-- is TRUE then the file is closed.
-- ============================================================================
--
procedure print_report(p_log_file_name  IN OUT nocopy varchar2,
		      p_report_array    IN ben_recn_rep.g_report_array,
		      p_close_file 	IN boolean default TRUE );

--
-- ============================================================================
--                     << recon_report >>
-- This procedure creates and prints the premium reconciliation report
-- called from BENRECON.rdf
-- ============================================================================
--
procedure recon_report
          (p_pl_id  		number,
           p_pgm_id		number,
           p_person_id		number,
           p_per_sel_rule	number,
           p_business_group_id	number,
           p_benefit_action_id	number,
           p_organization_id	number,
           p_location_id	number,
           p_ntl_identifier	varchar2,
           p_rptg_grp_id 	number,
           p_benfts_grp_id 	number,
           p_run_date 		date,
           p_report_start_date  date,
           p_report_end_date    date,
           p_prem_type		varchar2,
           p_payroll_id		number,
           p_dsply_pl_disc_rep  varchar2,
           p_dsply_pl_recn_rep  varchar2,
           p_dsply_pl_prtt_rep  varchar2,
           p_dsply_prtt_reps    varchar2,
           p_dsply_lfe_rep      varchar2,
           p_emp_name_format	varchar2,
           p_conc_request_id	number,
           p_rep_st_dt	  	date, -- original rep start date as submitted in the concurrent request
           p_rep_end_dt	  	date, -- original rep start date as submitted in the concurrent request
	   p_dsply_recn	        varchar2,
	   p_dsply_disc	        varchar2,
	   p_dsply_lfe	        varchar2,
	   p_dsply_pl_prtt      varchar2,
	   p_output_typ		varchar2,
	   p_op_file_name       IN OUT nocopy varchar2
          );

--
-- ============================================================================
--                     << exec_per_selection_rule >>
-- This procedure creates a person action for people who pass the person
-- selection rule and returns the benefit action item (for a set).
-- ============================================================================
--
procedure exec_per_selection_rule
	(p_pl_id	    	number,
	p_pgm_id		number,
	p_business_group_id	number,
	p_run_date		date,
	p_report_start_date	date,
	p_prem_type		varchar2,
	p_payroll_id		number,
	p_organization_id	number,
	p_location_id		number,
	p_benfts_grp_id		number,
	p_rptg_grp_id		number,
	p_person_selection_rule_id number,
	p_benefit_action_id	out nocopy number);

--
-- ============================================================================
--                     << get_rate_val >>
-- Function returns the rate value, used in reconciliation and discripancy rep
-- ============================================================================
--
FUNCTION get_rate_val
	(p_prtt_enrt_rslt_id 	number,
	p_run_date	      	date,
	p_business_group_id 	number,
	p_tx_typ_cd		varchar2,
	p_acty_typ_cd		varchar2,
	p_per_in_ler_id	number,
        p_run_date_end date default null) -- 3608119
RETURN NUMBER;

--
-- ============================================================================
--                     << get_element_val >>
-- Function returns the element value, used in reconciliation and discripancy rep
-- ============================================================================
--
FUNCTION get_element_val
	 (p_prtt_enrt_rslt_id 	number,
	  p_run_date	      	date,
	  p_business_group_id 	number,
	  p_tx_typ_cd		varchar2,
	  p_acty_typ_cd		varchar2,
	  p_per_in_ler_id	number,
          p_run_date_end date default null -- 3608119
	 )
RETURN NUMBER;

--
-- ============================================================================
--                     << get_new_rates >>
-- Function returns the new rate or element value for Life Event Report
-- ============================================================================
--
FUNCTION get_new_rates
	 (p_prtt_enrt_rslt_id	number,
	  p_report_start_date 	date,
	  p_run_date	      	date,
	  p_business_group_id 	number,
	  p_return_type	 	varchar2,  -- ('ELEMENT','RATE')
	  p_per_in_ler_id	number
	)
RETURN NUMBER;

--
-- ============================================================================
--                     << old_premium_val >>
-- Function returns the old prem or old rate for Life Event Report
-- ============================================================================
--
FUNCTION old_premium_val
	(p_person_id 		number,
	p_pl_id		number,
	p_pgm_id		number,
	p_oipl_id		number,
	p_report_start_date 	date,
	p_run_date	      	date,
	p_business_group_id 	number,
	p_return_type	 	varchar2
	 )
RETURN NUMBER;

--
-- ============================================================================
--                     << old_premium_val >>
-- Function returns the change effective date for Life Event Report
-- ============================================================================
--
FUNCTION get_change_eff_dt
	 (p_prtt_enrt_rslt_id	number,
	  p_report_start_date 	date,
	  p_run_date	      	date
	 )
RETURN date;

--
-- ============================================================================
--                            <<get_prtt_rate_val>>
-- ============================================================================
--
FUNCTION get_prtt_rate_val
	 (p_prtt_enrt_rslt_id 	number,
	  p_run_date	      	date ,
	  p_per_in_ler_id	number ,
	  p_run_date_end        date default null -- 3608119
	  ) RETURN NUMBER;

--
-- ============================================================================
--                            <<report_header>>
-- procedure returns the values passed to the recon report.
-- ============================================================================
--
procedure report_header
(p_run_date		IN  date,
p_person_id		IN  number,
p_emp_name_format	IN  varchar2,
p_pgm_id		IN  number,
p_pl_id			IN  number,
p_per_sel_rule_id	IN  number,
p_business_group_id	IN  number,
p_organization_id	IN  number,
p_location_id		IN  number,
p_benfts_grp_id		IN  number,
p_rptg_grp_id		IN  number,
p_prem_type		IN  varchar2,
p_payroll_id		IN  number,
p_output_typ		IN  varchar2,
p_dsply_pl_disc_rep	IN  varchar2,
p_dsply_pl_recn_rep	IN  varchar2,
p_dsply_pl_prtt_rep	IN  varchar2,
p_dsply_prtt_reps  	IN  varchar2,
p_dsply_lfe_rep    	IN  varchar2,
p_ret_person		OUT NOCOPY varchar2,
p_ret_emp_name_format	OUT NOCOPY varchar2,
p_ret_pgm		OUT NOCOPY varchar2,
p_ret_pl		OUT NOCOPY varchar2,
p_ret_per_sel_rule	OUT NOCOPY varchar2,
p_ret_business_group	OUT NOCOPY varchar2,
p_ret_organization	OUT NOCOPY varchar2,
p_ret_location		OUT NOCOPY varchar2,
p_ret_benfts_grp	OUT NOCOPY varchar2,
p_ret_rptg_grp		OUT NOCOPY varchar2,
p_ret_prem_type		OUT NOCOPY varchar2,
p_ret_payroll		OUT NOCOPY varchar2,
p_ret_output_typ	OUT NOCOPY varchar2,
p_ret_dsply_pl_disc_rep	OUT NOCOPY varchar2,
p_ret_dsply_pl_recn_rep	OUT NOCOPY varchar2,
p_ret_dsply_pl_prtt_rep	OUT NOCOPY varchar2,
p_ret_dsply_prtt_reps  	OUT NOCOPY varchar2,
p_ret_dsply_lfe_rep    	OUT NOCOPY varchar2);

end ben_recn_rep;

 

/
