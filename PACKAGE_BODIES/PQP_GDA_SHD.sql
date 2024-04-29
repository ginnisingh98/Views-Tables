--------------------------------------------------------
--  DDL for Package Body PQP_GDA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GDA_SHD" as
/* $Header: pqgdarhi.pkb 120.0 2005/05/29 01:52:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_gda_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQP_GAP_DAILY_ABSENCES_PK') Then
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
  (p_gap_daily_absence_id                 in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       gap_daily_absence_id
      ,gap_absence_plan_id
      ,absence_date
      ,work_pattern_day_type
      ,level_of_entitlement
      ,level_of_pay
      ,duration
      ,duration_in_hours
      ,working_days_per_week
      ,fte -- LG
      ,object_version_number
    from        pqp_gap_daily_absences
    where       gap_daily_absence_id = p_gap_daily_absence_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_gap_daily_absence_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_gap_daily_absence_id
        = pqp_gda_shd.g_old_rec.gap_daily_absence_id and
        p_object_version_number
        = pqp_gda_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqp_gda_shd.g_old_rec;
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
          <> pqp_gda_shd.g_old_rec.object_version_number) Then
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
  (p_gap_daily_absence_id                 in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       gap_daily_absence_id
      ,gap_absence_plan_id
      ,absence_date
      ,work_pattern_day_type
      ,level_of_entitlement
      ,level_of_pay
      ,duration
      ,duration_in_hours
      ,working_days_per_week
      ,fte -- LG
      ,object_version_number
    from        pqp_gap_daily_absences
    where       gap_daily_absence_id = p_gap_daily_absence_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'GAP_DAILY_ABSENCE_ID'
    ,p_argument_value     => p_gap_daily_absence_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqp_gda_shd.g_old_rec;
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
      <> pqp_gda_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqp_gap_daily_absences');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_gap_daily_absence_id           in number
  ,p_gap_absence_plan_id            in number
  ,p_absence_date                   in date
  ,p_work_pattern_day_type          in varchar2
  ,p_level_of_entitlement           in varchar2
  ,p_level_of_pay                   in varchar2
  ,p_duration                       in number
  ,p_duration_in_hours              in number
  ,p_working_days_per_week          in number
  ,p_fte                            in number -- LG
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
  l_rec.gap_daily_absence_id             := p_gap_daily_absence_id;
  l_rec.gap_absence_plan_id              := p_gap_absence_plan_id;
  l_rec.absence_date                     := p_absence_date;
  l_rec.work_pattern_day_type            := p_work_pattern_day_type;
  l_rec.level_of_entitlement             := p_level_of_entitlement;
  l_rec.level_of_pay                     := p_level_of_pay;
  l_rec.duration                         := p_duration;
  l_rec.duration_in_hours                := p_duration_in_hours;
  l_rec.working_days_per_week            := p_working_days_per_week;
  l_rec.fte                              := p_fte;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqp_gda_shd;

/
