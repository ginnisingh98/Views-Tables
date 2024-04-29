--------------------------------------------------------
--  DDL for Package Body SSP_SMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_SMP_PKG" as
/*$Header: spsmpapi.pkb 120.8.12010000.4 2009/05/26 06:58:32 pbalu ship $
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
        Statutory Maternity Pay Business Process
--
Purpose
        To perform calculation of entitlement and payment for SMP purposes
--
History
        31 Aug 95       N Simpson       Created
         8 Sep 95       N Simpson       Modified procedure
                                        check_entitlement_to_SMP and turned it
                                        into a function entitled_to_SMP.
        15 Sep 95       N Simpson       Various modifications because of
                                        change in ssp_stoppages table.
        19 Sep 95       N Simpson       Modified medical_control parameters.
        27 Oct 95       N Simpson       Renamed all HR_ prefixed objects to
                                        SSP_ prefix if they were SSP-specific.
        2 Nov 95        N Simpson       Replaced hrstpapi calls with new style
                                        table handler names.
                                        Amended derive_SMP_week to initialise
                                        hypothetical_entry.element_link_id and
                                        hypothetical_entry.assignment_id which
                                        were being read by get_entry_details and
                                        raising a no_data_found error.
                                        Added a few check_parameter procedures.
        9 Nov 95        N Simpson       Removed some obsolete code.
        16 Nov 95       N Simpson       Changed last_standard_process_date
                                        to final_process_date throughout as
                                        it should have been in the first place.
        27 Nov 95       N Simpson       Converted the SMP rate set for each
                                        entry to use the lookup meaning instead
                                        of the lookup code.
        30 Nov 95       N Simpson       Changed code creating stoppages for late
                                        absence notification. This should ensure
                                        that the first absence day is included
                                        in the stoppage period calculation
         5 Dec 95       N Simpson       Added handling of average earnings
                                        errors.
        22 Aug 96       C Barbieri      Deleted function maternity_leave_exists.
                                        With Oracle 7.3.2 it is not possible to
                                        reference a function that returns a
                                        BOOLEAN inside a SELECT statement.

DATE        AUTHOR    VERSION  BUG NO   DESCRIPTION
----        ------    -------  ------   -----------
06 Jan 97   M Fender           434233   Fully qualified call to function within
                                        cursor period_of_service with package
                                        name. This is a workaround to a bug in
                                        PL/SQL which is fixed in version 2.3.3.
                                        See related bug 410159 for details.

04-Feb-97   RThirlby  30.34    447690   Altered function continous_employment-
                                        _date to return correct date.

18-Apr-97   RThirlby  30.35    479378   Cursor csr_personal_details altered to
                                        allow for rehired employees - added
                                        subquery with max function on date_start
12-Dec-97   RThirlby  30.36    590966   Fix.
08-Jan-98   RThirlby  30.37             SMP Entries problem solved - on absence
                                        delete the entries were not deleted, or
                                        correction entries were not created if
                                        the entries had been through a payroll
                                        run.
06-Apr-98   AParkes   30.38    648313   Prevented raising of no_data_found in
                                        new_entries block. Changed hr_trace
                                        outputs to prevent errors.
08-Apr-98   AParkes   30.39    653276   Performance fix to csr_existing_entries
                                        cursor; drove from per_assignments using
                                        woman.person_id
20-Apr-98   AParkes   30.40    647543   Corrected sub-query in cursor
                                        csr_existing_entries which prevents
                                        selection of correction entries; used
                                        base tables not dt views. Made cursor
                                        csr_existing_entries return the rate
                                        meaning, not code, to simplify api calls
                                        and comparisons between old and hypo
                                        entry rates. save_hypothetical_entries
                                        altered to update existing unprocessed
                                        entries covering the same week, but
                                        having incorrect amounts.
30-JUL-98   A.Myers   30.41    705553   Added date formatting around week-
                                        commencing passed in attribute 2 to
                                        procedure insert_element_entry (2 calls)
31-JUL-98   A.Myers   30.42    701750   Only inserting temp_affected row if it
                                        does not already exist (new procedure).
01-NOV-99   M.Vilrokx 110.8    960689   Added service.date_start to the cursor
                                        csr_personal_details. This date will be
                                        passed to ssp_ern_ins.ins in stead of the
                                        QW date if the latter is smaller than the
                                        service.date_start. When this is not done
                                        the ssp_ern_ins.ins procedure will try to
                                        validate the QW and raise error 35049
                                        because it is before the effective start
                                        date of the person.
06-JAN-2000  ILeath   110.9   1021179   Remove the stoppage for
                                        check_birth_confirmation. A stoppage
                                        should not be created if the woman
                                        notifies her employer of the date the
                                        baby was born.
11-AUG-2000  DFoster  110.10  1304683   Amended the average_earnings function so
                                        that it calls the nwe version of the
                                        calculate_average_earnings which can
                                        treat Sicknesses and Maternities
                                        differently.
30-MAY-2002 SMRobins  115.9             Changes to add changes for APR 2003
                                        legislation. Added woman.MPP_start_date
                                        to call to Calculate_SMP_amounts, and
                                        so extra p_MPP_start_date parameter
                                        to Calculate_SMP_amounts procedure.
                                        Then code splits within
                                        Calculate_SMP_amounts dependent on
                                        whether MPP start date before or
                                        after 06-APR-2003. The code for prior
                                        to 06-APR-2003 can be removed once
                                        this date has elapsed.
28-OCT-2002 SHVEERAB  115.10  2620611   Do not create stoppage for pre-matured
                                        birth of baby.
06-NOV-2002  GButler  115.12  2649315   Changes to EXPECTED_WEEK_OF_CONFINEMENT,
                                        CONTINUOUS_EMPLOYMENT_DATE
                                        functions and CHECK_DEATH procedure to resolve
                                        translation issues
13-NOV-2002  GButler  115.13  2620413   Change to entitled_to_smp, check on
                                        creation of late notification stoppages
15-NOV-2002  Bhaskar  115.14  2663735   New procedure check_employment_qw is
                                        created to check for employee
                                        terminated in qualifying week.
15-NOV-2002  Bhaskar  115.14  2663899   Check for employee death in the
                                        MPP pay period.
22-NOV-2002  BTHAMMIN 115.16  2663899   SMP was paid one week more than
                                        required
27-JAN-2003  GButler  115.17		nocopy fix to average_earnings - 2nd
					dummy variable created as placeholder
					to OUT param from ssp_ern_ins
24-FEB-2003  ABlinko  115.18  2811430   Amended csr_maternity in earnings_control
                                        for SAP/SPP
17-APR-2003  MMAhmad  115.19  2801805   Amended code for Late Absence Notification
14-MAY-2003  GButler  115.20  2939058	Changes to csr_period_of_service_qw in
					check_employment_qw to resolve bug
25-AUG-2003  asengar  115.21  3111736   Added to_number to make it compatible for 10g
25-FEB-2004  asengar  115.22  3436510   Cursor period_of_service and Procedure
                              3429978   entitled_to_SMP have been modified.
29-MAR-2004  skhandwa 115.23  3510141   Added condition to generate Late evidence stoppage

15-JUN-2004  ssekhar  115.24  3693735   Added to_number to make it compatible for 10g
12-JUL-2004  ablinko  115.25  3682122   Changes for recalculating lump sum updates
11-OCT-2005  npershad 115.26  4621910   Fixed two problems with date conversion,
                                        one in the cursor csr_existing_entries
                                        and twice when calling insert_element_entry
09-FEB-2006  kthampan 115.27  4891953   Fixed performance bug.
21-MAR-2006  kthampan 115.28  5105039   Added function to calculate max SMP paid date.
16-JUN-2006  ajeyam   115.29  5210118   In check_continuity_rule procedure,
                                        period_of_service cursor changed to fetch the
                                        latest start date for rehired persons.
23-AUG-2006  kthampan 115.30  5482199   Change from per_people_f and per_assignments_f
                                        to per_all_people_f and per_all_assignments_f
19-SEP-2006  kthampan 115.31  5547703   Amend smp_control to call generate_payments
                                        with insert-mode if absence is > 0 and
                                        also change csr_check_if_existing_entries
                                        not to reference from per_absence_attendances
                                        table
19-OCT-2006  kthampan 115.32  5604330   Amend check_death to create the stoppage based
                                        on the '7 day rolling weeks', currently it
                                        will always created using the next Sunday after
                                        the date of death.
09-DEC-2006  kthampan 115.33  5706912   Amend procedure ins_ssp_temp_affected_rows_mat
                                        and person_control
06-JAN-2009  npannamp 115.34  7680593  In csr_existing_entries cursor, trimmed
                                        the Group seperator before calling to_number.
                                        'HR: Number Separator' profile causing issue.
15-May-2009  pbalu    115.35  8470655   Problems with 'Some work done' is corrected.
20-May-2009  pbalu    115.36  8470655   Changes for Code review coments
*/
--------------------------------------------------------------------------------
g_package  varchar2(33) := '  ssp_smp_pkg.';  -- Global package name
--
cursor csr_absence_details (p_maternity_id in number) is
        --
        -- Get details of maternity leave for a maternity, in chronological
        -- order of start date
        --
        select  absence.absence_attendance_id,
                absence.date_start,
                nvl (absence.date_end, hr_general.end_of_time) date_end,
                absence.date_notification,
                absence.accept_late_notification_flag
        from    per_absence_attendances ABSENCE
        where absence.maternity_id = p_maternity_id
        order by absence.date_start;
        --
--------------------------------------------------------------------------------
cursor csr_personal_details (p_maternity_id in number) is
        --
        -- Get details of the maternal woman
        --
        select  maternity.person_id,
                maternity.due_date,
                ssp_smp_pkg.qualifying_week (due_date) QW,
                ssp_smp_pkg.expected_week_of_confinement (due_date) EWC,
                maternity.maternity_id,
                maternity.actual_birth_date,
                maternity.live_birth_flag,
                maternity.start_date_with_new_employer,
                maternity.MPP_start_date,
                maternity.notification_of_birth_date,
                maternity.start_date_maternity_allowance,
                maternity.pay_SMP_as_lump_sum,
                person.date_of_death,
                service.date_start,
                nvl (service.final_process_date, hr_general.end_of_time)
                                                        FINAL_PROCESS_DATE
        from    ssp_maternities                         MATERNITY,
                per_all_people_f                        PERSON,
                per_periods_of_service                  SERVICE
        where   person.person_id = maternity.person_id
        and     person.person_id = service.person_id
        and     maternity.maternity_id = p_maternity_id
        --
        -- Bug 2663899
        -- When employee is terminated, the person.date_of_death
        -- is null in the old record. Check the dates with
        -- actual termination date+1
        --
        and     nvl(service.actual_termination_date+1,service.date_start)
                between person.effective_start_date
                and     person.effective_end_date
        and     service.date_start = (select max(serv.date_start)
                                     from per_periods_of_service serv
                                     where serv.person_id = person.person_id);
        --
--------------------------------------------------------------------------------
woman                           csr_personal_details%rowtype;
g_SMP_element                   csr_SMP_element_details%rowtype;
g_SMP_Correction_element        csr_SMP_element_details%rowtype;
--------------------------------------------------------------------------------
procedure get_SMP_correction_element (p_effective_date in date) is
--
l_proc        varchar2(72) := g_package||'get_SMP_correction_element';
--
procedure check_parameters is
        begin
        --
        hr_utility.trace (l_proc||'     p_effective_date = '
                ||to_char (p_effective_date));
        --
        hr_api.mandatory_arg_error (
                p_api_name      => l_proc,
                p_argument      => 'effective_date',
                p_argument_value=> p_effective_date);
        end check_parameters;
        --
begin
--
hr_utility.set_location (l_proc,1);
--
check_parameters;
--
open csr_SMP_element_details (p_effective_date,c_SMP_Corr_element_name);
fetch csr_SMP_element_details into g_SMP_Correction_element;

--hr_utility.trace('g_SMP_Correction_element'||g_SMP_Correction_element);

close csr_SMP_element_details;
--
hr_utility.set_location (l_proc,100);
--
end get_SMP_correction_element;
--
--------------------------------------------------------------------------------
procedure get_SMP_element (p_effective_date in date) is
--
l_proc        varchar2(72) := g_package||'get_SMP_element';
--
procedure check_parameters is
        begin
        --
        hr_utility.trace (l_proc||'     p_effective_date = '
                ||to_char (p_effective_date));
        --
        hr_api.mandatory_arg_error (
                p_api_name      => l_proc,
                p_argument      => 'effective_date',
                p_argument_value=> p_effective_date);
        end check_parameters;
        --
begin
--
hr_utility.set_location (l_proc,1);
--
check_parameters;
--
open csr_SMP_element_details (p_effective_date,c_SMP_element_name);
fetch csr_SMP_element_details into g_SMP_element;
close csr_SMP_element_details;
--
hr_utility.set_location (l_proc,100);
--
end get_SMP_element;
--
--------------------------------------------------------------------------------
function EXPECTED_WEEK_OF_CONFINEMENT
         --
         -- Returns the date on which the EWC starts
         --
        (p_due_date  in date)
        --
        -- Due date comes from the woman's maternity record
        --
        return date is
        --
-- EWC is the Sunday prior to the due date
--
-- l_EWC  date := (next_day (p_due_date,'SUNDAY') -7);
--
l_EWC                  date;
l_sunday               varchar2(100) := to_char(to_date('07/01/2001','DD/MM/YYYY'),'DAY');


begin
--
hr_utility.set_location(g_package||'EXPECTED_WEEK_OF_CONFINEMENT',1);

l_EWC := (next_day (p_due_date,l_sunday) -7);

hr_utility.trace('l_EWC: '||l_EWC);

hr_utility.set_location(g_package||'EXPECTED_WEEK_OF_CONFINEMENT',99);

return l_EWC;
--
end expected_week_of_confinement;
--
--------------------------------------------------------------------------------
function QUALIFYING_WEEK
         --
         -- Returns the start date of the QW
         --
         (p_due_date in date)
         --
         return date is
         --
-- QW is the EWC minus the QW weeks from the SMP element
--
l_QW    date;
l_SMP_element   csr_SMP_element_details%rowtype;
--
begin
--
open csr_SMP_element_details (p_due_date, c_SMP_element_name);
fetch csr_SMP_element_details into l_SMP_element;
close csr_SMP_element_details;
--
l_QW := expected_week_of_confinement (p_due_date)
                - (l_SMP_element.qualifying_week);
return l_QW;
--
end qualifying_week;
--
--------------------------------------------------------------------------------
function EARLIEST_MPP_START_DATE (p_due_date in date) return date is
--
-- The earliest MPP start date, under normal circumstances is the EWC minus
-- the number of weeks specified on the SMP element for earliest SMP start
--
l_earliest_MPP_start    date;
l_SMP_element           csr_SMP_element_details%rowtype;
--
begin
--
open csr_SMP_element_details (p_due_date,c_SMP_element_name);
fetch csr_SMP_element_details into l_SMP_element;
close csr_SMP_element_details;
--
l_earliest_MPP_start := Expected_Week_of_Confinement (p_due_date)
                                - (l_SMP_element.earliest_start_of_MPP);
return l_earliest_MPP_start;
--
end earliest_MPP_start_date;
--
--------------------------------------------------------------------------------
function CONTINUOUS_EMPLOYMENT_DATE (p_due_date in date) return date is
--
-- The continuous employment start date is the date on which the woman must
-- have been employed (and continuously from then to the QW) in order to
-- qualify for SMP. It is the QW minus the continuous employment period
-- specified on the SMP element.
-- Bug 447690 a woman must have started work on or before the last day of the
-- week which starts 182 days (26 weeks) before the last day of the QW. In
-- SMP weeks start on Sunday and end on Saturday.
--
l_SMP_element                   csr_SMP_element_details%rowtype;
l_Continuously_employed_since   date;

l_saturday                      varchar2(100) := to_char(to_date('06/01/2001','DD/MM/YYYY'),'DAY');

--
begin
--
hr_utility.set_location(g_package||'CONTINUOUS_EMPLOYMENT_DATE',1);

open csr_SMP_element_details (p_due_date,c_SMP_element_name);
fetch csr_SMP_element_details into l_SMP_element;
close csr_SMP_element_details;

hr_utility.set_location(g_package||'CONTINUOUS_EMPLOYMENT_DATE',2);
--

l_Continuously_employed_since :=
      next_day(next_day(Qualifying_Week (p_due_date),l_saturday)
      - (l_SMP_element.continuous_employment_period),l_saturday);

hr_utility.trace('l_Continuously_employed_since: '||l_Continuously_employed_since);

hr_utility.set_location(g_package||'CONTINUOUS_EMPLOYMENT_DATE',99);
--
return l_Continuously_employed_since;
--
end continuous_employment_date;
--
--------------------------------------------------------------------------------
function MATERNITY_RECORD_EXISTS (p_person_id in number) return boolean is
--
cursor maternity_record is
        select  1
        from    ssp_maternities
        where   person_id = p_person_id;
--
l_dummy         number (1);
l_maternity_record_exists       boolean;
--
begin
--
open maternity_record;
fetch maternity_record into l_dummy;
l_maternity_record_exists := maternity_record%found;
close maternity_record;
--
return l_maternity_record_exists;
--
end maternity_record_exists;
--
--------------------------------------------------------------------------------
function AVERAGE_EARNINGS return number is
--
l_average_earnings      number := null;
l_effective_date        date := null;
l_dummy                 number;
l_dummy2		number; -- nocopy fix, placeholder variable
l_user_entered          varchar2(30) := 'N'; -- DFoster 1304683
l_absence_category      varchar2(30) := 'M'; --DFoster 1304683
l_payment_periods       number := null; --DFoster 1304683
l_proc                  varchar2(72) := g_package||'average_earnings';
--
cursor csr_average_earnings is
        select  average_earnings_amount
        from    ssp_earnings_calculations
        where   person_id = woman.person_id
        and     effective_date = l_effective_date;
--
begin
--
hr_utility.set_location ('Entering '||l_proc,1);
--
if woman.actual_birth_date is not null then
   l_effective_date := least (greatest(woman.QW, woman.date_start), ssp_smp_support_pkg.start_of_week
                                                     (woman.actual_birth_date));
else
   l_effective_date := greatest(woman.QW, woman.date_start);
end if;
--
open csr_average_earnings;
fetch csr_average_earnings into l_average_earnings;
if csr_average_earnings%notfound
then
   ssp_ern_ins.ins (p_earnings_calculations_id  => l_dummy,
                    p_object_version_number     => l_dummy2,
                    p_person_id                 => woman.person_id,
                    p_effective_date            => l_effective_date,
                    p_average_earnings_amount   => l_average_earnings,
                    p_user_entered              => l_user_entered, --DFoster 1304683
                    p_absence_category          => l_absence_category, --DFoster 1304683
                    p_payment_periods           => l_payment_periods); --DFoster 1304683
end if;
--
close csr_average_earnings;
--
hr_utility.set_location ('Leaving '||l_proc,10);
--
return l_average_earnings;
--
end average_earnings;
--------------------------------------------------------------------------------
function entitled_to_SMP (p_maternity_id in number) return boolean is
--
-- See header for description of this procedure.
--
no_prima_facia_entitlement      exception;
invalid_absence_date            exception;
l_work_start_date               date := hr_general.end_of_time;
stoppage_end_date               date := null;
no_of_absence_periods           integer := 0;
l_proc                          varchar2(72) := g_package||'entitled_to_SMP';
l_keep_stoppages                boolean default FALSE;
--
cursor csr_no_of_absences is
        --
        -- Get the number of distinct absences within a maternity pay period
        --
        select  count (*)
        from    per_absence_attendances
        where   person_id = woman.person_id
        and     maternity_id = p_maternity_id;
       --
       --  returns entries associated with a maternity_id.
cursor csr_check_if_existing_entries is
       --
select  /*+ ORDERED use_nl(paa,paaf,etype,entry) */
        entry.element_entry_id,
        entry.effective_start_date
from    per_all_assignments_f   PAAF,
        pay_element_types_f     ETYPE,
        pay_element_entries_f   ENTRY
where   PAAF.person_id   = woman.person_id
and     ETYPE.element_name = c_SMP_element_name
and     ETYPE.legislation_code = 'GB'
and     ENTRY.element_type_id = ETYPE.element_type_id
and     entry.creator_type = c_SMP_creator_type
and     entry.creator_id   = p_maternity_id
and     entry.assignment_id = PAAF.assignment_id
and not exists (
        --
        -- Do not select entries which have already had reversal action
        -- taken against them because they are effectively cancelled out.
        --
        select 1
        from pay_element_entries_f      ENTRY2
        where entry.element_entry_id=entry2.target_entry_id
        and   entry.assignment_id = entry2.assignment_id)
        --
and not exists (
        --
        -- Do not select reversal entries
        --
        select  1
        from    pay_element_links_f LINK,
                pay_element_types_f TYPE
        where   link.element_link_id = entry.element_link_id
        and     entry.effective_start_date between link.effective_start_date and link.effective_end_date
        and     link.element_type_id = type.element_type_id
        and     link.effective_start_date between type.effective_start_date and type.effective_end_date
        and     type.element_name = c_SMP_Corr_element_name);
--
l_existing_entries              csr_check_if_existing_entries%rowtype;
--
procedure create_stoppage (
        --
        -- Create a stoppage of payment for SMP
        --
        p_reason        in varchar2,
        p_withhold_from in date,
        p_withhold_to   in date default null
        ) is
        --
        l_proc          varchar2(72) := g_package||'create_stoppage';
        l_dummy         number;
        l_reason_id     number;
        --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace (l_proc||'     p_reason = '||p_reason);
                hr_utility.trace (l_proc||'     withhold from '
                        ||to_char (p_withhold_from));
                hr_utility.trace (l_proc||'     withhold to '
                        ||to_char (p_withhold_to));
                --
                hr_api.mandatory_arg_error (
                        p_api_name      => l_proc,
                        p_argument      => 'reason',
                        p_argument_value=> p_reason);
                        --
                hr_api.mandatory_arg_error (
                        p_api_name      => l_proc,
                        p_argument      => 'withhold_from',
                        p_argument_value=> p_withhold_from);
                        --
                end check_parameters;
                --
        begin
        --
        hr_utility.set_location (l_proc,1);
        --
        check_parameters;
        --
        l_reason_id := ssp_smp_support_pkg.withholding_reason_id (
                                g_SMP_element.element_type_id,
                                p_reason);
                                --
        if not ssp_smp_support_pkg.stoppage_overridden (
                                p_maternity_id => p_maternity_id,
                                p_reason_id => l_reason_id)
        then
          --
          -- Only create the stoppage if there is not already a stoppage marked
          -- as overridden. Thus, overriding a stoppage effectively blocks that
          -- reason being used to withhold payment for this person.
          --
          ssp_stp_ins.ins (p_withhold_from => p_withhold_from,
                        p_withhold_to   => p_withhold_to,
                        p_stoppage_id   => l_dummy,
                        p_object_version_number => l_dummy,
                        p_maternity_id  => p_maternity_id,
                        p_user_entered  => 'N',
                        p_reason_id     => l_reason_id);
        else
           hr_utility.trace (l_proc||'  Stoppage is overridden');
        end if;
        --
        hr_utility.set_location (l_proc,100);
        --
        end create_stoppage;
        --
procedure remove_stoppages is
        --
        -- Remove old system, non-overridden stoppages
        --
        cursor csr_stoppages is
                select  stoppage_id
                from    ssp_stoppages
                where   user_entered <>'Y'
                and     override_stoppage <> 'Y'
                and     maternity_id = p_maternity_id;
                --
        l_dummy number;
        l_proc varchar2 (72) := g_package||'remove_stoppages';
        --
        begin
        --
        hr_utility.set_location (l_proc,1);
        --
        for each_stoppage in csr_stoppages LOOP
           ssp_stp_del.del (p_stoppage_id => each_stoppage.stoppage_id,
                            p_object_version_number => l_dummy);
        end loop;
        --
        hr_utility.set_location (l_proc,100);
        --
      end remove_stoppages;
      --
procedure check_continuity_rule is
        --
        -- Check that the woman has the right amount of continuous service to
        -- qualify for SMP
        --
        cursor period_of_service is
                --
                -- Check the period of service length up to the QW start date
                --
                -- 5210118 starts
                select 1
                from   per_periods_of_service
                where  person_id = woman.person_id
                and    ssp_smp_pkg.continuous_employment_date(woman.due_date) >=
                       (select max(date_start)
                        from   per_periods_of_service
                        where  person_id = woman.person_id
                       );
                -- 5210118 ends
              --and     nvl (actual_termination_date, hr_general.end_of_time) -- BUG 3436510
           --                  >= woman.QW;
        --
        l_dummy number (1);
        l_proc  varchar2 (72) := g_package||'check_continuity_rule';
        --
        begin
        --
        hr_utility.set_location (l_proc,1);
        --
        open period_of_service;
        fetch period_of_service into l_dummy;
        --
        if period_of_service%notfound then
          --
          -- Stop all SMP payment for the maternity because the woman has not
          -- been continuously employed for long enough.
          --
          create_stoppage (p_withhold_from => woman.MPP_start_date,
                           p_reason => 'Insufficient employment');
        end if;
        --
        close period_of_service;
        --
        hr_utility.set_location (l_proc,100);
        --
        end check_continuity_rule;
        --
--
-- New procedure for bug 2663735
--
procedure check_employment_qw is
  --
  -- retrieve period of service details relating to this maternity
  --
  cursor csr_period_of_service_qw is
  select nvl(ser.actual_termination_date, hr_general.end_of_time)  termination_date
        ,leaving_reason               leaving_reason
  from   per_periods_of_service ser
  where  ser.person_id       = woman.person_id
  and    ssp_smp_pkg.continuous_employment_date(woman.due_date)
  	 between ser.date_start and nvl(ser.actual_termination_date, hr_general.end_of_time);
  --
  l_proc              varchar2(72) := g_package||'check_employment_qw';
  l_termination_date  per_periods_of_service.actual_termination_date%type;
  l_leaving_reason    hr_lookups.meaning%type;
  --
  -- Local Function
  function get_leaving_reason(p_leaving_reason in varchar2)
  return varchar2 is
    cursor csr_leaving_reason is
    select upper(meaning)
    from   hr_lookups
    where  lookup_type = 'LEAV_REAS'
    and    lookup_code = p_leaving_reason
    and    enabled_flag = 'Y' ;
    --
    l_leaving_reason hr_lookups.meaning%type;
  begin
    open  csr_leaving_reason;
    fetch csr_leaving_reason into l_leaving_reason;
    close csr_leaving_reason;
    --
    return nvl(l_leaving_reason,'-1');
  end get_leaving_reason;
  --
begin
  hr_utility.set_location('Entering : '||l_proc,1);
  --
  open  csr_period_of_service_qw;
  fetch csr_period_of_service_qw into l_termination_date
                                     ,l_leaving_reason ;
  close csr_period_of_service_qw;
  --

  l_leaving_reason := get_leaving_reason(l_leaving_reason);
  --
  hr_utility.set_location(l_proc,2);
  --
  --
  -- Bug 2663735
  -- For current regulations (due date less than 06-APR-2003)
  -- If an employee is terminated in between QW and Due Date
  -- she is not entitled to SMP.
  -- But the employee gets complete SMP according to the
  -- new regulations (due date after 06-APR-2003)
  --
  if woman.due_date >= fnd_date.canonical_to_date('2003/04/06 00:00:00') then
    hr_utility.set_location(l_proc,3);
    if l_termination_date < woman.qw then
      hr_utility.set_location(l_proc,4);
      create_stoppage(p_withhold_from => l_termination_date + 1
                     ,p_reason        => 'Not employed in QW' );
    end if;
  else
    hr_utility.set_location(l_proc,5);
    if (l_termination_date
        between woman.qw
        and     nvl(woman.MPP_start_date
                   ,ssp_smp_pkg.earliest_mpp_start_date(woman.due_date)) )
       and
       (l_leaving_reason <> 'MATERNITY')
       then
         hr_utility.set_location(l_proc,6);
         create_stoppage(p_withhold_from => l_termination_date + 1
                        ,p_reason        => 'Insufficient employment' );
    elsif l_termination_date < woman.qw then
         hr_utility.set_location(l_proc,7);
         create_stoppage(p_withhold_from => l_termination_date + 1
                        ,p_reason        => 'Not employed in QW' );
    end if;
    hr_utility.set_location(l_proc,8);
  end if;
  --
  hr_utility.set_location('Leaving : '||l_proc,9);
  --
end check_employment_qw;
--
procedure check_stillbirth is
        --
        -- Check the pregnancy condition for qualification for SMP
        --
        l_proc varchar2 (72) := g_package||'check_stillbirth';
        --
        begin
        --
        hr_utility.set_location (l_proc,1);
        --
        -- Woman must be still pregnant, have had a live birth, or have had a
        -- stillbirth after the threshhold week to be eligible for SMP
        --
        if      NOT (woman.actual_birth_date is null
                or woman.live_birth_flag = 'Y'
                or woman.actual_birth_date > woman.EWC
                                - g_SMP_element.stillbirth_threshhold_week)
        then
          --
          -- Stop SMP payment from the start of the week in which the absence
          -- started.
          --
          create_stoppage (p_withhold_from => woman.MPP_start_date,
                           p_reason => 'Stillbirth');
        end if;
        --
        hr_utility.set_location (l_proc,100);
        --
        end check_stillbirth;
        --
procedure check_new_employer is
        --
        -- Check the woman has not been employed by a new employer after the
        -- birth of her child
        --
        l_proc  varchar2 (72) := g_package||'check_new_employer';
        --
        begin
        --
        hr_utility.set_location (l_proc,1);
        --
        if woman.start_date_with_new_employer >= woman.actual_birth_date then
          --
          -- Stop SMP payment from the start of the week in which the woman
          -- started work for a new employer after the birth of her child.
          --
          create_stoppage (p_withhold_from => ssp_smp_support_pkg.start_of_week
                                           (woman.start_date_with_new_employer),
                           p_reason => 'Worked for another employer');
        end if;
        --
        hr_utility.set_location (l_proc,100);
        --
        end check_new_employer;
        --
procedure check_maternity_allowance is
        --
        -- SMP ceases when SMA starts.
        --
        l_proc  varchar2 (72) := g_package||'check_maternity_allowance';
        --
        begin
        --
        hr_utility.set_location (l_proc,1);
        --
        if woman.start_date_maternity_allowance is not null then
          --
          -- Stop SMP payment from the start of the week in which SMA was first
          -- paid.
          --
          create_stoppage (p_withhold_from => ssp_smp_support_pkg.start_of_week
                                         (woman.start_date_maternity_allowance),
                           p_reason => 'Employee is receiving SMA');
        end if;
        --
        hr_utility.set_location (l_proc,100);
        --
        end check_maternity_allowance;
        --
procedure check_death is
  --
  -- SMP ceases after the death of the woman.
  --
  l_proc            varchar2 (72) := g_package||'check_death';
  l_sunday          varchar2(100)
                    := to_char(to_date('07/01/2001','DD/MM/YYYY'),'DAY');
  --
  -- Bug 2663899 Start
  --
  mpp_pay_period_end  date;
  current_mpp_period  number := 126;
  new_mpp_period      number := 182;
  mpp_start_date      date   := nvl(woman.MPP_start_date
                                   ,ssp_smp_pkg.earliest_mpp_start_date
                                    (woman.due_date));
  -- Bug 2663899 End
  cursor csr_get_week_day is
  select to_char(mpp_start_date,'DAY')
  from   dual;
  --
  l_day_of_the_week varchar2(20);
  --
  begin
  --
  hr_utility.set_location (l_proc,1);
  --
  if woman.date_of_death is not null then
    --
    -- SMP ceases on the Saturday following death
    --
    -- Bug 2663899 start
    /*
    if woman.due_date >= fnd_date.canonical_to_date('2003/04/06 00:00:00')
    then
      mpp_pay_period_end := mpp_start_date + new_mpp_period;
    else
      mpp_pay_period_end := mpp_start_date + current_mpp_period;
    end if;
    */
    mpp_pay_period_end := mpp_start_date + (g_SMP_element.maximum_mpp * 7);
    --
    if woman.date_of_death between mpp_start_date
                           and mpp_pay_period_end then

       open csr_get_week_day;
       fetch csr_get_week_day into l_day_of_the_week;
       close csr_get_week_day;
       -- Instead of using the next sunday, the code will use the '7-day rolling week'
       -- method where if the MPP start on Wednesday, the week will end on Tuesday
       -- We can assume that the MPP start date is correct as the validation is done
       -- when the user entered the absence/maternity record.
      create_stoppage (p_withhold_from => next_day (woman.date_of_death,
                                                    l_day_of_the_week)  --l_sunday)
                      ,p_reason => 'Employee died');
    end if;
    -- Bug 2663899 end
  end if;
  --
  hr_utility.set_location (l_proc,100);
  --
end check_death;
--
procedure check_average_earnings is
        --
        -- The woman must earn enough to qualify for SMP
        --
        l_proc varchar2 (72) := g_package||'check_average_earnings';
        l_average_earnings              number := average_earnings;
        l_reason_for_no_earnings        varchar2 (80) := null;
        earnings_not_derived            exception;
        --
        begin
        --
        hr_utility.set_location (l_proc,1);
        --
        if l_average_earnings = 0
        then
           --
           -- If the average earnings figure returned is zero then check that
           -- no error message was set. Error messages will be set for system-
           -- generated average earnings when the earnings could not be derived
           -- for some reason, but to allow this procedure to continue, no error
           -- will be raised.
           --
           l_reason_for_no_earnings:=ssp_smp_support_pkg.average_earnings_error;
           --
           if l_reason_for_no_earnings is not null then
              create_stoppage (p_withhold_from => woman.MPP_start_date,
                               p_reason => l_reason_for_no_earnings);
              --
              raise earnings_not_derived;
           end if;
        end if;
        --
        if l_average_earnings
                < ssp_smp_support_pkg.NI_Lower_Earnings_Limit (woman.QW)
        then
          --
          -- Stop SMP payment from the MPP start date
          --
          create_stoppage (p_withhold_from => woman.MPP_start_date,
                           p_reason => 'Earnings too low');
        end if;
        --
        hr_utility.set_location (l_proc,100);
        --
        exception
        --
        when earnings_not_derived then
          --
          -- Exit silently from this procedure
          --
          hr_utility.trace (l_proc||'   Earnings not derived');
          null;
          --
        end check_average_earnings;
        --
procedure check_medical_evidence is
        --
        -- Check the acceptability of the maternity evidence
        --
        cursor medical is
                select  *
                from    ssp_medicals
                where   maternity_id = woman.maternity_id
                and     evidence_status = 'CURRENT';
                --
        l_proc varchar2 (72) := g_package||'check_medical_evidence';
        l_medical       medical%rowtype;
        --
        begin
        --
        hr_utility.set_location (l_proc,1);
        --
        open medical;
        fetch medical into l_medical;
        --
        if medical%notfound -- no medical evidence recorded
        or (medical%found and
                --
                -- evidence is dated too early
                --
           (l_medical.evidence_date < woman.EWC
                                        - g_SMP_element.earliest_SMP_evidence)
                --
                -- evidence was received late for no good reason
                --
           or (l_medical.evidence_received_date > woman.MPP_start_date
                                        + g_SMP_element.latest_SMP_evidence
              and l_medical.accept_late_evidence_flag = 'N')
                --
                -- evidence was received late, even after extension allowed
                --
           or (l_medical.evidence_received_date > woman.MPP_start_date
                                        + g_SMP_element.extended_SMP_evidence)
		--
                -- Added condition for bug 3510141
		-- evidence was received late, after mpp_notice_requirement_period
                -- Bug 3693735 Added to_number to make the code compatible with 10g
           or (l_medical.evidence_received_date > woman.MPP_start_date
                                        - to_number(g_SMP_element.mpp_notice_requirement)))
        then
          --
          -- Stop SMP payment from the start of the week in which the MPP
          -- started.
          --
          create_stoppage (p_withhold_from => woman.MPP_start_date,
                           p_reason => 'Late/unacceptable evidence');
        end if;
        --
        close medical;
        --
        hr_utility.set_location (l_proc,100);
        --
        end check_medical_evidence;
        --
procedure check_birth_confirmation is
        --
        -- Check that confirmation of birth was received in good time.
        --
        l_proc  varchar2 (72) := g_package||'check_birth_confirmation';
        --
        begin
        --
        hr_utility.set_location (l_proc,1);
        --
        --
        -- This should not create a stoppage. A quick fix for bug 1021179
        -- is to comment out the stoppage process.
        --
        null;

--      if (woman.actual_birth_date is not null
--      and (nvl (woman.notification_of_birth_date, sysdate)
--              > woman.actual_birth_date
--                              + g_SMP_element.notice_of_birth_requirement))
--      then
          --
           -- Stop SMP payment from the start of the week in which the MPP
           -- started.
           --
--          create_stoppage (p_withhold_from => woman.MPP_start_date,
--                          p_reason => 'Late notification of birth');
--      end if;
        --
        hr_utility.set_location (l_proc,100);
        --
        end check_birth_confirmation;
        --
procedure check_parameters is
        --
        begin
        --
        hr_utility.trace (l_proc||'     p_maternity_id = '
                ||to_char (p_maternity_id));
        --
        hr_api.mandatory_arg_error (
                p_api_name      => l_proc,
                p_argument      => 'maternity_id',
                p_argument_value=> p_maternity_id);
                --
        end check_parameters;
        --
begin
--
hr_utility.set_location (l_proc,1);
--
check_parameters;
--
-- Get the details of the woman and her maternity.
--
open csr_personal_details (p_maternity_id);
fetch csr_personal_details into woman;
--
if csr_personal_details%notfound
then
   --
   -- If no maternity record exists then there can be no entitlement to SMP
   --
   close csr_personal_details;
   --
   hr_utility.trace (l_proc||'  Woman has no maternity record - exiting');
   --
   raise no_prima_facia_entitlement;
end if;
--
close csr_personal_details;
--
if woman.MPP_start_date is null then
   --
   -- If the MPP has not started then there is no entitlement to SMP.
   --
   hr_utility.trace (l_proc||'  Woman has no MPP start date - exiting');
   --
   raise no_prima_facia_entitlement;
end if;
--
-- Count how many absences there are for the maternity.
--
open csr_no_of_absences;
fetch csr_no_of_absences into no_of_absence_periods;
close csr_no_of_absences;
--
if no_of_absence_periods = 0
then
   --
   -- check if entries exist despite there being no absence
   --
   open csr_check_if_existing_entries;
   fetch csr_check_if_existing_entries into l_existing_entries;
   --
   if csr_check_if_existing_entries%NOTFOUND
   then
      hr_utility.trace (l_proc||'    Woman has not stopped work - exiting');
      raise no_prima_facia_entitlement;
   end if;
   --
   -- if entries are found then the absence has been deleted and entries remain
   -- that must be dealt with
   --
   while csr_check_if_existing_entries%FOUND LOOP
      fetch csr_check_if_existing_entries into l_existing_entries;
   end loop;
   --
   close csr_check_if_existing_entries;
   l_keep_stoppages := TRUE;
end if;
--
-- Having established a prima facia entitlement to SMP, perform checks which
-- may lead to creation of stoppages for particular periods.
--
hr_utility.set_location ('ssp_smp_pkg.entitled_to_SMP',2);
--
-- Get the SMP legislative parameters.
--
get_SMP_element (woman.due_date);
--
-- Clear stoppages created by previous calculations of SMP but if an absence
-- is being deleted, then must keep stoppages so that when later comparison of
-- old_entry and hypothetical_entry is done then stoppages are still there.
--
if not l_keep_stoppages then
   remove_stoppages;
end if;
--
for absence in csr_absence_details (p_maternity_id) LOOP
  --
  -- Check that sufficient notification of absence was given
  --

  if
     -- for pre-matured birth of baby, Bug 2620611
     -- Bug 2620413, check notified date of absence is less than
     -- or equal to the actual birth date + 21/28 days for cases
     -- of premature birth (extended allowable date for notifications rule)
     --
   (woman.actual_birth_date < woman.due_date
           and absence.date_notification > woman.actual_birth_date
                                        + g_SMP_element.MPP_notice_requirement)
     --
   or  (absence.date_notification > absence.date_start
                                - to_number(g_SMP_element.MPP_notice_requirement)
     -- BUG 3111736 Added to_number to make it compatible for 10g
     -- and there was no acceptable reason for the delay
         and absence.accept_late_notification_flag = 'N'
     -- and baby was not born prematurely
         and nvl(woman.actual_birth_date,hr_general.end_of_time) >= woman.due_date )
  then
    --
    -- Stop SMP payment from the start of the week in which the absence
    -- starts, to the end of the notice period
    --
    stoppage_end_date := g_SMP_element.MPP_notice_requirement
                        + absence.date_start - 1;
    --
    create_stoppage (
        --p_withhold_from => ssp_smp_support_pkg.start_of_week
         --                                               (absence.date_start),
       -- p_withhold_to => ssp_smp_support_pkg.end_of_week (stoppage_end_date),
    p_withhold_from => woman.MPP_start_date,
        p_reason => 'Late absence notification');
  end if;
  --
  hr_utility.set_location ('ssp_smp_pkg.entitled_to_SMP',3);

  --8470655 begin
  if to_char(absence.date_start-1,'DAY') = to_char(woman.MPP_start_date - 1,'DAY')
  then
  stoppage_end_date := absence.date_start-1;
  else
  stoppage_end_date := next_day (absence.date_start-1, to_char(woman.MPP_start_date - 1,'DAY'));
  end if;
  --8470655 end
  --
  -- Check for any work done during the MPP.
  --
  if
     -- this is the first absence period in the MPP
     csr_absence_details%rowcount = 1
     --
     -- and the absence starts after the MPP start date
     and absence.date_start > woman.MPP_start_date
  then
  /* 8470655 Begin
     create_stoppage (p_reason => 'Some work was done',
                      p_withhold_from => woman.MPP_start_date,
                      p_withhold_to => ssp_smp_support_pkg.end_of_week
                                                       (absence.date_start -1));
   The Stoppage should be created on a '7 days rolling week'
*/
     create_stoppage (p_reason => 'Some work was done',
                      p_withhold_from => woman.MPP_start_date ,
                      p_withhold_to => stoppage_end_date);
--8470655 end
  end if;
  --
  if
     -- this is the last absence period in the MPP
     csr_absence_details%rowcount = no_of_absence_periods
     --
     -- and the absence period ends before the end of the MPP
     and absence.date_end < (g_SMP_element.maximum_MPP * 7)
                                + woman.MPP_start_date
     and woman.date_of_death is null -- Added the condition 3429978
  then
  /* 8470655 Begin
     create_stoppage (p_reason => 'Some work was done',
                      p_withhold_from => ssp_smp_support_pkg.start_of_week
                                                        (absence.date_end+1));
           The Stoppage should be created on a '7 days rolling week'
*/

     create_stoppage (p_reason => 'Some work was done',
                      p_withhold_from => next_day (absence.date_end -6, to_char(woman.MPP_start_date,'DAY')));
  --elsif -- Code will never enter the below portion hence changing the elsif to end if and if
  end if;
  if
--8470655 end
        -- there is a period of work between two absences
        l_work_start_date < absence.date_start
        and l_work_start_date < (g_SMP_element.maximum_MPP * 7)
                                        + woman.MPP_start_date
  then
     /*8470655 Begin
     create_stoppage (p_reason => 'Some work was done',
                p_withhold_from => ssp_smp_support_pkg.start_of_week
                                                        (l_work_start_date),
                p_withhold_to => ssp_smp_support_pkg.end_of_week
                                                (absence.date_start -1));
     */

        create_stoppage (p_reason => 'Some work was done',
                      p_withhold_from =>  next_day (l_work_start_date -7, to_char(woman.MPP_start_date,'DAY')) ,
                      p_withhold_to =>  stoppage_end_date );
     --
    /*
     The assignment for l_work_start_date should happen for all rows hence moving this out of the if condition.
     --the last row which may or may not have end date.
     if absence.date_end <> hr_general.end_of_time
     then
        l_work_start_date := absence.date_end + 1;
     else
     */

     --Intermediate Absences for a single Maternity record cannot have end date as end of time
     if absence.date_end = hr_general.end_of_time and
     csr_absence_details%rowcount < no_of_absence_periods
     then
     --8470655 end
        --
        -- This is not the last absence in the maternity but it has no end date.
        --
        hr_utility.trace (l_proc||'    ERROR: Invalid null absence end date');
        --
        raise invalid_absence_date;
     end if;
  end if;

  --8470655 Begin
  if absence.date_end <> hr_general.end_of_time
  then
        l_work_start_date := absence.date_end + 1;
  end if;
  --8470655 end

end loop;
--
check_continuity_rule;
check_stillbirth;
check_new_employer;
check_maternity_allowance;
check_death;
check_medical_evidence;
check_birth_confirmation;
-- bug 2663735
check_employment_qw;
check_average_earnings;
--
-- If we get this far the person is entitled to SMP (though stoppages may apply)
--
return TRUE;
--
exception
--
when invalid_absence_date then
   fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
   fnd_message.set_token ('PROCEDURE','ssp_smp_pkg.entitled_to_SMP');
   fnd_message.set_token ('STEP','3');
   --
when no_prima_facia_entitlement then
   --
   -- Exit silently; this will allow us to call this procedure with impunity
   -- from absences which are not maternity absences (e.g. via a row trigger)
   --
   return FALSE;
   --
end entitled_to_SMP;
--------------------------------------------------------------------------------
procedure generate_payments
--
        --
        -- Starting with the start of the Maternity Pay Period (MPP), create
        -- a nonrecurring entry for each week of maternity absence up to the
        -- end of the maternity absence or to the maximum number of weeks
        -- specified by the SMP rules. Note that there may be more than one
        -- absence for a maternity, and the absences should be put together;
        -- however, if the woman works for any part of a week (Sun-Sat), then
        -- that week does not count towards maternity pay.
        --
        -- If there is a stoppage which overlaps either partially or completely
        -- with the period covered by an entry then skip the creation of that
        -- entry and move on to the next week. There are two kinds of stoppages;
        -- those which apply temporarily, and those which apply forever once
        -- started. Stoppages only apply within a maternity. If there is a
        -- stoppage which applies forever (ie it has no end date), then there
        -- is no need to continue creating entries after the start of that
        -- stoppage. Temporary entries should only affect creation while they
        -- apply. A further feature of stoppages is that they may be overridden
        -- by the user; if the override flag is set, then take no acount of
        -- that stoppage when creating entries.
        --
        -- The maximum allowed number of weeks is held as a DDF segment on the
        -- SMP element.
        --
        -- Whilst each entry is created to cover a particular period of absence,
        -- the payroll period in which the entry resides is determined
        -- separately. The default is that the entry will be created in the
        -- payroll period which covers the end of the week of absence for which
        -- the entry is created. If, however, that payroll period is in the
        -- past, or has already been processed, or is closed, or is after the
        -- person's last standard process date, then the entry must be placed
        -- in the next open period for which no main payroll run has been
        -- performed and which falls around or before the last standard process
        -- date. If the entry cannot be created in any such period, for whatever
        -- reason, then an error should be raised and the user required to
        -- resolve the problem before any entry for the absence can be created.
        -- The user may choose to pay SMP as a lump sum, in which case all
        -- entries are to be placed in the next possible payroll period after
        -- the start of the Maternity Pay Period.
        --
        -- If any detail of the absence is changed, then the entries must be
        -- recalculated to ensure that the change is reflected in the
        -- payments. Therefore, we may be performing the entry creation when
        -- entries already exist for the absence. For each entry which we are
        -- about to create, we must check that there is not an existing entry
        -- which covers the same absence period. If there is not, then we
        -- create the entry as planned; if there is, then we must update the
        -- existing one rather than create a new one, if a change is required.
        -- However, if that entry has already been processed in a payroll run,
        -- then rather than updating it, we must ensure that the
        -- over/underpayment is corrected at the next opportunity. This is
        -- done by creating two entries; one which pays the correct amount
        -- and another, for the SMP Correction element, which reverses the
        -- incorrect payment by replicating it with a negative sign in front of
        -- the amount entry value. Before creating the negative entry, it is
        -- essential to check that there is not already a negative entry for
        -- the incorrect entry; we do not want to overcorrect.
        --
        -- The week commencing entry value is the date of the Sunday of the
        -- week for which this entry is being created.
        --
        -- The Rate entry value is simply 'Higher' or 'Lower'. The number of
        -- entries to be created at the higher rate is determined by the
        -- DDF segment on the SMP element. When creating entries for SMP,
        -- that number of entries is to be created at the higher rate before
        -- any are created at the lower rate, and so stoppages are always
        -- affecting the lower rate first.
        --
        -- The amount entry value is determined by the rate; if it is the
        -- higher rate, then the higer rate DDF segment of the SMP element
        -- will identify a percentage of average earnings. The average
        -- earnings should have been calculated by the entitlement check, for
        -- payroll users, or entered independently by HR users. If it is the
        -- lower rate, then the amount to be paid is held directly in the
        -- lower rate DDF segment on the SMP element.
        --
        -- Each entry created by this procedure is to have a creator type
        -- which identifies it as an SMP entry, and a creator_id which is
        -- the maternity_id.
        --
        -- p_deleting parameter has been added to carry out logic for
        -- dealing with deleted absences
--
(p_maternity_id in number,
 p_deleting     in boolean ) is
--
type date_table is table of date index by binary_integer;
type number_table is table of number index by binary_integer;
type varchar_table is table of varchar2 (80) index by binary_integer;
l_proc varchar2(72) := g_package||'generate_payments';
--
type SMP_entry is record (
        --
        element_entry_id        number_table,
        element_link_id         number_table,
        assignment_id           number_table,
        effective_start_date    date_table,
        effective_end_date      date_table,
        amount                  number_table,
        rate                    varchar_table,
        week_commencing         date_table,
        recoverable_amount      number_table,
        stopped                 varchar_table,
        dealt_with              varchar_table);
        --
--
-- A store for all the SMP entries that potentially may be granted to the woman.
--
hypothetical_entry      SMP_entry;
--
-- A tally of the number of weeks of the MPP which are subject to stoppages.
--
l_stopped_weeks         number := 0;
--
l_high_rate     varchar2 (80) := null;
l_low_rate      varchar2 (80) := null;
-- RT entries prob
l_no_of_absence_periods  integer := 0;
--
-- p_deleting passed into save_hypothetical_entries, so that logic can be
-- dealt with for deleted absences.
--
procedure save_hypothetical_entries (p_deleting in boolean ) is
        --
        -- Having generated the potential SMP entries, reconcile them with any
        -- previously granted entries for the same maternity.
        --
--Start Bug Fix for 7680593
-- When 'HR: Number Separator' profile is set to 'Y', then ssp_smp_support_pkg.value
-- returns amount with Group Seperator. Group seperator character has to be trimmed
-- before calling to_number.

l_group_separator  VARCHAR2(2) := substr(ltrim(to_char(1032,'0G999')),2,1);
--End Bug Fix for 6870415
    cursor csr_existing_entries is
      --
      -- Get all entries and entry values for the maternity
      --
      -- Decode the rate code to give the meaning using local variables
      -- populated earlier by Calculate_correct_SMP_rate
      -- these can then be passed directly into the hr_entry_api's and
      -- simplifies comparison with hypo entries
      --
      select    entry.element_entry_id,
        entry.element_link_id,
        entry.assignment_id,
        entry.effective_start_date,
        entry.effective_end_date,
        decode(ssp_smp_support_pkg.value(entry.element_entry_id,
          ssp_smp_pkg.c_rate_name),'HIGH',l_high_rate,l_low_rate) RATE,
        /*to_date (ssp_smp_support_pkg.value
            (entry.element_entry_id,
            ssp_smp_pkg.c_week_commencing_name),
          'DD-MON-YYYY') WEEK_COMMENCING,*/
	fnd_date.chardate_to_date(ssp_smp_support_pkg.value
	(entry.element_entry_id,ssp_smp_pkg.c_week_commencing_name)) WEEK_COMMENCING,
-- Start Bug Fix for 7680593
/*
        to_number(ssp_smp_support_pkg.value (entry.element_entry_id,
              ssp_smp_pkg.c_amount_name)) AMOUNT,
        to_number(ssp_smp_support_pkg.value (entry.element_entry_id,
              ssp_smp_pkg.c_recoverable_amount_name)) RECOVERABLE_AMOUNT
*/
        to_number(replace(ssp_smp_support_pkg.value (entry.element_entry_id,
              ssp_smp_pkg.c_amount_name), l_group_separator, '')) AMOUNT,
        to_number(replace(ssp_smp_support_pkg.value (entry.element_entry_id,
              ssp_smp_pkg.c_recoverable_amount_name), l_group_separator, '')) RECOVERABLE_AMOUNT
-- End Bug Fix for 7680593
      from      pay_element_entries_f ENTRY,
            per_all_assignments_f     asg
      where     creator_type = c_SMP_creator_type
      and creator_id = p_maternity_id
      and asg.person_id     = woman.person_id
      and asg.assignment_id = entry.assignment_id
      and       entry.effective_start_date between asg.effective_start_date
                                               and asg.effective_end_date
      and not exists (
        --
        -- Do not select entries which have already had reversal action taken
        -- against them because they are effectively cancelled out.
        --
        select 1
        from pay_element_entries_f      ENTRY2
        where entry.element_entry_id= entry2.target_entry_id
        and   entry.assignment_id   = entry2.assignment_id)
        --
      and not exists (
        --
        -- Do not select reversal entries
        --
        select 1
        from    pay_element_links_f LINK,
          pay_element_types_f TYPE
        where link.element_link_id = entry.element_link_id
        and     entry.effective_start_date between link.effective_start_date
                and link.effective_end_date
        and link.element_type_id = type.element_type_id
        and     link.effective_start_date between type.effective_start_date
                and type.effective_end_date
        and type.element_name = c_SMP_Corr_element_name);
                --
cursor csr_no_of_absences is
        --
        -- Get the number of distinct absences within a maternity pay period
        --
        select  count (*)
        from    per_absence_attendances
        where   person_id = woman.person_id
        and     maternity_id = p_maternity_id;
         --
    l_ins_corr_ele  boolean;
    l_dummy         number;
    Entry_number    integer;
    l_ern_calc_id   number;
    l_ob_v_no       number;
    l_new_ob_v_no   number;
    l_proc varchar2 (72) := g_package||'save_hypothetical_entries';
--
-- This procedure was a private procedure in the function entitled_to_smp. I
-- wanted to call it within this procedure (generate_payments) aswell, so
-- instead of making it a public procedure I have copied the procedure to here.
--
procedure remove_stoppages is
        --
        -- Remove old system, non-overridden stoppages
        --
        cursor csr_stoppages is
                --
                select  stoppage_id
                from    ssp_stoppages
                where   user_entered <>'Y'
                and     override_stoppage <> 'Y'
                and     maternity_id = p_maternity_id;
                --
        l_dummy number;
        l_proc varchar2 (72) := g_package||'.remove_stoppages';
        --
        begin
        --
        hr_utility.set_location (l_proc,1);
        --
        for each_stoppage in csr_stoppages LOOP
           ssp_stp_del.del (p_stoppage_id => each_stoppage.stoppage_id,
                            p_object_version_number => l_dummy);
        end loop;
        --
        hr_utility.set_location (l_proc,100);
        --
      end remove_stoppages;
        --
  begin
    --
    --hr_utility.trace_on(null,'ssp');
    hr_utility.set_location('Entering: '||l_proc,10);

    hr_utility.trace('woman.due_date='||woman.due_date);
    --
    get_SMP_correction_element (woman.due_date);
    --
    -- Check each existing SMP entry in turn against all the potential new ones.
    --
    <<OLD_ENTRIES>>

     hr_utility.trace('Old entries');


    for old_entry in csr_existing_entries
    LOOP
      --First loop through the hypothetical entries to see if there is one
      --which covers the same week as the old entry and is not subject to
      --a stoppage.  If there isn't one, invalidate the old entry.
      --Assume we don't need to correct the entry until we discover otherwise:
      --

      hr_utility.trace('Entered csr_existing_entries');

      l_ins_corr_ele := FALSE;
      begin
          hr_utility.trace('Entering begin');
        entry_number := 0;
        if p_deleting then
	   hr_utility.trace('Raising error');
           raise no_data_found; -- enter exception handler
        end if;
        LOOP

           hr_utility.trace('First loop');
          entry_number := entry_number +1;

          -- Exit the loop when we find a hypothetical entry covering the
          -- same week as the old entry, which is not subject to a stoppage.
          -- If no such match is found, then we will reach the end of the
          -- pl/sql table and attempt to read beyond the existing rows; this
          -- will cause us to enter the exception handler and indicate that
          -- no match was found.

          exit when ((old_entry.week_commencing
             = hypothetical_entry.week_commencing (entry_number)
             and not hypothetical_entry.stopped (entry_number) = 'TRUE'
             and g_smp_update = 'N')
                  or (old_entry.effective_start_date
             = hypothetical_entry.effective_start_date (entry_number)
             and old_entry.week_commencing
             = hypothetical_entry.week_commencing (entry_number)
             and not hypothetical_entry.stopped (entry_number) = 'TRUE'
             and g_smp_update = 'Y'));

	     hr_utility.trace('Exiting');
        end loop;

        hr_utility.trace (l_proc||' Old entry / Hypo entry time Match with values:');
        hr_utility.trace (l_proc||'        Rate: '
          ||old_entry.rate||' / '
          ||hypothetical_entry.rate (Entry_number));
        hr_utility.trace (l_proc||'      Amount: '
          ||old_entry.amount||' / '
          ||hypothetical_entry.amount (entry_number));
        hr_utility.trace (l_proc||' Recoverable: '
          ||old_entry.recoverable_amount||' / '
          ||hypothetical_entry.recoverable_amount (entry_number));
        hr_utility.trace (l_proc||'   Week Comm: '
          ||hypothetical_entry.week_commencing (entry_number) );
        --A hypo entry covers the same week as the old one
        if    old_entry.rate   = hypothetical_entry.rate (entry_number)
          and old_entry.amount = hypothetical_entry.amount(entry_number)
          and old_entry.recoverable_amount
                   = hypothetical_entry.recoverable_amount (entry_number)
        then
          -- the hypo entry has the same values as the old one
          -- don't create a correction element.
          -- don't create a new entry
          hypothetical_entry.dealt_with (entry_number) := 'TRUE';
          hr_utility.trace (l_proc||' leave unchanged');
        else
          if ssp_smp_support_pkg.entry_already_processed
                                            (old_entry.element_entry_id)
          then l_ins_corr_ele := TRUE;
          hr_utility.trace (l_proc||' processed - correct it');
          else
            -- update old entry
            hr_utility.trace (l_proc||' unprocessed - update it');
            hr_entry_api.update_element_entry (
              p_dt_update_mode => 'CORRECTION',
              p_session_date => old_entry.effective_start_date,
              p_element_entry_id => old_entry.element_entry_id,
              p_input_value_id1 => g_SMP_element.rate_id,
              p_input_value_id2 => g_SMP_element.amount_id,
              p_input_value_id3 => g_SMP_element.recoverable_amount_id,
              p_entry_value1=> hypothetical_entry.rate (entry_number),
              p_entry_value2=> hypothetical_entry.amount(entry_number),
              p_entry_value3=>
                      hypothetical_entry.recoverable_amount (entry_number));
            --
            --prevent insertion of new entry
            --
            hypothetical_entry.dealt_with (entry_number) := 'TRUE';
          end if;
        end if;
      exception

        when no_data_found then
          -- There was no new entry which exactly matched the old entry.
          -- or we are deleting.
          entry_number := null;
          hr_utility.trace (l_proc||' No Old entry - Hypo entry time Match');
          hr_utility.trace (l_proc||' or p_deleting is true');
          hr_utility.trace (l_proc||' Old entry values:');
          hr_utility.trace (l_proc||'        Rate: '||old_entry.rate);
          hr_utility.trace (l_proc||'      Amount: '||old_entry.amount);
          hr_utility.trace (l_proc||' Recoverable: '
                                        ||old_entry.recoverable_amount);
          if ssp_smp_support_pkg.entry_already_processed
                                            (old_entry.element_entry_id)
          then l_ins_corr_ele := TRUE;
            hr_utility.trace (l_proc||' Old entry already processed');
          else
            hr_utility.trace (l_proc||' Old entry NOT already processed');
            --Old entry not already processed so delete it
            hr_entry_api.delete_element_entry (
              p_dt_delete_mode => 'ZAP',
              p_session_date => old_entry.effective_start_date,
              p_element_entry_id => old_entry.element_entry_id);
          end if;
	when others then
	   hr_utility.trace('Entered error');
	   hr_utility.trace('SQL ERROR:='||SQLERRM);
      end;
      if l_ins_corr_ele
      then
        -- Create a correction element to reverse the old entry. Then create a
        -- brand new entry with the correct values.
        --
        hr_utility.trace (l_proc ||
                          ' Inserting CORRECTION entry for week commencing ' ||
                          to_char (old_entry.week_commencing));
        hr_utility.trace (l_proc||'              Old value / New value:');
        if entry_number is null then
          hr_utility.trace (l_proc||'        Rate: '
            ||old_entry.rate||' / NA');
          hr_utility.trace (l_proc||'      Amount: '
            ||old_entry.amount||' / NA');
          hr_utility.trace (l_proc||' Recoverable: '
            ||old_entry.recoverable_amount||' / NA');
        else
          hr_utility.trace (l_proc||'        Rate: '
            ||old_entry.rate||' / '
            ||hypothetical_entry.rate (Entry_number));
          hr_utility.trace (l_proc||'      Amount: '
            ||old_entry.amount||' / '
            ||hypothetical_entry.amount (entry_number));
          hr_utility.trace (l_proc||' Recoverable: '
            ||old_entry.recoverable_amount||' /'
            ||hypothetical_entry.recoverable_amount (entry_number));
        end if;
        --
        -- Determine the next available period in which to place the
        -- correction entry
        --

	hr_utility.trace('Correction Entry');

        ssp_smp_support_pkg.get_entry_details (
          p_date_earned  => old_entry.week_commencing,
          p_last_process_date => woman.final_process_date,
          p_person_id  => woman.person_id,
          p_element_type_id => g_SMP_Correction_element.element_type_id,
          p_element_link_id => old_entry.element_link_id,
          p_assignment_id  => old_entry.assignment_id,
          p_effective_start_date => old_entry.effective_start_date,
          p_effective_end_date => old_entry.effective_end_date,
          p_pay_as_lump_sum => woman.pay_SMP_as_lump_sum);
        --
        -- hr_entry_api's take the lookup meanings not the lookup codes.
        -- Fix to Bug 590966 converted rate codes to meanings before calling the
        -- api.  Later fix 647543 made old_entry (csr_existing_entries) return
        -- the meaning, so rate passed directly.
        --

	hr_utility.trace('Insert element entry');

        hr_entry_api.insert_element_entry (
          p_effective_start_date=> old_entry.effective_start_date,
          p_effective_end_date => old_entry.effective_end_date,
          p_element_entry_id  => l_dummy,
          p_target_entry_id  => old_entry.element_entry_id,
          p_assignment_id  => old_entry.assignment_id,
          p_element_link_id  => old_entry.element_link_id,
          p_creator_type  => c_SMP_creator_type,
          p_creator_id  => p_maternity_id,
          p_entry_type  => c_SMP_entry_type,
          p_input_value_id1=> g_SMP_correction_element.rate_id,
          p_input_value_id2=> g_SMP_correction_element.week_commencing_id,
          p_input_value_id3=> g_SMP_correction_element.amount_id,
          p_input_value_id4=> g_SMP_correction_element.recoverable_amount_id,
          p_entry_value1=> old_entry.rate,
        --p_entry_value2  => to_char(old_entry.week_commencing,'DD-MON-YYYY'),
	  p_entry_value2  => fnd_date.date_to_chardate(old_entry.week_commencing),
          p_entry_value3=> old_entry.amount * -1,
          p_entry_value4=> old_entry.recoverable_amount * -1);
        --
        --New entry will be created by brand_new_entries loop if not p_deleting
      end if;
      --
    end loop old_entries;
    --
    -- Having been through all the existing entries, we now check that we
    -- have dealt with all the newly derived entries by inserting any which
    -- were not flagged as dealt with during the above actions.
    --
    hr_utility.set_location (l_proc,20);
    --
    <<BRAND_NEW_ENTRIES>>
    begin
      if p_deleting then
        hr_utility.trace('Deleting an absence so don''t insert entries');
      else
        for new_entry in 1..g_SMP_element.maximum_MPP LOOP
          if (not hypothetical_entry.dealt_with (new_entry) = 'TRUE')
            and (not hypothetical_entry.stopped (new_entry) = 'TRUE')
          then
            hr_entry_api.insert_element_entry (
              p_effective_start_date =>
                          hypothetical_entry.effective_start_date (new_entry),
              p_effective_end_date =>
                          hypothetical_entry.effective_end_date (new_entry),
              p_element_entry_id => l_dummy,
              p_assignment_id  => hypothetical_entry.assignment_id (new_entry),
              p_element_link_id => hypothetical_entry.element_link_id (new_entry),
              p_creator_type  => c_SMP_creator_type,
              p_creator_id  => p_maternity_id,
              p_entry_type  => c_SMP_entry_type,
              p_input_value_id1 => g_SMP_element.rate_id,
              p_input_value_id2 => g_SMP_element.week_commencing_id,
              p_input_value_id3 => g_SMP_element.amount_id,
              p_input_value_id4 => g_SMP_element.recoverable_amount_id,
              p_entry_value1  => hypothetical_entry.rate (new_entry),
--            p_entry_value2  => hypothetical_entry.week_commencing (new_entry),
              p_entry_value2  => to_char(hypothetical_entry.week_commencing(new_entry),'DD-MON-YYYY'),
              p_entry_value3  => hypothetical_entry.amount (new_entry),
              p_entry_value4  =>
                          hypothetical_entry.recoverable_amount (new_entry));
          end if;
        end loop brand_new_entries;
      end if;
    exception
      when no_data_found then
        --
        -- We have run out of hypothetical entries to insert
        --
        null;
        --
    end;
    --
    -- Orphaned stoppages, associated with deleted absence can now be deleted
    -- This replaces cross product constraints that are no longer allowed.
    --
    open csr_no_of_absences;
    fetch csr_no_of_absences into l_no_of_absence_periods;
    close csr_no_of_absences;
    --
    if l_no_of_absence_periods = 0 then
      remove_stoppages;
    end if;
    --
    hr_utility.set_location(' Leaving: '||l_proc,100);
    --
  end save_hypothetical_entries;
        --
procedure derive_SMP_week (p_week_number in integer) is
        --
        -- Derive the start and end dates of the week covered by the SMP
        -- payment. This is done by finding out how many weeks into the MPP
        -- we are and finding the offset from the start date.
        --
        begin
        --
        hr_utility.set_location ('Entering: ssp_smp_pkg.derive_SMP_week',1);
        hr_utility.trace ('Entry number = '||to_char (p_week_number));
        --
        hypothetical_entry.week_commencing (p_week_number)
                := (woman.MPP_start_date + ((p_week_number -1) * 7));
        --
        hypothetical_entry.dealt_with (p_week_number) := 'FALSE';
        hypothetical_entry.stopped (p_week_number) := 'FALSE';
        hypothetical_entry.element_link_id (p_week_number) := null;
        hypothetical_entry.assignment_id (p_week_number) := null;
        --
        hr_utility.trace ('week_commencing = '
                ||to_char (hypothetical_entry.week_commencing (p_week_number)));
                --
        hr_utility.set_location ('Leaving : ssp_smp_pkg.derive_SMP_week',100);
        --
        end derive_SMP_week;
        --
procedure Check_SMP_stoppages (p_week_number in integer) is
        --
        -- Find any SMP stoppage for the maternity which overlaps a date range
        --
        employee_died varchar2 (30) := 'Employee died';
        --
        cursor csr_stoppages (p_start_date in date, p_end_date in date) is
                --
                -- Find any non-overridden stoppages
                --
                select  1
                from    ssp_stoppages STP,
                        ssp_withholding_reasons WRE
                where   stp.override_stoppage <> 'Y'
                --
                -- and the stoppage ovelaps the period or the stoppage is for
                -- death and is prior to the period
                --
                and     ((wre.reason <> employee_died
                           and stp.withhold_from <= p_end_date
                           and nvl (stp.withhold_to, hr_general.end_of_time)
                                >= p_start_date)
                        --
                        or (wre.reason = employee_died
                           -- Bug 2663899
                           and stp.withhold_from <= p_end_date))
                --
                and     stp.maternity_id = p_maternity_id
                and     stp.reason_id = wre.reason_id;
                --
        l_dummy integer (1);
        --
        begin
        --
        hr_utility.set_location ('ssp_smp_pkg.Check_SMP_stoppages',1);
        --
        hypothetical_entry.stopped (p_week_number) := 'FALSE';
        --
        open csr_stoppages (
                hypothetical_entry.week_commencing (p_week_number),
                ssp_smp_support_pkg.end_of_week
                        (hypothetical_entry.week_commencing (p_week_number)));
        --
        fetch csr_stoppages into l_dummy;
        --
        if csr_stoppages%found
        then
          --
          -- There is an overlap between the SMP week and a stoppage so no SMP
          -- is payable.
          --
          hypothetical_entry.stopped (p_week_number) := 'TRUE';
          --
          hr_utility.trace ('Entry is STOPPED');
          --
          -- Keep a tally of the number of stopped weeks
          --
          l_stopped_weeks := l_stopped_weeks +1;
        end if;
        --
        close csr_stoppages;
        --
        hr_utility.set_location ('ssp_smp_pkg.Check_SMP_stoppages',10);
        --
        end Check_SMP_stoppages;
        --
procedure Calculate_correct_SMP_rate (p_week_number in number) is
        --
        -- The entry API takes the lookup meanings so we must find
        -- the meanings rather than the codes for SMP rates.
        --
        cursor csr_rate_meaning (p_rate_band varchar2) is
                --
                select  meaning
                from    hr_lookups
                where   lookup_type = 'SMP_RATES'
                and     lookup_code = p_rate_band;
                --
        begin
        --
        hr_utility.set_location ('ssp_smp_pkg.Calculate_correct_SMP_rate',1);
        --
        if l_high_rate is null then
          --
          -- Get the meanings for the rate bands
          --
          -- Get the higher rate band
          --
          open csr_rate_meaning ('HIGH');
          fetch csr_rate_meaning into l_high_rate;
          close csr_rate_meaning;
          --
          -- Get the lower rate band
          --
          open csr_rate_meaning ('LOW');
          fetch csr_rate_meaning into l_low_rate;
          close csr_rate_meaning;
        end if;
        --
        if (p_week_number - l_stopped_weeks)
                <= g_SMP_element.period_at_higher_rate
        then
          hr_utility.set_location ('ssp_smp_pkg.Calculate_correct_SMP_rate',1);
          --
          -- We have not yet given the employee all their higher rate weeks
          --
          hypothetical_entry.rate (p_week_number) := l_high_rate;
        else
          hypothetical_entry.rate (p_week_number) := l_low_rate;
        end if;
        --
        hr_utility.trace ('SMP Rate = '
                ||hypothetical_entry.rate (p_week_number));
                --
        hr_utility.set_location ('ssp_smp_pkg.Calculate_correct_SMP_rate',10);
        --
        end Calculate_correct_SMP_rate;
        --
procedure Calculate_SMP_amounts (p_week_number in integer, p_MPP_start_date in date) is
        --
        begin
        --
        hr_utility.set_location('Entering: ssp_smp_pkg.Calculate_SMP_amounts',1);
        --
        -- Get the SMP element for each week in case the SMP rate has changed
        --
        get_SMP_element (hypothetical_entry.week_commencing (p_week_number));
        --
        if hypothetical_entry.rate (p_week_number) = l_high_rate then
          --
          -- The higher rate is the greater of the low SMP flat rate amount and
          -- the legislation-specified proportion of average earnings (rounded
          -- UP to the nearest penny)
          --
           hr_utility.trace('Calculate at high rate');
           hr_utility.trace('p_MPP_start_date : '||fnd_date.date_to_canonical(p_MPP_start_date));
         if p_MPP_start_date >= fnd_date.canonical_to_date('2003/04/06 00:00:00') then
            hr_utility.trace('MPP start date after 06-APR-2003, therefore 90 percent of average earnings');
             hypothetical_entry.amount (p_week_number)
                := round((average_earnings * g_SMP_element.higher_SMP_rate)
                                + 0.0049,2);
         else
            hr_utility.trace('Due date before 06-APR-2003, therfore under higher rate with lower rate, else 90 percent of average earnings');
             hypothetical_entry.amount (p_week_number)
                := greatest (round (
                        (average_earnings * g_SMP_element.higher_SMP_rate)
                                + 0.0049,2),
                        g_SMP_element.lower_SMP_rate);
         end if;
        else
          hr_utility.trace('Calculating for lower, therfore we need to find out if week commencing date is before or after 06-APR-2003, week_commencing : '||fnd_date.date_to_canonical(hypothetical_entry.week_commencing(p_week_number)));
          if hypothetical_entry.week_commencing(p_week_number) <
            fnd_date.canonical_to_date('2003/04/06 00:00:00') then
            hr_utility.trace('Decided week commencing before 06-APR-2003');
            -- Any SMP weeks paid before 06-APR-2003 to be paid
            -- at floored lower amount
              hypothetical_entry.amount (p_week_number)
                := g_SMP_element.lower_SMP_rate;
          elsif (hypothetical_entry.week_commencing(p_week_number) >=
           fnd_date.canonical_to_date('2003/04/06 00:00:00') and
           p_MPP_start_date < fnd_date.canonical_to_date('2003/04/06 00:00:00')) then
           -- For payments after 06-APR-2003 for maternities with MPP start date
           -- prior to 06-APR-2003, the payment must be underpinned by SMP
           -- lower rate
             hr_utility.trace('Week commenicng is after 06-APR-2003, but MPP start date is before 06-APR-2003, therfore amount must be underpinned');
           if g_SMP_element.lower_SMP_rate > round(
                (average_earnings * g_SMP_element.higher_SMP_rate)
                                + 0.0049,2) then
             -- Payment to be underpinned
                 hr_utility.trace('Average earnings * 90 percent less than lower rate, therfore underpin');
                   hypothetical_entry.amount (p_week_number)
                          := g_SMP_element.lower_SMP_rate;
           else
             -- Calculated amount is higher than lower SMP rate, so
             -- assign calculated amount
                  hr_utility.trace('average earnings * 90 percent greater than lower rate, no need to underpin');
                   hypothetical_entry.amount (p_week_number)
                      := least(round(
                           (average_earnings * g_SMP_element.higher_SMP_rate)
                             + 0.0049,2), g_SMP_element.standard_SMP_rate);
           end if;
          else
             hr_utility.trace('Due date and week Commencing both after 06-APr-2003, therfore lowest of average earnings and standard rate');
                   hypothetical_entry.amount (p_week_number)
                      := least(round(
                           (average_earnings * g_SMP_element.higher_SMP_rate)
                             + 0.0049,2), g_SMP_element.standard_SMP_rate);
          end if;
        end if;
        --
        hypothetical_entry.recoverable_amount (p_week_number)
                := round (hypothetical_entry.amount (p_week_number)
                        * g_SMP_element.recovery_rate,2);
        --
        hr_utility.trace ('SMP amount = '
                ||to_char (hypothetical_entry.amount (p_week_number)));
        hr_utility.trace ('Recoverable amount = '
        ||to_char (hypothetical_entry.recoverable_amount (p_week_number)));
        --
        hr_utility.set_location('Leaving : ssp_smp_pkg.Calculate_SMP_amounts',100);
        --
        end calculate_SMP_amounts;
        --
        procedure check_parameters is
        begin
        hr_api.mandatory_arg_error (
                p_api_name      => l_proc,
                p_argument      => 'maternity_id',
                p_argument_value=> p_maternity_id);
                --
        end check_parameters;
        --
begin
--
hr_utility.set_location ('ssp_smp_pkg.generate_payments',1);
--
check_parameters;
--
<<SMP_WEEKS>>
--
if woman.MPP_start_date is not null then
   for week_number in 1..g_SMP_element.maximum_MPP
   LOOP
       --
       -- Derive hypothetical entries ie those entries which would be applied for a
       -- completely new maternity. Store them internally because we must check
       -- previously created entries before applying the hypothetical entries to the
       -- database.
       --
       Derive_SMP_week                      (week_number);
       Check_SMP_stoppages                  (week_number);
       Calculate_correct_SMP_rate           (week_number);
       Calculate_SMP_amounts                (week_number, woman.MPP_start_date);
       --
       if (hypothetical_entry.stopped (week_number) = 'FALSE') then
         --
         -- Get the entry details unless the entry has been stopped (in which case
         -- we do not need the entry details and errors may occur if we call the
         -- procedure; eg the woman's assignment ends)
         --
         ssp_smp_support_pkg.get_entry_details     (
            p_date_earned          => hypothetical_entry.week_commencing
                                                (week_number),
            p_pay_as_lump_sum      => woman.pay_SMP_as_lump_sum,
            p_last_process_date    => woman.final_process_date,
            p_person_id            => woman.person_id,
            p_element_type_id      => g_SMP_element.element_type_id,
            p_element_link_id      => hypothetical_entry.element_link_id
                                                (week_number),
            p_assignment_id        => hypothetical_entry.assignment_id
                                                (week_number),
            p_effective_start_date => hypothetical_entry.effective_start_date
                                                (week_number),
            p_effective_end_date   => hypothetical_entry.effective_end_date
                                                (week_number));
      end if;
   end loop SMP_weeks;
end if;
--
Save_hypothetical_entries(p_deleting);
--
end generate_payments;
--
--------------------------------------------------------------------------------
procedure SMP_control (p_maternity_id   in number,
                       p_deleting       in boolean ) is
--
-- p_deleting parameter added to deal with absences being deleted, without
-- maternity being deleted.
--
cursor csr_maternity is
        --
        -- Find out if the maternity exists
        --
        select  1
        from    ssp_maternities
        where   maternity_id = p_maternity_id;
        --
cursor csr_entries is
        --
        -- Get all element entries associated with a maternity
        --
select /*+ ORDERED use_nl(paa,paaf,etype,entry) */
       entry.element_entry_id,
       entry.effective_start_date
from   per_absence_attendances PAA,
       per_all_assignments_f   PAAF,
       pay_element_entries_f   entry
where  PAA.maternity_id = p_maternity_id
and    PAAF.person_id = PAA.person_id
and    entry.creator_type = 'M'
and    entry.creator_id = p_maternity_id
and    entry.assignment_id = paaf.assignment_id;
        --
cursor csr_count_absences is
select count(*)
from   ssp_maternities mat,
       per_absence_attendances ab
where  mat.maternity_id = p_maternity_id
and    ab.person_id = mat.person_id
and    ab.maternity_id = mat.maternity_id;
        --
l_count number;
l_dummy number;
l_proc  varchar2 (72) := g_package||'SMP_control';
--
begin
--
hr_utility.set_location (l_proc,1);
--
open csr_maternity;
fetch csr_maternity into l_dummy;
--
if csr_maternity%found then
   --
   -- Recalculate SMP
   --
   if entitled_to_SMP (p_maternity_id) then
      open csr_count_absences;
      fetch csr_count_absences into l_count;
      close csr_count_absences;
      if l_count > 0 then
          generate_payments (p_maternity_id, false);
      else
          generate_payments (p_maternity_id, p_deleting);
      end if;
   elsif p_deleting then
        -- not entitled but deleting absence then
      generate_payments (p_maternity_id, p_deleting);
   end if;
else
   --
   -- The maternity may have been deleted. Remove any element entries associated
   -- with it (the absences, stoppages and medicals are handled by constraints).
   --
   for obsolete in csr_entries LOOP
      hr_utility.trace (l_proc||'       Deleting element entry_id '||
                        to_char (obsolete.element_entry_id));
      hr_utility.trace (l_proc||'-------------------------------------------');
      --
      hr_entry_api.delete_element_entry (
                           p_dt_delete_mode    => 'ZAP',
                           p_session_date      => obsolete.effective_start_date,
                           p_element_entry_id  => obsolete.element_entry_id);
   end loop;
end if;
--
g_smp_update := 'N';
--
hr_utility.set_location (l_proc,100);
--
end SMP_control;
--
--------------------------------------------------------------------------------
procedure ins_ssp_temp_affected_rows_mat(p_maternity_id in number,
                                         p_deleting in boolean ) is
--
-- Inserts a row in ssp_temp_affected_rows for the maternity, if not there
--
l_proc  varchar2 (72) := g_package||'ins_ssp_temp_affected_rows_mat';
l_deleting_ch  varchar2(1);
--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
if p_deleting then
   l_deleting_ch := 'Y';
else
   l_deleting_ch := 'N';
end if;
--
if p_maternity_id is not null then
   hr_utility.trace (l_proc||'   Saving maternity_id #' || p_maternity_id ||
                     ' for recalculation (p_del = '||l_deleting_ch||').');
   --
   insert into ssp_temp_affected_rows (MATERNITY_ID, p_deleting, locked)
   select p_maternity_id, l_deleting_ch, userenv('sessionid')
     from sys.dual
    where not exists
          (select null
             from ssp_temp_affected_rows t2
            where t2.maternity_id = p_maternity_id);
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
end ins_ssp_temp_affected_rows_mat;
--
--------------------------------------------------------------------------------
procedure absence_control (p_maternity_id in number,
                           p_deleting     in boolean ) is
--
-- Handle the event of DML on per_absence_attendances
--
l_proc  varchar2 (72) := g_package||'absence_control';
--
begin
--
hr_utility.set_location (l_proc,1);
--
g_smp_update := 'N';
--
if p_maternity_id is not null then
   ins_ssp_temp_affected_rows_mat(p_maternity_id, p_deleting);
end if;
--
hr_utility.set_location (l_proc,100);
--
end absence_control;
--------------------------------------------------------------------------------
procedure maternity_control (p_maternity_id in number) is
--
l_proc varchar2 (72) := g_package||'maternity_control';
--
begin
--
hr_utility.set_location (l_proc,1);
--
g_smp_update := 'Y';
--
ins_ssp_temp_affected_rows_mat(p_maternity_id, p_deleting => FALSE);
--
hr_utility.set_location (l_proc,100);
--
end maternity_control;
--------------------------------------------------------------------------------
procedure medical_control (p_maternity_id in number) is
--
l_proc varchar2 (72) := g_package||'medical_control';
--
begin
--
hr_utility.set_location (l_proc,1);
--
if p_maternity_id is not null -- the medical is for a maternity
then
   ins_ssp_temp_affected_rows_mat(p_maternity_id, p_deleting => FALSE);
end if;
--
hr_utility.set_location (l_proc,100);
--
end medical_control;
--
--------------------------------------------------------------------------------
procedure earnings_control (
        p_person_id           in number,
        p_effective_date      in date) is
        --
cursor csr_maternity is
        --
        -- Find any maternity whose SMP figures rely on the earnings
        -- calculation.
        --
        select  mat.maternity_id
        from    ssp_maternities mat
        where   mat.person_id = p_person_id
        and     p_effective_date = decode(mat.leave_type,
                 'AD',ssp_sap_pkg.MATCHING_WEEK_OF_ADOPTION(mat.matching_date),
                 'PA',ssp_pad_pkg.MATCHING_WEEK_OF_ADOPTION(mat.matching_date),
                 'PB',ssp_pab_pkg.QUALIFYING_WEEK(mat.due_date),
                 ssp_smp_pkg.QUALIFYING_WEEK(mat.due_date))
        and     exists (select 1
                        from per_absence_attendances abs
                        where abs.person_id = p_person_id
                        and abs.maternity_id = mat.maternity_id);
        --
l_maternity_id  number := null;
l_proc          varchar2(72) := g_package||'earnings_control';
--
begin
--
hr_utility.set_location (l_proc,1);
--
open csr_maternity;
fetch csr_maternity into l_maternity_id;
--
if csr_maternity%found
then
   ins_ssp_temp_affected_rows_mat(l_maternity_id, p_deleting => FALSE);
else
   hr_utility.trace(l_proc||'   No maternities affected by change in earnings');
end if;
--
close csr_maternity;
--
hr_utility.set_location (l_proc,100);
--
end earnings_control;
--
--------------------------------------------------------------------------------
procedure person_control (
        p_person_id     in number,
        p_date_of_death in date) is
        --
cursor csr_maternity is
        --
        -- Get any maternity which may be affected by the death of the person,
        -- where the date of death falls within the MPP and leave is recorded.
        --
        select  maternity.maternity_id
        from    ssp_maternities MATERNITY,
                pay_element_types_f     ELEMENT
        where   maternity.person_id = p_person_id
        and     element.legislation_code = 'GB'
        and     element.element_name = c_SMP_element_name
        and     maternity.due_date between element.effective_start_date
                                        and element.effective_end_date
        and     p_date_of_death <= maternity.MPP_start_date
                                        + (element.element_information6 * 7)
        and     EXISTS  (
                        select  1
                        from    per_absence_attendances ABSENCE
                        where   ABSENCE.maternity_id = MATERNITY.maternity_id
                        );
        --
l_maternity_id  number := null;
l_proc          varchar2(72) := g_package||'person_control';
--
begin
--
hr_utility.set_location (l_proc,1);
--
open csr_maternity;
fetch csr_maternity into l_maternity_id;
--
if csr_maternity%found
then
   ins_ssp_temp_affected_rows_mat(l_maternity_id, p_deleting => FALSE);
end if;
--
close csr_maternity;
--
ssp_smp_support_pkg.recalculate_ssp_and_smp(p_deleting => FALSE);
--
hr_utility.set_location (l_proc,100);
--
end person_control;
--
--------------------------------------------------------------------------------
procedure stoppage_control (p_maternity_id in number) is
--
-- Because stoppages are the result of the SMP entitlement check, if the user
-- modifies these stoppages, then there is no point in rerunning the check on
-- entitlement. However, the alteration of stoppage information will almost
-- certainly have an effect on the SMP payments and so we must regenerate them.
--
l_proc varchar2 (72) := g_package||'stoppage_control';
--
begin
--
hr_utility.set_location (l_proc,1);
--
if p_maternity_id is not null
then
   ins_ssp_temp_affected_rows_mat(p_maternity_id, p_deleting => FALSE);
end if;
--
hr_utility.set_location (l_proc,100);
--
end stoppage_control;
--
--------------------------------------------------------------------------------
function get_max_SMP_date(p_maternity_id in number) return date is
    l_due_date  date;
    l_mpp_date  date;
    l_max_mpp   number;

    cursor get_person_details is
    select mpp_start_date, due_date
    from   ssp_maternities
    where  maternity_id = p_maternity_id;

    cursor get_maximum_mpp is
    select to_number(element_information4)
    from   pay_element_types_f
    where  element_name = c_SMP_element_name
    and	   l_due_date between effective_start_date and effective_end_date;
begin
    open get_person_details;
    fetch get_person_details into l_mpp_date, l_due_date;
    close get_person_details;

    open get_maximum_mpp;
    fetch get_maximum_mpp into l_max_mpp;
    close get_maximum_mpp;

    if l_mpp_date is not null then
       return trunc(l_mpp_date + (l_max_mpp * 7));
    else
       return l_due_date;
    end if;
end;
--------------------------------------------------------------------------------
function get_max_SMP_date(p_maternity_id in number,
                          p_due_date     in date,
                          p_mpp_date     in date) return date is
    l_max_mpp number;

    cursor get_maximum_mpp is
    select to_number(element_information4)
    from   pay_element_types_f
    where  element_name = c_SMP_element_name
    and    p_due_date between effective_start_date and effective_end_date;
begin
    open get_maximum_mpp;
    fetch get_maximum_mpp into l_max_mpp;
    close get_maximum_mpp;

    if p_mpp_date is not null then
       return trunc(p_mpp_date + (l_max_mpp * 7));
    else
       return p_due_date;
    end if;
end;
--------------------------------------------------------------------------------
end ssp_SMP_pkg;

/
