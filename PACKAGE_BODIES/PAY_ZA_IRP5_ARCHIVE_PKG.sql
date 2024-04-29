--------------------------------------------------------
--  DDL for Package Body PAY_ZA_IRP5_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_IRP5_ARCHIVE_PKG" as
/* $Header: pyzaarch.pkb 120.14.12010000.2 2008/08/14 07:24:35 rbabla ship $ */
sql_range          varchar2(4000);
prev_asg_id        number;
g_size             number;           -- Used to keep track of the size of the IRP5 file
g_file_count       number;           -- Total Number of all records on file
g_employer_count   number;           -- Total Number of all records for the employer
g_employer_code    number;           -- Total code value for the employer
g_employer_amounts number;           -- Total amounts for the employer
g_previous_code    varchar2(256);    -- The last SARS code that was written out
g_ls_assid         number;           -- The current Assignment ID used by the Lump Sum Function
g_ls_assactid      number;           -- The current Assignment Action ID used by the Lump Sum Function
g_ls_size          number;           -- The size of the PLSQL table used by the Lump Sum Function
g_ls_index         number;           -- An index into the PLSQL table used by the Lump Sum Function
g_ls_indicator     varchar2(1);      -- The Lump Sum Indicator used by the Lump Sum Function
type char_table is table of varchar2(60)
     index by binary_integer;
g_ls_table         char_table;       -- The PL_SQL table used by the Lump Sum Function

/*--------------------------------------------------------------------------
  Name      : range_cursor
  Purpose   : This returns the select statement that is used to create the
              range rows.
  Arguments :
  Notes     : The range cursor determines which people should be processed.
              The normal practice is to include everyone, and then limit
              the list during the assignment action creation.
--------------------------------------------------------------------------*/
procedure range_cursor
(
   pactid in  number,
   sqlstr out nocopy varchar2
)  is
begin

   sql_range :=
'SELECT distinct ASG.person_id
FROM   per_assignments_f   ASG,
       pay_payrolls_f      PPY,
       pay_payroll_actions PPA
WHERE  PPA.payroll_action_id     = :payroll_action_id
  AND  ASG.business_group_id     = PPA.business_group_id
  AND  ASG.assignment_type       = ''E''
  AND  PPY.payroll_id            = ASG.payroll_id
ORDER  BY ASG.person_id';

   sqlstr := sql_range;

end range_cursor;

/*--------------------------------------------------------------------------
  Name      : action_creation
  Purpose   : This creates the assignment actions for a specific chunk.
  Arguments :
  Notes     :
--------------------------------------------------------------------------*/
procedure action_creation
(
   pactid    in number,
   stperson  in number,
   endperson in number,
   chunk     in number
) is

-- This cursor returns all assignments for which processing took place
-- in the Tax Year.
-- Note: This cursor does not date effectively join to per_assignments_f.
--       Duplicate assignments are, however, removed in the cursor loop.
/*
   "The cursor looks for assignments that were processed
   "on the specific payroll that was given in the TYE Archiver SRS -
   "BUT, this means it will find the Assignment for ALL the payrolls it was on during
   "the Tax year (and for which processing took place), whenever the TYE Archiver SRS
   "is run for each of those payrolls, and not only the last payroll that the
   "assignment was on at TYE.
   "This needs to change to only pick up Assignments that are on the specific payroll,
   "AT TAX YEAR END, that was given in the TYE Archiver SRS
   "- it will resolve the problem of duplicate certificates
   "being produced for Assignments where the payroll had been changed during
   "the Tax Year. "Duplicates" is meant in the sense that Certificates are produced for
   "such an Assignment when the Tax Year End is run for EACH of the payrolls that it
   "was on during the Tax Year - which is incorrect, it should only be done for the
   "payroll that the assignment was on AT TAX YEAR END.
   "As follows:
*/
--Modified cursor get_asg to date effectively select assignments as at Tax Year End
--and to limit them to where the payroll is equal to the specific payroll that was
--given in the TYE Archiver SRS
cursor get_asg(p_payroll_id pay_all_payrolls_f.payroll_id%TYPE) is
   SELECT /*+ INDEX(asg PER_ASSIGNMENTS_F_N12) */
          /* we used the above hint to always ensure that the use the person_id
             index on per_assignments_f, otherwise, it is feasible the CBO may decide to
             choose the N7 (payroll_id) index due to it being a bind */
          asg.person_id     person_id
        , asg.assignment_id assignment_id
     FROM
          per_all_assignments_f asg
        , pay_all_payrolls_f    ppf
        , pay_payroll_actions   ppa_arch
    WHERE
          asg.business_group_id + 0 = ppa_arch.business_group_id
      AND asg.person_id BETWEEN stperson
                            AND endperson
      AND ppf.payroll_id      = p_payroll_id
      AND ppf.payroll_id      = asg.payroll_id
      AND
        ( ppa_arch.effective_date BETWEEN asg.effective_start_date
                                      AND asg.effective_end_date
          OR
           ( asg.effective_end_date <= ppa_arch.effective_date
             AND asg.effective_end_date =
               ( SELECT MAX(asg2.effective_end_date)
                   FROM per_all_assignments_f asg2
                  WHERE asg2.assignment_id  = asg.assignment_id
               )
           )
        )
      AND ppa_arch.payroll_action_id = pactid
      AND EXISTS (SELECT /*+ ORDERED */
                         /* the ordered hint will force the paa table to be joined to first */
                         NULL
                    FROM pay_assignment_actions     paa
                       , pay_payroll_actions        ppa
                   WHERE paa.assignment_id        = asg.assignment_id
                     AND ppa.effective_date BETWEEN ppa_arch.start_date
                                                AND ppa_arch.effective_date
                     AND ppa.action_type         IN ('R', 'Q', 'V', 'B', 'I')
                     AND ppf.payroll_id           = ppa.payroll_id
                     AND paa.payroll_action_id    = ppa.payroll_action_id)
   order by 1, 2
   for update of asg.assignment_id;

-- Note: A Run Result source_type of E means the entry was a normal entry,
--       and not an indirect result
-- Note: The source_id is the Source Element Entry
/*
   "The TYE Archiver Payroll Action is tied to the specific payroll that was given
   "in the TYE Archiver SRS - thus, whenever the pay_payroll_actions.payroll_id is used
   "subsequently, it will limit the query to ONLY processing that took place on the
   "last payroll the assignment was on at TYE - thus, for e.g. cursor lumpsum, in which any
   "Lump Sums run on the earlier payroll will NOT be found because ppa_arch.payroll_id is used.
   "
   "If cursor lumpsum is changed to not use ppa_arch.payroll_id, it does find the
   "Lump Sums run on an earlier payroll, as follows:
*/
--Modified cursor lumpsum to find 'ZA_Tax_On_Lump_Sums' processing that took place on
--earlier payrolls for the assignment also, not only for the assignment's payroll as at TYE.
--It now looks for all ASSIGNMENT ACTIONS for the Assignment in which the
--'ZA_Tax_On_Lump_Sums' element was processed, not for PAYROLL ACTIONS
--for the Payroll as at Tax Year End anymore.
cursor lumpsum (pay_action_id number, asg_id number) is
select distinct pac.context_value
   from   pay_action_contexts    pac,
          pay_assignment_actions paa,
          pay_payroll_actions    ppa,
	  ff_contexts            ffc
   where  paa.assignment_id = asg_id
     and  paa.payroll_action_id = ppa.payroll_action_id
     and  ppa.action_type in ('R', 'Q', 'V', 'B', 'I') -- added for 5165859
     AND  pac.assignment_Action_id = paa.assignment_action_id
     And  pac.context_value <> 'To Be Advised'
     and  ffc.context_name = 'SOURCE_TEXT'
     and  ffc.context_id = pac.context_id
     and  ppa.effective_date >= (select ppa_arch.start_date
                                   from pay_payroll_actions ppa_arch
                                  where ppa_arch.payroll_action_id = pay_action_id)
     and  ppa.effective_date <= (select ppa_arch.effective_date
                                   from pay_payroll_actions ppa_arch
                                  where ppa_arch.payroll_action_id = pay_action_id);

asg_set_id   number;
person_id    number;
l_payroll_id number;
leg_param    pay_payroll_actions.legislative_parameters%type;
asg_include  boolean;
lockingactid number;
v_incl_sw    char;
l_ppa_payroll_id pay_payroll_actions.payroll_id%TYPE;

BEGIN

--  hr_utility.trace_on(null, 'TYE2005');

   -- Get the legislative parameters from the archiver payroll action
   select legislative_parameters,payroll_id
   into   leg_param,l_ppa_payroll_id
   from   pay_payroll_actions
   where  payroll_action_id = pactid;

   asg_set_id   := get_parameter('ASG_SET_ID', leg_param);
   person_id    := get_parameter('PERSON_ID',  leg_param);
   l_payroll_id := get_parameter('PAYROLL_ID', leg_param);

   -- Update the Payroll Action with the Payroll ID
   --
   IF l_ppa_payroll_id IS NULL THEN
      update pay_payroll_actions
         set payroll_id = l_payroll_id
       where payroll_action_id = pactid;
   END IF;

   if  asg_set_id is not null then
-- TAR37293; need to find out if assignments in assignment-set are set to Include or Exclude.
       begin
         select distinct include_or_exclude
         into v_incl_sw
         from   hr_assignment_set_amendments
         where  assignment_set_id = asg_set_id;
       exception
         when no_data_found  then
-- TAR37293;default to Include, should not go here though.
              v_incl_sw := 'I';
       end;
   end if;
   for asgrec in get_asg(l_payroll_id) loop

      hr_utility.set_location('ASS: ' || to_char(asgrec.assignment_id), 5);
      asg_include := TRUE;

      -- Remove duplicate assignments
      if prev_asg_id <> asgrec.assignment_id then

         prev_asg_id := asgrec.assignment_id;

         if asg_set_id is not null then

            declare
               inc_flag varchar2(5);
            begin
               select include_or_exclude
               into   inc_flag
               from   hr_assignment_set_amendments
               where  assignment_set_id = asg_set_id
                 and  assignment_id = asgrec.assignment_id;

               if inc_flag = 'E' then
                  asg_include := FALSE;
               end if;
            exception
-- TAR37293; goes through this exception, for each assignment in the payroll but not in the
-- relevant assignment_set.
               when no_data_found then
                    if  v_incl_sw = 'I' then
                        asg_include := FALSE;
                    else
                        asg_include := TRUE;
                    end if;
            end ;

         end if;

         if person_id is not null then
            if person_id <> asgrec.person_id then
               asg_include := FALSE;
            end if;
         end if;

            -- Process Lump Sums
         if asg_include = TRUE then
            for lumprec in lumpsum(pactid, asgrec.assignment_id) loop

               hr_utility.set_location('LUMP SUM:' || to_char(asgrec.assignment_id),10);

               select pay_assignment_actions_s.nextval
               into   lockingactid
               from   dual;
              hr_utility.set_location('lockingactidM:' || lockingactid,10);
               -- Insert Lump Sums into pay_assignment_actions
               hr_nonrun_asact.insact
               (
                  lockingactid => lockingactid,
                  assignid     => asgrec.assignment_id,
                  pactid       => pactid,
                  chunk        => chunk,
                  greid        => null,
                  source_act   => null -- for advance retro
                );

            end loop;
-- For Normal

            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;

            -- Insert assignment into pay_assignment_actions
            hr_nonrun_asact.insact
            (
               lockingactid,
               asgrec.assignment_id,
               pactid,
               chunk,
               null
            );

         end if;

      end if;

   end loop;
--   hr_utility.trace_off;

end action_creation;

/*--------------------------------------------------------------------------
  Name      : archive_data
  Purpose   : This sets up the contexts needed for the live (non-archive)
              database items
  Arguments :
  Notes     : Every possible context for a specific assignment action has to
              be added to the PL/SQL table
--------------------------------------------------------------------------*/
procedure archive_data
(
   p_assactid       in number,
   p_effective_date in date
) is

asgid        pay_assignment_actions.assignment_id%type;
l_count      number;
l_flag       number;
l_context_no number;
aaseq        number;
aaid         number;
l_pact_id    number;
paid         number;
l_payroll_id number;
l_eff_date   date;
l_dir_no     number;
l_main_crt_flag number;

-- Deductions SARS codes
cursor cursars is
   select distinct code
   from   pay_za_irp5_bal_codes
   where  code in (4001, 4002, 4003, 4004, 4005, 4006, 4007, 4018);

-- A list of distinct Clearance Numbers
/* For 4346920  */

CURSOR curclr (p_assignment_Action_id IN number
               ) is
  Select distinct context_value clearance_number
  FROM PAY_ACTION_CONTEXTS PAC,
       ff_contexts         fcon
Where pac.context_id               = fcon.context_id
AND   fcon.context_name            ='SOURCE_NUMBER'
And PAC.ASSIGNMENT_ACTION_ID in
(
     Select paa_all.assignment_Action_id from
        pay_assignment_actions paa,
        pay_assignment_actions paa_all,
        pay_payroll_actions ppa,
        per_time_periods    ptp
     Where paa.assignment_action_id = p_assignment_Action_id
        and paa_all.assignment_id = paa.assignment_id
        and paa_all.payroll_action_id = ppa.payroll_action_id
        and ppa.time_period_id = ptp.time_period_id
        and ptp.end_date > add_months(p_effective_date,-12)
        and ptp.end_date <=   p_effective_date
        and ppa.action_type in ('R', 'Q','V', 'B', 'I') -- added for 5165859
 )
UNION
Select '99999999999'
FROM dual;

-- Cursor for Directive Number Context
/*CURSOR curdirnum (p_assignment_action_id IN number) is
   Select max(context_value) directive_number
   From
        PAY_ACTION_CONTEXTS PAC,
        ff_contexts         fcon
   Where PAC.assignment_action_id     = p_assignment_action_id
   AND   pac.context_id               = fcon.context_id
   AND   fcon.context_name            ='SOURCE_TEXT'; */

CURSOR curdirnum (p_ass_id IN NUMBER ,p_pact_id IN number) is
  SELECT DISTINCT pac.context_value directive_number
   from   pay_action_contexts    pac,
          pay_assignment_actions paa,
          pay_payroll_actions    ppa,
	  ff_contexts            ffc
   where  paa.assignment_id = p_ass_id
     and  paa.payroll_action_id = ppa.payroll_action_id
     and  ppa.action_type in ('R', 'Q', 'V', 'B', 'I') -- added for 5165859
     AND  pac.assignment_Action_id = paa.assignment_action_id
     And  pac.context_value <> 'To Be Advised'
     and  ffc.context_name = 'SOURCE_TEXT'
     and  ffc.context_id = pac.context_id
     and  ppa.effective_date >= (select ppa_arch.start_date
                                   from pay_payroll_actions ppa_arch
                                  where ppa_arch.payroll_action_id = p_pact_id)
     and  ppa.effective_date <= (select ppa_arch.effective_date
                                   from pay_payroll_actions ppa_arch
                                  where ppa_arch.payroll_action_id = p_pact_id);

begin
l_main_crt_flag :=0;
--hr_utility.trace_on(null,'TYE2005');
hr_utility.set_location('archive_data ',1);
hr_utility.set_location('p_assactid ' ||p_assactid,1);
hr_utility.set_location('p_effective_date ' ||to_char(p_effective_date,'DD-MON-YYYY'),1);
   -- Get some contexts
   -- Note: The last entry in this tax year is chosen. It might happen that a person
   --       transfers between payrolls, but this is not catered for; since he is
   --       supposed to start on a new assignment number.
   select aa.assignment_id,
          paf.payroll_id,
          ppa.effective_date,
          ppa.payroll_action_id
   into   asgid, l_payroll_id, l_eff_date, l_pact_id
   from   pay_assignment_actions aa,
          pay_payroll_actions    ppa,
          per_assignments_f      paf
   where  aa.assignment_action_id = p_assactid
     and  aa.assignment_id = paf.assignment_id
     and  ppa.payroll_action_id = aa.payroll_action_id
     and  paf.effective_start_date =
     (
        select max(paf2.effective_start_date)
        from   per_assignments_f paf2
        where  paf2.effective_start_date <= ppa.effective_date
        and    paf2.assignment_id = aa.assignment_id
     );

hr_utility.set_location('l_pact_id is ' || l_pact_id, 999);

   -- Clear the PL/SQL table that contains the contexts
   l_context_no := pay_archive.g_context_values.sz;
   hr_utility.set_location('l_context_no ' ||l_context_no,1);
   for i in 1..l_context_no loop



      pay_archive.g_context_values.name(i)  := NULL;
      pay_archive.g_context_values.value(i) := NULL;

   end loop;

   pay_archive.g_context_values.sz := 0;
   l_count := 0;

   /* Set up the assignment id, date earned and payroll id contexts */
   l_count := l_count + 1;
   pay_archive.g_context_values.name(l_count)  := 'ASSIGNMENT_ID';
   pay_archive.g_context_values.value(l_count) := asgid;
hr_utility.set_location('pay_archive.g_context_values.name(l_count) ' ||pay_archive.g_context_values.name(l_count),1);
hr_utility.set_location('pay_archive.g_context_values.value(l_count) ' ||pay_archive.g_context_values.value(l_count),1);


   l_count := l_count + 1;
   pay_archive.g_context_values.name(l_count)  := 'PAYROLL_ID';
   pay_archive.g_context_values.value(l_count) := l_payroll_id;

hr_utility.set_location('pay_archive.g_context_values.name(l_count) ' ||pay_archive.g_context_values.name(l_count),1);
hr_utility.set_location('pay_archive.g_context_values.value(l_count) ' ||pay_archive.g_context_values.value(l_count),1);

   l_count := l_count + 1;
   pay_archive.g_context_values.name(l_count)  := 'DATE_EARNED';
   pay_archive.g_context_values.value(l_count) := l_eff_date;
hr_utility.set_location('pay_archive.g_context_values.name(l_count) ' ||pay_archive.g_context_values.name(l_count),1);
hr_utility.set_location('pay_archive.g_context_values.value(l_count) ' ||pay_archive.g_context_values.value(l_count),1);
   -- Select the maximum action_sequence of an assignment action, for which
   -- a ZA_Tax_On_Lump_Sums element was processed in the same period, and
   -- for which a previous archive assignment action did not archive of the
   -- same period into A_PAY_PROC_PERIOD_ID
/*
"This will not select the processing of any ZA_Tax_On_Lump_Sums that took place for this
"Assignment while it was still on an earlier Payroll.
"Thus, modified to not limit the search to Lump Sum processing that took place on the
"Payroll that the assignment was on at Tax Year End. Instead it will also look for
"Lump Sum processing that took place on earlier payrolls for this assignment
*/
/*
As part of Lump Sum Enhancement the Assignment_action_id is stored
in the table pay_assignment_actions during action_creation which will be used here
*/
Select count(*)
   into   l_main_crt_flag
    From pay_assignment_actions paa_arch
    Where paa_arch.assignment_action_id > p_assactid
    AND   paa_arch.payroll_action_id = l_pact_id
    AND   paa_arch.assignment_id = asgid;


   -- Note: It is important that the Main Certificate has a higher action_sequence,
   --       since this is needed for the Lump Sum Database Item. The Report can,
   --       however sort by assignment_id asc, assignment_action_id desc to avoid
   --       printing the Lump Sum Certificates before the Main Certificate

      select max(paa.action_sequence)
      into   aaseq
      from   pay_assignment_actions     paa,
             pay_payroll_actions        ppa
      where  paa.assignment_id = asgid
        and  paa.payroll_action_id = ppa.payroll_action_id
        and  ppa.action_type IN ('R', 'Q', 'V', 'B', 'I')
        and  ppa.effective_date <= p_effective_date;



   select assignment_action_id, payroll_action_id
   into   aaid, paid
   from   pay_assignment_actions
   where  assignment_id = asgid
     and  action_sequence = aaseq;

   -- Assignment Action ID of a max(action_sequence) Payroll Run
   l_count := l_count + 1;
   pay_archive.g_context_values.name(l_count)  := 'ASSIGNMENT_ACTION_ID';
   pay_archive.g_context_values.value(l_count) := aaid;
   pay_archive.balance_aa := aaid;
   hr_utility.set_location('pay_archive.g_context_values.name(l_count) ' ||pay_archive.g_context_values.name(l_count),1);
   hr_utility.set_location('pay_archive.g_context_values.value(l_count) ' ||pay_archive.g_context_values.value(l_count),1);

   l_count := l_count + 1;
   pay_archive.g_context_values.name(l_count)  := 'PAYROLL_ACTION_ID';
   pay_archive.g_context_values.value(l_count) := paid;
   hr_utility.set_location('pay_archive.g_context_values.name(l_count) ' ||pay_archive.g_context_values.name(l_count),1);
   hr_utility.set_location('pay_archive.g_context_values.value(l_count) ' ||pay_archive.g_context_values.value(l_count),1);

   -- Save the current count
   l_flag := l_count;

   -- Populate the PL/SQL table with Clearance Numbers
   -- execute cursor only if the certificate is main certificate
   IF l_main_crt_flag = 0 then
      for clrrev in curclr(aaid)  loop
         l_count := l_count + 1;
         pay_archive.g_context_values.name(l_count)  := 'SOURCE_NUMBER';
         pay_archive.g_context_values.value(l_count) := clrrev.clearance_number;
         hr_utility.set_location('pay_archive.g_context_values.name(l_count) ' ||pay_archive.g_context_values.name(l_count),1);
         hr_utility.set_location('pay_archive.g_context_values.value(l_count) ' ||pay_archive.g_context_values.value(l_count),1);
      end loop;
   END if;
   -- Make sure that at least one Clearance Number exist,
   -- otherwise create a dummy one
   if l_flag = l_count then

      l_count := l_count + 1;
      pay_archive.g_context_values.name(l_count)  := 'SOURCE_NUMBER';
      pay_archive.g_context_values.value(l_count) := '99999999999';
      hr_utility.set_location('pay_archive.g_context_values.name(l_count) ' ||pay_archive.g_context_values.name(l_count),2);
      hr_utility.set_location('pay_archive.g_context_values.value(l_count) ' ||pay_archive.g_context_values.value(l_count),2);
   end if;
   l_flag := l_count;
   l_dir_no :=1;

   IF l_main_crt_flag > 0 then
      for dirnumrev in curdirnum (asgid,l_pact_id) loop
         IF l_main_crt_flag = l_dir_no then
            l_count := l_count + 1;
            pay_archive.g_context_values.name(l_count)  := 'SOURCE_TEXT';
            pay_archive.g_context_values.value(l_count) := dirnumrev.directive_number;
            hr_utility.set_location('pay_archive.g_context_values.name(l_count) ' ||pay_archive.g_context_values.name(l_count),1);
            hr_utility.set_location('pay_archive.g_context_values.value(l_count) ' ||pay_archive.g_context_values.value(l_count),1);
         END if;
         l_dir_no := l_dir_no +1;
      end loop;
   -- Setting default Tax directive Number
      if l_flag = l_count then
        l_count := l_count + 1;
        pay_archive.g_context_values.name(l_count)  := 'SOURCE_TEXT';
        pay_archive.g_context_values.value(l_count) := 'To Be Advised';
        hr_utility.set_location('pay_archive.g_context_values.name(l_count) ' ||pay_archive.g_context_values.name(l_count),2);
        hr_utility.set_location('pay_archive.g_context_values.value(l_count) ' ||pay_archive.g_context_values.value(l_count),2);
      end if;
   else
-- setting Context for Main Certificate
        l_count := l_count + 1;
        hr_utility.set_location('setting Context for Main Certificate ' ,3);
        pay_archive.g_context_values.name(l_count)  := 'SOURCE_TEXT';
        pay_archive.g_context_values.value(l_count) := 'To Be Advised';

   END if;


   l_main_crt_flag := 0;

   -- Populate the PL/SQL table with Deduction SARS codes
   for sarrec in cursars loop
      l_count := l_count + 1;
      pay_archive.g_context_values.name(l_count)  := 'SOURCE_ID';
      pay_archive.g_context_values.value(l_count) := sarrec.code;
   end loop;

   pay_archive.g_context_values.sz := l_count;
--hr_utility.trace_off;

end archive_data;

/*--------------------------------------------------------------------------
  Name      : archinit
  Purpose   : This procedure can be used to perform an initialisation
              section
  Arguments :
  Notes     :
--------------------------------------------------------------------------*/
procedure archinit
(
   p_payroll_action_id in NUMBER
)  is
   l_req_id NUMBER ;
begin
   NULL ;
END archinit ;

procedure archdinit
(
   p_payroll_action_id in NUMBER
)  is
   l_req_id NUMBER ;
   l_start_date DATE;
   l_end_date DATE;
   leg_param pay_payroll_actions.legislative_parameters%type;
begin
   select legislative_parameters
   into   leg_param
   from   pay_payroll_actions
   where  payroll_action_id = p_payroll_action_id;

   l_start_date  := to_date(get_parameter('START_DATE', leg_param),'YYYY/MM/DD hh24:mi:ss');
   l_end_date    := to_date(get_parameter('END_DATE',  leg_param),'YYYY/MM/DD hh24:mi:ss');
   l_req_id      := fnd_request.submit_request( 'PAY', -- application
        'PYZATYVL', -- program
        'Create Tax Year End exception log',  -- description
        NULL,                         -- start_time
        NULL,                         -- sub_request
        p_payroll_action_id,l_start_date,l_end_date,chr(0),-- Start of Parameters or Arguments
        '','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','');


     IF (l_req_id = 0) THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unable to Create Tax Certificate Exception Log');
     END IF;
end archdinit;

/*--------------------------------------------------------------------------
  Name      : get_parameter
  Purpose   : Returns a legislative parameter
  Arguments :
  Notes     : The legislative parameter field must be of the form:
              PARAMETER_NAME=PARAMETER_VALUE. No spaces is allowed in either
              the PARAMETER_NAME or the PARAMETER_VALUE.
--------------------------------------------------------------------------*/
function get_parameter
(
   name        in varchar2,
   parameter_list varchar2
)  return varchar2 is

start_ptr number;
end_ptr   number;
token_val pay_payroll_actions.legislative_parameters%type;
par_value pay_payroll_actions.legislative_parameters%type;

begin

   token_val := name || '=';

   start_ptr := instr(parameter_list, token_val) + length(token_val);
   end_ptr   := instr(parameter_list, ' ', start_ptr);

   /* if there is no spaces, then use the length of the string */
   if end_ptr = 0 then
     end_ptr := length(parameter_list) + 1;
   end if;

   /* Did we find the token */
   if instr(parameter_list, token_val) = 0 then
     par_value := NULL;
   else
     par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
   end if;

   return par_value;

end get_parameter;

/*--------------------------------------------------------------------------
  Name      : get_lump_sum
  Purpose   : Returns the Lump Sum Balances one by one
  Arguments :
  Notes     : The balances are placed in the PL/SQL table in the following
              order: current PTD, future PTD, current YTD, future YTD
              g_ls_assactid is the Assignment Action ID of a Payroll Run
              pay_archive.archive_aa is the Assignment Action ID of the
              Archiver
--------------------------------------------------------------------------*/
function get_lump_sum
(
   p_assid    in number,     -- The Assignment ID
   p_assactid in number,     -- The Assignment Action ID of a Payroll Run
   p_index    in number      -- Identifies the balance we are looking for
)  return varchar2 is

i number;

begin

   -- Check whether this is the first time this assignment_id is processed
   if p_assid <> g_ls_assid then

      -- Set the global variables
      g_ls_assid    := p_assid;
      g_ls_assactid := p_assactid;

      -- Get and cache the Lump Sum Indicator
/*     Select decode(count(source_action_id),0,'N','Y')
     into   g_ls_indicator
     From pay_assignment_actions paa_arch
     Where paa_arch.assignment_action_id = pay_archive.archive_aa;*/

        Select decode(count(*), 0 ,'Y', 'N')
           into   g_ls_indicator
            From      pay_payroll_actions    ppa_arch,
              pay_assignment_actions paa_arch
        where paa_arch.assignment_action_id = pay_archive.archive_aa
        and   ppa_arch.payroll_action_id    = paa_arch.payroll_action_id
        and   paa_arch.assignment_action_id =
        (
           select max(paa.assignment_action_id)
           from   pay_assignment_actions paa
           where  paa.payroll_action_id = ppa_arch.payroll_action_id
           and   paa.assignment_id = paa_arch.assignment_id
        ) ;

      -- Clear the PL/SQL table
      g_ls_table.delete;

      -- Check whether this is the main certificate
      if g_ls_indicator = 'N' then

         -- This means there is no ZA_Tax_On_Lump_Sums, therefore PTD, LS_YTD = 0
         -- Populate the PLSQL table with retro YTD values

         -- bug no 4276047. Added Executive Equity Shares

      null;
      else

         -- Populate the PLSQL table with retro PTD
            -- bug no 4276047. Added Executive Equity Shares

      null;
      end if;

   else

      -- Check whether is the first time this assignment_action_id is processed
      if p_assactid <> g_ls_assactid then

         -- Set the global variables
         g_ls_assactid := p_assactid;

         -- Get and cache the Lump Sum Indicator
/*        Select decode(count(source_action_id),0,'N','Y')
           into   g_ls_indicator
            From pay_assignment_actions paa_arch
            Where paa_arch.assignment_action_id = pay_archive.archive_aa;*/

        Select decode(count(*), 0 ,'Y', 'N')
           into   g_ls_indicator
            From      pay_payroll_actions    ppa_arch,
              pay_assignment_actions paa_arch
        where paa_arch.assignment_action_id = pay_archive.archive_aa
        and   ppa_arch.payroll_action_id    = paa_arch.payroll_action_id
        and   paa_arch.assignment_action_id =
        (
           select max(paa.assignment_action_id)
           from   pay_assignment_actions paa
           where  paa.payroll_action_id = ppa_arch.payroll_action_id
           and   paa.assignment_id = paa_arch.assignment_id
        ) ;

         -- Check whether this is the main certificate
         if g_ls_indicator = 'N' then

            -- Pull all the summed PTD values of the PLSQL table
            null;

         else

            -- Populate the PLSQL table with PTD
            -- return first PTD
            null;

         end if;

      else

         -- Check whether this is the main certificate
         if g_ls_indicator = 'N' then

            -- Pull all the summed PTD values of the PLSQL table
            null;

         else

            -- Pull the current period's PTD values of the PLSQL table
            null;

         end if;

      end if;

   end if;

end get_lump_sum;

--------------------------------------------------------------------------------------------
-- This function is used to return the initials of the employee
-- Note: initials('Francois, Daniel, van der Merwe') would return 'FDV'
-- Note: A maximum of five characters is returned
--------------------------------------------------------------------------------------------
function initials(name varchar2) return varchar2 is

   l_initials varchar2(255);
   l_pos      number;
   l_name     varchar2(255);

begin

   -- Get the first initial
   l_name := rtrim(ltrim(name));
   if length(l_name) > 0 then

      l_initials := substr(l_name, 1, 1);

   end if;

   -- Check for a comma
   if l_initials = ',' or l_initials = '&' then

      l_initials := '';

   end if;

   l_pos := instr(l_name, ',', 1, 1);
   while l_pos <> 0 loop

      -- Move the Position indicator to the character after the comma
      l_pos := l_pos + 1;

      -- Move forward until you find something that is not a space
      while substr(l_name, l_pos, 1) = ' ' loop

         l_pos := l_pos + 1;

      end loop;

      -- Append the initial
      l_initials := l_initials || substr(l_name, l_pos, 1);

      -- Find the next initial
      l_pos := instr(l_name, ',', l_pos, 1);

   end loop;

   -- Check for a empty string
   if l_initials is null then

      l_initials := '&&&';

   end if;

   -- Format the result and limit it to 5 characters
   l_initials := upper(substr(l_initials, 1, 5));

   return l_initials;

end initials;

function names(name varchar2) return varchar2 is

l_pos    number;
l_pos2   number;
l_name   varchar2(255);
l_answer varchar2(255);

begin

   -- Remove any unnecessary spaces
   l_name := ltrim(rtrim(name));

   -- Get the first name
   l_pos := instr(l_name, ',', 1, 1);
   l_answer := rtrim(substr(l_name, 1, l_pos - 1));

   -- Append the second name
   l_pos2 := instr(l_name, ',', l_pos + 1, 1);
   if l_pos2 = 0 then

      -- Concatenate the rest of the string
      l_answer := l_answer || ' ' || ltrim(rtrim( substr(l_name, l_pos + 1) ));

   else

      -- Concatenate the name up to the comma
      l_answer := l_answer || ' ' || ltrim(rtrim( substr(l_name, l_pos + 1, l_pos2 - l_pos - 1) ));

   end if;

   l_answer := ltrim(rtrim(l_answer));

   return l_answer;

end names;

function clean(name varchar2) return varchar2 is

l_invalid varchar2(255);
l_answer  varchar2(255);
l_pos     number;
l_count   number;

begin

   l_invalid := '&`''';
   l_answer := name;

   if l_answer = '&&&,&&&' then

      return '&&&';

   else

      -- Loop through the invalid characters
      for l_count in 1..length(l_invalid) loop

         l_pos := instr(l_answer, substr(l_invalid, l_count, 1), 1, 1);
         while l_pos <> 0 loop

            -- Replace the invalid character with a space
            l_answer := substr(l_answer, 1, l_pos - 1) || ' ' || substr(l_answer, l_pos + 1);
            l_pos := instr(l_answer, substr(l_invalid, l_count, 1), 1, 1);

         end loop;

      end loop;

      return l_answer;

   end if;

end;

function get_size return number is
begin

   return g_size;

end;

function get_employer_count return number is
begin

   return g_employer_count;

end;

function get_employer_code return number is
begin

   return g_employer_code;

end;

function get_employer_amounts return number is
begin

   return g_employer_amounts;

end;

function get_file_count return number is
begin

   return g_file_count;

end;

function gen_x
(
   p_code      in varchar2,
   p_bg_id     in varchar2,
   p_tax_year  in varchar2,
   p_test_flag in varchar2
)  return varchar2 is

l_count number;
l_temp  varchar2(255);

begin

   -- Check whether this is the Init formula
   if p_code = '0000' then

      -- Only use the overriding Generation Number if this is a LIVE file
      if p_test_flag = 'N' then

         -- Get the overriding Generation Number
         l_temp := pay_magtape_generic.get_parameter_value('GEN_NUM');

         -- Check whether a valid overriding Generation Number was given
         if l_temp is not null then

            begin

               -- Override the Generation Number
               l_count := to_number(l_temp);

               if l_count < 1 or l_count > 9999 then
                  l_temp := null;
               end if;

            exception when invalid_number then
               -- Get the Generation Number the old way
               l_temp := null;

            end;

         end if;

         -- Check whether an overriding Generation Number was not entered
         if l_temp is null then

            -- Check whether this is the first time that THIS Creator is running in this tax year
            -- If the answer is yes, then reset the Generation Number to 0
            select count(*)
            into   l_count
            from   pay_payroll_actions
            where  action_type = 'X'
            and    report_type = 'ZA_IRP5'
            and    business_group_id = to_number(p_bg_id)
            and    pay_za_irp5_archive_pkg.get_parameter('TAX_YEAR', legislative_parameters) = p_tax_year;

            if l_count = 1 then

               -- Reset the Generation Number to 0
               update hr_organization_information
               set    org_information11       = '0'
               where  organization_id         = to_number(p_bg_id)
               and    org_information_context = 'ZA_TAX_FILE_ENTITY';

            end if;

         else   -- An overriding Generation Number was entered

            -- Subtract one from the number, since it will be added again in the Header
            l_count := l_count - 1;

            -- Update the Generation Number
            update hr_organization_information
            set    org_information11       = to_char(l_count)
            where  organization_id         = to_number(p_bg_id)
            and    org_information_context = 'ZA_TAX_FILE_ENTITY';

         end if;

      else   -- This is a TEST file

         l_count := 0;

      end if;

   else   -- This is the Header formula

      -- Get the Generation Number
      select nvl(to_number(org_information11), 0)
      into   l_count
      from   hr_organization_information
      where  organization_id         = to_number(p_bg_id)
      and    org_information_context = 'ZA_TAX_FILE_ENTITY';

      -- Check Test Flag
      if p_test_flag = 'LIVE' then

         -- Increment the Generation Number
         l_count := l_count + 1;

         -- Wrap at 9999
         if l_count = 10000 then

            l_count := 1;

         end if;

         -- Set the Generation Number
         update hr_organization_information
         set    org_information11       = to_char(l_count)
         where  organization_id         = to_number(p_bg_id)
         and    org_information_context = 'ZA_TAX_FILE_ENTITY';

      end if;

      -- If the answer was 0, then rather return 1
      if l_count = 0 then

         l_count := 1;

      end if;

   end if;

   -- Return the Generation Number
   return lpad(to_char(l_count), 4, '0');

end gen_x;

/* Not used */
function cert_num
(
   p_bg       number,
   p_tax_year varchar2,
   p_pay      varchar2,
   p_ass      number
) return varchar2 is

l_max_num varchar2(30);

begin

   if max_num = 'START' then

      -- Get the current largest number
      select max(substr(paa.serial_number, 5, 6))
      into   max_num
      from   pay_assignment_actions paa,
             pay_payroll_actions    ppa
      where  ppa.business_group_id = p_bg
      and    ppa.report_type = 'ZA_IRP5'
      and    ppa.action_type = 'X'
      and    substr(ppa.legislative_parameters,
             instr(ppa.legislative_parameters, 'TAX_YEAR') + 9, 4) = p_tax_year
      and    ppa.payroll_action_id <> substr(p_pay, 28, 9)
      and    paa.payroll_action_id = ppa.payroll_action_id
      and    paa.assignment_id = p_ass
      and    substr(paa.serial_number, 1, 2) = '&&';

      select max(substr(paa.serial_number, 3, 6))
      into   l_max_num
      from   pay_assignment_actions paa,
             pay_payroll_actions    ppa
      where  ppa.business_group_id = p_bg
      and    ppa.report_type = 'ZA_IRP5'
      and    ppa.action_type = 'X'
      and    substr(ppa.legislative_parameters,
             instr(ppa.legislative_parameters, 'TAX_YEAR') + 9, 4) = p_tax_year
      and    ppa.payroll_action_id <> substr(p_pay, 28, 9)
      and    paa.payroll_action_id = ppa.payroll_action_id
      and    paa.assignment_id = p_ass
      and    substr(paa.serial_number, 1, 2) <> '&&';

      if l_max_num > max_num then

         max_num := l_max_num;

      end if;

   end if;

   -- Add 1 to the largest number
   max_num := lpad(to_char(to_number(max_num) + 1), 6, '0');

   return max_num;

end;

function set_size
(
   p_code         in varchar2,
   p_type         in varchar2,
   p_value        in varchar2,
   p_tax_status   in varchar2,
   p_nature       in varchar2
)  return varchar2 is

l_text      varchar2(256);
l_code      varchar2(256);
l_value     varchar2(256);
l_gen       number;
   l_code2     varchar2(256);
   l_sars_code varchar2(256);

begin

   -- Remove any spaces
   l_value := rtrim(ltrim(p_value));

   -- Check for empty fields
   if (l_value = '&&&') or (l_value = '0') or (l_value = '0.00') then

      -- Check whether the field should be blank or left out
      if p_code in ('1010', '2010', '3010', '6010', '7010') then

         l_text := p_code || ',';
         -- Increment the file size
         g_size := g_size + length(l_text);

      -- Check whether the counters should be initialized
      elsif p_code = '0000' then

         g_size             := 0;
         g_employer_count   := 0;
         g_employer_code    := 0;
         g_employer_amounts := 0;
         g_file_count       := 0;

      else

         l_text := '';

      end if;

   -- Check for a terminator field
   elsif (l_value = '@@@') then

      l_text := ',9999' || fnd_global.local_chr(13) || fnd_global.local_chr(10);
      -- Increment the file size
      g_size := g_size + 7;

   -- A value field was provided
   else

      -- Check for the start of a record
      if p_code in ('1010', '2010', '3010', '6010', '7010') then
         l_text := p_code;
      else

         l_code2 := substr(p_code, 1, 4);

         if to_number(l_code2) >= 3601 and to_number(l_code2) <= 3907
            and to_number(l_code2) not in (3695, 3696, 3697, 3698, 3699) then

            l_sars_code := py_za_tax_certificates.get_sars_code
                              (
                                 l_code2,
                                 p_tax_status,
                                 p_nature
                              );

            l_text := ',' || l_sars_code || substr(p_code, 5);

         else
            l_text := ',' || p_code;

         end if;
      end if;

      -- Append the value
      if p_type = 'N' then
         l_text := l_text || ',' || l_value;
      else
         -- Add quotes if it is a character field
         l_text := l_text || ',"' || l_value || '"';
      end if;

      -- Increment the file size
      g_size := g_size + length(l_text);

   end if;

   -- Get the 4 digit SARS code
   l_code := substr(p_code, 1, 4);

   -- Check whether the Employer record count should be incremented
   if l_code in ('2010', '3010') then

      g_employer_count := g_employer_count + 1;

   end if;

   -- Check whether the file record count should be incremented
   if l_code in ('1010', '2010', '3010', '6010') then

      g_file_count := g_file_count + 1;

   end if;

   -- Check whether the Employer code count should be incremented
   if l_code not in ('1010', '1020', '1030', '1040', '1050', '1060', '1070', '1080', '1090',
                     '1100', '1110', '1120', '1130', '6010', '6020', '6030', '7010') then

      -- Only count those codes that were written out
      if ((l_value = '&&&') or (l_value = '0') or (l_value = '0.00')) then

         null;

      else

         -- Check whether the '9999' was written for a valid range
         if l_code = '9999' then

            if g_previous_code not in ('1010', '1020', '1030', '1040', '1050', '1060', '1070',
               '1080', '1090', '1100', '1110', '1120', '1130', '6010', '6020', '6030', '7010') then

               g_employer_code := g_employer_code + 9999;
               hr_utility.trace('COUNT(9999,' || to_char(g_employer_code) || ',' || l_value || ')');

            end if;

         else

             if (l_sars_code is not null and to_number(l_sars_code) > to_number(l_code)) then

                g_employer_code := g_employer_code + to_number(l_sars_code);
                hr_utility.trace('COUNT(l_sars_code = ' || l_sars_code || ',' || to_char(g_employer_code) || ',' || l_value || ')');

             else

               g_employer_code := g_employer_code + to_number(l_code);
               hr_utility.trace('COUNT(l_code = ' || l_code || ',' || to_char(g_employer_code) || ',' || l_value || ')');

            end if;

         end if;

      end if;

   end if;

   -- Check whether the Employer amounts total should be incremented
   if to_number(l_code) >= 3601 and to_number(l_code) <= 4493 then --Changed for code 6030 in electronic tax file

      g_employer_amounts := g_employer_amounts + to_number(l_value);

   end if;

   -- Check whether the Employer counts should be reset
   if l_code = '6030' then

      g_employer_count   := 0;
      g_employer_code    := 0;
      g_employer_amounts := 0;

   end if;

   -- Check whether the File counts should be reset
   if l_code = '7010' then

      g_size       := 0;
      g_file_count := 0;

   end if;

   -- Store the code that was written out
   g_previous_code := l_code;

   hr_utility.trace('DO(' || l_code || ',' || l_value || ',' || l_text || ')');

   return l_text;

end;

function za_power
(
   p_number in number,
   p_power  in number
)  return number is

begin

   return power(p_number, p_power);

end;

function za_to_char
(
   p_number in number,
   p_format in varchar2
)  return varchar2 is

begin

   -- Check whether the Format parameter was defaulted
   if p_format = '&&&' then

      return to_char(p_number);

   else

      return ltrim(to_char(p_number, p_format));

   end if;

end;

function put_nature
(
   p_nature in varchar2
)  return varchar2 is
begin

   g_nature := p_nature;

   return p_nature;

end put_nature;

function put_3696
(
   p_3696 in number
)  return varchar2 is

begin

   g_3696 := p_3696;

   return 'Y';

end put_3696;

function put_3699
(
   p_3699 in number
)  return varchar2 is

begin

   g_3699 := p_3699;

   return 'Y';

end put_3699;

function get_stored_values
(
   p_nature out nocopy varchar2,
   p_3699   out nocopy number,
   p_3696   out nocopy number
)  return varchar2 is

begin

   p_nature := g_nature;
   p_3699   := g_3699;
   p_3696   := g_3696;

   return 'Y';

end get_stored_values;

begin

   prev_asg_id := 0;
   g_size := 0;

end pay_za_irp5_archive_pkg;

/
