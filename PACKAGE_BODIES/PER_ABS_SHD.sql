--------------------------------------------------------
--  DDL for Package Body PER_ABS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABS_SHD" as
/* $Header: peabsrhi.pkb 120.17.12010000.9 2010/03/23 06:49:45 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_abs_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc    varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PER_ABSENCE_ATTENDANCES_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_ABSENCE_ATTENDANCES_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_ABSENCE_ATTENDANCES_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_ABSENCE_ATTENDANCES_FK4') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_ABSENCE_ATTENDANCES_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'SSP_ABA_MATERNITY_NOT_SICKNESS') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','30');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'SSP_ABA_SICKNESS_ATTRIBUTES') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','35');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'SSP_ABA_SICKNESS_END_DATE') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','40');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'SSP_ABA_SICKNESS_START_DATE') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','45');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'SSP_ABA_SICK_NOTIFICATION_DATE') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','50');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'SSP_ABA_START_AND_END_DATES') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','55');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'SSP_ABA_TIME_END_FORMAT') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','60');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'SSP_ABA_TIME_START_FORMAT') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','65');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_absence_attendance_id                in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       absence_attendance_id
      ,business_group_id
      ,absence_attendance_type_id
      ,abs_attendance_reason_id
      ,person_id
      ,authorising_person_id
      ,replacement_person_id
      ,period_of_incapacity_id
      ,absence_days
      ,absence_hours
      ,comments
      ,date_end
      ,date_notification
      ,date_projected_end
      ,date_projected_start
      ,date_start
      ,occurrence
      ,ssp1_issued
      ,time_end
      ,time_projected_end
      ,time_projected_start
      ,time_start
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,maternity_id
      ,sickness_start_date
      ,sickness_end_date
      ,pregnancy_related_illness
      ,reason_for_notification_delay
      ,accept_late_notification_flag
      ,linked_absence_id
      ,abs_information_category
      ,abs_information1
      ,abs_information2
      ,abs_information3
      ,abs_information4
      ,abs_information5
      ,abs_information6
      ,abs_information7
      ,abs_information8
      ,abs_information9
      ,abs_information10
      ,abs_information11
      ,abs_information12
      ,abs_information13
      ,abs_information14
      ,abs_information15
      ,abs_information16
      ,abs_information17
      ,abs_information18
      ,abs_information19
      ,abs_information20
      ,abs_information21
      ,abs_information22
      ,abs_information23
      ,abs_information24
      ,abs_information25
      ,abs_information26
      ,abs_information27
      ,abs_information28
      ,abs_information29
      ,abs_information30
      ,absence_case_id
      ,batch_id
      ,object_version_number
    from    per_absence_attendances
    where   absence_attendance_id = p_absence_attendance_id;
--
  l_fct_ret boolean;
--
Begin
  --
  If (p_absence_attendance_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_absence_attendance_id
        = per_abs_shd.g_old_rec.absence_attendance_id and
        p_object_version_number
        = per_abs_shd.g_old_rec.object_version_number
       ) Then
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
      --
      Open C_Sel1;
      Fetch C_Sel1 Into per_abs_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> per_abs_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_absence_attendance_id                in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       absence_attendance_id
      ,business_group_id
      ,absence_attendance_type_id
      ,abs_attendance_reason_id
      ,person_id
      ,authorising_person_id
      ,replacement_person_id
      ,period_of_incapacity_id
      ,absence_days
      ,absence_hours
      ,comments
      ,date_end
      ,date_notification
      ,date_projected_end
      ,date_projected_start
      ,date_start
      ,occurrence
      ,ssp1_issued
      ,time_end
      ,time_projected_end
      ,time_projected_start
      ,time_start
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,maternity_id
      ,sickness_start_date
      ,sickness_end_date
      ,pregnancy_related_illness
      ,reason_for_notification_delay
      ,accept_late_notification_flag
      ,linked_absence_id
      ,abs_information_category
      ,abs_information1
      ,abs_information2
      ,abs_information3
      ,abs_information4
      ,abs_information5
      ,abs_information6
      ,abs_information7
      ,abs_information8
      ,abs_information9
      ,abs_information10
      ,abs_information11
      ,abs_information12
      ,abs_information13
      ,abs_information14
      ,abs_information15
      ,abs_information16
      ,abs_information17
      ,abs_information18
      ,abs_information19
      ,abs_information20
      ,abs_information21
      ,abs_information22
      ,abs_information23
      ,abs_information24
      ,abs_information25
      ,abs_information26
      ,abs_information27
      ,abs_information28
      ,abs_information29
      ,abs_information30
      ,absence_case_id
      ,batch_id
      ,object_version_number
    from    per_absence_attendances
    where   absence_attendance_id = p_absence_attendance_id
    for update nowait;
--
  l_proc    varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ABSENCE_ATTENDANCE_ID'
    ,p_argument_value     => p_absence_attendance_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_abs_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> per_abs_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- We need to trap the ORA LOCK exception
  --
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'per_absence_attendances');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_absence_attendance_id          in number
  ,p_business_group_id              in number
  ,p_absence_attendance_type_id     in number
  ,p_abs_attendance_reason_id       in number
  ,p_person_id                      in number
  ,p_authorising_person_id          in number
  ,p_replacement_person_id          in number
  ,p_period_of_incapacity_id        in number
  ,p_absence_days                   in number
  ,p_absence_hours                  in number
  --changes start for bug 5987410
  --,p_comments                       in varchar2
  ,p_comments                       in long
  --changes end for bug 5987410
  ,p_date_end                       in date
  ,p_date_notification              in date
  ,p_date_projected_end             in date
  ,p_date_projected_start           in date
  ,p_date_start                     in date
  ,p_occurrence                     in number
  ,p_ssp1_issued                    in varchar2
  ,p_time_end                       in varchar2
  ,p_time_projected_end             in varchar2
  ,p_time_projected_start           in varchar2
  ,p_time_start                     in varchar2
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_maternity_id                   in number
  ,p_sickness_start_date            in date
  ,p_sickness_end_date              in date
  ,p_pregnancy_related_illness      in varchar2
  ,p_reason_for_notification_dela   in varchar2
  ,p_accept_late_notification_fla   in varchar2
  ,p_linked_absence_id              in number
  ,p_abs_information_category       in varchar2
  ,p_abs_information1               in varchar2
  ,p_abs_information2               in varchar2
  ,p_abs_information3               in varchar2
  ,p_abs_information4               in varchar2
  ,p_abs_information5               in varchar2
  ,p_abs_information6               in varchar2
  ,p_abs_information7               in varchar2
  ,p_abs_information8               in varchar2
  ,p_abs_information9               in varchar2
  ,p_abs_information10              in varchar2
  ,p_abs_information11              in varchar2
  ,p_abs_information12              in varchar2
  ,p_abs_information13              in varchar2
  ,p_abs_information14              in varchar2
  ,p_abs_information15              in varchar2
  ,p_abs_information16              in varchar2
  ,p_abs_information17              in varchar2
  ,p_abs_information18              in varchar2
  ,p_abs_information19              in varchar2
  ,p_abs_information20              in varchar2
  ,p_abs_information21              in varchar2
  ,p_abs_information22              in varchar2
  ,p_abs_information23              in varchar2
  ,p_abs_information24              in varchar2
  ,p_abs_information25              in varchar2
  ,p_abs_information26              in varchar2
  ,p_abs_information27              in varchar2
  ,p_abs_information28              in varchar2
  ,p_abs_information29              in varchar2
  ,p_abs_information30              in varchar2
  ,p_absence_case_id                in number
  ,p_batch_id                       in number
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.absence_attendance_id            := p_absence_attendance_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.absence_attendance_type_id       := p_absence_attendance_type_id;
  l_rec.abs_attendance_reason_id         := p_abs_attendance_reason_id;
  l_rec.person_id                        := p_person_id;
  l_rec.authorising_person_id            := p_authorising_person_id;
  l_rec.replacement_person_id            := p_replacement_person_id;
  l_rec.period_of_incapacity_id          := p_period_of_incapacity_id;
  l_rec.absence_days                     := p_absence_days;
  l_rec.absence_hours                    := p_absence_hours;
  l_rec.comments                         := p_comments;
  l_rec.date_end                         := p_date_end;
  l_rec.date_notification                := p_date_notification;
  l_rec.date_projected_end               := p_date_projected_end;
  l_rec.date_projected_start             := p_date_projected_start;
  l_rec.date_start                       := p_date_start;
  l_rec.occurrence                       := p_occurrence;
  l_rec.ssp1_issued                      := p_ssp1_issued;
  l_rec.time_end                         := p_time_end;
  l_rec.time_projected_end               := p_time_projected_end;
  l_rec.time_projected_start             := p_time_projected_start;
  l_rec.time_start                       := p_time_start;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.maternity_id                     := p_maternity_id;
  l_rec.sickness_start_date              := p_sickness_start_date;
  l_rec.sickness_end_date                := p_sickness_end_date;
  l_rec.pregnancy_related_illness        := p_pregnancy_related_illness;
  l_rec.reason_for_notification_delay    := p_reason_for_notification_dela;
  l_rec.accept_late_notification_flag    := p_accept_late_notification_fla;
  l_rec.linked_absence_id                := p_linked_absence_id;
  l_rec.abs_information_category         := p_abs_information_category;
  l_rec.abs_information1                 := p_abs_information1;
  l_rec.abs_information2                 := p_abs_information2;
  l_rec.abs_information3                 := p_abs_information3;
  l_rec.abs_information4                 := p_abs_information4;
  l_rec.abs_information5                 := p_abs_information5;
  l_rec.abs_information6                 := p_abs_information6;
  l_rec.abs_information7                 := p_abs_information7;
  l_rec.abs_information8                 := p_abs_information8;
  l_rec.abs_information9                 := p_abs_information9;
  l_rec.abs_information10                := p_abs_information10;
  l_rec.abs_information11                := p_abs_information11;
  l_rec.abs_information12                := p_abs_information12;
  l_rec.abs_information13                := p_abs_information13;
  l_rec.abs_information14                := p_abs_information14;
  l_rec.abs_information15                := p_abs_information15;
  l_rec.abs_information16                := p_abs_information16;
  l_rec.abs_information17                := p_abs_information17;
  l_rec.abs_information18                := p_abs_information18;
  l_rec.abs_information19                := p_abs_information19;
  l_rec.abs_information20                := p_abs_information20;
  l_rec.abs_information21                := p_abs_information21;
  l_rec.abs_information22                := p_abs_information22;
  l_rec.abs_information23                := p_abs_information23;
  l_rec.abs_information24                := p_abs_information24;
  l_rec.abs_information25                := p_abs_information25;
  l_rec.abs_information26                := p_abs_information26;
  l_rec.abs_information27                := p_abs_information27;
  l_rec.abs_information28                := p_abs_information28;
  l_rec.abs_information29                := p_abs_information29;
  l_rec.abs_information30                := p_abs_information30;
  l_rec.absence_case_id                  := p_absence_case_id;
  l_rec.batch_id                         := p_batch_id;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_abs_shd;

/
