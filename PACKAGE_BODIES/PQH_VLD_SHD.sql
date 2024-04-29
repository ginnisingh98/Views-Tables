--------------------------------------------------------
--  DDL for Package Body PQH_VLD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_VLD_SHD" as
/* $Header: pqvldrhi.pkb 115.2 2002/12/13 00:33:20 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_vld_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_VLD_PK') Then
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
  (p_validation_id                        in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       validation_id
      ,pension_fund_type_code
      ,pension_fund_id
      ,business_group_id
      ,person_id
      ,request_date
      ,completion_date
      ,previous_employer_id
      ,previously_validated_flag
      ,status
      ,employer_amount
      ,employer_currency_code
      ,employee_amount
      ,employee_currency_code
      ,deduction_per_period
      ,deduction_currency_code
      ,percent_of_salary
      ,object_version_number
    from        pqh_fr_validations
    where       validation_id = p_validation_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_validation_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_validation_id
        = pqh_vld_shd.g_old_rec.validation_id and
        p_object_version_number
        = pqh_vld_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_vld_shd.g_old_rec;
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
          <> pqh_vld_shd.g_old_rec.object_version_number) Then
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
  (p_validation_id                        in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       validation_id
      ,pension_fund_type_code
      ,pension_fund_id
      ,business_group_id
      ,person_id
      ,request_date
      ,completion_date
      ,previous_employer_id
      ,previously_validated_flag
      ,status
      ,employer_amount
      ,employer_currency_code
      ,employee_amount
      ,employee_currency_code
      ,deduction_per_period
      ,deduction_currency_code
      ,percent_of_salary
      ,object_version_number
    from        pqh_fr_validations
    where       validation_id = p_validation_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'VALIDATION_ID'
    ,p_argument_value     => p_validation_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_vld_shd.g_old_rec;
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
      <> pqh_vld_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqh_fr_validations');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_validation_id                  in number
  ,p_pension_fund_type_code         in varchar2
  ,p_pension_fund_id                in number
  ,p_business_group_id              in number
  ,p_person_id                      in number
  ,p_request_date                   in date
  ,p_completion_date                in date
  ,p_previous_employer_id           in number
  ,p_previously_validated_flag      in varchar2
  ,p_status                         in varchar2
  ,p_employer_amount                in number
  ,p_employer_currency_code         in varchar2
  ,p_employee_amount                in number
  ,p_employee_currency_code         in varchar2
  ,p_deduction_per_period           in number
  ,p_deduction_currency_code        in varchar2
  ,p_percent_of_salary              in number
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
  l_rec.validation_id                    := p_validation_id;
  l_rec.pension_fund_type_code           := p_pension_fund_type_code;
  l_rec.pension_fund_id                  := p_pension_fund_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.person_id                        := p_person_id;
  l_rec.request_date                     := p_request_date;
  l_rec.completion_date                  := p_completion_date;
  l_rec.previous_employer_id             := p_previous_employer_id;
  l_rec.previously_validated_flag        := p_previously_validated_flag;
  l_rec.status                           := p_status;
  l_rec.employer_amount                  := p_employer_amount;
  l_rec.employer_currency_code           := p_employer_currency_code;
  l_rec.employee_amount                  := p_employee_amount;
  l_rec.employee_currency_code           := p_employee_currency_code;
  l_rec.deduction_per_period             := p_deduction_per_period;
  l_rec.deduction_currency_code          := p_deduction_currency_code;
  l_rec.percent_of_salary                := p_percent_of_salary;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_vld_shd;

/
