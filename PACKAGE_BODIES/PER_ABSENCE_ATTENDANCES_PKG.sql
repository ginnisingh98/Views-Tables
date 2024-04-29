--------------------------------------------------------
--  DDL for Package Body PER_ABSENCE_ATTENDANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABSENCE_ATTENDANCES_PKG" as
/* $Header: peaba01t.pkb 120.0 2005/05/31 04:39:27 appldev noship $ */

/* Date   Name   Release        Description
   ----   ----   -------        -----------
 25-Jul-95 AMILLS 70.9          Replaced tokenised error messages with hard
                                coded messages, including
                                'PER_7073_EMP_ABS_DURATION' with
                                PER_7887_EMP_ABS_DURATION ,
                                PER_7886_EMP_ABS_DURATION.
 06-SEP-95 SSETHI               Added SSP/SMP Procedures/Functions and
                                modified Insert_row, Update_Row and
                                Lock_Row to include new columns.
 15-SEP-95 SSETHI               Removed calls to
                                app_exception.raise_exception
  3 Oct 95      N Simpson       Added code to Insert/Update/Delete Row
                                procedures to validate SSP Periods of Incapacity
                                for Work.
  6-OCT-95 S Sethi              Added constraint exception handling to
                                insert and update statements.
 12-OCT-95      N Simpson       Commented out references to objects which will
                                not be delivered until SSP delivery. These
                                commented out bits should be uncommented at that
                                time.
 13-OCT-95      J Thuringer     Replaced 'PACKAGE_NAME' variable by
                                hardcoded 'PER_ABSENCE_ATTENDANCES_PKG';
                                removed error checking code from end of script
 17-OCT-95      F Assadi        Added a new function get_anuual_bal to work
                                out the absence taken from the year.
                                is_emp_entitled function was added. This
                                function checks whether an employee is
                                entilted for the requested absence.
 03-NOV-95      N Simpson       Amended constraint names in procedure
                                constraint_error.
 13-Nov-95      N Simpson       Renamed column reason_for_notification_delay
                                because it was incorrectly named on the table
                                and it is easier to modify all references to it
                                than to rename the column itself.
 16 Nov 95      N Simpson       Corrected message names in constraint_error
                                and added comments.
 05 Dec 95      A Mills         Corrected date checking method for ease of
                                translation.
 20 Dec 95      N Simpson       Added check on MPP start date so that maternity
                                absence may not start if there is no MPP start
                                date on the maternity record.
 20 Dec 95      N Simpson       Changed check_related_maternity to use a
                                different error message.
 04 Sep 96      K Habibulla     Removed rtrim on columns sickness_start_date
                                and sickness_end_date as this was causing a
                                locking problem on the record.
                                * Date columns should not be rtrim'med *
 04 Mar 97      J Alloun        Changed all occurances of system.dual
                                to sys.dual for next release requirements.
------------------------------------------------------------------------------------
Change List
===========

Version Date         BugNo     Author     Comment
-------+------------+---------+----------+--------------------------------------
70.36   29-NOV-1996  418051    Khabibul   Applied fix to bug 418051. Suppressed the
                                          index in procedure geT-annual_balance on
                                          pay_element_entry_values_f.input_value_id
                                          Also included new Change List Header.

 70.39  07-AUG-1997            Mbocutt    Change hardcoded date usage to use
110.1                                      hr_general.end_of_time
 70.40  23-OCT-1997  565478    ASAHAY     modified cursor in b_check_auth_de
110.1                                     and b_check_rep_de to check for
                                          correct start date and end date
70.42   05-MAY-1998  563202    AParkes    Performance fix for SSP; Altered
110.3                                     cursor c19 in get_annual_balance
110.4   26-MAY-1998  673835    CTredwin   Amended cursor csr_get_accrual_plan
                                          since it could not previously
                                          get any accrual plans. Cursor is
                                          in fuction is_emp_entitled. Also
                                          amended function to close cursor if
                                          no plans are found.
110.5   07-SEP-1998            JARTHURT   Added parameters to insert, update
                                          and lock routine to deal with the new
                                          DDF fields
110.6   22-DEC-1998  725730    A.Myers    Added facility to update MPP date if
                                          it is not null. Added procedures
                                          get_mat_details, Delete_Row overload
                                          and get_earliest_abs_start_date.
        22-DEC-1998  673835    A.Myers    C.Tredwin fix forward ported.
                                          Altered is_emp_entitled. Changed
                                          cursor to pick up element entries for
                                          the correct element type.
110.7   19-Jan-1999  n/a       C.Tredwin  Replaced get_net_accrual call in
                                          is_emp_entitled with new pto accrual
                                          procedure per_accrual_calc_functions.
                                          get_net_accrual.
110.8   19-Jan-1999  n/a       C.Tredwin  Correction to 110.7
110.9   19-Jan-1999  n/a       C.Tredwin  Correction to 110.8
110.10  20-Jan-1999  n/a       C.Tredwin  Corrected call to get_net_accrual,
                                          the function having changed as a
                                          result of the pto accruals upgrade.
115.9   11-Mar-1999  835944    S.Billing  Altered cursor c15,
                                          added employment category to link
                                          selection criteria
115.10  12-Oct-1999            SCNair     Date track position related changes
115.16  22-Oct-1999            Ctredwin   Added Batch_Id to insert and
                                          update procedures.
115.16  07-Feb-2000  1184545   CTredwin   Amended get_defaults to calculate
                                          days in hours value correctly, ie
                                          (end date - start date + 1) * 24
115.17  24-Jul-2000  1337672   CTredwin   Amended get_defaults again to
                                          correct default hours calculation
115.19  19-Oct-2000  1408379   GPerry     Fixed WWBUG 1408379.
                                          Provided hooks to OAB.
115.20  24-Jan-2002  2189311   Kparekh    Took out the default null values from
                                          the 'insert_row' procedure to match
                                          the parameter values in the header.
115.21  09-JUL-2002            mmudigon   Absences related changes
                                          Added new proc populate_ben_absence_rec.
                                          Also added a call to ler_chk in
                                          delete_row
115.22  11-JUL-2002            mmudigon   Added dbdrv commands
115.24  23-JUL-2003  2829746   ablinko    amendments for SAP/SPP
115.25  25-Aug-2003  3111653   skota      added to_number() for explicit
					  conversion. Seems implicit conversion
					  is not taking place in 10G
115.26  06-NOV-2003  3156665   kjagadee   Modified per_absence_attendances_pkg.get_defaults
                                          procedure to calculate the drfault hours in a day
                                          as 24 hours.
115.27  29-JAN-2004  3387265  smparame    Modified inti_form procedure.
					  upper(formula_type_name) is changed to formula
					  name in the cursor c21 to avoid FTS.
115.28  27-APR-2004  3580603  kthampan    Change the condition in the if statement
                                          in procedure default_MPP_start_date.
115.29  29-JUN-2004  3648445  kjagadee    Performance repository fixes.
115.30  14-JUL-2004  3694165  ablinko     Now calls earliest_ppp_start_date with
                                          actual_birth_date instead of due_date
-------+------------+---------+----------+--------------------------------------
*/
g_package  varchar2(33) := '  per_absence_attendances_pkg.';
-- Global package name

--
------------------------------------------------------------------------------
-- |--------------------------< constraint_error >---------------------------|
------------------------------------------------------------------------------
Procedure constraint_error
           (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PER_ABSENCE_ATTENDANCES_FK4') Then
    --
    -- The linked_absence_id does not refer to a valid absence_attendance_id.
    --
    fnd_message.set_name('SSP', 'SSP_35060_SSP_ABS_FK2');
    --
  ElsIf (p_constraint_name = 'PER_ABSENCE_ATTENDANCES_FK5') Then
    --
    -- The maternity_id is not valid.
    --
    fnd_message.set_name('SSP', 'SSP_35061_SSP_ABS_FK1');
    --
  ElsIf (p_constraint_name = 'SSP_ABA_SICKNESS_END_DATE') Then
    --
    -- date_end must be specified if sickness_end_date is specified, and
    -- date_end cannot be after sickness_end_date
    --
    fnd_message.set_name('SSP', 'SSP_35062_ABS_SICK_END_DATE');
    --
  ElsIf (p_constraint_name = 'SSP_ABA_MATERNITY_NOT_SICKNESS') Then
    --
    -- Cannot mix maternity and sickness attributes for an absence.
    --
    fnd_message.set_name('SSP', 'SSP_35063_MAT_NOT_SICKNESS');
    --
  ElsIf (p_constraint_name = 'SSP_ABA_START_AND_END_DATES') Then
    --
    -- Date_start must be before date_end
    --
    fnd_message.set_name('SSP', 'SSP_35064_ABS_START_AND_END');
    --
  ElsIf (p_constraint_name = 'SSP_ABA_SICKNESS_START_DATE') Then
    --
    -- The sickness start date must not be after the absence date start
    --
    fnd_message.set_name('SSP', 'SSP_36066_ABS_SICK_START_DATE');
    --
  ElsIf (p_constraint_name = 'SSP_ABA_SICK_NOTIFICATION_DATE') Then
    --
    -- The notification date must be on or after the sickness start date.
    --
    fnd_message.set_name('SSP', 'SSP_35067_ABS_SICK_NOTIF_DATE');
    --
  ElsIf (p_constraint_name = 'SSP_ABA_TIME_START_FORMAT') Then
    --
    -- The time format is incorrect.
    --
    fnd_message.set_name('SSP', 'SSP_36069_TIME_FORMAT');
    --
  ElsIf (p_constraint_name = 'SSP_ABA_TIME_END_FORMAT') Then
    --
    -- The time format is incorrect.
    --
    fnd_message.set_name('SSP', 'SSP_36069_TIME_FORMAT');
    --
  ElsIf (p_constraint_name = 'SSP_ABA_SICKNESS_ATTRIBUTES') Then
    --
    -- An invalid combination of attributes have been entered.
    --
    fnd_message.set_name('SSP', 'SSP_36072_ABS_SICK_ATTRIBUTES');
    --
  ElsIf (p_constraint_name = 'SSP_35037_PIW_BROKEN') Then
    --
    -- The linked series of sickness absences has been disrupted.
    --
    fnd_message.set_name('SSP', 'SSP_35037_PIW_BROKEN');
    --
  Else
    --
    -- A constraint has been violated which is not explicitly handled by this
    -- code.
    --
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE',l_proc);
    fnd_message.set_token('CONSTRAINT_NAME',p_constraint_name);
    --
  End If;
  --
  fnd_message.raise_error;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End constraint_error;
--
-- ---------------------------------------------------------------------------
-- ---------------------< get_earliest_abs_start_date >-----------------------
-- ---------------------------------------------------------------------------
-- PRIVATE:
-- Description: returns start date of earliest absence for this maternity and
--              the number of absences for the maternity.
--
procedure get_earliest_abs_start_date (
                             p_maternity_id in number,
                             p_earliest_abs_start_date in out nocopy date,
                             p_earliest_abs_rowid in out nocopy rowid,
                             p_nos_absences in out nocopy number) is
--
cursor c2 is
   select date_start, rowid
   from   per_absence_attendances
   where  maternity_id = p_maternity_id;
  c2_rec c2%ROWTYPE;
--
begin
  p_nos_absences := 0;
  p_earliest_abs_start_date := hr_general.end_of_time;
  --
  for c2_rec in c2 LOOP
    p_nos_absences := p_nos_absences + 1;
    --
    if c2_rec.date_start < p_earliest_abs_start_date
    then
      p_earliest_abs_start_date := c2_rec.date_start;
      p_earliest_abs_rowid := c2_rec.rowid;
    end if;
  end LOOP;
  --
end get_earliest_abs_start_date;
--
-- ---------------------------------------------------------------------------
-- ---------------------------< MPP_update_mode >-----------------------------
-- ---------------------------------------------------------------------------
procedure MPP_update_mode (p_update_mode in number) is
--
l_proc varchar2 (72) := g_package||'MPP_update_mode';
--
begin
--
hr_utility.set_location ('Entering:'||l_proc,1);
--
if p_update_mode = 1
then
   g_mpp_update_mode := TRUE;
else
   g_mpp_update_mode := FALSE;
end if;
--
hr_utility.set_location ('Leaving :'||l_proc,100);
--
end MPP_update_mode;
--
------------------------------------------------------------------------------
procedure reset_MPP_start_date_on_delete (p_maternity_id in number) is
--
cursor csr_MPP is
        select  MPP_start_date,
                leave_type,
                object_version_number,
                decode(leave_type,
                       'AD',ssp_sap_pkg.earliest_APP_start_date(due_date),
                       'PA',ssp_pad_pkg.earliest_PPP_start_date(due_date),
                       'PB',ssp_pab_pkg.earliest_PPP_start_date(actual_birth_date),
                        ssp_smp_pkg.earliest_MPP_start_date (due_date))
                                                earliest_MPP_start_date
        from    ssp_maternities
        where   maternity_id = p_maternity_id;
--
l_maternity               csr_MPP%rowtype;
--
l_proc varchar2 (72) := g_package||'reset_MPP_start_date_on_delete';
--
l_default_MPP_start_date  date := null;
l_earliest_abs_start_date date;
l_earliest_abs_rowid      rowid;
l_nos_absences            number;
--
begin
--
hr_utility.set_location ('Entering:'||l_proc,1);
--
if g_mpp_update_mode = TRUE
then
  --
  -- If we are deleting an absence, then reset the MPP start date IF there are
  -- still absences left to provide data to do this.
  --
  open csr_MPP;
  fetch csr_MPP into l_maternity;
  close csr_MPP;
  --
  get_earliest_abs_start_date(p_maternity_id,
                              l_earliest_abs_start_date,
                              l_earliest_abs_rowid,
                              l_nos_absences);
  --
  if l_nos_absences = 0 and l_maternity.MPP_start_date is not null
  then
    ssp_mat_upd.upd
          (p_maternity_id           => p_maternity_id,
           p_object_version_number  => l_maternity.object_version_number,
           p_leave_type             => l_maternity.leave_type,
           p_mpp_start_date         => null);
  else
    l_default_MPP_start_date :=
      greatest (l_earliest_abs_start_date, l_maternity.earliest_MPP_start_date
);
    ssp_mat_upd.upd
          (p_maternity_id           => p_maternity_id,
           p_object_version_number  => l_maternity.object_version_number,
           p_leave_type             => l_maternity.leave_type,
           p_mpp_start_date         => l_default_MPP_start_date);
  end if;
  --
  g_mpp_updated_date := l_default_MPP_start_date;
end if;
--
hr_utility.set_location ('Leaving :'||l_proc,100);
--
end reset_MPP_start_date_on_delete;
--
--------------------------------------------------------------------------------
procedure default_MPP_start_date (
--
p_maternity_id     in number,
p_start_date       in date,
p_end_date         in date) is
--
l_proc varchar2 (72) := g_package||'default_MPP_start_date';
--
cursor csr_MPP is
        --
        -- Find out if the MPP has started
        --
        select  MPP_start_date,
                object_version_number,
                decode(leave_type,
                       'AD',ssp_sap_pkg.earliest_APP_start_date(due_date),
                       'PA',ssp_pad_pkg.earliest_PPP_start_date(due_date),
                       'PB',ssp_pab_pkg.earliest_PPP_start_date(actual_birth_date),
                        ssp_smp_pkg.earliest_MPP_start_date (due_date))
                                                earliest_MPP_start_date,
                ssp_smp_pkg.qualifying_week (due_date) QW,
                nvl(mpp_start_date,hr_general.end_of_time) MPP,
                person_id,
                leave_type,
                placement_date,
                due_date,
                actual_birth_date
        from    ssp_maternities
        where   maternity_id = p_maternity_id;
--
l_maternity               csr_MPP%rowtype;
l_default_MPP_start_date  date := null;
l_end_date                date := nvl (p_end_date, hr_general.end_of_time);
l_current_mpp_start_date  date := hr_general.end_of_time;
l_earliest_abs_start_date date;
l_ewc                     date;
l_earliest_mpp_start      date;
l_qw                      date;
l_cont_emp_start          date;
l_earliest_abs_rowid      rowid;
l_nos_absences            number;
l_mpp_updated_date        date := g_mpp_updated_date;
--
begin
--
hr_utility.set_location ('Entering:'||l_proc,1);
--
if p_maternity_id is not null
then
  --
  -- this is a maternity absence so look up the maternity record
  --
  open csr_MPP;
  fetch csr_MPP into l_maternity;
  close csr_MPP;
  --
  if (
     -- The MPP has not started
     l_maternity.MPP_start_date is null
     or
     -- or user wants the MPP date to be udpated
     g_mpp_update_mode = TRUE
     )
    -- and the absence does not end before the earliest MPP start date
    and l_end_date >= l_maternity.earliest_MPP_start_date
  then
    get_earliest_abs_start_date(p_maternity_id,
                              l_earliest_abs_start_date,
                              l_earliest_abs_rowid,
                              l_nos_absences);
    --
    -- The default MPP start date is the later of the absence start and
    -- the earliest allowed MPP start date.
    --
    l_default_MPP_start_date :=
        greatest (least(p_start_date, l_earliest_abs_start_date),
                  l_maternity.earliest_MPP_start_date);
    --
    if l_maternity.MPP_start_date is not null
    then
       l_current_mpp_start_date := l_maternity.MPP_start_date;
    end if;
    --
    -- Update the MPP start date to the default MPP start date
    --

    -- Bug 3580603 - change the condition of the If statement
    if (l_current_mpp_start_date <> l_default_MPP_start_date)
    then

      if l_maternity.leave_type = 'AD'
      then
        ssp_mat_bus.check_app_start_date(
          p_mpp_start_date => l_default_MPP_start_date,
          p_placement_date => l_maternity.placement_date,
          p_due_date       => l_maternity.due_date);
      elsif l_maternity.leave_type = 'PB'
      then
        sspwsmat_pkg.calculate_pab_form_fields (
          p_due_date            => l_maternity.due_date,
          p_ewc                 => l_ewc,
          p_qw                  => l_qw,
          p_cont_emp_start_date => l_cont_emp_start);

        ssp_mat_bus.check_ppp_start_date (
          p_ppp_start_date => l_default_MPP_start_date,
          p_birth_date     => l_maternity.actual_birth_date,
          p_ewc            => l_ewc,
          p_due_date       => l_maternity.due_date);
      elsif l_maternity.leave_type = 'PA'
      then
        ssp_mat_bus.check_pppa_start_date (
          p_ppp_start_date => l_default_MPP_start_date,
          p_placement_date => l_maternity.placement_date,
          p_due_date       => l_maternity.due_date);
      else
        sspwsmat_pkg.calculate_smp_form_fields (
          p_due_date            => l_maternity.due_date,
          p_ewc                 => l_ewc,
          p_earliest_mpp_start  => l_earliest_mpp_start,
          p_qw                  => l_qw,
          p_cont_emp_start_date => l_cont_emp_start);

        ssp_mat_bus.check_MPP_start_date_2 (
          p_mpp_start_date          => l_default_MPP_start_date,
          p_person_id               => l_maternity.person_id,
          p_ewc                     => l_ewc,
          p_earliest_mpp_start_date => l_earliest_mpp_start,
          p_due_date                => l_maternity.due_date,
          p_prev_mpp_start_date     => l_maternity.mpp,
          p_actual_birth_date       => l_maternity.actual_birth_date);

      end if;

       ssp_mat_upd.upd
          (p_maternity_id           => p_maternity_id,
           p_object_version_number  => l_maternity.object_version_number,
           p_leave_type             => l_maternity.leave_type,
           p_mpp_start_date         => l_default_MPP_start_date);
       --
       g_mpp_updated_date := l_default_MPP_start_date;
    end if;
  end if;
end if;
--
hr_utility.set_location ('Leaving :'||l_proc,100);
--
end default_MPP_start_date;
--
procedure populate_ben_absence_rec
  (p_absence_attendance_id   in number,
   p_rec_type                in varchar2,
   p_old_rec                 in per_absence_attendances%rowtype,
   p_ben_rec                 out nocopy ben_abs_ler.g_abs_ler_rec) is

  cursor c_current_absence is
    select *
    from   per_absence_attendances
    where  absence_attendance_id = p_absence_attendance_id;
  --
  l_absence_rec         per_absence_attendances%rowtype;
  l_proc                varchar2(72) := g_package||'populate_ben_absence_rec';

begin

  hr_utility.set_location('Entering: '|| l_proc, 10);

  if (p_rec_type = 'O') then
     l_absence_rec := p_old_rec;
  else
      open c_current_absence;
     fetch c_current_absence into l_absence_rec;
     close c_current_absence;
  end if;

  p_ben_rec.person_id := l_absence_rec.person_id;
  p_ben_rec.business_group_id := l_absence_rec.business_group_id;
  p_ben_rec.date_start := l_absence_rec.date_start;
  p_ben_rec.date_end := l_absence_rec.date_end;
  p_ben_rec.absence_attendance_type_id := l_absence_rec.absence_attendance_type_id;
  p_ben_rec.abs_attendance_reason_id := l_absence_rec.abs_attendance_reason_id;
  p_ben_rec.absence_attendance_id := l_absence_rec.absence_attendance_id;
  p_ben_rec.authorising_person_id := l_absence_rec.authorising_person_id;
  p_ben_rec.replacement_person_id := l_absence_rec.replacement_person_id;
  p_ben_rec.period_of_incapacity_id := l_absence_rec.period_of_incapacity_id;
  p_ben_rec.absence_days := l_absence_rec.absence_days;
  p_ben_rec.absence_hours := l_absence_rec.absence_hours;
  p_ben_rec.date_notification := l_absence_rec.date_notification;
  p_ben_rec.date_projected_end := l_absence_rec.date_projected_end;
  p_ben_rec.date_projected_start := l_absence_rec.date_projected_start;
  p_ben_rec.occurrence := l_absence_rec.occurrence;
  p_ben_rec.ssp1_issued := l_absence_rec.ssp1_issued;
  p_ben_rec.time_end := l_absence_rec.time_end;
  p_ben_rec.time_projected_end := l_absence_rec.time_projected_end;
  p_ben_rec.time_projected_start := l_absence_rec.time_projected_start;
  p_ben_rec.time_start := l_absence_rec.time_start;
  p_ben_rec.attribute_category := l_absence_rec.attribute_category;
  p_ben_rec.attribute1 := l_absence_rec.attribute1;
  p_ben_rec.attribute2 := l_absence_rec.attribute2;
  p_ben_rec.attribute3 := l_absence_rec.attribute3;
  p_ben_rec.attribute4 := l_absence_rec.attribute4;
  p_ben_rec.attribute5 := l_absence_rec.attribute5;
  p_ben_rec.attribute6 := l_absence_rec.attribute6;
  p_ben_rec.attribute7 := l_absence_rec.attribute7;
  p_ben_rec.attribute8 := l_absence_rec.attribute8;
  p_ben_rec.attribute9 := l_absence_rec.attribute9;
  p_ben_rec.attribute10 := l_absence_rec.attribute10;
  p_ben_rec.attribute11 := l_absence_rec.attribute11;
  p_ben_rec.attribute12 := l_absence_rec.attribute12;
  p_ben_rec.attribute13 := l_absence_rec.attribute13;
  p_ben_rec.attribute14 := l_absence_rec.attribute14;
  p_ben_rec.attribute15 := l_absence_rec.attribute15;
  p_ben_rec.attribute16 := l_absence_rec.attribute16;
  p_ben_rec.attribute17 := l_absence_rec.attribute17;
  p_ben_rec.attribute18 := l_absence_rec.attribute18;
  p_ben_rec.attribute19 := l_absence_rec.attribute19;
  p_ben_rec.attribute20 := l_absence_rec.attribute20;
  p_ben_rec.maternity_id := l_absence_rec.maternity_id;
  p_ben_rec.sickness_start_date := l_absence_rec.sickness_start_date;
  p_ben_rec.sickness_end_date := l_absence_rec.sickness_end_date;
  p_ben_rec.pregnancy_related_illness := l_absence_rec.pregnancy_related_illness;
  p_ben_rec.reason_for_notification_delay := l_absence_rec.reason_for_notification_delay;
  p_ben_rec.accept_late_notification_flag := l_absence_rec.accept_late_notification_flag;
  p_ben_rec.linked_absence_id := l_absence_rec.linked_absence_id;
  p_ben_rec.batch_id := l_absence_rec.batch_id;
  p_ben_rec.abs_information_category := l_absence_rec.abs_information_category;
  p_ben_rec.abs_information1 := l_absence_rec.abs_information1;
  p_ben_rec.abs_information2 := l_absence_rec.abs_information2;
  p_ben_rec.abs_information3 := l_absence_rec.abs_information3;
  p_ben_rec.abs_information4 := l_absence_rec.abs_information4;
  p_ben_rec.abs_information5 := l_absence_rec.abs_information5;
  p_ben_rec.abs_information6 := l_absence_rec.abs_information6;
  p_ben_rec.abs_information7 := l_absence_rec.abs_information7;
  p_ben_rec.abs_information8 := l_absence_rec.abs_information8;
  p_ben_rec.abs_information9 := l_absence_rec.abs_information9;
  p_ben_rec.abs_information10 := l_absence_rec.abs_information10;
  p_ben_rec.abs_information11 := l_absence_rec.abs_information11;
  p_ben_rec.abs_information12 := l_absence_rec.abs_information12;
  p_ben_rec.abs_information13 := l_absence_rec.abs_information13;
  p_ben_rec.abs_information14 := l_absence_rec.abs_information14;
  p_ben_rec.abs_information15 := l_absence_rec.abs_information15;
  p_ben_rec.abs_information16 := l_absence_rec.abs_information16;
  p_ben_rec.abs_information17 := l_absence_rec.abs_information17;
  p_ben_rec.abs_information18 := l_absence_rec.abs_information18;
  p_ben_rec.abs_information19 := l_absence_rec.abs_information19;
  p_ben_rec.abs_information20 := l_absence_rec.abs_information20;
  p_ben_rec.abs_information21 := l_absence_rec.abs_information21;
  p_ben_rec.abs_information22 := l_absence_rec.abs_information22;
  p_ben_rec.abs_information23 := l_absence_rec.abs_information23;
  p_ben_rec.abs_information24 := l_absence_rec.abs_information24;
  p_ben_rec.abs_information25 := l_absence_rec.abs_information25;
  p_ben_rec.abs_information26 := l_absence_rec.abs_information26;
  p_ben_rec.abs_information27 := l_absence_rec.abs_information27;
  p_ben_rec.abs_information28 := l_absence_rec.abs_information28;
  p_ben_rec.abs_information29 := l_absence_rec.abs_information29;
  p_ben_rec.abs_information30 := l_absence_rec.abs_information30;

  hr_utility.set_location('Leaving: '|| l_proc, 15);
end;
--------------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Absence_Attendance_Id        IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Absence_Attendance_Type_Id          NUMBER,
                     X_Abs_Attendance_Reason_Id            NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Authorising_Person_Id               NUMBER,
                     X_Replacement_Person_Id               NUMBER,
                     X_Period_Of_Incapacity_Id             NUMBER,
                     X_Absence_Days                        NUMBER,
                     X_Absence_Hours                       NUMBER,
                     X_Comments                            VARCHAR2,
                     X_Date_End                            DATE,
                     X_Date_Notification                   DATE,
                     X_Date_Projected_End                  DATE,
                     X_Date_Projected_Start                DATE,
                     X_Date_Start                          DATE,
                     X_Occurrence                          NUMBER,
                     X_Ssp1_Issued                         VARCHAR2,
                     X_Time_End                            VARCHAR2,
                     X_Time_Projected_End                  VARCHAR2,
                     X_Time_Projected_Start                VARCHAR2,
                     X_Time_Start                          VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2  ,
    X_Linked_Absence_id                   NUMBER,
    X_Sickness_Start_Date                 DATE,
    X_Sickness_End_Date                   DATE,
    X_Accept_Late_Notif_Flag              VARCHAR2,
    x_reason_for_late_notification        VARCHAR2,
    X_Pregnancy_Related_Illness           VARCHAR2,
    X_Maternity_Id                        NUMBER,
    X_Batch_Id                            NUMBER default null,
    X_Abs_Information_Category            VARCHAR2,
    X_Abs_Information1                    VARCHAR2,
    X_Abs_Information2                    VARCHAR2,
    X_Abs_Information3                    VARCHAR2,
    X_Abs_Information4                    VARCHAR2,
    X_Abs_Information5                    VARCHAR2,
    X_Abs_Information6                    VARCHAR2,
    X_Abs_Information7                    VARCHAR2,
    X_Abs_Information8                    VARCHAR2,
    X_Abs_Information9                    VARCHAR2,
    X_Abs_Information10                   VARCHAR2,
    X_Abs_Information11                   VARCHAR2,
    X_Abs_Information12                   VARCHAR2,
    X_Abs_Information13                   VARCHAR2,
    X_Abs_Information14                   VARCHAR2,
    X_Abs_Information15                   VARCHAR2,
    X_Abs_Information16                   VARCHAR2,
    X_Abs_Information17                   VARCHAR2,
    X_Abs_Information18                   VARCHAR2,
    X_Abs_Information19                   VARCHAR2,
    X_Abs_Information20                   VARCHAR2,
    X_Abs_Information21                   VARCHAR2,
    X_Abs_Information22                   VARCHAR2,
    X_Abs_Information23                   VARCHAR2,
    X_Abs_Information24                   VARCHAR2,
    X_Abs_Information25                   VARCHAR2,
    X_Abs_Information26                   VARCHAR2,
    X_Abs_Information27                   VARCHAR2,
    X_Abs_Information28                   VARCHAR2,
    X_Abs_Information29                   VARCHAR2,
    X_Abs_Information30                   VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM per_absence_attendances
             WHERE  absence_attendance_id = X_absence_attendance_id;

    CURSOR C2 IS SELECT per_absence_attendances_s.nextval FROM sys.dual;

cursor csr_later_sickness is
        select  1
        from    per_absence_attendances
        where   person_id = X_person_id
        and     sickness_start_date is not null
        and     sickness_start_date > X_sickness_start_date;
        --
l_dummy number;
  --
  -- Start of BUGFIX for WWBUG 1408379
  --
  l_old ben_abs_ler.g_abs_ler_rec;
  l_new ben_abs_ler.g_abs_ler_rec;
  --
  -- End of BUGFIX for WWBUG 1408379
  --
BEGIN

   --
   -- Check that maternity absence does not start before the QW
   check_val_abs_start (p_maternity_id  => x_maternity_id,
                        p_date_start    => x_date_start);
   --
   -- Prevent insertion of sickness absence prior to an existing sickness
   -- for the person
   --
   if X_sickness_start_date is not null then
     --
     -- We must be dealing with a sickness absence
     --
     open csr_later_sickness;
     fetch csr_later_sickness into l_dummy;
     if csr_later_sickness%found then
       --
       close csr_later_sickness;
       constraint_error (p_constraint_name => 'SSP_35037_PIW_BROKEN');
       --
      else
        --
        close csr_later_sickness;
        --
      end if;
      --
    end if;
    --

   if (X_absence_attendance_id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_absence_attendance_id;
     CLOSE C2;
   end if;
  INSERT INTO per_absence_attendances(
          absence_attendance_id,
          business_group_id,
          absence_attendance_type_id,
          abs_attendance_reason_id,
          person_id,
          authorising_person_id,
          replacement_person_id,
          period_of_incapacity_id,
          absence_days,
          absence_hours,
          comments,
          date_end,
          date_notification,
          date_projected_end,
          date_projected_start,
          date_start,
          occurrence,
          ssp1_issued,
          time_end,
          time_projected_end,
          time_projected_start,
          time_start,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          Linked_Absence_id,
          Sickness_Start_Date,
          Sickness_End_Date,
          Accept_Late_Notification_Flag,
          reason_for_notification_delay,
          Pregnancy_Related_Illness,
          Maternity_Id,
          Batch_Id,
          abs_information_category,
          abs_information1,
          abs_information2,
          abs_information3,
          abs_information4,
          abs_information5,
          abs_information6,
          abs_information7,
          abs_information8,
          abs_information9,
          abs_information10,
          abs_information11,
          abs_information12,
          abs_information13,
          abs_information14,
          abs_information15,
          abs_information16,
          abs_information17,
          abs_information18,
          abs_information19,
          abs_information20,
          abs_information21,
          abs_information22,
          abs_information23,
          abs_information24,
          abs_information25,
          abs_information26,
          abs_information27,
          abs_information28,
          abs_information29,
          abs_information30
         ) VALUES (
          X_Absence_Attendance_Id,
          X_Business_Group_Id,
          X_Absence_Attendance_Type_Id,
          X_Abs_Attendance_Reason_Id,
          X_Person_Id,
          X_Authorising_Person_Id,
          X_Replacement_Person_Id,
          X_Period_Of_Incapacity_Id,
          X_Absence_Days,
          X_Absence_Hours,
          X_Comments,
          X_Date_End,
          X_Date_Notification,
          X_Date_Projected_End,
          X_Date_Projected_Start,
          X_Date_Start,
          X_Occurrence,
          X_Ssp1_Issued,
          X_Time_End,
          X_Time_Projected_End,
          X_Time_Projected_Start,
          X_Time_Start,
          X_Attribute_Category,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
          X_Attribute16,
          X_Attribute17,
          X_Attribute18,
          X_Attribute19,
          X_Attribute20,
          X_Linked_Absence_id,
          X_Sickness_Start_Date,
          X_Sickness_End_Date,
          X_Accept_Late_Notif_Flag,
          x_reason_for_late_notification,
          X_Pregnancy_Related_Illness,
          X_Maternity_Id,
          X_Batch_Id,
          X_Abs_Information_Category,
          X_Abs_Information1,
          X_Abs_Information2,
          X_Abs_Information3,
          X_Abs_Information4,
          X_Abs_Information5,
          X_Abs_Information6,
          X_Abs_Information7,
          X_Abs_Information8,
          X_Abs_Information9,
          X_Abs_Information10,
          X_Abs_Information11,
          X_Abs_Information12,
          X_Abs_Information13,
          X_Abs_Information14,
          X_Abs_Information15,
          X_Abs_Information16,
          X_Abs_Information17,
          X_Abs_Information18,
          X_Abs_Information19,
          X_Abs_Information20,
          X_Abs_Information21,
          X_Abs_Information22,
          X_Abs_Information23,
          X_Abs_Information24,
          X_Abs_Information25,
          X_Abs_Information26,
          X_Abs_Information27,
          X_Abs_Information28,
          X_Abs_Information29,
          X_Abs_Information30
  );
  --
  -- Start of BUGFIX for WWBUG 1408379
  --
  populate_ben_absence_rec
  (p_absence_attendance_id => x_absence_attendance_id,
   p_rec_type => 'N',
   p_old_rec => null,
   p_ben_rec => l_new);

  ben_abs_ler.ler_chk(p_old            => l_old,
                      p_new            => l_new,
                      p_effective_date => trunc(nvl(l_new.date_start,sysdate)));
  --
  -- End of BUGFIX for WWBUG 1408379
  --
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  --
  -- SSP users only:
  -- If the MPP has not started and the absence is maternity leave, update
  -- the MPP start date
  --
  default_MPP_start_date (p_maternity_id        => x_maternity_id,
                          p_start_date          => x_date_start,
                          p_end_date            => x_date_end);
  --
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
   PER_ABSENCE_ATTENDANCES_PKG.constraint_error
       (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
   PER_ABSENCE_ATTENDANCES_PKG.constraint_error
         (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
   PER_ABSENCE_ATTENDANCES_PKG.constraint_error
         (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
     Raise;
END Insert_Row;



PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Absence_Attendance_Id                 NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Absence_Attendance_Type_Id            NUMBER,
                   X_Abs_Attendance_Reason_Id              NUMBER,
                   X_Person_Id                             NUMBER,
                   X_Authorising_Person_Id                 NUMBER,
                   X_Replacement_Person_Id                 NUMBER,
                   X_Period_Of_Incapacity_Id               NUMBER,
                   X_Absence_Days                          NUMBER,
                   X_Absence_Hours                         NUMBER,
                   X_Comments                              VARCHAR2,
                   X_Date_End                              DATE,
                   X_Date_Notification                     DATE,
                   X_Date_Projected_End                    DATE,
                   X_Date_Projected_Start                  DATE,
                   X_Date_Start                            DATE,
                   X_Occurrence                            NUMBER,
                   X_Ssp1_Issued                           VARCHAR2,
                   X_Time_End                              VARCHAR2,
                   X_Time_Projected_End                    VARCHAR2,
                   X_Time_Projected_Start                  VARCHAR2,
                   X_Time_Start                            VARCHAR2,
                   X_Attribute_Category                    VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
                   X_Attribute16                           VARCHAR2,
                   X_Attribute17                           VARCHAR2,
                   X_Attribute18                           VARCHAR2,
                   X_Attribute19                           VARCHAR2,
                   X_Attribute20                           VARCHAR2  ,
                     X_Linked_Absence_id                   NUMBER,
                     X_Sickness_Start_Date                 DATE,
                     X_Sickness_End_Date                   DATE,
                     X_Accept_Late_Notif_Flag              VARCHAR2,
                     x_reason_for_late_notification        VARCHAR2,
                     X_Pregnancy_Related_Illness           VARCHAR2,
                     X_Maternity_Id                        NUMBER,
                     X_Abs_Information_Category            VARCHAR2,
                     X_Abs_Information1                    VARCHAR2,
                     X_Abs_Information2                    VARCHAR2,
                     X_Abs_Information3                    VARCHAR2,
                     X_Abs_Information4                    VARCHAR2,
                     X_Abs_Information5                    VARCHAR2,
                     X_Abs_Information6                    VARCHAR2,
                     X_Abs_Information7                    VARCHAR2,
                     X_Abs_Information8                    VARCHAR2,
                     X_Abs_Information9                    VARCHAR2,
                     X_Abs_Information10                   VARCHAR2,
                     X_Abs_Information11                   VARCHAR2,
                     X_Abs_Information12                   VARCHAR2,
                     X_Abs_Information13                   VARCHAR2,
                     X_Abs_Information14                   VARCHAR2,
                     X_Abs_Information15                   VARCHAR2,
                     X_Abs_Information16                   VARCHAR2,
                     X_Abs_Information17                   VARCHAR2,
                     X_Abs_Information18                   VARCHAR2,
                     X_Abs_Information19                   VARCHAR2,
                     X_Abs_Information20                   VARCHAR2,
                     X_Abs_Information21                   VARCHAR2,
                     X_Abs_Information22                   VARCHAR2,
                     X_Abs_Information23                   VARCHAR2,
                     X_Abs_Information24                   VARCHAR2,
                     X_Abs_Information25                   VARCHAR2,
                     X_Abs_Information26                   VARCHAR2,
                     X_Abs_Information27                   VARCHAR2,
                     X_Abs_Information28                   VARCHAR2,
                     X_Abs_Information29                   VARCHAR2,
                     X_Abs_Information30                   VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   per_absence_attendances
      WHERE  rowid = chartorowid(X_Rowid)
      FOR UPDATE of absence_attendance_id NOWAIT;

  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE', 'lock_row');
     hr_utility.set_message_token('STEP', '1');
     hr_utility.raise_error;
  end if;
  CLOSE C;

recinfo.comments := rtrim(recinfo.comments);
recinfo.ssp1_issued := rtrim(recinfo.ssp1_issued);
recinfo.time_end := rtrim(recinfo.time_end);
recinfo.time_projected_end := rtrim(recinfo.time_projected_end);
recinfo.time_projected_start := rtrim(recinfo.time_projected_start);
recinfo.time_start := rtrim(recinfo.time_start);
recinfo.attribute_category := rtrim(recinfo.attribute_category);
recinfo.attribute1 := rtrim(recinfo.attribute1);
recinfo.attribute2 := rtrim(recinfo.attribute2);
recinfo.attribute3 := rtrim(recinfo.attribute3);
recinfo.attribute4 := rtrim(recinfo.attribute4);
recinfo.attribute5 := rtrim(recinfo.attribute5);
recinfo.attribute6 := rtrim(recinfo.attribute6);
recinfo.attribute7 := rtrim(recinfo.attribute7);
recinfo.attribute8 := rtrim(recinfo.attribute8);
recinfo.attribute9 := rtrim(recinfo.attribute9);
recinfo.attribute10 := rtrim(recinfo.attribute10);
recinfo.attribute11 := rtrim(recinfo.attribute11);
recinfo.attribute12 := rtrim(recinfo.attribute12);
recinfo.attribute13 := rtrim(recinfo.attribute13);
recinfo.attribute14 := rtrim(recinfo.attribute14);
recinfo.attribute15 := rtrim(recinfo.attribute15);
recinfo.attribute16 := rtrim(recinfo.attribute16);
recinfo.attribute17 := rtrim(recinfo.attribute17);
recinfo.attribute18 := rtrim(recinfo.attribute18);
recinfo.attribute19 := rtrim(recinfo.attribute19);
recinfo.attribute20 := rtrim(recinfo.attribute20);
recinfo.abs_information_category := rtrim(recinfo.abs_information_category);
recinfo.abs_information1 := rtrim(recinfo.abs_information1);
recinfo.abs_information2 := rtrim(recinfo.abs_information2);
recinfo.abs_information3 := rtrim(recinfo.abs_information3);
recinfo.abs_information4 := rtrim(recinfo.abs_information4);
recinfo.abs_information5 := rtrim(recinfo.abs_information5);
recinfo.abs_information6 := rtrim(recinfo.abs_information6);
recinfo.abs_information7 := rtrim(recinfo.abs_information7);
recinfo.abs_information8 := rtrim(recinfo.abs_information8);
recinfo.abs_information9 := rtrim(recinfo.abs_information9);
recinfo.abs_information10 := rtrim(recinfo.abs_information10);
recinfo.abs_information11 := rtrim(recinfo.abs_information11);
recinfo.abs_information12 := rtrim(recinfo.abs_information12);
recinfo.abs_information13 := rtrim(recinfo.abs_information13);
recinfo.abs_information14 := rtrim(recinfo.abs_information14);
recinfo.abs_information15 := rtrim(recinfo.abs_information15);
recinfo.abs_information16 := rtrim(recinfo.abs_information16);
recinfo.abs_information17 := rtrim(recinfo.abs_information17);
recinfo.abs_information18 := rtrim(recinfo.abs_information18);
recinfo.abs_information19 := rtrim(recinfo.abs_information19);
recinfo.abs_information20 := rtrim(recinfo.abs_information20);
recinfo.abs_information21 := rtrim(recinfo.abs_information21);
recinfo.abs_information22 := rtrim(recinfo.abs_information22);
recinfo.abs_information23 := rtrim(recinfo.abs_information23);
recinfo.abs_information24 := rtrim(recinfo.abs_information24);
recinfo.abs_information25 := rtrim(recinfo.abs_information25);
recinfo.abs_information26 := rtrim(recinfo.abs_information26);
recinfo.abs_information27 := rtrim(recinfo.abs_information27);
recinfo.abs_information28 := rtrim(recinfo.abs_information28);
recinfo.abs_information29 := rtrim(recinfo.abs_information29);
recinfo.abs_information30 := rtrim(recinfo.abs_information30);

--
-- SSP additions
--
recinfo.accept_late_notification_flag
                      := rtrim(recinfo.accept_late_notification_flag);
recinfo.reason_for_notification_delay
                      := rtrim(recinfo.reason_for_notification_delay);
recinfo.pregnancy_related_illness := rtrim(recinfo.pregnancy_related_illness);

--
--

if (
          (   (Recinfo.absence_attendance_id = X_Absence_Attendance_Id)
           OR (    (Recinfo.absence_attendance_id IS NULL)
               AND (X_Absence_Attendance_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.absence_attendance_type_id = X_Absence_Attendance_Type_Id)
           OR (    (Recinfo.absence_attendance_type_id IS NULL)
               AND (X_Absence_Attendance_Type_Id IS NULL)))
      AND (   (Recinfo.abs_attendance_reason_id = X_Abs_Attendance_Reason_Id)
           OR (    (Recinfo.abs_attendance_reason_id IS NULL)
               AND (X_Abs_Attendance_Reason_Id IS NULL)))
      AND (   (Recinfo.person_id = X_Person_Id)
           OR (    (Recinfo.person_id IS NULL)
               AND (X_Person_Id IS NULL)))
      AND (   (Recinfo.authorising_person_id = X_Authorising_Person_Id)
           OR (    (Recinfo.authorising_person_id IS NULL)
               AND (X_Authorising_Person_Id IS NULL)))
      AND (   (Recinfo.replacement_person_id = X_Replacement_Person_Id)
           OR (    (Recinfo.replacement_person_id IS NULL)
               AND (X_Replacement_Person_Id IS NULL)))
      AND (   (Recinfo.period_of_incapacity_id = X_Period_Of_Incapacity_Id)
           OR (    (Recinfo.period_of_incapacity_id IS NULL)
               AND (X_Period_Of_Incapacity_Id IS NULL)))
      AND (   (Recinfo.absence_days = X_Absence_Days)
           OR (    (Recinfo.absence_days IS NULL)
               AND (X_Absence_Days IS NULL)))
      AND (   (Recinfo.absence_hours = X_Absence_Hours)
           OR (    (Recinfo.absence_hours IS NULL)
               AND (X_Absence_Hours IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.date_end = X_Date_End)
           OR (    (Recinfo.date_end IS NULL)
               AND (X_Date_End IS NULL)))
      AND (   (Recinfo.date_notification = X_Date_Notification)
           OR (    (Recinfo.date_notification IS NULL)
               AND (X_Date_Notification IS NULL)))
      AND (   (Recinfo.date_projected_end = X_Date_Projected_End)
           OR (    (Recinfo.date_projected_end IS NULL)
               AND (X_Date_Projected_End IS NULL)))
      AND (   (Recinfo.date_projected_start = X_Date_Projected_Start)
           OR (    (Recinfo.date_projected_start IS NULL)
               AND (X_Date_Projected_Start IS NULL)))
      AND (   (Recinfo.date_start = X_Date_Start)
           OR (    (Recinfo.date_start IS NULL)
               AND (X_Date_Start IS NULL)))
      AND (   (Recinfo.occurrence = X_Occurrence)
           OR (    (Recinfo.occurrence IS NULL)
               AND (X_Occurrence IS NULL)))
      AND (   (Recinfo.ssp1_issued = X_Ssp1_Issued)
           OR (    (Recinfo.ssp1_issued IS NULL)
               AND (X_Ssp1_Issued IS NULL)))
      AND (   (Recinfo.time_end = X_Time_End)
           OR (    (Recinfo.time_end IS NULL)
               AND (X_Time_End IS NULL)))
      AND (   (Recinfo.time_projected_end = X_Time_Projected_End)
           OR (    (Recinfo.time_projected_end IS NULL)
               AND (X_Time_Projected_End IS NULL)))
      AND (   (Recinfo.time_projected_start = X_Time_Projected_Start)
           OR (    (Recinfo.time_projected_start IS NULL)
               AND (X_Time_Projected_Start IS NULL)))
      AND (   (Recinfo.time_start = X_Time_Start)
           OR (    (Recinfo.time_start IS NULL)
               AND (X_Time_Start IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.attribute16 = X_Attribute16)
           OR (    (Recinfo.attribute16 IS NULL)
               AND (X_Attribute16 IS NULL)))
      AND (   (Recinfo.attribute17 = X_Attribute17)
           OR (    (Recinfo.attribute17 IS NULL)
               AND (X_Attribute17 IS NULL)))
      AND (   (Recinfo.attribute18 = X_Attribute18)
           OR (    (Recinfo.attribute18 IS NULL)
               AND (X_Attribute18 IS NULL)))
      AND (   (Recinfo.attribute19 = X_Attribute19)
           OR (    (Recinfo.attribute19 IS NULL)
               AND (X_Attribute19 IS NULL)))
      AND (   (Recinfo.attribute20 = X_Attribute20)
           OR (    (Recinfo.attribute20 IS NULL)
               AND (X_Attribute20 IS NULL)))
          --
          -- SSP Columns  added SS 2/10/1995
          --

      AND (   (Recinfo.linked_absence_id = X_linked_absence_id)
           OR (    (Recinfo.linked_absence_id IS NULL)
               AND (X_linked_absence_id IS NULL)))
      AND (   (Recinfo.sickness_start_date = X_sickness_start_date)
           OR (    (Recinfo.sickness_start_date IS NULL)
               AND (X_sickness_start_date IS NULL)))
      AND (   (Recinfo.sickness_end_date = X_sickness_end_date)
           OR (    (Recinfo.sickness_end_date IS NULL)
               AND (X_sickness_end_date IS NULL)))
      AND (   (Recinfo.accept_late_notification_flag = X_accept_late_notif_flag)
           OR (    (Recinfo.accept_late_notification_flag IS NULL)
               AND (X_accept_late_notif_flag IS NULL)))
      AND ((Recinfo.reason_for_notification_delay=x_reason_for_late_notification)
           OR (    (Recinfo.reason_for_notification_delay IS NULL)
               AND (x_reason_for_late_notification IS NULL)))
      AND (   (Recinfo.pregnancy_related_illness = X_pregnancy_related_illness)
           OR (    (Recinfo.pregnancy_related_illness IS NULL)
               AND (X_pregnancy_related_illness IS NULL)))
      AND (   (Recinfo.maternity_id = X_maternity_id)
           OR (    (Recinfo.maternity_id IS NULL)
               AND (X_maternity_id IS NULL)))
      AND (   (Recinfo.abs_information_category = X_Abs_Information_Category)
           OR (    (Recinfo.abs_information_category IS NULL)
               AND (X_Abs_Information_Category IS NULL)))
      AND (   (Recinfo.abs_information1 = X_Abs_Information1)
           OR (    (Recinfo.abs_information1 IS NULL)
               AND (X_Abs_Information1 IS NULL)))
      AND (   (Recinfo.abs_information2 = X_Abs_Information2)
           OR (    (Recinfo.abs_information2 IS NULL)
               AND (X_Abs_Information2 IS NULL)))
      AND (   (Recinfo.abs_information3 = X_Abs_Information3)
           OR (    (Recinfo.abs_information3 IS NULL)
               AND (X_Abs_Information3 IS NULL)))
      AND (   (Recinfo.abs_information4 = X_Abs_Information4)
           OR (    (Recinfo.abs_information4 IS NULL)
               AND (X_Abs_Information4 IS NULL)))
      AND (   (Recinfo.abs_information5 = X_Abs_Information5)
           OR (    (Recinfo.abs_information5 IS NULL)
               AND (X_Abs_Information5 IS NULL)))
      AND (   (Recinfo.abs_information6 = X_Abs_Information6)
           OR (    (Recinfo.abs_information6 IS NULL)
               AND (X_Abs_Information6 IS NULL)))
      AND (   (Recinfo.abs_information7 = X_Abs_Information7)
           OR (    (Recinfo.abs_information7 IS NULL)
               AND (X_Abs_Information7 IS NULL)))
      AND (   (Recinfo.abs_information8 = X_Abs_Information8)
           OR (    (Recinfo.abs_information8 IS NULL)
               AND (X_Abs_Information8 IS NULL)))
      AND (   (Recinfo.abs_information9 = X_Abs_Information9)
           OR (    (Recinfo.abs_information9 IS NULL)
               AND (X_Abs_Information9 IS NULL)))
      AND (   (Recinfo.abs_information10 = X_Abs_Information10)
           OR (    (Recinfo.abs_information10 IS NULL)
               AND (X_Abs_Information10 IS NULL)))
      AND (   (Recinfo.abs_information11 = X_Abs_Information11)
           OR (    (Recinfo.abs_information11 IS NULL)
               AND (X_Abs_Information11 IS NULL)))
      AND (   (Recinfo.abs_information12 = X_Abs_Information12)
           OR (    (Recinfo.abs_information12 IS NULL)
               AND (X_Abs_Information12 IS NULL)))
      AND (   (Recinfo.abs_information13 = X_Abs_Information13)
           OR (    (Recinfo.abs_information13 IS NULL)
               AND (X_Abs_Information13 IS NULL)))
      AND (   (Recinfo.abs_information14 = X_Abs_Information14)
           OR (    (Recinfo.abs_information14 IS NULL)
               AND (X_Abs_Information14 IS NULL)))
      AND (   (Recinfo.abs_information15 = X_Abs_Information15)
           OR (    (Recinfo.abs_information15 IS NULL)
               AND (X_Abs_Information15 IS NULL)))
      AND (   (Recinfo.abs_information16 = X_Abs_Information16)
           OR (    (Recinfo.abs_information16 IS NULL)
               AND (X_Abs_Information16 IS NULL)))
      AND (   (Recinfo.abs_information17 = X_Abs_Information17)
           OR (    (Recinfo.abs_information17 IS NULL)
               AND (X_Abs_Information17 IS NULL)))
      AND (   (Recinfo.abs_information18 = X_Abs_Information18)
           OR (    (Recinfo.abs_information18 IS NULL)
               AND (X_Abs_Information18 IS NULL)))
      AND (   (Recinfo.abs_information19 = X_Abs_Information19)
           OR (    (Recinfo.abs_information19 IS NULL)
               AND (X_Abs_Information19 IS NULL)))
      AND (   (Recinfo.abs_information20 = X_Abs_Information20)
           OR (    (Recinfo.abs_information20 IS NULL)
               AND (X_Abs_Information20 IS NULL)))
        AND (   (Recinfo.abs_information21 = X_Abs_Information21)
           OR (    (Recinfo.abs_information21 IS NULL)
               AND (X_Abs_Information21 IS NULL)))
      AND (   (Recinfo.abs_information22 = X_Abs_Information22)
           OR (    (Recinfo.abs_information22 IS NULL)
               AND (X_Abs_Information22 IS NULL)))
      AND (   (Recinfo.abs_information23 = X_Abs_Information23)
           OR (    (Recinfo.abs_information23 IS NULL)
               AND (X_Abs_Information23 IS NULL)))
      AND (   (Recinfo.abs_information24 = X_Abs_Information24)
           OR (    (Recinfo.abs_information24 IS NULL)
               AND (X_Abs_Information24 IS NULL)))
      AND (   (Recinfo.abs_information25 = X_Abs_Information25)
           OR (    (Recinfo.abs_information25 IS NULL)
               AND (X_Abs_Information25 IS NULL)))
      AND (   (Recinfo.abs_information26 = X_Abs_Information26)
           OR (    (Recinfo.abs_information26 IS NULL)
               AND (X_Abs_Information26 IS NULL)))
      AND (   (Recinfo.abs_information27 = X_Abs_Information27)
           OR (    (Recinfo.abs_information27 IS NULL)
               AND (X_Abs_Information27 IS NULL)))
      AND (   (Recinfo.abs_information28 = X_Abs_Information28)
           OR (    (Recinfo.abs_information28 IS NULL)
               AND (X_Abs_Information28 IS NULL)))
      AND (   (Recinfo.abs_information29 = X_Abs_Information29)
           OR (    (Recinfo.abs_information29 IS NULL)
               AND (X_Abs_Information29 IS NULL)))
      AND (   (Recinfo.abs_information30 = X_Abs_Information30)
           OR (    (Recinfo.abs_information30 IS NULL)
               AND (X_Abs_Information30 IS NULL)))
          )
  then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    fnd_message.raise_error;
  end if;
END Lock_Row;



PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Absence_Attendance_Id               NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Absence_Attendance_Type_Id          NUMBER,
                     X_Abs_Attendance_Reason_Id            NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Authorising_Person_Id               NUMBER,
                     X_Replacement_Person_Id               NUMBER,
                     X_Period_Of_Incapacity_Id             NUMBER,
                     X_Absence_Days                        NUMBER,
                     X_Absence_Hours                       NUMBER,
                     X_Comments                            VARCHAR2,
                     X_Date_End                            DATE,
                     X_Date_Notification                   DATE,
                     X_Date_Projected_End                  DATE,
                     X_Date_Projected_Start                DATE,
                     X_Date_Start                          DATE,
                     X_Occurrence                          NUMBER,
                     X_Ssp1_Issued                         VARCHAR2,
                     X_Time_End                            VARCHAR2,
                     X_Time_Projected_End                  VARCHAR2,
                     X_Time_Projected_Start                VARCHAR2,
                     X_Time_Start                          VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2  ,
                     X_Linked_Absence_id                   NUMBER  ,
                     X_Sickness_Start_Date                 DATE,
                     X_Sickness_End_Date                   DATE,
                     X_Accept_Late_Notif_Flag              VARCHAR2,
                     x_reason_for_late_notification        VARCHAR2,
                     X_Pregnancy_Related_Illness           VARCHAR2,
                     X_Maternity_Id                        NUMBER,
                     X_Abs_Information_Category            VARCHAR2,
                     X_Abs_Information1                    VARCHAR2,
                     X_Abs_Information2                    VARCHAR2,
                     X_Abs_Information3                    VARCHAR2,
                     X_Abs_Information4                    VARCHAR2,
                     X_Abs_Information5                    VARCHAR2,
                     X_Abs_Information6                    VARCHAR2,
                     X_Abs_Information7                    VARCHAR2,
                     X_Abs_Information8                    VARCHAR2,
                     X_Abs_Information9                    VARCHAR2,
                     X_Abs_Information10                   VARCHAR2,
                     X_Abs_Information11                   VARCHAR2,
                     X_Abs_Information12                   VARCHAR2,
                     X_Abs_Information13                   VARCHAR2,
                     X_Abs_Information14                   VARCHAR2,
                     X_Abs_Information15                   VARCHAR2,
                     X_Abs_Information16                   VARCHAR2,
                     X_Abs_Information17                   VARCHAR2,
                     X_Abs_Information18                   VARCHAR2,
                     X_Abs_Information19                   VARCHAR2,
                     X_Abs_Information20                   VARCHAR2,
                     X_Abs_Information21                   VARCHAR2,
                     X_Abs_Information22                   VARCHAR2,
                     X_Abs_Information23                   VARCHAR2,
                     X_Abs_Information24                   VARCHAR2,
                     X_Abs_Information25                   VARCHAR2,
                     X_Abs_Information26                   VARCHAR2,
                     X_Abs_Information27                   VARCHAR2,
                     X_Abs_Information28                   VARCHAR2,
                     X_Abs_Information29                   VARCHAR2,
                     X_Abs_Information30                   VARCHAR2
) IS

cursor csr_absence is
        select  *
        from    per_absence_attendances
        where   absence_attendance_id = X_absence_attendance_id;
        --
l_absence       csr_absence%rowtype;
--
  --
  -- Start of BUGFIX for WWBUG 1408379
  --
  cursor c1 is
    select *
    from   per_absence_attendances
    where  rowid = chartorowid(X_rowid);
  --
  l_c1 c1%rowtype;
  l_rows_found boolean := false;
  --
  l_old ben_abs_ler.g_abs_ler_rec;
  l_new ben_abs_ler.g_abs_ler_rec;
  --
  -- End of BUGFIX for WWBUG 1408379
  --
BEGIN

  -- Check that maternity absence does not start before the QW
  check_val_abs_start (p_maternity_id   => x_maternity_id,
                        p_date_start    => x_date_start);
  --
  --
  if X_sickness_start_date is not null then
    --
    -- We must be dealing with a sickness absence. Find the old values for the
    -- absence being updated (for use later).
    --
    open csr_absence;
    fetch csr_absence into l_absence;
    close csr_absence;
    --
  end if;
  --
  -- Start of BUGFIX for WWBUG 1408379
  --
  open c1;
    --
    fetch c1 into l_c1;
    if c1%found then
      --
      l_rows_found := true;
      --
    end if;
    --
  close c1;
  --
  -- End of BUGFIX for WWBUG 1408379
  --
  UPDATE per_absence_attendances
  SET
    absence_attendance_id                     =    X_Absence_Attendance_Id,
    business_group_id                         =    X_Business_Group_Id,
    absence_attendance_type_id                =    X_Absence_Attendance_Type_Id,
    abs_attendance_reason_id                  =    X_Abs_Attendance_Reason_Id,
    person_id                                 =    X_Person_Id,
    authorising_person_id                     =    X_Authorising_Person_Id,
    replacement_person_id                     =    X_Replacement_Person_Id,
    period_of_incapacity_id                   =    X_Period_Of_Incapacity_Id,
    absence_days                              =    X_Absence_Days,
    absence_hours                             =    X_Absence_Hours,
    comments                                  =    X_Comments,
    date_end                                  =    X_Date_End,
    date_notification                         =    X_Date_Notification,
    date_projected_end                        =    X_Date_Projected_End,
    date_projected_start                      =    X_Date_Projected_Start,
    date_start                                =    X_Date_Start,
    occurrence                                =    X_Occurrence,
    ssp1_issued                               =    X_Ssp1_Issued,
    time_end                                  =    X_Time_End,
    time_projected_end                        =    X_Time_Projected_End,
    time_projected_start                      =    X_Time_Projected_Start,
    time_start                                =    X_Time_Start,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    attribute16                               =    X_Attribute16,
    attribute17                               =    X_Attribute17,
    attribute18                               =    X_Attribute18,
    attribute19                               =    X_Attribute19,
    attribute20                               =    X_Attribute20  ,
    Linked_Absence_id                    = X_Linked_Absence_Id,
    Sickness_Start_Date                  = X_Sickness_Start_Date,
    Sickness_End_Date                    = X_Sickness_End_Date,
    Accept_Late_Notification_Flag        = X_Accept_Late_Notif_Flag,
    reason_for_notification_delay    = x_reason_for_late_notification,
    Pregnancy_Related_Illness          = X_Pregnancy_Related_Illness,
    Maternity_Id                         = X_Maternity_Id,
    Batch_Id                             = NULL,
    abs_information_category                  =    X_Abs_Information_Category,
    abs_information1                          =    X_Abs_Information1,
    abs_information2                          =    X_Abs_Information2,
    abs_information3                          =    X_Abs_Information3,
    abs_information4                          =    X_Abs_Information4,
    abs_information5                          =    X_Abs_Information5,
    abs_information6                          =    X_Abs_Information6,
    abs_information7                          =    X_Abs_Information7,
    abs_information8                          =    X_Abs_Information8,
    abs_information9                          =    X_Abs_Information9,
    abs_information10                         =    X_Abs_Information10,
    abs_information11                         =    X_Abs_Information11,
    abs_information12                         =    X_Abs_Information12,
    abs_information13                         =    X_Abs_Information13,
    abs_information14                         =    X_Abs_Information14,
    abs_information15                         =    X_Abs_Information15,
    abs_information16                         =    X_Abs_Information16,
    abs_information17                         =    X_Abs_Information17,
    abs_information18                         =    X_Abs_Information18,
    abs_information19                         =    X_Abs_Information19,
    abs_information20                         =    X_Abs_Information20,
    abs_information21                         =    X_Abs_Information21,
    abs_information22                         =    X_Abs_Information22,
    abs_information23                         =    X_Abs_Information23,
    abs_information24                         =    X_Abs_Information24,
    abs_information25                         =    X_Abs_Information25,
    abs_information26                         =    X_Abs_Information26,
    abs_information27                         =    X_Abs_Information27,
    abs_information28                         =    X_Abs_Information28,
    abs_information29                         =    X_Abs_Information29,
    abs_information30                         =    X_Abs_Information30
  WHERE rowid = chartorowid(X_rowid);
  --
  -- Start of BUGFIX for WWBUG 1408379
  --
  if l_rows_found then
    --
    populate_ben_absence_rec
    (p_absence_attendance_id => x_absence_attendance_id,
     p_rec_type => 'O',
     p_old_rec => l_c1,
     p_ben_rec => l_old);

    populate_ben_absence_rec
    (p_absence_attendance_id => x_absence_attendance_id,
     p_rec_type => 'N',
     p_old_rec => null,
     p_ben_rec => l_new);

    ben_abs_ler.ler_chk(p_old            => l_old,
                        p_new            => l_new,
                        p_effective_date => trunc(nvl(l_new.date_start,sysdate)));

    --
  end if;
  --
  -- End of BUGFIX for WWBUG 1408379
  --
  --
  -- SSP specific code to check the effect of the update of sickness dates.
  --
  if X_sickness_start_date is not null
  and (l_absence.sickness_start_date <> X_sickness_start_date
      or nvl (l_absence.sickness_end_date,
                hr_general.end_of_time) <> nvl (X_sickness_end_date,
                                                hr_general.end_of_time) )
  then
    --
    -- The sickness dates are being updated. Make sure that the PIW series is
    -- not affected as a result of the update.
    --
    ssp_ssp_pkg.check_sickness_date_change (
        --
        p_person_id                     => l_absence.person_id,
        p_linked_absence_id             => l_absence.linked_absence_id,
        p_absence_attendance_id         => l_absence.absence_attendance_id,
        p_old_sickness_end_date         => l_absence.sickness_end_date,
        p_new_sickness_start_date       => X_sickness_start_date,
        p_new_sickness_end_date         => X_sickness_end_date);
    --
  end if;
  --
  -- SSP users only:
  -- If the MPP has not started and the absence is maternity leave, update
  -- the MPP start date
  --
  default_MPP_start_date (p_maternity_id        => x_maternity_id,
                          p_start_date          => x_date_start,
                          p_end_date            => x_date_end);
  --
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
   PER_ABSENCE_ATTENDANCES_PKG.constraint_error
       (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
   PER_ABSENCE_ATTENDANCES_PKG.constraint_error
         (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
   PER_ABSENCE_ATTENDANCES_PKG.constraint_error
         (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
     Raise;
END Update_Row;



PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
--
cursor csr_current_absence is
        select  *
        from    per_absence_attendances
        where   rowid = X_ROWID;
        --
l_absence       csr_current_absence%rowtype;
l_old ben_abs_ler.g_abs_ler_rec;
l_new ben_abs_ler.g_abs_ler_rec;
--
BEGIN
  --
  open csr_current_absence;
  fetch csr_current_absence into l_absence;
  close csr_current_absence;
  --
  if l_absence.sickness_start_date is not null then
    --
    -- This is a sickness absence so check that deletion will not interrupt a
    -- PIW series.
    --
    ssp_ssp_pkg.check_for_break_in_linked_PIW (
        --
        p_sickness_start_date   => l_absence.sickness_start_date,
        p_sickness_end_date     => l_absence.sickness_end_date,
        p_linked_absence_id     => l_absence.linked_absence_id,
        p_absence_attendance_id => l_absence.absence_attendance_id);
        --
  end if;
  --
  DELETE FROM per_absence_attendances
  WHERE  rowid = chartorowid(X_Rowid);

  if (SQL%NOTFOUND) then
  hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token('PROCEDURE', 'delete_row');
  hr_utility.set_message_token('STEP', '1');
  hr_utility.raise_error;
  end if;

  populate_ben_absence_rec
  (p_absence_attendance_id => l_absence.absence_attendance_id,
   p_rec_type => 'O',
   p_old_rec => l_absence,
   p_ben_rec => l_old);

  ben_abs_ler.ler_chk(p_old            => l_old,
                      p_new            => l_new,
                      p_effective_date => trunc(sysdate));
END Delete_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2, p_maternity_id in number) IS
--
begin
--
Delete_Row(X_Rowid);
reset_MPP_start_date_on_delete (p_maternity_id);
--
END Delete_Row;


procedure b_check_auth_de(p_date_start IN DATE,
                          p_proj_start IN DATE,
                          p_date_end IN DATE,
                          p_proj_end IN DATE,
                          p_sess In DATE,
                          p_auth_id IN NUMBER) is
l_exists VARCHAR2(1);

cursor c1 is
select 'x'
from per_all_people_f pp
where nvl(p_date_start,nvl(p_proj_start,p_sess)) >=
                (select min(ppf.effective_start_date)
                 from per_all_people_f ppf
                 where pp.person_id = ppf.person_id
                 and   pp.current_employee_flag = ppf.current_employee_flag)
and nvl(p_date_end,nvl(p_proj_end,p_sess)) <=
                (select max(ppf.effective_end_date)
                 from per_all_people_f ppf
                 where pp.person_id = ppf.person_id
                 and   pp.current_employee_flag = ppf.current_employee_flag)
-- where nvl(p_date_start,nvl(p_proj_start,p_sess)) between
--       pp.effective_start_date and pp.effective_end_date
-- and nvl(p_date_end,nvl(p_proj_end,p_sess)) between
--       pp.effective_start_date and pp.effective_end_date
and   pp.person_id = p_auth_id
and   pp.current_employee_flag = 'Y';
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.b_check_auth_de',1);
--
open c1;
--
  fetch c1 into l_exists;
  IF c1%notfound THEN
  hr_utility.set_message(801, 'PER_7886_EMP_ABS_DURATION');
  close c1;
  hr_utility.raise_error;
  END IF;
--
close c1;
--
end b_check_auth_de;


procedure b_check_rep_de(p_date_start In DATE,
                         p_date_proj_start IN DATE,
                         p_date_end IN DATE,
                         p_date_proj_end IN DATE,
                         p_sess IN DATE,
                         p_rep_id IN NUMBER) is
l_exists VARCHAR2(1);

cursor c3 is
select 'x'
from per_all_people_f pp
where nvl(p_date_start,nvl(p_date_proj_start,p_sess)) >=
                (select min(ppf.effective_start_date)
                 from per_all_people_f ppf
                 where pp.person_id = ppf.person_id
                 and   pp.current_employee_flag = ppf.current_employee_flag)
and nvl(p_date_end,nvl(p_date_proj_end,p_sess)) <=
                (select max(ppf.effective_end_date)
                 from per_all_people_f ppf
                 where pp.person_id = ppf.person_id
                 and   pp.current_employee_flag = ppf.current_employee_flag)
-- where nvl(p_date_start,nvl(p_date_proj_start,p_sess)) between
--      pp.effective_start_date and pp.effective_end_date
-- and nvl(p_date_end,nvl(p_date_proj_end,p_sess)) between
--      pp.effective_start_date and pp.effective_end_date
and   pp.person_id = p_rep_id
and   pp.current_employee_flag = 'Y';
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.b_check_rep_de',1);
--
open c3;
--
  fetch c3 into l_exists;
  IF c3%notfound THEN
  hr_utility.set_message(801, 'PER_7887_EMP_ABS_DURATION');
  close c3;
  hr_utility.raise_error;
  END IF;
--
close c3;
--
end b_check_rep_de;


function check_for_term(p_date IN DATE,
                        p_rep_per IN NUMBER)
  RETURN BOOLEAN IS
l_ret_val BOOLEAN;

cursor c2 is
select 'x'
from per_periods_of_service p
where ((trunc(p.actual_termination_date) < p_date
and   p.actual_termination_date is not null)
or    (trunc(p.projected_termination_date) < p_date
and   p.projected_termination_date is not null))
and   p.person_id = p_rep_per;
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.b_check_for_termination',1);
--
open c2;
--
  l_ret_val := c2%found;
--
close c2;
--
RETURN l_ret_val;
--
end check_for_term;



function chk_rep_req(p_psn_id IN NUMBER,
                     p_dstart IN DATE,
                     p_proj_start IN DATE,
                     p_sess IN DATE)
   RETURN BOOLEAN is
l_exists number;
l_ret_val BOOLEAN;
--
-- Changed 12-Oct-99 SCNair (per_positions to hr_positions) Date tracked position req.
--
cursor c4 is
select 1
from hr_positions_f pp,
     per_assignments_f asg
where asg.person_id = p_psn_id
and nvl(p_dstart,nvl(p_proj_start,p_sess)) between
    asg.effective_start_date and asg.effective_end_date
and pp.position_id = asg.position_id
and nvl(p_dstart,nvl(p_proj_start,p_sess)) between
    pp.effective_start_date and pp.effective_end_date
and pp.replacement_required_flag = 'Y';
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.chk_rep_req',1);
--
open c4;
fetch c4 into l_exists;
--
IF c4%found THEN
  l_ret_val := true;
ELSE l_ret_val := false;
END IF;
--
close c4;
--
RETURN (l_ret_val);
--
end chk_rep_req;


procedure chk_type(p_abat_type In NUMBER,
                   p_dstart IN DATE,
                   p_eot IN DATE,
                   p_dend IN DATE,
                   p_abs_from IN DATE,
                   p_abs_to IN DATE) is
l_exists VARCHAR2(1);

cursor c5 is
select 'x'
from per_absence_attendance_types
where absence_attendance_type_id = p_abat_type
and   date_effective <= p_dstart
and   (nvl(date_end,p_eot) >= p_dend
or    p_dend is null);
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.chk_type',1);
--
open c5;
--
  fetch c5 into l_exists;
  IF c5%notfound THEN
  hr_utility.set_message(801, 'HR_6847_ABS_DET_RANGE_CHECK');
  hr_utility.set_message_token('ABS_DATE_FROM', to_char(p_abs_from,'DD-MON-YYYY'));
  hr_utility.set_message_token('ABS_DATE_TO', to_char(p_abs_to,'DD-MON-YYYY'));
  close c5;
  hr_utility.raise_error;
  END IF;
--
close c5;
--
end chk_type;


procedure chk_proj(p_abat_type IN NUMBER,
                   p_proj_start IN DATE,
                   p_eot IN DATE,
                   p_proj_end IN DATE) is
l_exists VARCHAR2(1);

cursor c6 is
select 'x'
from per_absence_attendance_types
where absence_attendance_type_id = p_abat_type
and   date_effective <= p_proj_start
and   (nvl(date_end,p_eot) >= p_proj_end
or    p_proj_end is null);
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.chk_proj',1);
--
open c6;
--
  fetch c6 into l_exists;
  IF c6%notfound THEN
  hr_utility.set_message(801, 'HR_6457_ABS_DET_DATES');
  close c6;
  hr_utility.raise_error;
  END IF;
--
close c6;
--
end chk_proj;



function chkab1(p_abat_id IN NUMBER,
                p_per_id IN NUMBER,
                p_abat_type In NUMBER,
                p_dstart IN DATE)
  RETURN BOOLEAN is
l_exists number;
l_ret_val BOOLEAN;

cursor c7 is
select 1
from per_absence_attendances t,
     per_absence_attendance_types a,
     per_absence_attendance_types b
where (p_abat_id is null
      or (p_abat_id is not null and p_abat_id <> t.absence_attendance_id))
and   t.person_id = p_per_id
and   p_abat_type = a.absence_attendance_type_id
and   t.absence_attendance_type_id = b.absence_attendance_type_id
and   a.absence_category = 'S'
and   b.absence_category = 'S'
and   t.date_end = p_dstart -1;
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.chkab1',1);
--
open c7;
fetch c7 into l_exists;
--
IF c7%found THEN
  l_ret_val := true;
ELSE l_ret_val := false;
END IF;
--
close c7;
--
RETURN (l_ret_val);
--
end chkab1;



procedure chkab2(p_abat_id IN NUMBER,
                 p_per_id IN NUMBER,
                 p_abat_type IN NUMBER,
                 p_dstart IN DATE,
                 p_dend IN DATE,
                 p_eot IN DATE) is
   l_exists VARCHAR2(1);
   l_exists2 VARCHAR2(1);

cursor c8 is
select 'x'
from per_absence_attendances t,
     per_absence_attendance_types a,
     per_absence_attendance_types b
where (p_abat_id is null
      or (p_abat_id is not null and p_abat_id <> t.absence_attendance_id))
and   t.person_id = p_per_id
and   p_abat_type = a.absence_attendance_type_id
and   t.absence_attendance_type_id = b.absence_attendance_type_id
and   a.absence_category = 'S'
and   b.absence_category = 'S'
and   p_dend is null
and   t.date_end is null;
--
cursor c9 is
select 'x'
from per_absence_attendances t,
     per_absence_attendance_types a,
     per_absence_attendance_types b
where (p_abat_id is null
      or (p_abat_id is not null and p_abat_id <> t.absence_attendance_id))
and   t.person_id = p_per_id
and   t.absence_attendance_type_id = a.absence_attendance_type_id
and   a.absence_category = 'S'
and   p_abat_type = b.absence_attendance_type_id
and   b.absence_category = 'S'
and   ((p_dstart between t.date_start and nvl(t.date_end,p_eot))
or    (t.date_start between p_dstart and nvl(p_dend,p_eot)));
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.chkab2',1);
--
open c8;
--
  fetch c8 into l_exists;
  IF c8%found THEN
  hr_utility.set_message(801, 'SSP_35217_DEF_ONLY_ONE_ABS');
  close c8;
  hr_utility.raise_error;
  END IF;
--
close c8;
--
hr_utility.set_location('per_absence_attendances_pkg.chkab2',2);
--
open c9;
--
  fetch c9 into l_exists2;
  IF c9%found THEN
  hr_utility.set_message(801, 'SSP_35216_DEF_OVERLAP_ABS');
  close c9;
  hr_utility.raise_error;
  END IF;
--
close c9;
--
end chkab2;



function chkab3(p_abat_id IN NUMBER,
                p_per_id IN NUMBER,
                p_abat_type IN NUMBER,
                p_dstart IN DATE,
                p_dend In DATE,
                p_eot IN DATE)
   RETURN BOOLEAN is
l_exists number;
l_ret_val BOOLEAN;

cursor c10 is
select 1
from per_absence_attendances t,
     per_absence_attendance_types a,
     per_absence_attendance_types b
where (p_abat_id is null
      or (p_abat_id is not null and p_abat_id <> t.absence_attendance_id))
and   t.person_id = p_per_id
and   t.absence_attendance_type_id = a.absence_attendance_type_id
and   p_abat_type = b.absence_attendance_type_id
and   ((p_dstart between t.date_start and nvl(t.date_end,p_eot))
or    (t.date_start between p_dstart and nvl(p_dend,p_eot)));
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.chkab3',1);
--
open c10;
fetch c10 into l_exists;
--
IF c10%found THEN
  l_ret_val := true;
ELSE l_ret_val := false;
END IF;
--
close c10;
--
RETURN (l_ret_val);
--
end chkab3;



procedure b_elmnt_entry_dets(p_per_id IN NUMBER,
                             p_sdstart IN DATE,
                             p_abat_id IN NUMBER,
                             p_e_entry_id IN OUT NOCOPY NUMBER,
                             p_e_link_id IN OUT NOCOPY NUMBER,
                             p_cpay_id IN OUT NOCOPY NUMBER,
                             p_period_sdate IN OUT NOCOPY DATE,
                             p_period_edate IN OUT NOCOPY DATE) is

cursor c11 is
select e.element_entry_id,
       e.element_link_id,
       a.payroll_id,
       t.start_date,
       t.end_date
from   per_time_periods t,
       pay_element_entries_f e,
       per_assignments_f a
where  a.person_id = p_per_id
and    a.primary_flag = 'Y'
and    p_sdstart between a.effective_start_date and a.effective_end_date
and    e.assignment_id = a.assignment_id
and    e.creator_type = 'A'
and    e.creator_id = p_abat_id
and    p_sdstart between e.effective_start_date and e.effective_end_date
and    t.payroll_id = a.payroll_id
and    p_sdstart between t.start_date and t.end_date;
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.b_elmnt_entry_dets',1);
--
open c11;
--
  fetch c11 into p_e_entry_id,
                 p_e_link_id,
                 p_cpay_id,
                 p_period_sdate,
                 p_period_edate;
--
close c11;
--
end b_elmnt_entry_dets;


procedure b_get_category(p_mean IN OUT NOCOPY VARCHAR2,
                         p_abcat IN VARCHAR2) is

cursor c12 is
select meaning
from   hr_lookups
where  lookup_type = 'ABSENCE_CATEGORY'
and    lookup_code = p_abcat;
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.b_get_category',1);
--
open c12;
--
  fetch c12 into p_mean;
--
close c12;
--
end b_get_category;


procedure get_defaults(p_tend IN VARCHAR2,
                       p_tstart IN VARCHAR2,
                       p_dend IN DATE,
                       p_dstart IN DATE,
                       p_hrs_def IN OUT NOCOPY NUMBER,
                       p_dys_hrs IN OUT NOCOPY NUMBER,
                       p_dys_def IN OUT NOCOPY NUMBER) is

l_hrs_def number;
l_dys_def number;
l_dys_hrs number;

cursor c14 is
select (((substr(p_tend,1,2) * 60) + substr(p_tend,4,2)) -
        ((substr(p_tstart,1,2) * 60) + substr(p_tstart,4,2))) / 60,
       (p_dend - p_dstart + 1) * 24,
       (p_dend - p_dstart) + 1
from   sys.dual;
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.get_defaults',1);
--
open c14;
--
  fetch c14 into l_hrs_def,
                 l_dys_hrs,
                 l_dys_def;
--
close c14;

p_hrs_def := l_hrs_def * l_dys_def;
-- Start of fix 3156665
/* If the normal working hours is not defined at Assignment or
   Organization level, then system will take the default start time as
   00:00 and end time as 23:59. If we calculate the total hours with
   this duration then we will be getting as 23.98333'. For a day the
   it must be 24 hours as default. We cannot change the default
   end time as 24:00, because this will not work with the standard
   hours format like HH24:MI. Hence overriding the calculated hours
   with 24 hours. */
--
if p_tstart = '00:00' and p_tend = '23:59' then
   p_hrs_def := l_dys_hrs;
end if;
-- End of 3156665
p_dys_hrs := l_dys_hrs;
p_dys_def := l_dys_def;

--
end get_defaults;


procedure get_ele_det1(p_bgroup_id IN NUMBER,
                       p_eltype IN NUMBER,
                       p_per_id IN NUMBER,
                       p_dstart IN DATE,
                       p_sess IN DATE,
                       p_ass_id IN OUT NOCOPY NUMBER,
                       p_ele_link IN OUT NOCOPY NUMBER,
                       p_pay_id IN OUT NOCOPY NUMBER,
                       p_test IN OUT NOCOPY VARCHAR2) is

cursor c15 is
select asg.assignment_id,
       l.element_link_id,
       asg.payroll_id,
       'X'
from   per_assignments_f asg,
       pay_element_types_f t,
       pay_element_links_f l
where  l.business_group_id + 0 = p_bgroup_id
and    t.element_type_id = p_eltype
and    asg.person_id = p_per_id
and    asg.primary_flag = 'Y'
and    p_dstart between asg.effective_start_date and asg.effective_end_date
and    t.element_type_id = l.element_type_id
and    ((l.payroll_id is not null
and      l.payroll_id = asg.payroll_id)
or      (l.link_to_all_payrolls_flag = 'Y'
and      asg.payroll_id is not null)
or       (l.payroll_id is null
and       l.link_to_all_payrolls_flag = 'N'))
and    (l.organization_id = asg.organization_id
or      l.organization_id is null)
and    (l.position_id = asg.position_id
or      l.position_id is null)
and    (l.grade_id = asg.grade_id
or      l.grade_id is null)
and    (l.location_id = asg.location_id
or      l.location_id is null)
and    (l.job_id = asg.job_id
or      l.job_id is null)
and    (l.employment_category = asg.employment_category
or      l.employment_category is null)
and    p_dstart between l.effective_start_date and l.effective_end_date
and    p_dstart between t.effective_start_date and t.effective_end_date
and    (l.people_group_id is null
or     exists
       (select 1
        from pay_assignment_link_usages_f lu1
        where lu1.assignment_id = asg.assignment_id
        and   lu1.element_link_id = l.element_link_id
        and   p_sess between lu1.effective_start_date and lu1.effective_end_date));
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.get_ele_det1',1);
--
open c15;
--
  fetch c15 into p_ass_id,
                 p_ele_link,
                 p_pay_id,
                 p_test;
--
close c15;
--
end get_ele_det1;


procedure get_ele_det2(p_eletype IN NUMBER,
                        p_abat_type IN NUMBER,
                        p_dstart IN DATE,
                        p_dele_name IN OUT NOCOPY VARCHAR2) is

cursor c16 is
select pettl.element_name
from   per_absence_attendance_types paa,
       pay_element_types_f pet,
       pay_element_types_f_tl pettl
where  pet.element_type_id = p_eletype
and    paa.absence_attendance_type_id = p_abat_type
and    pet.element_type_id = pettl.element_type_id
and    nvl(p_dstart,paa.date_effective)
       between pet.effective_start_date and pet.effective_end_date
and    pettl.language = userenv('LANG');
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.get_ele_det2',1);
--
open c16;
--
  fetch c16 into p_dele_name;
--
close c16;
--
end get_ele_det2;



procedure get_period_dates(p_cpay_id IN NUMBER,
                           p_dstart In DATE,
                           p_prd_start IN OUT NOCOPY DATE,
                           p_prd_end IN OUT NOCOPY DATE,
                           p_test IN OUT NOCOPY VARCHAR2) is

cursor c18 is
select start_date,
       end_date,
       'X'
from   per_time_periods
where  payroll_id = p_cpay_id
and    p_dstart between start_date and end_date;
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.get_period_dates',1);
--
open c18;
--
fetch c18 into p_prd_start,
               p_prd_end,
               p_test;
--
close c18;
--
end get_period_dates;


procedure get_run_tot(p_abat_type IN NUMBER,
                      p_per_id IN NUMBER,
                      p_db_itm IN OUT NOCOPY VARCHAR2,
                      p_ass_id IN OUT NOCOPY NUMBER) is

cursor c19 is
select di.user_name
from   ff_database_items di,
       ff_user_entities ue
where  di.user_entity_id = ue.user_entity_id
and    ue.creator_type = 'A'
and    ue.creator_id = p_abat_type;
--
cursor c20 is
select assignment_id
from   per_assignments
where  person_id = p_per_id
and    primary_flag = 'Y';
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.get_run_tot',1);
--
open c19;
--
  fetch c19 into p_db_itm;
--
close c19;
--
hr_utility.set_location('per_absence_attendances_pkg.get_run_tot',2);
--
open c20;
--
  fetch c20 into p_ass_id;
--
close c20;
--
end get_run_tot;
--
-- this function returns the total number of absence taken
-- by the employee from the start of the year.
--
--
function get_annual_balance(p_session_date IN DATE,
                        p_abs_type_id  IN NUMBER,
                        p_ass_id IN  NUMBER)return NUMBER is

cursor c19 is
-- Bug 563202 - drive from abs and go via link input value
select nvl(sum(fnd_number.canonical_to_number(
                    nvl(pev.screen_entry_value,'0.0'))),0)
from pay_element_entry_values_f   pev,
     pay_element_entries_f        pee,
     pay_link_input_values_f      lnk,
     per_absence_attendance_types abs
where abs.absence_attendance_type_id    = p_abs_type_id
and   lnk.input_value_id              = abs.input_value_id
and   pev.input_value_id + 0                  = abs.input_value_id
and   pee.element_link_id             = lnk.element_link_id
and   pev.element_entry_id            = pee.element_entry_id
and   pee.assignment_id               = p_ass_id
and   to_char(pev.effective_start_date, 'YYYY') =
        to_char(p_session_date, 'YYYY')
and   to_char(pev.effective_end_date,'YYYY')   =
        to_char(p_session_date, 'YYYY')
and   pev.effective_start_date = pee.effective_start_date
and   pev.effective_end_date   = pee.effective_end_date
and   pee.effective_start_date between
              lnk.effective_start_date and lnk.effective_end_date;
--
l_balance  NUMBER := 0;
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.get_annual_bal',1);
--
open c19;
--
fetch c19 into l_balance;
--
close c19;
--
return l_balance;
--
end get_annual_balance;
--
-- The following function checks first of all that the absence is of type
-- accrual. If the absence is Accural then the net entitlement is checked
-- to see whether the absence duration would exceeds the entitlement.
--
function is_emp_entitled (p_abs_att_type_id              NUMBER,
                              p_ass_id                   NUMBER,
                              p_calculation_date         DATE,
                              p_days_requested           NUMBER,
                              p_hours_requested          NUMBER)
                                                         return boolean is

-- Bug 673835. Editted cursor so that it can pick up an accrual plan,
-- if there is one for the given assignment_id. Also added check so that
-- plan is only selected if the employee is enrolled in it as at the
-- calculation date.

CURSOR csr_get_accrual_plan is
select pap.accrual_plan_id,
       pap.accrual_category,
       pap.accrual_units_of_measure,
       asg.payroll_id,
       asg.business_group_id
from   pay_element_entry_values_f       pev,
       pay_element_entries_f            pee,
       pay_input_values_f               piv,
       pay_accrual_plans                pap,
       per_absence_attendance_types     abst,
       per_all_assignments_f            asg
where  pee.assignment_id                        = p_ass_id
and    abst.absence_attendance_type_id          = p_abs_att_type_id
and    pap.pto_input_value_id                   = abst.input_value_id
and    pee.element_entry_id                     = pev.element_entry_id
and    piv.input_value_id                       = pev.input_value_id
and    pap.accrual_plan_element_type_id         = piv.element_type_id
and    piv.element_type_id                      = pee.element_type_id
and    asg.assignment_id                        = pee.assignment_id
and    p_calculation_date between pee.effective_start_date
                          and     pee.effective_end_date;

l_plan_id       pay_accrual_plans.accrual_plan_id%TYPE;
l_plan_category pay_accrual_plans.accrual_category%TYPE;
l_units_of_measure pay_accrual_plans.accrual_units_of_measure%TYPE;
l_payroll_id number;
l_business_group_id number;
l_entitlement   NUMBER;
l_start_date date;
l_end_date date;
l_accrual_end_date date;
l_accrual number;

--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.check_entitlement',1);
--
if p_days_requested is null and p_days_requested is null then
--
  return true;
--
end if;

open csr_get_accrual_plan;
fetch csr_get_accrual_plan into l_plan_id,
                                l_plan_category,
                                l_units_of_measure,
                                l_payroll_id,
                                l_business_group_id;

if csr_get_accrual_plan%FOUND and l_payroll_id is not null then
--
  close csr_get_accrual_plan;
  per_accrual_calc_functions.get_net_accrual(
                   P_Assignment_ID     => p_ass_id
                  ,P_Plan_ID           => l_plan_id
                  ,P_Payroll_ID        => l_payroll_id
                  ,P_Business_Group_ID => l_business_group_id
                  ,P_Calculation_Date  => p_calculation_date
                  ,P_Start_Date        => l_start_date
                  ,P_End_Date          => l_end_date
                  ,P_Accrual_End_Date  => l_accrual_end_date
                  ,P_Accrual           => l_accrual
                  ,P_Net_Entitlement   => l_entitlement
                  );
hr_utility.trace('ent= '||to_char(l_entitlement));

  if (l_units_of_measure = 'D' and l_entitlement < p_days_requested) THEN
    return FALSE;
  elsif (l_units_of_measure = 'H' and l_entitlement < p_hours_requested) THEN
    return FALSE;
  else
    return true;
  end if;
else
  close csr_get_accrual_plan;
  return TRUE;
end if;
--
end is_emp_entitled;


procedure init_form(p_form_type IN OUT NOCOPY NUMBER,
                    p_per_id IN NUMBER,
                    p_sess IN DATE,
                    p_dstart IN OUT NOCOPY DATE,
                    p_dend IN OUT NOCOPY DATE) is

-- Bug fix 3387265.
-- cursor c21 modified to improve performance.

cursor c21 is
select formula_type_id
from ff_formula_types
where formula_type_name = 'QuickPaint';
--
cursor c21b is
select greatest(date_start),
       actual_termination_date
from   per_periods_of_service
where  person_id = p_per_id
and    date_start <= p_sess;
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.init_form',1);
--
open c21;
--
  fetch c21 into p_form_type;
--
close c21;
--
hr_utility.set_location('per_absence_attendances_pkg.init_form',2);
--
open c21b;
--
  fetch c21b into p_dstart,
                  p_dend;
--
close c21b;
--
end init_form;


procedure ins_ok(p_per_id IN NUMBER,
                 p_test IN OUT NOCOPY VARCHAR2) is

cursor c22 is
select 'Y'
from per_assignments
where primary_flag = 'Y'
and person_id = p_per_id
and payroll_id is not null;
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.ins_ok',1);
--
open c22;
--
  fetch c22 into p_test;
--
close c22;
--
end ins_ok;


procedure get_occur(p_bgroup_id IN NUMBER,
                    p_abat_type IN NUMBER,
                    p_per_id IN NUMBER,
                    p_occur IN OUT NOCOPY NUMBER) is

cursor c23 is
select nvl(max(occurrence),0) + 1
from per_absence_attendances
where business_group_id + 0 = p_bgroup_id
and   absence_attendance_type_id = p_abat_type
and   person_id = p_per_id;
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.get_occur',1);
--
open c23;
--
  fetch c23 into p_occur;
--
close c23;
--
end get_occur;


function chk_serv_period(p_per_id in number,
                         p_curr_date_end in date,
                         p_proj_start in date)
RETURN BOOLEAN IS
l_ret_val BOOLEAN;
--
cursor chk_periods is
select 1
from per_periods_of_service pos
where pos.person_id = p_per_id
and pos.date_start > p_curr_date_end
and p_proj_start between
  pos.date_start AND nvl(pos.actual_termination_date,hr_general.end_of_time);
--
begin
--
hr_utility.set_location('per_absence_attendances_pkg.chk_serv_period',1);
--
open chk_periods;
--
  l_ret_val := chk_periods%found;
--
close chk_periods;
--
RETURN l_ret_val;
--
end chk_serv_period;
--
-- ---------------------------------------------------------------------------
-- ---------------------------< get_mat_details >-----------------------------
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Procedure that is used by SSP/SMP users of Absence form.
--   Gets the due and MPP dates.  Called from Form PERWSEAD (absence).
--
--   NOTE: rowid parameter defined as varchar2 parameter because PL/SQL 1.1
--         used in forms and rowid isn't a datatype.
--
procedure get_mat_details
(
p_maternity_id            in number,
p_due_date                in out nocopy date,
p_mpp_start_date          in out nocopy date,
p_earliest_abs_start_date in out nocopy date,
p_earliest_abs_rowid      in out nocopy varchar2,
p_nos_absences            in out nocopy number
) is
--
  cursor c1 is
   select h.due_date, h.mpp_start_date
   from   ssp_maternities h
   where h.maternity_id = p_maternity_id;
--
BEGIN
  open c1;
  fetch c1 into p_due_date, p_mpp_start_date;
  close c1;
  --
  get_earliest_abs_start_date(p_maternity_id,
                              p_earliest_abs_start_date,
                              p_earliest_abs_rowid,
                              p_nos_absences);
END get_mat_details;
--
-- ---------------------------------------------------------------------------
-- ---------------------------< get_due_date >--------------------------------
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Procedure that is used by SSP/SMP users of Absence form
--     Get the due date.  Used from Form PERWSEAD (absence).
--
Function get_due_date (p_maternity_id in number) return date is
  cursor c1 is
   select h.due_date
   from   ssp_maternities h
   where h.maternity_id = p_maternity_id;
  c1_rec c1%ROWTYPE;
BEGIN
  open c1;
  hr_utility.set_location('per_absence_attendances_pkg.get_due_date',1);
  fetch c1 into c1_rec;
  close c1;
  return(c1_rec.due_date);
END get_due_date;
--
-- ---------------------------------------------------------------------------
-- ---------------------------< get_due_date_2 >------------------------------
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Procedure that is used by SSP/SMP users of Absence form
--    Get the due_date if there is ONLY one due date and also check that
--    the person specified has indeed a related maternity record.
--
Function get_due_date_2 (p_person_id in number,
                         p_leave_type in varchar2,
                         p_smp_due_date in out nocopy date)
                         return BOOLEAN is

counter number;

cursor c1 is
  select h.due_date
  from ssp_maternities h
  where h.person_id = p_person_id
  and   nvl(h.leave_type,'MA') = p_leave_type;


BEGIN
  hr_utility.set_location('per_absence_attendances_pkg.get_due_date_2',1);
  counter:= 0;
  for c1_rec in c1 LOOP
      p_smp_due_date := c1_rec.due_date;
      counter := counter + 1;
  end LOOP;

  if counter = 0 then
  --  there was no maternity record
    fnd_message.set_name('SSP','SSP_35032_NO_RELATED_MATERNITY');
    fnd_message.raise_error;
    return(FALSE);
  elsif counter > 1 then
  -- There are multiple maternity records
     p_smp_due_date := null;
  end if;

  -- So left with only one row returned and smp_due_date was set
     return(TRUE);
END get_due_date_2;
--
-- ---------------------------------------------------------------------------
-- -----------------------< check_val_abs_start >-----------------------------
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check that the maternity absence start is not before the Qualifying Week
--
Procedure check_val_abs_start (p_date_start in date,
                               p_maternity_id in number) is
Cursor csr_maternity is
        select  ssp_smp_pkg.qualifying_week (mat.due_date) QW,
                nvl(mat.mpp_start_date,hr_general.end_of_time) MPP,
                nvl(mat.leave_type,'MA') leave_type
        from    ssp_maternities MAT
        where   mat.maternity_id = p_maternity_id;
        --
maternity csr_maternity%ROWTYPE;
--
BEGIN
  hr_utility.set_location('per_absence_attendances_pkg.check_val_abs_start',1);
  --
  -- This functionality only applies to Oracle SSP users
  if not ssp_ssp_pkg.ssp_is_installed then
    return;
  end if;
  --
  if p_maternity_id is not null then
    --
    open csr_maternity;
    fetch csr_maternity into maternity;
    close csr_maternity;
    --
      if p_date_start < least(maternity.QW, maternity.MPP)
      and maternity.leave_type = 'MA'
      then
        fnd_message.set_name('SSP', 'SSP_35031_MAT_ABS_DATE');
        fnd_message.raise_error;
      end if;

  end if;
  --
END check_val_abs_start;

--
-- ---------------------------------------------------------------------------
-- -----------------------< check_related_maternity >-------------------------
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Procedure that is used by SSP/SMP users of Absence form
--    Ensure that there is a related Maternity record for this Person
--
Procedure check_related_maternity (p_person_id in number) is
cursor c1 is
  select h.rowid
  from  ssp_maternities h
  where h.person_id = p_person_id;
c1_rec c1%ROWTYPE;
BEGIN
   hr_utility.set_location('per_absence_attendances_pkg.chk_related_maernity',1);
   open c1;
   fetch c1 into c1_rec;
   if c1%NOTFOUND then
     fnd_message.set_name('SSP','SSP_36073_PREG_RELATED_ILLNESS');
     fnd_message.raise_error;
   end if;
   close c1;
END check_related_maternity;


--
-- ---------------------------------------------------------------------------
-- -----------------------< check_evd_before_del >----------------------------
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Procedure that is used by SSP/SMP users of Absence form
--    Ensure that there is no attached sick note for this Sickness absence
--    before deletion.  Valid for SSP/SMP users only
--
Procedure check_evd_before_del(p_absence_attendance_id in number,
                               p_medical_type in varchar2) is
cursor c1 is
  select h.rowid
  from   ssp_medicals h
  where h.absence_attendance_id = p_absence_attendance_id
    and h.medical_type = p_medical_type;
 c1_rec c1%ROWTYPE;
BEGIN
  hr_utility.set_location('per_absence_attendances_pkg.chk_evd_before_del',1);
  open c1;
  fetch c1 into c1_rec;
  if c1%FOUND then
     fnd_message.set_name('SSP','SSP_35033_ATTACHED_SICK_NOTE');
     fnd_message.raise_error;
  end if;
  close c1;
END check_evd_before_del;

-- ---------------------------------------------------------------------------
-- -----------------------< late_abs_notification>----------------------------
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Procedure that is used by SSP/SMP users of Absence form
--    Validation used for Absences of type SSP to see if notification
--    was late.  If it is, then reason_for_notification_delay becomes
--    mandatory (accept_late_notification will be also).
--
Function late_abs_notification (p_date_notification in date,
                                p_date_start in date,
                                p_effective_date in date,
                                p_element_name in varchar2) return boolean is

l_element_details ssp_SMP_pkg.csr_SMP_element_details%rowtype;

BEGIN
  hr_utility.set_location
    ('per_absence_attendances_pkg.late_abs_notification',1);
  open ssp_SMP_pkg.csr_SMP_element_details(p_effective_date,
                                          p_element_name);
  fetch ssp_SMP_pkg.csr_SMP_element_details into l_element_details;
  close ssp_SMP_pkg.csr_SMP_element_details;
  if p_date_notification >
              (p_date_start -
              to_number(l_element_details.mpp_notice_requirement)) then
              -- Added explicit number conversion above. Bug 3111653

    return(TRUE);
  else
    return(FALSE);
  end if;
END late_abs_notification;

end PER_ABSENCE_ATTENDANCES_PKG;

/
