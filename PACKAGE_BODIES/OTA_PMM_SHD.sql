--------------------------------------------------------
--  DDL for Package Body OTA_PMM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_PMM_SHD" as
/* $Header: otpmm01t.pkb 115.2 99/07/16 00:53:06 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_pmm_shd.';  -- Global package name
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
            (p_constraint_name in varchar2) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'OTA_PMM_REQUIRED_FLAG_CHK') Then
    hr_utility.set_message(801, 'OTA_13423_PMM_REQUIRED_FLAG');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PROGRAM_MEMBERSHIPS_FK1') Then
    hr_utility.set_message(801, 'OTA_13424_PMM_NO_EVENT');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PROGRAM_MEMBERSHIPS_FK2') Then
    hr_utility.set_message(801, 'OTA_13425_PMM_NO_PROGRAM');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_PROGRAM_MEMBERSHIPS_PK') Then
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
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
  p_program_membership_id              in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		program_membership_id,
	event_id,
	program_event_id,
	object_version_number,
	comments,
	group_name,
	required_flag,
	role,
	sequence,
	pmm_information_category,
	pmm_information1,
	pmm_information2,
	pmm_information3,
	pmm_information4,
	pmm_information5,
	pmm_information6,
	pmm_information7,
	pmm_information8,
	pmm_information9,
	pmm_information10,
	pmm_information11,
	pmm_information12,
	pmm_information13,
	pmm_information14,
	pmm_information15,
	pmm_information16,
	pmm_information17,
	pmm_information18,
	pmm_information19,
	pmm_information20
    from	ota_program_memberships
    where	program_membership_id = p_program_membership_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_program_membership_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_program_membership_id = g_old_rec.program_membership_id and
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
  p_program_membership_id              in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	program_membership_id,
	event_id,
	program_event_id,
	object_version_number,
	comments,
	group_name,
	required_flag,
	role,
	sequence,
	pmm_information_category,
	pmm_information1,
	pmm_information2,
	pmm_information3,
	pmm_information4,
	pmm_information5,
	pmm_information6,
	pmm_information7,
	pmm_information8,
	pmm_information9,
	pmm_information10,
	pmm_information11,
	pmm_information12,
	pmm_information13,
	pmm_information14,
	pmm_information15,
	pmm_information16,
	pmm_information17,
	pmm_information18,
	pmm_information19,
	pmm_information20
    from	ota_program_memberships
    where	program_membership_id = p_program_membership_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_program_memberships');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_program_membership_id         in number,
	p_event_id                      in number,
	p_program_event_id              in number,
	p_object_version_number         in number,
	p_comments                      in varchar2,
	p_group_name                    in varchar2,
	p_required_flag                 in varchar2,
	p_role                          in varchar2,
	p_sequence                      in number,
	p_pmm_information_category      in varchar2,
	p_pmm_information1              in varchar2,
	p_pmm_information2              in varchar2,
	p_pmm_information3              in varchar2,
	p_pmm_information4              in varchar2,
	p_pmm_information5              in varchar2,
	p_pmm_information6              in varchar2,
	p_pmm_information7              in varchar2,
	p_pmm_information8              in varchar2,
	p_pmm_information9              in varchar2,
	p_pmm_information10             in varchar2,
	p_pmm_information11             in varchar2,
	p_pmm_information12             in varchar2,
	p_pmm_information13             in varchar2,
	p_pmm_information14             in varchar2,
	p_pmm_information15             in varchar2,
	p_pmm_information16             in varchar2,
	p_pmm_information17             in varchar2,
	p_pmm_information18             in varchar2,
	p_pmm_information19             in varchar2,
	p_pmm_information20             in varchar2
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
  l_rec.program_membership_id            := p_program_membership_id;
  l_rec.event_id                         := p_event_id;
  l_rec.program_event_id                 := p_program_event_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.comments                         := p_comments;
  l_rec.group_name                       := p_group_name;
  l_rec.required_flag                    := p_required_flag;
  l_rec.role                             := p_role;
  l_rec.sequence                         := p_sequence;
  l_rec.pmm_information_category         := p_pmm_information_category;
  l_rec.pmm_information1                 := p_pmm_information1;
  l_rec.pmm_information2                 := p_pmm_information2;
  l_rec.pmm_information3                 := p_pmm_information3;
  l_rec.pmm_information4                 := p_pmm_information4;
  l_rec.pmm_information5                 := p_pmm_information5;
  l_rec.pmm_information6                 := p_pmm_information6;
  l_rec.pmm_information7                 := p_pmm_information7;
  l_rec.pmm_information8                 := p_pmm_information8;
  l_rec.pmm_information9                 := p_pmm_information9;
  l_rec.pmm_information10                := p_pmm_information10;
  l_rec.pmm_information11                := p_pmm_information11;
  l_rec.pmm_information12                := p_pmm_information12;
  l_rec.pmm_information13                := p_pmm_information13;
  l_rec.pmm_information14                := p_pmm_information14;
  l_rec.pmm_information15                := p_pmm_information15;
  l_rec.pmm_information16                := p_pmm_information16;
  l_rec.pmm_information17                := p_pmm_information17;
  l_rec.pmm_information18                := p_pmm_information18;
  l_rec.pmm_information19                := p_pmm_information19;
  l_rec.pmm_information20                := p_pmm_information20;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ota_pmm_shd;

/
