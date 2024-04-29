--------------------------------------------------------
--  DDL for Package Body PQP_AAD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_AAD_SHD" as
/* $Header: pqaadrhi.pkb 115.5 2003/02/17 22:13:35 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_aad_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQP_ANALYZED_ALIEN_DATA_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
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
  p_analyzed_data_id                   in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	analyzed_data_id,
	assignment_id,
	data_source,
	tax_year,
	current_residency_status,
	nra_to_ra_date,
	target_departure_date,
	tax_residence_country_code,
	treaty_info_update_date,
	number_of_days_in_usa,
	withldg_allow_eligible_flag,
	ra_effective_date,
	record_source,
	visa_type,
	j_sub_type,
	primary_activity,
	non_us_country_code,
	citizenship_country_code,
	object_version_number	,
        date_8233_signed,
        date_w4_signed
    from	pqp_analyzed_alien_data
    where	analyzed_data_id = p_analyzed_data_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_analyzed_data_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_analyzed_data_id = g_old_rec.analyzed_data_id and
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
  p_analyzed_data_id                   in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	analyzed_data_id,
	assignment_id,
	data_source,
	tax_year,
	current_residency_status,
	nra_to_ra_date,
	target_departure_date,
	tax_residence_country_code,
	treaty_info_update_date,
	number_of_days_in_usa,
	withldg_allow_eligible_flag,
	ra_effective_date,
	record_source,
	visa_type,
	j_sub_type,
	primary_activity,
	non_us_country_code,
	citizenship_country_code,
	object_version_number	,
        date_8233_signed,
        date_w4_signed
    from	pqp_analyzed_alien_data
    where	analyzed_data_id = p_analyzed_data_id
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
    hr_utility.set_message_token('TABLE_NAME', 'pqp_analyzed_alien_data');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_analyzed_data_id              in number,
	p_assignment_id                 in number,
	p_data_source                   in varchar2,
	p_tax_year                      in number,
	p_current_residency_status      in varchar2,
	p_nra_to_ra_date                in date,
	p_target_departure_date         in date,
	p_tax_residence_country_code    in varchar2,
	p_treaty_info_update_date       in date,
	p_number_of_days_in_usa         in number,
	p_withldg_allow_eligible_flag   in varchar2,
	p_ra_effective_date             in date,
	p_record_source                 in varchar2,
	p_visa_type                     in varchar2,
	p_j_sub_type                    in varchar2,
	p_primary_activity              in varchar2,
	p_non_us_country_code           in varchar2,
	p_citizenship_country_code      in varchar2,
	p_object_version_number         in number ,
        p_date_8233_signed              in date   ,
        p_date_w4_signed                in date
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
  l_rec.analyzed_data_id                 := p_analyzed_data_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.data_source                      := p_data_source;
  l_rec.tax_year                         := p_tax_year;
  l_rec.current_residency_status         := p_current_residency_status;
  l_rec.nra_to_ra_date                   := p_nra_to_ra_date;
  l_rec.target_departure_date            := p_target_departure_date;
  l_rec.tax_residence_country_code       := p_tax_residence_country_code;
  l_rec.treaty_info_update_date          := p_treaty_info_update_date;
  l_rec.number_of_days_in_usa            := p_number_of_days_in_usa;
  l_rec.withldg_allow_eligible_flag      := p_withldg_allow_eligible_flag;
  l_rec.ra_effective_date                := p_ra_effective_date;
  l_rec.record_source                    := p_record_source;
  l_rec.visa_type                        := p_visa_type;
  l_rec.j_sub_type                       := p_j_sub_type;
  l_rec.primary_activity                 := p_primary_activity;
  l_rec.non_us_country_code              := p_non_us_country_code;
  l_rec.citizenship_country_code         := p_citizenship_country_code;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.date_8233_signed                 := p_date_8233_signed     ;
  l_rec.date_w4_signed                   := p_date_w4_signed       ;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pqp_aad_shd;

/
