--------------------------------------------------------
--  DDL for Package BEN_BATCH_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_UTILS" AUTHID CURRENT_USER as
/* $Header: benrptut.pkh 120.2.12010000.1 2008/07/29 12:30:40 appldev ship $ */
/* ===========================================================================
 * Name:
 *   Batch_utils
 * Purpose:
 *   This package is provide all batch utility and data structure to simply
 *   batch process.
 * History:
 *   Date        Who            Version  What?
 *   ----------- ------------   -------  ------------------------------------
 *   19-NOV-1998 Hdang          115.0    Created.
 *   11-DEC-1998 Hdang          115.1    Add more functions. ret_str(s).
 *   16-DEC-1998 Hdang          115.2    Add parameter into end_process proc.
 *   22-DEC-1998 Hdang          115.3    Add parameter into print_parameter.
 *   23-DEC-1998 Hdang          115.4    Add Person cache to header from body.
 *   23-DEC-1998 Hdang          115.5    Add Prtt_enrt_rslt_id in to comp struct
 *   29-DEC-1998 Hdang          115.6    Add Actn_cd into comp_cache.
 *   06-JAN-1999 Hdang          115.7    Added new procedure for generic reports
 *   05-APR-1999 mhoyes         115.11   Un-datetrack of per_in_ler_f changes.
 *   20-JUL-1999 Gperry         115.12   genutils -> benutils package rename.
 *   27-JUL-1999 mhoyes         115.13 - Changed g_report_rec ref it ben_type.
 *   03-Nov-1999 lmcdonal       115.14   Added non_person_cd to end_process,
 *                                       write_logfile, create_restart...
 *   21-JAN-2002 aprabhak       115.15   added enrt_perd_id to print_parameters
 *   12-Mar-2002 maagrawa       115.16   Added missing dbdrv command.
 *   19-Mar-2002 ikasire        115.17   Bug 2271796 added commit
 *   26-Dec-2002 rpillay        115.18   NOCOPY changes
 *   02-Jun-2003 glingapp       115.19   Added function rows_exist. This is
 *                                       called to check for child records of
 *					             derived factors.
 *   20-Aug-2004 nhunur         115.20   Added a procedure for person selection rule
 *                                       with proper error handling.
 *   02-Nov-2004 abparekh       115.21   Bug 3517604  - Added p_date_From to procedure
 *                                       standard_header
 *   03-Nov-06  swjain          115.22   Bug 5331889 - Added input1 as additional param
 *                                       in person_selection_rule for future use
 *   09-Aug-07  vvprabhu	115.23   Bug 5857493 - added g_audit_flag to
                                         control person selection rule error logging
 * =====================================================================================
 */
--
    g_audit_flag       boolean :=false;
-- Types declaration.
--
Type g_cache_person_rec is record
  (full_name                  per_people_f.full_name%type
  ,date_of_birth              per_people_f.date_of_birth%type
  ,date_of_death              per_people_f.date_of_death%type
  ,benefit_group              ben_benfts_grp.name%type
  ,benefit_group_id           per_people_f.benefit_group_id%type
  ,postal_code                per_addresses.postal_code%type
  ,national_identifier        per_people_f.national_identifier%type
  ,person_has_type_emp        varchar2(1)
  ,assignment_id              per_assignments_f.assignment_id%type
  ,fte_value                  per_assignment_budget_values.value%type
  ,total_fte_value            per_assignment_budget_values.value%type
  ,per_system_status          per_assignment_status_types.per_system_status%type
  ,date_start                 per_periods_of_service.date_start%type
  ,adjusted_svc_date          per_periods_of_service.adjusted_svc_date%type
  ,lf_evt_ocrd_dt             ben_per_in_ler.lf_evt_ocrd_dt%type
  ,pay_period_start_date      per_time_periods.start_date%type
  ,pay_period_end_date        per_time_periods.end_date%type
  ,pay_period_next_start_date per_time_periods.start_date%type
  ,pay_period_next_end_date   per_time_periods.end_date%type
  ,grade_id                   per_assignments_f.grade_id%type
  ,job_id                     per_assignments_f.job_id%type
  ,pay_basis_id               per_assignments_f.pay_basis_id%type
  ,pay_basis                  per_pay_bases.pay_basis%type
  ,payroll_id                 per_assignments_f.payroll_id%type
  ,payroll_name               pay_all_payrolls_f.payroll_name%type
  ,location_id                per_assignments_f.location_id%type
  ,address_line_1             hr_locations.address_line_1%type
  ,organization_id            per_assignments_f.organization_id%type
  ,normal_hours               per_assignments_f.normal_hours%type
  ,frequency                  per_assignments_f.frequency%type
  ,bargaining_unit_code       per_assignments_f.bargaining_unit_code%type
  ,hourly_salaried_code       per_assignments_f.hourly_salaried_code%type
  ,labour_union_member_flag   per_assignments_f.labour_union_member_flag%type
  ,assignment_status_type_id  per_assignments_f.assignment_status_type_id%type
  ,change_reason              per_assignments_f.change_reason%type
  ,employment_category        per_assignments_f.employment_category%type
  ,org_information1           hr_organization_information.org_information1%type
  ,bg_name                    hr_all_organization_units.name%type
  ,org_id                     hr_all_organization_units.organization_id%type
  ,org_name                   hr_all_organization_units.name%type
  );
--
Type g_cache_person_types_object is record
  (person_type_id             per_person_type_usages_f.person_type_id%type
  ,user_person_type           per_person_types.user_person_type%type
  ,system_person_type         per_person_types.system_person_type%type
  );
--
type g_cache_person_types_rec is table of g_cache_person_types_object
  index by binary_integer;
--
Type g_process_information_rec is record
  (start_date                 date
  ,start_time_numeric         number
  ,num_persons_selected       number := 0
  ,num_persons_errored        number := 0
  ,num_persons_unprocessed    number := 0
  ,num_persons_processed_succ number := 0
  ,num_persons_processed      number := 0
  );
--
Type g_comp_obj_rec is record
  (pgm_id                     ben_pgm_f.pgm_id%type
  ,pl_typ_id                  ben_pl_typ_f.pl_typ_id%type
  ,pl_id                      ben_pl_f.pl_id%type
  ,oipl_id                    ben_oipl_f.oipl_id%type
  ,opt_id                     ben_opt_f.opt_id%type
  ,prtt_enrt_rslt_id          ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type
  ,bnft_amt                   ben_prtt_enrt_rslt_f.bnft_amt%type
  ,uom                        ben_prtt_enrt_rslt_f.uom%type
  ,cst_amt                    number(15)
  ,credit_amt                 number(15)
  ,cvg_strt_dt                date
  ,cvg_thru_dt                date
  ,upd_flag                   Boolean := FALSE
  ,ins_flag                   Boolean := FALSE
  ,del_flag                   Boolean := FALSE
  ,def_flag                   Boolean := FALSE
  ,susp_flag                  Boolean := FALSE
  ,actn_cd                    varchar2(30)
  );
Type g_comp_obj_table is table of g_comp_obj_rec Index by binary_integer;
--
Type g_pgm_rec is record
  (pgm_id                     ben_pgm_f.pgm_id%type
  ,name                       ben_pgm_f.name%type
  );
Type g_pgm_table is table of g_pgm_rec Index by binary_integer;
--
Type g_pl_rec is record
  (pl_id                      ben_pl_f.pl_id%type
  ,name                       ben_pl_f.name%type
  );
Type g_pl_table is table of g_pl_rec Index by binary_integer;
--
Type g_pl_typ_rec is record
  (pl_typ_id                  ben_pl_typ_f.pl_typ_id%type
  ,name                       ben_pl_typ_f.name%type
  );
Type g_pl_typ_table is table of g_pl_typ_rec Index by binary_integer;
--
Type g_opt_rec is record
  (oipl_id                    ben_oipl_f.oipl_id%type
  ,opt_id                     ben_opt_f.opt_id%type
  ,name                       ben_opt_f.name%type
  );
Type g_opt_table is table of g_opt_rec Index by binary_integer;
--
Type g_processes_table is table of number index by binary_integer;
--
Type g_ref_cursor is ref cursor;
--
-- Global variable
--
g_record_error         Exception;
g_debug                Boolean:= FALSE;
g_mx_binary_integer    constant binary_integer := 2147483647;
g_num_processes        number := 0;
g_processes_tbl        g_processes_table;
g_cache_comp           g_comp_obj_table;
g_cache_comp_cnt       binary_integer := 0;
g_rec                  ben_type.g_report_rec;
g_cache_person         g_cache_person_rec;
--
-- ============================================================================
-- Function Name:<<cache_comp_obj>>
-- Description:
--      Cache_comp objects data into memory
--.
-- ============================================================================
--
Procedure Cache_comp_obj(p_pgm_id            in number     Default NULL
                        ,p_pl_typ_id         in Number     Default NULL
                        ,p_pl_id             in Number     Default NULL
                        ,p_oipl_id           in Number     Default NULL
                        ,p_opt_id            in number     Default NULL
                        ,p_bnft_amt          in number     Default NULL
                        ,p_uom               in varchar2   Default NULL
                        ,p_cst_amt           in number     Default NULL
                        ,p_credit_amt        in number     Default NULL
                        ,p_cvg_strt_dt       in date       Default NULL
                        ,p_cvg_thru_dt       in date       Default hr_api.g_eot
                        ,p_prtt_enrt_rslt_id in number     default NULL
                        ,p_effective_date    in date
                        ,P_actn_cd           in varchar2
                        ,p_suspended         in varchar2   default 'N'
                        );
--
-- ============================================================================
-- Function Name:<<write_comp>>
-- Description:
--      Write cache out to file from Cache_comp objects data memory.
--
-- ============================================================================
--
Procedure write_comp(p_business_group_id  in number
                    ,p_effective_date     in date
                    );
--
-- ============================================================================
-- Function Name:<<get_pgm_name>>
-- Description:
--      Return program name from cache or from database.
--.
-- ============================================================================
--
Function get_pgm_name
             (p_pgm_id             in number
             ,p_business_group_id  in number
             ,p_effective_date     in date
             ,p_batch_flag         in boolean default FALSE
             ) return varchar2;
--
-- ============================================================================
-- Function Name:<<get_pl_typ_name>>
-- Description:
--      Return plan type name from cache or from database.
--.
-- ============================================================================
--
Function get_pl_typ_name
             (p_pl_typ_id          in number
             ,p_business_group_id  in number
             ,p_effective_date     in Date
             ,p_batch_flag         in boolean default FALSE
             ) return varchar2;
--
-- ============================================================================
-- Function Name:<<get_pl_name>>
-- Description:
--      Return plan name from cache or from database.
--.
-- ============================================================================
--
Function get_pl_name
             (p_pl_id              in number
             ,p_business_group_id  in number
             ,p_effective_date     in date
             ,p_batch_flag         in boolean default FALSE
             ) return varchar2;
--
-- ============================================================================
-- Function Name:<<get_opt_name>>
-- Description:
--      Return option name from cache or from database.
--.
-- ============================================================================
--
Function get_opt_name
             (p_oipl_id            in number
             ,p_business_group_id  in number
             ,p_effective_date     in date
             ,p_batch_flag         in boolean default FALSE
             ) return varchar2;
--
-- ============================================================================
-- Procedure Name:<<cache_person_information>>
-- Description:
--      Cache person infor into person cache data structure.
--.
-- ============================================================================
--
procedure cache_person_information
                (p_person_id            in number
                ,p_business_group_id    in number
                ,p_effective_date       in date
                ,p_cache_time_perd_flag in boolean default TRUE
                ,p_cache_pay_perd_flag  in boolean default TRUE
                ,p_cache_total_fte_flag in boolean default TRUE
                ) ;
--
-- ============================================================================
-- Procedure Name:<<Person_header>>
-- Description:
--      Procedure to print out the header of a person.
-- ============================================================================
--
Procedure person_header
             (p_person_id         in number default null
             ,p_business_group_id in number
             ,p_effective_date    in date
             ) ;
--
-- ============================================================================
-- Procedure Name:<<Ini>>
-- Description:
--      Procedure is to initialize the all batch_utils caches or individual
--      cache such as person. comp. obj, etc...
-- P_actn_cd: Null      - All
--            Per       - Person cache.
--            Comp      - Comp object cache.
--            comp_name - comp object name cache.
--            proc_info - process information.
--
-- ============================================================================
--
Procedure ini(p_actn_cd   in Varchar2 default hr_api.g_varchar2 );
--
-- ============================================================================
-- Procedure Name:<<rpt_error>>
-- Description:
--      Procedure is used to debug.
--
-- ============================================================================
--
procedure rpt_error (p_proc       in varchar2
                    ,p_last_actn  in varchar2
                    ,p_rpt_flag   in boolean default FALSE
                    );
--
-- ============================================================================
-- Procedure Name:<<person_selection_rule>>
-- Description:
--      Function will return Y if rule is passed. and N if fail.  If error,
--      then it will raise ben_batch_utils.g_record_error.
--
-- ============================================================================
--
Function person_selection_rule
                 (p_person_id                in  Number
                 ,p_business_group_id        in  Number
                 ,p_person_selection_rule_id in  Number
                 ,p_effective_date           in  Date
                 ,p_batch_flag               in  Boolean default FALSE
                 ,p_input1                   in  varchar2 default null    -- Bug 5331889
                 ,p_input1_value             in  varchar2 default null
                 ) return char;
--
-- ============================================================================
-- Procedure Name:<<print_parameters>>
-- Description:
--      procedure print out the parameter list
--
-- ============================================================================
--
procedure print_parameters
            (p_thread_id                in number
            ,p_validate                 in varchar2
            ,p_benefit_action_id        in number
            ,p_effective_date           in date
            ,p_business_group_id        in number
            ,p_pgm_id                   in number	 default hr_api.g_number
            ,p_pl_id                    in number	 default hr_api.g_number
            ,p_popl_enrt_typ_cycl_id    in number	 default hr_api.g_number
            ,p_person_id                in number    default hr_api.g_number
            ,p_person_type_id           in number    default hr_api.g_number
            ,p_ler_id                   in number    default hr_api.g_number
            ,p_organization_id          in number  	 default hr_api.g_number
            ,p_benfts_grp_id            in number    default hr_api.g_number
            ,p_location_id              in number    default hr_api.g_number
            ,p_legal_entity_id          in number    default hr_api.g_number
            ,p_payroll_id               in number    default hr_api.g_number
            ,p_no_programs              in varchar2	 default hr_api.g_varchar2
            ,p_no_plans                 in varchar2	 default hr_api.g_varchar2
            ,p_rptg_grp_id              in number	 default hr_api.g_number
            ,p_pl_typ_id                in number	 default hr_api.g_number
            ,p_opt_id                   in number	 default hr_api.g_number
            ,p_eligy_prfl_id            in number	 default hr_api.g_number
            ,p_vrbl_rt_prfl_id          in number	 default hr_api.g_number
            ,p_mode                     in varchar2	 default hr_api.g_varchar2
            ,p_person_selection_rule_id in number	 default hr_api.g_number
            ,p_comp_selection_rule_id   in number	 default hr_api.g_number
            ,p_enrt_perd_id             in number        default hr_api.g_number
            ,p_derivable_factors        in varchar2	 default hr_api.g_varchar2
            ,p_audit_log                in varchar2	 default hr_api.g_varchar2
            );
--
-- ============================================================================
-- Procedure Name:<<Check_all_slaves_finished>>
-- Description:
--      Procedure will make sure all the slaves belong to the master process
--      completed before exit the loop.
--
-- ============================================================================
--
Procedure check_all_slaves_finished(p_rpt_flag Boolean default FALSE);
--
-- ============================================================================
-- Procedure Name:<<Write_Rec>>
-- Description:
--      Procedure write an report record into ben_report table.
--
-- ============================================================================
--
Procedure Write_rec(p_typ_cd   in varchar2
                   ,p_text     in varchar2 default NULL
                   ,p_err_cd   in varchar2 default NULL
                   );
--
-- ============================================================================
-- Procedure Name:<<Write>>
-- Description:
--   Procedure write text directly into log file.  If not run from con-
--   current manager, then it will run dbms_output to screen if debug
--   flag set to TRUE.
--
-- ============================================================================
--
Procedure write (p_text varchar2);
--
-- ============================================================================
-- Procedure Name:<<Write_logfile>>
-- Description:
--   Procedure write process info into report table.
--
-- ============================================================================
--
procedure write_logfile(p_num_pers_processed in number
                       ,p_num_pers_errored   in number
                       ,p_non_person_cd      in varchar2 default null
                       );

--
-- ============================================================================
-- Procedure Name:<<End Process>>
-- Description:
--   Procedure write process info into report table.
--
-- ============================================================================
--
Procedure End_process (p_benefit_action_id   in number
                      ,p_person_selected     in number
                      ,p_business_group_id   in number   default NULL
                      ,p_non_person_cd       in varchar2 default null
                      );
--
-- ============================================================================
--                     <<Create_restart_person_actions>>
-- ============================================================================
--
Procedure create_restart_person_actions
  (p_benefit_action_id  in  number
  ,p_effective_date     in  date
  ,p_chunk_size         in  number
  ,p_threads            in  number
  ,p_num_ranges         out nocopy number
  ,p_num_persons        out nocopy number
  ,p_commit_data        in  varchar2 default 'Y'
  ,p_non_person_cd      in  varchar2 default null
  );
--
-- ============================================================================
--                     <<Batch_report>>
-- ============================================================================
--
Procedure batch_report
            (p_concurrent_request_id      in  number
            ,p_program_name               in  varchar2
            ,p_subtitle                   in  varchar2 default NULL
            ,p_request_id                 out nocopy number
            );
--
-- ============================================================================
--                     <<Write_error_rec>>
-- ============================================================================
--
Procedure write_error_rec ;
--
-- ============================================================================
--                     <<Summary_by_action>>
-- ============================================================================
--
procedure summary_by_action
            (p_concurrent_request_id in  number
            ,p_cd_1   in  varchar2, p_val_1  out nocopy number
            ,p_cd_2   in  varchar2, p_val_2  out nocopy number
            ,p_cd_3   in  varchar2, p_val_3  out nocopy number
            ,p_cd_4   in  varchar2, p_val_4  out nocopy number
            ,p_cd_5   in  varchar2, p_val_5  out nocopy number
            ,p_cd_6   in  varchar2, p_val_6  out nocopy number
            ,p_cd_7   in  varchar2, p_val_7  out nocopy number
            ,p_cd_8   in  varchar2, p_val_8  out nocopy number
            ,p_cd_9   in  varchar2, p_val_9  out nocopy number
            ,p_cd_10  in  varchar2, p_val_10 out nocopy number
            );
--
-- ============================================================================
--                     <<Procedure: *get_rpt_header*>>
-- ============================================================================
--
Procedure get_rpt_header
            (p_concurrent_request_id in     number
            ,p_cd_1                     out nocopy varchar2
            ,p_cd_2                     out nocopy varchar2
            ,p_cd_3                     out nocopy varchar2
            ,p_cd_4                     out nocopy varchar2
            ,p_cd_5                     out nocopy varchar2
            ,p_cd_6                     out nocopy varchar2
            ,p_cd_7                     out nocopy varchar2
            ,p_cd_8                     out nocopy varchar2
            ,p_cd_9                     out nocopy varchar2
            ,p_cd_10                    out nocopy varchar2
            ,p_cd_11                    out nocopy varchar2
            ,p_cd_12                    out nocopy varchar2
            ,p_cd_13                    out nocopy varchar2
            ,p_cd_14                    out nocopy varchar2
            ,p_cd_15                    out nocopy varchar2
            ,p_cd_16                    out nocopy varchar2
            ,p_cd_17                    out nocopy varchar2
            ,p_cd_18                    out nocopy varchar2
            ,p_cd_19                    out nocopy varchar2
            ,p_cd_20                    out nocopy varchar2
            );
--
-- ============================================================================
--                     <<Function: standart_header>>
-- ============================================================================
--
Procedure standard_header
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
           p_debug_message			 out nocopy varchar2,
           p_location                   out nocopy varchar2,
           p_audit_log                  out nocopy varchar2,
           p_benfts_group               out nocopy varchar2,
           p_date_from                  out nocopy date,         /* Bug 3517604 */
           p_status                     out nocopy varchar2);
--
-- ============================================================================
--                     <<Function: Ret_str (Overload function)>>
-- ============================================================================
--
Function ret_str(p_str varchar2, p_len number default 30) return varchar2;
Function ret_str(p_num number,   p_len number default 15) return varchar2;
Function ret_str(p_date date,    p_len number default 12) return varchar2;
--

-- Bug 2978945 added function rows_exist.
-- ============================================================================
-- Function Name:<<rows_exist>>
-- Description:
--	       Return true if one or more record exists in the table
--             for the given id. This is similar to the rows_exist function
--	       in dt_api, but for records that are not date tracked.
-- ============================================================================
--
FUNCTION rows_exist
         (p_base_table_name IN VARCHAR2,
          p_base_key_column IN VARCHAR2,
          p_base_key_value  IN NUMBER
         )
         RETURN BOOLEAN;
--
procedure person_selection_rule
		 (p_person_id                in  Number
                 ,p_business_group_id        in  Number
                 ,p_person_selection_rule_id in  Number
                 ,p_effective_date           in  Date
                 ,p_input1                   in  varchar2 default null    -- Bug 5331889
                 ,p_input1_value             in  varchar2 default null
		 ,p_return                   in out nocopy varchar2
                 ,p_err_message              in out nocopy varchar2 ) ;


end ben_batch_utils;

/
