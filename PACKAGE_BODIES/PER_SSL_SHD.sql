--------------------------------------------------------
--  DDL for Package Body PER_SSL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SSL_SHD" as
/* $Header: pesslrhi.pkb 120.0.12010000.2 2008/09/09 11:18:51 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ssl_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_SALARY_SURVEY_LINES_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_SALARY_SURVEY_LINES_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_SALARY_SURVEY_LINES_UK1') Then
    hr_utility.set_message(800, 'PER_50340_PSS_INV_COMB1');
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
  p_salary_survey_line_id             in number,
  p_object_version_number             in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	salary_survey_line_id,
	object_version_number,
	salary_survey_id,
	survey_job_name_code,
	survey_region_code,
	survey_seniority_code,
	company_size_code,
	industry_code,
        survey_age_code,
	start_date,
	end_date,
        currency_code,
	differential,
	minimum_pay,
	mean_pay,
	maximum_pay,
	graduate_pay,
	starting_pay,
	percentage_change,
	job_first_quartile,
	job_median_quartile,
	job_third_quartile,
	job_fourth_quartile,
	minimum_total_compensation,
	mean_total_compensation,
	maximum_total_compensation,
	compnstn_first_quartile,
	compnstn_median_quartile,
	compnstn_third_quartile,
	compnstn_fourth_quartile,
/*Added for Enhancement 4021737 */
        tenth_percentile,
        twenty_fifth_percentile,
        fiftieth_percentile,
        seventy_fifth_percentile,
        ninetieth_percentile,
        minimum_bonus,
        mean_bonus,
        maximum_bonus,
        minimum_salary_increase,
        mean_salary_increase,
        maximum_salary_increase,
        min_variable_compensation,
        mean_variable_compensation,
        max_variable_compensation,
        minimum_stock,
        mean_stock,
        maximum_stock,
        stock_display_type,
/* End Enhancement 4021737 */
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
/*Added for Enhancement 4021737*/
        attribute21,
        attribute22,
        attribute23,
        attribute24,
        attribute25,
        attribute26,
        attribute27,
        attribute28,
        attribute29,
        attribute30
/*Enhancement 4021737 */
    from	per_salary_survey_lines
    where	salary_survey_line_id = p_salary_survey_line_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_salary_survey_line_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_salary_survey_line_id = g_old_rec.salary_survey_line_id and
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
  p_salary_survey_line_id             in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	salary_survey_line_id,
	object_version_number,
	salary_survey_id,
	survey_job_name_code,
	survey_region_code,
	survey_seniority_code,
	company_size_code,
	industry_code,
        survey_age_code,
	start_date,
	end_date,
        currency_code,
	differential,
	minimum_pay,
	mean_pay,
	maximum_pay,
	graduate_pay,
	starting_pay,
	percentage_change,
	job_first_quartile,
	job_median_quartile,
	job_third_quartile,
	job_fourth_quartile,
	minimum_total_compensation,
	mean_total_compensation,
	maximum_total_compensation,
	compnstn_first_quartile,
	compnstn_median_quartile,
	compnstn_third_quartile,
	compnstn_fourth_quartile,
/*Added for Enhancement 4021737 */
        tenth_percentile,
        twenty_fifth_percentile,
        fiftieth_percentile,
        seventy_fifth_percentile,
        ninetieth_percentile,
        minimum_bonus,
        mean_bonus,
        maximum_bonus,
        minimum_salary_increase,
        mean_salary_increase,
        maximum_salary_increase,
        min_variable_compensation,
        mean_variable_compensation,
        max_variable_compensation,
        minimum_stock,
        mean_stock,
        maximum_stock,
        stock_display_type,
/* End Enhancement 4021737 */
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
/*Added for Enhancement 4021737 */
        attribute21,
        attribute22,
        attribute23,
        attribute24,
        attribute25,
        attribute26,
        attribute27,
        attribute28,
        attribute29,
        attribute30
/*End Enhancement 4021737 */
    from	per_salary_survey_lines
    where	salary_survey_line_id = p_salary_survey_line_id
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
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked Then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'per_salary_survey_lines');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_salary_survey_line_id         in number,
	p_object_version_number         in number,
	p_salary_survey_id              in number,
	p_survey_job_name_code          in varchar2,
	p_survey_region_code            in varchar2,
	p_survey_seniority_code         in varchar2,
	p_company_size_code             in varchar2,
	p_industry_code                 in varchar2,
        p_survey_age_code               in varchar2,
	p_start_date                    in date,
	p_end_date                      in date,
        p_currency_code                 in varchar2,
	p_differential                  in number,
	p_minimum_pay                   in number,
	p_mean_pay                      in number,
	p_maximum_pay                   in number,
	p_graduate_pay                  in number,
	p_starting_pay                  in number,
	p_percentage_change             in number,
	p_job_first_quartile            in number,
	p_job_median_quartile           in number,
	p_job_third_quartile            in number,
	p_job_fourth_quartile           in number,
	p_minimum_total_compensation    in number,
	p_mean_total_compensation       in number,
	p_maximum_total_compensation    in number,
	p_compnstn_first_quartile       in number,
	p_compnstn_median_quartile      in number,
	p_compnstn_third_quartile       in number,
	p_compnstn_fourth_quartile      in number,
/*Added for Enhancement 4021737*/
        p_tenth_percentile              in number,
        p_twenty_fifth_percentile       in number,
        p_fiftieth_percentile           in number,
        p_seventy_fifth_percentile      in number,
        p_ninetieth_percentile          in number,
        p_minimum_bonus                 in number,
        p_mean_bonus                    in number,
        p_maximum_bonus                 in number,
        p_minimum_salary_increase       in number,
        p_mean_salary_increase          in number,
        p_maximum_salary_increase       in number,
        p_min_variable_compensation     in number,
        p_mean_variable_compensation    in number,
        p_max_variable_compensation     in number,
        p_minimum_stock                 in number,
        p_mean_stock                    in number,
        p_maximum_stock                 in number,
        p_stock_display_type            in varchar2,
/*End Enhancement 4021737 */
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
/*Added for Enhancement 4021737 */
        p_attribute21                   in varchar2,
        p_attribute22                   in varchar2,
        p_attribute23                   in varchar2,
        p_attribute24                   in varchar2,
        p_attribute25                   in varchar2,
        p_attribute26                   in varchar2,
        p_attribute27                   in varchar2,
        p_attribute28                   in varchar2,
        p_attribute29                   in varchar2,
        p_attribute30                   in varchar2
/*End Enhancement 4021737 */
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
  l_rec.salary_survey_line_id            := p_salary_survey_line_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.salary_survey_id                 := p_salary_survey_id;
  l_rec.survey_job_name_code             := p_survey_job_name_code;
  l_rec.survey_region_code               := p_survey_region_code;
  l_rec.survey_seniority_code            := p_survey_seniority_code;
  l_rec.company_size_code                := p_company_size_code;
  l_rec.industry_code                    := p_industry_code;
  l_rec.survey_age_code                  := p_survey_age_code;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.currency_code                    := p_currency_code;
  l_rec.differential                     := p_differential;
  l_rec.minimum_pay                      := p_minimum_pay;
  l_rec.mean_pay                         := p_mean_pay;
  l_rec.maximum_pay                      := p_maximum_pay;
  l_rec.graduate_pay                     := p_graduate_pay;
  l_rec.starting_pay                     := p_starting_pay;
  l_rec.percentage_change                := p_percentage_change;
  l_rec.job_first_quartile               := p_job_first_quartile;
  l_rec.job_median_quartile              := p_job_median_quartile;
  l_rec.job_third_quartile               := p_job_third_quartile;
  l_rec.job_fourth_quartile              := p_job_fourth_quartile;
  l_rec.minimum_total_compensation       := p_minimum_total_compensation;
  l_rec.mean_total_compensation          := p_mean_total_compensation;
  l_rec.maximum_total_compensation       := p_maximum_total_compensation;
  l_rec.compnstn_first_quartile          := p_compnstn_first_quartile;
  l_rec.compnstn_median_quartile         := p_compnstn_median_quartile;
  l_rec.compnstn_third_quartile          := p_compnstn_third_quartile;
  l_rec.compnstn_fourth_quartile         := p_compnstn_fourth_quartile;
/*Added for Enhancement 4021737 */
  l_rec.tenth_percentile                 := p_tenth_percentile;
  l_rec.twenty_fifth_percentile          := p_twenty_fifth_percentile;
  l_rec.fiftieth_percentile              := p_fiftieth_percentile;
  l_rec.seventy_fifth_percentile         := p_seventy_fifth_percentile;
  l_rec.ninetieth_percentile             := p_ninetieth_percentile;
  l_rec.minimum_bonus                    := p_minimum_bonus;
  l_rec.mean_bonus                       := p_mean_bonus;
  l_rec.maximum_bonus                    := p_maximum_bonus;
  l_rec.minimum_salary_increase          := p_minimum_salary_increase;
  l_rec.mean_salary_increase             := p_mean_salary_increase;
  l_rec.maximum_salary_increase          := p_maximum_salary_increase;
  l_rec.min_variable_compensation        := p_min_variable_compensation;
  l_rec.mean_variable_compensation       := p_mean_variable_compensation;
  l_rec.max_variable_compensation        := p_max_variable_compensation;
  l_rec.minimum_stock                    := p_minimum_stock;
  l_rec.mean_stock                       := p_mean_stock;
  l_rec.maximum_stock                    := p_maximum_stock;
  l_rec.stock_display_type               := p_stock_display_type;
/*End Enhancement 4021737 */
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
/*Added for Enhancement 4021737 */
  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;
/*End Enhancement 4021737 */
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
End per_ssl_shd;

/
