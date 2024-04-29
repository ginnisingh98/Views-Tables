--------------------------------------------------------
--  DDL for Package Body OTA_ACI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ACI_SHD" as
/* $Header: otacirhi.pkb 120.0 2005/05/29 06:51:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_aci_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_ACT_CAT_ACTIVE_DATE_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_ACT_CAT_INCLUSIONS_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_ACT_CAT_INCLUSIONS_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_ACT_CAT_INCLUSIONS_UK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
/*
  ElsIf (p_constraint_name = 'OTA_ACT_CAT_INCL_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
 */
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
  (p_activity_version_id                  in     number
  ,p_category_usage_id                    in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       activity_version_id
      ,activity_category
      ,object_version_number
      ,event_id
      ,comments
      ,aci_information_category
      ,aci_information1
      ,aci_information2
      ,aci_information3
      ,aci_information4
      ,aci_information5
      ,aci_information6
      ,aci_information7
      ,aci_information8
      ,aci_information9
      ,aci_information10
      ,aci_information11
      ,aci_information12
      ,aci_information13
      ,aci_information14
      ,aci_information15
      ,aci_information16
      ,aci_information17
      ,aci_information18
      ,aci_information19
      ,aci_information20
      ,start_date_active
      ,end_date_active
      ,primary_flag
      ,category_usage_id
    from        ota_act_cat_inclusions
    where       activity_version_id = p_activity_version_id
    and   category_usage_id = p_category_usage_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_activity_version_id is null and
      p_object_version_number is null and
      p_category_usage_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_activity_version_id
        = ota_aci_shd.g_old_rec.activity_version_id and
        p_object_version_number
        = ota_aci_shd.g_old_rec.object_version_number and
        p_category_usage_id
        = ota_aci_shd.g_old_rec.category_usage_id
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
      Fetch C_Sel1 Into ota_aci_shd.g_old_rec;
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
          <> ota_aci_shd.g_old_rec.object_version_number) Then
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
  (p_activity_version_id                  in     number
  ,p_category_usage_id                    in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       activity_version_id
      ,activity_category
      ,object_version_number
      ,event_id
      ,comments
      ,aci_information_category
      ,aci_information1
      ,aci_information2
      ,aci_information3
      ,aci_information4
      ,aci_information5
      ,aci_information6
      ,aci_information7
      ,aci_information8
      ,aci_information9
      ,aci_information10
      ,aci_information11
      ,aci_information12
      ,aci_information13
      ,aci_information14
      ,aci_information15
      ,aci_information16
      ,aci_information17
      ,aci_information18
      ,aci_information19
      ,aci_information20
      ,start_date_active
      ,end_date_active
      ,primary_flag
      ,category_usage_id
    from        ota_act_cat_inclusions
    where       activity_version_id = p_activity_version_id
    and   category_usage_id = p_category_usage_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ACTIVITY_VERSION_ID'
    ,p_argument_value     => p_activity_version_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  hr_utility.set_location(l_proc,7);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CATEGORY_USAGE_ID'
    ,p_argument_value     => p_category_usage_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ota_aci_shd.g_old_rec;
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
      <> ota_aci_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ota_act_cat_inclusions');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_activity_version_id            in number
  ,p_activity_category              in varchar2
  ,p_object_version_number          in number
  ,p_event_id                       in number
  ,p_comments                       in varchar2
  ,p_aci_information_category       in varchar2
  ,p_aci_information1               in varchar2
  ,p_aci_information2               in varchar2
  ,p_aci_information3               in varchar2
  ,p_aci_information4               in varchar2
  ,p_aci_information5               in varchar2
  ,p_aci_information6               in varchar2
  ,p_aci_information7               in varchar2
  ,p_aci_information8               in varchar2
  ,p_aci_information9               in varchar2
  ,p_aci_information10              in varchar2
  ,p_aci_information11              in varchar2
  ,p_aci_information12              in varchar2
  ,p_aci_information13              in varchar2
  ,p_aci_information14              in varchar2
  ,p_aci_information15              in varchar2
  ,p_aci_information16              in varchar2
  ,p_aci_information17              in varchar2
  ,p_aci_information18              in varchar2
  ,p_aci_information19              in varchar2
  ,p_aci_information20              in varchar2
  ,p_start_date_active              in date
  ,p_end_date_active                in date
  ,p_primary_flag                   in varchar2
  ,p_category_usage_id              in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.activity_version_id              := p_activity_version_id;
  l_rec.activity_category                := p_activity_category;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.event_id                         := p_event_id;
  l_rec.comments                         := p_comments;
  l_rec.aci_information_category         := p_aci_information_category;
  l_rec.aci_information1                 := p_aci_information1;
  l_rec.aci_information2                 := p_aci_information2;
  l_rec.aci_information3                 := p_aci_information3;
  l_rec.aci_information4                 := p_aci_information4;
  l_rec.aci_information5                 := p_aci_information5;
  l_rec.aci_information6                 := p_aci_information6;
  l_rec.aci_information7                 := p_aci_information7;
  l_rec.aci_information8                 := p_aci_information8;
  l_rec.aci_information9                 := p_aci_information9;
  l_rec.aci_information10                := p_aci_information10;
  l_rec.aci_information11                := p_aci_information11;
  l_rec.aci_information12                := p_aci_information12;
  l_rec.aci_information13                := p_aci_information13;
  l_rec.aci_information14                := p_aci_information14;
  l_rec.aci_information15                := p_aci_information15;
  l_rec.aci_information16                := p_aci_information16;
  l_rec.aci_information17                := p_aci_information17;
  l_rec.aci_information18                := p_aci_information18;
  l_rec.aci_information19                := p_aci_information19;
  l_rec.aci_information20                := p_aci_information20;
  l_rec.start_date_active                := p_start_date_active;
  l_rec.end_date_active                  := p_end_date_active;
  l_rec.primary_flag                     := p_primary_flag;
  l_rec.category_usage_id                := p_category_usage_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_aci_shd;

/
