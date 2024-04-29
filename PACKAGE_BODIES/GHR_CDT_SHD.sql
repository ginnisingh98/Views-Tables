--------------------------------------------------------
--  DDL for Package Body GHR_CDT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CDT_SHD" as
/* $Header: ghcdtrhi.pkb 115.4 2003/01/30 19:25:13 asubrahm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_cdt_shd.';  -- Global package name
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
  If (p_constraint_name = 'GHR_COMPL_CA_DETAILS_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'GHR_COMPL_CA_DETAILS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
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
  (p_compl_ca_detail_id                   in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       compl_ca_detail_id
      ,compl_ca_header_id
      --,action
      ,amount
      ,order_date
      ,due_date
      ,request_date
      ,complete_date
      ,category
      --,type
      ,phase
      ,action_type
      ,payment_type
      ,object_version_number
      ,description
    from        ghr_compl_ca_details
    where       compl_ca_detail_id = p_compl_ca_detail_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_compl_ca_detail_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_compl_ca_detail_id
        = ghr_cdt_shd.g_old_rec.compl_ca_detail_id and
        p_object_version_number
        = ghr_cdt_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ghr_cdt_shd.g_old_rec;
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
          <> ghr_cdt_shd.g_old_rec.object_version_number) Then
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
  (p_compl_ca_detail_id                   in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       compl_ca_detail_id
      ,compl_ca_header_id
      --,action
      ,amount
      ,order_date
      ,due_date
      ,request_date
      ,complete_date
      ,category
      --,type
      ,phase
      ,action_type
      ,payment_type
      ,object_version_number
      ,description
    from        ghr_compl_ca_details
    where       compl_ca_detail_id = p_compl_ca_detail_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'COMPL_CA_DETAIL_ID'
    ,p_argument_value     => p_compl_ca_detail_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ghr_cdt_shd.g_old_rec;
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
      <> ghr_cdt_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ghr_compl_ca_details');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_compl_ca_detail_id             in number
  ,p_compl_ca_header_id             in number
  --,p_action                         in varchar2
  ,p_amount                         in number
  ,p_order_date                     in date
  ,p_due_date                       in date
  ,p_request_date                   in date
  ,p_complete_date                  in date
  ,p_category                       in varchar2
  --,p_type                           in varchar2
  ,p_phase                          in varchar2
  ,p_action_type                    in varchar2
  ,p_payment_type                   in varchar2
  ,p_object_version_number          in number
  ,p_description                    in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.compl_ca_detail_id               := p_compl_ca_detail_id;
  l_rec.compl_ca_header_id               := p_compl_ca_header_id;
  --l_rec.action                           := p_action;
  l_rec.amount                           := p_amount;
  l_rec.order_date                       := p_order_date;
  l_rec.due_date                         := p_due_date;
  l_rec.request_date                     := p_request_date;
  l_rec.complete_date                    := p_complete_date;
  l_rec.category                         := p_category;
  --l_rec.type                             := p_type;
  l_rec.phase                            := p_phase;
  l_rec.action_type                      := p_action_type;
  l_rec.payment_type                     := p_payment_type;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.description                      := p_description;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ghr_cdt_shd;

/
