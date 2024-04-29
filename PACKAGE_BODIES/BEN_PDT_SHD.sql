--------------------------------------------------------
--  DDL for Package Body BEN_PDT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PDT_SHD" as
/* $Header: bepdtrhi.pkb 115.0 2003/10/30 09:33 rpillay noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pdt_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PYMT_CHECK_DET_PK') Then
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
  (p_pymt_check_det_id                    in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       pymt_check_det_id
      ,person_id
      ,business_group_id
      ,check_num
      ,pymt_dt
      ,pymt_amt
      ,pdt_attribute_category
      ,pdt_attribute1
      ,pdt_attribute2
      ,pdt_attribute3
      ,pdt_attribute4
      ,pdt_attribute5
      ,pdt_attribute6
      ,pdt_attribute7
      ,pdt_attribute8
      ,pdt_attribute9
      ,pdt_attribute10
      ,pdt_attribute11
      ,pdt_attribute12
      ,pdt_attribute13
      ,pdt_attribute14
      ,pdt_attribute15
      ,pdt_attribute16
      ,pdt_attribute17
      ,pdt_attribute18
      ,pdt_attribute19
      ,pdt_attribute20
      ,pdt_attribute21
      ,pdt_attribute22
      ,pdt_attribute23
      ,pdt_attribute24
      ,pdt_attribute25
      ,pdt_attribute26
      ,pdt_attribute27
      ,pdt_attribute28
      ,pdt_attribute29
      ,pdt_attribute30
      ,object_version_number
    from        ben_pymt_check_det
    where       pymt_check_det_id = p_pymt_check_det_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_pymt_check_det_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_pymt_check_det_id
        = ben_pdt_shd.g_old_rec.pymt_check_det_id and
        p_object_version_number
        = ben_pdt_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ben_pdt_shd.g_old_rec;
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
          <> ben_pdt_shd.g_old_rec.object_version_number) Then
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
  (p_pymt_check_det_id                    in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       pymt_check_det_id
      ,person_id
      ,business_group_id
      ,check_num
      ,pymt_dt
      ,pymt_amt
      ,pdt_attribute_category
      ,pdt_attribute1
      ,pdt_attribute2
      ,pdt_attribute3
      ,pdt_attribute4
      ,pdt_attribute5
      ,pdt_attribute6
      ,pdt_attribute7
      ,pdt_attribute8
      ,pdt_attribute9
      ,pdt_attribute10
      ,pdt_attribute11
      ,pdt_attribute12
      ,pdt_attribute13
      ,pdt_attribute14
      ,pdt_attribute15
      ,pdt_attribute16
      ,pdt_attribute17
      ,pdt_attribute18
      ,pdt_attribute19
      ,pdt_attribute20
      ,pdt_attribute21
      ,pdt_attribute22
      ,pdt_attribute23
      ,pdt_attribute24
      ,pdt_attribute25
      ,pdt_attribute26
      ,pdt_attribute27
      ,pdt_attribute28
      ,pdt_attribute29
      ,pdt_attribute30
      ,object_version_number
    from        ben_pymt_check_det
    where       pymt_check_det_id = p_pymt_check_det_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'PYMT_CHECK_DET_ID'
    ,p_argument_value     => p_pymt_check_det_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_pdt_shd.g_old_rec;
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
      <> ben_pdt_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ben_pymt_check_det');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_pymt_check_det_id              in number
  ,p_person_id                      in number
  ,p_business_group_id              in number
  ,p_check_num                      in varchar2
  ,p_pymt_dt                        in date
  ,p_pymt_amt                       in number
  ,p_pdt_attribute_category         in varchar2
  ,p_pdt_attribute1                 in varchar2
  ,p_pdt_attribute2                 in varchar2
  ,p_pdt_attribute3                 in varchar2
  ,p_pdt_attribute4                 in varchar2
  ,p_pdt_attribute5                 in varchar2
  ,p_pdt_attribute6                 in varchar2
  ,p_pdt_attribute7                 in varchar2
  ,p_pdt_attribute8                 in varchar2
  ,p_pdt_attribute9                 in varchar2
  ,p_pdt_attribute10                in varchar2
  ,p_pdt_attribute11                in varchar2
  ,p_pdt_attribute12                in varchar2
  ,p_pdt_attribute13                in varchar2
  ,p_pdt_attribute14                in varchar2
  ,p_pdt_attribute15                in varchar2
  ,p_pdt_attribute16                in varchar2
  ,p_pdt_attribute17                in varchar2
  ,p_pdt_attribute18                in varchar2
  ,p_pdt_attribute19                in varchar2
  ,p_pdt_attribute20                in varchar2
  ,p_pdt_attribute21                in varchar2
  ,p_pdt_attribute22                in varchar2
  ,p_pdt_attribute23                in varchar2
  ,p_pdt_attribute24                in varchar2
  ,p_pdt_attribute25                in varchar2
  ,p_pdt_attribute26                in varchar2
  ,p_pdt_attribute27                in varchar2
  ,p_pdt_attribute28                in varchar2
  ,p_pdt_attribute29                in varchar2
  ,p_pdt_attribute30                in varchar2
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
  l_rec.pymt_check_det_id                := p_pymt_check_det_id;
  l_rec.person_id                        := p_person_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.check_num                        := p_check_num;
  l_rec.pymt_dt                          := p_pymt_dt;
  l_rec.pymt_amt                         := p_pymt_amt;
  l_rec.pdt_attribute_category           := p_pdt_attribute_category;
  l_rec.pdt_attribute1                   := p_pdt_attribute1;
  l_rec.pdt_attribute2                   := p_pdt_attribute2;
  l_rec.pdt_attribute3                   := p_pdt_attribute3;
  l_rec.pdt_attribute4                   := p_pdt_attribute4;
  l_rec.pdt_attribute5                   := p_pdt_attribute5;
  l_rec.pdt_attribute6                   := p_pdt_attribute6;
  l_rec.pdt_attribute7                   := p_pdt_attribute7;
  l_rec.pdt_attribute8                   := p_pdt_attribute8;
  l_rec.pdt_attribute9                   := p_pdt_attribute9;
  l_rec.pdt_attribute10                  := p_pdt_attribute10;
  l_rec.pdt_attribute11                  := p_pdt_attribute11;
  l_rec.pdt_attribute12                  := p_pdt_attribute12;
  l_rec.pdt_attribute13                  := p_pdt_attribute13;
  l_rec.pdt_attribute14                  := p_pdt_attribute14;
  l_rec.pdt_attribute15                  := p_pdt_attribute15;
  l_rec.pdt_attribute16                  := p_pdt_attribute16;
  l_rec.pdt_attribute17                  := p_pdt_attribute17;
  l_rec.pdt_attribute18                  := p_pdt_attribute18;
  l_rec.pdt_attribute19                  := p_pdt_attribute19;
  l_rec.pdt_attribute20                  := p_pdt_attribute20;
  l_rec.pdt_attribute21                  := p_pdt_attribute21;
  l_rec.pdt_attribute22                  := p_pdt_attribute22;
  l_rec.pdt_attribute23                  := p_pdt_attribute23;
  l_rec.pdt_attribute24                  := p_pdt_attribute24;
  l_rec.pdt_attribute25                  := p_pdt_attribute25;
  l_rec.pdt_attribute26                  := p_pdt_attribute26;
  l_rec.pdt_attribute27                  := p_pdt_attribute27;
  l_rec.pdt_attribute28                  := p_pdt_attribute28;
  l_rec.pdt_attribute29                  := p_pdt_attribute29;
  l_rec.pdt_attribute30                  := p_pdt_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_pdt_shd;

/
