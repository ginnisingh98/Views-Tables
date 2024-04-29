--------------------------------------------------------
--  DDL for Package Body PAY_AUD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AUD_SHD" as
/* $Header: pyaudrhi.pkb 115.4 2002/12/09 10:29:32 alogue ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_aud_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_stat_trans_AUDIT_FK1') Then
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
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_stat_trans_audit_id                 in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       stat_trans_audit_id
      ,transaction_type
      ,transaction_subtype
      ,transaction_date
      ,transaction_effective_date
      ,business_group_id
      ,person_id
      ,assignment_id
      ,source1
      ,source1_type
      ,source2
      ,source2_type
      ,source3
      ,source3_type
      ,source4
      ,source4_type
      ,source5
      ,source5_type
      ,transaction_parent_id
      ,audit_information_category
      ,audit_information1
      ,audit_information2
      ,audit_information3
      ,audit_information4
      ,audit_information5
      ,audit_information6
      ,audit_information7
      ,audit_information8
      ,audit_information9
      ,audit_information10
      ,audit_information11
      ,audit_information12
      ,audit_information13
      ,audit_information14
      ,audit_information15
      ,audit_information16
      ,audit_information17
      ,audit_information18
      ,audit_information19
      ,audit_information20
      ,audit_information21
      ,audit_information22
      ,audit_information23
      ,audit_information24
      ,audit_information25
      ,audit_information26
      ,audit_information27
      ,audit_information28
      ,audit_information29
      ,audit_information30
      ,title
      ,object_version_number
    from	pay_stat_trans_audit
    where	stat_trans_audit_id = p_stat_trans_audit_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'STAT_TRANS_AUDIT_ID'
    ,p_argument_value     => p_stat_trans_audit_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_aud_shd.g_old_rec;
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
      <> pay_aud_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pay_stat_trans_audit');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_stat_trans_audit_id           in number
  ,p_transaction_type               in varchar2
  ,p_transaction_subtype            in varchar2
  ,p_transaction_date               in date
  ,p_transaction_effective_date     in date
  ,p_business_group_id              in number
  ,p_person_id                      in number
  ,p_assignment_id                  in number
  ,p_source1                        in varchar2
  ,p_source1_type                   in varchar2
  ,p_source2                        in varchar2
  ,p_source2_type                   in varchar2
  ,p_source3                        in varchar2
  ,p_source3_type                   in varchar2
  ,p_source4                        in varchar2
  ,p_source4_type                   in varchar2
  ,p_source5                        in varchar2
  ,p_source5_type                   in varchar2
  ,p_transaction_parent_id          in number
  ,p_audit_information_category     in varchar2
  ,p_audit_information1             in varchar2
  ,p_audit_information2             in varchar2
  ,p_audit_information3             in varchar2
  ,p_audit_information4             in varchar2
  ,p_audit_information5             in varchar2
  ,p_audit_information6             in varchar2
  ,p_audit_information7             in varchar2
  ,p_audit_information8             in varchar2
  ,p_audit_information9             in varchar2
  ,p_audit_information10            in varchar2
  ,p_audit_information11            in varchar2
  ,p_audit_information12            in varchar2
  ,p_audit_information13            in varchar2
  ,p_audit_information14            in varchar2
  ,p_audit_information15            in varchar2
  ,p_audit_information16            in varchar2
  ,p_audit_information17            in varchar2
  ,p_audit_information18            in varchar2
  ,p_audit_information19            in varchar2
  ,p_audit_information20            in varchar2
  ,p_audit_information21            in varchar2
  ,p_audit_information22            in varchar2
  ,p_audit_information23            in varchar2
  ,p_audit_information24            in varchar2
  ,p_audit_information25            in varchar2
  ,p_audit_information26            in varchar2
  ,p_audit_information27            in varchar2
  ,p_audit_information28            in varchar2
  ,p_audit_information29            in varchar2
  ,p_audit_information30            in varchar2
  ,p_title                          in varchar2
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
  l_rec.stat_trans_audit_id             := p_stat_trans_audit_id;
  l_rec.transaction_type                 := p_transaction_type;
  l_rec.transaction_subtype              := p_transaction_subtype;
  l_rec.transaction_date                 := p_transaction_date;
  l_rec.transaction_effective_date       := p_transaction_effective_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.person_id                        := p_person_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.source1                          := p_source1;
  l_rec.source1_type                     := p_source1_type;
  l_rec.source2                          := p_source2;
  l_rec.source2_type                     := p_source2_type;
  l_rec.source3                          := p_source3;
  l_rec.source3_type                     := p_source3_type;
  l_rec.source4                          := p_source4;
  l_rec.source4_type                     := p_source4_type;
  l_rec.source5                          := p_source5;
  l_rec.source5_type                     := p_source5_type;
  l_rec.transaction_parent_id            := p_transaction_parent_id;
  l_rec.audit_information_category       := p_audit_information_category;
  l_rec.audit_information1               := p_audit_information1;
  l_rec.audit_information2               := p_audit_information2;
  l_rec.audit_information3               := p_audit_information3;
  l_rec.audit_information4               := p_audit_information4;
  l_rec.audit_information5               := p_audit_information5;
  l_rec.audit_information6               := p_audit_information6;
  l_rec.audit_information7               := p_audit_information7;
  l_rec.audit_information8               := p_audit_information8;
  l_rec.audit_information9               := p_audit_information9;
  l_rec.audit_information10              := p_audit_information10;
  l_rec.audit_information11              := p_audit_information11;
  l_rec.audit_information12              := p_audit_information12;
  l_rec.audit_information13              := p_audit_information13;
  l_rec.audit_information14              := p_audit_information14;
  l_rec.audit_information15              := p_audit_information15;
  l_rec.audit_information16              := p_audit_information16;
  l_rec.audit_information17              := p_audit_information17;
  l_rec.audit_information18              := p_audit_information18;
  l_rec.audit_information19              := p_audit_information19;
  l_rec.audit_information20              := p_audit_information20;
  l_rec.audit_information21              := p_audit_information21;
  l_rec.audit_information22              := p_audit_information22;
  l_rec.audit_information23              := p_audit_information23;
  l_rec.audit_information24              := p_audit_information24;
  l_rec.audit_information25              := p_audit_information25;
  l_rec.audit_information26              := p_audit_information26;
  l_rec.audit_information27              := p_audit_information27;
  l_rec.audit_information28              := p_audit_information28;
  l_rec.audit_information29              := p_audit_information29;
  l_rec.audit_information30              := p_audit_information30;
  l_rec.title                            := p_title;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_aud_shd;

/
