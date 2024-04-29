--------------------------------------------------------
--  DDL for Package Body PQP_EXR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EXR_SHD" as
/* $Header: pqexrrhi.pkb 120.4 2006/10/20 18:38:32 sshetty noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_exr_shd.';  -- Global package name
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
  If (p_constraint_name = 'PET_PK') Then
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
  (p_exception_report_id                  in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       exception_report_id
      ,exception_report_name
      ,legislation_code
      ,business_group_id
      ,currency_code
      ,balance_type_id
      ,balance_dimension_id
      ,variance_type
      ,variance_value
      ,comparison_type
      ,comparison_value
      ,object_version_number
      ,output_format
      ,variance_operator
    from        pqp_exception_reports
    where       exception_report_id = p_exception_report_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_exception_report_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_exception_report_id
        = pqp_exr_shd.g_old_rec.exception_report_id and
        p_object_version_number
        = pqp_exr_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqp_exr_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
       IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
       END IF;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> pqp_exr_shd.g_old_rec.object_version_number) Then
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
  (p_exception_report_id                  in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       exception_report_id
      ,exception_report_name
      ,legislation_code
      ,business_group_id
      ,currency_code
      ,balance_type_id
      ,balance_dimension_id
      ,variance_type
      ,variance_value
      ,comparison_type
      ,comparison_value
      ,object_version_number
      ,output_format
      ,variance_operator

    from        pqp_exception_reports
    where       exception_report_id = p_exception_report_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EXCEPTION_REPORT_ID'
    ,p_argument_value     => p_exception_report_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqp_exr_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
   IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
   END IF;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> pqp_exr_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqp_exception_reports');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_exception_report_id            in number
  ,p_exception_report_name          in varchar2
  ,p_legislation_code               in varchar2
  ,p_business_group_id              in number
  ,p_currency_code                  in varchar2
  ,p_balance_type_id                in number
  ,p_balance_dimension_id           in number
  ,p_variance_type                  in varchar2
  ,p_variance_value                 in number
  ,p_comparison_type                in varchar2
  ,p_comparison_value               in number
  ,p_object_version_number          in number
  ,p_output_format_type             in varchar2
  ,p_variance_operator              in varchar2

  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--

Begin

  --

  -- Convert arguments into local l_rec structure.

  --

  l_rec.exception_report_id              := p_exception_report_id;

  l_rec.exception_report_name            := p_exception_report_name;

  l_rec.legislation_code                 := p_legislation_code;

  l_rec.business_group_id                := p_business_group_id;

  l_rec.currency_code                    := p_currency_code;
  l_rec.balance_type_id                  := p_balance_type_id;
  l_rec.balance_dimension_id             := p_balance_dimension_id;
  l_rec.variance_type                    := p_variance_type;
  l_rec.variance_value                   := p_variance_value;
  l_rec.comparison_type                  := p_comparison_type;
  l_rec.comparison_value                 := p_comparison_value;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.output_format_type               := p_output_format_type;
  l_rec.variance_operator                := p_variance_operator;
   --
  -- Return the plsql record structure.
  Return(l_rec);
  --
End convert_args;

--

end pqp_exr_shd;


/
