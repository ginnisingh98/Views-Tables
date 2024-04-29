--------------------------------------------------------
--  DDL for Package Body PQP_SHP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_SHP_SHD" as
/* $Header: pqshprhi.pkb 115.8 2003/02/17 22:14:48 tmehra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_shp_shd.';  -- Global package name
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
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PQP_SERVICE_HISTORY_PERIODS_PK') Then
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
  (p_service_history_period_id            in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       service_history_period_id
      ,business_group_id
      ,assignment_id
      ,start_date
      ,end_date
      ,employer_name
      ,employer_address
      ,employer_type
      ,employer_subtype
      ,period_years
      ,period_days
      ,description
      ,continuous_service
      ,all_assignments
      ,object_version_number
      ,shp_attribute_category
      ,shp_attribute1
      ,shp_attribute2
      ,shp_attribute3
      ,shp_attribute4
      ,shp_attribute5
      ,shp_attribute6
      ,shp_attribute7
      ,shp_attribute8
      ,shp_attribute9
      ,shp_attribute10
      ,shp_attribute11
      ,shp_attribute12
      ,shp_attribute13
      ,shp_attribute14
      ,shp_attribute15
      ,shp_attribute16
      ,shp_attribute17
      ,shp_attribute18
      ,shp_attribute19
      ,shp_attribute20
      ,shp_information_category
      ,shp_information1
      ,shp_information2
      ,shp_information3
      ,shp_information4
      ,shp_information5
      ,shp_information6
      ,shp_information7
      ,shp_information8
      ,shp_information9
      ,shp_information10
      ,shp_information11
      ,shp_information12
      ,shp_information13
      ,shp_information14
      ,shp_information15
      ,shp_information16
      ,shp_information17
      ,shp_information18
      ,shp_information19
      ,shp_information20
    from	pqp_service_history_periods
    where	service_history_period_id = p_service_history_period_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_service_history_period_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_service_history_period_id
        = pqp_shp_shd.g_old_rec.service_history_period_id and
        p_object_version_number
        = pqp_shp_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqp_shp_shd.g_old_rec;
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
          <> pqp_shp_shd.g_old_rec.object_version_number) Then
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
  (p_service_history_period_id            in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       service_history_period_id
      ,business_group_id
      ,assignment_id
      ,start_date
      ,end_date
      ,employer_name
      ,employer_address
      ,employer_type
      ,employer_subtype
      ,period_years
      ,period_days
      ,description
      ,continuous_service
      ,all_assignments
      ,object_version_number
      ,shp_attribute_category
      ,shp_attribute1
      ,shp_attribute2
      ,shp_attribute3
      ,shp_attribute4
      ,shp_attribute5
      ,shp_attribute6
      ,shp_attribute7
      ,shp_attribute8
      ,shp_attribute9
      ,shp_attribute10
      ,shp_attribute11
      ,shp_attribute12
      ,shp_attribute13
      ,shp_attribute14
      ,shp_attribute15
      ,shp_attribute16
      ,shp_attribute17
      ,shp_attribute18
      ,shp_attribute19
      ,shp_attribute20
      ,shp_information_category
      ,shp_information1
      ,shp_information2
      ,shp_information3
      ,shp_information4
      ,shp_information5
      ,shp_information6
      ,shp_information7
      ,shp_information8
      ,shp_information9
      ,shp_information10
      ,shp_information11
      ,shp_information12
      ,shp_information13
      ,shp_information14
      ,shp_information15
      ,shp_information16
      ,shp_information17
      ,shp_information18
      ,shp_information19
      ,shp_information20
    from	pqp_service_history_periods
    where	service_history_period_id = p_service_history_period_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'SERVICE_HISTORY_PERIOD_ID'
    ,p_argument_value     => p_service_history_period_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqp_shp_shd.g_old_rec;
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
      <> pqp_shp_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqp_service_history_periods');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_service_history_period_id      in number
  ,p_business_group_id              in number
  ,p_assignment_id                  in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_employer_name                  in varchar2
  ,p_employer_address               in varchar2
  ,p_employer_type                  in varchar2
  ,p_employer_subtype               in varchar2
  ,p_period_years                   in number
  ,p_period_days                    in number
  ,p_description                    in varchar2
  ,p_continuous_service             in varchar2
  ,p_all_assignments                in varchar2
  ,p_object_version_number          in number
  ,p_shp_attribute_category         in varchar2
  ,p_shp_attribute1                 in varchar2
  ,p_shp_attribute2                 in varchar2
  ,p_shp_attribute3                 in varchar2
  ,p_shp_attribute4                 in varchar2
  ,p_shp_attribute5                 in varchar2
  ,p_shp_attribute6                 in varchar2
  ,p_shp_attribute7                 in varchar2
  ,p_shp_attribute8                 in varchar2
  ,p_shp_attribute9                 in varchar2
  ,p_shp_attribute10                in varchar2
  ,p_shp_attribute11                in varchar2
  ,p_shp_attribute12                in varchar2
  ,p_shp_attribute13                in varchar2
  ,p_shp_attribute14                in varchar2
  ,p_shp_attribute15                in varchar2
  ,p_shp_attribute16                in varchar2
  ,p_shp_attribute17                in varchar2
  ,p_shp_attribute18                in varchar2
  ,p_shp_attribute19                in varchar2
  ,p_shp_attribute20                in varchar2
  ,p_shp_information_category       in varchar2
  ,p_shp_information1               in varchar2
  ,p_shp_information2               in varchar2
  ,p_shp_information3               in varchar2
  ,p_shp_information4               in varchar2
  ,p_shp_information5               in varchar2
  ,p_shp_information6               in varchar2
  ,p_shp_information7               in varchar2
  ,p_shp_information8               in varchar2
  ,p_shp_information9               in varchar2
  ,p_shp_information10              in varchar2
  ,p_shp_information11              in varchar2
  ,p_shp_information12              in varchar2
  ,p_shp_information13              in varchar2
  ,p_shp_information14              in varchar2
  ,p_shp_information15              in varchar2
  ,p_shp_information16              in varchar2
  ,p_shp_information17              in varchar2
  ,p_shp_information18              in varchar2
  ,p_shp_information19              in varchar2
  ,p_shp_information20              in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.service_history_period_id        := p_service_history_period_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.employer_name                    := p_employer_name;
  l_rec.employer_address                 := p_employer_address;
  l_rec.employer_type                    := p_employer_type;
  l_rec.employer_subtype                 := p_employer_subtype;
  l_rec.period_years                     := p_period_years;
  l_rec.period_days                      := p_period_days;
  l_rec.description                      := p_description;
  l_rec.continuous_service               := p_continuous_service;
  l_rec.all_assignments                  := p_all_assignments;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.shp_attribute_category           := p_shp_attribute_category;
  l_rec.shp_attribute1                   := p_shp_attribute1;
  l_rec.shp_attribute2                   := p_shp_attribute2;
  l_rec.shp_attribute3                   := p_shp_attribute3;
  l_rec.shp_attribute4                   := p_shp_attribute4;
  l_rec.shp_attribute5                   := p_shp_attribute5;
  l_rec.shp_attribute6                   := p_shp_attribute6;
  l_rec.shp_attribute7                   := p_shp_attribute7;
  l_rec.shp_attribute8                   := p_shp_attribute8;
  l_rec.shp_attribute9                   := p_shp_attribute9;
  l_rec.shp_attribute10                  := p_shp_attribute10;
  l_rec.shp_attribute11                  := p_shp_attribute11;
  l_rec.shp_attribute12                  := p_shp_attribute12;
  l_rec.shp_attribute13                  := p_shp_attribute13;
  l_rec.shp_attribute14                  := p_shp_attribute14;
  l_rec.shp_attribute15                  := p_shp_attribute15;
  l_rec.shp_attribute16                  := p_shp_attribute16;
  l_rec.shp_attribute17                  := p_shp_attribute17;
  l_rec.shp_attribute18                  := p_shp_attribute18;
  l_rec.shp_attribute19                  := p_shp_attribute19;
  l_rec.shp_attribute20                  := p_shp_attribute20;
  l_rec.shp_information_category         := p_shp_information_category;
  l_rec.shp_information1                 := p_shp_information1;
  l_rec.shp_information2                 := p_shp_information2;
  l_rec.shp_information3                 := p_shp_information3;
  l_rec.shp_information4                 := p_shp_information4;
  l_rec.shp_information5                 := p_shp_information5;
  l_rec.shp_information6                 := p_shp_information6;
  l_rec.shp_information7                 := p_shp_information7;
  l_rec.shp_information8                 := p_shp_information8;
  l_rec.shp_information9                 := p_shp_information9;
  l_rec.shp_information10                := p_shp_information10;
  l_rec.shp_information11                := p_shp_information11;
  l_rec.shp_information12                := p_shp_information12;
  l_rec.shp_information13                := p_shp_information13;
  l_rec.shp_information14                := p_shp_information14;
  l_rec.shp_information15                := p_shp_information15;
  l_rec.shp_information16                := p_shp_information16;
  l_rec.shp_information17                := p_shp_information17;
  l_rec.shp_information18                := p_shp_information18;
  l_rec.shp_information19                := p_shp_information19;
  l_rec.shp_information20                := p_shp_information20;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqp_shp_shd;

/
