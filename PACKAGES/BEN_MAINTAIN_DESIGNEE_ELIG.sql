--------------------------------------------------------
--  DDL for Package BEN_MAINTAIN_DESIGNEE_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MAINTAIN_DESIGNEE_ELIG" AUTHID CURRENT_USER as
/* $Header: bendsgel.pkh 120.0.12010000.1 2008/07/29 12:11:55 appldev ship $ */
--
-- Global Cursors and Global variables.
--
g_record_error	exception;
g_debug		    boolean := FALSE;
type rpt_str is table of varchar2(132) index by binary_integer;
g_rpt_cache     rpt_str;
g_rpt_cnt       binary_integer := 0;
g_profile_value varchar2(30) := fnd_profile.value('BEN_DSG_NO_CHG');

type g_cache_log_file_rec is table of varchar2(255)
     index by binary_integer;
g_cache_log_file g_cache_log_file_rec;

type g_cache_person_process_object is record
   	(person_id                ben_person_actions.person_id%type
   	,person_action_id         ben_person_actions.person_action_id%type
   	,object_version_number    ben_person_actions.object_version_number%type
   	,ler_id                   ben_person_actions.ler_id%type
        );
type g_cache_person_process_rec is table of g_cache_person_process_object
    index by binary_integer;
g_cache_person_process g_cache_person_process_rec;

type g_cache_person_rec is record
  	(full_name                  per_people_f.full_name%type
   	,date_of_birth              per_people_f.date_of_birth%type
   	,date_of_death              per_people_f.date_of_death%type
   	,benefit_group              ben_benfts_grp.name%type
   	,benefit_group_id           per_people_f.benefit_group_id%type
   	,postal_code                per_addresses.postal_code%type
   	,person_has_type_emp        varchar2(1)
   	,assignment_id              per_assignments_f.assignment_id%type
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
   	,labour_union_member_flag   per_assignments_f.labour_union_member_flag%type
   	,assignment_status_type_id  per_assignments_f.assignment_status_type_id%type
   	,change_reason              per_assignments_f.change_reason%type
   	,employment_category        per_assignments_f.employment_category%type
   	,org_information1           hr_organization_information.org_information1%type
   	,bg_name                    hr_all_organization_units.name%type
   	,org_id                     hr_all_organization_units.organization_id%type
   	,org_name                   hr_all_organization_units.name%type
    );
g_cache_person g_cache_person_rec;
type g_cache_person_types_object is record
     	(person_type_id         per_person_type_usages_f.person_type_id%type
      	,user_person_type       per_person_types.user_person_type%type
      	,system_person_type     per_person_types.system_person_type%type
        );
type g_cache_person_types_rec is table of g_cache_person_types_object
      index by binary_integer;
g_cache_person_types g_cache_person_types_rec;
--
procedure process(errbuf                        out nocopy varchar2
                 ,retcode                       out nocopy number
                 ,p_benefit_action_id        in     number
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_person_id                in     number   default null
                 ,p_person_type_id           in     number   default null
                 ,p_business_group_id        in     number
                 ,p_person_selection_rule_id in     number   default null
                 ,p_comp_selection_rule_id   in     number   default null
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_organization_id          in     number   default null
                 ,p_benfts_grp_id            in     number   default null
                 ,p_location_id              in     number   default null
                 ,p_legal_entity_id          in     number   default null
                 ,p_payroll_id               in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N'
                 );
procedure restart (errbuf                 out nocopy varchar2
                  ,retcode                out nocopy number
                  ,p_benefit_action_id in     number
                  );
procedure do_multithread
             (errbuf                     out nocopy varchar2
             ,retcode                    out nocopy number
             ,p_validate              in     varchar2 default 'N'
             ,p_benefit_action_id     in     number
             ,p_thread_id             in     number
             ,p_effective_date        in     varchar2
             ,p_business_group_id     in     number
             );
procedure process_designee_elig
                  (p_validate              in     varchar2 default 'N'
                  ,p_person_id             in     number default null
                  ,p_person_action_id      in     number default null
                  ,p_comp_selection_rl     in     number
                  ,p_pgm_id                in     number
                  ,p_pl_id                 in     number
                  ,p_object_version_number in out nocopy number
                  ,p_business_group_id     in     number
                  ,p_effective_date        in     date
                  );
function comp_selection_rule
                 (p_person_id                in     number
                 ,p_business_group_id        in     number
                 ,p_pgm_id                   in     number
                 ,p_pl_id                    in     number
                 ,p_pl_typ_id                    in     number
                 ,p_opt_id                   in     number
                 ,p_ler_id                   in     number
                 ,p_oipl_id                  in     number
                 ,p_comp_selection_rule_id   in     number
                 ,p_effective_date           in     date
                 ) return char;
End ben_maintain_designee_elig;

/
