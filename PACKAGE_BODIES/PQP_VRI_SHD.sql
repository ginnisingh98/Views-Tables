--------------------------------------------------------
--  DDL for Package Body PQP_VRI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VRI_SHD" as
/* $Header: pqvrirhi.pkb 120.0.12010000.2 2008/08/08 07:24:11 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_vri_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQP_VEH_REPOS_EXTRA_INFO_PK') Then
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
  (p_veh_repos_extra_info_id              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       veh_repos_extra_info_id
      ,vehicle_repository_id
      ,information_type
      ,vrei_attribute_category
      ,vrei_attribute1
      ,vrei_attribute2
      ,vrei_attribute3
      ,vrei_attribute4
      ,vrei_attribute5
      ,vrei_attribute6
      ,vrei_attribute7
      ,vrei_attribute8
      ,vrei_attribute9
      ,vrei_attribute10
      ,vrei_attribute11
      ,vrei_attribute12
      ,vrei_attribute13
      ,vrei_attribute14
      ,vrei_attribute15
      ,vrei_attribute16
      ,vrei_attribute17
      ,vrei_attribute18
      ,vrei_attribute19
      ,vrei_attribute20
      ,vrei_information_category
      ,vrei_information1
      ,vrei_information2
      ,vrei_information3
      ,vrei_information4
      ,vrei_information5
      ,vrei_information6
      ,vrei_information7
      ,vrei_information8
      ,vrei_information9
      ,vrei_information10
      ,vrei_information11
      ,vrei_information12
      ,vrei_information13
      ,vrei_information14
      ,vrei_information15
      ,vrei_information16
      ,vrei_information17
      ,vrei_information18
      ,vrei_information19
      ,vrei_information20
      ,vrei_information21
      ,vrei_information22
      ,vrei_information23
      ,vrei_information24
      ,vrei_information25
      ,vrei_information26
      ,vrei_information27
      ,vrei_information28
      ,vrei_information29
      ,vrei_information30
      ,object_version_number
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
    from        pqp_veh_repos_extra_info
    where       veh_repos_extra_info_id = p_veh_repos_extra_info_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_veh_repos_extra_info_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_veh_repos_extra_info_id
        = pqp_vri_shd.g_old_rec.veh_repos_extra_info_id and
        p_object_version_number
        = pqp_vri_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqp_vri_shd.g_old_rec;
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
          <> pqp_vri_shd.g_old_rec.object_version_number) Then
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
  (p_veh_repos_extra_info_id              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       veh_repos_extra_info_id
      ,vehicle_repository_id
      ,information_type
      ,vrei_attribute_category
      ,vrei_attribute1
      ,vrei_attribute2
      ,vrei_attribute3
      ,vrei_attribute4
      ,vrei_attribute5
      ,vrei_attribute6
      ,vrei_attribute7
      ,vrei_attribute8
      ,vrei_attribute9
      ,vrei_attribute10
      ,vrei_attribute11
      ,vrei_attribute12
      ,vrei_attribute13
      ,vrei_attribute14
      ,vrei_attribute15
      ,vrei_attribute16
      ,vrei_attribute17
      ,vrei_attribute18
      ,vrei_attribute19
      ,vrei_attribute20
      ,vrei_information_category
      ,vrei_information1
      ,vrei_information2
      ,vrei_information3
      ,vrei_information4
      ,vrei_information5
      ,vrei_information6
      ,vrei_information7
      ,vrei_information8
      ,vrei_information9
      ,vrei_information10
      ,vrei_information11
      ,vrei_information12
      ,vrei_information13
      ,vrei_information14
      ,vrei_information15
      ,vrei_information16
      ,vrei_information17
      ,vrei_information18
      ,vrei_information19
      ,vrei_information20
      ,vrei_information21
      ,vrei_information22
      ,vrei_information23
      ,vrei_information24
      ,vrei_information25
      ,vrei_information26
      ,vrei_information27
      ,vrei_information28
      ,vrei_information29
      ,vrei_information30
      ,object_version_number
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
    from        pqp_veh_repos_extra_info
    where       veh_repos_extra_info_id = p_veh_repos_extra_info_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'VEH_REPOS_EXTRA_INFO_ID'
    ,p_argument_value     => p_veh_repos_extra_info_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqp_vri_shd.g_old_rec;
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
      <> pqp_vri_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqp_veh_repos_extra_info');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_veh_repos_extra_info_id        in number
  ,p_vehicle_repository_id          in number
  ,p_information_type               in varchar2
  ,p_vrei_attribute_category        in varchar2
  ,p_vrei_attribute1                in varchar2
  ,p_vrei_attribute2                in varchar2
  ,p_vrei_attribute3                in varchar2
  ,p_vrei_attribute4                in varchar2
  ,p_vrei_attribute5                in varchar2
  ,p_vrei_attribute6                in varchar2
  ,p_vrei_attribute7                in varchar2
  ,p_vrei_attribute8                in varchar2
  ,p_vrei_attribute9                in varchar2
  ,p_vrei_attribute10               in varchar2
  ,p_vrei_attribute11               in varchar2
  ,p_vrei_attribute12               in varchar2
  ,p_vrei_attribute13               in varchar2
  ,p_vrei_attribute14               in varchar2
  ,p_vrei_attribute15               in varchar2
  ,p_vrei_attribute16               in varchar2
  ,p_vrei_attribute17               in varchar2
  ,p_vrei_attribute18               in varchar2
  ,p_vrei_attribute19               in varchar2
  ,p_vrei_attribute20               in varchar2
  ,p_vrei_information_category      in varchar2
  ,p_vrei_information1              in varchar2
  ,p_vrei_information2              in varchar2
  ,p_vrei_information3              in varchar2
  ,p_vrei_information4              in varchar2
  ,p_vrei_information5              in varchar2
  ,p_vrei_information6              in varchar2
  ,p_vrei_information7              in varchar2
  ,p_vrei_information8              in varchar2
  ,p_vrei_information9              in varchar2
  ,p_vrei_information10             in varchar2
  ,p_vrei_information11             in varchar2
  ,p_vrei_information12             in varchar2
  ,p_vrei_information13             in varchar2
  ,p_vrei_information14             in varchar2
  ,p_vrei_information15             in varchar2
  ,p_vrei_information16             in varchar2
  ,p_vrei_information17             in varchar2
  ,p_vrei_information18             in varchar2
  ,p_vrei_information19             in varchar2
  ,p_vrei_information20             in varchar2
  ,p_vrei_information21             in varchar2
  ,p_vrei_information22             in varchar2
  ,p_vrei_information23             in varchar2
  ,p_vrei_information24             in varchar2
  ,p_vrei_information25             in varchar2
  ,p_vrei_information26             in varchar2
  ,p_vrei_information27             in varchar2
  ,p_vrei_information28             in varchar2
  ,p_vrei_information29             in varchar2
  ,p_vrei_information30             in varchar2
  ,p_object_version_number          in number
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.veh_repos_extra_info_id          := p_veh_repos_extra_info_id;
  l_rec.vehicle_repository_id            := p_vehicle_repository_id;
  l_rec.information_type                 := p_information_type;
  l_rec.vrei_attribute_category          := p_vrei_attribute_category;
  l_rec.vrei_attribute1                  := p_vrei_attribute1;
  l_rec.vrei_attribute2                  := p_vrei_attribute2;
  l_rec.vrei_attribute3                  := p_vrei_attribute3;
  l_rec.vrei_attribute4                  := p_vrei_attribute4;
  l_rec.vrei_attribute5                  := p_vrei_attribute5;
  l_rec.vrei_attribute6                  := p_vrei_attribute6;
  l_rec.vrei_attribute7                  := p_vrei_attribute7;
  l_rec.vrei_attribute8                  := p_vrei_attribute8;
  l_rec.vrei_attribute9                  := p_vrei_attribute9;
  l_rec.vrei_attribute10                 := p_vrei_attribute10;
  l_rec.vrei_attribute11                 := p_vrei_attribute11;
  l_rec.vrei_attribute12                 := p_vrei_attribute12;
  l_rec.vrei_attribute13                 := p_vrei_attribute13;
  l_rec.vrei_attribute14                 := p_vrei_attribute14;
  l_rec.vrei_attribute15                 := p_vrei_attribute15;
  l_rec.vrei_attribute16                 := p_vrei_attribute16;
  l_rec.vrei_attribute17                 := p_vrei_attribute17;
  l_rec.vrei_attribute18                 := p_vrei_attribute18;
  l_rec.vrei_attribute19                 := p_vrei_attribute19;
  l_rec.vrei_attribute20                 := p_vrei_attribute20;
  l_rec.vrei_information_category        := p_vrei_information_category;
  l_rec.vrei_information1                := p_vrei_information1;
  l_rec.vrei_information2                := p_vrei_information2;
  l_rec.vrei_information3                := p_vrei_information3;
  l_rec.vrei_information4                := p_vrei_information4;
  l_rec.vrei_information5                := p_vrei_information5;
  l_rec.vrei_information6                := p_vrei_information6;
  l_rec.vrei_information7                := p_vrei_information7;
  l_rec.vrei_information8                := p_vrei_information8;
  l_rec.vrei_information9                := p_vrei_information9;
  l_rec.vrei_information10               := p_vrei_information10;
  l_rec.vrei_information11               := p_vrei_information11;
  l_rec.vrei_information12               := p_vrei_information12;
  l_rec.vrei_information13               := p_vrei_information13;
  l_rec.vrei_information14               := p_vrei_information14;
  l_rec.vrei_information15               := p_vrei_information15;
  l_rec.vrei_information16               := p_vrei_information16;
  l_rec.vrei_information17               := p_vrei_information17;
  l_rec.vrei_information18               := p_vrei_information18;
  l_rec.vrei_information19               := p_vrei_information19;
  l_rec.vrei_information20               := p_vrei_information20;
  l_rec.vrei_information21               := p_vrei_information21;
  l_rec.vrei_information22               := p_vrei_information22;
  l_rec.vrei_information23               := p_vrei_information23;
  l_rec.vrei_information24               := p_vrei_information24;
  l_rec.vrei_information25               := p_vrei_information25;
  l_rec.vrei_information26               := p_vrei_information26;
  l_rec.vrei_information27               := p_vrei_information27;
  l_rec.vrei_information28               := p_vrei_information28;
  l_rec.vrei_information29               := p_vrei_information29;
  l_rec.vrei_information30               := p_vrei_information30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqp_vri_shd;

/
