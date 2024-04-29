--------------------------------------------------------
--  DDL for Package Body PQH_VLP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_VLP_SHD" as
/* $Header: pqvlprhi.pkb 115.6 2004/03/31 00:31:40 kgowripe noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_vlp_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_VLP_FK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PQH_VLP_PK') Then
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
  (p_validation_period_id                 in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       validation_period_id
      ,validation_id
      ,start_date
      ,end_date
      ,previous_employer_id
      ,assignment_category
      ,normal_hours
      ,frequency
      ,period_years
      ,period_months
      ,period_days
      ,comments
      ,validation_status
      ,object_version_number
    from        pqh_fr_validation_periods
    where       validation_period_id = p_validation_period_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_validation_period_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_validation_period_id
        = pqh_vlp_shd.g_old_rec.validation_period_id and
        p_object_version_number
        = pqh_vlp_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_vlp_shd.g_old_rec;
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
          <> pqh_vlp_shd.g_old_rec.object_version_number) Then
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
  (p_validation_period_id                 in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       validation_period_id
      ,validation_id
      ,start_date
      ,end_date
      ,previous_employer_id
      ,assignment_category
      ,normal_hours
      ,frequency
      ,period_years
      ,period_months
      ,period_days
      ,comments
      ,validation_status
      ,object_version_number
    from        pqh_fr_validation_periods
    where       validation_period_id = p_validation_period_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'VALIDATION_PERIOD_ID'
    ,p_argument_value     => p_validation_period_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_vlp_shd.g_old_rec;
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
      <> pqh_vlp_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqh_fr_validation_periods');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_validation_period_id           in number
  ,p_validation_id                  in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_previous_employer_id           in number
  ,p_assignment_category	    in varchar2
  ,p_normal_hours                   in number
  ,p_frequency                      in varchar2
  ,p_period_years                   in number
  ,p_period_months                  in number
  ,p_period_days                    in number
  ,p_comments                       in varchar2
  ,p_validation_status              in varchar2
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
  l_rec.validation_period_id             := p_validation_period_id;
  l_rec.validation_id                    := p_validation_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.previous_employer_id             := p_previous_employer_id;
  l_rec.assignment_category		 := p_assignment_category;
  l_rec.normal_hours                     := p_normal_hours;
  l_rec.frequency                        := p_frequency;
  l_rec.period_years                     := p_period_years;
  l_rec.period_months                    := p_period_months;
  l_rec.period_days                      := p_period_days;
  l_rec.comments                         := p_comments;
  l_rec.validation_status                := p_validation_status;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_vlp_shd;

/
