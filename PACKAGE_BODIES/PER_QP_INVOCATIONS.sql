--------------------------------------------------------
--  DDL for Package Body PER_QP_INVOCATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QP_INVOCATIONS" as
/* $Header: ffqti01t.pkb 115.6 2002/12/23 14:15:02 arashid ship $ */
--
function get_qp_session_id return NUMBER is
--
cursor c is
  select per_quickpaint_invocations_s.nextval
  from   sys.dual;
--
l_id NUMBER;
--
begin
--
  open c;
  fetch c into l_id;
  close c;
  return(l_id);
--
end;
--
procedure pre_insert_checks(p_qp_session_id             NUMBER
                           ,p_invocation_context        NUMBER
                           ,p_invocation_type           VARCHAR2
                           ,p_qp_report_id              NUMBER
                           ,p_qp_invocation_id   IN OUT NOCOPY NUMBER) is
--
cursor c is
  select  'x'
  from    per_quickpaint_invocations
  where   qp_session_id       = p_qp_session_id
  and     invocation_context  = p_invocation_context
  and     invocation_type     = p_invocation_type
  and     qp_report_id        = p_qp_report_id;
--
cursor c1 is
  select  per_quickpaint_invocations_s.nextval
  from    sys.dual;
--
l_exists varchar2(1);
--
begin
--
hr_utility.set_location('per_qp_invocations.pre_insert_checks',1);
--
  open c;
  fetch c into l_exists;
  if c%found then
  --
    close c;
    if p_invocation_type = 'S' then
    --
      hr_utility.set_message(801,'HR_6737_QP_NO_SET_TWICE');
    --
    else
    --
      hr_utility.set_message(801,'HR_6694_QP_NO_RUN_TWICE');
    --
    end if;
  --
  hr_utility.raise_error;
  --
  end if;
  close c;
  --
  open c1;
  fetch c1 into p_qp_invocation_id;
  close c1;
  --
end pre_insert_checks;
--
procedure populate_fields(p_qp_report_id              NUMBER
                         ,p_invocation_context        NUMBER
                         ,p_invocation_type           VARCHAR2
                         ,p_session_date              DATE
                         ,p_qp_report_name     IN OUT NOCOPY VARCHAR2
                         ,p_assignment_set     IN OUT NOCOPY VARCHAR2
                         ,p_full_name          IN OUT NOCOPY VARCHAR2
                         ,p_assignment_number  IN OUT NOCOPY VARCHAR2
                         ,p_user_person_type   IN OUT NOCOPY VARCHAR2) is
--
cursor c is
  select assignment_set_name
  from   hr_assignment_sets
  where  assignment_set_id = p_invocation_context;
--
cursor c1 is
  select qp_report_name
  from   ff_qp_reports
  where  qp_report_id = p_qp_report_id;
--
cursor c2 is
  select p.full_name
  ,      a.assignment_number
  ,      hr_person_type_usage_info.get_user_person_type(p_session_date,p.person_id)
  from   per_people        p
  ,      per_assignments_f a
  where  p.person_id = a.person_id
  and    a.assignment_id = p_invocation_context
  and    p_session_date between a.effective_start_date
                        and     a.effective_end_date;
--
begin
--
hr_utility.set_location('per_qp_invocations.populate_fields',1);
--
  open c1;
  fetch c1 into p_qp_report_name;
  close c1;
  --
  if p_invocation_type = 'A' then
  --
    open c2;
    fetch c2 into p_full_name, p_assignment_number, p_user_person_type;
    close c2;
  --
  end if;
  --
  if p_invocation_type = 'S' then
  --
    open c;
    fetch c into p_assignment_set;
    close c;
  --
  end if;
--
end populate_fields;
--
-- Name    : format_date_line
-- Purpose : To convert canonical dates which appear in quickpaint result text
--           into user display dates within the result text.
--
function format_date_line(p_textline VARCHAR2) return VARCHAR2 is
--
l_canonical_date  varchar2(19);
l_display_date    varchar2(19);
l_start_text      varchar2(240);
l_end_text        varchar2(240);
l_new_line        varchar2(240);
l_start_of_date   number;
l_end_of_date     number;
--
Begin
--
  --
  -- Select the location of the start of the first canonical date
  -- Will be of format 'YYYY/MM/DD 00:00:00'
  --
  l_start_of_date := (instr(p_textline,'00:00:00') - 11);
  --
  -- If no date is present in the line return line unaltered
  --
  if (l_start_of_date < 1) then
  --
    return(p_textline);
  --
  end if;
  --
  -- Select the location of the end of the first canonical date
  -- and select the chunks of text appearing before and after the date.
  -- Select the date in canonical format and convert to display format.
  -- Right pad the display format to prevent formatting errors and
  -- create the new line inserting the start and end text around the date.
  --
  l_end_of_date     := (l_start_of_date + 18);
  l_start_text      := substr(p_textline,1,(l_start_of_date - 1));
  l_end_text        := substr(p_textline,(l_end_of_date + 1));
  l_canonical_date  := substr(p_textline,l_start_of_date,19);
  l_display_date    := fnd_date.date_to_chardate(fnd_date.canonical_to_date(l_canonical_date));
  l_display_date    := rpad(l_display_date,19);
  l_new_line        := l_start_text||l_display_date||l_end_text;
  --
  -- Recursively call this program again to check if any more canonical dates
  -- appear in this line of text.  Continues until no more dates found and the
  -- new text line with formatted dates is returned.
  --
  l_new_line := format_date_line(l_new_line);
  --
  return(l_new_line);
--
End format_date_line;
--
-- Name    : load_result
-- Purpose : To format and return the quickpaint report result text.
--
function load_result(p_assignment_id    NUMBER
                    ,p_qp_invocation_id NUMBER) return VARCHAR2 is
--
cursor c is
  select text
  from   per_quickpaint_result_text
  where  assignment_id    = p_assignment_id
  and    qp_invocation_id = p_qp_invocation_id
  order by line_number;
--
l_result         VARCHAR2(16000) := '';
l_line           VARCHAR2(240);
l_formatted_line VARCHAR2(240);
l_eol            VARCHAR2(1)     := '';
--
Begin
--
hr_utility.set_location('per_qp_invocations.load_result',1);
--
  open c;
  loop
  --
    fetch c into l_line;
    exit when c%notfound;
    l_formatted_line := format_date_line(l_line);
    l_result := l_result || l_eol || l_formatted_line;
    --
    -- Excuse the loss of formatting, but chr(10) has been replaced
    -- by an acceptable method for getting a newline.
    --
    l_eol :=
'
';
  --
  end loop;
  close c;
--
  return(l_result);
--
End load_result;
--
procedure get_assignment(p_assignment_id            NUMBER
                        ,p_qp_invocation_id         NUMBER
                        ,p_full_name         IN OUT NOCOPY VARCHAR2
                        ,p_user_person_type  IN OUT NOCOPY VARCHAR2
                        ,p_assignment_number IN OUT NOCOPY VARCHAR2
                        ,p_result               OUT NOCOPY VARCHAR2) is
cursor c is
  select full_name
  ,      user_person_type
  ,      assignment_number
  from   per_quickpaint_assignments a
  where  assignment_id = p_assignment_id
  and    exists(select null
                from   per_quickpaint_result_text t
                where  t.assignment_id = p_assignment_id
                and    t.qp_invocation_id = p_qp_invocation_id);
--
begin
--
hr_utility.set_location('per_qp_invocations.get_assignment',1);
--
  open c;
  fetch c into p_full_name,p_user_person_type,p_assignment_number;
  close c;
  p_result := load_result(p_assignment_id
                         ,p_qp_invocation_id);
--
end get_assignment;
--
procedure init_cust(p_customized_restriction_id        NUMBER
                   ,p_restrict_empapl           IN OUT NOCOPY VARCHAR2
                   ,p_restrict_person_type      IN OUT NOCOPY VARCHAR2
                   ,p_restrict_inq              IN OUT NOCOPY VARCHAR2
                   ,p_restrict_use              IN OUT NOCOPY VARCHAR2) is
--
cursor restriction(l_customization_type VARCHAR2) is
  select  value
  from    pay_restriction_values
  where   restriction_code = l_customization_type
  and     customized_restriction_id = p_customized_restriction_id;
--
l_exists varchar2(30);
--
begin
--
hr_utility.set_location('per_qp_invocations.init_cust',1);
--
  p_restrict_empapl := 'N';
  open restriction('EMP_APL');
  fetch restriction into l_exists;
  if restriction%found then
  --
    p_restrict_empapl := 'Y';
  --
  end if;
  close restriction;
  --
  p_restrict_person_type := 'N';
  open restriction('PERSON_TYPE');
  fetch restriction into l_exists;
  if restriction%found then
  --
    p_restrict_person_type := 'Y';
  --
  end if;
  close restriction;
  --
  p_restrict_inq := 'N';
  open restriction('QP_INQUIRY');
  fetch restriction into l_exists;
  if restriction%found then
  --
    p_restrict_inq := 'Y';
  --
  end if;
  close restriction;
  --
  open restriction('ASG_SET');
  fetch restriction into p_restrict_use;
  close restriction;
--
end init_cust;
--
function validate_assignment(p_business_group_id NUMBER
                            ,p_session_date      DATE
                            ,p_full_name         VARCHAR2
                            ,p_assignment_number VARCHAR2) return NUMBER is
--
cursor c is
  select a.assignment_id
  from   per_assignments_f a
  ,      per_people        p
  where  a.person_id = p.person_id
  and    ((p_assignment_number is null
  and    a.assignment_number is null)
  or     (p_assignment_number is not null
  and    a.assignment_number = p_assignment_number))
  and    p.full_name = p_full_name
  and    a.business_group_id + 0 = p_business_group_id
  and    p_session_date between a.effective_start_date
                        and     a.effective_end_date;
--
l_invocation_context NUMBER;
--
begin
--
hr_utility.set_location('per_qp_invocations.validate_assignment',1);
--
  open c;
  fetch c into l_invocation_context;
  if c%notfound then
  --
    close c;
    hr_utility.set_message(801,'HR_7097_ASS_SET_INVALID');
    hr_utility.set_message_token('ASS_SET','assignment');
    hr_utility.raise_error;
  --
  end if;
  close c;
  --
  return(l_invocation_context);
--
end validate_assignment;
--
procedure delete_quickpaints(p_qp_session_id NUMBER) is
--
begin
--
hr_utility.set_location('per_qp_invocations.delete_quickpaints',1);
--
  delete from per_quickpaint_invocations
  where qp_session_id = p_qp_session_id;
  --
  commit;
--
end delete_quickpaints;
--
function print_result(p_business_group_id NUMBER
                     ,p_session_date      DATE
                     ,p_qp_invocation_id  NUMBER) return BOOLEAN is
--
l_bg_arg VARCHAR2(80);
l_sd_arg VARCHAR2(80);
l_qi_arg VARCHAR2(80);
l_req_id NUMBER;
--
begin
--
  l_bg_arg := to_char(p_business_group_id);
  /* Fix for WWBUG 1756943 */
  l_sd_arg := fnd_date.date_to_canonical(p_session_date);
  l_qi_arg := to_char(p_qp_invocation_id);
  --
  l_req_id := fnd_request.submit_request
                ('PER'
                ,'PERRPRQP'
		,NULL
		,NULL
		,NULL
                ,l_bg_arg
                ,l_sd_arg
                ,l_qi_arg);
  --
  if (l_req_id = 0) then
  --
    rollback;
    return(FALSE);
  --
  else
  --
    commit;
    return(TRUE);
  --
  end if;
--
end print_result;
--
END PER_QP_INVOCATIONS;

/
