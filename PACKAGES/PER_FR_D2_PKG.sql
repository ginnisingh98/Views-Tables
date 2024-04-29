--------------------------------------------------------
--  DDL for Package PER_FR_D2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_D2_PKG" 
/* $Header: pefrd2rp.pkh 120.0 2005/05/31 08:54:26 appldev noship $ */
  AUTHID CURRENT_USER AS
    --
    type table_of_number is table of number index by binary_integer;
    -- #4068197
    type table_of_varchar is table of varchar2(30) index by binary_integer;
    -- #4068197

    --
    type block_record is record (
        per_type_id             per_all_people_f.person_type_id%type := null,
        person_type_usages      varchar2(32000),
        asg_id                  per_all_assignments_f.assignment_id%type := null,
        asg_status              per_all_assignments_f.assignment_status_type_id%type := null,
        asg_primary             per_all_assignments_f.primary_flag%type := null,
        asg_employment_category per_all_assignments_f.employment_category%type := null,
        asg_freq                per_all_assignments_f.frequency%type := null,
        asg_hours               per_all_assignments_f.normal_hours%type := null,
        asg_type                per_all_assignments_f.assignment_type%type,
        ctr_type                per_contracts_f.type%type := null,
        ctr_fr_person_replaced  per_contracts_f.ctr_information5%type := null,
        ctr_status              per_contracts_f.status%type := null,
        ass_employee_category   hr_soft_coding_keyflex.segment2%type := null,
        asg_full_time_freq      per_all_positions.frequency%type := null,
        asg_full_time_hours     per_all_positions.working_hours%type := null,
        asg_fte_value           per_assignment_budget_values_f.value%type := null,
        block_start_date        date := null,
        block_end_date          date := null );
    --
    type table_of_block is table of block_record index by binary_integer;

    -- Removed nvl operators (Bug 2662236)
    --
    cursor csr_get_emp_year (p_establishment_id in NUMBER,
                             p_1jan in DATE,
                             p_31dec in date)
    is
    -- scan all employees in the given year
    select distinct a.person_id
      from per_assignment_status_types t,
      per_all_assignments_f a
      where t.assignment_status_type_id = a.assignment_status_type_id
      and t.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN'
                                 ,'ACTIVE_CWK','SUSP_CWK_ASG')
      and a.establishment_id = p_establishment_id
      and a.assignment_type in ('E','C')
      and a.effective_end_date >= p_1jan
      and a.effective_start_date <= p_31dec;
    --
    cursor csr_get_asg_emp (p_establishment_id in number,
                            p_1jan in date,
                            p_31dec in date,
                            p_person_id in number)
    is
    -- scan all assignments for the given employee
    select distinct a.assignment_id asg_id
      from per_assignment_status_types t,
      per_all_assignments_f a
      where a.person_id                 = p_person_id
      and t.assignment_status_type_id   = a.assignment_status_type_id
      and nvl(t.per_system_status,' ') in ('ACTIVE_ASSIGN','SUSP_ASSIGN'
                                          ,'ACTIVE_CWK','SUSP_CWK_ASG')
      and nvl(a.establishment_id,-1)    = p_establishment_id
      and a.assignment_type            in ('E','C')
      and a.effective_end_date         >= p_1jan
      and a.effective_start_date       <= p_31dec
      order by asg_id;
      --
     cursor csr_get_disabled (p_establishment_id in number,
        p_1jan in date,
        p_31dec in date)
      is
        -- works out IDs of disabled
     select distinct id from
       (select asg.person_id id,
       pdf.effective_start_date date_from,
       pdf.effective_end_date date_to,
       asg.effective_start_date asg_from,
       asg.effective_end_date asg_to
       from
       per_disabilities_f pdf,
       per_assignment_status_types typ,
       per_all_assignments_f asg
       where asg.person_id               = pdf.person_id
       and asg.assignment_type           = 'E'
       and typ.assignment_status_type_id = asg.assignment_status_type_id
       and typ.per_system_status        in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
       and asg.establishment_id          = p_establishment_id
       and (pdf.category in ('A','B','C') or
            pdf.reason = 'OCC_INC' or
            pdf.dis_information1 in ('CIVIL','MILITARY','MILITARY_EQUIVALENT'))
       and pdf.DIS_INFORMATION_CATEGORY  = 'FR'
       and asg.effective_start_date     <= p_31dec
       and asg.effective_end_date       >= p_1jan)
       where date_from                  <= least(p_31dec,asg_to)
       and   date_to                    >= greatest(p_1jan,asg_from)
       order by id;
     --
     --
    function set_headcounts (p_establishment_id in number,
                               p_1jan in date,
                               p_31dec in date,
                               p_headcount_obligation out nocopy number,
                               p_headcount_particular out nocopy number,
                               p_basis_obligation out nocopy number,
                               p_obligation out nocopy number,
                               p_breakdown_particular out nocopy varchar2,
                               p_count_disabled out nocopy varchar2,
                            p_disabled_where_clause out nocopy varchar2)
                              return integer;
    -- compute headcounts for the establishment
    --
    procedure get_extra_units (p_establishment_id in number,
			       p_effective_date in date,
			       p_base_unit out nocopy number,
			       p_xcot_a out nocopy number,
			       p_xcot_b out nocopy number,
			       p_xcot_c out nocopy number,
			       p_xcot_young_age out nocopy number,
			       p_xcot_old_age out nocopy number,
			       p_xcot_age_units out nocopy number,
			       p_xcot_training_hours out nocopy number,
			       p_xcot_training_units out nocopy number,
			       p_xcot_ap out nocopy number,
			       p_xcot_impro out nocopy number,
			       p_xcot_cat out nocopy number,
			       p_xcot_cdtd out nocopy number,
			       p_xcot_cfp out nocopy number,
			       p_xipp_low_rate out nocopy number,
			       p_xipp_medium_rate out nocopy number,
			       p_xipp_high_rate out nocopy number,
			       p_xipp_low_units out nocopy number,
			       p_xipp_medium_units out nocopy number,
			       p_xipp_high_units out nocopy number,
			       p_hire_units out nocopy number);
    -- get values from fr_d2_rates
    --
    function include_this_person_type (p_user_person_types in varchar2,
                                       p_business_group_id in number,
                                       p_effective_date in date)
                                       return boolean;
    -- decide wether the person type is reported in the D2 or not
    --
    procedure trunc_list_disabled (p_person_id in number,
                                   p_list in out nocopy varchar2);
    -- remove person from list of disabled
    --
    function contract_prorated (p_block in block_record,
                                p_business_group_id in number,
                                p_estab_hours in number,
                                p_31dec in date,
                                p_tmp_total in out nocopy number,
                                p_formula_id in number,
                                p_formula_start_date in date)
                                return integer;
    -- update non-integer headcount (eg. 0.5 for half-time assignment)
    --
    -- Get the job valid pcs code
    procedure get_pcs_code (p_report_qualifier    in         varchar2
                           ,p_job_id              in         per_jobs.job_id%type default null
	                   ,p_job_name            in         per_jobs.name%type   default null
                           ,p_pcs_code            in out nocopy varchar2
                           ,p_effective_date      in         date);

    procedure get_job_info (p_establishment_id in number,
                           p_person_id in number,
                           p_1jan in date,
                           p_31dec in date,
                           p_year in number,
                           p_pcs_code out nocopy varchar2,
                           p_job_title out nocopy varchar2,
                           p_hours_training out nocopy number,
                           p_hire_year out nocopy number,
                           p_year_became_permanent out nocopy number);
    -- retrieves info on job
    --pragma restrict_references (get_job_info,WNDS,WNPS);
    --
    function get_estab_hours (p_establishment_id in number)
                              return number;
    -- return reference monthly hours
    --
    function list_disabled (p_establishment_id in number,
                            p_1jan in date,
                            p_31dec in date)
                            return varchar2;
    -- return SQL statement to select disabled employees ID
    --
    procedure update_particular (p_establishment_id in number,
                             p_person_id in number,
                             p_1jan in date,
                             p_31dec in date,
                             p_business_group_id in number,
                             p_employee_count in number,
                             p_headcount_particular in out nocopy number,
                             p_pcs_count in out nocopy table_of_number,
                             p_pcs_codes in out nocopy table_of_varchar);
    -- update headcount for particular pcs_codes
    --
    -- #4068197
    function string_of_particular (p_pcs_count in table_of_number,
                                   p_pcs_codes in table_of_varchar)
                                   return varchar2;
    -- #4068197
    -- change table (for breakdown) into SQL string to pass to the report
    --
    procedure update_count_disabled (p_person_id in number,
                               p_list in varchar2,
                               p_employee_count in number,
                               p_count_disabled in out nocopy varchar2);
    -- update string of disabled employees (eg. '123=1;436=0.5;677=1;')
    --
    procedure get_formula_ref (p_effective_date in date,
                               p_business_group_id in number,
                               p_formula_id out nocopy number,
                               p_formula_start_date out nocopy date);
    -- give references of 'Contract Prorated' fast formula
    --
    function relevant_change (block1 in block_record,
                         block2 in block_record)
                              return boolean;
    -- work out if 2 consecutive small blocks must be considered
    -- as 1 consolidated block or 2 distinct blocks
    --
    function posid_in_list (p_id in number,
                            p_list in varchar2)
                            return integer;
    -- return position of id in list (or 0 if not in list)
    -- eg. 78 is a substring of 178 but 78 is not an id in '12,178,2200'
    --
    procedure populate_blocks_table (p_establishment_id in number,
                                     p_1jan in date,
                                     p_31dec in date,
                                     p_person_id in number,
                                     p_blocks out nocopy table_of_block);
    -- populate the table of blocks for an employee
    --
    function latest_block (p_assignment_id in number,
                           p_establishment_id in number,
                           p_start_period in date,
                           p_end_period in date)
                           return date;
    -- get the end-date of the latest block
    -- which meets the criteria in the given period
    --
    function beginning_of_block (p_assignment_id in number,
                                 p_end_date in date,
                                 p_1jan in date)
                                 return date;
    -- get the start-date of the block which end date is known
    --
    procedure add_block_row (p_block_table in out nocopy table_of_block,
                             p_assignment_id in number,
                             p_start_date in date,
                             p_end_date in date);
    -- add a record into the table of blocks
    --
END PER_FR_D2_PKG;

 

/
