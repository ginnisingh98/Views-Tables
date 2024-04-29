--------------------------------------------------------
--  DDL for Package Body PQP_DET_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_DET_SHD" as
/* $Header: pqdetrhi.pkb 115.8 2003/02/17 22:14:03 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_det_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQP_ANALYZED_ALIEN_DATA_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PQP_ANALYZED_ALIEN_DETAILS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_analyzed_data_details_id           in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	analyzed_data_details_id,
	analyzed_data_id,
	income_code,
	withholding_rate,
	income_code_sub_type,
	exemption_code,
	maximum_benefit_amount,
	retro_lose_ben_amt_flag,
	date_benefit_ends,
	retro_lose_ben_date_flag,
	nra_exempt_from_ss,
	nra_exempt_from_medicare,
	student_exempt_from_ss,
	student_exempt_from_medicare,
	addl_withholding_flag,
	constant_addl_tax,
	addl_withholding_amt,
	addl_wthldng_amt_period_type,
	personal_exemption,
	addl_exemption_allowed,
	treaty_ben_allowed_flag,
	treaty_benefits_start_date,
	object_version_number,
        retro_loss_notification_sent,
        current_analysis,
        forecast_income_code
    from	pqp_analyzed_alien_details
    where	analyzed_data_details_id = p_analyzed_data_details_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_analyzed_data_details_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_analyzed_data_details_id = g_old_rec.analyzed_data_details_id and
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
  p_analyzed_data_details_id           in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	analyzed_data_details_id,
	analyzed_data_id,
	income_code,
	withholding_rate,
	income_code_sub_type,
	exemption_code,
	maximum_benefit_amount,
	retro_lose_ben_amt_flag,
	date_benefit_ends,
	retro_lose_ben_date_flag,
	nra_exempt_from_ss,
	nra_exempt_from_medicare,
	student_exempt_from_ss,
	student_exempt_from_medicare,
	addl_withholding_flag,
	constant_addl_tax,
	addl_withholding_amt,
	addl_wthldng_amt_period_type,
	personal_exemption,
	addl_exemption_allowed,
	treaty_ben_allowed_flag,
	treaty_benefits_start_date,
	object_version_number,
        retro_loss_notification_sent,
        current_analysis,
        forecast_income_code
    from	pqp_analyzed_alien_details
    where	analyzed_data_details_id = p_analyzed_data_details_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqp_analyzed_alien_details');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_analyzed_data_details_id      in number,
	p_analyzed_data_id              in number,
	p_income_code                   in varchar2,
	p_withholding_rate              in number,
	p_income_code_sub_type          in varchar2,
	p_exemption_code                in varchar2,
	p_maximum_benefit_amount        in number,
	p_retro_lose_ben_amt_flag       in varchar2,
	p_date_benefit_ends             in date,
	p_retro_lose_ben_date_flag      in varchar2,
	p_nra_exempt_from_ss            in varchar2,
	p_nra_exempt_from_medicare      in varchar2,
	p_student_exempt_from_ss        in varchar2,
	p_student_exempt_from_medi      in varchar2,
	p_addl_withholding_flag         in varchar2,
	p_constant_addl_tax             in number,
	p_addl_withholding_amt          in number,
	p_addl_wthldng_amt_period_type  in varchar2,
	p_personal_exemption            in number,
	p_addl_exemption_allowed        in number,
	p_treaty_ben_allowed_flag       in varchar2,
	p_treaty_benefits_start_date    in date,
	p_object_version_number         in number,
        p_retro_loss_notification_sent  in varchar2,
        p_current_analysis              in varchar2,
        p_forecast_income_code          in varchar2
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
  l_rec.analyzed_data_details_id         := p_analyzed_data_details_id;
  l_rec.analyzed_data_id                 := p_analyzed_data_id;
  l_rec.income_code                      := p_income_code;
  l_rec.withholding_rate                 := p_withholding_rate;
  l_rec.income_code_sub_type             := p_income_code_sub_type;
  l_rec.exemption_code                   := p_exemption_code;
  l_rec.maximum_benefit_amount           := p_maximum_benefit_amount;
  l_rec.retro_lose_ben_amt_flag          := p_retro_lose_ben_amt_flag;
  l_rec.date_benefit_ends                := p_date_benefit_ends;
  l_rec.retro_lose_ben_date_flag         := p_retro_lose_ben_date_flag;
  l_rec.nra_exempt_from_ss               := p_nra_exempt_from_ss;
  l_rec.nra_exempt_from_medicare         := p_nra_exempt_from_medicare;
  l_rec.student_exempt_from_ss           := p_student_exempt_from_ss;
  l_rec.student_exempt_from_medicare     := p_student_exempt_from_medi;
  l_rec.addl_withholding_flag            := p_addl_withholding_flag;
  l_rec.constant_addl_tax                := p_constant_addl_tax;
  l_rec.addl_withholding_amt             := p_addl_withholding_amt;
  l_rec.addl_wthldng_amt_period_type     := p_addl_wthldng_amt_period_type;
  l_rec.personal_exemption               := p_personal_exemption;
  l_rec.addl_exemption_allowed           := p_addl_exemption_allowed;
  l_rec.treaty_ben_allowed_flag          := p_treaty_ben_allowed_flag;
  l_rec.treaty_benefits_start_date       := p_treaty_benefits_start_date;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.retro_loss_notification_sent     := p_retro_loss_notification_sent;
  l_rec.current_analysis                 := p_current_analysis            ;
  l_rec.forecast_income_code             := p_forecast_income_code        ;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pqp_det_shd;

/
