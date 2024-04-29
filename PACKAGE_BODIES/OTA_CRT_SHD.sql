--------------------------------------------------------
--  DDL for Package Body OTA_CRT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CRT_SHD" as
/* $Header: otcrtrhi.pkb 120.14 2006/03/17 14:54 cmora noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_crt_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_CERTIFICATIONS_B_PK') Then
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
  (p_certification_id                     in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       certification_id
      ,business_group_id
      ,public_flag
      ,initial_completion_date
      ,initial_completion_duration
      ,initial_compl_duration_units
      ,renewal_duration
      ,renewal_duration_units
      ,notify_days_before_expire
      ,object_version_number
      ,start_date_active
      ,end_date_active
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
      ,VALIDITY_DURATION
      ,VALIDITY_DURATION_UNITS
      ,RENEWABLE_FLAG
      ,VALIDITY_START_TYPE
      ,COMPETENCY_UPDATE_LEVEL
    from        ota_certifications_b
    where       certification_id = p_certification_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_certification_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_certification_id
        = ota_crt_shd.g_old_rec.certification_id and
        p_object_version_number
        = ota_crt_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ota_crt_shd.g_old_rec;
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
          <> ota_crt_shd.g_old_rec.object_version_number) Then
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
  (p_certification_id                     in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       certification_id
      ,business_group_id
      ,public_flag
      ,initial_completion_date
      ,initial_completion_duration
      ,initial_compl_duration_units
      ,renewal_duration
      ,renewal_duration_units
      ,notify_days_before_expire
      ,object_version_number
      ,start_date_active
      ,end_date_active
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
      ,VALIDITY_DURATION
      ,VALIDITY_DURATION_UNITS
      ,RENEWABLE_FLAG
      ,VALIDITY_START_TYPE
      ,COMPETENCY_UPDATE_LEVEL
    from        ota_certifications_b
    where       certification_id = p_certification_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CERTIFICATION_ID'
    ,p_argument_value     => p_certification_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ota_crt_shd.g_old_rec;
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
      <> ota_crt_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ota_certifications_b');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_certification_id               in number
  ,p_business_group_id              in number
  ,p_public_flag                    in varchar2
  ,p_initial_completion_date        in date
  ,p_initial_completion_duration    in number
  ,p_initial_compl_duration_units   in varchar2
  ,p_renewal_duration               in number
  ,p_renewal_duration_units         in varchar2
  ,p_notify_days_before_expire      in number
  ,p_object_version_number          in number
  ,p_start_date_active              in date
  ,p_end_date_active                in date
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
  ,p_VALIDITY_DURATION              in NUMBER
  ,p_VALIDITY_DURATION_UNITS        in VARCHAR2
  ,p_RENEWABLE_FLAG                 in VARCHAR2
  ,p_VALIDITY_START_TYPE            in VARCHAR2
  ,p_COMPETENCY_UPDATE_LEVEL        in VARCHAR2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.certification_id                 := p_certification_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.public_flag                      := p_public_flag;
  l_rec.initial_completion_date          := p_initial_completion_date;
  l_rec.initial_completion_duration      := p_initial_completion_duration;
  l_rec.initial_compl_duration_units     := p_initial_compl_duration_units;
  l_rec.renewal_duration                 := p_renewal_duration;
  l_rec.renewal_duration_units           := p_renewal_duration_units;
  l_rec.notify_days_before_expire        := p_notify_days_before_expire;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.start_date_active                := p_start_date_active;
  l_rec.end_date_active                  := p_end_date_active;
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
  l_rec.VALIDITY_DURATION                := p_VALIDITY_DURATION;
  l_rec.VALIDITY_DURATION_UNITS          := p_VALIDITY_DURATION_UNITS;
  l_rec.RENEWABLE_FLAG                   := p_RENEWABLE_FLAG;
  l_rec.VALIDITY_START_TYPE              := p_VALIDITY_START_TYPE;
  l_rec.COMPETENCY_UPDATE_LEVEL          := p_COMPETENCY_UPDATE_LEVEL;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_crt_shd;

/
