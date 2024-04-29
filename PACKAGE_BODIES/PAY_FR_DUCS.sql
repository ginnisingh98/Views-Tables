--------------------------------------------------------
--  DDL for Package Body PAY_FR_DUCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_DUCS" as
/* $Header: pyfraduc.pkb 120.1 2006/01/27 04:37:54 aparkes noship $ */
--
-- Globals
--
type g_org_info_tabtype is table of
  hr_organization_information.org_information1%TYPE
  index by binary_integer;

type g_estab_pens_prov_rectype is record (
  estab_id   hr_organization_information.organization_id%TYPE,
  pens_provs g_org_info_tabtype);

g_estab_pens_provs       g_estab_pens_prov_rectype;

g_package                constant varchar2(30):= 'pay_fr_ducs';

g_business_group_id      per_business_Groups.business_group_id%TYPE;
g_payroll_action_id      pay_payroll_actions.payroll_action_id%TYPE;

g_company_id             hr_all_organization_units.organization_id%TYPE;
g_period_type            varchar2(60);
g_period_start_date      date;
g_effective_date         date;
g_english_base           varchar2(20) := 'Base';
g_english_rate           varchar2(20) := 'Rate';
g_english_pay_value      varchar2(20) := 'Pay Value';
g_english_contrib_code   varchar2(20) := 'Contribution_Code';
g_french_base            fnd_lookup_values.meaning%TYPE;
g_french_rate            fnd_lookup_values.meaning%TYPE;
g_french_pay_value       fnd_lookup_values.meaning%TYPE;
g_french_contrib_code    fnd_lookup_values.meaning%TYPE;
g_range_person_enh_enabled boolean;
--
-------------------------------------------------------------------------------
-- GET_PARAMETER  used in sql to decode legislative parameters
-------------------------------------------------------------------------------
FUNCTION get_parameter(
                p_parameter_string  in varchar2
               ,p_token             in varchar2
               ,p_segment_number    in number default null ) RETURN varchar2
IS
  l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
  l_start_pos  NUMBER;
  l_delimiter  varchar2(1):=' ';
  l_proc VARCHAR2(60):= g_package||' get parameter ';
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 20);
  l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
  IF l_start_pos = 0 THEN
    l_delimiter := '|';
    l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
  end if;
  IF l_start_pos <> 0 THEN
    l_start_pos := l_start_pos + length(p_token||'=');
    l_parameter := substr(p_parameter_string,
                          l_start_pos,
                          instr(p_parameter_string||' ',
                          l_delimiter,l_start_pos)
                          - l_start_pos);
    IF p_segment_number IS NOT NULL THEN
      l_parameter := ':'||l_parameter||':';
      l_parameter := substr(l_parameter,
                            instr(l_parameter,':',1,p_segment_number)+1,
                            instr(l_parameter,':',1,p_segment_number+1) -1
                            - instr(l_parameter,':',1,p_segment_number));
    END IF;
  END IF;
  hr_utility.set_location('Leaving ' || l_proc, 100);
  RETURN l_parameter;

END get_parameter;

-------------------------------------------------------------------------------
-- GET_ALL_PARAMETERS gets all parameters for the payroll action
-------------------------------------------------------------------------------
PROCEDURE get_all_parameters (p_payroll_action_id       in number
                             ,p_business_group_id       out nocopy number
                             ,p_company_id              out nocopy number
                             ,p_period_type             out nocopy varchar2
                             ,p_period_start_date       out nocopy date
                             ,p_effective_date          out nocopy date
                             ,p_english_base            out nocopy varchar2
                             ,p_english_rate            out nocopy varchar2
                             ,p_english_pay_value       out nocopy varchar2
                             ,p_english_contrib_code    out nocopy varchar2
                             ,p_french_base             out nocopy varchar2
                             ,p_french_rate             out nocopy varchar2
                             ,p_french_pay_value        out nocopy varchar2
                             ,p_french_contrib_code     out nocopy varchar2) IS
  --
  CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
  SELECT fnd_number.canonical_to_number(
           pay_fr_ducs.get_parameter(legislative_parameters, 'COMPANY_ID'))
        ,pay_fr_ducs.get_parameter(legislative_parameters, 'PERIOD_TYPE')
        ,effective_date
        ,business_group_id
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
  --
  l_proc VARCHAR2(60):= g_package||' get_all_parameters ';

BEGIN

  hr_utility.set_location('Entering ' || l_proc, 20);

  OPEN  csr_parameter_info (p_payroll_action_id);
  FETCH csr_parameter_info INTO p_company_id,
                                p_period_type,
                                p_effective_date,
                                p_business_group_id;
  CLOSE csr_parameter_info;

  p_period_start_date := trunc(p_effective_date,
                               translate(p_period_type,'C','M'));
  --
  p_english_base := 'Base';
  p_english_rate := 'Rate';
  p_english_pay_value := 'Pay Value';
  p_english_contrib_code := 'Contribution_Code';
  --
  p_french_base := hr_general.decode_lookup('NAME_TRANSLATIONS','BASE');
  p_french_rate := hr_general.decode_lookup('NAME_TRANSLATIONS','RATE');
  p_french_pay_value :=
       hr_general.decode_lookup('NAME_TRANSLATIONS','PAY VALUE');
  p_french_contrib_code :=
       hr_general.decode_lookup('NAME_TRANSLATIONS','CONTRIBUTION CODE');


  hr_utility.set_location('Leaving ' || l_proc, 100);

END get_all_parameters;
--

/*--------------------------------------------------------------------------
  Name      : range_code
  Purpose   : This returns the select statement that is used to created the
              range rows.
  ------------------------------------------------------------------------*/

PROCEDURE range_code(p_payroll_action_id   in number
                    ,sqlstr                out nocopy varchar2)  IS

-- Local Variable

l_proc                 VARCHAR2(60) :=    g_package||' range_cursor ';

l_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
duplicate EXCEPTION;

l_year        varchar2(10);
l_quarter     varchar2(10);
l_month       varchar2(10);
l_mm          varchar2(12);
l_miq         varchar2(12);
l_period_code varchar2(30);
--
-- Cursor
--

CURSOR  c_existing_archive (p_company_id_chr in varchar2) is
SELECT  payact.payroll_action_id
FROM    pay_payroll_actions payact
       ,pay_action_information ref_actinfo
WHERE   payact.payroll_action_id = ref_actinfo.action_context_id
  and   ref_actinfo.action_information_category = 'FR_DUCS_REFERENCE_INFO'
  and   ref_actinfo.action_context_type = 'PA'
  and   ref_actinfo.action_information1 = p_company_id_chr
  and   ref_actinfo.action_information2 = l_period_code
  and   payact.business_group_id = g_business_group_id
  and   payact.payroll_action_id <> p_payroll_action_id;

BEGIN



 hr_utility.set_location('Entering ' || l_proc,10);

--
-- Load the parameters to the process
--

  pay_fr_ducs.get_all_parameters
        (p_payroll_action_id    => p_payroll_action_id
        ,p_business_group_id    => g_business_group_id
        ,p_company_id           => g_company_id
        ,p_period_type          => g_period_type
        ,p_period_start_date    => g_period_start_date
        ,p_effective_date       => g_effective_date
        ,p_english_base         => g_english_base
        ,p_english_rate         => g_english_rate
        ,p_english_pay_value    => g_english_pay_value
        ,p_english_contrib_code => g_english_contrib_code
        ,p_french_base          => g_french_base
        ,p_french_rate          => g_french_rate
        ,p_french_pay_value     => g_french_pay_value
        ,p_french_contrib_code  => g_french_contrib_code);

  g_payroll_action_id:=p_payroll_action_id;



l_year    := to_char(g_effective_date,'YYYY');
l_quarter := to_char(g_effective_date,'Q');
l_month   := replace(to_char(g_effective_date,'MONTH'),' ','');
l_mm      := to_char(g_effective_date,'MM');
l_miq     := to_char(to_number(l_mm)-(to_number(l_quarter)*3-2)+1);

IF g_period_type = 'CM' THEN
   l_period_code := substr(l_year,3,2)||l_quarter||l_miq;
ELSE
   l_period_code := substr(l_year,3,2)||l_quarter||'0';
END IF;

OPEN c_existing_archive(fnd_number.number_to_canonical(g_company_id));
FETCH c_existing_archive INTO l_payroll_action_id;
   IF c_existing_archive%found THEN
     CLOSE c_existing_archive;
     RAISE duplicate;
   END IF;
CLOSE c_existing_archive;


hr_utility.set_location('Step ' || l_proc, 30);

sqlstr := 'SELECT DISTINCT person_id
           FROM   per_people_f ppf
                 ,pay_payroll_actions ppa
           WHERE  ppa.payroll_action_id = :payroll_action_id
                  AND ppa.business_group_id = ppf.business_group_id
                  ORDER BY ppf.person_id';

hr_utility.set_location('Leaving ' || l_proc,100);
EXCEPTION

  WHEN duplicate THEN
    hr_utility.set_location(' Leaving with EXCEPTION: '||l_proc,100);

    hr_utility.set_message(801, 'PAY_75086_DUCS_DUPLICATE_ARCH');
    FND_FILE.PUT_LINE(fnd_file.log,substr(hr_utility.get_message,1,240));
    sqlstr := 'select 1 from dual where to_char(:payroll_action_id) = dummy';


  WHEN OTHERS THEN
    hr_utility.set_location(' Leaving with EXCEPTION: '||l_proc,100);
    -- Return cursor that selects no rows
    sqlstr := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
    hr_utility.set_location('Quitting ' || l_proc,10);

END range_code;

/*--------------------------------------------------------------------------
  Name      : assignment_action_code
  Purpose   : This creates the assignment actions for a specific chunk.
  Arguments :
  Notes     :
--------------------------------------------------------------------------*/
PROCEDURE assignment_action_code (p_payroll_action_id in number
                                 ,p_start_person_id in number
                                 ,p_end_person_id in number
                                 ,p_chunk in number) IS

-- Local Variable

l_proc                 VARCHAR2(60):=g_package||'.assignment_action_code ';

l_actid                pay_assignment_actions.assignment_action_id%TYPE;

--
-- Do not process child assignment actions here  these will be
-- explicitly created in ARCHIVE_CODE
--
--
-- Cursor to retrieve assignment actions
-- during the processing period given the person_id range
-- including the set of archive records created in earlier archives
-- but that will be summed for the reporting period.
-- Company Id is a mandatory param for DUCS so filter on leg params
-- before joining to establishment info
CURSOR csr_assact_by_range(p_company_id_chr in varchar2) is
SELECT /*+ ORDERED */ assact.assignment_id
,      assact.assignment_action_id
,      assact.tax_unit_id establishment_id
,      payact.action_type
FROM   pay_assignment_actions assact
,      pay_payroll_actions payact
,      hr_organization_information cmp_check
WHERE  assact.source_action_id is null
AND    assact.action_status = 'C'
AND    assact.payroll_action_id = payact.payroll_action_id
AND    payact.effective_date between g_period_start_date
                                     and g_effective_date
AND    assact.assignment_id in
         (select assignment_id
          from per_all_assignments_f asg
          where asg.business_group_id+0 = g_business_group_id
          and   asg.person_id between p_start_person_id and p_end_person_id
          and   asg.effective_end_date >= g_period_start_date
          and   asg.effective_start_date <= g_effective_date
          and   asg.period_of_service_id is not null)
AND    (payact.action_type in ('Q','R','B','I') or
        (payact.action_type       = 'X'
         and    payact.report_type        = 'DUCS_ARCHIVE'
         and    payact.report_qualifier   = 'FR'
         and    payact.report_category    = 'DUCS_ARCHIVE'
         AND    legislative_parameters like '%COMPANY_ID='||
                                            p_company_id_chr ||' %'))
/* Bug 2309322 Run assg_actions restricted by company */
AND    assact.tax_unit_id = cmp_check.organization_id
AND    cmp_check.org_information_context = 'FR_ESTAB_INFO'
AND    cmp_check.org_information1 = p_company_id_chr;
--
--
-- Cursor to retrieve assignment actions
-- during the processing period given the chunk_number,
-- including the set of archive records created in earlier archives
-- but that will be summed for the reporting period.
-- Company Id is a mandatory param for DUCS so filter on leg params
-- before joining to establishment info
--
CURSOR csr_assact_by_chunk(p_company_id_chr in varchar2) is
SELECT /*+ ORDERED */ assact.assignment_id
,      assact.assignment_action_id
,      assact.tax_unit_id establishment_id
,      payact.action_type
FROM   pay_population_ranges pop
,      per_periods_of_service pos
,      per_all_assignments_f asg
,      pay_assignment_actions assact
,      pay_payroll_actions payact
,      hr_organization_information cmp_check
WHERE  pop.payroll_action_id             = p_payroll_action_id
and    pop.chunk_number                  = p_chunk
and    asg.business_group_id+0           = g_business_group_id
and    asg.effective_end_date           >= g_period_start_date
and    asg.effective_start_date         <= g_effective_date
and    asg.period_of_service_id          = pos.period_of_service_id
and    pos.person_id                     = pop.person_id
and    assact.source_action_id          is null
and    assact.action_status              = 'C'
AND    assact.payroll_action_id          = payact.payroll_action_id
AND    payact.effective_date       between g_period_start_date
                                       and g_effective_date
AND    (asg.effective_start_date,assact.assignment_id) =
         (select max(asg2.effective_start_date), asg2.assignment_id
          from  per_all_assignments_f asg2
          where asg.assignment_id          = asg2.assignment_id
          and   asg2.effective_end_date   >= g_period_start_date
          and   asg2.effective_start_date <= g_effective_date
          group by asg2.assignment_id)
AND    (payact.action_type in ('Q','R','B','I') or
        (payact.action_type       = 'X'
         and    payact.report_type        = 'DUCS_ARCHIVE'
         and    payact.report_qualifier   = 'FR'
         and    payact.report_category    = 'DUCS_ARCHIVE'
         AND    legislative_parameters like '%COMPANY_ID='||
                                            p_company_id_chr ||' %'))
/* Bug 2309322 Run assg_actions restricted by company */
AND    assact.tax_unit_id                = cmp_check.organization_id
AND    cmp_check.org_information_context = 'FR_ESTAB_INFO'
AND    cmp_check.org_information1        = p_company_id_chr;
--
CURSOR csr_locking_archive(p_run_act_id number) is
SELECT /*+ ORDERED */ 1
FROM   pay_action_interlocks plock
,      pay_assignment_actions assact
,      pay_action_information actinfo
WHERE  plock.locked_action_id = p_run_act_id
AND    plock.locking_action_id = assact.assignment_action_id
AND    assact.payroll_action_id = actinfo.action_context_id
AND    actinfo.action_context_type = 'PA'
AND    actinfo.action_information_category = 'FR_DUCS_REFERENCE_INFO';
--
rec_assact   csr_assact_by_range%ROWTYPE;
l_num        number(1);
l_create_act boolean;
--
BEGIN -- assignment_action_code
  hr_utility.set_location('Entering ' || l_proc,10);

  if g_payroll_action_id is null
  or g_payroll_action_id <> p_payroll_action_id
  then
    pay_fr_ducs.get_all_parameters
        (p_payroll_action_id    => p_payroll_action_id
        ,p_business_group_id    => g_business_group_id
        ,p_company_id           => g_company_id
        ,p_period_type          => g_period_type
        ,p_period_start_date    => g_period_start_date
        ,p_effective_date       => g_effective_date
        ,p_english_base         => g_english_base
        ,p_english_rate         => g_english_rate
        ,p_english_pay_value    => g_english_pay_value
        ,p_english_contrib_code => g_english_contrib_code
        ,p_french_base          => g_french_base
        ,p_french_rate          => g_french_rate
        ,p_french_pay_value     => g_french_pay_value
        ,p_french_contrib_code  => g_french_contrib_code);
    g_payroll_action_id := p_payroll_action_id;
    g_range_person_enh_enabled := null;
  end if;

  if g_range_person_enh_enabled is null then
     g_range_person_enh_enabled :=
        pay_fr_arc_utl.range_person_enh_enabled(p_payroll_action_id);
  end if;
  if g_range_person_enh_enabled then
    open csr_assact_by_chunk(to_number(g_company_id));
  else
    open csr_assact_by_range(to_number(g_company_id));
  end if;
  LOOP
    if csr_assact_by_chunk%ISOPEN then
      fetch csr_assact_by_chunk into rec_assact;
      if csr_assact_by_chunk%NOTFOUND then
        close csr_assact_by_chunk;
        exit;
      end if;
    elsif csr_assact_by_range%ISOPEN then
      fetch csr_assact_by_range into rec_assact;
      if csr_assact_by_range%NOTFOUND then
        close csr_assact_by_range;
        exit;
      end if;
    end if;
    --
    if rec_assact.action_type = 'X' then
      l_create_act := TRUE;
    else
      open csr_locking_archive(rec_assact.assignment_action_id);
      fetch csr_locking_archive into l_num;
      l_create_act := csr_locking_archive%NOTFOUND;
      close csr_locking_archive;
    end if;
    if l_create_act then
      -- insert the new assignment action
      SELECT pay_assignment_actions_s.nextval
      INTO   l_actid
      FROM   dual;
      hr_nonrun_asact.insact( l_actid
                            , rec_assact.assignment_id
                            , p_payroll_action_id
                            , p_chunk
                            , rec_assact.establishment_id);
      -- insert the lock on the run/arch action.
      hr_nonrun_asact.insint(l_actid
                          , rec_assact.assignment_action_id);
    end if; -- l_create_act
  END LOOP;

hr_utility.set_location('Leaving ' || l_proc,100);

END assignment_action_code;  --End of Assignment Action Creation

/*--------------------------------------------------------------------------
  Name      : archinit
  Purpose   : This sets up the session-static globals used in archive_code
  Arguments :
  Notes     :
--------------------------------------------------------------------------*/
PROCEDURE archinit(p_payroll_action_id IN NUMBER) IS
  l_proc      VARCHAR2(60):= g_package||'.archinit';
BEGIN
hr_utility.set_location('Entering: ' || l_proc,10);
if g_payroll_action_id is null
or g_payroll_action_id <> p_payroll_action_id
then
  hr_utility.set_location(l_proc,20);
  pay_fr_ducs.get_all_parameters
        (p_payroll_action_id    => p_payroll_action_id
        ,p_business_group_id    => g_business_group_id
        ,p_company_id           => g_company_id
        ,p_period_type          => g_period_type
        ,p_period_start_date    => g_period_start_date
        ,p_effective_date       => g_effective_date
        ,p_english_base         => g_english_base
        ,p_english_rate         => g_english_rate
        ,p_english_pay_value    => g_english_pay_value
        ,p_english_contrib_code => g_english_contrib_code
        ,p_french_base          => g_french_base
        ,p_french_rate          => g_french_rate
        ,p_french_pay_value     => g_french_pay_value
        ,p_french_contrib_code  => g_french_contrib_code);
  g_payroll_action_id := p_payroll_action_id;
END IF;
hr_utility.set_location(' Leaving: ' || l_proc,99);

END archinit;

/*--------------------------------------------------------------------------
  Name      : archive_code
  Purpose   : This creates child assignment actions as necessary
              and archives the pertinent data for a leaf action.

  Arguments :
  Notes     : Assumes no more than 3 levels in the action hierarchy.
--------------------------------------------------------------------------*/
PROCEDURE archive_code (p_assignment_action_id in number,
                        p_effective_date       in date) IS


-- Local Variable

  l_proc                 VARCHAR2(60):= g_package||' Archive code ';

  l_child                boolean:=false;
  l_grand_child          boolean:=false;
  l_num                  number(1);
--
-- Cursors
--
  CURSOR csr_locked_action_info is
  SELECT payact.action_type type,
         locked_assact.assignment_action_id id,
         locked_assact.tax_unit_id
  FROM   pay_action_interlocks interlock
  ,      pay_assignment_actions locked_assact
  ,      pay_payroll_actions payact
  WHERE interlock.locking_action_id     = p_assignment_action_id
    AND interlock.locked_action_id      = locked_assact.assignment_action_id
    AND locked_assact.payroll_action_id = payact.payroll_action_id;
--
  CURSOR csr_locking_reversal (p_run_act_id number) is
  SELECT 1 /* if the run action is reversed exclude it */
  FROM   pay_action_interlocks rev_interlock
  ,      pay_assignment_actions rev_assact
  ,      pay_payroll_actions rev_payact
  WHERE  rev_interlock.locked_action_id  = p_run_act_id
  AND    rev_interlock.locking_action_id = rev_assact.assignment_action_id
  AND    rev_assact.action_status        = 'C'
  AND    rev_payact.payroll_action_id    = rev_assact.payroll_action_id
  AND    rev_payact.action_type          = 'V'
  AND    rev_payact.action_status        = 'C';

  CURSOR csr_run_child is
  SELECT assact.chunk_number
        ,runchild.payroll_action_id
        ,runchild.assignment_action_id
        ,runchild.assignment_id
        ,runchild.tax_unit_id
        ,pay_assignment_actions_s.nextval new_ass_act_id
  FROM   pay_assignment_actions assact
        ,pay_action_interlocks interlock
        ,pay_assignment_actions runchild
  WHERE  assact.assignment_action_id = p_assignment_action_id
  AND    interlock.locking_action_id = assact.assignment_action_id
  AND    interlock.locked_action_id  = runchild.source_action_id;

  CURSOR csr_grand_child (p_child_action_id   in number) is
  SELECT assact.assignment_action_id
        ,assact.tax_unit_id
        ,pay_assignment_actions_s.nextval new_ass_act_id
  FROM   pay_assignment_actions assact
  WHERE  assact.source_action_id   = p_child_action_id;
--
  l_locked_action csr_locked_action_info%ROWTYPE;
--
BEGIN


hr_utility.set_location('Entering ' || l_proc,10);

  open csr_locked_action_info;
  fetch csr_locked_action_info into l_locked_action;
  close csr_locked_action_info;
  if l_locked_action.type <> 'X' then

    --Create child archive assignment action records

    FOR child IN csr_run_child LOOP
    --
      l_child := true;
      l_grand_child :=false;
      hr_nonrun_asact.insact(lockingactid => child.new_ass_act_id
                            ,assignid     => child.assignment_id
                            ,pactid       => g_payroll_action_id
                            ,chunk        => child.chunk_number
                            ,greid        => child.tax_unit_id
                            ,source_act   => p_assignment_action_id);
      --
      -- insert the lock on the run action.
      --
      hr_nonrun_asact.insint(child.new_ass_act_id,child.assignment_action_id);

      --Create grand child archive assignment action records
      FOR grand_child IN csr_grand_child (child.assignment_action_id)
      LOOP
        l_grand_child :=true;
        hr_nonrun_asact.insact(lockingactid => grand_child.new_ass_act_id
                              ,assignid     => child.assignment_id
                              ,pactid       => g_payroll_action_id
                              ,chunk        => child.chunk_number
                              ,greid        => grand_child.tax_unit_id
                              ,source_act   => child.new_ass_act_id);
        --
        -- insert the lock on the run action.
        --

        hr_nonrun_asact.insint(grand_child.new_ass_act_id,
                               grand_child.assignment_action_id);

        open csr_locking_reversal (grand_child.assignment_action_id);
        fetch csr_locking_reversal into l_num;
        if csr_locking_reversal%NOTFOUND then
          -- Run the contribution retrieval procedure
          pay_fr_ducs.retrieve_contributions(grand_child.new_ass_act_id,
                                             p_effective_date,
                                             grand_child.tax_unit_id);
        end if; -- csr_locking_reversal%NOTFOUND
        close csr_locking_reversal;
        update pay_assignment_actions
        set action_status = 'C'
        where assignment_action_id = grand_child.new_ass_act_id;
      END LOOP; -- grand_child
      -- Only process the child action if it has no grand child actions
      IF not l_grand_child THEN
        open csr_locking_reversal (child.assignment_action_id);
        fetch csr_locking_reversal into l_num;
        if csr_locking_reversal%NOTFOUND then
          -- Run the contribution retrieval procedure
          pay_fr_ducs.retrieve_contributions(child.new_ass_act_id,
                                             p_effective_date,
                                             child.tax_unit_id);
        end if; -- csr_locking_reversal%NOTFOUND
        close csr_locking_reversal;
      END IF;
      update pay_assignment_actions
      set action_status = 'C'
      where assignment_action_id = child.new_ass_act_id;
    END LOOP; -- child


    hr_utility.set_location('Step ' || l_proc,20);

    -- Only process the parent action if it has no child actions

    IF not l_child THEN
      open csr_locking_reversal (l_locked_action.id);
      fetch csr_locking_reversal into l_num;
      if csr_locking_reversal%NOTFOUND then
        pay_fr_ducs.retrieve_contributions(p_assignment_action_id
                                          ,p_effective_date
                                          ,l_locked_action.tax_unit_id);
      end if; -- csr_locking_reversal%NOTFOUND
      close csr_locking_reversal;
    END IF;
  end if; --  l_action_type <> 'X'
hr_utility.set_location('Leaving ' || l_proc,100);

END archive_code; -- End of Archive Code

-------------------------------------------------------------------
--Procedure Retreive Contribituions
-------------------------------------------------------------------

PROCEDURE retrieve_contributions(p_assignment_action_id in number
                                ,p_effective_date       in date
                                ,p_tax_unit_id          in number default null)
IS


-- Local Variable

l_proc      VARCHAR2(60):= g_package||' retrieve_contributions ';


l_establishment_id      pay_assignment_actions.tax_unit_id%TYPE;
l_Order_Number          binary_integer;

l_page_type             pay_run_result_values.result_value%TYPE;
l_subpage_identifier    varchar2(150);


l_action_info_id        pay_action_information.action_information_id%TYPE;
l_ovn                   pay_action_information.object_version_number%TYPE;


l_rate_type             pay_fr_contribution_usages.RATE_TYPE%TYPE;

--
-- Cursor sums the rates of contributions for common contribution codes
-- and bases within an assignment action.
--

CURSOR ccontrib is
SELECT decode(substr(contribution_code,1,1),'1','URSSAF'
                                           ,'2','ASSEDIC'
                                           ,'3','AGIRC'
                                           ,'4','ARRCO') contribution_type
,      contribution_code
,      base
,      source_asg_action_id
,      nvl(process_path,' ') retro_process_path
,      retro_adjustment_type
,      sum(rate) rate
,      sum(pv) pv
FROM (
SELECT /*+ ORDERED USE_NL(et) INDEX(et PAY_ELEMENT_TYPES_F_PK) */
   rr.run_result_id
,  nvl(epd.source_asg_action_id,rr.assignment_action_id) source_asg_action_id
,  epd.process_path
,  epd.adjustment_type retro_adjustment_type
,  max(decode(iv.name,
              g_english_contrib_code,rrv.result_value,
              g_french_contrib_code, rrv.result_value))       contribution_code
,  nvl(max(decode(iv.name,
     g_english_base, fnd_number.canonical_to_number(rrv.result_value),
     g_french_base,  fnd_number.canonical_to_number(rrv.result_value))),0) base
,  nvl(max(decode(iv.name,
     g_english_rate, fnd_number.canonical_to_number(rrv.result_value),
     g_french_rate,  fnd_number.canonical_to_number(rrv.result_value))),0) rate
,  nvl(max(decode(iv.name,
       g_english_pay_value, decode(ec.classification_name,'Rebates',-1,1) *
          fnd_number.canonical_to_number(rrv.result_value),
       g_french_pay_value, decode(ec.classification_name,'Rebates',-1,1) *
          fnd_number.canonical_to_number(rrv.result_value))),0) pv
FROM  pay_action_interlocks       ail,
      pay_run_results             rr,
      pay_element_types_f         et,
      pay_element_classifications ec,
      pay_input_values_f          iv,
      pay_run_result_values       rrv,
      pay_entry_process_details   epd
WHERE ail.locking_action_id = p_assignment_action_id
AND   rr.assignment_action_id = ail.locked_action_id
AND   rr.element_type_id = et.element_type_id
AND   et.classification_id = ec.classification_id
AND   ec.classification_name in
           ('Statutory EE Deductions'
            ,'Statutory ER Charges'
            ,'CSG Non-Deductible'
            ,'Conventional EE Deductions'
            ,'Conventional ER Charges'
            ,'Rebates')
AND   ec.legislation_code = 'FR'
AND   g_effective_date between
      et.effective_start_date and et.effective_end_date
AND   rr.element_type_id = et.element_type_id
AND   rrv.run_result_id = rr.run_result_id
AND   rr.status in ('P','PA')
AND   rrv.input_value_id = iv.input_value_id
AND   iv.element_type_id = et.element_type_id
AND   iv.name in (g_english_base,g_french_base
                 ,g_english_rate,g_french_rate
                 ,g_english_pay_value,g_french_pay_value
                 ,g_english_contrib_code,g_french_contrib_code)
AND   g_effective_date between
      iv.effective_start_date and iv.effective_end_date
and   epd.element_entry_id (+)           = rr.element_entry_id
and   epd.retro_component_id (+) is not null
GROUP BY rr.run_result_id,
         nvl(epd.source_asg_action_id,rr.assignment_action_id),
         epd.process_path,epd.adjustment_type
HAVING  max(decode(iv.name,
              g_english_contrib_code,rrv.result_value,
              g_french_contrib_code, rrv.result_value)) < '5')
--
GROUP BY decode(substr(contribution_code,1,1),'1','URSSAF'
                                           ,'2','ASSEDIC'
                                           ,'3','AGIRC'
                                           ,'4','ARRCO')
,        source_asg_action_id
,        nvl(process_path,' ')
,        retro_adjustment_type
,        contribution_code,base
ORDER BY decode(substr(contribution_code,1,1),'1','URSSAF'
                                           ,'2','ASSEDIC'
                                           ,'3','AGIRC'
                                           ,'4','ARRCO')
,        source_asg_action_id
,        nvl(process_path,' ')
,        retro_adjustment_type
,        contribution_code;
--
-- Cursor sums the rates of contributions for common contribution codes
-- and bases within an assignment action.
--
CURSOR cassact is
SELECT tax_unit_id
FROM   pay_assignment_actions
WHERE  assignment_action_id = p_assignment_action_id;
--
-- Cursor to retrieve the pension provider id
--
CURSOR cestpens(p_Order_Number varchar2) is
SELECT org_information1  -- Org ID of Pension Provider
FROM   hr_organization_information
WHERE  organization_id = l_establishment_id
       and   org_information4 = p_Order_Number
       and   org_information_context = 'FR_ESTAB_PE_PRVS';
--
type t_contrib_rec is record (
  r          ccontrib%ROWTYPE,
  group_type varchar2(30));

crec        t_contrib_rec;  -- Current record
prec        t_contrib_rec;  -- Previous record

BEGIN


  hr_utility.set_location('Entering ' || l_proc,10);

  -- Determine establishment ID
  IF p_tax_unit_id is null then
    OPEN  cassact;
    FETCH cassact INTO l_establishment_id;
    CLOSE cassact;
  ELSE
    l_establishment_id := p_tax_unit_id;
  END IF;

  prec.r.contribution_code := null;
  crec.group_type        :='FULL';  -- will remain FULL for all but URSSAF
                                    -- given ordering of ccontrib

  open ccontrib;
  LOOP
    fetch ccontrib into crec.r;

    -- Bug 2311582 commented for l_group_type to refer to the previous group_type
    --l_group_type :='FULL';

    --
    -- For URSSAF merge "A" rate and Pay Value into "D" records
    -- N.B. The "A" and "D" rows will be consecutive
    --
    IF ccontrib%FOUND and crec.r.contribution_type = 'URSSAF' THEN
      --
      IF substr(crec.r.contribution_code,7,1) = 'D'
      AND prec.r.contribution_code = substr(crec.r.contribution_code,1,6)||'A'
      AND prec.r.base              = crec.r.base
      AND prec.r.source_asg_action_id = crec.r.source_asg_action_id
      AND prec.r.retro_process_path   = crec.r.retro_process_path
      THEN
        crec.r.rate := crec.r.rate + prec.r.rate;
        crec.r.pv   := crec.r.pv   + prec.r.pv;
        prec.r.base := 0;
        prec.r.pv   := 0;
      END IF;

      -- If the previous code (1st 6 chars) is the same as the current
      -- code or if the code ends in A then need to use the full
      -- contribion code for grouping, otherwise use partial code

      -- Bug 2311582 added l_group_type = 'FULL'

      IF   (substr(prec.r.contribution_code,1,6)=
            substr(crec.r.contribution_code,1,6) AND prec.group_type = 'FULL')
      OR  substr(crec.r.contribution_code,7,1) = 'A'
      THEN
        crec.group_type := 'FULL';
      ELSE
        crec.group_type := 'PARTIAL';
      END IF;
    END IF; -- URSSAF processing
    --
    IF prec.r.contribution_code is not null THEN
      -- Not first time through loop so archive the previous record
      IF prec.r.contribution_type in ('URSSAF','ASSEDIC') THEN
        l_page_type := prec.r.contribution_type;
        l_subpage_identifier := fnd_number.number_to_canonical(
                                  l_establishment_id);
      ELSIF prec.r.contribution_type IN ('AGIRC','ARRCO') THEN
        l_page_type := 'PENSION';
        -- Determine Company Pension Provider ID for Pension contribs
        IF g_estab_pens_provs.estab_id is null
        OR g_estab_pens_provs.estab_id <> l_establishment_id THEN
          g_estab_pens_provs.estab_id := l_establishment_id;
          g_estab_pens_provs.pens_provs.delete;
        END IF;
        l_Order_Number := to_number(substr(prec.r.contribution_code,2,1));
        IF NOT g_estab_pens_provs.pens_provs.exists(l_Order_Number) THEN
          OPEN cestpens(to_char(l_Order_Number));
          FETCH cestpens INTO g_estab_pens_provs.pens_provs(l_Order_Number);
          IF cestpens%notfound THEN
            hr_utility.set_message(801, 'PAY_75087_DUCS_PENS_PROV');
            FND_FILE.NEW_LINE(fnd_file.log, 1);
            FND_FILE.PUT_LINE(fnd_file.log,hr_utility.get_message);
          END IF;
          CLOSE cestpens;
          --
        END IF;
        l_subpage_identifier := g_estab_pens_provs.pens_provs(l_Order_Number);
      END IF;

      pay_action_information_api.create_action_information (
        p_action_information_id       => l_action_info_id
      , p_action_context_id           => p_assignment_action_id
      , p_action_context_type         => 'AAP'
      , p_object_version_number       => l_ovn
      , p_action_information_category => 'FR_DUCS_ACTION_CONTRIB_INFO'
      , p_action_information1         => l_subpage_identifier
      , p_action_information2         => l_page_type
      , p_action_information3         => prec.r.contribution_type
      , p_action_information4         => prec.r.contribution_code
      , p_action_information5    => fnd_number.number_to_canonical(prec.r.base)
      , p_action_information6    => fnd_number.number_to_canonical(prec.r.rate)
      , p_action_information7    => fnd_number.number_to_canonical(prec.r.pv)
      , p_action_information8    => prec.group_type);

    END IF;
    EXIT WHEN ccontrib%NOTFOUND;
    prec := crec;
  END LOOP;
  close ccontrib;


  hr_utility.set_location('Leaving ' || l_proc, 100);

END retrieve_contributions;

---------------------------------------------------------------------
-- Summary process
---------------------------------------------------------------------
---------------------------------------------------------------------
-- FUNCTION split_payment
---------------------------------------------------------------------

FUNCTION split_payment(
                p_total_payment     in  number
               ,p_payment_type      in  varchar2
               ,p_limit             in  number
               ,p_remaining_amount  in out nocopy number) return number IS

l_payment number:=0;

BEGIN


   IF  p_payment_type = 'REMAINDER' THEN
       l_payment:=p_remaining_amount;
   ELSIF p_payment_type = 'AMOUNT' THEN
       l_payment:=least(p_limit,p_remaining_amount);
   ELSE
       l_payment:=least(p_total_payment*p_limit/100,p_remaining_amount);
   END IF;

   p_remaining_amount := p_remaining_amount - l_payment;

   return (l_payment);


END split_payment;

---------------------------------------------------------------------
-- PROCEDURE  get_lookup
---------------------------------------------------------------------

PROCEDURE get_lookup(
                     p_lookup_type    in varchar2
                    ,p_lookup_code    in varchar2
                    ,p_lookup_meaning out nocopy varchar2
                    ,p_lookup_tag     out nocopy varchar2) IS

  CURSOR csr_get_lookup IS
  SELECT meaning,tag
  FROM   fnd_lookup_values
  WHERE  lookup_type=p_lookup_type
  AND    lookup_code=p_lookup_code
  AND    language = userenv('LANG')
  AND    view_application_id = 3;


BEGIN

  OPEN csr_get_lookup;
  FETCH csr_get_lookup INTO p_lookup_meaning,p_lookup_tag;

  CLOSE csr_get_lookup;

END get_lookup;

---------------------------------------------------------------------
-- get_count_emps
---------------------------------------------------------------------

PROCEDURE get_count_emps(p_payroll_action_id in  number
                        ,p_page_identifier   in  number
                        ,p_page_type         in  varchar2
                        ,p_contribution_emps out nocopy number
                        ,p_month_end_male    out nocopy number
                        ,p_month_end_female  out nocopy number
                        ,p_month_end_total   out nocopy number
                        ,p_total_actions     out nocopy number) IS


l_male_count    number:=0;
l_female_count  number:=0;
l_total_count   number:=0;
l_actions_count number:=0;
l_sex           varchar2(2);
l_page_id_chr   pay_action_information.action_information1%TYPE:=
                   fnd_number.number_to_canonical(p_page_identifier);

CURSOR cur_per IS
SELECT distinct paa.person_id
FROM   pay_action_information pai
      ,pay_assignment_actions pac
      ,per_all_assignments_f  paa
WHERE  pac.payroll_action_id=p_payroll_action_id
       and pai.action_information_category = 'FR_DUCS_ACTION_CONTRIB_INFO'
       and pai.action_information1 = l_page_id_chr
       and pai.action_information2 = p_page_type
       and pai.action_context_id =pac.assignment_action_id
       and paa.assignment_id=pac.assignment_id;

CURSOR cur_sex(l_person_id number) IS
SELECT per.sex
FROM   per_all_people_f per
WHERE  per.person_id = l_person_id;

CURSOR cur_asg_count IS
SELECT count(distinct pac.assignment_id),
       count(distinct pac.assignment_action_id)
FROM   pay_action_information pai
      ,pay_assignment_actions pac
WHERE  pac.payroll_action_id=p_payroll_action_id
       and pai.action_information_category = 'FR_DUCS_ACTION_CONTRIB_INFO'
       and pai.action_information1 = l_page_id_chr
       and pai.action_information2 = p_page_type
       and pai.action_context_id =pac.assignment_action_id;

BEGIN

FOR rec_per IN cur_per LOOP

        l_total_count:=l_total_count + 1;

        OPEN cur_sex(rec_per.person_id);
        FETCH cur_sex INTO l_sex;
        CLOSE cur_sex;

        IF l_sex='M' THEN
           l_male_count:=l_male_count + 1;
        ELSE
           l_female_count:=l_female_count + 1;
        END IF;

END LOOP;

OPEN  cur_asg_count;
FETCH cur_asg_count INTO p_contribution_emps, p_total_actions;
CLOSE cur_asg_count;

p_month_end_total   := l_total_count;
p_month_end_male    := l_male_count;
p_month_end_female  := l_female_count;


END get_count_emps;
--
---------------------------------------------------------------------
--PROCEDURE Process_payment
---------------------------------------------------------------------
PROCEDURE process_payment(
                         p_name           in varchar2
                        ,p_total_payment  in number
                        ,p_payment1_type  in varchar2
                        ,p_payment1_limit in number
                        ,p_payment1_value out nocopy number
                        ,p_payment2_type  in varchar2
                        ,p_payment2_limit in number
                        ,p_payment2_value out nocopy number
                        ,p_payment3_type  in varchar2
                        ,p_payment3_limit in number
                        ,p_payment3_value out nocopy number) IS

-- Local Variable
l_proc                   VARCHAR2(40):= g_package||' process_payment';

l_remaining_amount       number;

BEGIN


  l_remaining_amount := p_total_payment;

  IF p_payment1_type IS NOT null and
     (p_payment1_type = 'REMAINDER' OR
      p_payment1_limit IS NOT null) THEN
     p_payment1_value := split_payment( p_total_payment
                                      , p_payment1_type
                                      , p_payment1_limit
                                      , l_remaining_amount);


  END IF;



  IF p_payment2_type IS NOT null and
     (p_payment2_type = 'REMAINDER' OR
      p_payment2_limit IS NOT null) THEN
     p_payment2_value := split_payment( p_total_payment
                                      , p_payment2_type
                                      , p_payment2_limit
                                      , l_remaining_amount);

  END IF;

  IF p_payment3_type IS NOT null and
     (p_payment3_type = 'REMAINDER' OR
      p_payment3_limit is not null) THEN
     p_payment3_value := split_payment( p_total_payment
                                      , p_payment3_type
                                      , p_payment3_limit
                                      , l_remaining_amount);

  END IF;

  IF l_remaining_amount > 0 THEN
     hr_utility.set_message(801, 'PAY_75088_DUCS_TOTAL_NOT_ALLOC');
     hr_utility.set_message_token(801,'ORGANIZATION',p_name);
     FND_FILE.NEW_LINE(fnd_file.log, 1);
     FND_FILE.PUT_LINE(fnd_file.log,hr_utility.get_message);
  END IF;


END process_payment;

---------------------------------------------------------------------
--PROCEDURE Process_contributions
---------------------------------------------------------------------
PROCEDURE process_contributions(p_payroll_action_id   in number
                               ,p_page_identifier     in number
                               ,p_page_type           in varchar2
                               ,p_total_contributions out nocopy number) IS


-- Local Variable
l_proc                   varchar2(40):= g_package||' process_contributions ';

l_total_contrib          number;
l_total_payment       number;
l_sort1_code          varchar2(30);
l_sort1_text1         varchar2(30);
l_sort1_text2         varchar2(30);
l_sort2_code          varchar2(30);
l_sort2_text1         varchar2(30);
l_sort2_text2         varchar2(30);
l_organization_id     varchar2(30);
l_pension_provider    varchar2(30);
l_pension_provider_id varchar2(30);

l_contribution_text  pay_action_information.action_information4%TYPE;
l_meaning            varchar2(80);
l_tag                pay_action_information.action_information4%TYPE;
l_pension_code       varchar2(80);
l_pay_value          number;

l_action_info_id     pay_action_information.action_information_id%TYPE;
l_ovn                pay_action_information.object_version_number%TYPE;

--
-- Cursors
--
CURSOR ccontrib_urssaf_assedic is
SELECT /*+ ORDERED */
  contrib.action_information1 subpage_identifier
, contrib.action_information3 contribution_type
, substr(contrib.action_information4,1,1)||
       translate(substr(contrib.action_information4,2,2), '1234567890',
               decode(contrib.action_information8
                     ,'FULL','1234567890'
                     ,'PARTIAL','XXXXXXXXXX'))||
         substr(contrib.action_information4,4,4) contribution_code
, round(sum(fnd_number.canonical_to_number(contrib.action_information5)))  base
, fnd_number.canonical_to_number(contrib.action_information6) rate
, sum(fnd_number.canonical_to_number(contrib.action_information7))    pay_value
, count(distinct assact.assignment_id) number_of_employees
FROM   pay_assignment_actions assact
,      pay_action_information contrib
WHERE
    assact.payroll_action_id in
   (SELECT payroll_action_id
    FROM   pay_payroll_actions payact
    ,      pay_action_information actinfo
    WHERE  payact.effective_date between g_period_start_date
                                     and g_effective_date
    and    payact.payroll_action_id = actinfo.action_context_id
    and    actinfo.action_context_type = 'PA'
    and    actinfo.action_information_category = 'FR_DUCS_REFERENCE_INFO'
    and    payact.report_type = 'DUCS_ARCHIVE'
    and    payact.report_qualifier = 'FR'
    and    payact.report_category = 'DUCS_ARCHIVE')
and   assact.assignment_action_id = contrib.action_context_id
and   contrib.action_context_type = 'AAP'
and   contrib.action_information1 = to_char(p_page_identifier)
and   contrib.action_information2 = p_page_type
and   contrib.action_information_category = 'FR_DUCS_ACTION_CONTRIB_INFO'
GROUP BY contrib.action_information1
,        contrib.action_information3
,      substr(contrib.action_information4,1,1)||
       translate(substr(contrib.action_information4,2,2), '1234567890',
               decode(contrib.action_information8   ,'FULL','1234567890'
                     ,'PARTIAL','XXXXXXXXXX'))||
         substr(contrib.action_information4,4,4)
,        fnd_number.canonical_to_number(contrib.action_information6)
ORDER BY contrib.action_information1 ,contrib.action_information3;

CURSOR ccontrib_pension is
SELECT /*+ ORDERED */
  contrib.action_information1 subpage_identifier
, contrib.action_information3 contribution_type
, substr(contrib.action_information4,1,1)||
       translate(substr(contrib.action_information4,2,2), '1234567890',
               decode(contrib.action_information8
                     ,'FULL','1234567890'
                     ,'PARTIAL','XXXXXXXXXX'))||
         substr(contrib.action_information4,4,4) contribution_code
, round(sum(fnd_number.canonical_to_number(contrib.action_information5))) base
, fnd_number.canonical_to_number(contrib.action_information6) rate
, sum(fnd_number.canonical_to_number(contrib.action_information7)) pay_value
, count(distinct assact.assignment_id) number_of_employees
FROM   pay_payroll_actions    payact
,      pay_assignment_actions assact
,      pay_action_information contrib
WHERE  assact.payroll_action_id = payact.payroll_action_id
and    payact.report_type = 'DUCS_ARCHIVE'
and    payact.report_qualifier = 'FR'
and    payact.report_category = 'DUCS_ARCHIVE'
and    payact.effective_date between g_period_start_date and g_effective_date
and    payact.business_group_id = g_business_group_id
and    contrib.action_context_type = 'AAP'
and    assact.assignment_action_id = contrib.action_context_id
and    ((contrib.action_information1 in
         (SELECT pens_prv.org_information1
          FROM   hr_organization_information pens_prv
          WHERE  pens_prv.org_information_id = p_page_identifier
          AND    pens_prv.org_information_context = 'FR_COMP_PE_PRVS'))
        or
        (contrib.action_information1 in
         (SELECT fnd_number.number_to_canonical(ind_pens_prv.organization_id)
          FROM   hr_organization_information ind_pens_prv
          ,      hr_organization_information pens_grp
          WHERE  pens_grp.org_information_id = p_page_identifier
             AND pens_grp.org_information_context = 'FR_COMP_PE_PRVS'
             AND ind_pens_prv.org_information3 = pens_grp.org_information1
             AND ind_pens_prv.org_information_context = 'FR_PE_PRV_INFO')))
and   contrib.action_information2 = p_page_type
and   contrib.action_information_category = 'FR_DUCS_ACTION_CONTRIB_INFO'
GROUP BY contrib.action_information1
,        contrib.action_information3
,      substr(contrib.action_information4,1,1)||
       translate(substr(contrib.action_information4,2,2), '1234567890',
               decode(contrib.action_information8   ,'FULL','1234567890'
                     ,'PARTIAL','XXXXXXXXXX'))||
         substr(contrib.action_information4,4,4)
,        fnd_number.canonical_to_number(contrib.action_information6)
ORDER BY contrib.action_information1, contrib.action_information3;

/**/

BEGIN

l_total_contrib         := 0;
l_total_payment         := 0;
l_sort1_code            := null;
l_sort1_text1           := null;
l_sort1_text2           := null;
l_sort2_code            := null;
l_sort2_text1           := null;
l_sort2_text2           := null;
l_organization_id       := null;
l_pension_provider      := null;
l_pension_provider_id   := null;
l_pension_code          := null;


IF p_page_type in ('URSSAF','ASSEDIC') then

FOR  rec_contr IN ccontrib_urssaf_assedic LOOP



           -- Get Contribution Text
           IF rec_contr.contribution_type = 'URSSAF' THEN
              -- Last 4 chars of contribution code define the text
              l_contribution_text := hr_general.decode_lookup('FR_URSSAF_CONTRI_CODE'
                                    ,substr(rec_contr.contribution_code,4,4));

           ELSIF rec_contr.contribution_type = 'ASSEDIC' THEN -- ASSEDIC
              -- Last 3 chars of contribution code define the text
              pay_fr_ducs.get_lookup('FR_ASSEDIC_CONTRI_CODE'
                        ,substr(rec_contr.contribution_code,5,3)
                        ,l_meaning
                        ,l_tag);
              l_contribution_text := l_meaning;


              l_sort1_code  := substr(l_tag,instr(l_tag,'=')+1,instr(l_tag,',')-instr(l_tag,'=',-1)-1);
              l_sort1_text1 :=substr(l_tag,instr(l_tag,',')+1,INSTR(l_tag,',',-1,1)-instr(l_tag,',',-1,2)-1);
              l_sort1_text2 :=substr(l_tag,instr(l_tag,',',-1)+1);


           END IF;

           -- Bug 2311582

	   IF NVL(rec_contr.base,0) <> 0 AND NVL(rec_contr.rate,0) <> 0 THEN
	   	l_pay_value := rec_contr.base * (rec_contr.rate/100);
	   ELSE
	   	l_pay_value := rec_contr.pay_value;
	   END IF;

	   l_pay_value := round(l_pay_value,2);


	   pay_action_information_api.create_action_information (
	     p_action_information_id       =>  l_action_info_id
	   , p_action_context_id           =>  p_payroll_action_id
	   , p_action_context_type         =>  'PA'
	   , p_object_version_number       =>  l_ovn
	   , p_action_information_category =>  'FR_DUCS_CONTRIB_INFO'
	   , p_action_information1         => p_page_identifier
	   , p_action_information2         => p_page_type
	   , p_action_information3         => rec_contr.contribution_code
	   , p_action_information4         => l_contribution_text
	   , p_action_information5         => l_sort1_code
	   , p_action_information6         => l_sort1_text1
	   , p_action_information7         => l_sort1_text2
	   , p_action_information8         => l_sort2_code
	   , p_action_information9         => l_sort2_text1
	   , p_action_information10        => l_sort2_text2
	   , p_action_information11        => fnd_number.number_to_canonical(
                                                 rec_contr.number_of_employees)
	   , p_action_information12        => fnd_number.number_to_canonical(
                                                                rec_contr.base)
	   , p_action_information13        => fnd_number.number_to_canonical(
                                                                rec_contr.rate)
	   , p_action_information14        => fnd_number.number_to_canonical(
                                                                 l_pay_value));

	    -- Keep running total

           l_total_contrib := l_total_contrib + l_pay_value;


  END LOOP;


  ELSE 		-- PENSION
                -- Concatenate last 5 chars of contrib code with
                -- TAG value from FR_EMPLOYEE_PENSION
                -- and FR_PENSION_CODE meaning for code of last 2 chars
                --
      FOR  rec_contr IN ccontrib_pension LOOP



                pay_fr_ducs.get_lookup('FR_PENSION_CATEGORY'
                          ,substr(rec_contr.contribution_code,3,3)
                          ,l_meaning
                          ,l_tag);
                l_tag:=replace(l_tag,'N/C','NON CADRES');

                -- if the code exists in FR_USER_PENSION_CODE first
                l_pension_code := hr_general.decode_lookup('FR_USER_PENSION_CONTRIB_CODE'
                                      ,substr(rec_contr.contribution_code,6,2));

                -- If user code is null then use
                IF l_pension_code IS NULL THEN
                    l_pension_code := hr_general.decode_lookup('FR_PENSION_CONTRI_CODE'
                                      ,substr(rec_contr.contribution_code,6,2));
                END IF;


                l_contribution_text :=  substr(rec_contr.contribution_code,3,5) || ' '
                			|| l_tag || ' ' || l_pension_code;



                -- if pension provider is different from last row retrieved
                -- then get new pension provider details otherwise
                -- reuse existing details

                IF rec_contr.subpage_identifier = l_pension_provider_id then
                   NULL;
                ELSE
                   l_pension_provider_id := rec_contr.subpage_identifier;
                   BEGIN
                      SELECT org_information1
                      INTO   l_pension_provider
                      FROM   hr_organization_information
                      WHERE  organization_id = l_pension_provider_id
                             AND org_information_context = 'FR_PE_PRV_INFO';
                   EXCEPTION
                     WHEN no_data_found THEN
                       hr_utility.set_message(801,'PAY_75087_DUCS_PENS_PROV');
                       FND_FILE.NEW_LINE(fnd_file.log, 1);
           	       FND_FILE.PUT_LINE(fnd_file.log,hr_utility.get_message);
                   END;
                END IF;

                l_sort1_code  := rec_contr.subpage_identifier;
                l_sort1_text2 := l_pension_provider;

                l_sort2_code  := rec_contr.contribution_type;
                l_sort2_text2 := rec_contr.contribution_type;

                -- Bug 2311582

                IF NVL(rec_contr.base,0) <> 0 AND NVL(rec_contr.rate,0) <> 0 THEN
			l_pay_value := rec_contr.base * (rec_contr.rate/100);
		ELSE
			l_pay_value := rec_contr.pay_value;
	   	END IF;

	   	l_pay_value:=round(l_pay_value,2);

                pay_action_information_api.create_action_information (
		     p_action_information_id       =>  l_action_info_id
		   , p_action_context_id           =>  p_payroll_action_id
		   , p_action_context_type         =>  'PA'
		   , p_object_version_number       =>  l_ovn
		   , p_action_information_category =>  'FR_DUCS_CONTRIB_INFO'
		   , p_action_information1         => p_page_identifier
		   , p_action_information2         => p_page_type
		   , p_action_information3         => rec_contr.contribution_code
		   , p_action_information4         => l_contribution_text
		   , p_action_information5         => l_sort1_code
		   , p_action_information6         => l_sort1_text1
		   , p_action_information7         => l_sort1_text2
		   , p_action_information8         => l_sort2_code
		   , p_action_information9         => l_sort2_text1
		   , p_action_information10        => l_sort2_text2
		   , p_action_information11 => fnd_number.number_to_canonical(
                                                 rec_contr.number_of_employees)
		   , p_action_information12 => fnd_number.number_to_canonical(
                                                                rec_contr.base)
		   , p_action_information13 => fnd_number.number_to_canonical(
                                                                rec_contr.rate)
   		   , p_action_information14 => fnd_number.number_to_canonical(
                                                                 l_pay_value));

   		   l_total_contrib := l_total_contrib + l_pay_value;
   	END LOOP;

     END IF;


  p_total_contributions := l_total_contrib;


END process_contributions;

------------------------------------------------------------------------
--deinitialize_code section
------------------------------------------------------------------------

PROCEDURE deinitialize_code(p_payroll_action_id    in number) IS

l_proc    VARCHAR2(60):= g_package||' deinitialize_code ';
duplicate EXCEPTION;

-- Local Variable
l_payroll_action_id     pay_payroll_actions.payroll_action_id%TYPE;

l_year			varchar2(10);
l_quarter		varchar2(10);
l_month			varchar2(10);
l_mm			varchar2(12);
l_miq			varchar2(12);
l_date_to		varchar2(12);
l_date_from		varchar2(12);
l_period_description	varchar2(30);
l_period_code		varchar2(30);
l_currency 		varchar2(10);
l_currency_code 	varchar2(10);
l_currency_number 	varchar2(10);

l_action_info_id        pay_action_information.action_information_id%TYPE;
l_ovn                   pay_action_information.object_version_number%TYPE;

l_org_information_id    number;
l_object_version_number	number;

l_payment_1_account	hr_organization_information.org_information3%TYPE;
l_payment_1_type	hr_organization_information.org_information4%TYPE;
l_payment_1_limit	hr_organization_information.org_information5%TYPE;
l_payment_2_account	hr_organization_information.org_information6%TYPE;
l_payment_2_type	hr_organization_information.org_information7%TYPE;
l_payment_2_limit	hr_organization_information.org_information8%TYPE;
l_payment_3_account	hr_organization_information.org_information9%TYPE;
l_payment_3_type	hr_organization_information.org_information10%TYPE;
l_payment_3_limit	hr_organization_information.org_information11%TYPE;
l_advances		number;
l_regularization	number;
l_payment_1_acc_no     varchar2(60);
l_payment_2_acc_no     varchar2(60);
l_payment_3_acc_no     varchar2(60);

l_total_contributions   number;
l_total_payment		number;

l_contribution_emps 	number;
l_month_end_male	number;
l_month_end_female	number;
l_month_end_total	number;
l_total_actions		number;

l_payment_1_val	        number;
l_payment_2_val         number;
l_payment_3_val         number;

l_Declaration_Due       date;
l_Latest_Declaration    date;
l_Last_Contribution     date;
l_Payment_Date	        date;

-----------
-- Cursor
-----------

CURSOR  c_existing_archive (p_company_id_chr in varchar2) is
SELECT  payact.payroll_action_id
FROM    pay_payroll_actions payact
       ,pay_action_information ref_actinfo
WHERE   payact.payroll_action_id = ref_actinfo.action_context_id
  and   ref_actinfo.action_information_category = 'FR_DUCS_REFERENCE_INFO'
  and   ref_actinfo.action_context_type = 'PA'
  and   ref_actinfo.action_information1 = p_company_id_chr
  and   ref_actinfo.action_information2 = l_period_code
  and   payact.business_group_id = g_business_group_id
  and   payact.payroll_action_id <> p_payroll_action_id;


CURSOR csr_company is
SELECT substr(o.name,1,150) company_name
,      substr(l.address_line_1,1,150) company_address_line_1
,      substr(l.address_line_2,1,150) company_address_line_2
,      substr(l.region_3,1,150)       company_address_line_3
,      l.town_or_city company_address_line_4
,      l.telephone_number_1             company_telephone
,      l.telephone_number_2             company_fax
,      rep_estab_info.org_information2  rep_estab_SIRET
,      rep_estab_info.org_information3  rep_estab_NAF
,      comp_rep_info.ORG_INFORMATION1	Declaration_Due_Offset
,      comp_rep_info.ORG_INFORMATION2	Latest_Declaration_Offset
,      comp_rep_info.ORG_INFORMATION3	Last_Contribution_Offset
,      comp_rep_info.ORG_INFORMATION4	Payment_Date_Offset
,      comp_rep_info.ORG_INFORMATION5	Activities_Ceased_Date
,      comp_rep_info.ORG_INFORMATION6	No_Employees_Date
,      comp_rep_info.ORG_INFORMATION7	Activities_Suspended
,      comp_rep_info.ORG_INFORMATION8	Keep_Account_Open
,      comp_rep_info.ORG_INFORMATION9	Administrator_Line_1
,      comp_rep_info.ORG_INFORMATION10	Administrator_Line_2
,      comp_rep_info.ORG_INFORMATION11	Administrator_Telephone_Number
,      comp_rep_info.ORG_INFORMATION12	Administrator_FAX_Number
FROM   hr_all_organization_units o
,      hr_locations l
,      hr_organization_information comp_info
,      hr_organization_information rep_estab_info
,      hr_organization_information comp_rep_info
WHERE  o.organization_id = g_company_id
       and   o.location_id = l.location_id (+)
       and   comp_info.organization_id (+) = o.organization_id
       and   comp_info.org_information_context (+) = 'FR_COMP_INFO'
       and   rep_estab_info.organization_id (+) =
  		 to_number(comp_info.org_information10)
       and   rep_estab_info.org_information_context (+) = 'FR_ESTAB_INFO'
       and   comp_rep_info.organization_id (+) = o.organization_id
       and   comp_rep_info.org_information_context (+) = 'FR_COMP_REPORTING_INFO';


-- 4312297 Removed to_char on urssaf.organization_id and
--           assedic.organization_id as that was disabling the index and
--           causing FTS.
--         Used hr_locations_all rather than hr_locations
CURSOR csr_estab (p_company_id_chr in varchar2) is
SELECT estab_info.organization_id  establishment_id
,      estab_info.org_information2 estab_SIRET
,      estab_info.org_information3 estab_NAF
--
-- Establishment Reporting Details
--
,      estab_rep_info.ORG_INFORMATION1	Activities_Ceased_Date
,      estab_rep_info.ORG_INFORMATION2	No_Employees_Date
,      estab_rep_info.ORG_INFORMATION3	Activities_Suspended
,      estab_rep_info.ORG_INFORMATION4	Keep_Account_Open
--
-- URSSAF Details
--
,      urssaf.organization_id urssaf_id
,      substr(urssaf.name,1,150) urssaf_name
,      estab_urssaf_info.org_information2  estab_urssaf_ID
,      estab_urssaf_info.ORG_INFORMATION6  U_Declaration_Due_Offset
,      estab_urssaf_info.ORG_INFORMATION7  U_Latest_Declaration_Offset
,      estab_urssaf_info.ORG_INFORMATION8  U_Last_Contribution_Offset
,      estab_urssaf_info.ORG_INFORMATION9  U_Payment_Date_Offset
,      estab_urssaf_info.ORG_INFORMATION10 URSSAF_Payment_1_Account
,      estab_urssaf_info.ORG_INFORMATION11 URSSAF_Payment_1_Type
,      estab_urssaf_info.ORG_INFORMATION12 URSSAF_Payment_1_Limit
,      estab_urssaf_info.ORG_INFORMATION13 URSSAF_Payment_2_Account
,      estab_urssaf_info.ORG_INFORMATION14 URSSAF_Payment_2_Type
,      estab_urssaf_info.ORG_INFORMATION15 URSSAF_Payment_2_Limit
,      estab_urssaf_info.ORG_INFORMATION16 URSSAF_Payment_3_Account
,      estab_urssaf_info.ORG_INFORMATION17 URSSAF_Payment_3_Type
,      estab_urssaf_info.ORG_INFORMATION18 URSSAF_Payment_3_Limit
,      substr(urssaf_loc.address_line_1,1,150) urssaf_address_line_1
,      substr(urssaf_loc.address_line_2,1,150) urssaf_address_line_2
,      substr(urssaf_loc.region_3,1,150)       urssaf_address_line_3
,      urssaf_loc.postal_code||' '||urssaf_loc.town_or_city urssaf_address_line_4
--
-- ASSEDIC Details
--
,      substr(assedic.name,1,150) assedic_name
,      estab_assedic_info.org_information2  estab_ASSEDIC_ID
,      estab_assedic_info.ORG_INFORMATION4  A_Declaration_Due_Offset
,      estab_assedic_info.ORG_INFORMATION5  A_Latest_Declaration_Offset
,      estab_assedic_info.ORG_INFORMATION6  A_Last_Contribution_Offset
,      estab_assedic_info.ORG_INFORMATION7  A_Payment_Date_Offset
,      estab_assedic_info.ORG_INFORMATION8  ASSEDIC_Payment_1_Account
,      estab_assedic_info.ORG_INFORMATION9  ASSEDIC_Payment_1_Type
,      estab_assedic_info.ORG_INFORMATION10 ASSEDIC_Payment_1_Limit
,      estab_assedic_info.ORG_INFORMATION11 ASSEDIC_Payment_2_Account
,      estab_assedic_info.ORG_INFORMATION12 ASSEDIC_Payment_2_Type
,      estab_assedic_info.ORG_INFORMATION13 ASSEDIC_Payment_2_Limit
,      estab_assedic_info.ORG_INFORMATION14 ASSEDIC_Payment_3_Account
,      estab_assedic_info.ORG_INFORMATION15 ASSEDIC_Payment_3_Type
,      estab_assedic_info.ORG_INFORMATION16 ASSEDIC_Payment_3_Limit
,      substr(assedic_loc.address_line_1,1,150) assedic_address_line_1
,      substr(assedic_loc.address_line_2,1,150) assedic_address_line_2
,      substr(assedic_loc.region_3,1,150)       assedic_address_line_3
,      assedic_loc.postal_code||' '||assedic_loc.town_or_city assedic_address_line_4
FROM  hr_organization_information estab_info
,     hr_organization_information estab_urssaf_info
,     hr_organization_information estab_assedic_info
,     hr_organization_information estab_rep_info
,     hr_all_organization_units   urssaf
,     hr_all_organization_units   assedic
,     hr_locations_all            urssaf_loc
,     hr_locations_all            assedic_loc
WHERE estab_info.org_information1 = p_company_id_chr
and   estab_info.org_information_context = 'FR_ESTAB_INFO'
--
-- Get the URSSAF details
--
and   estab_info.organization_id = estab_urssaf_info.organization_id (+)
and   estab_urssaf_info.org_information_context (+) = 'FR_ESTAB_URSSAF'
and   estab_urssaf_info.org_information1 = urssaf.organization_id(+)
and   urssaf.location_id = urssaf_loc.location_id  (+)
--
-- Get the ASSEDIC details
--
and   estab_info.organization_id = estab_assedic_info.organization_id (+)
and   estab_assedic_info.org_information_context (+) = 'FR_ESTAB_ASSEDIC'
and   estab_assedic_info.org_information1 = assedic.organization_id(+)
and   assedic.location_id = assedic_loc.location_id  (+)
--
-- Get the Establishment Reporting details
--
and   estab_info.organization_id = estab_rep_info.organization_id (+)
and   estab_rep_info.org_information_context (+) = 'FR_ESTAB_REPORTING_INFO';

--
-- 3612082 Removed to_char on pens_prov.organization_id as it was disabling
--           the index and causing FTS.  Used ORDERED hint to ensure org_info
--           is visited 1st hence org_information1 is numeric prior to any
--           implicit conversion to number.
--         Used hr_locations_all rather than hr_locations
CURSOR csr_comp_pension_prvs is
SELECT /*+ ORDERED */
       pens_prov_info.org_information_id comp_pens_prov_id
,      pens_prov.organization_id pens_prov_id
,      substr(pens_prov.name,1,150) name
,      substr(pens_loc.address_line_1,1,150) address_line_1
,      substr(pens_loc.address_line_2,1,150) address_line_2
,      substr(pens_loc.region_3,1,150)       address_line_3
,      pens_loc.postal_code||' '||pens_loc.town_or_city address_line_4
,      pens_prov_info.ORG_INFORMATION3 Declaration_Due_Offset
,      pens_prov_info.ORG_INFORMATION4 Latest_Declaration_Offset
,      pens_prov_info.ORG_INFORMATION5 Last_Contribution_Offset
,      pens_prov_info.ORG_INFORMATION6 Payment_Date_Offset
,      pens_prov_info.ORG_INFORMATION7 Payment_1_Account
,      pens_prov_info.ORG_INFORMATION8 Payment_1_Type
,      pens_prov_info.ORG_INFORMATION9 Payment_1_Limit
,      pens_prov_info.ORG_INFORMATION10 Payment_2_Account
,      pens_prov_info.ORG_INFORMATION11 Payment_2_Type
,      pens_prov_info.ORG_INFORMATION12 Payment_2_Limit
,      pens_prov_info.ORG_INFORMATION13 Payment_3_Account
,      pens_prov_info.ORG_INFORMATION14 Payment_3_Type
,      pens_prov_info.ORG_INFORMATION15 Payment_3_Limit
FROM   hr_organization_information pens_prov_info
,      hr_all_organization_units   pens_prov
,      hr_locations_all            pens_loc
WHERE  pens_prov_info.organization_id         = g_company_id
and    pens_prov_info.org_information_context = 'FR_COMP_PE_PRVS'
and    pens_prov_info.org_information1        = pens_prov.organization_id
and    pens_prov.location_id                  = pens_loc.location_id (+);

--
-- Cursor to retrieve Bank Info
--
CURSOR cbank_info(l_org_method_id number) is
SELECT ea.segment2 || ea.segment3 || replace(ea.segment5,'-','')
FROM   pay_org_payment_methods_f opm
,      pay_external_accounts ea
WHERE  opm.org_payment_method_id  = l_org_method_id
AND    opm.external_account_id = ea.external_account_id
AND    g_effective_date between opm.effective_start_date
                            and opm.effective_end_date;

--
-- Cursor retrieve existing payroll archive records storing the payment options
--

CURSOR cpayment
	(p_page_identifier          number
	,p_page_type                varchar2) is
SELECT org_information7  payment_1_account
,      org_information8  payment_1_type
,      org_information9  payment_1_limit
,      org_information10  payment_2_account
,      org_information11 payment_2_type
,      org_information12  payment_2_limit
,      org_information13  payment_3_account
,      org_information14 payment_3_type
,      org_information15 payment_3_limit
,      fnd_number.canonical_to_number(org_information16) advances
,      fnd_number.canonical_to_number(org_information17) regularisation
FROM   hr_organization_information
WHERE  organization_id = g_company_id
       and   org_information_context = 'FR_COMP_PAYMENT_OVERRIDE'
       and   org_information2 = p_page_identifier
       and   org_information4 = p_page_type;



BEGIN

hr_utility.set_location('Entering ' || l_proc, 20);
if g_payroll_action_id is null
or g_payroll_action_id <> p_payroll_action_id
then
  pay_fr_ducs.get_all_parameters
        (p_payroll_action_id    => p_payroll_action_id
  	,p_business_group_id    => g_business_group_id
  	,p_company_id           => g_company_id
  	,p_period_type          => g_period_type
  	,p_period_start_date    => g_period_start_date
  	,p_effective_date       => g_effective_date
  	,p_english_base         => g_english_base
  	,p_english_rate         => g_english_rate
  	,p_english_pay_value    => g_english_pay_value
  	,p_english_contrib_code => g_english_contrib_code
  	,p_french_base          => g_french_base
  	,p_french_rate          => g_french_rate
  	,p_french_pay_value     => g_french_pay_value
  	,p_french_contrib_code  => g_french_contrib_code);
   g_payroll_action_id := p_payroll_action_id;
END IF;


l_year    := to_char(g_effective_date,'YYYY');
l_quarter := to_char(g_effective_date,'Q');
l_month   := replace(to_char(g_effective_date,'MONTH'),' ','');
l_mm      := to_char(g_effective_date,'MM');
l_miq     := to_char(to_number(l_mm)-(to_number(l_quarter)*3-2)+1);

l_date_to := to_char(g_effective_date,'DD/MM/YYYY');

IF g_period_type = 'CM' THEN

   l_date_from := '01/'||to_char(g_effective_date,'MM/YYYY');
   l_period_description := l_month||' '||l_year;

   l_period_code := substr(l_year,3,2)||l_quarter||l_miq;

ELSE
   l_date_from := '01/'||to_char(add_months(g_effective_date,-2), 'MM/YYYY');
   l_period_description := l_quarter||' '|| hr_general.decode_lookup('PROC_PERIOD_TYPE','Q')||' '||l_year;
   l_period_code := substr(l_year,3,2)||l_quarter||'0';
END IF;

l_currency := 'euro';
l_currency_code   := 'EUR';
l_currency_number := '9';

OPEN c_existing_archive(fnd_number.number_to_canonical(g_company_id));
FETCH c_existing_archive INTO l_payroll_action_id;
   IF c_existing_archive%found THEN

   	RAISE duplicate;

   END IF;
CLOSE c_existing_archive;



DELETE FROM pay_action_information
WHERE action_context_id = p_payroll_action_id
and   action_context_type = 'PA'
and   action_information_category IN
       ('FR_DUCS_COMP_INFO'
       ,'FR_DUCS_ESTAB_INFO'
       ,'FR_DUCS_PAGE_INFO'
       ,'FR_DUCS_REFERENCE_INFO'
       ,'FR_DUCS_CONTRIB_INFO');

-- Delete any payment override information from previous periods

DELETE FROM hr_organization_information
WHERE organization_id = g_company_id
AND   org_information_context = 'FR_COMP_PAYMENT_OVERRIDE'
AND   org_information1 <> p_payroll_action_id;



FOR rec_company IN csr_company loop

pay_action_information_api.create_action_information (
  p_action_information_id       =>  l_action_info_id
, p_action_context_id           =>  p_payroll_action_id
, p_action_context_type         =>  'PA'
, p_object_version_number       =>  l_ovn
, p_action_information_category =>  'FR_DUCS_COMP_INFO'
, p_action_information1         =>  fnd_number.number_to_canonical(
                                      g_company_id)
, p_action_information2         =>  rec_company.company_name
, p_action_information3         =>  rec_company.company_address_line_1
, p_action_information4         =>  rec_company.company_address_line_2
, p_action_information5         =>  rec_company.company_address_line_3
, p_action_information6         =>  rec_company.company_address_line_4
, p_action_information7         =>  rec_company.company_telephone
, p_action_information8         =>  rec_company.company_fax
, p_action_information9         =>  rec_company.rep_estab_SIRET
, p_action_information10         =>  rec_company.rep_estab_NAF
, p_action_information11         =>  null
, p_action_information12         =>  null
, p_action_information13         =>  rec_company.Activities_Ceased_Date
, p_action_information14         =>  rec_company.No_Employees_Date
, p_action_information15         =>  rec_company.Activities_Suspended
, p_action_information16         =>  rec_company.Keep_Account_Open);


-- Create a record in PAY_ACTION_INFORMATION --FR_DUCS_REFERENCE_INFO

pay_action_information_api.create_action_information (
  p_action_information_id       => l_action_info_id
, p_action_context_id           => p_payroll_action_id
, p_action_context_type         => 'PA'
, p_object_version_number       => l_ovn
, p_action_information_category => 'FR_DUCS_REFERENCE_INFO'
, p_action_information1         => fnd_number.number_to_canonical(g_company_id)
, p_action_information2         => l_period_code
, p_action_information3         => l_date_from
, p_action_information4         => l_date_to
, p_action_information5         => l_period_description
, p_action_information6         => l_currency
, p_action_information7         => l_currency_code
, p_action_information8         => l_currency_number
, p_action_information9         => rec_company.administrator_line_1
, p_action_information10        => rec_company.administrator_line_2
, p_action_information11        => rec_company.administrator_telephone_number
, p_action_information12        => rec_company.administrator_fax_number);

END LOOP;

------


FOR rec_estab IN csr_estab(fnd_number.number_to_canonical(g_company_id))
LOOP

  pay_action_information_api.create_action_information (
    p_action_information_id       =>  l_action_info_id
  , p_action_context_id           =>  p_payroll_action_id
  , p_action_context_type         =>  'PA'
  , p_object_version_number       =>  l_ovn
  , p_action_information_category =>  'FR_DUCS_ESTAB_INFO'
  , p_action_information1         =>  rec_estab.establishment_id
  , p_action_information2         =>  rec_estab.estab_SIRET
  , p_action_information3         =>  rec_estab.estab_NAF
  , p_action_information4         =>  rec_estab.Activities_Ceased_Date
  , p_action_information5         =>  rec_estab.No_Employees_Date
  , p_action_information6         =>  rec_estab.Activities_Suspended
  , p_action_information7         =>  rec_estab.Keep_Account_Open);

  --
  -- Insert the Establishment Archive record
  --

  -- Process URSSAF contributions
  pay_fr_ducs.process_contributions
    (p_payroll_action_id    => p_payroll_action_id
    ,p_page_identifier      => rec_estab.establishment_id
    ,p_page_type            => 'URSSAF'
    ,p_total_contributions  => l_total_contributions
     );


  -- Get existing payment options (from previous archive)

  OPEN cpayment(p_page_identifier      => rec_estab.establishment_id
               ,p_page_type            => 'URSSAF');

  FETCH cpayment INTO l_payment_1_account,
                      l_payment_1_type,
                      l_payment_1_limit,
                      l_payment_2_account,
                      l_payment_2_type,
                      l_payment_2_limit,
                      l_payment_3_account,
                      l_payment_3_type,
                      l_payment_3_limit,
                      l_advances,
                      l_regularization;

  IF cpayment%notfound THEN

    -- Initialise the Payment Options
    l_payment_1_account  := rec_estab.urssaf_payment_1_account;
    l_payment_1_type     := rec_estab.urssaf_payment_1_type;
    l_payment_1_limit    := rec_estab.urssaf_payment_1_limit;
    l_payment_2_account  := rec_estab.urssaf_payment_2_account;
    l_payment_2_type     := rec_estab.urssaf_payment_2_type;
    l_payment_2_limit    := rec_estab.urssaf_payment_2_limit;
    l_payment_3_account  := rec_estab.urssaf_payment_3_account;
    l_payment_3_type     := rec_estab.urssaf_payment_3_type;
    l_payment_3_limit    := rec_estab.urssaf_payment_3_limit;
    l_advances           := null;
    l_regularization     := null;

    hr_organization_api.create_org_information(
       p_effective_date                 => g_effective_date
      ,p_organization_id                => g_company_id
      ,p_org_info_type_code             => 'FR_COMP_PAYMENT_OVERRIDE'
      ,p_org_information1               => p_payroll_action_id
      ,p_org_information2               => rec_estab.establishment_id
      ,p_org_information3               => l_period_code
      ,p_org_information4               => 'URSSAF'
      ,p_org_information5               => null
      ,p_org_information6               => rec_estab.establishment_id
      ,p_org_information7               => l_payment_1_account
      ,p_org_information8               => l_payment_1_type
      ,p_org_information9               => l_payment_1_limit
      ,p_org_information10              => l_payment_2_account
      ,p_org_information11              => l_payment_2_type
      ,p_org_information12              => l_payment_2_limit
      ,p_org_information13              => l_payment_3_account
      ,p_org_information14              => l_payment_3_type
      ,p_org_information15              => l_payment_3_limit
      ,p_org_information_id             => l_org_information_id
      ,p_object_version_number          => l_object_version_number);

  END IF;


  CLOSE cpayment;

  l_advances        := round(nvl(l_advances,0),2);
  l_regularization  := round(nvl(l_regularization,0),2);
  l_total_payment := l_total_contributions + l_advances + l_regularization;



  pay_fr_ducs.process_payment
    (p_name           => rec_estab.assedic_name
    ,p_total_payment  => l_total_payment
    ,p_payment1_type  => l_payment_1_type
    ,p_payment1_limit => fnd_number.canonical_to_number(l_payment_1_limit)
    ,p_payment1_value => l_payment_1_val
    ,p_payment2_type  => l_payment_2_type
    ,p_payment2_limit => fnd_number.canonical_to_number(l_payment_2_limit)
    ,p_payment2_value => l_payment_2_val
    ,p_payment3_type  => l_payment_3_type
    ,p_payment3_limit => fnd_number.canonical_to_number(l_payment_3_limit)
    ,p_payment3_value => l_payment_3_val);



  pay_fr_ducs.get_count_emps(p_payroll_action_id
                  ,rec_estab.establishment_id
                  ,'URSSAF'
                  ,l_contribution_emps
                  ,l_month_end_male
                  ,l_month_end_female
                  ,l_month_end_total
                  ,l_total_actions);



  l_Declaration_Due    := g_effective_date
                        + nvl(to_number(rec_estab.U_Declaration_Due_Offset),0);
  l_Latest_Declaration := g_effective_date + nvl(to_number(
                                     rec_estab.U_Latest_Declaration_Offset),0);
  l_Last_Contribution  := g_effective_date + nvl(to_number(
                                      rec_estab.U_Last_Contribution_Offset),0);
  l_Payment_Date       := g_effective_date
                        + nvl(to_number(rec_estab.U_Payment_Date_Offset),0);

  l_payment_1_acc_no := null;
  l_payment_2_acc_no := null;
  l_payment_3_acc_no := null;
  IF l_payment_1_account IS NOT NULL THEN
    OPEN cbank_info(l_payment_1_account);
    FETCH cbank_info INTO l_payment_1_acc_no;
    CLOSE cbank_info;
  END IF;

  IF l_payment_2_account IS NOT NULL THEN
    OPEN cbank_info(l_payment_2_account);
    FETCH cbank_info INTO l_payment_2_acc_no;
    CLOSE cbank_info;
  END IF;

  IF l_payment_3_account IS NOT NULL THEN
    OPEN cbank_info(l_payment_3_account);
    FETCH cbank_info INTO l_payment_3_acc_no;
    CLOSE cbank_info;
  END IF;


  pay_action_information_api.create_action_information (
     p_action_information_id       => l_action_info_id
    ,p_action_context_id           => p_payroll_action_id
    ,p_action_context_type         => 'PA'
    ,p_object_version_number       => l_ovn
    ,p_action_information_category => 'FR_DUCS_PAGE_INFO'
    ,p_action_information1         => rec_estab.establishment_id
    ,p_action_information2  => 'URSSAF'
    ,p_action_information3  => rec_estab.urssaf_id
    ,p_action_information4  => rec_estab.urssaf_name
    ,p_action_information5  => rec_estab.estab_urssaf_id
    ,p_action_information6  => null
    ,p_action_information7  => rec_estab.urssaf_address_line_1
    ,p_action_information8  => rec_estab.urssaf_address_line_2
    ,p_action_information9  => rec_estab.urssaf_address_line_3
    ,p_action_information10 => rec_estab.urssaf_address_line_4
    ,p_action_information11 => l_payment_1_acc_no
    ,p_action_information12 => fnd_number.number_to_canonical(l_payment_1_val)
    ,p_action_information13 => l_payment_2_acc_no
    ,p_action_information14 => fnd_number.number_to_canonical(l_payment_2_val)
    ,p_action_information15 => l_payment_3_acc_no
    ,p_action_information16 => fnd_number.number_to_canonical(l_payment_3_val)
    ,p_action_information17 => to_char(l_Declaration_Due,'dd/mm/yyyy')
    ,p_action_information18 => to_char(l_Latest_Declaration,'dd/mm/yyyy')
    ,p_action_information19 => to_char(l_Last_Contribution,'dd/mm/yyyy')
    ,p_action_information20 => to_char(l_Payment_Date,'dd/mm/yyyy')
    ,p_action_information21 => l_contribution_emps
    ,p_action_information22 => l_month_end_male
    ,p_action_information23 => l_month_end_female
    ,p_action_information24 => l_month_end_total
    ,p_action_information25 => fnd_number.number_to_canonical(
                                                         l_total_contributions)
    ,p_action_information26 => fnd_number.number_to_canonical(l_advances)
    ,p_action_information27 => fnd_number.number_to_canonical(l_regularization)
    ,p_action_information28 => fnd_number.number_to_canonical(l_total_payment)
    ,p_action_information29 => l_total_actions);

  -- AASEDIC

  pay_fr_ducs.process_contributions
        (p_payroll_action_id    => p_payroll_action_id
        ,p_page_identifier      => rec_estab.establishment_id
        ,p_page_type            => 'ASSEDIC'
        ,p_total_contributions  => l_total_contributions
         );


  -- Get existing payment options (from previous archive)
  OPEN cpayment(p_page_identifier      => rec_estab.establishment_id
               ,p_page_type            => 'ASSEDIC');

  FETCH cpayment INTO l_payment_1_account,
                      l_payment_1_type,
                      l_payment_1_limit,
                      l_payment_2_account,
                      l_payment_2_type,
                      l_payment_2_limit,
                      l_payment_3_account,
                      l_payment_3_type,
                      l_payment_3_limit,
                      l_advances,
                      l_regularization;
  IF cpayment%notfound THEN

    -- Initialise the Payment Options
    l_payment_1_account  := rec_estab.assedic_payment_1_account;
    l_payment_1_type     := rec_estab.assedic_payment_1_type;
    l_payment_1_limit    := rec_estab.assedic_payment_1_limit;
    l_payment_2_account  := rec_estab.assedic_payment_2_account;
    l_payment_2_type     := rec_estab.assedic_payment_2_type;
    l_payment_2_limit    := rec_estab.assedic_payment_2_limit;
    l_payment_3_account  := rec_estab.assedic_payment_3_account;
    l_payment_3_type     := rec_estab.assedic_payment_3_type;
    l_payment_3_limit    := rec_estab.assedic_payment_3_limit;
    l_advances           := null;
    l_regularization     := null;

    hr_organization_api.create_org_information (
	     p_effective_date                 => g_effective_date
	    ,p_organization_id                => g_company_id
	    ,p_org_info_type_code             => 'FR_COMP_PAYMENT_OVERRIDE'
	    ,p_org_information1               => p_payroll_action_id
	    ,p_org_information2               => rec_estab.establishment_id
	    ,p_org_information3               => l_period_code
	    ,p_org_information4               => 'ASSEDIC'
	    ,p_org_information5               => null
	    ,p_org_information6               => rec_estab.establishment_id
	    ,p_org_information7               => l_payment_1_account
	    ,p_org_information8               => l_payment_1_type
	    ,p_org_information9               => l_payment_1_limit
	    ,p_org_information10              => l_payment_2_account
	    ,p_org_information11              => l_payment_2_type
	    ,p_org_information12              => l_payment_2_limit
	    ,p_org_information13              => l_payment_3_account
	    ,p_org_information14              => l_payment_3_type
	    ,p_org_information15              => l_payment_3_limit
	    ,p_org_information_id             => l_org_information_id
            ,p_object_version_number          => l_object_version_number);


  END IF;

  CLOSE cpayment;

  --
  -- Determine how ASSEDIC payments are to be split across bank accounts
  --
  l_advances        := round(nvl(l_advances,0),2);
  l_regularization  := round(nvl(l_regularization,0),2);
  l_total_payment := l_total_contributions + l_advances + l_regularization;

  pay_fr_ducs.process_payment
    (p_name           => rec_estab.assedic_name
    ,p_total_payment  => l_total_payment
    ,p_payment1_type  => l_payment_1_type
    ,p_payment1_limit => fnd_number.canonical_to_number(l_payment_1_limit)
    ,p_payment1_value => l_payment_1_val
    ,p_payment2_type  => l_payment_2_type
    ,p_payment2_limit => fnd_number.canonical_to_number(l_payment_2_limit)
    ,p_payment2_value => l_payment_2_val
    ,p_payment3_type  => l_payment_3_type
    ,p_payment3_limit => fnd_number.canonical_to_number(l_payment_3_limit)
    ,p_payment3_value => l_payment_3_val);



  pay_fr_ducs.get_count_emps(p_payroll_action_id
                      ,rec_estab.establishment_id
                      ,'ASSEDIC'
                      ,l_contribution_emps
                      ,l_month_end_male
                      ,l_month_end_female
                      ,l_month_end_total
                      ,l_total_actions);

  l_Declaration_Due    := g_effective_date
                        + nvl(to_number(rec_estab.A_Declaration_Due_Offset),0);
  l_Latest_Declaration := g_effective_date + nvl(to_number(
                                     rec_estab.A_Latest_Declaration_Offset),0);
  l_Last_Contribution  := g_effective_date + nvl(to_number(
                                      rec_estab.A_Last_Contribution_Offset),0);
  l_Payment_Date       := g_effective_date
                        + nvl(to_number(rec_estab.A_Payment_Date_Offset),0);

  l_payment_1_acc_no := null;
  l_payment_2_acc_no := null;
  l_payment_3_acc_no := null;
  IF l_payment_1_account IS NOT NULL THEN
    OPEN cbank_info(l_payment_1_account);
    FETCH cbank_info INTO l_payment_1_acc_no;
    CLOSE cbank_info;
  END IF;

  IF l_payment_2_account IS NOT NULL THEN
    OPEN cbank_info(l_payment_2_account);
    FETCH cbank_info INTO l_payment_2_acc_no;
    CLOSE cbank_info;
  END IF;

  IF l_payment_3_account IS NOT NULL THEN
    OPEN cbank_info(l_payment_3_account);
    FETCH cbank_info INTO l_payment_3_acc_no;
    CLOSE cbank_info;
  END IF;


  pay_action_information_api.create_action_information (
     p_action_information_id       => l_action_info_id
    ,p_action_context_id           => p_payroll_action_id
    ,p_action_context_type         => 'PA'
    ,p_object_version_number       => l_ovn
    ,p_action_information_category => 'FR_DUCS_PAGE_INFO'
    ,p_action_information1         => rec_estab.establishment_id
    ,p_action_information2  => 'ASSEDIC'
    ,p_action_information3  => rec_estab.estab_ASSEDIC_id
    ,p_action_information4  => rec_estab.ASSEDIC_name
    ,p_action_information5  => rec_estab.estab_ASSEDIC_id
    ,p_action_information6  => null
    ,p_action_information7  => rec_estab.assedic_address_line_1
    ,p_action_information8  => rec_estab.assedic_address_line_2
    ,p_action_information9  => rec_estab.assedic_address_line_3
    ,p_action_information10 => rec_estab.assedic_address_line_4
    ,p_action_information11 => l_payment_1_acc_no
    ,p_action_information12 => fnd_number.number_to_canonical(l_payment_1_val)
    ,p_action_information13 => l_payment_2_acc_no
    ,p_action_information14 => fnd_number.number_to_canonical(l_payment_2_val)
    ,p_action_information15 => l_payment_3_acc_no
    ,p_action_information16 => fnd_number.number_to_canonical(l_payment_3_val)
    ,p_action_information17 => to_char(l_Declaration_Due,'dd/mm/yyyy')
    ,p_action_information18 => to_char(l_Latest_Declaration,'dd/mm/yyyy')
    ,p_action_information19 => to_char(l_Last_Contribution,'dd/mm/yyyy')
    ,p_action_information20 => to_char(l_Payment_Date,'dd/mm/yyyy')
    ,p_action_information21 => l_contribution_emps
    ,p_action_information22 => l_month_end_male
    ,p_action_information23 => l_month_end_female
    ,p_action_information24 => l_month_end_total
    ,p_action_information25 => fnd_number.number_to_canonical(
                                                         l_total_contributions)
    ,p_action_information26 => fnd_number.number_to_canonical(l_advances)
    ,p_action_information27 => fnd_number.number_to_canonical(l_regularization)
    ,p_action_information28 => fnd_number.number_to_canonical(l_total_payment)
    ,p_action_information29 => l_total_actions);

END LOOP;

--Pension

FOR rec_pens IN csr_comp_pension_prvs LOOP


  -- Process PENSION contributions
  pay_fr_ducs.process_contributions
  (p_payroll_action_id    => p_payroll_action_id
  ,p_page_identifier      => rec_pens.comp_pens_prov_id
  ,p_page_type            => 'PENSION'
  ,p_total_contributions  => l_total_contributions
  );

  -- Get existing payment options (from previous archive)
  OPEN cpayment(p_page_identifier   => rec_pens.comp_pens_prov_id
               ,p_page_type         => 'PENSION');

  FETCH cpayment INTO l_payment_1_account,
                      l_payment_1_type,
                      l_payment_1_limit,
                      l_payment_2_account,
                      l_payment_2_type,
                      l_payment_2_limit,
                      l_payment_3_account,
                      l_payment_3_type,
                      l_payment_3_limit,
                      l_advances,
                      l_regularization;

  IF cpayment%notfound THEN

    -- Initialise the Payment Options
    l_payment_1_account  := rec_pens.payment_1_account;
    l_payment_1_type     := rec_pens.payment_1_type;
    l_payment_1_limit    := rec_pens.payment_1_limit;
    l_payment_2_account  := rec_pens.payment_2_account;
    l_payment_2_type     := rec_pens.payment_2_type;
    l_payment_2_limit    := rec_pens.payment_2_limit;
    l_payment_3_account  := rec_pens.payment_3_account;
    l_payment_3_type     := rec_pens.payment_3_type;
    l_payment_3_limit    := rec_pens.payment_3_limit;
    l_advances           := null;
    l_regularization     := null;

    hr_organization_api.create_org_information (
      p_effective_date                 => g_effective_date
     ,p_organization_id                => g_company_id
     ,p_org_info_type_code             => 'FR_COMP_PAYMENT_OVERRIDE'
     ,p_org_information1               => p_payroll_action_id
     ,p_org_information2               => rec_pens.comp_pens_prov_id
     ,p_org_information3               => l_period_code
     ,p_org_information4               => 'PENSION'
     ,p_org_information5               => rec_pens.pens_prov_id
     ,p_org_information6               => null
     ,p_org_information7               => l_payment_1_account
     ,p_org_information8               => l_payment_1_type
     ,p_org_information9               => l_payment_1_limit
     ,p_org_information10              => l_payment_2_account
     ,p_org_information11              => l_payment_2_type
     ,p_org_information12              => l_payment_2_limit
     ,p_org_information13              => l_payment_3_account
     ,p_org_information14              => l_payment_3_type
     ,p_org_information15              => l_payment_3_limit
     ,p_org_information_id             => l_org_information_id
     ,p_object_version_number          => l_object_version_number);

  END IF;

  CLOSE cpayment;

  l_advances        := round(nvl(l_advances,0),2);
  l_regularization  := round(nvl(l_regularization,0),2);

  l_total_payment := l_total_contributions + l_advances + l_regularization;

  pay_fr_ducs.process_payment
    (p_name           => rec_pens.name
    ,p_total_payment  => l_total_payment
    ,p_payment1_type  => l_payment_1_type
    ,p_payment1_limit => fnd_number.canonical_to_number(l_payment_1_limit)
    ,p_payment1_value => l_payment_1_val
    ,p_payment2_type  => l_payment_2_type
    ,p_payment2_limit => fnd_number.canonical_to_number(l_payment_2_limit)
    ,p_payment2_value => l_payment_2_val
    ,p_payment3_type  => l_payment_3_type
    ,p_payment3_limit => fnd_number.canonical_to_number(l_payment_3_limit)
    ,p_payment3_value => l_payment_3_val);

  pay_fr_ducs.get_count_emps(p_payroll_action_id
                  ,rec_pens.comp_pens_prov_id
                  ,'PENSION'
                  ,l_contribution_emps
                  ,l_month_end_male
                  ,l_month_end_female
                  ,l_month_end_total
                  ,l_total_actions);

  l_Declaration_Due    := g_effective_date
                        + nvl(to_number(rec_pens.Declaration_Due_Offset),0);
  l_Latest_Declaration := g_effective_date
                        + nvl(to_number(rec_pens.Latest_Declaration_Offset),0);
  l_Last_Contribution  := g_effective_date
                        + nvl(to_number(rec_pens.Last_Contribution_Offset),0);
  l_Payment_Date       := g_effective_date
                        + nvl(to_number(rec_pens.Payment_Date_Offset),0);

  l_payment_1_acc_no := null;
  l_payment_2_acc_no := null;
  l_payment_3_acc_no := null;
  IF l_payment_1_account IS NOT NULL THEN
    OPEN cbank_info(l_payment_1_account);
    FETCH cbank_info INTO l_payment_1_acc_no;
    CLOSE cbank_info;
  END IF;

  IF l_payment_2_account IS NOT NULL THEN
    OPEN cbank_info(l_payment_2_account);
    FETCH cbank_info INTO l_payment_2_acc_no;
    CLOSE cbank_info;
  END IF;

  IF l_payment_3_account IS NOT NULL THEN
    OPEN cbank_info(l_payment_3_account);
    FETCH cbank_info INTO l_payment_3_acc_no;
    CLOSE cbank_info;
  END IF;

  pay_action_information_api.create_action_information (
     p_action_information_id       => l_action_info_id
    ,p_action_context_id           => p_payroll_action_id
    ,p_action_context_type         => 'PA'
    ,p_object_version_number       => l_ovn
    ,p_action_information_category => 'FR_DUCS_PAGE_INFO'
    ,p_action_information1         => rec_pens.comp_pens_prov_id
    ,p_action_information2  => 'PENSION'
    ,p_action_information3  => rec_pens.pens_prov_id
    ,p_action_information4  => rec_pens.name
    ,p_action_information5  => null
    ,p_action_information6  => null
    ,p_action_information7  => rec_pens.address_line_1
    ,p_action_information8  => rec_pens.address_line_2
    ,p_action_information9  => rec_pens.address_line_3
    ,p_action_information10 => rec_pens.address_line_4
    ,p_action_information11 => l_payment_1_acc_no
    ,p_action_information12 => fnd_number.number_to_canonical(l_payment_1_val)
    ,p_action_information13 => l_payment_2_acc_no
    ,p_action_information14 => fnd_number.number_to_canonical(l_payment_2_val)
    ,p_action_information15 => l_payment_3_acc_no
    ,p_action_information16 => fnd_number.number_to_canonical(l_payment_3_val)
    ,p_action_information17 => to_char(l_Declaration_Due,'dd/mm/yyyy')
    ,p_action_information18 => to_char(l_Latest_Declaration,'dd/mm/yyyy')
    ,p_action_information19 => to_char(l_Last_Contribution,'dd/mm/yyyy')
    ,p_action_information20 => to_char(l_Payment_Date,'dd/mm/yyyy')
    ,p_action_information21 => l_contribution_emps
    ,p_action_information22 => l_month_end_male
    ,p_action_information23 => l_month_end_female
    ,p_action_information24 => l_month_end_total
    ,p_action_information25 => fnd_number.number_to_canonical(
                                                         l_total_contributions)
    ,p_action_information26 => fnd_number.number_to_canonical(l_advances)
    ,p_action_information27 => fnd_number.number_to_canonical(l_regularization)
    ,p_action_information28 => fnd_number.number_to_canonical(l_total_payment)
    ,p_action_information29 => l_total_actions);


END LOOP;  -- End of Pension Loop



--
hr_utility.set_location('Leaving ' || l_proc, 100);

EXCEPTION

  WHEN duplicate THEN
    hr_utility.set_location('Leaving with duplicate exception' || l_proc, 100);
  WHEN others THEN
    --3655620 write any other errors to the log file as otherwise the message
    --text is not propagated back to the CM and only appears in the log if
    --the LOGGING action parameter includes the letter G
    FND_FILE.NEW_LINE(fnd_file.log, 1);
    FND_FILE.PUT_LINE(fnd_file.log,substrb(SQLERRM,1,1023));
    raise;
END deinitialize_code;
--

-------------------------------------------------------------------------------
-- PROCEDURE recalculate_payment
-------------------------------------------------------------------------------

PROCEDURE recalculate_payment(
          errbuf                      out nocopy varchar2
         ,retcode                     out nocopy varchar2
         ,p_company_id                in number
         ,p_period_end_date 	      in varchar2
         ,p_period_type 	      in varchar2
         ,p_override_information_id   in number default null) IS

l_proc               varchar2(60) :=    g_package||' recalculate_payment ';
-- Local variables
l_error_flag varchar2(2):='N';
l_final_error_flag varchar2(2):='N';
l_total_payment      number;
l_advances           number;
l_regularisation     number;
l_payment_1_val      number;
l_payment_2_val      number;
l_payment_3_val      number;

l_period_end_date    date;

l_payment_1_acc_no     varchar2(60);
l_payment_2_acc_no     varchar2(60);
l_payment_3_acc_no     varchar2(60);


-- Cursor definitions

CURSOR cpayment_option IS
SELECT payment.org_information1 payroll_action_id
,      payment.org_information2 page_identifier
,      payment.org_information4 page_type
,      payment.org_information7 payment_1_account
,      payment.org_information8 payment_1_type
,      payment.org_information9 payment_1_limit
,      payment.org_information10 payment_2_account
,      payment.org_information11 payment_2_type
,      payment.org_information12 payment_2_limit
,      payment.org_information13 payment_3_account
,      payment.org_information14 payment_3_type
,      payment.org_information15 payment_3_limit
,      payment.org_information16 advances
,      payment.org_information17 regularisation
,      page.action_information_id
,      page.object_version_number
,      page.action_information4 organization_name
,      page.action_information25 total_contributions
FROM   hr_organization_information payment
,      pay_action_information page
WHERE  payment.organization_id = p_company_id
and    payment.org_information3 =
       to_char(l_period_end_date,'YY') ||
       to_char(l_period_end_date,'Q') ||
       decode(p_period_type,'CM',
       to_char(to_number(to_char(l_period_end_date,'MM'))
       -(to_number(to_char(l_period_end_date,'Q'))*3-2)+1)
                          ,'0')
and   payment.org_information_context = 'FR_COMP_PAYMENT_OVERRIDE'
and   payment.org_information_id =
         nvl(p_override_information_id, payment.org_information_id)
and   payment.org_information2 = page.action_information1
and   payment.org_information1 = page.action_context_id
and   page.action_context_type = 'PA'
and   page.action_information_category = 'FR_DUCS_PAGE_INFO'
and   page.action_information1 = payment.org_information2
and   page.action_information2 = payment.org_information4;

--
-- Cursor to retrieve Bank Info
--
CURSOR cbank_info(l_org_method_id number) is
SELECT ea.segment2 || ea.segment3 || replace(ea.segment5,'-','')
FROM   pay_org_payment_methods_f opm
,      pay_external_accounts ea
WHERE  opm.org_payment_method_id  = l_org_method_id
AND    opm.external_account_id = ea.external_account_id
AND    l_period_end_date between opm.effective_start_date
                         and opm.effective_end_date;



BEGIN

hr_utility.set_location('Entering ' || l_proc,10);

l_period_end_date :=  fnd_date.string_to_date(p_period_end_date,'YYYY/MM/DD HH24:MI:SS');

FOR payment IN cpayment_option LOOP


-- Validation checks on data entered
l_error_flag:='N';

IF (payment.payment_1_type IN ('AMOUNT','PERCENT')
AND payment.payment_1_limit IS NULL)
OR (payment.payment_2_type IN ('AMOUNT','PERCENT')
AND payment.payment_2_limit IS NULL)
OR (payment.payment_3_type IN ('AMOUNT','PERCENT')
AND payment.payment_3_limit IS NULL) THEN
  l_error_flag:='Y';
  hr_utility.set_message(801, 'PAY_75089_DUCS_NULL_ACC_LIMIT');
  hr_utility.set_message_token(801,'ORGANIZATION',payment.organization_name);
  FND_FILE.NEW_LINE(fnd_file.log, 1);
  FND_FILE.PUT_LINE(fnd_file.log,hr_utility.get_message);
END IF;

IF l_error_flag ='Y' THEN

  l_final_error_flag:='Y';

ELSE

  -- Set total payment using the update advances and regularisation values

  l_advances:=round(nvl(fnd_number.canonical_to_number(payment.advances),0),2);
  l_regularisation:=round(nvl(fnd_number.canonical_to_number(
                                payment.regularisation),0),2);
  l_total_payment :=
    round(fnd_number.canonical_to_number(payment.total_contributions),2) +
    l_advances + l_regularisation;

  pay_fr_ducs.process_payment
   (p_name           => payment.organization_name
   ,p_total_payment  => l_total_payment
   ,p_payment1_type  => payment.payment_1_type
   ,p_payment1_limit => fnd_number.canonical_to_number(payment.payment_1_limit)
   ,p_payment1_value => l_payment_1_val
   ,p_payment2_type  => payment.payment_2_type
   ,p_payment2_limit => fnd_number.canonical_to_number(payment.payment_2_limit)
   ,p_payment2_value => l_payment_2_val
   ,p_payment3_type  => payment.payment_3_type
   ,p_payment3_limit => fnd_number.canonical_to_number(payment.payment_3_limit)
   ,p_payment3_value => l_payment_3_val);


  l_payment_1_acc_no := null;
  l_payment_2_acc_no := null;
  l_payment_3_acc_no := null;
  IF payment.payment_1_account IS NOT NULL THEN
    OPEN cbank_info(payment.payment_1_account);
    FETCH cbank_info INTO l_payment_1_acc_no;
    CLOSE cbank_info;
  END IF;

  IF payment.payment_2_account IS NOT NULL THEN
    OPEN cbank_info(payment.payment_2_account);
    FETCH cbank_info INTO l_payment_2_acc_no;
    CLOSE cbank_info;
  END IF;

  IF payment.payment_3_account IS NOT NULL THEN
    OPEN cbank_info(payment.payment_3_account);
    FETCH cbank_info INTO l_payment_3_acc_no;
    CLOSE cbank_info;
  END IF;


  -- Update FR_DUCS_PAGE_INFO record using the update API.


  pay_action_information_api.update_action_information(
    p_action_information_id => payment.action_information_id
   ,p_object_version_number => payment.object_version_number
   ,p_action_information11 => l_payment_1_acc_no
   ,p_action_information12 => fnd_number.number_to_canonical(l_payment_1_val)
   ,p_action_information13 => l_payment_2_acc_no
   ,p_action_information14 => fnd_number.number_to_canonical(l_payment_2_val)
   ,p_action_information15 => l_payment_3_acc_no
   ,p_action_information16 => fnd_number.number_to_canonical(l_payment_3_val)
   ,p_action_information26 => fnd_number.number_to_canonical(l_advances)
   ,p_action_information27 => fnd_number.number_to_canonical(l_regularisation)
   ,p_action_information28 => fnd_number.number_to_canonical(l_total_payment));

END IF;

END LOOP;

IF l_final_error_flag = 'Y' THEN
  retcode := 1;
END IF;


hr_utility.set_location('Leaving ' || l_proc, 100);

END recalculate_payment;
--

END PAY_FR_DUCS; -- End of package

/
