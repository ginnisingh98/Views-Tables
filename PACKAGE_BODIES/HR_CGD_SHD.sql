--------------------------------------------------------
--  DDL for Package Body HR_CGD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CGD_SHD" as
/* $Header: hrcgdrhi.pkb 115.4 2002/12/03 09:17:25 hjonnala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_cgd_shd.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating(p_cagr_grade_def_id in number) Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	cagr_grade_def_id,
	id_flex_num,
	summary_flag,
	enabled_flag,
	start_date_active,
	end_date_active,
	segment1,
	segment2,
	segment3,
	segment4,
	segment5,
	segment6,
	segment7,
	segment8,
	segment9,
	segment10,
	segment11,
	segment12,
	segment13,
	segment14,
	segment15,
	segment16,
	segment17,
	segment18,
	segment19,
	segment20
    from  per_cagr_grades_def
    where cagr_grade_def_id = p_cagr_grade_def_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_cagr_grade_def_id is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cagr_grade_def_id = g_old_rec.cagr_grade_def_id) Then
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
      --
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
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_cagr_grade_def_id             in number,
	p_id_flex_num                   in number,
	p_summary_flag                  in varchar2,
	p_enabled_flag                  in varchar2,
	p_start_date_active             in date,
	p_end_date_active               in date,
	p_segment1                      in varchar2,
	p_segment2                      in varchar2,
	p_segment3                      in varchar2,
	p_segment4                      in varchar2,
	p_segment5                      in varchar2,
	p_segment6                      in varchar2,
	p_segment7                      in varchar2,
	p_segment8                      in varchar2,
	p_segment9                      in varchar2,
	p_segment10                     in varchar2,
	p_segment11                     in varchar2,
	p_segment12                     in varchar2,
	p_segment13                     in varchar2,
	p_segment14                     in varchar2,
	p_segment15                     in varchar2,
	p_segment16                     in varchar2,
	p_segment17                     in varchar2,
	p_segment18                     in varchar2,
	p_segment19                     in varchar2,
	p_segment20                     in varchar2
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
  l_rec.cagr_grade_def_id                := p_cagr_grade_def_id;
  l_rec.id_flex_num                      := p_id_flex_num;
  l_rec.summary_flag                     := p_summary_flag;
  l_rec.enabled_flag                     := p_enabled_flag;
  l_rec.start_date_active                := p_start_date_active;
  l_rec.end_date_active                  := p_end_date_active;
  l_rec.segment1                         := p_segment1;
  l_rec.segment2                         := p_segment2;
  l_rec.segment3                         := p_segment3;
  l_rec.segment4                         := p_segment4;
  l_rec.segment5                         := p_segment5;
  l_rec.segment6                         := p_segment6;
  l_rec.segment7                         := p_segment7;
  l_rec.segment8                         := p_segment8;
  l_rec.segment9                         := p_segment9;
  l_rec.segment10                        := p_segment10;
  l_rec.segment11                        := p_segment11;
  l_rec.segment12                        := p_segment12;
  l_rec.segment13                        := p_segment13;
  l_rec.segment14                        := p_segment14;
  l_rec.segment15                        := p_segment15;
  l_rec.segment16                        := p_segment16;
  l_rec.segment17                        := p_segment17;
  l_rec.segment18                        := p_segment18;
  l_rec.segment19                        := p_segment19;
  l_rec.segment20                        := p_segment20;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end hr_cgd_shd;

/
