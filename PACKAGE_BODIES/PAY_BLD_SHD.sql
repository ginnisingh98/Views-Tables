--------------------------------------------------------
--  DDL for Package Body PAY_BLD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BLD_SHD" as
/* $Header: pybldrhi.pkb 120.0 2005/05/29 03:19:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_bld_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_BALANCE_DIMENSIONS_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BALANCE_DIMENSIONS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BALANCE_DIMENSIONS_UK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BDIM_DIMENSION_TYPE_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BDIM_EXPIRY_CHECKING_L_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BDIM_FEED_CHECKING_TYP_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','30');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BDIM_PAYMENTS_FLAG_CHK') Then
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
  (p_balance_dimension_id                 in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       balance_dimension_id
      ,business_group_id
      ,legislation_code
      ,route_id
      ,database_item_suffix
      ,dimension_name
      ,dimension_type
      ,description
      ,feed_checking_code
      ,legislation_subgroup
      ,payments_flag
      ,expiry_checking_code
      ,expiry_checking_level
      ,feed_checking_type
      ,dimension_level
      ,period_type
      ,asg_action_balance_dim_id
      ,database_item_function
      ,save_run_balance_enabled
      ,start_date_code
    from        pay_balance_dimensions
    where       balance_dimension_id = p_balance_dimension_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_balance_dimension_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_balance_dimension_id
        = pay_bld_shd.g_old_rec.balance_dimension_id
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
      Fetch C_Sel1 Into pay_bld_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      --
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
  (p_balance_dimension_id                 in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       balance_dimension_id
      ,business_group_id
      ,legislation_code
      ,route_id
      ,database_item_suffix
      ,dimension_name
      ,dimension_type
      ,description
      ,feed_checking_code
      ,legislation_subgroup
      ,payments_flag
      ,expiry_checking_code
      ,expiry_checking_level
      ,feed_checking_type
      ,dimension_level
      ,period_type
      ,asg_action_balance_dim_id
      ,database_item_function
      ,save_run_balance_enabled
      ,start_date_code
    from        pay_balance_dimensions
    where       balance_dimension_id = p_balance_dimension_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'BALANCE_DIMENSION_ID'
    ,p_argument_value     => p_balance_dimension_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_bld_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
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
    fnd_message.set_token('TABLE_NAME', 'pay_balance_dimensions');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_balance_dimension_id           in number
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_route_id                       in number
  ,p_database_item_suffix           in varchar2
  ,p_dimension_name                 in varchar2
  ,p_dimension_type                 in varchar2
  ,p_description                    in varchar2
  ,p_feed_checking_code             in varchar2
  ,p_legislation_subgroup           in varchar2
  ,p_payments_flag                  in varchar2
  ,p_expiry_checking_code           in varchar2
  ,p_expiry_checking_level          in varchar2
  ,p_feed_checking_type             in varchar2
  ,p_dimension_level                in varchar2
  ,p_period_type                    in varchar2
  ,p_asg_action_balance_dim_id      in number
  ,p_database_item_function         in varchar2
  ,p_save_run_balance_enabled       in varchar2
  ,p_start_date_code                in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.balance_dimension_id             := p_balance_dimension_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.route_id                         := p_route_id;
  l_rec.database_item_suffix             := p_database_item_suffix;
  l_rec.dimension_name                   := p_dimension_name;
  l_rec.dimension_type                   := p_dimension_type;
  l_rec.description                      := p_description;
  l_rec.feed_checking_code               := p_feed_checking_code;
  l_rec.legislation_subgroup             := p_legislation_subgroup;
  l_rec.payments_flag                    := p_payments_flag;
  l_rec.expiry_checking_code             := p_expiry_checking_code;
  l_rec.expiry_checking_level            := p_expiry_checking_level;
  l_rec.feed_checking_type               := p_feed_checking_type;
  l_rec.dimension_level                  := p_dimension_level;
  l_rec.period_type                      := p_period_type;
  l_rec.asg_action_balance_dim_id        := p_asg_action_balance_dim_id;
  l_rec.database_item_function           := p_database_item_function;
  l_rec.save_run_balance_enabled         := p_save_run_balance_enabled;
  l_rec.start_date_code                  := p_start_date_code;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_bld_shd;

/
