--------------------------------------------------------
--  DDL for Package Body BEN_CSO_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CSO_SHD" as
/* $Header: becsorhi.pkb 115.0 2003/03/17 13:37:07 csundar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cso_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CWB_STOCK_OPTN_DTLS_PK') Then
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
  (p_cwb_stock_optn_dtls_id               in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       cwb_stock_optn_dtls_id
      ,grant_id
      ,grant_number
      ,grant_name
      ,grant_type
      ,grant_date
      ,grant_shares
      ,grant_price
      ,value_at_grant
      ,current_share_price
      ,current_shares_outstanding
      ,vested_shares
      ,unvested_shares
      ,exercisable_shares
      ,exercised_shares
      ,cancelled_shares
      ,trading_symbol
      ,expiration_date
      ,reason_code
      ,class
      ,misc
      ,employee_number
      ,person_id
      ,business_group_id
      ,prtt_rt_val_id
      ,object_version_number
      ,cso_attribute_category
      ,cso_attribute1
      ,cso_attribute2
      ,cso_attribute3
      ,cso_attribute4
      ,cso_attribute5
      ,cso_attribute6
      ,cso_attribute7
      ,cso_attribute8
      ,cso_attribute9
      ,cso_attribute10
      ,cso_attribute11
      ,cso_attribute12
      ,cso_attribute13
      ,cso_attribute14
      ,cso_attribute15
      ,cso_attribute16
      ,cso_attribute17
      ,cso_attribute18
      ,cso_attribute19
      ,cso_attribute20
      ,cso_attribute21
      ,cso_attribute22
      ,cso_attribute23
      ,cso_attribute24
      ,cso_attribute25
      ,cso_attribute26
      ,cso_attribute27
      ,cso_attribute28
      ,cso_attribute29
      ,cso_attribute30
    from        ben_cwb_stock_optn_dtls
    where       cwb_stock_optn_dtls_id = p_cwb_stock_optn_dtls_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_cwb_stock_optn_dtls_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cwb_stock_optn_dtls_id
        = ben_cso_shd.g_old_rec.cwb_stock_optn_dtls_id and
        p_object_version_number
        = ben_cso_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ben_cso_shd.g_old_rec;
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
          <> ben_cso_shd.g_old_rec.object_version_number) Then
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
  (p_cwb_stock_optn_dtls_id               in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       cwb_stock_optn_dtls_id
      ,grant_id
      ,grant_number
      ,grant_name
      ,grant_type
      ,grant_date
      ,grant_shares
      ,grant_price
      ,value_at_grant
      ,current_share_price
      ,current_shares_outstanding
      ,vested_shares
      ,unvested_shares
      ,exercisable_shares
      ,exercised_shares
      ,cancelled_shares
      ,trading_symbol
      ,expiration_date
      ,reason_code
      ,class
      ,misc
      ,employee_number
      ,person_id
      ,business_group_id
      ,prtt_rt_val_id
      ,object_version_number
      ,cso_attribute_category
      ,cso_attribute1
      ,cso_attribute2
      ,cso_attribute3
      ,cso_attribute4
      ,cso_attribute5
      ,cso_attribute6
      ,cso_attribute7
      ,cso_attribute8
      ,cso_attribute9
      ,cso_attribute10
      ,cso_attribute11
      ,cso_attribute12
      ,cso_attribute13
      ,cso_attribute14
      ,cso_attribute15
      ,cso_attribute16
      ,cso_attribute17
      ,cso_attribute18
      ,cso_attribute19
      ,cso_attribute20
      ,cso_attribute21
      ,cso_attribute22
      ,cso_attribute23
      ,cso_attribute24
      ,cso_attribute25
      ,cso_attribute26
      ,cso_attribute27
      ,cso_attribute28
      ,cso_attribute29
      ,cso_attribute30
    from        ben_cwb_stock_optn_dtls
    where       cwb_stock_optn_dtls_id = p_cwb_stock_optn_dtls_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CWB_STOCK_OPTN_DTLS_ID'
    ,p_argument_value     => p_cwb_stock_optn_dtls_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ben_cso_shd.g_old_rec;
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
      <> ben_cso_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ben_cwb_stock_optn_dtls');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_cwb_stock_optn_dtls_id         in number
  ,p_grant_id                       in number
  ,p_grant_number                   in varchar2
  ,p_grant_name                     in varchar2
  ,p_grant_type                     in varchar2
  ,p_grant_date                     in date
  ,p_grant_shares                   in number
  ,p_grant_price                    in number
  ,p_value_at_grant                 in number
  ,p_current_share_price            in number
  ,p_current_shares_outstanding     in number
  ,p_vested_shares                  in number
  ,p_unvested_shares                in number
  ,p_exercisable_shares             in number
  ,p_exercised_shares               in number
  ,p_cancelled_shares               in number
  ,p_trading_symbol                 in varchar2
  ,p_expiration_date                in date
  ,p_reason_code                    in varchar2
  ,p_class                          in varchar2
  ,p_misc                           in varchar2
  ,p_employee_number                in varchar2
  ,p_person_id                      in number
  ,p_business_group_id              in number
  ,p_prtt_rt_val_id                 in number
  ,p_object_version_number          in number
  ,p_cso_attribute_category         in varchar2
  ,p_cso_attribute1                 in varchar2
  ,p_cso_attribute2                 in varchar2
  ,p_cso_attribute3                 in varchar2
  ,p_cso_attribute4                 in varchar2
  ,p_cso_attribute5                 in varchar2
  ,p_cso_attribute6                 in varchar2
  ,p_cso_attribute7                 in varchar2
  ,p_cso_attribute8                 in varchar2
  ,p_cso_attribute9                 in varchar2
  ,p_cso_attribute10                in varchar2
  ,p_cso_attribute11                in varchar2
  ,p_cso_attribute12                in varchar2
  ,p_cso_attribute13                in varchar2
  ,p_cso_attribute14                in varchar2
  ,p_cso_attribute15                in varchar2
  ,p_cso_attribute16                in varchar2
  ,p_cso_attribute17                in varchar2
  ,p_cso_attribute18                in varchar2
  ,p_cso_attribute19                in varchar2
  ,p_cso_attribute20                in varchar2
  ,p_cso_attribute21                in varchar2
  ,p_cso_attribute22                in varchar2
  ,p_cso_attribute23                in varchar2
  ,p_cso_attribute24                in varchar2
  ,p_cso_attribute25                in varchar2
  ,p_cso_attribute26                in varchar2
  ,p_cso_attribute27                in varchar2
  ,p_cso_attribute28                in varchar2
  ,p_cso_attribute29                in varchar2
  ,p_cso_attribute30                in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.cwb_stock_optn_dtls_id           := p_cwb_stock_optn_dtls_id;
  l_rec.grant_id                         := p_grant_id;
  l_rec.grant_number                     := p_grant_number;
  l_rec.grant_name                       := p_grant_name;
  l_rec.grant_type                       := p_grant_type;
  l_rec.grant_date                       := p_grant_date;
  l_rec.grant_shares                     := p_grant_shares;
  l_rec.grant_price                      := p_grant_price;
  l_rec.value_at_grant                   := p_value_at_grant;
  l_rec.current_share_price              := p_current_share_price;
  l_rec.current_shares_outstanding       := p_current_shares_outstanding;
  l_rec.vested_shares                    := p_vested_shares;
  l_rec.unvested_shares                  := p_unvested_shares;
  l_rec.exercisable_shares               := p_exercisable_shares;
  l_rec.exercised_shares                 := p_exercised_shares;
  l_rec.cancelled_shares                 := p_cancelled_shares;
  l_rec.trading_symbol                   := p_trading_symbol;
  l_rec.expiration_date                  := p_expiration_date;
  l_rec.reason_code                      := p_reason_code;
  l_rec.class                            := p_class;
  l_rec.misc                             := p_misc;
  l_rec.employee_number                  := p_employee_number;
  l_rec.person_id                        := p_person_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.prtt_rt_val_id                   := p_prtt_rt_val_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.cso_attribute_category           := p_cso_attribute_category;
  l_rec.cso_attribute1                   := p_cso_attribute1;
  l_rec.cso_attribute2                   := p_cso_attribute2;
  l_rec.cso_attribute3                   := p_cso_attribute3;
  l_rec.cso_attribute4                   := p_cso_attribute4;
  l_rec.cso_attribute5                   := p_cso_attribute5;
  l_rec.cso_attribute6                   := p_cso_attribute6;
  l_rec.cso_attribute7                   := p_cso_attribute7;
  l_rec.cso_attribute8                   := p_cso_attribute8;
  l_rec.cso_attribute9                   := p_cso_attribute9;
  l_rec.cso_attribute10                  := p_cso_attribute10;
  l_rec.cso_attribute11                  := p_cso_attribute11;
  l_rec.cso_attribute12                  := p_cso_attribute12;
  l_rec.cso_attribute13                  := p_cso_attribute13;
  l_rec.cso_attribute14                  := p_cso_attribute14;
  l_rec.cso_attribute15                  := p_cso_attribute15;
  l_rec.cso_attribute16                  := p_cso_attribute16;
  l_rec.cso_attribute17                  := p_cso_attribute17;
  l_rec.cso_attribute18                  := p_cso_attribute18;
  l_rec.cso_attribute19                  := p_cso_attribute19;
  l_rec.cso_attribute20                  := p_cso_attribute20;
  l_rec.cso_attribute21                  := p_cso_attribute21;
  l_rec.cso_attribute22                  := p_cso_attribute22;
  l_rec.cso_attribute23                  := p_cso_attribute23;
  l_rec.cso_attribute24                  := p_cso_attribute24;
  l_rec.cso_attribute25                  := p_cso_attribute25;
  l_rec.cso_attribute26                  := p_cso_attribute26;
  l_rec.cso_attribute27                  := p_cso_attribute27;
  l_rec.cso_attribute28                  := p_cso_attribute28;
  l_rec.cso_attribute29                  := p_cso_attribute29;
  l_rec.cso_attribute30                  := p_cso_attribute30;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ben_cso_shd;

/
