--------------------------------------------------------
--  DDL for Package Body OTA_TSP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TSP_SHD" as
/* $Header: ottsp01t.pkb 120.0 2005/05/29 07:54:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tsp_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_SKILL_PROVISIONS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TSP_TYPE_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
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
  p_skill_provision_id                 in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		skill_provision_id,
	activity_version_id,
	object_version_number,
	type,
	comments,
	tsp_information_category,
	tsp_information1,
	tsp_information2,
	tsp_information3,
	tsp_information4,
	tsp_information5,
	tsp_information6,
	tsp_information7,
	tsp_information8,
	tsp_information9,
	tsp_information10,
	tsp_information11,
	tsp_information12,
	tsp_information13,
	tsp_information14,
	tsp_information15,
	tsp_information16,
	tsp_information17,
	tsp_information18,
	tsp_information19,
	tsp_information20,
	analysis_criteria_id
    from	ota_skill_provisions
    where	skill_provision_id = p_skill_provision_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_skill_provision_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_skill_provision_id = g_old_rec.skill_provision_id and
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
  p_skill_provision_id                 in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	skill_provision_id,
	activity_version_id,
	object_version_number,
	type,
	comments,
	tsp_information_category,
	tsp_information1,
	tsp_information2,
	tsp_information3,
	tsp_information4,
	tsp_information5,
	tsp_information6,
	tsp_information7,
	tsp_information8,
	tsp_information9,
	tsp_information10,
	tsp_information11,
	tsp_information12,
	tsp_information13,
	tsp_information14,
	tsp_information15,
	tsp_information16,
	tsp_information17,
	tsp_information18,
	tsp_information19,
	tsp_information20,
	analysis_criteria_id
    from	ota_skill_provisions
    where	skill_provision_id = p_skill_provision_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_skill_provisions');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_skill_provision_id            in number,
	p_activity_version_id           in number,
	p_object_version_number         in number,
	p_type                          in varchar2,
	p_comments                      in varchar2,
	p_tsp_information_category      in varchar2,
	p_tsp_information1              in varchar2,
	p_tsp_information2              in varchar2,
	p_tsp_information3              in varchar2,
	p_tsp_information4              in varchar2,
	p_tsp_information5              in varchar2,
	p_tsp_information6              in varchar2,
	p_tsp_information7              in varchar2,
	p_tsp_information8              in varchar2,
	p_tsp_information9              in varchar2,
	p_tsp_information10             in varchar2,
	p_tsp_information11             in varchar2,
	p_tsp_information12             in varchar2,
	p_tsp_information13             in varchar2,
	p_tsp_information14             in varchar2,
	p_tsp_information15             in varchar2,
	p_tsp_information16             in varchar2,
	p_tsp_information17             in varchar2,
	p_tsp_information18             in varchar2,
	p_tsp_information19             in varchar2,
	p_tsp_information20             in varchar2,
	p_analysis_criteria_id          in number
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
  l_rec.skill_provision_id               := p_skill_provision_id;
  l_rec.activity_version_id              := p_activity_version_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.type                             := p_type;
  l_rec.comments                         := p_comments;
  l_rec.tsp_information_category         := p_tsp_information_category;
  l_rec.tsp_information1                 := p_tsp_information1;
  l_rec.tsp_information2                 := p_tsp_information2;
  l_rec.tsp_information3                 := p_tsp_information3;
  l_rec.tsp_information4                 := p_tsp_information4;
  l_rec.tsp_information5                 := p_tsp_information5;
  l_rec.tsp_information6                 := p_tsp_information6;
  l_rec.tsp_information7                 := p_tsp_information7;
  l_rec.tsp_information8                 := p_tsp_information8;
  l_rec.tsp_information9                 := p_tsp_information9;
  l_rec.tsp_information10                := p_tsp_information10;
  l_rec.tsp_information11                := p_tsp_information11;
  l_rec.tsp_information12                := p_tsp_information12;
  l_rec.tsp_information13                := p_tsp_information13;
  l_rec.tsp_information14                := p_tsp_information14;
  l_rec.tsp_information15                := p_tsp_information15;
  l_rec.tsp_information16                := p_tsp_information16;
  l_rec.tsp_information17                := p_tsp_information17;
  l_rec.tsp_information18                := p_tsp_information18;
  l_rec.tsp_information19                := p_tsp_information19;
  l_rec.tsp_information20                := p_tsp_information20;
  l_rec.analysis_criteria_id             := p_analysis_criteria_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< copy_skill >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Copy all skills from one activity to another
--
Procedure copy_skill
  (
  p_activity_version_from                in number,
  p_activity_version_to                  in number
  )  Is
--
l_rec           g_rec_type;
v_proc          varchar2(72):= g_package||'copy_skill';
--
--
cursor sel_skill is
  select
        skill_provision_id,
	activity_version_id,
	type,
	comments,
	tsp_information_category,
	tsp_information1,
	tsp_information2,
	tsp_information3,
	tsp_information4,
	tsp_information5,
	tsp_information6,
	tsp_information7,
	tsp_information8,
	tsp_information9,
	tsp_information10,
	tsp_information11,
	tsp_information12,
	tsp_information13,
	tsp_information14,
	tsp_information15,
	tsp_information16,
	tsp_information17,
	tsp_information18,
	tsp_information19,
	tsp_information20,
	analysis_criteria_id
    from	ota_skill_provisions
    where	activity_version_id = p_activity_version_from;
--
Begin
  --
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  Open sel_skill;
  Fetch sel_skill into
        l_rec.skill_provision_id,
	l_rec.activity_version_id,
	l_rec.type,
	l_rec.comments,
	l_rec.tsp_information_category,
	l_rec.tsp_information1,
	l_rec.tsp_information2,
	l_rec.tsp_information3,
	l_rec.tsp_information4,
	l_rec.tsp_information5,
	l_rec.tsp_information6,
	l_rec.tsp_information7,
	l_rec.tsp_information8,
	l_rec.tsp_information9,
	l_rec.tsp_information10,
	l_rec.tsp_information11,
	l_rec.tsp_information12,
	l_rec.tsp_information13,
	l_rec.tsp_information14,
	l_rec.tsp_information15,
	l_rec.tsp_information16,
	l_rec.tsp_information17,
	l_rec.tsp_information18,
	l_rec.tsp_information19,
	l_rec.tsp_information20,
	l_rec.analysis_criteria_id;
--
Loop
 --
 Exit When sel_skill%notfound;
 --
ota_tsp_ins. ins(
      l_rec.skill_provision_id,
      p_activity_version_to,
      l_rec.object_version_number,
      l_rec.type,
      l_rec.comments,
      l_rec.tsp_information_category,
      l_rec.tsp_information1,
      l_rec.tsp_information2,
      l_rec.tsp_information3,
      l_rec.tsp_information4,
      l_rec.tsp_information5,
      l_rec.tsp_information6,
      l_rec.tsp_information7,
      l_rec.tsp_information8,
      l_rec.tsp_information9,
      l_rec.tsp_information10,
      l_rec.tsp_information11,
      l_rec.tsp_information12,
      l_rec.tsp_information13,
      l_rec.tsp_information14,
      l_rec.tsp_information15,
      l_rec.tsp_information16,
      l_rec.tsp_information17,
      l_rec.tsp_information18,
      l_rec.tsp_information19,
      l_rec.tsp_information20,
      l_rec.analysis_criteria_id,
      false);
 --
 Fetch sel_skill into
        l_rec.skill_provision_id,
	l_rec.activity_version_id,
	l_rec.type,
	l_rec.comments,
	l_rec.tsp_information_category,
	l_rec.tsp_information1,
	l_rec.tsp_information2,
	l_rec.tsp_information3,
	l_rec.tsp_information4,
	l_rec.tsp_information5,
	l_rec.tsp_information6,
	l_rec.tsp_information7,
	l_rec.tsp_information8,
	l_rec.tsp_information9,
	l_rec.tsp_information10,
	l_rec.tsp_information11,
	l_rec.tsp_information12,
	l_rec.tsp_information13,
	l_rec.tsp_information14,
	l_rec.tsp_information15,
	l_rec.tsp_information16,
	l_rec.tsp_information17,
	l_rec.tsp_information18,
	l_rec.tsp_information19,
	l_rec.tsp_information20,
	l_rec.analysis_criteria_id;
 --
End Loop;
--
Close sel_skill;
--
hr_utility.set_location('Leaving:'||v_proc, 10);
--
End copy_skill;
--
end ota_tsp_shd;

/
