--------------------------------------------------------
--  DDL for Package Body OTA_TEA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TEA_SHD" as
/* $Header: ottea01t.pkb 120.1 2005/06/09 01:16:02 jbharath noship $ */

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tea_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_EVENT_ASSOCIATIONS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_EVENT_ASSOCIATIONS_UK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'OTA_TEA_CHECK_KEYS') then
    fnd_message.set_name('OTA','OTA_13528_TEA_INVALID_KEY');
    fnd_message.raise_error;
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
  p_event_association_id               in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		event_association_id,
	event_id,
	customer_id,
        organization_id,
        job_id,
        position_id,
	comments,
	tea_information_category,
	tea_information1,
	tea_information2,
	tea_information3,
	tea_information4,
	tea_information5,
	tea_information6,
	tea_information7,
	tea_information8,
	tea_information9,
	tea_information10,
	tea_information11,
	tea_information12,
	tea_information13,
	tea_information14,
	tea_information15,
	tea_information16,
	tea_information17,
	tea_information18,
	tea_information19,
	tea_information20
    from	ota_event_associations
    where	event_association_id = p_event_association_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_event_association_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_event_association_id = g_old_rec.event_association_id
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
      --
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
procedure lck
  (
  p_event_association_id               in number
  ) is
begin
   lck(p_event_association_id      => p_event_association_id
      ,p_booking_id                => null
      ,p_tdb_object_version_number => null);
end;
--
Procedure lck
  (
  p_event_association_id               in number
 ,p_booking_id				in number
 ,p_tdb_object_version_number		in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	event_association_id,
	event_id,
	customer_id,
        organization_id,
        job_id,
        position_id,
	comments,
	tea_information_category,
	tea_information1,
	tea_information2,
	tea_information3,
	tea_information4,
	tea_information5,
	tea_information6,
	tea_information7,
	tea_information8,
	tea_information9,
	tea_information10,
	tea_information11,
	tea_information12,
	tea_information13,
	tea_information14,
	tea_information15,
	tea_information16,
	tea_information17,
	tea_information18,
	tea_information19,
	tea_information20
    from	ota_event_associations
    where	event_association_id = p_event_association_id
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
hr_utility.trace('Event Association ID is '||to_char(p_event_association_id));
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
  --
  if p_booking_id is not null then
     OTA_TDB_SHD.lck (
	p_booking_id			=> p_booking_id
	,p_object_version_number	=> p_tdb_object_version_number
  );
  end if;
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_event_associations');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_event_association_id          in number,
	p_event_id                      in number,
	p_customer_id                   in number,
        p_organization_id               in number,
        p_job_id                        in number,
        p_position_id                   in number,
	p_comments                      in varchar2,
	p_tea_information_category      in varchar2,
	p_tea_information1              in varchar2,
	p_tea_information2              in varchar2,
	p_tea_information3              in varchar2,
	p_tea_information4              in varchar2,
	p_tea_information5              in varchar2,
	p_tea_information6              in varchar2,
	p_tea_information7              in varchar2,
	p_tea_information8              in varchar2,
	p_tea_information9              in varchar2,
	p_tea_information10             in varchar2,
	p_tea_information11             in varchar2,
	p_tea_information12             in varchar2,
	p_tea_information13             in varchar2,
	p_tea_information14             in varchar2,
	p_tea_information15             in varchar2,
	p_tea_information16             in varchar2,
	p_tea_information17             in varchar2,
	p_tea_information18             in varchar2,
	p_tea_information19             in varchar2,
	p_tea_information20             in varchar2
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
  l_rec.event_association_id             := p_event_association_id;
  l_rec.event_id                         := p_event_id;
  l_rec.customer_id                      := p_customer_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.job_id                           := p_job_id;
  l_rec.position_id                      := p_position_id;
  l_rec.comments                         := p_comments;
  l_rec.tea_information_category         := p_tea_information_category;
  l_rec.tea_information1                 := p_tea_information1;
  l_rec.tea_information2                 := p_tea_information2;
  l_rec.tea_information3                 := p_tea_information3;
  l_rec.tea_information4                 := p_tea_information4;
  l_rec.tea_information5                 := p_tea_information5;
  l_rec.tea_information6                 := p_tea_information6;
  l_rec.tea_information7                 := p_tea_information7;
  l_rec.tea_information8                 := p_tea_information8;
  l_rec.tea_information9                 := p_tea_information9;
  l_rec.tea_information10                := p_tea_information10;
  l_rec.tea_information11                := p_tea_information11;
  l_rec.tea_information12                := p_tea_information12;
  l_rec.tea_information13                := p_tea_information13;
  l_rec.tea_information14                := p_tea_information14;
  l_rec.tea_information15                := p_tea_information15;
  l_rec.tea_information16                := p_tea_information16;
  l_rec.tea_information17                := p_tea_information17;
  l_rec.tea_information18                := p_tea_information18;
  l_rec.tea_information19                := p_tea_information19;
  l_rec.tea_information20                := p_tea_information20;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ota_tea_shd;

/
