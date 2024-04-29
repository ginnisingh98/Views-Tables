--------------------------------------------------------
--  DDL for Package Body SSP_STP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_STP_SHD" as
/* $Header: spstprhi.pkb 115.3 99/10/13 01:54:40 porting ship  $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ssp_stp_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'SSP_STOPPAGES_FK1') Then
    fnd_message.set_name ('SSP', 'SSP_35069_STOPPAGES_FK1');
  ElsIf (p_constraint_name = 'SSP_STOPPAGES_FK2') Then
    fnd_message.set_name ('SSP', 'SSP_35070_STOPPAGES_FK2');
  ElsIf (p_constraint_name = 'SSP_STOPPAGES_FK3') Then
    fnd_message.set_name ('SSP', 'SSP_35071_STOPPAGES_FK3');
  ElsIf (p_constraint_name = 'SSP_STOPPAGES_PK') Then
    fnd_message.set_name ('SSP', 'SSP_35072_STOPPAGES_PK');
  ElsIf (p_constraint_name = 'SSP_STP_ARC_ABS_MAT') Then
    fnd_message.set_name ('SSP', 'SSP_35073_STP_ARC_ABS_MAT');
  ElsIf (p_constraint_name = 'SSP_STP_SMP_STOPPAGE_DATES') Then
    fnd_message.set_name ('SSP', 'SSP_35074_STOPPAGE_DATES');
  ElsIf (p_constraint_name = 'SSP_STP_WITHHOLD_TO_PERMANENT') Then
    fnd_message.set_name ('SSP', 'SSP_35075_PERMANENT_STOPPAGE');
  ElsIf (p_constraint_name = 'SSP_STP_SYSTEM_NOT_OVERRIDE') Then
    fnd_message.set_name ('SSP', 'SSP_35076_SYSTEM_NOT_OVERRIDE');
  Else
    fnd_message.set_name ('SSP', 'HR_7877_API_INVALID_CONSTRAINT');
  End If;
  --
  fnd_message.raise_error;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_stoppage_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		stoppage_id,
	object_version_number,
	absence_attendance_id,
	maternity_id,
	reason_id,
	user_entered,
	override_stoppage,
	employee_notified,
	withhold_from,
	withhold_to
    from	ssp_stoppages
    where	stoppage_id = p_stoppage_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_stoppage_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_stoppage_id = g_old_rec.stoppage_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
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
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_stoppage_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	stoppage_id,
	object_version_number,
	absence_attendance_id,
	maternity_id,
	reason_id,
	user_entered,
	override_stoppage,
	employee_notified,
	withhold_from,
	withhold_to
    from	ssp_stoppages
    where	stoppage_id = p_stoppage_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'ssp_stoppages');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_stoppage_id                   in number,
	p_object_version_number         in number,
	p_absence_attendance_id         in number,
	p_maternity_id                  in number,
	p_reason_id                     in number,
	p_user_entered                  in varchar2,
	p_override_stoppage             in varchar2,
	p_employee_notified             in varchar2,
	p_withhold_from                 in date,
	p_withhold_to                   in date
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.stoppage_id                      := p_stoppage_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.absence_attendance_id            := p_absence_attendance_id;
  l_rec.maternity_id                     := p_maternity_id;
  l_rec.reason_id                        := p_reason_id;
  l_rec.user_entered                     := p_user_entered;
  l_rec.override_stoppage                := p_override_stoppage;
  l_rec.employee_notified                := p_employee_notified;
  l_rec.withhold_from                    := p_withhold_from;
  l_rec.withhold_to                      := p_withhold_to;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ssp_stp_shd;

/
