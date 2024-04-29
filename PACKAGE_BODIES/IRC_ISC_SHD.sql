--------------------------------------------------------
--  DDL for Package Body IRC_ISC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ISC_SHD" as
/* $Header: iriscrhi.pkb 120.0 2005/07/26 15:11:17 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_isc_shd.';  -- Global package name
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
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'IRC_SEARCH_CRITERIA_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'IRC_SEARCH_CRITERIA_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'IRC_SEARCH_CRITERIA_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'SEARCH_CRITERIA_ID_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
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
  (p_search_criteria_id                   in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       search_criteria_id
      ,object_id
      ,object_type
      ,search_name
      ,search_type
      ,location
      ,distance_to_location
      ,geocode_location
      ,geocode_country
      ,derived_location
      ,location_id
      ,isc.geometry.sdo_point.x
      ,isc.geometry.sdo_point.y
      ,employee
      ,contractor
      ,employment_category
      ,keywords
      ,travel_percentage
      ,min_salary
      ,max_salary
      ,salary_currency
      ,salary_period
      ,match_competence
      ,match_qualification
      ,job_title
      ,department
      ,professional_area
      ,work_at_home
      ,min_qual_level
      ,max_qual_level
      ,use_for_matching
      ,description
      ,''
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
      ,isc_information_category
      ,isc_information1
      ,isc_information2
      ,isc_information3
      ,isc_information4
      ,isc_information5
      ,isc_information6
      ,isc_information7
      ,isc_information8
      ,isc_information9
      ,isc_information10
      ,isc_information11
      ,isc_information12
      ,isc_information13
      ,isc_information14
      ,isc_information15
      ,isc_information16
      ,isc_information17
      ,isc_information18
      ,isc_information19
      ,isc_information20
      ,isc_information21
      ,isc_information22
      ,isc_information23
      ,isc_information24
      ,isc_information25
      ,isc_information26
      ,isc_information27
      ,isc_information28
      ,isc_information29
      ,isc_information30
      ,object_version_number
      ,date_posted
    from        irc_search_criteria isc
    where       search_criteria_id = p_search_criteria_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_search_criteria_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_search_criteria_id
        = irc_isc_shd.g_old_rec.search_criteria_id and
        p_object_version_number
        = irc_isc_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into irc_isc_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      -- Convert description from clob to varchar
      irc_isc_shd.g_old_rec.description
      := dbms_lob.substr(irc_isc_shd.g_old_rec.description_c);

      If (p_object_version_number
          <> irc_isc_shd.g_old_rec.object_version_number) Then
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
  (p_search_criteria_id                   in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       search_criteria_id
      ,object_id
      ,object_type
      ,search_name
      ,search_type
      ,location
      ,distance_to_location
      ,geocode_location
      ,geocode_country
      ,derived_location
      ,location_id
      ,isc.geometry.sdo_point.x
      ,isc.geometry.sdo_point.y
      ,employee
      ,contractor
      ,employment_category
      ,keywords
      ,travel_percentage
      ,min_salary
      ,max_salary
      ,salary_currency
      ,salary_period
      ,match_competence
      ,match_qualification
      ,job_title
      ,department
      ,professional_area
      ,work_at_home
      ,min_qual_level
      ,max_qual_level
      ,use_for_matching
      ,description
      ,''
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
      ,isc_information_category
      ,isc_information1
      ,isc_information2
      ,isc_information3
      ,isc_information4
      ,isc_information5
      ,isc_information6
      ,isc_information7
      ,isc_information8
      ,isc_information9
      ,isc_information10
      ,isc_information11
      ,isc_information12
      ,isc_information13
      ,isc_information14
      ,isc_information15
      ,isc_information16
      ,isc_information17
      ,isc_information18
      ,isc_information19
      ,isc_information20
      ,isc_information21
      ,isc_information22
      ,isc_information23
      ,isc_information24
      ,isc_information25
      ,isc_information26
      ,isc_information27
      ,isc_information28
      ,isc_information29
      ,isc_information30
      ,object_version_number
      ,date_posted
    from        irc_search_criteria isc
    where       search_criteria_id = p_search_criteria_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'SEARCH_CRITERIA_ID'
    ,p_argument_value     => p_search_criteria_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into irc_isc_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  -- Convert description from clob to varchar
  irc_isc_shd.g_old_rec.description
  := dbms_lob.substr(irc_isc_shd.g_old_rec.description_c);

  If (p_object_version_number
      <> irc_isc_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'irc_search_criteria');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_search_criteria_id             in number
  ,p_object_id                      in number
  ,p_object_type                    in varchar2
  ,p_search_name                    in varchar2
  ,p_search_type                    in varchar2
  ,p_location                       in varchar2
  ,p_distance_to_location           in varchar2
  ,p_geocode_location               in varchar2
  ,p_geocode_country                in varchar2
  ,p_derived_location               in varchar2
  ,p_location_id                    in number
  ,p_longitude                      in number
  ,p_latitude                       in number
  ,p_employee                       in varchar2
  ,p_contractor                     in varchar2
  ,p_employment_category            in varchar2
  ,p_keywords                       in varchar2
  ,p_travel_percentage              in number
  ,p_min_salary                     in number
  ,p_max_salary                     in number
  ,p_salary_currency                in varchar2
  ,p_salary_period                  in varchar2
  ,p_match_competence               in varchar2
  ,p_match_qualification            in varchar2
  ,p_job_title                      in varchar2
  ,p_department                     in varchar2
  ,p_professional_area              in varchar2
  ,p_work_at_home                   in varchar2
  ,p_min_qual_level                 in number
  ,p_max_qual_level                 in number
  ,p_use_for_matching               in varchar2
  ,p_description                    in varchar2
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
  ,p_isc_information_category       in varchar2
  ,p_isc_information1               in varchar2
  ,p_isc_information2               in varchar2
  ,p_isc_information3               in varchar2
  ,p_isc_information4               in varchar2
  ,p_isc_information5               in varchar2
  ,p_isc_information6               in varchar2
  ,p_isc_information7               in varchar2
  ,p_isc_information8               in varchar2
  ,p_isc_information9               in varchar2
  ,p_isc_information10              in varchar2
  ,p_isc_information11              in varchar2
  ,p_isc_information12              in varchar2
  ,p_isc_information13              in varchar2
  ,p_isc_information14              in varchar2
  ,p_isc_information15              in varchar2
  ,p_isc_information16              in varchar2
  ,p_isc_information17              in varchar2
  ,p_isc_information18              in varchar2
  ,p_isc_information19              in varchar2
  ,p_isc_information20              in varchar2
  ,p_isc_information21              in varchar2
  ,p_isc_information22              in varchar2
  ,p_isc_information23              in varchar2
  ,p_isc_information24              in varchar2
  ,p_isc_information25              in varchar2
  ,p_isc_information26              in varchar2
  ,p_isc_information27              in varchar2
  ,p_isc_information28              in varchar2
  ,p_isc_information29              in varchar2
  ,p_isc_information30              in varchar2
  ,p_object_version_number          in number
  ,p_date_posted                    in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.search_criteria_id               := p_search_criteria_id;
  l_rec.object_id                        := p_object_id;
  l_rec.object_type                      := p_object_type;
  l_rec.search_name                      := p_search_name;
  l_rec.search_type                      := p_search_type;
  l_rec.location                         := p_location;
  l_rec.distance_to_location             := p_distance_to_location;
  l_rec.geocode_location                 := p_geocode_location;
  l_rec.geocode_country                  := p_geocode_country;
  l_rec.derived_location                 := p_derived_location;
  l_rec.location_id                      := p_location_id;
  l_rec.longitude                        := p_longitude;
  l_rec.latitude                         := p_latitude;
  l_rec.employee                         := p_employee;
  l_rec.contractor                       := p_contractor;
  l_rec.employment_category              := p_employment_category;
  l_rec.keywords                         := p_keywords;
  l_rec.travel_percentage                := p_travel_percentage;
  l_rec.min_salary                       := p_min_salary;
  l_rec.max_salary                       := p_max_salary;
  l_rec.salary_currency                  := p_salary_currency;
  l_rec.salary_period                    := p_salary_period;
  l_rec.match_competence                 := p_match_competence;
  l_rec.match_qualification              := p_match_qualification;
  l_rec.job_title                        := p_job_title;
  l_rec.department                       := p_department;
  l_rec.professional_area                := p_professional_area;
  l_rec.work_at_home                     := p_work_at_home;
  l_rec.min_qual_level                   := p_min_qual_level;
  l_rec.max_qual_level                   := p_max_qual_level;
  l_rec.use_for_matching                 := p_use_for_matching;
  l_rec.description                      := p_description;
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
  l_rec.isc_information_category         := p_isc_information_category;
  l_rec.isc_information1                 := p_isc_information1;
  l_rec.isc_information2                 := p_isc_information2;
  l_rec.isc_information3                 := p_isc_information3;
  l_rec.isc_information4                 := p_isc_information4;
  l_rec.isc_information5                 := p_isc_information5;
  l_rec.isc_information6                 := p_isc_information6;
  l_rec.isc_information7                 := p_isc_information7;
  l_rec.isc_information8                 := p_isc_information8;
  l_rec.isc_information9                 := p_isc_information9;
  l_rec.isc_information10                := p_isc_information10;
  l_rec.isc_information11                := p_isc_information11;
  l_rec.isc_information12                := p_isc_information12;
  l_rec.isc_information13                := p_isc_information13;
  l_rec.isc_information14                := p_isc_information14;
  l_rec.isc_information15                := p_isc_information15;
  l_rec.isc_information16                := p_isc_information16;
  l_rec.isc_information17                := p_isc_information17;
  l_rec.isc_information18                := p_isc_information18;
  l_rec.isc_information19                := p_isc_information19;
  l_rec.isc_information20                := p_isc_information20;
  l_rec.isc_information21                := p_isc_information21;
  l_rec.isc_information22                := p_isc_information22;
  l_rec.isc_information23                := p_isc_information23;
  l_rec.isc_information24                := p_isc_information24;
  l_rec.isc_information25                := p_isc_information25;
  l_rec.isc_information26                := p_isc_information26;
  l_rec.isc_information27                := p_isc_information27;
  l_rec.isc_information28                := p_isc_information28;
  l_rec.isc_information29                := p_isc_information29;
  l_rec.isc_information30                := p_isc_information30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.date_posted                      := p_date_posted;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end irc_isc_shd;

/
