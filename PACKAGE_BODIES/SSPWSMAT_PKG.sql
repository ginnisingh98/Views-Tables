--------------------------------------------------------
--  DDL for Package Body SSPWSMAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSPWSMAT_PKG" as
/* $Header: sspwsmat.pkb 120.1 2005/06/15 04:09:34 tukumar noship $ */

  procedure calculate_pab_form_fields
  (
   p_due_date            in date,
   p_ewc                 in out NOCOPY date,
   p_qw                  in out NOCOPY date,
   p_cont_emp_start_date in out NOCOPY date
) is

BEGIN
  p_ewc := ssp_pab_pkg.expected_week_of_confinement (p_due_date);
  p_qw := ssp_pab_pkg.qualifying_week (p_due_date);
  p_cont_emp_start_date := ssp_pab_pkg.continuous_employment_date(p_due_date);
END calculate_pab_form_fields;

  procedure calculate_pad_form_fields
  (
   p_matching_date       in date,
   p_qw                  in out NOCOPY date,
   p_cont_emp_start_date in out NOCOPY date
) is

BEGIN
  if p_matching_date is not null then
      p_qw := ssp_pad_pkg.MATCHING_WEEK_OF_ADOPTION (p_matching_date);
      p_cont_emp_start_date := ssp_pad_pkg.continuous_employment_date(p_matching_date);
  end if;
END calculate_pad_form_fields;

  procedure calculate_sap_form_fields
 (
  p_due_date            in date,
  p_matching_date       in date,
  p_earliest_mpp_start  in out NOCOPY date,
  p_qw                  in out NOCOPY date,
  p_cont_emp_start_date in out NOCOPY date
 ) is

BEGIN
  if p_matching_date is not null then
      p_qw := ssp_sap_pkg.MATCHING_WEEK_OF_ADOPTION (p_matching_date);
      p_cont_emp_start_date :=ssp_sap_pkg.continuous_employment_date (p_matching_date);
  end if;
  p_earliest_mpp_start := ssp_sap_pkg.EARLIEST_APP_START_DATE (p_due_date);
END calculate_sap_form_fields;

procedure calculate_smp_form_fields
(
p_due_date            in date,
p_ewc                 in out NOCOPY date,
p_earliest_mpp_start  in out NOCOPY date,
p_qw                  in out NOCOPY date,
p_cont_emp_start_date in out NOCOPY date
) is

BEGIN
  p_qw := ssp_smp_pkg.qualifying_week (p_due_date);
  p_ewc := ssp_smp_pkg.expected_week_of_confinement (p_due_date);
  p_earliest_mpp_start := ssp_smp_pkg.earliest_mpp_start_date (p_due_date);
  p_cont_emp_start_date := ssp_smp_pkg.continuous_employment_date (p_due_date);
END calculate_smp_form_fields;


procedure get_latest_absence_date
(
 p_maternity_id           in     number,
 p_absence_attendance_id  in out NOCOPY number,
 p_abs_end_date           in out NOCOPY date,
 p_rec_found              in out NOCOPY boolean
)
 is
   cursor c1 is
     select absence_attendance_id,
            max(p.date_end) end_date
     from per_absence_attendances p
     where p.maternity_id = p_maternity_id
     group by absence_attendance_id;
   c1_rec c1%ROWTYPE;
BEGIN
  open c1;
  fetch c1 into c1_rec;
  if c1%NOTFOUND then
    p_rec_found := FALSE;
  else
    p_rec_found := TRUE;
    p_abs_end_date := c1_rec.end_date;
    p_absence_attendance_id := c1_rec.absence_attendance_id;
  end if;
  close c1;
END get_latest_absence_date;


procedure upd_abse_end_date (p_maternity_id in number,
                             p_absence_attendance_id in number,
                             p_absence_end_date in date) is
cursor c1 is
     select rowid,
            absence_attendance_id,
            business_group_id,
            absence_attendance_type_id,
            Abs_Attendance_Reason_Id,
            Person_Id,
            Authorising_Person_Id,
            Replacement_Person_Id,
            Period_Of_Incapacity_Id,
            Absence_Days,
            Absence_Hours,
            Comments,
            Date_End,
            Date_Notification,
            Date_Projected_End,
            Date_Projected_Start,
            Date_Start,
            Occurrence,
            Ssp1_Issued,
            Time_End,
            Time_Projected_End,
            Time_Projected_Start,
            Time_Start,
            Attribute_Category,
            Attribute1,
            Attribute2,
            Attribute3,
            Attribute4,
            Attribute5,
            Attribute6,
            Attribute7,
            Attribute8,
            Attribute9,
            Attribute10,
            Attribute11,
            Attribute12,
            Attribute13,
            Attribute14,
            Attribute15,
            Attribute16,
            Attribute17,
            Attribute18,
            Attribute19,
            Attribute20,
            Linked_Absence_Id,
            Sickness_Start_Date,
            Sickness_End_date,
            Accept_Late_Notification_Flag,
            reason_for_notification_delay,
            Pregnancy_Related_Illness,
            Maternity_Id,
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
            abs_information30,
	    object_version_number --Bug fix 3633461
       from per_absence_attendances
      where maternity_id = p_maternity_id
        and absence_attendance_id = p_absence_attendance_id;

    /* Added cursors for bug fix 3633461*/
     CURSOR csr_get_date is
     SELECT effective_date
     FROM   fnd_sessions
     WHERE  session_id=userenv('sessionid');

     CURSOR csr_get_hours_or_days(p_absence_attendance_type_id in NUMBER) is
     SELECT hours_or_days
     FROM   per_absence_attendance_types
     WHERE  absence_attendance_type_id = p_absence_attendance_type_id;

c1_rec c1%ROWTYPE;

l_absence_days   NUMBER;
l_absence_hours  NUMBER;
l_absence_days_calc   NUMBER;
l_absence_hours_calc  NUMBER;
l_use_formula    BOOLEAN;
l_hours_or_days  VARCHAR2(1);
l_effective_date DATE;

 BEGIN


  --Bug fix 3633461 Start
  OPEN  csr_get_date;
  FETCH csr_get_date into l_effective_date;
  CLOSE csr_get_date;

  open  c1;
  fetch c1 into c1_rec;

  OPEN  csr_get_hours_or_days(c1_rec.Absence_Attendance_Type_Id);
  FETCH csr_get_hours_or_days into l_hours_or_days;
  CLOSE csr_get_hours_or_days;

  IF c1_rec.Date_Start is not null and p_absence_end_date is not null
  THEN
	  per_abs_bus.calculate_absence_duration
	 (p_absence_attendance_id      =>c1_rec.Absence_Attendance_Id
	 ,p_absence_attendance_type_id =>c1_rec.Absence_Attendance_Type_Id
	 ,p_business_group_id          =>c1_rec.Business_Group_Id
	 ,p_object_version_number      =>c1_rec.object_version_number
	 ,p_effective_date             =>l_effective_date
	 ,p_person_id                  =>c1_rec.Person_Id
	 ,p_date_start                 =>c1_rec.Date_Start
	 ,p_date_end                   =>p_absence_end_date
	 ,p_time_start                 =>c1_rec.Time_Start
	 ,p_time_end                   =>c1_rec.Time_End
	 ,p_absence_days               =>l_absence_days
	 ,p_absence_hours              =>l_absence_hours
	 ,p_use_formula                =>l_use_formula);
  END IF;


  IF l_use_formula = TRUE and l_hours_or_days = 'H' and  c1_rec.Time_Start is not null and c1_rec.Time_End is not null THEN
	l_absence_hours_calc := l_absence_hours;
  ELSIF l_use_formula = TRUE  THEN
        l_absence_days_calc := l_absence_days;
  END IF;

  --Bug fix 3633461 End

  PER_ABSENCE_ATTENDANCES_PKG.Update_Row(
       X_Rowid                       => c1_rec.RowId,
       X_Absence_Attendance_Id       => c1_rec.Absence_Attendance_Id,
       X_Business_Group_Id           => c1_rec.Business_Group_Id,
       X_Absence_Attendance_Type_Id  => c1_rec.Absence_Attendance_Type_Id,
       X_Abs_Attendance_Reason_Id    => c1_rec.Abs_Attendance_Reason_Id,
       X_Person_Id                   => c1_rec.Person_Id,
       X_Authorising_Person_Id       => c1_rec.Authorising_Person_Id,
       X_Replacement_Person_Id       => c1_rec.Replacement_Person_Id,
       X_Period_Of_Incapacity_Id     => c1_rec.Period_Of_Incapacity_Id,
       X_Absence_Days                => nvl(l_absence_days_calc,c1_rec.Absence_Days),   --Bug fix 3633461
       X_Absence_Hours               => nvl(l_absence_hours_calc,c1_rec.Absence_Hours), --Bug fix 3633461
       X_Comments                    => c1_rec.Comments,
       X_Date_End                    => p_absence_end_date,
       X_Date_Notification           => c1_rec.Date_Notification,
       X_Date_Projected_End          => c1_rec.Date_Projected_End,
       X_Date_Projected_Start        => c1_rec.Date_Projected_Start,
       X_Date_Start                  => c1_rec.Date_Start,
       X_Occurrence                  => c1_rec.Occurrence,
       X_Ssp1_Issued                 => c1_rec.Ssp1_Issued,
       X_Time_End                    => c1_rec.Time_End,
       X_Time_Projected_End          => c1_rec.Time_Projected_End,
       X_Time_Projected_Start        => c1_rec.Time_Projected_Start,
       X_Time_Start                  => c1_rec.Time_Start,
       X_Attribute_Category          => c1_rec.Attribute_Category,
       X_Attribute1                  => c1_rec.Attribute1,
       X_Attribute2                  => c1_rec.Attribute2,
       X_Attribute3                  => c1_rec.Attribute3,
       X_Attribute4                  => c1_rec.Attribute4,
       X_Attribute5                  => c1_rec.Attribute5,
       X_Attribute6                  => c1_rec.Attribute6,
       X_Attribute7                  => c1_rec.Attribute7,
       X_Attribute8                  => c1_rec.Attribute8,
       X_Attribute9                  => c1_rec.Attribute9,
       X_Attribute10                 => c1_rec.Attribute10,
       X_Attribute11                 => c1_rec.Attribute11,
       X_Attribute12                 => c1_rec.Attribute12,
       X_Attribute13                 => c1_rec.Attribute13,
       X_Attribute14                 => c1_rec.Attribute14,
       X_Attribute15                 => c1_rec.Attribute15,
       X_Attribute16                 => c1_rec.Attribute16,
       X_Attribute17                 => c1_rec.Attribute17,
       X_Attribute18                 => c1_rec.Attribute18,
       X_Attribute19                 => c1_rec.Attribute19,
       X_Attribute20                 => c1_rec.Attribute20,
       X_Linked_Absence_Id           => c1_rec.Linked_Absence_Id,
       X_Sickness_Start_Date         => c1_rec.Sickness_Start_Date,
       X_Sickness_End_Date           => c1_rec.Sickness_End_Date,
       X_Accept_Late_Notif_Flag  => c1_rec.Accept_late_Notification_flag,
       X_REASON_FOR_LATE_NOTIFICATION =>
                                   c1_rec.reason_for_notification_delay,
       X_Pregnancy_Related_Illness  => c1_rec.Pregnancy_Related_Illness,
       X_Maternity_Id                => c1_rec.Maternity_Id,
       X_Abs_Information_Category    => c1_rec.abs_information_category,
       X_Abs_Information1            => c1_rec.abs_information1,
       X_Abs_Information2            => c1_rec.abs_information2,
       X_Abs_Information3            => c1_rec.abs_information3,
       X_Abs_Information4            => c1_rec.abs_information4,
       X_Abs_Information5            => c1_rec.abs_information5,
       X_Abs_Information6            => c1_rec.abs_information6,
       X_Abs_Information7            => c1_rec.abs_information7,
       X_Abs_Information8            => c1_rec.abs_information8,
       X_Abs_Information9            => c1_rec.abs_information9,
       X_Abs_Information10           => c1_rec.abs_information10,
       X_Abs_Information11           => c1_rec.abs_information11,
       X_Abs_Information12           => c1_rec.abs_information12,
       X_Abs_Information13           => c1_rec.abs_information13,
       X_Abs_Information14           => c1_rec.abs_information14,
       X_Abs_Information15           => c1_rec.abs_information15,
       X_Abs_Information16           => c1_rec.abs_information16,
       X_Abs_Information17           => c1_rec.abs_information17,
       X_Abs_Information18           => c1_rec.abs_information18,
       X_Abs_Information19           => c1_rec.abs_information19,
       X_Abs_Information20           => c1_rec.abs_information20,
       X_Abs_Information21           => c1_rec.abs_information21,
       X_Abs_Information22           => c1_rec.abs_information22,
       X_Abs_Information23           => c1_rec.abs_information23,
       X_Abs_Information24           => c1_rec.abs_information24,
       X_Abs_Information25           => c1_rec.abs_information25,
       X_Abs_Information26           => c1_rec.abs_information26,
       X_Abs_Information27           => c1_rec.abs_information27,
       X_Abs_Information28           => c1_rec.abs_information28,
       X_Abs_Information29           => c1_rec.abs_information29,
       X_Abs_Information30           => c1_rec.abs_information30);
    close c1;
  END upd_abse_end_date;

END SSPWSMAT_PKG;

/
