--------------------------------------------------------
--  DDL for Package Body PAY_AU_DLEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_DLEC" AS
/* $Header: pyaudlec.pkb 120.0 2005/05/29 03:04 appldev noship $ */

  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : DISPLAY_LE_CHANGE                                     --
  -- Type           : PROCEDURE                                             --
  -- Access         : Private                                               --
  -- Description    : Procedure to display the employees who have had a     --
  --                : change in legal employer in a specified financial     --
  --                  year for AU.                                          --
  --                  p_financial_year_end is in format YYYY where YYYY     --
  --                  is the ending financial year.                         --
  --                  Eg. enter 2005 for Financial Year 2004/2005           --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_business_group_id    NUMBER                         --
  --                  p_financial_year_end   VARCHAR2                       --
  --            OUT :                                                       --

PROCEDURE display_le_change (  errbuf      OUT NOCOPY VARCHAR2
                              ,retcode     OUT NOCOPY NUMBER
                              ,p_business_group_id    IN NUMBER
                              ,p_financial_year_end   IN NUMBER
                            )
IS

-- Determine all assignments which have had a change of legal employer.
-- Note : we're not checking effective date of the assignments because
-- we want to check all date-tracked changes for the assignment.

cursor c_select_assignments
(
  c_business_group_id  per_all_assignments_f.business_group_id%type,
  c_start_date  per_all_assignments_f.effective_start_date%type,
  c_end_date    per_all_assignments_f.effective_end_date%type
)
 is
 select asg.assignment_id,
        asg.assignment_number,
        asg.effective_start_date,
        asg.effective_end_date,
        asg.person_id,
        scl.segment1
     from   per_all_assignments_f  asg
           ,hr_soft_coding_keyflex scl
     where  scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
     and    asg.business_group_id = c_business_group_id
     and    asg.effective_start_date <= c_end_date
     and    asg.effective_end_date   >= c_start_date
     order by asg.assignment_id,
              asg.effective_start_date;

l_prev_assignment_id  number := 0;
l_prev_legal_emp number := 0;
l_count number := 0;

l_year number := 0;
l_fin_year_start date;
l_fin_year_end   date;
l_today          date;
l_business_group_name hr_all_organization_units.name%type;

type l_asg_rec is record
  (assignment_id        per_all_assignments_f.assignment_id%type,
   assignment_number    per_all_assignments_f.assignment_number%type,
   effective_start_date per_all_assignments_f.effective_start_date%type,
   effective_end_date   per_all_assignments_f.effective_end_date%type,
   segment1             hr_soft_coding_keyflex.segment1%type,
   prev_segment1        hr_soft_coding_keyflex.segment1%type,
   seg1_name            hr_organization_units.name%type,
   seg1_prev_name       hr_organization_units.name%type,
   person_id            per_all_assignments_f.person_id%type,
   full_name            per_all_people_f.full_name%type
  );

type l_asg_table_def is table of l_asg_rec
  index by binary_integer;

l_asg_tab  l_asg_table_def;

l_proc_name   VARCHAR2(150);

BEGIN

-- Clear out assignment table.

  select  to_char(sysdate,'DD-MON-YYYY')
    into l_today
    from dual;

-- Get the business group name.

  select hou.name
    into l_business_group_name
    from hr_all_organization_units hou,
         hr_organization_information hoi
    where hou.organization_id = hou.business_group_id
    and   hou.organization_id = hoi.organization_id
    and   hoi.org_information_context = 'Business Group Information'
    and   hou.business_group_id = p_business_group_id;

-- Set up the start and end financial year dates.

  l_year := to_number(p_financial_year_end) - 1;

  l_fin_year_start := to_date('01-07-' || l_year, 'dd-mm-yyyy');

  l_fin_year_end := to_date('30-06-' || p_financial_year_end, 'dd-mm-yyyy');

  l_asg_tab.delete;

  fnd_file.put_line(fnd_file.output, '  Listing of Assignments who have changed Legal Employer in Financial Year');
  fnd_file.put_line(fnd_file.output, '---------------------------------------------------------------------------- ');
  fnd_file.put_line(fnd_file.output, ' ');
  fnd_file.put_line(fnd_file.output, 'Report Date : ' ||
                        to_char(l_today, 'dd-MON-yyyy' ));
  fnd_file.put_line(fnd_file.output, ' ');
  fnd_file.put_line(fnd_file.output, 'Parameters : ');
  fnd_file.put_line(fnd_file.output, '     Business Group Id : ' ||
                             l_business_group_name );
  fnd_file.put_line(fnd_file.output, '     Financial Year    : ' ||
                     to_char(l_fin_year_start, 'dd-MON-yyyy') || ' to ' ||
                     to_char(l_fin_year_end, 'dd-MON-yyyy') );
  fnd_file.put_line(fnd_file.output, ' ');
  fnd_file.put_line(fnd_file.output, '---------------------------------------------------------------------------- ');

  for asg_rec in c_select_assignments(p_business_group_id,
                                      l_fin_year_start,
                                      l_fin_year_end)
  loop

-- For each assignment check with previous legal employer if it's the
-- same assignment and it started in the fin year we require.

    if asg_rec.assignment_id = l_prev_assignment_id and
       asg_rec.effective_start_date between l_fin_year_start
                                      and l_fin_year_end then

      if l_prev_legal_emp <> asg_rec.segment1 then
        l_count := l_count + 1;
        l_asg_tab(l_count).assignment_id        := asg_rec.assignment_id;
        l_asg_tab(l_count).assignment_number    := asg_rec.assignment_number;
        l_asg_tab(l_count).effective_start_date := asg_rec.effective_start_date;
        l_asg_tab(l_count).effective_end_date   := asg_rec.effective_end_date;
        l_asg_tab(l_count).person_id            := asg_rec.person_id;
        l_asg_tab(l_count).segment1             := asg_rec.segment1;
        l_asg_tab(l_count).prev_segment1        := l_prev_legal_emp;
      end if;

    end if;

    l_prev_assignment_id := asg_rec.assignment_id;
    l_prev_legal_emp := asg_rec.segment1;

  end loop;

fnd_file.put_line(fnd_file.output, ' ');
fnd_file.put_line(fnd_file.output, 'Assignments that have changed legal employer in ' ||
                     'financial year ' ||
                     to_char(l_fin_year_start, 'dd-MON-yyyy') || ' to ' ||
                     to_char(l_fin_year_end, 'dd-MON-yyyy') );
fnd_file.put_line(fnd_file.output, ' ');

if l_asg_tab.count > 0 then
    fnd_file.put_line(fnd_file.output, '   Full Name                        Assignment Number        Date of New LE        New Legal Employer               Previous Legal Employer');
    fnd_file.put_line(fnd_file.output, ' ');
end if;

if l_asg_tab.count > 0 then
  for i in 1..l_asg_tab.last
  loop

-- Get the legal employer name

    select hou.name
         into l_asg_tab(i).seg1_name
         from hr_organization_units  hou
         where  l_asg_tab(i).segment1 = hou.organization_id;

-- Get the previous legal employer name

    select hou.name
         into l_asg_tab(i).seg1_prev_name
         from hr_organization_units  hou
         where  l_asg_tab(i).prev_segment1 = hou.organization_id;

-- Get the persons full name.

    select per.full_name
        into l_asg_tab(i).full_name
        from per_all_people_f per
        where per.person_id = l_asg_tab(i).person_id
        and   l_fin_year_end  between per.effective_start_date and per.effective_end_date;

-- Output the line.

    fnd_file.put_line(fnd_file.output,
            '   ' || rpad(l_asg_tab(i).full_name, 30, ' ') ||
            '   ' || rpad(l_asg_tab(i).assignment_number, 15, ' ') ||
            '            ' || to_char(l_asg_tab(i).effective_start_date, 'dd-MON-yyyy') ||
            '         ' || rpad(l_asg_tab(i).seg1_name, 30, ' ') ||
            '   ' || rpad(l_asg_tab(i).seg1_prev_name, 30, ' ')
                    );
  end loop;
else
    fnd_file.put_line(fnd_file.output, 'No assignments have had a legal employer change in the specified financial year');
end if;

  fnd_file.put_line(fnd_file.output, ' ');
  fnd_file.put_line(fnd_file.output, ' ');
  fnd_file.put_line(fnd_file.output, ' ');
  fnd_file.put_line(fnd_file.output, ' ');
  fnd_file.put_line(fnd_file.output, '                          E N D   O F   R E P O R T ');

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('AU : Exception, Leaving: '|| l_proc_name);
    RAISE;

END display_le_change;

END pay_au_dlec;

/
