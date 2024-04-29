--------------------------------------------------------
--  DDL for Package Body PAY_RETRO_NOTIF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RETRO_NOTIF_PKG" as
/* $Header: payretno.pkb 120.20.12010000.5 2009/12/11 09:57:18 phattarg ship $ */
-------------------------------------------------------------------------------
g_package varchar2(80) := 'PAY_RETRO_NOTIF_PKG.';
g_traces BOOLEAN := hr_utility.debug_enabled; --See if hr_utility.traces should show
g_dbg    BOOLEAN := FALSE; --Extra debugging messages

g_event_group       pay_event_groups.event_group_id%type;
g_business_group_id per_business_groups.business_group_id%type;
g_payroll_act_id    pay_payroll_actions.payroll_action_id%type;
g_payroll_id        pay_payrolls_f.payroll_id%type;
g_asg_set_id        hr_assignment_sets.assignment_set_id%type;
g_global_env        pay_interpreter_pkg.t_global_env_rec;
g_adv_flag          varchar2(5);
g_report_date       date;


procedure get_pact_details (pactid in number,
                            p_asg_set_name out nocopy varchar2,
                            p_bus_grp      out nocopy number,
                            p_payroll      out nocopy number,
                            p_evt_grp      out nocopy number,
                            p_adv_flag     out nocopy varchar2,
                            p_report_date  out nocopy date)
is
  l_payroll_id     number;
  l_evt_grp_id     number;
  l_legparam       pay_payroll_actions.legislative_parameters%type;
  l_asg_set_name   pay_payroll_actions.legislative_parameters%type;
  l_bus_grp        number;
  l_adv_flag       varchar2(1) := 'N';
  l_report_date    date;
begin
      select legislative_parameters,
             business_group_id,
             nvl(to_date( pay_core_utils.get_parameter('REPORT_DATE',
                                                       l_legparam)
                      ,'DD/MM/YYYYHH24:MI:SS'),
                 effective_date)
        into l_legparam,
             l_bus_grp,
             l_report_date
        from pay_payroll_actions
       where payroll_action_id = pactid;
--
      l_payroll_id := pay_core_utils.get_parameter('PAYROLL_ID', l_legparam);
      l_asg_set_name := pay_core_utils.get_parameter('ASG_SET', l_legparam)||'_'||pactid;
      l_evt_grp_id := pay_core_utils.get_parameter('EVT_GRP_ID', l_legparam);
      l_adv_flag  := pay_core_utils.get_parameter('ADV_FLAG', l_legparam);
--
      p_asg_set_name := l_asg_set_name;
      p_payroll      := l_payroll_id;
      p_bus_grp      := l_bus_grp;
      p_evt_grp      := l_evt_grp_id;
      if (l_adv_flag is null) then
        l_adv_flag := 'N';
      end if;
      p_adv_flag     := l_adv_flag;
      p_report_date  := l_report_date;
--
  if (g_traces) then
  hr_utility.trace('Full param string: '||l_legparam);
  hr_utility.trace('Got report date in get_pact_details '
                    ||to_char(l_report_date,'DD-MON-YYYY HH24:MI:SS'));
  end if;

end get_pact_details;


procedure get_asg_set_id (p_asg_set_name in         varchar2,
                          p_payroll      in         number,
                          p_asg_set_id   out nocopy number)
is
l_asg_set_id number;
begin
--
    select assignment_set_id
      into l_asg_set_id
      from hr_assignment_sets
     where assignment_set_name = p_asg_set_name
       and payroll_id = p_payroll;
--
  p_asg_set_id := l_asg_set_id;
--
exception when no_data_found then
  p_asg_set_id := -1;
--
end get_asg_set_id;
--
procedure validate_asg_set (p_asg_set in varchar2) IS
--
cursor c_set_check is
  SELECT 'X'
  FROM    hr_assignment_sets
  WHERE   UPPER(assignment_set_name) = UPPER(p_asg_set);
--
l_dummy VARCHAR2(1);
--
begin
--
  open c_set_check;
  fetch c_set_check into l_dummy;
    if c_set_check%FOUND then
      hr_utility.set_message(801, 'HR_6395_SETUP_SET_EXISTS');
      hr_utility.raise_error;
    end if;
  close c_set_check;
--
end validate_asg_set;
--
procedure run_report (p_payroll_action_id      in number,
                      p_adv_flag               in varchar2)
--
is
l_wait_outcome          BOOLEAN;
l_phase                 VARCHAR2(80);
l_status                VARCHAR2(80);
l_dev_phase             VARCHAR2(80);
l_dev_status            VARCHAR2(80);
l_message               VARCHAR2(80);
l_errbuf                VARCHAR2(240);
l_req_id                NUMBER;
--
l_copies_buffer 	varchar2(80) := null;
l_print_buffer  	varchar2(80) := null;
l_printer_buffer  	varchar2(80) := null;
l_style_buffer  	varchar2(80) := null;
l_save_buffer    	boolean := null;
l_save_result   	varchar2(1) := null;
c_req_id 	    	VARCHAR2(80) := NULL; /* Request Id of the main request */
l_dummy  			BOOLEAN;
--
zero_req_id                 Exception;
pragma exception_init(zero_req_id, -9999);
--
begin

  c_req_id:=fnd_profile.value('CONC_REQUEST_ID');
  l_print_buffer:= fnd_profile.value('CONC_PRINT_TOGETHER');

  select number_of_copies,
        printer,
        print_style,
        save_output_flag
  into  l_copies_buffer,
        l_printer_buffer,
        l_style_buffer,
        l_save_result
  from  fnd_concurrent_requests
  where request_id = to_number(c_req_id);

  if (l_save_result='Y') then
     l_save_buffer:=true;
  elsif (l_save_result='N') then
     l_save_buffer:=false;
  else
     l_save_buffer:=NULL;
  end if;

  l_dummy := FND_REQUEST.set_print_options(
			printer => l_printer_buffer,
			style	=> l_style_buffer,
			copies  => l_copies_buffer,
			save_output => l_save_buffer,
			print_together => l_print_buffer);


  l_req_id := fnd_request.submit_request(
                            application    => 'PAY',
                            program        => 'PYXMLRNP3',
                            sub_request    => FALSE,
                            argument1      => p_payroll_action_id);

  IF l_req_id = 0 THEN
     fnd_message.retrieve(l_errbuf);
     hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
     raise zero_req_id;
  ELSE
--
    if p_adv_flag = 'Y' then
      update fnd_concurrent_requests
         set output_file_type = 'XML'
       where request_id = l_req_id;
    end if;
--
    COMMIT;
--
    l_wait_outcome := FND_CONCURRENT.WAIT_FOR_REQUEST(
                                         request_id     => l_req_id,
                                         interval       => 30,
                                         max_wait       => 86400,
                                         phase          => l_phase,
                                         status         => l_status,
                                         dev_phase      => l_dev_phase,
                                         dev_status     => l_dev_status,
                                         message        => l_message);
--
--     IF (l_dev_phase = 'COMPLETE' and l_status = 'NORMAL') THEN
--        update fnd_concurrent_requests
--           set PARENT_REQUEST_ID = to_number(c_req_id)
--         where request_id = l_req_id;
--     ELSE
--        hr_utility.set_message(801, 'HR_51002_REPORT_CANT_SUBMITTED');
--        hr_utility.raise_error;
--     END IF;
--
  END IF;

exception
  when zero_req_id then
    hr_utility.set_message(801, 'HR_51002_REPORT_CANT_SUBMITTED');
    hr_utility.raise_error;
  when others then
    l_errbuf := SQLERRM;
    hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
    hr_utility.set_message(801, 'HR_51002_REPORT_CANT_SUBMITTED');
    hr_utility.raise_error;

end run_report;
--
procedure create_retro_asg_set(p_asg_set_name in varchar2,
                               p_business_group_id in number,
                               p_payroll_id in number) is
--
  cursor c_sequence is
   SELECT hr_assignment_sets_s.nextval
   FROM dual;
  --
  l_rowid        VARCHAR2(30);
  l_asg_set_id   NUMBER;
--
begin
--
  validate_asg_set (p_asg_set_name);
--
  open c_sequence;
  fetch c_sequence into l_asg_set_id;
  close c_sequence;
  --
  hr_assignment_sets_pkg.insert_row(
           p_rowid               => l_rowid
  ,        p_assignment_set_id   => l_asg_set_id
  ,        p_business_group_id   => p_business_group_id
  ,        p_payroll_id          => p_payroll_id
  ,        p_assignment_set_name => p_asg_set_name
  ,        p_formula_id          => null);
  --
end create_retro_asg_set;
--
-------------------------------------------------------------------------------
Procedure get_asg_info(
        p_assignment_id     IN            NUMBER
,       p_report_date       IN            DATE
,       p_business_group_id IN            NUMBER
,       p_legislation_code  IN            VARCHAR2
,       p_asg_status           OUT NOCOPY VARCHAR2
,       p_person_name          OUT NOCOPY VARCHAR2) is
--
l_asg_status  VARCHAR2(80)  := NULL;
l_person_name VARCHAR2(240) := NULL;
--
Begin
--
  SELECT astTL.user_status
  ,      ppf.full_name
  INTO   l_asg_status
  ,      l_person_name
  FROM   per_assignments_f              paf
  ,      per_assignment_status_types    ast
  ,      per_assignment_status_types_tl astTL
  ,      per_people_f                   ppf
  WHERE  paf.assignment_id = p_assignment_id
  AND    paf.business_group_id = p_business_group_id
  AND    paf.person_id = ppf.person_id
  AND    ppf.business_group_id = p_business_group_id
  AND    paf.assignment_status_type_id = ast.assignment_status_type_id
  AND    (ast.business_group_id = p_business_group_id
  OR     (ast.business_group_id IS NULL
  AND    ast.legislation_code = p_legislation_code)
  OR     (ast.business_group_id IS NULL
  AND    ast.legislation_code IS NULL))
  AND    ast.assignment_status_type_id = astTL.assignment_status_type_id
  AND    astTL.language = userenv('LANG')
  AND    p_report_date BETWEEN paf.effective_start_date
                       AND     paf.effective_end_date
  AND    p_report_date BETWEEN ppf.effective_start_date
                       AND     ppf.effective_end_date;
--
p_asg_status  := l_asg_status;
p_person_name := l_person_name;
--
EXCEPTION
WHEN OTHERS THEN NULL;
--
End get_asg_info;
-------------------------------------------------------------------------------
Procedure get_ele_info(
        p_element_entry_id  IN            NUMBER
,       p_report_date       IN            DATE
,       p_business_group_id IN            NUMBER
,       p_legislation_code  IN            VARCHAR2
,       p_element_name         OUT NOCOPY VARCHAR2) is
--
l_element_name VARCHAR2(80) := NULL;
--
Cursor c_ins_upd_ele is
  SELECT petTL.element_name element
  FROM   pay_element_types_f_tl petTL
  ,      pay_element_types_f    pet
  ,      pay_element_links_f    pel
  ,      pay_element_entries_f  pef
  WHERE  pef.element_entry_id = p_element_entry_id
  AND    pef.element_link_id  = pel.element_link_id
  AND    pel.business_group_id = p_business_group_id
  AND    pel.element_type_id  = pet.element_type_id
  AND    pet.element_type_id  = petTL.element_type_id
  AND    petTL.language = userenv('LANG')
  AND    (pet.business_group_id = p_business_group_id
  OR     (pet.business_group_id IS NULL
  AND    pet.legislation_code = p_legislation_code)
  OR     (pet.business_group_id IS NULL
  AND    pet.legislation_code IS NULL))
  AND    p_report_date BETWEEN pef.effective_start_date
                       AND     pef.effective_end_date
  AND    p_report_date BETWEEN pel.effective_start_date
                       AND     pel.effective_end_date
  AND    p_report_date BETWEEN pet.effective_start_date
                       AND     pet.effective_end_date;
--
Cursor c_del_ele is
  SELECT petTL.element_name
  FROM   pay_element_types_f_tl petTL
  ,      pay_element_types_f    pet
  ,      pay_run_results        prr
  WHERE  prr.source_id = p_element_entry_id
  AND    prr.source_type = 'E'
  AND    prr.element_type_id  = pet.element_type_id
  AND    pet.element_type_id  = petTL.element_type_id
  AND    petTL.language = userenv('LANG')
  AND    (pet.business_group_id = p_business_group_id
  OR     (pet.business_group_id IS NULL
  AND    pet.legislation_code = p_legislation_code)
  OR     (pet.business_group_id IS NULL
  AND    pet.legislation_code IS NULL))
  AND    p_report_date BETWEEN pet.effective_start_date
                       AND     pet.effective_end_date;
--
Begin
--
  open c_ins_upd_ele;
  fetch c_ins_upd_ele into l_element_name;
    if c_ins_upd_ele%NOTFOUND then
      open c_del_ele;
      fetch c_del_ele into l_element_name;
        if c_del_ele%NOTFOUND then
          close c_del_ele;
        end if;
      close c_del_ele;
    end if;
  close c_ins_upd_ele;
--
p_element_name := l_element_name;
--
EXCEPTION
WHEN OTHERS THEN NULL;
--
End get_ele_info;
-------------------------------------------------------------

procedure process_assignment (p_assignment_id in number,
                              p_report_date in date,
                              p_event_group in number,
                              p_business_group_id in number,
                              p_payroll_act_id in number,
                              p_payroll_id in number,
                              p_asg_set_id in number,
                              p_min_creation_date in date,
                              p_time_processing_started in date,
                              p_global_env in out nocopy pay_interpreter_pkg.t_global_env_rec,
                              p_debug_flag in boolean,
                              p_adv_flag in varchar2 default 'N'
                             )
is
--
  Cursor c_ele (p_asg NUMBER,
                p_min DATE,
                p_max DATE,
                p_event_group_id number) is
   SELECT /*+ ORDERED INDEX(PDE PAY_DATETRACKED_EVENTS_UK1)
                   INDEX(PPA PAY_PAYROLL_ACTIONS_PK)
                   USE_NL(PDE)*/
          DISTINCT
          prr.source_id          entry,
          pde.datetracked_event_id
   FROM   pay_assignment_actions paa
   ,      pay_payroll_actions    ppa
   ,      pay_run_results        prr
   ,      pay_datetracked_events pde
   WHERE  prr.source_type = 'E'
   AND    prr.assignment_action_id = paa.assignment_action_id
   AND    paa.assignment_id = p_asg
   AND    paa.payroll_action_id = ppa.payroll_action_id
   AND    ppa.business_group_id = p_business_group_id
   AND    ppa.action_type in ('R', 'Q', 'B', 'V')
   AND    pde.event_group_id = p_event_group_id
   AND    ppa.date_earned IS NOT NULL
   AND   (ppa.date_earned    BETWEEN p_min AND p_max
       OR ppa.effective_date BETWEEN p_min AND p_max)
   /* Make sure that the Entry is not a Retropay Entry */
   AND NOT EXISTS (select ''
                     from pay_element_entries_f pee
                    where pee.element_entry_id = prr.source_id
                      and nvl(pee.creator_type, 'F') in ('EE', 'RR', 'PR', 'NR')
                  )
   UNION
   SELECT /*+ ORDERED INDEX(PDE PAY_DATETRACKED_EVENTS_UK1)
                      INDEX(PET PAY_ELEMENT_TYPES_F_PK)
                      INDEX(PAF PER_ASSIGNMENTS_F_PK)
                      USE_NL(PDE PAF)*/
          DISTINCT
          pee.element_entry_id   entry,
          pde.datetracked_event_id
   FROM   pay_element_entries_f  pee
   ,      pay_datetracked_events pde
   WHERE  pee.assignment_id = p_asg
   AND    pde.event_group_id = p_event_group_id
   /* Make sure that the Entry is not a Retropay Entry */
   AND    nvl(pee.creator_type, 'F') not in ('EE', 'RR', 'PR', 'NR')
   AND    pee.effective_start_date <= p_max
   AND    pee.effective_end_date   >= p_min
   AND    exists (select /*+ ORDERED INDEX(paa PAY_ASSIGNMENT_ACTIONS_N51)
                                     INDEX(ppa PAY_PAYROLL_ACTIONS_PK)
                                     USE_NL(paa ppa) */
                         ''
                    from pay_assignment_actions paa,
                         pay_payroll_actions ppa,
                         per_time_periods    ptp
                   where ppa.payroll_action_id = paa.payroll_action_id
                     and paa.assignment_id = pee.assignment_id
                     and paa.action_status not in ('E', 'M', 'U')
                     and ppa.action_type in ('R', 'Q', 'B', 'V')
                     and (ppa.date_earned    BETWEEN p_min AND p_max
                       OR ppa.effective_date BETWEEN p_min AND p_max)
                     and ppa.payroll_id = ptp.payroll_id
                     and ppa.date_earned between ptp.start_date
                                             and ptp.end_date
                     and pee.effective_start_date <= ptp.end_date
                     and pee.effective_end_date >= ptp.start_date
                  )
   ORDER BY 2;
--
  Cursor c_ele_adv (cp_asg NUMBER,
                cp_min_ed DATE,
                cp_max_ed DATE,
                p_event_group_id number) is
   SELECT /*+ ORDERED INDEX(PDE PAY_DATETRACKED_EVENTS_UK1)
                   INDEX(PPA PAY_PAYROLL_ACTIONS_PK)
                   USE_NL(PDE)*/
          DISTINCT
          prr.source_id          entry,
          prr.element_type_id    type,
          pde.datetracked_event_id,
          p_event_group_id
   FROM   pay_assignment_actions paa
   ,      pay_payroll_actions    ppa
   ,      pay_run_results        prr
   ,      pay_datetracked_events pde
   WHERE  prr.source_type = 'E'
   AND    prr.assignment_action_id = paa.assignment_action_id
   AND    prr.element_type_id = prr.element_type_id
   AND    paa.assignment_id = cp_asg
   AND    paa.payroll_action_id = ppa.payroll_action_id
   -- Only bring back a row if an event group is
   -- supplied to the process or a recalc one
   -- is on the element
   AND    pde.event_group_id = p_event_group_id
   AND    ppa.business_group_id = p_business_group_id
   AND    ppa.action_type in ('R', 'Q', 'B', 'V')
   AND    ppa.date_earned IS NOT NULL
   /* Make sure that the Entry is not a Retropay Entry */
   AND NOT EXISTS (select ''
                     from pay_element_entries_f pee
                    where pee.element_entry_id = prr.source_id
                      and nvl(pee.creator_type, 'F') in ('EE', 'RR', 'PR', 'NR')
                  )
   AND    (ppa.date_earned    BETWEEN cp_min_ed AND cp_max_ed
        OR ppa.effective_date BETWEEN cp_min_ed AND cp_max_ed)
   UNION
   SELECT  /*+ ORDERED INDEX(PDE PAY_DATETRACKED_EVENTS_UK1)
                      USE_NL(PDE)*/
          DISTINCT
          pee.element_entry_id   entry,
          pee.element_type_id    type,
          pde.datetracked_event_id,
          p_event_group_id
   FROM   pay_element_entries_f  pee
   ,      pay_datetracked_events pde
   WHERE  pee.assignment_id = cp_asg
   -- Only bring back a row if an event group is
   -- supplied to the process or a recalc one
   -- is on the element
   AND    pde.event_group_id = p_event_group_id
   /* Make sure that the Entry is not a Retropay Entry */
   AND    nvl(pee.creator_type, 'F') not in ('EE', 'RR', 'PR', 'NR')
   AND    pee.effective_start_date <= cp_max_ed
   AND    pee.effective_end_date   >= cp_min_ed
   AND    exists (select ''
                    from pay_assignment_actions paa,
                         pay_payroll_actions ppa,
                         per_time_periods    ptp
                   where ppa.payroll_action_id = paa.payroll_action_id
                     and paa.assignment_id = pee.assignment_id
                     and paa.action_status not in ('E', 'M', 'U')
                     and ppa.action_type in ('R', 'Q', 'B', 'V')
                     and (ppa.date_earned    BETWEEN cp_min_ed AND cp_max_ed
                       OR ppa.effective_date BETWEEN cp_min_ed AND cp_max_ed)
                     and ppa.payroll_id = ptp.payroll_id
                     and ppa.date_earned between ptp.start_date
                                             and ptp.end_date
                     and pee.effective_start_date <= ptp.end_date
                     and pee.effective_end_date >= ptp.start_date
                  )
  ORDER BY 1, 2;
--
  Cursor c_ele_adv_neg (cp_asg NUMBER,
                cp_min_ed DATE,
                cp_max_ed DATE,
                p_event_group_id number) is
   SELECT /*+ ORDERED INDEX(PDE PAY_DATETRACKED_EVENTS_UK1)
                   INDEX(PET PAY_ELEMENT_TYPES_F_PK)
                   INDEX(PPA PAY_PAYROLL_ACTIONS_PK)
                   USE_NL(PDE PET)*/
          DISTINCT
          prr.source_id          entry,
          pet.element_type_id    type,
          pde.datetracked_event_id,
          nvl(pet.recalc_event_group_id, -1) event_group_id
   FROM   pay_assignment_actions paa
   ,      pay_payroll_actions    ppa
   ,      pay_run_results        prr
   ,      pay_element_types_f    pet
   ,      pay_datetracked_events pde
   WHERE  prr.source_type = 'E'
   AND    prr.assignment_action_id = paa.assignment_action_id
   AND    prr.element_type_id = pet.element_type_id
   AND    paa.assignment_id = cp_asg
   AND    paa.payroll_action_id = ppa.payroll_action_id
   -- Only bring back a row if an event group is
   -- supplied to the process or a recalc one
   -- is on the element
   AND    pde.event_group_id = nvl(pet.recalc_event_group_id, -1)
   AND    ppa.business_group_id = p_business_group_id
   AND    ppa.action_type in ('R', 'Q', 'B', 'V')
   AND    ppa.date_earned IS NOT NULL
   /* Make sure that the Entry is not a Retropay Entry */
   AND NOT EXISTS (select ''
                     from pay_element_entries_f pee
                    where pee.element_entry_id = prr.source_id
                      and nvl(pee.creator_type, 'F') in ('EE', 'RR', 'PR', 'NR')
                  )
   AND    (ppa.date_earned    BETWEEN cp_min_ed AND cp_max_ed
        OR ppa.effective_date BETWEEN cp_min_ed AND cp_max_ed)
   UNION
   SELECT  /*+ ORDERED INDEX(PDE PAY_DATETRACKED_EVENTS_UK1)
                      INDEX(PET PAY_ELEMENT_TYPES_F_PK)
                      USE_NL(PDE PET)*/
          DISTINCT
          pee.element_entry_id   entry,
          pet.element_type_id    type,
          pde.datetracked_event_id,
          nvl(pet.recalc_event_group_id, -1) event_group_id
   FROM   pay_element_entries_f  pee
   ,      pay_element_types_f    pet
   ,      pay_datetracked_events pde
   WHERE  pee.assignment_id = cp_asg
   AND    pee.element_type_id = pet.element_type_id
   -- Only bring back a row if an event group is
   -- supplied to the process or a recalc one
   -- is on the element
   AND    pde.event_group_id = nvl(pet.recalc_event_group_id, -1)
   /* Make sure that the Entry is not a Retropay Entry */
   AND    nvl(pee.creator_type, 'F') not in ('EE', 'RR', 'PR', 'NR')
   AND    pee.effective_start_date <= cp_max_ed
   AND    pee.effective_end_date   >= cp_min_ed
   AND    exists (select ''
                    from pay_assignment_actions paa,
                         pay_payroll_actions ppa,
                         per_time_periods    ptp
                   where ppa.payroll_action_id = paa.payroll_action_id
                     and paa.assignment_id = pee.assignment_id
                     and paa.action_status not in ('E', 'M', 'U')
                     and ppa.action_type in ('R', 'Q', 'B', 'V')
                     and (ppa.date_earned    BETWEEN cp_min_ed AND cp_max_ed
                       OR ppa.effective_date BETWEEN cp_min_ed AND cp_max_ed)
                     and ppa.payroll_id = ptp.payroll_id
                     and ppa.date_earned between ptp.start_date
                                             and ptp.end_date
                     and pee.effective_start_date <= ptp.end_date
                     and pee.effective_end_date >= ptp.start_date
                  )
   ORDER BY 1, 2;
--
type t_element_entry_id is table of
     pay_element_entries_f.element_entry_id%type
       index by binary_integer;
type t_element_type_id is table of
     pay_element_entries_f.element_type_id%type
       index by binary_integer;
type t_datetracked_evt_id is table of
     pay_datetracked_events.datetracked_event_id%type
       index by binary_integer;
type t_retro_component_id is table of
     pay_retro_components.retro_component_id%type
       index by binary_integer;
type t_event_group_id is table of
     pay_event_groups.event_group_id%type
       index by binary_integer;
--
l_entry_id t_element_entry_id;
l_type_id  t_element_type_id;
l_ele_type_id  t_element_type_id; --temp store
l_datetracked_evt_id t_datetracked_evt_id;
l_retro_component_id t_retro_component_id;
l_ret_comp_id   t_retro_component_id; --temp store
l_event_group_id t_event_group_id;
l_min_run_eff_date date;
l_min_run_ear_date date;
l_min_run_pro_date date;
l_min_eff_date date;
l_min_grp_eff_date date;
l_max_ppa_de_date date;
l_max_ppa_eff_date date;
l_detailed_output pay_interpreter_pkg.t_detailed_output_table_type;
l_ret_asg_id number;
--
l_reprocess_date date;
l_cache_date     date;
l_cache_ef_date  date;
--
l_proc  varchar2(80) := g_package||'.process_assignment';
--
  Procedure add_retro_set_assignment(
          p_assignment_id IN NUMBER
  ,       p_asg_set_id    IN NUMBER) is
  --
    Cursor c_already_in_set is
      SELECT 'X'
      FROM   hr_assignment_set_amendments
      WHERE  assignment_id = p_assignment_id
      AND    assignment_set_id = p_asg_set_id
      AND    include_or_exclude = 'I';
  --
    l_rowid VARCHAR2(30);
    l_dummy VARCHAR2(1);
  --
  Begin
  --
    Open c_already_in_set;
    Fetch c_already_in_set into l_dummy;
      If c_already_in_set%NOTFOUND then
        hr_assignment_set_amds_pkg.insert_row(
                 p_rowid               => l_rowid
         ,       p_assignment_id       => p_assignment_id
         ,       p_assignment_set_id   => p_asg_set_id
         ,       p_include_or_exclude  => 'I');
      End if;
    Close c_already_in_set;
  --
  End add_retro_set_assignment;
--
  Procedure retro_table_insert(
          p_assignment_id    IN NUMBER
  ,       p_element_entry_id IN NUMBER
  ,       p_date_processed   IN DATE
  ,       p_date_earned      IN DATE
  ,       p_change_type      IN VARCHAR2
  ,       p_asg_set_id       IN NUMBER) is
  --
  Begin
  --
    INSERT INTO pay_retro_notif_reports
    (        report_id
    ,        payroll_id
    ,        report_date
    ,        assignment_id
    ,        element_entry_id
    ,        event_group_id
    ,        date_processed
    ,        date_earned
    ,        change_type
    ,        assignment_set_id
    ,        business_group_id
    )
    VALUES
    (        p_payroll_act_id
    ,        p_payroll_id
    ,        p_report_date
    ,        p_assignment_id
    ,        p_element_entry_id
    ,        p_event_group
    ,        p_date_processed
    ,        p_date_earned
    ,        p_change_type
    ,        p_asg_set_id
    ,        p_business_group_id
    );
  --
  End retro_table_insert;
--
BEGIN
--
  l_detailed_output.delete;
  l_ret_asg_id := null;
--
  /* Find the min effective date so that we know
     which entries to reprocess for
  */
  select /*+ INDEX(ppe PAY_PROCESS_EVENTS_N3) use_nl(ppe peu pdt)
             ORDERED */
         min(decode(peu.event_type,
                    'U', decode(peu.column_name,
                                pdt.end_date_name, ppe.effective_date +1,
                                ppe.effective_date
                               ),
                    ppe.effective_date)
            )
    into l_min_eff_date
    from pay_process_events ppe,
         pay_event_updates  peu,
         pay_dated_tables   pdt
   where ppe.assignment_id = p_assignment_id
     and ppe.creation_date between p_min_creation_date
                           and p_time_processing_started
     and peu.event_update_id = ppe.event_update_id
     and peu.dated_table_id = pdt.dated_table_id;
--
  select /*+ INDEX(ppe PAY_PROCESS_EVENTS_N3) use_nl(ppe peu pdt)
             ORDERED */
         min(decode(peu.event_type,
                    'U', decode(peu.column_name,
                                pdt.end_date_name, ppe.effective_date +1,
                                ppe.effective_date
                               ),
                    ppe.effective_date)
            )
    into l_min_grp_eff_date
    from pay_process_events ppe,
         pay_event_updates  peu,
         pay_dated_tables   pdt
   where ppe.assignment_id is null
     and ppe.creation_date between p_min_creation_date
                           and p_time_processing_started
     and peu.event_update_id = ppe.event_update_id
     and peu.dated_table_id = pdt.dated_table_id;
--
   select min(effective_date),
          min(date_earned)
     into l_min_run_eff_date,
          l_min_run_ear_date
     from pay_payroll_actions ppa,
          pay_assignment_actions paa
    where paa.assignment_id  = p_assignment_id
      and paa.payroll_action_id = ppa.payroll_action_id
      and ppa.action_type in ('Q', 'R', 'B', 'V');
--
   if (l_min_run_eff_date is null) then
      l_min_run_eff_date := hr_api.g_eot;
   end if;
   if (l_min_run_ear_date is null) then
      l_min_run_ear_date := hr_api.g_eot;
   end if;
   l_min_run_pro_date := least(l_min_run_eff_date, l_min_run_ear_date);
--
   if (l_min_eff_date is null) then
       if (l_min_grp_eff_date is not null) then
          l_min_eff_date := l_min_grp_eff_date;
       end if;
   else
      if (l_min_grp_eff_date is not null
          and l_min_grp_eff_date < l_min_eff_date) then
          l_min_eff_date := l_min_grp_eff_date;
      end if;
   end if;
--
   if (l_min_eff_date is not null) then
      if (l_min_eff_date < l_min_run_pro_date) then
         l_min_eff_date := l_min_run_pro_date;
      end if;
   end if;
--
   if (g_dbg) then
     hr_utility.set_location(l_proc,100);
     hr_utility.trace(' Processing ASG             '||p_assignment_id);
     hr_utility.trace(' p_min_creation_date:       '||to_char(p_min_creation_date,'YYYY/MM/DD HH24:MI:SS'));
     hr_utility.trace(' p_time_processing_started: '||to_char(p_time_processing_started,'YYYY/MM/DD HH24:MI:SS'));
     hr_utility.trace(' l_min_eff_date:            '||to_char(l_min_eff_date,'YYYY/MM/DD HH24:MI:SS'));
     hr_utility.trace(' l_min_grp_eff_date:        '||to_char(l_min_grp_eff_date,'YYYY/MM/DD HH24:MI:SS'));
   end if;

  /* only do something if there were process events */
--
  if (l_min_eff_date is not null) then
--
    /* Find the element entry and datetrack details needed
       to build the PL/SQL tables
       Note this sursor needs to used the effective dates
    */
    if (p_adv_flag = 'N') then
--
       open c_ele(p_assignment_id,
                  l_min_eff_date,
                  hr_api.g_eot,
                  p_event_group);
--
       fetch c_ele bulk collect into
                       l_entry_id,
                       l_datetracked_evt_id;
--
    else
--
     if (p_event_group is not null) then
       open c_ele_adv(p_assignment_id,
                  l_min_eff_date,
                  hr_api.g_eot,
                  p_event_group);
--
       fetch c_ele_adv bulk collect into
                       l_entry_id,
                       l_type_id,
                       l_datetracked_evt_id,
                       l_event_group_id;
--
     else
--
       open c_ele_adv_neg(p_assignment_id,
                  l_min_eff_date,
                  hr_api.g_eot,
                  p_event_group);
--
       fetch c_ele_adv_neg bulk collect into
                       l_entry_id,
                       l_type_id,
                       l_datetracked_evt_id,
                       l_event_group_id;
     end if;
--
     for i in 1..l_entry_id.count loop

        l_retro_component_id(i) :=
          pay_retro_utils_pkg.get_retro_component_id
                       (l_entry_id(i),
                        trunc(sysdate), l_type_id(i),
                        p_assignment_id);

     end loop;
--
    end if;
--
    for i in 1..l_entry_id.count loop
--
      if (p_adv_flag = 'N') then
--
        pay_interpreter_pkg.add_datetrack_event_to_entry
             (p_datetracked_evt_id => l_datetracked_evt_id(i),
              p_element_entry_id   => l_entry_id(i),
              p_global_env         => p_global_env);
--
      else
--
        if (l_retro_component_id(i) <> -1) then
--
           pay_interpreter_pkg.add_datetrack_event_to_entry
                (p_datetracked_evt_id => l_datetracked_evt_id(i),
                 p_element_entry_id   => l_entry_id(i),
                 p_global_env         => p_global_env);
--
           pay_interpreter_pkg.event_group_tables(l_event_group_id(i),
                                   pay_interpreter_pkg.glo_monitored_events);
           p_global_env.monitor_start_ptr    := 1;
           p_global_env.monitor_end_ptr      :=
                          pay_interpreter_pkg.glo_monitored_events.count;
--
          -- Also populate our table for local store of ele type id and rc_id
          l_ele_type_id(l_entry_id(i)) := l_type_id(i);
          l_ret_comp_id(l_entry_id(i)) := l_retro_component_id(i);
        else
          if (g_dbg) then
            hr_utility.trace('>> Element has no retro_component.  Not adding '||l_entry_id(i)||' to store.');
          end if;
        end if;
--
      end if;
--
    end loop;
--
    if (p_adv_flag = 'N') then
       close c_ele;
    else
     if (p_event_group is not null) then
       close c_ele_adv;
     else
       close c_ele_adv_neg;
     end if;
    end if;
--
     select max(ppa.date_earned),
            max(ppa.effective_date)
       into l_max_ppa_de_date,
            l_max_ppa_eff_date
       from pay_assignment_actions paa,
            pay_payroll_actions    ppa
     where paa.assignment_id = p_assignment_id
       and paa.action_status not in ('U', 'M', 'E')
       and ppa.payroll_action_id = paa.payroll_action_id
       and ppa.action_type in ('R', 'Q');
--
    /* Now we have the combination of entries and events loaded
       call the interpreter for Date Processed
    */
    pay_interpreter_pkg.entries_affected(
            p_assignment_id         => p_assignment_id,
            p_mode                  => 'DATE_PROCESSED',
            p_start_date            => p_min_creation_date,
            p_end_date              => p_time_processing_started,
            p_business_group_id     => p_business_group_id,
            p_global_env            => p_global_env,
            t_detailed_output       => l_detailed_output
           );
--
   for cnt in 1..l_detailed_output.count loop
       if (l_detailed_output(cnt).effective_date <= l_max_ppa_eff_date)
       then
--
         if (p_debug_flag = FALSE) then
--
          if (p_adv_flag = 'N') then
--
            retro_table_insert(
              p_assignment_id    => p_assignment_id,
              p_element_entry_id => l_detailed_output(cnt).element_entry_id,
              p_date_processed   => l_detailed_output(cnt).effective_date,
              p_date_earned      => NULL,
              p_change_type      => l_detailed_output(cnt).update_type,
              p_asg_set_id       => p_asg_set_id);
--
            add_retro_set_assignment(
                          p_assignment_id => p_assignment_id,
                          p_asg_set_id    => p_asg_set_id);
--
         else
--
          if (l_ret_asg_id is null) then
--
             PAY_RETRO_UTILS_PKG.maintain_retro_asg(
                       p_asg_id       => p_assignment_id
                      ,p_payroll_id   => p_payroll_id
                      ,p_min_date     => p_min_creation_date
                      ,p_eff_date     => l_detailed_output(cnt).effective_date
                      ,p_retro_asg_id => l_ret_asg_id);
--
          end if;
--
          pay_retro_pkg.maintain_retro_entry(
             p_retro_assignment_id    => l_ret_asg_id
            ,p_element_entry_id       => l_detailed_output(cnt).element_entry_id
            ,p_element_type_id        => l_ele_type_id(l_detailed_output(cnt).element_entry_id)
            ,p_reprocess_date         => l_detailed_output(cnt).effective_date
            ,p_eff_date               => l_detailed_output(cnt).effective_date
            ,p_retro_component_id     => l_ret_comp_id(l_detailed_output(cnt).element_entry_id)
            -- As this is System, need to record details to differentiate
            -- to a User row, as the RE may get Merged in the future
            ,p_owner_type             => 'S'
            ,p_system_reprocess_date  => l_detailed_output(cnt).effective_date );
--
            if (g_dbg) then
             hr_utility.trace('>DP >Entry Saved id = '||l_detailed_output(cnt).element_entry_id);
             hr_utility.trace('>DP >effective_date = '||l_detailed_output(cnt).effective_date);
             hr_utility.trace('>DP >update type    = '||l_detailed_output(cnt).update_type);
            end if;
        end if;
      else
        -- In debug mode
        hr_utility.trace('>DP >Entry Saved id = '||l_detailed_output(cnt).element_entry_id);
        hr_utility.trace('>DP >effective_date = '||l_detailed_output(cnt).effective_date);
        hr_utility.trace('>DP >update type    = '||l_detailed_output(cnt).update_type);
      end if;
--
       end if;

    end loop;
--
    /* Now we have the combination of entries and events loaded
       call the interpreter for Date Earned
    */
    l_detailed_output.delete;
    l_cache_date := NULL;
    l_cache_ef_date := NULL;
    l_reprocess_date := NULL;
    pay_interpreter_pkg.entries_affected(
            p_assignment_id         => p_assignment_id,
            p_mode                  => 'DATE_EARNED',
            p_start_date            => p_min_creation_date,
            p_end_date              => p_time_processing_started,
            p_business_group_id     => p_business_group_id,
            p_global_env            => p_global_env,
            t_detailed_output       => l_detailed_output
           );
--
   for cnt in 1..l_detailed_output.count loop
       if (l_detailed_output(cnt).effective_date <= l_max_ppa_de_date)
       then
--
         if (p_debug_flag = FALSE) then
--
          if (p_adv_flag = 'N') then
--
            retro_table_insert(
              p_assignment_id    => p_assignment_id,
              p_element_entry_id => l_detailed_output(cnt).element_entry_id,
              p_date_processed   => null,
              p_date_earned      => l_detailed_output(cnt).effective_date,
              p_change_type      => l_detailed_output(cnt).update_type,
              p_asg_set_id       => p_asg_set_id);
--
            add_retro_set_assignment(
                          p_assignment_id => p_assignment_id,
                          p_asg_set_id    => p_asg_set_id);
--
          else
--
            if (l_ret_asg_id is null) then
--
               PAY_RETRO_UTILS_PKG.maintain_retro_asg(
                        p_asg_id       => p_assignment_id
                       ,p_payroll_id   => p_payroll_id
                       ,p_min_date     => p_min_creation_date
                       ,p_eff_date     => l_detailed_output(cnt).effective_date
                       ,p_retro_asg_id => l_ret_asg_id);
--
            end if;
--
            if (l_detailed_output(cnt).effective_date <> l_cache_date
                or l_cache_date is null) then
--
                begin
--
                   select min(ppa.effective_date)
                     into l_reprocess_date
                     from pay_payroll_actions ppa,
                          pay_assignment_actions paa
                    where ppa.payroll_action_id = paa.payroll_action_id
                      and paa.assignment_id = p_assignment_id
                      and ppa.date_earned >=
                          l_detailed_output(cnt).effective_date
                      and ppa.action_type in ('R','Q');
--
                   if l_reprocess_date <= l_detailed_output(cnt).effective_date then
                      l_cache_date := l_detailed_output(cnt).effective_date;
                      l_cache_ef_date := l_reprocess_date;
                   else
                      l_cache_date := l_detailed_output(cnt).effective_date;
                      l_cache_ef_date := l_detailed_output(cnt).effective_date;
                   end if;
--
                exception
                   when no_data_found then
                      l_reprocess_date := l_detailed_output(cnt).effective_date;
                      l_cache_ef_date := l_reprocess_date;
                      l_cache_date := l_reprocess_date;
                end;
--
            else
                l_reprocess_date := l_cache_ef_date;
            end if;
--
            pay_retro_pkg.maintain_retro_entry(
               p_retro_assignment_id    => l_ret_asg_id
              ,p_element_entry_id       => l_detailed_output(cnt).element_entry_id
              ,p_element_type_id        => l_ele_type_id(l_detailed_output(cnt).element_entry_id)
              ,p_reprocess_date         => l_reprocess_date
              ,p_eff_date               => l_detailed_output(cnt).effective_date
              ,p_retro_component_id     => l_ret_comp_id(l_detailed_output(cnt).element_entry_id)
              ,p_owner_type             => 'S'
              ,p_system_reprocess_date  => l_reprocess_date);
--
             if (g_dbg) then
             hr_utility.trace('>DE >Entry Saved id = '||l_detailed_output(cnt).element_entry_id);
             hr_utility.trace('>DE >effective_date = '||l_detailed_output(cnt).effective_date);
             hr_utility.trace('>DE >update type    = '||l_detailed_output(cnt).update_type);
             hr_utility.trace('>DE >Reprocess Date = '||l_reprocess_date);
             end if;
            end if;
--
          else
            hr_utility.trace('>DE >Entry Saved id = '||l_detailed_output(cnt).element_entry_id);
            hr_utility.trace('>DE >effective_date = '||l_detailed_output(cnt).effective_date);
            hr_utility.trace('>DE >update type    = '||l_detailed_output(cnt).update_type);
--
          end if;
--
       end if;
--
    end loop;
--
     -- We have inserted all retro-entries, and stored the earliest
     -- effective_date for this assignment.  Now update the retro_assignment
     -- with this date
--
    if (l_ret_asg_id is not null) then
--
       update pay_retro_assignments
       set reprocess_date = (select min(reprocess_date)
                               from pay_retro_entries
                              where retro_assignment_id = l_ret_asg_id),
               start_date = p_min_creation_date
       where retro_assignment_id = l_ret_asg_id;
--
    end if;
--
  end if;
--
  /* now clear the caches */
--
   pay_interpreter_pkg.clear_dt_event_for_entry
              (p_global_env         => p_global_env);
   l_ele_type_id.delete;
   l_ret_comp_id.delete;
--
--
   if (g_traces) then
     hr_utility.set_location(l_proc,900);
   end if;
end process_assignment;

procedure initialise_globals(p_event_group       in number,
                             p_business_group_id in number,
                             p_payroll_action_id in number,
                             p_payroll_id        in number,
                             p_asg_set_name      in varchar2,
                             p_adv_flag          in varchar2,
                             p_report_date       in date
                            )
is
begin

  /* Setup the global area */
  pay_interpreter_pkg.initialise_global(g_global_env);
  pay_interpreter_pkg.event_group_tables(p_event_group,
                                         pay_interpreter_pkg.glo_monitored_events);
  g_global_env.monitor_start_ptr    := 1;
  g_global_env.monitor_end_ptr      := pay_interpreter_pkg.glo_monitored_events.count;
  g_global_env.datetrack_ee_tab_use := TRUE;
  g_global_env.validate_run_actions := TRUE;
--
  g_event_group       := p_event_group;
  g_business_group_id := p_business_group_id;
  g_payroll_act_id    := p_payroll_action_id;
  g_payroll_id        := p_payroll_id;
  g_adv_flag          := p_adv_flag;
--
  if (g_adv_flag = 'Y') then
--
    -- Advanced report performs until the end of time.
--
    g_report_date := to_date('4712/12/31', 'YYYY/MM/DD');
    g_asg_set_id  := null;
  else
    get_asg_set_id (p_asg_set_name,
                    g_payroll_id,
                    g_asg_set_id);
    g_report_date := p_report_date;
  end if;

end initialise_globals;
--
 /* Name      : archinit
    Purpose   : Initialise the process thread.
    Arguments :
    Notes     :
 */
procedure archinit(p_payroll_action_id in number)
is
l_bus_grp number;
l_evt_grp number;
l_payroll number;
l_asg_set_name hr_assignment_sets.assignment_set_name%type;
l_adv_flag  varchar2(1);
l_report_date date;

begin
--

hr_utility.trace('In archinit');

   get_pact_details (p_payroll_action_id,
                     l_asg_set_name,
                     l_bus_grp,
                     l_payroll,
                     l_evt_grp,
                     l_adv_flag,
                     l_report_date);
--
   initialise_globals(p_event_group       => l_evt_grp,
                      p_business_group_id => l_bus_grp,
                      p_payroll_action_id => p_payroll_action_id,
                      p_payroll_id        => l_payroll,
                      p_asg_set_name      => l_asg_set_name,
                      p_adv_flag          => l_adv_flag,
                      p_report_date       => l_report_date
                     );
--
end archinit;
--
procedure generate_dates_and_process(p_assignment_id in number)
is
l_time_processing_started date;
l_start_date date;
l_min_creation_date date;
l_old_retronot_date date;
begin
--
    -- Need to find out the dates for which the RetroNotification
    -- should run.
--
    l_time_processing_started := sysdate;
--
    begin
--
      select start_date
        into l_start_date
        from pay_retro_assignments
       where assignment_id = p_assignment_id
         and retro_assignment_action_id is null
         and superseding_retro_asg_id is null;
--
    exception
        when no_data_found then
           l_start_date := hr_api.g_eot;
    end;
--
    pay_recorded_requests_pkg.get_recorded_date(
       p_process        => 'RETRONOT_ASG',
       p_recorded_date  => l_min_creation_date,
       p_attribute1     => p_assignment_id);

    if (l_min_creation_date is not null) then
--
        /* If this process has never run before for this
           assignment then we need to find the earliest
           date to run from.
        */
        if (l_min_creation_date = hr_api.g_sot) then
           select min(creation_date)
             into l_min_creation_date
             from pay_process_events
            where assignment_id = p_assignment_id
              and nvl(retroactive_status, 'P') <> 'C';
        end if;
--
        if (l_start_date < l_min_creation_date) then
            l_min_creation_date := l_start_date;
        end if;
--
        process_assignment (p_assignment_id           => p_assignment_id,
                            p_report_date             => g_report_date,
                            p_event_group             => g_event_group,
                            p_business_group_id       => g_business_group_id,
                            p_payroll_act_id          => g_payroll_act_id,
                            p_payroll_id              => g_payroll_id,
                            p_asg_set_id              => g_asg_set_id,
                            p_min_creation_date       => l_min_creation_date,
                            p_time_processing_started => l_time_processing_started,
                            p_global_env              => g_global_env,
                            p_debug_flag              => FALSE,
                            p_adv_flag                => g_adv_flag
                           );
    end if;
--
    pay_recorded_requests_pkg.set_recorded_date(
       p_process          => 'RETRONOT_ASG',
       p_recorded_date    => l_time_processing_started,
       p_recorded_date_o  => l_old_retronot_date,
       p_attribute1       => to_char(p_assignment_id));
--
end generate_dates_and_process;
--
procedure process_action(p_assactid in number, p_effective_date in date)
is
--
  l_asg_id pay_assignment_actions.assignment_id%type;
--
begin
--
hr_utility.trace('In process_action');

   select assignment_id
     into l_asg_id
     from pay_assignment_actions
    where assignment_action_id = p_assactid;
--
   generate_dates_and_process(l_asg_id);
--
end process_action;
--
-- populate_adv_retro_tables is called from the RetroNotification Report ENh
-- and is executed at Payroll level
-- This run_asg_adv_retronot is called at an individual assignment level
-- from the Automated RetroPay Solution
procedure run_asg_adv_retronot(
                    p_assignment_id      in number,
                    p_business_group_id  in number,
                    p_time_started       in date   default sysdate,
                    p_event_group        in number default null)

IS

  l_proc varchar2(80) := g_package||'run_asg_adv_retronot';
  l_old_retronot_date    date; -- debug store
  l_start_date           date; -- existing RA date
  l_min_creation_date    date; -- date stored for last execution
  l_global_env pay_interpreter_pkg.t_global_env_rec;

BEGIN
   hr_utility.set_location(l_proc,10);
--
   initialise_globals(p_event_group       => p_event_group,
                      p_business_group_id => p_business_group_id,
                      p_payroll_action_id => null,
                      p_payroll_id        => null,
                      p_asg_set_name      => null,
                      p_adv_flag          => 'Y',
                      p_report_date       => p_time_started
                     );
--
   hr_utility.set_location(l_proc,15);
--
  generate_dates_and_process(p_assignment_id);
--
  hr_utility.set_location(l_proc,20);
--
END run_asg_adv_retronot;



procedure run_debug(p_event_group in number,
                    p_start_date  in date,
                    p_end_date    in date,
                    p_bg_id       in number,
                    p_assignment_id in number,
                    p_rownum      in number,
                    p_adv_flag    in varchar2)
is
--
  Cursor c_asg (p_bg_id       in number,
                p_asg_id      in number,
                p_start_date  in date,
                p_end_date    in date,
                p_rownum      in number)
   is
   SELECT distinct assignment_id             asg
   FROM   pay_process_events            ppe
   WHERE  business_group_id = p_bg_id
   and    assignment_id = nvl(p_asg_id, assignment_id)
   and    creation_date between p_start_date
                            and p_end_date
   and    assignment_id is not null
   and    rownum < p_rownum;
--
l_global_env pay_interpreter_pkg.t_global_env_rec;
--
begin
  /* Setup the global area */
  pay_interpreter_pkg.initialise_global(l_global_env);
  pay_interpreter_pkg.event_group_tables(p_event_group,
                                         pay_interpreter_pkg.glo_monitored_events);
  l_global_env.monitor_start_ptr    := 1;
  l_global_env.monitor_end_ptr      := pay_interpreter_pkg.glo_monitored_events.count;
  l_global_env.datetrack_ee_tab_use := TRUE;
  l_global_env.validate_run_actions := TRUE;
--
  -- If assignment ID is null there is a group level event recorded
  -- this has been incorporated in to c_asg
  For l_asg_rec in c_asg(p_bg_id, p_assignment_id,
                         p_start_date, p_end_date, p_rownum) loop
--
      process_assignment (p_assignment_id           => l_asg_rec.asg,
                          p_report_date             => p_end_date,
                          p_event_group             => p_event_group,
                          p_business_group_id       => p_bg_id,
                          p_payroll_act_id          => null,
                          p_payroll_id              => null,
                          p_asg_set_id              => null,
                          p_min_creation_date       => p_start_date,
                          p_time_processing_started => p_end_date,
                          p_global_env              => l_global_env,
                          p_debug_flag              => TRUE,
                          p_adv_flag                => p_adv_flag
                         );
--
  end loop;
end run_debug;

--
----------------------------------- range_cursor ----------------------------------
--
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is
--
  l_payroll_id     number;
  l_legparam       pay_payroll_actions.legislative_parameters%type;
  l_asg_set_name   pay_payroll_actions.legislative_parameters%type;
  l_bus_grp        number;
  l_adv_flag  varchar2(1);
--
begin
      hr_utility.trace('In range_cursor');
      /* Effective date will be set to sysdate for CC*/
      sqlstr := 'select  distinct asg.person_id
                from
                        per_assignments_f      asg,
                        pay_payroll_actions    pa1
                 where  pa1.payroll_action_id    = :payroll_action_id
                 and    asg.payroll_id =
                          pay_core_utils.get_parameter(''PAYROLL_ID'',
                                 pa1.legislative_parameters)
                 and    pa1.effective_date between asg.effective_start_date
                                               and asg.effective_end_date
                order by asg.person_id';
--
      select legislative_parameters,
             business_group_id
        into l_legparam,
             l_bus_grp
        from pay_payroll_actions
       where payroll_action_id = pactid;
--
      l_payroll_id := pay_core_utils.get_parameter('PAYROLL_ID', l_legparam);
      l_asg_set_name := pay_core_utils.get_parameter('ASG_SET', l_legparam)||'_'||pactid;
      l_adv_flag  := pay_core_utils.get_parameter('ADV_FLAG', l_legparam);
--
      -- if old style then create an assignment set
      if (l_adv_flag is null) then
        l_adv_flag := 'N';
--
        create_retro_asg_set(l_asg_set_name,
                           l_bus_grp,
                           l_payroll_id);
--
      end if;

      hr_utility.trace('l_asg_set_name = '||l_asg_set_name);
      commit;
      hr_utility.trace('Out range_cursor');
--
end range_cursor;
--
 -------------------------- action_creation ---------------------------------
 PROCEDURE action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is
  CURSOR c_actions
      (
         pactid    number,
         stperson  number,
         endperson number
      ) is
      select /*+ ordered
                 INDEX(paf PER_ASSIGNMENTS_N12)
                 USE_NL(pos paf) */
             paf.assignment_id
      from
             per_periods_of_service         pos,
             per_assignments_f              paf,
             pay_payroll_actions            ppa
      where  ppa.payroll_action_id          = pactid
      and    paf.payroll_id     =
                          pay_core_utils.get_parameter('PAYROLL_ID',
                                                        ppa.legislative_parameters)
      and    pos.period_of_service_id       = paf.period_of_service_id
      and    pos.person_id                  = paf.person_id
      and    pos.person_id between stperson and endperson
      and    ppa.effective_date between paf.effective_start_date
                                   and paf.effective_end_date
      order by paf.assignment_id
      for update of paf.assignment_id, pos.period_of_service_id;
  --
  CURSOR c_get_report_type (pactid number) IS

      SELECT report_type
      FROM pay_payroll_actions
      WHERE payroll_action_id = pactid;
  --
  CURSOR c_actions_range_on
      (
         pactid    number,
         chunk     number
      ) is
      select /*+ ordered
                 INDEX(paf PER_ASSIGNMENTS_N12)
		 USE_NL(pos paf) */
             paf.assignment_id
      FROM   pay_population_ranges ppr,
             per_periods_of_service         pos,
             per_assignments_f              paf,
             pay_payroll_actions            ppa
      where  ppa.payroll_action_id          = pactid
      and    paf.payroll_id  =  pay_core_utils.get_parameter('PAYROLL_ID', ppa.legislative_parameters)
      and    pos.period_of_service_id       = paf.period_of_service_id
      and    pos.person_id                  = paf.person_id
      AND    ppa.payroll_action_id          = ppr.payroll_action_id
      AND    ppr.chunk_number               = chunk
      and    pos.person_id                  = ppr.person_id
      and    ppa.effective_date between paf.effective_start_date
                                   and paf.effective_end_date
      order by paf.assignment_id
      for update of paf.assignment_id, pos.period_of_service_id;
--
lockingactid      NUMBER;
l_report_type     pay_payroll_actions.report_type%type;
l_range_person    BOOLEAN;   -- 7508169 Variable used to check if RANGE_PERSON_ID is enabled

--
 BEGIN
--
OPEN c_get_report_type(pactid);
FETCH c_get_report_type INTO l_report_type;
CLOSE c_get_report_type;

IF(g_traces) THEN
hr_utility.trace('In action_creation');
hr_utility.trace('l_report_type : '|| l_report_type);
END if;

l_range_person := pay_ac_utility.range_person_on(
                           p_report_type      => l_report_type
                          ,p_report_format    => 'DEFAULT'
                          ,p_report_qualifier => 'DEFAULT'
                          ,p_report_category  => 'REPORT');

 if l_range_person THEN  -- 7508169. Use the new cursor c_actions_range_on cursor to fetch the assignment_ids

   IF(g_traces) then
    hr_utility.trace('l_range_person is true');
   END if;

   for asgrec in c_actions_range_on(pactid, chunk) loop
--
       SELECT pay_assignment_actions_s.nextval
         INTO lockingactid
         FROM dual;
--
       -- insert the action record.
       hr_nonrun_asact.insact(lockingactid,asgrec.assignment_id,pactid,chunk, null);
--
    end loop;

 ELSE   --  Retain Old Logic- No Range Person

   IF(g_traces) then
    hr_utility.trace('l_range_person is false');
   END if;

    for asgrec in c_actions(pactid, stperson, endperson) loop
--
       SELECT pay_assignment_actions_s.nextval
         INTO lockingactid
         FROM dual;
--
       -- insert the action record.
       hr_nonrun_asact.insact(lockingactid,asgrec.assignment_id,pactid,chunk, null);
--
    end loop;

 END IF;
--
 END action_creation;
--
procedure check_retro_asg_set(p_asg_set_id IN NUMBER) is
--
  cursor c_check_retro_set is
   SELECT 'X'
   FROM   hr_assignment_set_amendments
   WHERE  assignment_set_id = p_asg_set_id;
  --
  l_dummy  VARCHAR2(1);
--
begin
--
  open c_check_retro_set;
  fetch c_check_retro_set into l_dummy;
    if c_check_retro_set%NOTFOUND then
      DELETE FROM hr_assignment_sets
      WHERE assignment_set_id = p_asg_set_id;
    end if;
  close c_check_retro_set;
--
End check_retro_asg_set;
--
procedure deinitialise (pactid in number)
is

l_bus_grp number;
l_evt_grp number;
l_payroll number;
l_asg_set_name hr_assignment_sets.assignment_set_name%type;
l_asg_set_id number;
l_adv_flag  varchar2(1);
l_report_date date;
remove_act    varchar2(10);
l_generate_report varchar2(10);

l_proc  varchar2(160) := g_package||'deinitialise';

begin
  hr_utility.set_location(l_proc,10);
--
   get_pact_details (pactid,
                     l_asg_set_name,
                     l_bus_grp,
                     l_payroll,
                     l_evt_grp,
                     l_adv_flag,
                     l_report_date);
--
--
  if (l_adv_flag = 'Y') then
--
      null;
--
  else
  --If its original format then just tidy up the assignment set
   get_asg_set_id (l_asg_set_name,
                   l_payroll,
                   l_asg_set_id);
--
   check_retro_asg_set(l_asg_set_id);

  end if;
--
  -- Now we need to generate the report and delete the
  -- output if required
--
  select pay_core_utils.get_parameter('REMOVE_ACT',
                                      pa1.legislative_parameters),
         pay_core_utils.get_parameter('GEN_REPORT',
                                      pa1.legislative_parameters)
    into remove_act,
         l_generate_report
    from pay_payroll_actions    pa1
   where pa1.payroll_action_id    = pactid;
--
--
  if (l_generate_report is null or l_generate_report = 'Y') then
--
    -- Need to submit the report here and wait for it
    -- to complete
--
    run_report(pactid,l_adv_flag);
--
  end if;
--
  if (remove_act is null or remove_act = 'Y') then
--
     pay_archive.remove_report_actions(pactid);
--
     -- Not allowing the delete of this table as this has not been
     -- deleted before.
     --
     -- delete from pay_retro_notif_reports
     -- where report_id = pactid;
--
  end if;
--
  hr_utility.set_location(l_proc,900);
--
end deinitialise;
--
-------------------------------------------------------------------------------
Function get_person_name(
        p_assignment_id     IN            NUMBER
,       p_report_date       IN            DATE
,       p_business_group_id IN            NUMBER
,       p_legislation_code  IN            VARCHAR2)
Return varchar2 is
l_asg_status  VARCHAR2(80)  := NULL;
l_person_name VARCHAR2(240) := NULL;
Begin
get_asg_info(
        p_assignment_id
,       p_report_date
,       p_business_group_id
,       p_legislation_code
,       l_asg_status
,       l_person_name );
Return (l_person_name);
End get_person_name;
-------------------------------------------------------------------------------
Function get_asg_status(
        p_assignment_id     IN            NUMBER
,       p_report_date       IN            DATE
,       p_business_group_id IN            NUMBER
,       p_legislation_code  IN            VARCHAR2)

Return varchar2 is
	l_asg_status  VARCHAR2(80)  := NULL;
	l_person_name VARCHAR2(240) := NULL;
Begin
	get_asg_info(
        p_assignment_id
	,       p_report_date
	,       p_business_group_id
	,       p_legislation_code
	,       l_asg_status
	,       l_person_name );
Return l_asg_status;
End get_asg_status;
-------------------------------------------------------------------------------

--
End PAY_RETRO_NOTIF_PKG;

/
