--------------------------------------------------------
--  DDL for Package Body PAY_CON_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CON_SHD" as
/* $Header: pyconrhi.pkb 115.3 1999/12/03 16:45:29 pkm ship      $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_con_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PAY_US_CONTRIBUTION_HISTORY_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_US_CONTRIBUTION_HISTORY_UK') Then
    --hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIl');
    --hr_utility.set_message_token('PROCEDURE', l_proc);
    --hr_utility.set_message_token('STEP','10');
    hr_utility.set_message(801, 'PAY_CONTRIB_HIST_NOT_UNIQUE');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_contr_history_id                   in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		contr_history_id,
	person_id,
	date_from,
	date_to,
	contr_type,
	business_group_id,
	legislation_code,
	amt_contr,
	max_contr_allowed,
	includable_comp,
	tax_unit_id,
	source_system,
	contr_information_category,
	contr_information1,
	contr_information2,
	contr_information3,
	contr_information4,
	contr_information5,
	contr_information6,
	contr_information7,
	contr_information8,
	contr_information9,
	contr_information10,
	contr_information11,
	contr_information12,
	contr_information13,
	contr_information14,
	contr_information15,
	contr_information16,
	contr_information17,
	contr_information18,
	contr_information19,
	contr_information20,
	contr_information21,
	contr_information22,
	contr_information23,
	contr_information24,
	contr_information25,
	contr_information26,
	contr_information27,
	contr_information28,
	contr_information29,
	contr_information30,
	object_version_number
    from	pay_us_contribution_history
    where	contr_history_id = p_contr_history_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_contr_history_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_contr_history_id = g_old_rec.contr_history_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
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
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_contr_history_id                   in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	contr_history_id,
	person_id,
	date_from,
	date_to,
	contr_type,
	business_group_id,
	legislation_code,
	amt_contr,
	max_contr_allowed,
	includable_comp,
	tax_unit_id,
	source_system,
	contr_information_category,
	contr_information1,
	contr_information2,
	contr_information3,
	contr_information4,
	contr_information5,
	contr_information6,
	contr_information7,
	contr_information8,
	contr_information9,
	contr_information10,
	contr_information11,
	contr_information12,
	contr_information13,
	contr_information14,
	contr_information15,
	contr_information16,
	contr_information17,
	contr_information18,
	contr_information19,
	contr_information20,
	contr_information21,
	contr_information22,
	contr_information23,
	contr_information24,
	contr_information25,
	contr_information26,
	contr_information27,
	contr_information28,
	contr_information29,
	contr_information30,
	object_version_number
    from	pay_us_contribution_history
    where	contr_history_id = p_contr_history_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pay_us_contribution_history');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_contr_history_id              in number,
	p_person_id                     in number,
	p_date_from                     in date,
	p_date_to                       in date,
	p_contr_type                    in varchar2,
	p_business_group_id             in number,
	p_legislation_code              in varchar2,
	p_amt_contr                     in number,
	p_max_contr_allowed             in number,
	p_includable_comp               in number,
	p_tax_unit_id                   in number,
	p_source_system                 in varchar2,
	p_contr_information_category    in varchar2,
	p_contr_information1            in varchar2,
	p_contr_information2            in varchar2,
	p_contr_information3            in varchar2,
	p_contr_information4            in varchar2,
	p_contr_information5            in varchar2,
	p_contr_information6            in varchar2,
	p_contr_information7            in varchar2,
	p_contr_information8            in varchar2,
	p_contr_information9            in varchar2,
	p_contr_information10           in varchar2,
	p_contr_information11           in varchar2,
	p_contr_information12           in varchar2,
	p_contr_information13           in varchar2,
	p_contr_information14           in varchar2,
	p_contr_information15           in varchar2,
	p_contr_information16           in varchar2,
	p_contr_information17           in varchar2,
	p_contr_information18           in varchar2,
	p_contr_information19           in varchar2,
	p_contr_information20           in varchar2,
	p_contr_information21           in varchar2,
	p_contr_information22           in varchar2,
	p_contr_information23           in varchar2,
	p_contr_information24           in varchar2,
	p_contr_information25           in varchar2,
	p_contr_information26           in varchar2,
	p_contr_information27           in varchar2,
	p_contr_information28           in varchar2,
	p_contr_information29           in varchar2,
	p_contr_information30           in varchar2,
	p_object_version_number         in number
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.contr_history_id                 := p_contr_history_id;
  l_rec.person_id                        := p_person_id;
  l_rec.date_from                        := p_date_from;
  l_rec.date_to                          := p_date_to;
  l_rec.contr_type                       := p_contr_type;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.amt_contr                        := p_amt_contr;
  l_rec.max_contr_allowed                := p_max_contr_allowed;
  l_rec.includable_comp                  := p_includable_comp;
  l_rec.tax_unit_id                      := p_tax_unit_id;
  l_rec.source_system                    := p_source_system;
  l_rec.contr_information_category       := p_contr_information_category;
  l_rec.contr_information1               := p_contr_information1;
  l_rec.contr_information2               := p_contr_information2;
  l_rec.contr_information3               := p_contr_information3;
  l_rec.contr_information4               := p_contr_information4;
  l_rec.contr_information5               := p_contr_information5;
  l_rec.contr_information6               := p_contr_information6;
  l_rec.contr_information7               := p_contr_information7;
  l_rec.contr_information8               := p_contr_information8;
  l_rec.contr_information9               := p_contr_information9;
  l_rec.contr_information10              := p_contr_information10;
  l_rec.contr_information11              := p_contr_information11;
  l_rec.contr_information12              := p_contr_information12;
  l_rec.contr_information13              := p_contr_information13;
  l_rec.contr_information14              := p_contr_information14;
  l_rec.contr_information15              := p_contr_information15;
  l_rec.contr_information16              := p_contr_information16;
  l_rec.contr_information17              := p_contr_information17;
  l_rec.contr_information18              := p_contr_information18;
  l_rec.contr_information19              := p_contr_information19;
  l_rec.contr_information20              := p_contr_information20;
  l_rec.contr_information21              := p_contr_information21;
  l_rec.contr_information22              := p_contr_information22;
  l_rec.contr_information23              := p_contr_information23;
  l_rec.contr_information24              := p_contr_information24;
  l_rec.contr_information25              := p_contr_information25;
  l_rec.contr_information26              := p_contr_information26;
  l_rec.contr_information27              := p_contr_information27;
  l_rec.contr_information28              := p_contr_information28;
  l_rec.contr_information29              := p_contr_information29;
  l_rec.contr_information30              := p_contr_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pay_con_shd;

/
