--------------------------------------------------------
--  DDL for Package Body PQH_STS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_STS_SHD" as
/* $Header: pqstsrhi.pkb 120.0 2005/05/29 02:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_sts_shd.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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
  If (p_constraint_name = 'PQH_FR_STAT_SITUATIONS_PK') Then
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
  (p_statutory_situation_id               in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       statutory_situation_id
      ,business_group_id
      ,situation_name
      ,type_of_ps
      ,situation_type
      ,sub_type
      ,source
      ,location
      ,reason
      ,default_flag
      ,date_from
      ,date_to
      ,request_type
      ,employee_agreement_needed
      ,manager_agreement_needed
      ,print_arrette
      ,reserve_position
      ,allow_progression_flag
      ,extend_probation_period_flag
      ,remuneration_paid
      ,pay_share
      ,pay_periods
      ,frequency
      ,first_period_max_duration
      ,min_duration_per_request
      ,max_duration_per_request
      ,max_duration_whole_career
      ,renewable_allowed
      ,max_no_of_renewals
      ,max_duration_per_renewal
      ,max_tot_continuous_duration
      ,object_version_number
      ,remunerate_assign_status_id
    from        pqh_fr_stat_situations
    where       statutory_situation_id = p_statutory_situation_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_statutory_situation_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_statutory_situation_id
        = pqh_sts_shd.g_old_rec.statutory_situation_id and
        p_object_version_number
        = pqh_sts_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_sts_shd.g_old_rec;
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
          <> pqh_sts_shd.g_old_rec.object_version_number) Then
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
  (p_statutory_situation_id               in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       statutory_situation_id
      ,business_group_id
      ,situation_name
      ,type_of_ps
      ,situation_type
      ,sub_type
      ,source
      ,location
      ,reason
      ,default_flag
      ,date_from
      ,date_to
      ,request_type
      ,employee_agreement_needed
      ,manager_agreement_needed
      ,print_arrette
      ,reserve_position
      ,allow_progression_flag
      ,extend_probation_period_flag
      ,remuneration_paid
      ,pay_share
      ,pay_periods
      ,frequency
      ,first_period_max_duration
      ,min_duration_per_request
      ,max_duration_per_request
      ,max_duration_whole_career
      ,renewable_allowed
      ,max_no_of_renewals
      ,max_duration_per_renewal
      ,max_tot_continuous_duration
      ,object_version_number
      ,remunerate_assign_status_id
    from        pqh_fr_stat_situations
    where       statutory_situation_id = p_statutory_situation_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin

  if g_debug then
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
  end if;

  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'STATUTORY_SITUATION_ID'
    ,p_argument_value     => p_statutory_situation_id
    );

  if g_debug then
  --
     hr_utility.set_location(l_proc,6);
  --
  end if;

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_sts_shd.g_old_rec;
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
      <> pqh_sts_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  if g_debug then
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  end if;
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
    fnd_message.set_token('TABLE_NAME', 'pqh_fr_stat_situations');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_statutory_situation_id         in number
  ,p_business_group_id              in number
  ,p_situation_name                 in varchar2
  ,p_type_of_ps                     in varchar2
  ,p_situation_type                 in varchar2
  ,p_sub_type                       in varchar2
  ,p_source                         in varchar2
  ,p_location                       in varchar2
  ,p_reason                         in varchar2
  ,p_is_default                     in varchar2
  ,p_date_from                      in date
  ,p_date_to                        in date
  ,p_request_type                   in varchar2
  ,p_employee_agreement_needed      in varchar2
  ,p_manager_agreement_needed       in varchar2
  ,p_print_arrette                  in varchar2
  ,p_reserve_position               in varchar2
  ,p_allow_progressions             in varchar2
  ,p_extend_probation_period        in varchar2
  ,p_remuneration_paid              in varchar2
  ,p_pay_share                      in number
  ,p_pay_periods                    in number
  ,p_frequency                      in varchar2
  ,p_first_period_max_duration      in number
  ,p_min_duration_per_request       in number
  ,p_max_duration_per_request       in number
  ,p_max_duration_whole_career      in number
  ,p_renewable_allowed              in varchar2
  ,p_max_no_of_renewals             in number
  ,p_max_duration_per_renewal       in number
  ,p_max_tot_continuous_duration    in number
  ,p_object_version_number          in number
  ,p_remunerate_assign_status_id    in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.statutory_situation_id           := p_statutory_situation_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.situation_name                   := p_situation_name;
  l_rec.type_of_ps                       := p_type_of_ps;
  l_rec.situation_type                   := p_situation_type;
  l_rec.sub_type                         := p_sub_type;
  l_rec.source                           := p_source;
  l_rec.location                         := p_location;
  l_rec.reason                           := p_reason;
  l_rec.is_default                       := p_is_default;
  l_rec.date_from                        := p_date_from;
  l_rec.date_to                          := p_date_to;
  l_rec.request_type                     := p_request_type;
  l_rec.employee_agreement_needed        := p_employee_agreement_needed;
  l_rec.manager_agreement_needed         := p_manager_agreement_needed;
  l_rec.print_arrette                    := p_print_arrette;
  l_rec.reserve_position                 := p_reserve_position;
  l_rec.allow_progressions               := p_allow_progressions;
  l_rec.extend_probation_period          := p_extend_probation_period;
  l_rec.remuneration_paid                := p_remuneration_paid;
  l_rec.pay_share                        := p_pay_share;
  l_rec.pay_periods                      := p_pay_periods;
  l_rec.frequency                        := p_frequency;
  l_rec.first_period_max_duration        := p_first_period_max_duration;
  l_rec.min_duration_per_request         := p_min_duration_per_request;
  l_rec.max_duration_per_request         := p_max_duration_per_request;
  l_rec.max_duration_whole_career        := p_max_duration_whole_career;
  l_rec.renewable_allowed                := p_renewable_allowed;
  l_rec.max_no_of_renewals               := p_max_no_of_renewals;
  l_rec.max_duration_per_renewal         := p_max_duration_per_renewal;
  l_rec.max_tot_continuous_duration      := p_max_tot_continuous_duration;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.remunerate_assign_status_id      := p_remunerate_assign_status_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_sts_shd;

/
