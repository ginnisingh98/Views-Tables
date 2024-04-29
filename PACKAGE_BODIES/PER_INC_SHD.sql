--------------------------------------------------------
--  DDL for Package Body PER_INC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_INC_SHD" as
/* $Header: peincrhi.pkb 115.29 2003/08/31 00:49:48 kjagadee noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_inc_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PER_WORK_INCIDENTS_FK1') Then
    fnd_message.set_name('PER', 'PER_52893_INC_ABS_NOT_FOUND');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_WORK_INCIDENTS_FK2') Then
    fnd_message.set_name('PER', 'PER_52894_INC_INC_NOT_FOUND');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_WORK_INCIDENTS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
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
  (p_incident_id                          in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       incident_id
      ,person_id
      ,incident_reference
      ,incident_type
      ,incident_date
      ,incident_time
      ,org_notified_date
      ,assignment_id
      ,location
      ,at_work_flag
      ,report_date
      ,report_time
      ,report_method
      ,person_reported_by
      ,person_reported_to
      ,witness_details
      ,description
      ,injury_type
      ,disease_type
      ,hazard_type
      ,body_part
      ,treatment_received_flag
      ,hospital_details
        ,emergency_code
        ,hospitalized_flag
        ,hospital_address
        ,activity_at_time_of_work
        ,objects_involved
        ,privacy_issue
        ,work_start_time
        ,date_of_death
        ,report_completed_by
        ,reporting_person_title
        ,reporting_person_phone
        ,days_restricted_work
        ,days_away_from_work
      ,doctor_name
      ,compensation_date
      ,compensation_currency
      ,compensation_amount
      ,remedial_hs_action
      ,notified_hsrep_id
      ,notified_hsrep_date
      ,notified_rep_id
      ,notified_rep_date
      ,notified_rep_org_id
      ,related_incident_id
      ,over_time_flag
	 ,absence_exists_flag
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
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,inc_information_category
      ,inc_information1
      ,inc_information2
      ,inc_information3
      ,inc_information4
      ,inc_information5
      ,inc_information6
      ,inc_information7
      ,inc_information8
      ,inc_information9
      ,inc_information10
      ,inc_information11
      ,inc_information12
      ,inc_information13
      ,inc_information14
      ,inc_information15
      ,inc_information16
      ,inc_information17
      ,inc_information18
      ,inc_information19
      ,inc_information20
      ,inc_information21
      ,inc_information22
      ,inc_information23
      ,inc_information24
      ,inc_information25
      ,inc_information26
      ,inc_information27
      ,inc_information28
      ,inc_information29
      ,inc_information30
      ,object_version_number
    from	per_work_incidents
    where	incident_id = p_incident_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_incident_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_incident_id
        = per_inc_shd.g_old_rec.incident_id and
        p_object_version_number
        = per_inc_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into per_inc_shd.g_old_rec;
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
          <> per_inc_shd.g_old_rec.object_version_number) Then
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
  (p_incident_id                          in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       incident_id
      ,person_id
      ,incident_reference
      ,incident_type
      ,incident_date
      ,incident_time
      ,org_notified_date
      ,assignment_id
      ,location
      ,at_work_flag
      ,report_date
      ,report_time
      ,report_method
      ,person_reported_by
      ,person_reported_to
      ,witness_details
      ,description
      ,injury_type
      ,disease_type
      ,hazard_type
      ,body_part
      ,treatment_received_flag
      ,hospital_details
        ,emergency_code
        ,hospitalized_flag
        ,hospital_address
        ,activity_at_time_of_work
        ,objects_involved
        ,privacy_issue
        ,work_start_time
        ,date_of_death
        ,report_completed_by
        ,reporting_person_title
        ,reporting_person_phone
        ,days_restricted_work
        ,days_away_from_work
      ,doctor_name
      ,compensation_date
      ,compensation_currency
      ,compensation_amount
      ,remedial_hs_action
      ,notified_hsrep_id
      ,notified_hsrep_date
      ,notified_rep_id
      ,notified_rep_date
      ,notified_rep_org_id
      ,related_incident_id
      ,over_time_flag
	 ,absence_exists_flag
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
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,inc_information_category
      ,inc_information1
      ,inc_information2
      ,inc_information3
      ,inc_information4
      ,inc_information5
      ,inc_information6
      ,inc_information7
      ,inc_information8
      ,inc_information9
      ,inc_information10
      ,inc_information11
      ,inc_information12
      ,inc_information13
      ,inc_information14
      ,inc_information15
      ,inc_information16
      ,inc_information17
      ,inc_information18
      ,inc_information19
      ,inc_information20
      ,inc_information21
      ,inc_information22
      ,inc_information23
      ,inc_information24
      ,inc_information25
      ,inc_information26
      ,inc_information27
      ,inc_information28
      ,inc_information29
      ,inc_information30
      ,object_version_number
    from	per_work_incidents
    where	incident_id = p_incident_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'INCIDENT_ID'
    ,p_argument_value     => p_incident_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_inc_shd.g_old_rec;
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
      <> per_inc_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'per_work_incidents');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_incident_id                    in number
  ,p_person_id                      in number
  ,p_incident_reference             in varchar2
  ,p_incident_type                  in varchar2
  ,p_incident_date                  in date
  ,p_incident_time                  in varchar2
  ,p_org_notified_date              in date
  ,p_assignment_id                  in number
  ,p_location                       in varchar2
  ,p_at_work_flag                   in varchar2
  ,p_report_date                    in date
  ,p_report_time                    in varchar2
  ,p_report_method                  in varchar2
  ,p_person_reported_by             in number
  ,p_person_reported_to             in varchar2
  ,p_witness_details                in varchar2
  ,p_description                    in varchar2
  ,p_injury_type                    in varchar2
  ,p_disease_type                   in varchar2
  ,p_hazard_type                    in varchar2
  ,p_body_part                      in varchar2
  ,p_treatment_received_flag        in varchar2
  ,p_hospital_details               in varchar2
    ,p_emergency_code                 in varchar2
    ,p_hospitalized_flag              in varchar2
    ,p_hospital_address               in varchar2
    ,p_activity_at_time_of_work       in varchar2
    ,p_objects_involved               in varchar2
    ,p_privacy_issue                  in varchar2
    ,p_work_start_time                in varchar2
    ,p_date_of_death                  in date
    ,p_report_completed_by            in varchar2
    ,p_reporting_person_title         in varchar2
    ,p_reporting_person_phone         in varchar2
    ,p_days_restricted_work           in number
    ,p_days_away_from_work            in number
  ,p_doctor_name                    in varchar2
  ,p_compensation_date              in date
  ,p_compensation_currency          in varchar2
  ,p_compensation_amount            in number
  ,p_remedial_hs_action             in varchar2
  ,p_notified_hsrep_id              in number
  ,p_notified_hsrep_date            in date
  ,p_notified_rep_id                in number
  ,p_notified_rep_date              in date
  ,p_notified_rep_org_id            in number
  ,p_related_incident_id            in number
  ,p_over_time_flag                 in varchar2
  ,p_absence_exists_flag            in varchar2
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
  ,p_attribute21                    in varchar2
  ,p_attribute22                    in varchar2
  ,p_attribute23                    in varchar2
  ,p_attribute24                    in varchar2
  ,p_attribute25                    in varchar2
  ,p_attribute26                    in varchar2
  ,p_attribute27                    in varchar2
  ,p_attribute28                    in varchar2
  ,p_attribute29                    in varchar2
  ,p_attribute30                    in varchar2
  ,p_inc_information_category       in varchar2
  ,p_inc_information1               in varchar2
  ,p_inc_information2               in varchar2
  ,p_inc_information3               in varchar2
  ,p_inc_information4               in varchar2
  ,p_inc_information5               in varchar2
  ,p_inc_information6               in varchar2
  ,p_inc_information7               in varchar2
  ,p_inc_information8               in varchar2
  ,p_inc_information9               in varchar2
  ,p_inc_information10              in varchar2
  ,p_inc_information11              in varchar2
  ,p_inc_information12              in varchar2
  ,p_inc_information13              in varchar2
  ,p_inc_information14              in varchar2
  ,p_inc_information15              in varchar2
  ,p_inc_information16              in varchar2
  ,p_inc_information17              in varchar2
  ,p_inc_information18              in varchar2
  ,p_inc_information19              in varchar2
  ,p_inc_information20              in varchar2
  ,p_inc_information21              in varchar2
  ,p_inc_information22              in varchar2
  ,p_inc_information23              in varchar2
  ,p_inc_information24              in varchar2
  ,p_inc_information25              in varchar2
  ,p_inc_information26              in varchar2
  ,p_inc_information27              in varchar2
  ,p_inc_information28              in varchar2
  ,p_inc_information29              in varchar2
  ,p_inc_information30              in varchar2
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
  l_rec.incident_id                      := p_incident_id;
  l_rec.person_id                        := p_person_id;


  l_rec.incident_reference               := p_incident_reference;
  l_rec.incident_type                    := p_incident_type;
  l_rec.incident_date                    := p_incident_date;
  l_rec.incident_time                    := p_incident_time;
  l_rec.org_notified_date                := p_org_notified_date;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.location                         := p_location;
  l_rec.at_work_flag                     := p_at_work_flag;
  l_rec.report_date                      := p_report_date;
  l_rec.report_time                      := p_report_time;
  l_rec.report_method                    := p_report_method;
  l_rec.person_reported_by               := p_person_reported_by;
  l_rec.person_reported_to               := p_person_reported_to;
  l_rec.witness_details                  := p_witness_details;
  l_rec.description                      := p_description;
  l_rec.injury_type                      := p_injury_type;
  l_rec.disease_type                     := p_disease_type;
  l_rec.hazard_type                      := p_hazard_type;
  l_rec.body_part                        := p_body_part;
  l_rec.treatment_received_flag          := p_treatment_received_flag;
  l_rec.hospital_details                 := p_hospital_details;
--
    l_rec.emergency_code                   := p_emergency_code;
    l_rec.hospitalized_flag                := p_hospitalized_flag;
    l_rec.hospital_address                 := p_hospital_address;
    l_rec.activity_at_time_of_work         := p_activity_at_time_of_work;
    l_rec.objects_involved                 := p_objects_involved;
    l_rec.privacy_issue                    := p_privacy_issue;
    l_rec.work_start_time                  := p_work_start_time;
    l_rec.date_of_death                    := p_date_of_death;
    l_rec.report_completed_by              := p_report_completed_by;
    l_rec.reporting_person_title           := p_reporting_person_title;
    l_rec.reporting_person_phone           := p_reporting_person_phone;
    l_rec.days_restricted_work             := p_days_restricted_work;
    l_rec.days_away_from_work              := p_days_away_from_work;
--
  l_rec.doctor_name                      := p_doctor_name;
  l_rec.compensation_date                := p_compensation_date;
  l_rec.compensation_currency            := p_compensation_currency;
  l_rec.compensation_amount              := p_compensation_amount;
  l_rec.remedial_hs_action               := p_remedial_hs_action;
  l_rec.notified_hsrep_id                := p_notified_hsrep_id;
  l_rec.notified_hsrep_date              := p_notified_hsrep_date;
  l_rec.notified_rep_id                  := p_notified_rep_id;
  l_rec.notified_rep_date                := p_notified_rep_date;
  l_rec.notified_rep_org_id              := p_notified_rep_org_id;
  l_rec.related_incident_id              := p_related_incident_id;
  l_rec.over_time_flag                   := p_over_time_flag;
  l_rec.absence_exists_flag              := p_absence_exists_flag;
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
  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;
  l_rec.inc_information_category         := p_inc_information_category;
  l_rec.inc_information1                 := p_inc_information1;
  l_rec.inc_information2                 := p_inc_information2;
  l_rec.inc_information3                 := p_inc_information3;
  l_rec.inc_information4                 := p_inc_information4;
  l_rec.inc_information5                 := p_inc_information5;
  l_rec.inc_information6                 := p_inc_information6;
  l_rec.inc_information7                 := p_inc_information7;
  l_rec.inc_information8                 := p_inc_information8;
  l_rec.inc_information9                 := p_inc_information9;
  l_rec.inc_information10                := p_inc_information10;
  l_rec.inc_information11                := p_inc_information11;
  l_rec.inc_information12                := p_inc_information12;
  l_rec.inc_information13                := p_inc_information13;
  l_rec.inc_information14                := p_inc_information14;
  l_rec.inc_information15                := p_inc_information15;
  l_rec.inc_information16                := p_inc_information16;
  l_rec.inc_information17                := p_inc_information17;
  l_rec.inc_information18                := p_inc_information18;
  l_rec.inc_information19                := p_inc_information19;
  l_rec.inc_information20                := p_inc_information20;
  l_rec.inc_information21                := p_inc_information21;
  l_rec.inc_information22                := p_inc_information22;
  l_rec.inc_information23                := p_inc_information23;
  l_rec.inc_information24                := p_inc_information24;
  l_rec.inc_information25                := p_inc_information25;
  l_rec.inc_information26                := p_inc_information26;
  l_rec.inc_information27                := p_inc_information27;
  l_rec.inc_information28                := p_inc_information28;
  l_rec.inc_information29                := p_inc_information29;
  l_rec.inc_information30                := p_inc_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  --
  -- Return the plsql record structure.
  Return(l_rec);
--
End convert_args;
--
end per_inc_shd;

/
