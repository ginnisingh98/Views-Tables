--------------------------------------------------------
--  DDL for Package Body OTA_RUD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RUD_SHD" as
/* $Header: otrudrhi.pkb 120.2 2005/09/08 06:34:32 pgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_rud_shd.';  -- Global package name
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
	hr_utility.set_location('Entering:'||l_proc, 5);
	--
	--	Key constraints
	--
	If (p_constraint_name = 'OTA_RESOURCE_USAGES_FK1') Then
		fnd_message.set_name  ('OTA', 'OTA_13202_GEN_INVALID_KEY');
		fnd_message.set_token ('COLUMN_NAME','SUPPLIED_RESOURCE_ID');
		fnd_message.set_token ('TABLE_NAME', 'OTA_SUPPLIABLE_RESOURCES');
		fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_RESOURCE_USAGES_FK2') Then
		fnd_message.set_name  ('OTA', 'OTA_13235_RUD_NO_ACTIVITY');
		fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_RESOURCE_USAGES_PK') Then
		fnd_message.set_name  ('OTA', 'OTA_13216_RUD_RESOURCE_UNIQUE');
		fnd_message.raise_error;
	--
	--	Check constraints
	--
	ElsIf (p_constraint_name = 'OTA_RUD_DATES') Then
		fnd_message.set_name  ('OTA', 'OTA_13312_GEN_DATE_ORDER');
		fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_RUD_EXCLUSIVITY') Then
		fnd_message.set_name  ('OTA', 'OTA_13253_RUD_EXCLUSIVITY');
		fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_RUD_REQUIRED_FLAG_CHK') Then
		hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    		hr_utility.set_message_token('PROCEDURE', l_proc);
    		hr_utility.set_message_token('STEP','30');
		hr_utility.raise_error;
	ElsIf (p_constraint_name = 'OTA_RUD_RESOURCE_ROLE') Then
		fnd_message.set_name  ('OTA', 'OTA_13254_RUD_RESOURCE_ROLE');
		fnd_message.raise_error;
	--
	--	Others, see below
	--
	elsif (p_constraint_name = 'OTA_RUD_NON_TRANSFER') then
		fnd_message.set_name  ('OTA', 'OTA_13633_RUD_NON_TRANSFER');
		fnd_message.raise_error;
	elsif (p_constraint_name = 'OTA_RUD_TAV_DATES') then
		fnd_message.set_name  ('OTA', 'OTA_13256_RUD_TAV_DATES');
		fnd_message.raise_error;
	elsif (p_constraint_name = 'OTA_RUD_TSR_DATES') then
		fnd_message.set_name  ('OTA', 'OTA_13257_RUD_TSR_DATES');
		fnd_message.raise_error;
	elsif (p_constraint_name = 'OTA_RUD_BUSINESS_GROUPS') then
		fnd_message.set_name  ('OTA', 'OTA_13247_RUD_SAME_BIZ_GROUP');
		fnd_message.raise_error;
	elsif (p_constraint_name = 'OTA_RUD_REQUIRED') then
		HR_UTILITY.SET_MESSAGE (801,'HR_7166_OBJECT_CHK_CONSTRAINT');
		HR_UTILITY.SET_MESSAGE_TOKEN ('CONSTRAINT_NAME', 'OTA_RUD_REQUIRED');
		HR_UTILITY.SET_MESSAGE_TOKEN ('TABLE_NAME', 'OTA_RESOURCE_USAGES');
		HR_UTILITY.raise_error;
	--
	--
	Else
		fnd_message.set_name  ('OTA', 'OTA_13259_GEN_UNKN_CONSTRAINT');
		fnd_message.set_token ('PROCEDURE', l_proc);
		fnd_message.set_token ('CONSTRAINT', p_constraint_name);
                fnd_message.raise_error;
	End If;
	--
	hr_utility.set_location(' Leaving:'||l_proc, 10);
	--
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_resource_usage_id                    in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       resource_usage_id
      ,supplied_resource_id
      ,activity_version_id
      ,object_version_number
      ,required_flag
      ,start_date
      ,comments
      ,end_date
      ,quantity
      ,resource_type
      ,role_to_play
      ,usage_reason
      ,rud_information_category
      ,rud_information1
      ,rud_information2
      ,rud_information3
      ,rud_information4
      ,rud_information5
      ,rud_information6
      ,rud_information7
      ,rud_information8
      ,rud_information9
      ,rud_information10
      ,rud_information11
      ,rud_information12
      ,rud_information13
      ,rud_information14
      ,rud_information15
      ,rud_information16
      ,rud_information17
      ,rud_information18
      ,rud_information19
      ,rud_information20
      ,offering_id
    from        ota_resource_usages
    where       resource_usage_id = p_resource_usage_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_resource_usage_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_resource_usage_id
        = ota_rud_shd.g_old_rec.resource_usage_id and
        p_object_version_number
        = ota_rud_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ota_rud_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> ota_rud_shd.g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
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
  (p_resource_usage_id                    in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	resource_usage_id,
	supplied_resource_id,
	activity_version_id,
	object_version_number,
	required_flag,
	start_date,
	comments,
	end_date,
	quantity,
	resource_type,
	role_to_play,
	usage_reason,
	rud_information_category,
	rud_information1,
	rud_information2,
	rud_information3,
	rud_information4,
	rud_information5,
	rud_information6,
	rud_information7,
	rud_information8,
	rud_information9,
	rud_information10,
	rud_information11,
	rud_information12,
	rud_information13,
	rud_information14,
	rud_information15,
	rud_information16,
	rud_information17,
	rud_information18,
	rud_information19,
	rud_information20,
    offering_id
    from	ota_resource_usages
    where	resource_usage_id = p_resource_usage_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_resource_usages');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_resource_usage_id              in number
  ,p_supplied_resource_id           in number
  ,p_activity_version_id            in number
  ,p_object_version_number          in number
  ,p_required_flag                  in varchar2
  ,p_start_date                     in date
  ,p_comments                       in varchar2
  ,p_end_date                       in date
  ,p_quantity                       in number
  ,p_resource_type                  in varchar2
  ,p_role_to_play                   in varchar2
  ,p_usage_reason                   in varchar2
  ,p_rud_information_category       in varchar2
  ,p_rud_information1               in varchar2
  ,p_rud_information2               in varchar2
  ,p_rud_information3               in varchar2
  ,p_rud_information4               in varchar2
  ,p_rud_information5               in varchar2
  ,p_rud_information6               in varchar2
  ,p_rud_information7               in varchar2
  ,p_rud_information8               in varchar2
  ,p_rud_information9               in varchar2
  ,p_rud_information10              in varchar2
  ,p_rud_information11              in varchar2
  ,p_rud_information12              in varchar2
  ,p_rud_information13              in varchar2
  ,p_rud_information14              in varchar2
  ,p_rud_information15              in varchar2
  ,p_rud_information16              in varchar2
  ,p_rud_information17              in varchar2
  ,p_rud_information18              in varchar2
  ,p_rud_information19              in varchar2
  ,p_rud_information20              in varchar2
  ,p_offering_id                    in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.resource_usage_id                := p_resource_usage_id;
  l_rec.supplied_resource_id             := p_supplied_resource_id;
  l_rec.activity_version_id              := p_activity_version_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.required_flag                    := p_required_flag;
  l_rec.start_date                       := p_start_date;
  l_rec.comments                         := p_comments;
  l_rec.end_date                         := p_end_date;
  l_rec.quantity                         := p_quantity;
  l_rec.resource_type                    := p_resource_type;
  l_rec.role_to_play                     := p_role_to_play;
  l_rec.usage_reason                     := p_usage_reason;
  l_rec.rud_information_category         := p_rud_information_category;
  l_rec.rud_information1                 := p_rud_information1;
  l_rec.rud_information2                 := p_rud_information2;
  l_rec.rud_information3                 := p_rud_information3;
  l_rec.rud_information4                 := p_rud_information4;
  l_rec.rud_information5                 := p_rud_information5;
  l_rec.rud_information6                 := p_rud_information6;
  l_rec.rud_information7                 := p_rud_information7;
  l_rec.rud_information8                 := p_rud_information8;
  l_rec.rud_information9                 := p_rud_information9;
  l_rec.rud_information10                := p_rud_information10;
  l_rec.rud_information11                := p_rud_information11;
  l_rec.rud_information12                := p_rud_information12;
  l_rec.rud_information13                := p_rud_information13;
  l_rec.rud_information14                := p_rud_information14;
  l_rec.rud_information15                := p_rud_information15;
  l_rec.rud_information16                := p_rud_information16;
  l_rec.rud_information17                := p_rud_information17;
  l_rec.rud_information18                := p_rud_information18;
  l_rec.rud_information19                := p_rud_information19;
  l_rec.rud_information20                := p_rud_information20;
  l_rec.offering_id                      := p_offering_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_rud_shd;

/
