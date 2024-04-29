--------------------------------------------------------
--  DDL for Package Body OTA_OFF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OFF_SHD" as
/* $Header: otoffrhi.pkb 120.1.12000000.2 2007/02/06 15:25:23 vkkolla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_off_shd.';  -- Global package name

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
  If (p_constraint_name = 'OTA_OFFERINGS_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_OFFERINGS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_OFF_MAX_ATTENDEES_POSITIVE') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_OFF_MAX_INTERNALS_POSITIVE') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_OFF_MAX_INTERNAL_MAX_ORDER') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_OFF_MIN_ATTENDEES_POSITIVE') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','30');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_OFF_MIN_MAX_ORDER') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','35');
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
  (p_offering_id                          in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       ota_offerings.offering_id
      ,activity_version_id
      ,business_group_id

      ,start_date
      ,end_date
      ,owner_id
      ,delivery_mode_id
      ,language_id
      ,duration
      ,duration_units
      ,learning_object_id
      ,player_toolbar_flag
      ,player_toolbar_bitset
      ,player_new_window_flag
      ,maximum_attendees
      ,maximum_internal_attendees
      ,minimum_attendees
      ,actual_cost
      ,budget_cost
      ,budget_currency_code
      ,price_basis
      ,currency_code
      ,standard_price
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,data_source
      ,vendor_id
      ,competency_update_level
      ,language_code  -- 2733966
    from        ota_offerings
    where       ota_offerings.offering_id = p_offering_id;

  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_offering_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_offering_id
        = ota_off_shd.g_old_rec.offering_id and
        p_object_version_number
        = ota_off_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ota_off_shd.g_old_rec;
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
          <> ota_off_shd.g_old_rec.object_version_number) Then
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
  (p_offering_id                          in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       offering_id
      ,activity_version_id
      ,business_group_id

      ,start_date
      ,end_date
      ,owner_id
      ,delivery_mode_id
      ,language_id
      ,duration
      ,duration_units
      ,learning_object_id
      ,player_toolbar_flag
      ,player_toolbar_bitset
      ,player_new_window_flag
      ,maximum_attendees
      ,maximum_internal_attendees
      ,minimum_attendees
      ,actual_cost
      ,budget_cost
      ,budget_currency_code
      ,price_basis
      ,currency_code
      ,standard_price
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,data_source
      ,vendor_id
      ,competency_update_level
      ,language_code   -- 2733966
    from        ota_offerings
    where       offering_id = p_offering_id

    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OFFERING_ID'
    ,p_argument_value     => p_offering_id
    );
  hr_utility.set_location(l_proc,6);

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ota_off_shd.g_old_rec;
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
      <> ota_off_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ota_offerings');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_offering_id                    in number
  ,p_activity_version_id            in number
  ,p_business_group_id              in number
  ,p_offering_name                  in varchar2
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_owner_id                       in number
  ,p_delivery_mode_id               in number
  ,p_language_id                    in number
  ,p_duration                       in number
  ,p_duration_units                 in varchar2
  ,p_learning_object_id             in number
  ,p_player_toolbar_flag            in varchar2
  ,p_player_toolbar_bitset          in number
  ,p_player_new_window_flag         in varchar2
  ,p_maximum_attendees              in number
  ,p_maximum_internal_attendees     in number
  ,p_minimum_attendees              in number
  ,p_actual_cost                    in number
  ,p_budget_cost                    in number
  ,p_budget_currency_code           in varchar2
  ,p_price_basis                    in varchar2
  ,p_currency_code                  in varchar2
  ,p_standard_price                 in number
  ,p_object_version_number          in number
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_data_source                    in varchar2
  ,p_vendor_id                      in number
  ,p_competency_update_level      in     varchar2
  ,p_language_code                in     varchar2  -- 2733966
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.offering_id                      := p_offering_id;
  l_rec.activity_version_id              := p_activity_version_id;
  l_rec.business_group_id                := p_business_group_id;

  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.owner_id                         := p_owner_id;
  l_rec.delivery_mode_id                 := p_delivery_mode_id;
  l_rec.language_id                      := p_language_id;
  l_rec.duration                         := p_duration;
  l_rec.duration_units                   := p_duration_units;
  l_rec.learning_object_id               := p_learning_object_id;
  l_rec.player_toolbar_flag              := p_player_toolbar_flag;
  l_rec.player_toolbar_bitset            := p_player_toolbar_bitset;
  l_rec.player_new_window_flag           := p_player_new_window_flag;
  l_rec.maximum_attendees                := p_maximum_attendees;
  l_rec.maximum_internal_attendees       := p_maximum_internal_attendees;
  l_rec.minimum_attendees                := p_minimum_attendees;
  l_rec.actual_cost                      := p_actual_cost;
  l_rec.budget_cost                      := p_budget_cost;
  l_rec.budget_currency_code             := p_budget_currency_code;
  l_rec.price_basis                      := p_price_basis;
  l_rec.currency_code                    := p_currency_code;
  l_rec.standard_price                   := p_standard_price;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.data_source                      := p_data_source;
  l_rec.vendor_id                        := p_vendor_id;
  l_rec.competency_update_level      := p_competency_update_level;
  l_rec.language_code                := p_language_code; -- 2733966
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_off_shd;

/
