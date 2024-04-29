--------------------------------------------------------
--  DDL for Package Body PAY_GB_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_REP" AS
/* $Header: paygbrep.pkb 120.2.12000000.3 2007/02/07 22:22:27 rmakhija noship $ */

g_package                CONSTANT VARCHAR2(30) := 'PAY_GB_REP';

PROCEDURE ni_arrears_report(
                       errbuf                   out NOCOPY varchar2
                      ,retcode                  out NOCOPY varchar2
                      ,p_business_group_id      in  varchar2
                      ,p_effective_date         in  varchar2
                      ,p_payroll_id             in  varchar2
                      ,p_def_bal_id             in  varchar2) IS

    cursor header_details is
    select distinct
           pbg.name,
           fnd_date.canonical_to_date(p_effective_date),
           decode(p_payroll_id,null, '  ',papf.payroll_id, papf.payroll_name)
      from per_business_groups pbg,
           pay_all_payrolls_f papf
     where pbg.business_group_id = p_business_group_id
       and pbg.business_group_id = papf.business_group_id
       and papf.payroll_id = nvl(to_number(p_payroll_id),papf.payroll_id)
       and fnd_date.canonical_to_date(p_effective_date) between
           papf.effective_start_date and papf.effective_end_date;

    cursor body_details is
    select /*+ ORDERED
               use_index(ppf, PER_PEOPLE_F_FK1)
               use_index(ppt, PER_PERSON_TYPES_N1) */
           paf.assignment_number,
           ppf.full_name,
           paf.assignment_id
    --     hr_gbbal.calc_all_balances(fnd_date.canonical_to_date(p_effective_date), paf.assignment_id, p_def_bal_id ) ni_arrears
    from   per_all_people_f           ppf,
           per_person_types           ppt,
           per_all_assignments_f      paf,
           pay_all_payrolls_f         papf
    where  ppf.business_group_id   = p_business_group_id
    and    papf.business_group_id  = p_business_group_id
    and    ppt.business_group_id   = p_business_group_id
    --and    papf.payroll_id = nvl(p_payroll_id,papf.payroll_id)
    and    (p_payroll_id is null
             or
            papf.payroll_id = p_payroll_id)
    and    papf.payroll_id  = paf.payroll_id
    and    ppt.system_person_type = 'EMP'
    and    fnd_date.canonical_to_date(p_effective_date) between ppf.effective_start_date and ppf.effective_end_date
    and    fnd_date.canonical_to_date(p_effective_date) between papf.effective_start_date and papf.effective_end_date
    and    ppf.effective_end_date between paf.effective_start_date and paf.effective_end_date
    and    ppt.person_type_id = ppf.person_type_id
    and    paf.person_id      = ppf.person_id
    -- and    hr_gbbal.calc_all_balances(fnd_date.canonical_to_date(p_effective_date), paf.assignment_id, p_def_bal_id) > 0
    order by assignment_number;

    l_total_arrears  number;
    l_ni_arrears     number;
    l_date              varchar2(20);
    l_bg_name           varchar2(50);
    l_payroll_name      varchar2(50);

BEGIN
      OPEN header_details;
      FETCH header_details into l_bg_name, l_date, l_payroll_name;
      CLOSE header_details;

      fnd_file.put_line(fnd_file.output,lpad('NI Arrears Report',42));
      fnd_file.put_line(fnd_file.output,' ');
      fnd_file.put_line(fnd_file.output,'Business Group : ' || l_bg_name);
      fnd_file.put_line(fnd_file.output,'Effective Date : ' || l_date);
      fnd_file.put_line(fnd_file.output,'Payroll : ' || l_payroll_name);
      fnd_file.put_line(fnd_file.output,' ');

      fnd_file.put_line(fnd_file.output,rpad('Assignment',15,' ') || ' ' || rpad('Full Name',35,' ') || ' ' || rpad('NI Arrears YTD',15,' '));
      fnd_file.put_line(fnd_file.output,rpad('-',15,'-') || ' ' || rpad('-',35,'-') || ' ' || rpad('-',15,'-'));
      l_total_arrears := 0;

      for l_body in body_details loop
          l_ni_arrears := nvl(hr_gbbal.calc_all_balances(fnd_date.canonical_to_date(p_effective_date),
                                                         l_body.assignment_id,
                                                         p_def_bal_id),0);
          if (l_ni_arrears > 0) then
             fnd_file.put_line(fnd_file.output,rpad(l_body.assignment_number,15,' ') || ' ' || rpad(l_body.full_name,35,' ') ||
                                            ' ' || lpad(to_char(l_ni_arrears,'999,999,999.90'),15,' '));
             l_total_arrears := l_total_arrears + l_ni_arrears;
          end if;
      end loop;

      fnd_file.put_line(fnd_file.output,lpad(lpad('-',15,'-'),67,' '));
      fnd_file.put_line(fnd_file.output,'Report Total' || lpad(to_char(l_total_arrears,'999,999,999.90'),55,' '));

END ni_arrears_report;

PROCEDURE p45_issued_active_asg_report(
                       errbuf                   out NOCOPY varchar2
                      ,retcode                  out NOCOPY varchar2
                      ,p_business_group_id      in  varchar2
                      ,p_effective_date         in  varchar2
                      ,p_payroll_id             in  varchar2) IS

    cursor csr_header_details(c_business_group_id NUMBER,
                              c_payroll_id        NUMBER,
                              c_effective_date    VARCHAR2) is
    select pbg.name,
           fnd_date.canonical_to_date(c_effective_date),
           decode(c_payroll_id,null, '  ',papf.payroll_id, papf.payroll_name)
      from per_business_groups pbg,
           pay_all_payrolls_f papf
     where pbg.business_group_id = c_business_group_id
       and pbg.business_group_id = papf.business_group_id
       and papf.payroll_id = nvl(to_number(c_payroll_id),papf.payroll_id)
       and fnd_date.canonical_to_date(c_effective_date) between
           papf.effective_start_date and papf.effective_end_date;

    cursor csr_payroll_details(c_business_group_id NUMBER,
                               c_payroll_id        NUMBER,
                               c_effective_date    DATE) is
    select distinct
           papf.payroll_id,
           papf.payroll_name
      from per_business_groups pbg,
           pay_all_payrolls_f papf
     where pbg.business_group_id = c_business_group_id
       and pbg.business_group_id = papf.business_group_id
       and papf.payroll_id = nvl(to_number(c_payroll_id),papf.payroll_id)
       and c_effective_date between
           papf.effective_start_date and papf.effective_end_date
     order by papf.payroll_name;

    cursor csr_body_details(c_business_group_id NUMBER,
                            c_payroll_id        NUMBER,
                            c_effective_date    DATE) is
    select paf.assignment_number,
           ppf.full_name,
           paf.assignment_id
    from   per_all_people_f            ppf,
           per_all_assignments_f       paf,
           per_assignment_status_types past
    where  paf.assignment_status_type_id = past.assignment_status_type_id
    and    past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
    and    ppf.business_group_id  = c_business_group_id
    and    paf.payroll_id         = c_payroll_id
    and    c_effective_date between ppf.effective_start_date and ppf.effective_end_date
    and    c_effective_date between paf.effective_start_date and paf.effective_end_date
    and    paf.person_id      = ppf.person_id
    order by lpad(substr(assignment_number,1,decode(instr(assignment_number,'-'),0,25,instr(assignment_number,'-')-1)),25,'0') ||
    lpad(nvl(substr(assignment_number,decode(instr(assignment_number,'-'),0,null,instr(assignment_number,'-')+1)),'0'),10,'0');

    cursor csr_asg_dtls(c_assignment_id  number) is
      select assignment_number
      from   per_all_assignments_f
      where  assignment_id = c_assignment_id;

    cursor csr_locked_act_dtls(c_asg_action_id NUMBER) IS
      select locking_action_id, pact.effective_date
      from   pay_action_interlocks, pay_assignment_actions act, pay_payroll_actions pact
      where  locked_action_id      = c_asg_action_id
      and    locking_action_id     = act.assignment_action_id
      and    act.payroll_action_id = pact.payroll_action_id;

    l_date              varchar2(20);
    l_effective_date    date;
    l_bg_name           varchar2(50);
    l_payroll_name      varchar2(50);
    l_issue_date        date;

    l_assignment_action_id   number;
    l_agg_assignment_id      number;
    l_agg_assignment_number  per_all_assignments_f.assignment_number%type;
    l_final_payment_date     date;
    l_p45_issue_date         date;
    l_p45_agg_asg_action_id  number;
    l_action_sequence        number;

    l_locking_action_id      number;
    l_lock_effective_date    date;
    l_count                  number;
    l_total_count            number;
BEGIN
    --
    -- conveting the paramter value to date, effective date
    --
    l_effective_date := fnd_date.canonical_to_date(p_effective_date);

    OPEN csr_header_details(p_business_group_id, p_payroll_id, p_effective_date);
    FETCH csr_header_details into l_bg_name, l_date, l_payroll_name;
    CLOSE csr_header_details;

    fnd_file.put_line(fnd_file.output,lpad('P45 Issued for Active Assignments Report',80) || lpad(' ', 37, ' ') || sysdate);
    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output,'Business Group : ' || l_bg_name);
    fnd_file.put_line(fnd_file.output,'Effective Date : ' || l_date);
    fnd_file.put_line(fnd_file.output,'Payroll        : ' || l_payroll_name);
    fnd_file.put_line(fnd_file.output,' ');

    fnd_file.put_line(fnd_file.output,'P45 Manually Issued for Assignments active or suspended as at '|| l_effective_date || ' :');
    fnd_file.put_line(fnd_file.output,' ');

    l_total_count := 0;
    for p_rec in csr_payroll_details(p_business_group_id, p_payroll_id, l_effective_date) loop
        l_count := 0;
        for b_rec in csr_body_details(p_business_group_id, p_rec.payroll_id, l_effective_date) loop
           l_issue_date := pay_p45_pkg.get_p45_eit_manual_issue_dt(b_rec.assignment_id);
           if l_issue_date is not null then
             l_total_count := l_total_count + 1;
             if l_count = 0 then
               fnd_file.put_line(fnd_file.output,' ');
               fnd_file.put_line(fnd_file.output,'Payroll Name : ' || p_rec.payroll_name);
               fnd_file.put_line(fnd_file.output,' ');

               fnd_file.put_line(fnd_file.output,rpad('Assignment',15,' ') || ' ' || rpad('Full Name',35,' ') || ' ' || rpad('Manual Issue Date',20,' '));
               fnd_file.put_line(fnd_file.output,rpad('-',15,'-') || ' ' || rpad('-',35,'-') || ' ' || rpad('-',20,'-'));
               l_count := 1;
             end if;
             fnd_file.put_line(fnd_file.output,rpad(b_rec.assignment_number,15,' ') || ' ' ||
                                               rpad(b_rec.full_name,35,' ') ||' ' ||
                                               rpad(l_issue_date,20,' '));
           end if;
        end loop;
    end loop;

    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output,'Total Number of active or suspended assignments issued P45 manually: ' || l_total_count);


    --
    -- P45 Issued Assignments and P45 issued for
    -- Aggregated Assignments
    --
    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output,'P45 Issued for Assignments/Aggregated Assignments active or suspended as at ' || l_effective_date || ' :');
    fnd_file.put_line(fnd_file.output,' ');
    l_total_count := 0;
    for p_rec in csr_payroll_details(p_business_group_id, p_payroll_id, l_effective_date) loop
        l_count := 0;
        for b_rec in csr_body_details(p_business_group_id, p_rec.payroll_id, l_effective_date) loop
           pay_p45_pkg.get_p45_asg_action_id(p_assignment_id        => b_rec.assignment_id,
                                             p_assignment_action_id => l_assignment_action_id,
                                             p_issue_date           => l_issue_date,
                                             p_action_sequence      => l_action_sequence);

           if l_assignment_action_id is not null then
              l_total_count := l_total_count + 1;
              if l_count = 0 then
                fnd_file.put_line(fnd_file.output,' ');
                fnd_file.put_line(fnd_file.output,'Payroll Name : ' || p_rec.payroll_name);
                fnd_file.put_line(fnd_file.output,' ');
                fnd_file.put_line(fnd_file.output,rpad('Assignment',15,' ') || ' ' ||
                                                  rpad('Full Name',35,' ') || ' ' ||
                                                  rpad('Agg Assignment',15,' ') || ' ' ||
                                                  rpad('Issue Date',10,' ')  || ' ' ||
                                                  lpad('Asg Action ID', 15,' ') || ' ' ||
                                                  lpad('Locking Action ID',17,' ') || ' ' ||
                                                  rpad('Action Eff.Date',15,' '));
                fnd_file.put_line(fnd_file.output,rpad('-',15,'-') || ' ' ||
                                                  rpad('-',35,'-') || ' ' ||
                                                  rpad('-',15,'-') || ' ' ||
                                                  rpad('-',10,'-') || ' ' ||
                                                  lpad('-',15,'-') || ' ' ||
                                                  lpad('-',17,'-') || ' ' ||
                                                  rpad('-',15,'-'));
                l_count := 1;
              end if;

              --
              -- check for any payroll action, locked the P45 asg action. if found then show the
              -- locking acions id and effective date of that payroll action
              --
              open csr_locked_act_dtls(l_assignment_action_id);
              fetch csr_locked_act_dtls into l_locking_action_id, l_lock_effective_date;
              if csr_locked_act_dtls%notfound then
                fnd_file.put_line(fnd_file.output,rpad(b_rec.assignment_number,15,' ') || ' ' ||
                                                  rpad(b_rec.full_name,35,' ') || ' ' ||
                                                  rpad(' ',15,' ') || ' ' ||
                                                  rpad(l_issue_date,10,' ') || ' ' ||
                                                  lpad(l_assignment_action_id, 15,' ') || ' '||
                                                  lpad(' ',17,' ') || ' ' ||
                                                  rpad(' ',15,' '));
              else
                fnd_file.put_line(fnd_file.output,rpad(b_rec.assignment_number,15,' ') || ' ' ||
                                                  rpad(b_rec.full_name,35,' ') || ' ' ||
                                                  rpad(' ',15,' ') || ' ' ||
                                                  rpad(l_issue_date,10,' ') || ' ' ||
                                                  lpad(l_assignment_action_id, 15,' ') || ' '||
                                                  lpad(l_locking_action_id,17,' ') || ' ' ||
                                                  rpad(l_lock_effective_date,15,' '));
                loop
                   fetch csr_locked_act_dtls into l_locking_action_id, l_lock_effective_date;
                   if csr_locked_act_dtls%notfound then
                      exit;
                   end if;
                   fnd_file.put_line(fnd_file.output,rpad(' ',15,' ') || ' ' ||
                                                     rpad(' ',35,' ') || ' ' ||
                                                     rpad(' ',15,' ') || ' ' ||
                                                     rpad(' ',10,' ') || ' ' ||
                                                     lpad(' ',15,' ') || ' ' ||
                                                     lpad(l_locking_action_id,17,' ') || ' ' ||
                                                     rpad(l_lock_effective_date,15,' '));
                end loop;
              end if;
              close csr_locked_act_dtls;

           end if;

           --
           -- check for the P45 issued for any of the aggregated assignment associated with this assignment
           --
           pay_p45_pkg.get_p45_agg_asg_action_id(p_assignment_id         => b_rec.assignment_id,
                                                 p_agg_assignment_id     => l_agg_assignment_id,
                                                 p_final_payment_date    => l_final_payment_date,
                                                 p_p45_issue_date        => l_p45_issue_date,
                                                 p_p45_agg_asg_action_id => l_p45_agg_asg_action_id);
           if l_agg_assignment_id is not null then
              l_total_count := l_total_count + 1;
              if l_count = 0 then
                fnd_file.put_line(fnd_file.output,' ');
                fnd_file.put_line(fnd_file.output,'Payroll Name : ' || p_rec.payroll_name);
                fnd_file.put_line(fnd_file.output,' ');
                fnd_file.put_line(fnd_file.output,rpad('Assignment',15,' ') || ' ' ||
                                                  rpad('Full Name',35,' ') || ' ' ||
                                                  rpad('Agg Assignment',15,' ') || ' ' ||
                                                  rpad('Issue Date',10,' ')  || ' ' ||
                                                  lpad('Asg Action ID', 15,' ') || ' ' ||
                                                  lpad('Locking Action ID',17,' ') || ' ' ||
                                                  rpad('Action Eff.Date',15,' '));
                fnd_file.put_line(fnd_file.output,rpad('-',15,'-') || ' ' ||
                                                  rpad('-',35,'-') || ' ' ||
                                                  rpad('-',15,'-') || ' ' ||
                                                  rpad('-',10,'-') || ' ' ||
                                                  lpad('-',15,'-') || ' ' ||
                                                  lpad('-',17,'-') || ' ' ||
                                                  rpad('-',15,'-'));
                l_count := 1;
              end if;
--fnd_file.put_line(fnd_file.output,' l_final_payment_date '|| l_final_payment_date);
--fnd_file.put_line(fnd_file.output,' l_agg_assignment_id ' || l_agg_assignment_id );
              --
              -- fetching the Assignment number for the agg.assignment id
              --
              open csr_asg_dtls(l_agg_assignment_id);
              fetch csr_asg_dtls into l_agg_assignment_number;
              close csr_asg_dtls;

              --
              -- check for any payroll action, locked the P45 asg action. if found then show the
              -- locking acions id and effective date of that payroll action
              --
              open csr_locked_act_dtls(l_p45_agg_asg_action_id);
              fetch csr_locked_act_dtls into l_locking_action_id, l_lock_effective_date;
              if csr_locked_act_dtls%notfound then
                fnd_file.put_line(fnd_file.output,rpad(b_rec.assignment_number,15,' ') || ' ' ||
                                                  rpad(b_rec.full_name,35,' ') || ' ' ||
                                                  rpad(l_agg_assignment_number,15,' ') || ' ' ||
                                                  rpad(l_p45_issue_date,10,' ') || ' ' ||
                                                  lpad(l_p45_agg_asg_action_id, 15,' ') || ' ' ||
                                                  lpad(' ',17,' ') || ' ' ||
                                                  rpad(' ',15,' '));
              else
                fnd_file.put_line(fnd_file.output,rpad(b_rec.assignment_number,15,' ') || ' ' ||
                                                  rpad(b_rec.full_name,35,' ') || ' ' ||
                                                  rpad(l_agg_assignment_number,15,' ') || ' ' ||
                                                  rpad(l_p45_issue_date,10,' ') || ' ' ||
                                                  lpad(l_p45_agg_asg_action_id, 15,' ') || ' ' ||
                                                  lpad(l_locking_action_id,17,' ') || ' ' ||
                                                  rpad(l_lock_effective_date,15,' '));
                loop
                   fetch csr_locked_act_dtls into l_locking_action_id, l_lock_effective_date;
                   if csr_locked_act_dtls%notfound then
                      exit;
                   end if;
                   fnd_file.put_line(fnd_file.output,rpad(' ',15,' ') || ' ' ||
                                                     rpad(' ',35,' ') || ' ' ||
                                                     rpad(' ',15,' ') || ' ' ||
                                                     rpad(' ',10,' ') || ' ' ||
                                                     lpad(' ',15,' ') || ' ' ||
                                                     lpad(l_locking_action_id,17,' ') || ' ' ||
                                                     rpad(l_lock_effective_date,15,' '));
                end loop;
              end if;
              close csr_locked_act_dtls;
           end if;

        end loop;
    end loop;

    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output,'Total number of active or suspended assignments/aggregated assignments issued P45: ' || l_total_count);

END p45_issued_active_asg_report;

END;

/
