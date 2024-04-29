--------------------------------------------------------
--  DDL for Package Body PQP_VAI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VAI_SHD" as
/* $Header: pqvairhi.pkb 120.0.12010000.2 2008/08/08 07:19:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_vai_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQP_VEH_ALLOC_EXTRA_INFO_PK') Then
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
  (p_veh_alloc_extra_info_id              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       veh_alloc_extra_info_id
      ,vehicle_allocation_id
      ,information_type
      ,vaei_attribute_category
      ,vaei_attribute1
      ,vaei_attribute2
      ,vaei_attribute3
      ,vaei_attribute4
      ,vaei_attribute5
      ,vaei_attribute6
      ,vaei_attribute7
      ,vaei_attribute8
      ,vaei_attribute9
      ,vaei_attribute10
      ,vaei_attribute11
      ,vaei_attribute12
      ,vaei_attribute13
      ,vaei_attribute14
      ,vaei_attribute15
      ,vaei_attribute16
      ,vaei_attribute17
      ,vaei_attribute18
      ,vaei_attribute19
      ,vaei_attribute20
      ,vaei_information_category
      ,vaei_information1
      ,vaei_information2
      ,vaei_information3
      ,vaei_information4
      ,vaei_information5
      ,vaei_information6
      ,vaei_information7
      ,vaei_information8
      ,vaei_information9
      ,vaei_information10
      ,vaei_information11
      ,vaei_information12
      ,vaei_information13
      ,vaei_information14
      ,vaei_information15
      ,vaei_information16
      ,vaei_information17
      ,vaei_information18
      ,vaei_information19
      ,vaei_information20
      ,vaei_information21
      ,vaei_information22
      ,vaei_information23
      ,vaei_information24
      ,vaei_information25
      ,vaei_information26
      ,vaei_information27
      ,vaei_information28
      ,vaei_information29
      ,vaei_information30
      ,object_version_number
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
    from        pqp_veh_alloc_extra_info
    where       veh_alloc_extra_info_id = p_veh_alloc_extra_info_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_veh_alloc_extra_info_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_veh_alloc_extra_info_id
        = pqp_vai_shd.g_old_rec.veh_alloc_extra_info_id and
        p_object_version_number
        = pqp_vai_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqp_vai_shd.g_old_rec;
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
          <> pqp_vai_shd.g_old_rec.object_version_number) Then
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
  (p_veh_alloc_extra_info_id              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       veh_alloc_extra_info_id
      ,vehicle_allocation_id
      ,information_type
      ,vaei_attribute_category
      ,vaei_attribute1
      ,vaei_attribute2
      ,vaei_attribute3
      ,vaei_attribute4
      ,vaei_attribute5
      ,vaei_attribute6
      ,vaei_attribute7
      ,vaei_attribute8
      ,vaei_attribute9
      ,vaei_attribute10
      ,vaei_attribute11
      ,vaei_attribute12
      ,vaei_attribute13
      ,vaei_attribute14
      ,vaei_attribute15
      ,vaei_attribute16
      ,vaei_attribute17
      ,vaei_attribute18
      ,vaei_attribute19
      ,vaei_attribute20
      ,vaei_information_category
      ,vaei_information1
      ,vaei_information2
      ,vaei_information3
      ,vaei_information4
      ,vaei_information5
      ,vaei_information6
      ,vaei_information7
      ,vaei_information8
      ,vaei_information9
      ,vaei_information10
      ,vaei_information11
      ,vaei_information12
      ,vaei_information13
      ,vaei_information14
      ,vaei_information15
      ,vaei_information16
      ,vaei_information17
      ,vaei_information18
      ,vaei_information19
      ,vaei_information20
      ,vaei_information21
      ,vaei_information22
      ,vaei_information23
      ,vaei_information24
      ,vaei_information25
      ,vaei_information26
      ,vaei_information27
      ,vaei_information28
      ,vaei_information29
      ,vaei_information30
      ,object_version_number
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
    from        pqp_veh_alloc_extra_info
    where       veh_alloc_extra_info_id = p_veh_alloc_extra_info_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'VEH_ALLOC_EXTRA_INFO_ID'
    ,p_argument_value     => p_veh_alloc_extra_info_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqp_vai_shd.g_old_rec;
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
      <> pqp_vai_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqp_veh_alloc_extra_info');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_veh_alloc_extra_info_id        in number
  ,p_vehicle_allocation_id          in number
  ,p_information_type               in varchar2
  ,p_vaei_attribute_category        in varchar2
  ,p_vaei_attribute1                in varchar2
  ,p_vaei_attribute2                in varchar2
  ,p_vaei_attribute3                in varchar2
  ,p_vaei_attribute4                in varchar2
  ,p_vaei_attribute5                in varchar2
  ,p_vaei_attribute6                in varchar2
  ,p_vaei_attribute7                in varchar2
  ,p_vaei_attribute8                in varchar2
  ,p_vaei_attribute9                in varchar2
  ,p_vaei_attribute10               in varchar2
  ,p_vaei_attribute11               in varchar2
  ,p_vaei_attribute12               in varchar2
  ,p_vaei_attribute13               in varchar2
  ,p_vaei_attribute14               in varchar2
  ,p_vaei_attribute15               in varchar2
  ,p_vaei_attribute16               in varchar2
  ,p_vaei_attribute17               in varchar2
  ,p_vaei_attribute18               in varchar2
  ,p_vaei_attribute19               in varchar2
  ,p_vaei_attribute20               in varchar2
  ,p_vaei_information_category      in varchar2
  ,p_vaei_information1              in varchar2
  ,p_vaei_information2              in varchar2
  ,p_vaei_information3              in varchar2
  ,p_vaei_information4              in varchar2
  ,p_vaei_information5              in varchar2
  ,p_vaei_information6              in varchar2
  ,p_vaei_information7              in varchar2
  ,p_vaei_information8              in varchar2
  ,p_vaei_information9              in varchar2
  ,p_vaei_information10             in varchar2
  ,p_vaei_information11             in varchar2
  ,p_vaei_information12             in varchar2
  ,p_vaei_information13             in varchar2
  ,p_vaei_information14             in varchar2
  ,p_vaei_information15             in varchar2
  ,p_vaei_information16             in varchar2
  ,p_vaei_information17             in varchar2
  ,p_vaei_information18             in varchar2
  ,p_vaei_information19             in varchar2
  ,p_vaei_information20             in varchar2
  ,p_vaei_information21             in varchar2
  ,p_vaei_information22             in varchar2
  ,p_vaei_information23             in varchar2
  ,p_vaei_information24             in varchar2
  ,p_vaei_information25             in varchar2
  ,p_vaei_information26             in varchar2
  ,p_vaei_information27             in varchar2
  ,p_vaei_information28             in varchar2
  ,p_vaei_information29             in varchar2
  ,p_vaei_information30             in varchar2
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
  l_rec.veh_alloc_extra_info_id          := p_veh_alloc_extra_info_id;
  l_rec.vehicle_allocation_id            := p_vehicle_allocation_id;
  l_rec.information_type                 := p_information_type;
  l_rec.vaei_attribute_category          := p_vaei_attribute_category;
  l_rec.vaei_attribute1                  := p_vaei_attribute1;
  l_rec.vaei_attribute2                  := p_vaei_attribute2;
  l_rec.vaei_attribute3                  := p_vaei_attribute3;
  l_rec.vaei_attribute4                  := p_vaei_attribute4;
  l_rec.vaei_attribute5                  := p_vaei_attribute5;
  l_rec.vaei_attribute6                  := p_vaei_attribute6;
  l_rec.vaei_attribute7                  := p_vaei_attribute7;
  l_rec.vaei_attribute8                  := p_vaei_attribute8;
  l_rec.vaei_attribute9                  := p_vaei_attribute9;
  l_rec.vaei_attribute10                 := p_vaei_attribute10;
  l_rec.vaei_attribute11                 := p_vaei_attribute11;
  l_rec.vaei_attribute12                 := p_vaei_attribute12;
  l_rec.vaei_attribute13                 := p_vaei_attribute13;
  l_rec.vaei_attribute14                 := p_vaei_attribute14;
  l_rec.vaei_attribute15                 := p_vaei_attribute15;
  l_rec.vaei_attribute16                 := p_vaei_attribute16;
  l_rec.vaei_attribute17                 := p_vaei_attribute17;
  l_rec.vaei_attribute18                 := p_vaei_attribute18;
  l_rec.vaei_attribute19                 := p_vaei_attribute19;
  l_rec.vaei_attribute20                 := p_vaei_attribute20;
  l_rec.vaei_information_category        := p_vaei_information_category;
  l_rec.vaei_information1                := p_vaei_information1;
  l_rec.vaei_information2                := p_vaei_information2;
  l_rec.vaei_information3                := p_vaei_information3;
  l_rec.vaei_information4                := p_vaei_information4;
  l_rec.vaei_information5                := p_vaei_information5;
  l_rec.vaei_information6                := p_vaei_information6;
  l_rec.vaei_information7                := p_vaei_information7;
  l_rec.vaei_information8                := p_vaei_information8;
  l_rec.vaei_information9                := p_vaei_information9;
  l_rec.vaei_information10               := p_vaei_information10;
  l_rec.vaei_information11               := p_vaei_information11;
  l_rec.vaei_information12               := p_vaei_information12;
  l_rec.vaei_information13               := p_vaei_information13;
  l_rec.vaei_information14               := p_vaei_information14;
  l_rec.vaei_information15               := p_vaei_information15;
  l_rec.vaei_information16               := p_vaei_information16;
  l_rec.vaei_information17               := p_vaei_information17;
  l_rec.vaei_information18               := p_vaei_information18;
  l_rec.vaei_information19               := p_vaei_information19;
  l_rec.vaei_information20               := p_vaei_information20;
  l_rec.vaei_information21               := p_vaei_information21;
  l_rec.vaei_information22               := p_vaei_information22;
  l_rec.vaei_information23               := p_vaei_information23;
  l_rec.vaei_information24               := p_vaei_information24;
  l_rec.vaei_information25               := p_vaei_information25;
  l_rec.vaei_information26               := p_vaei_information26;
  l_rec.vaei_information27               := p_vaei_information27;
  l_rec.vaei_information28               := p_vaei_information28;
  l_rec.vaei_information29               := p_vaei_information29;
  l_rec.vaei_information30               := p_vaei_information30;
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
end pqp_vai_shd;

/
