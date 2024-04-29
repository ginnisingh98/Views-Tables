--------------------------------------------------------
--  DDL for Package Body PQH_LOS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_LOS_SHD" as
/* $Header: pqlosrhi.pkb 120.0 2005/05/29 02:11:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_los_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_SITUATIONS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
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
  (p_situation_id                         in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       situation_id
      ,situation
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,situation_type
      ,length_of_service
      ,employee_type
      ,entitlement_flag
      ,worktime_proportional
      ,entitlement_value
      ,information_category
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,information11
      ,information12
      ,information13
      ,information14
      ,information15
      ,information16
      ,information17
      ,information18
      ,information19
      ,information20
      ,information21
      ,information22
      ,information23
      ,information24
      ,information25
      ,information26
      ,information27
      ,information28
      ,information29
      ,information30
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
      ,object_version_number
    from        pqh_situations
    where       situation_id = p_situation_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_situation_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_situation_id
        = pqh_los_shd.g_old_rec.situation_id and
        p_object_version_number
        = pqh_los_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_los_shd.g_old_rec;
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
          <> pqh_los_shd.g_old_rec.object_version_number) Then
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
  (p_situation_id                         in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       situation_id
      ,situation
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,situation_type
      ,length_of_service
      ,employee_type
      ,entitlement_flag
      ,worktime_proportional
      ,entitlement_value
      ,information_category
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,information11
      ,information12
      ,information13
      ,information14
      ,information15
      ,information16
      ,information17
      ,information18
      ,information19
      ,information20
      ,information21
      ,information22
      ,information23
      ,information24
      ,information25
      ,information26
      ,information27
      ,information28
      ,information29
      ,information30
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
      ,object_version_number
    from        pqh_situations
    where       situation_id = p_situation_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'SITUATION_ID'
    ,p_argument_value     => p_situation_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_los_shd.g_old_rec;
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
      <> pqh_los_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqh_situations');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_situation_id                   in number
  ,p_situation                      in varchar2
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_business_group_id              in number
  ,p_situation_type                 in varchar2
  ,p_length_of_service              in varchar2
  ,p_employee_type                  in varchar2
  ,p_entitlement_flag               in varchar2
  ,p_worktime_proportional          in varchar2
  ,p_entitlement_value              in number
  ,p_information_category           in varchar2
  ,p_information1                   in varchar2
  ,p_information2                   in varchar2
  ,p_information3                   in varchar2
  ,p_information4                   in varchar2
  ,p_information5                   in varchar2
  ,p_information6                   in varchar2
  ,p_information7                   in varchar2
  ,p_information8                   in varchar2
  ,p_information9                   in varchar2
  ,p_information10                  in varchar2
  ,p_information11                  in varchar2
  ,p_information12                  in varchar2
  ,p_information13                  in varchar2
  ,p_information14                  in varchar2
  ,p_information15                  in varchar2
  ,p_information16                  in varchar2
  ,p_information17                  in varchar2
  ,p_information18                  in varchar2
  ,p_information19                  in varchar2
  ,p_information20                  in varchar2
  ,p_information21                  in varchar2
  ,p_information22                  in varchar2
  ,p_information23                  in varchar2
  ,p_information24                  in varchar2
  ,p_information25                  in varchar2
  ,p_information26                  in varchar2
  ,p_information27                  in varchar2
  ,p_information28                  in varchar2
  ,p_information29                  in varchar2
  ,p_information30                  in varchar2
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
  l_rec.situation_id                     := p_situation_id;
  l_rec.situation                        := p_situation;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.situation_type                   := p_situation_type;
  l_rec.length_of_service                := p_length_of_service;
  l_rec.employee_type                    := p_employee_type;
  l_rec.entitlement_flag                 := p_entitlement_flag;
  l_rec.worktime_proportional            := p_worktime_proportional;
  l_rec.entitlement_value                := p_entitlement_value;
  l_rec.information_category             := p_information_category;
  l_rec.information1                     := p_information1;
  l_rec.information2                     := p_information2;
  l_rec.information3                     := p_information3;
  l_rec.information4                     := p_information4;
  l_rec.information5                     := p_information5;
  l_rec.information6                     := p_information6;
  l_rec.information7                     := p_information7;
  l_rec.information8                     := p_information8;
  l_rec.information9                     := p_information9;
  l_rec.information10                    := p_information10;
  l_rec.information11                    := p_information11;
  l_rec.information12                    := p_information12;
  l_rec.information13                    := p_information13;
  l_rec.information14                    := p_information14;
  l_rec.information15                    := p_information15;
  l_rec.information16                    := p_information16;
  l_rec.information17                    := p_information17;
  l_rec.information18                    := p_information18;
  l_rec.information19                    := p_information19;
  l_rec.information20                    := p_information20;
  l_rec.information21                    := p_information21;
  l_rec.information22                    := p_information22;
  l_rec.information23                    := p_information23;
  l_rec.information24                    := p_information24;
  l_rec.information25                    := p_information25;
  l_rec.information26                    := p_information26;
  l_rec.information27                    := p_information27;
  l_rec.information28                    := p_information28;
  l_rec.information29                    := p_information29;
  l_rec.information30                    := p_information30;
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
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_los_shd;

/
