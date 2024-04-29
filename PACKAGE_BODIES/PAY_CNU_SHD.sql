--------------------------------------------------------
--  DDL for Package Body PAY_CNU_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CNU_SHD" as
/* $Header: pycnurhi.pkb 120.0 2005/05/29 04:04:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_cnu_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PAY_FR_CONTRIBUTION_USAGES_FK1') Then
    fnd_message.set_name('PAY', 'PAY_74895_CNU_BAD_BG');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_FR_CONTRIBUTION_USAGES_UK1') Then
    fnd_message.set_name('PAY', 'PAY_74896_CNU_UNIQUE_VALUES');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_FR_CONTRIBUTION_USAG_PK') Then
    fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
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
  (p_contribution_usage_id                in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       contribution_usage_id
      ,date_from
      ,date_to
      ,group_code
      ,process_type
      ,element_name
      ,rate_type
      ,contribution_code
      ,retro_contribution_code
      ,contribution_type
      ,contribution_usage_type
      ,rate_category
      ,business_group_id
      ,object_version_number
      ,code_Rate_id
    from	pay_fr_contribution_usages
    where	contribution_usage_id = p_contribution_usage_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_contribution_usage_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_contribution_usage_id
        = pay_cnu_shd.g_old_rec.contribution_usage_id and
        p_object_version_number
        = pay_cnu_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_cnu_shd.g_old_rec;
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
          <> pay_cnu_shd.g_old_rec.object_version_number) Then
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
  (p_contribution_usage_id                in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       contribution_usage_id
      ,date_from
      ,date_to
      ,group_code
      ,process_type
      ,element_name
      ,rate_type
      ,contribution_code
      ,retro_contribution_code
      ,contribution_type
      ,contribution_usage_type
      ,rate_category
      ,business_group_id
      ,object_version_number
	  ,code_rate_id
    from	pay_fr_contribution_usages
    where	contribution_usage_id = p_contribution_usage_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CONTRIBUTION_USAGE_ID'
    ,p_argument_value     => p_contribution_usage_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_cnu_shd.g_old_rec;
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
      <> pay_cnu_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pay_fr_contribution_usages');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_contribution_usage_id          in number
  ,p_date_from                      in date
  ,p_date_to                        in date
  ,p_group_code                     in varchar2
  ,p_process_type                   in varchar2
  ,p_element_name                   in varchar2
  ,p_rate_type                      in varchar2
  ,p_contribution_code              in varchar2
  ,p_retro_contribution_code        in varchar2
  ,p_contribution_type              in varchar2
  ,p_contribution_usage_type        in varchar2
  ,p_rate_category                  in varchar2
  ,p_business_group_id              in number
  ,p_object_version_number          in number
  ,p_code_rate_id                   in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.contribution_usage_id            := p_contribution_usage_id;
  l_rec.date_from                        := p_date_from;
  l_rec.date_to                          := p_date_to;
  l_rec.group_code                       := p_group_code;
  l_rec.process_type                     := p_process_type;
  l_rec.element_name                     := p_element_name;
  l_rec.rate_type                        := p_rate_type;
  l_rec.contribution_code                := p_contribution_code;
  l_rec.retro_contribution_code          := p_retro_contribution_code;
  l_rec.contribution_type                := p_contribution_type;
  l_rec.contribution_usage_type          := p_contribution_usage_type;
  l_rec.rate_category                    := p_rate_category;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.code_rate_id                     := p_code_Rate_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_cnu_shd;

/
