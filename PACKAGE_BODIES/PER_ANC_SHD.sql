--------------------------------------------------------
--  DDL for Package Body PER_ANC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ANC_SHD" as
/* $Header: peancrhi.pkb 120.2 2005/10/05 06:19:33 asahay noship $ */
--
-- ---------------------------------------------------------------------------- --
-- |                     Private Global Definitions                           | --
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_anc_shd.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |------------------------< segment_combination_check >---------------------|
-- ----------------------------------------------------------------------------
procedure segment_combination_check
         (p_segment1              in  varchar2 default null,
          p_segment2              in  varchar2 default null,
          p_segment3              in  varchar2 default null,
          p_segment4              in  varchar2 default null,
          p_segment5              in  varchar2 default null,
          p_segment6              in  varchar2 default null,
          p_segment7              in  varchar2 default null,
          p_segment8              in  varchar2 default null,
          p_segment9              in  varchar2 default null,
          p_segment10             in  varchar2 default null,
          p_segment11             in  varchar2 default null,
          p_segment12             in  varchar2 default null,
          p_segment13             in  varchar2 default null,
          p_segment14             in  varchar2 default null,
          p_segment15             in  varchar2 default null,
          p_segment16             in  varchar2 default null,
          p_segment17             in  varchar2 default null,
          p_segment18             in  varchar2 default null,
          p_segment19             in  varchar2 default null,
          p_segment20             in  varchar2 default null,
          p_segment21             in  varchar2 default null,
          p_segment22             in  varchar2 default null,
          p_segment23             in  varchar2 default null,
          p_segment24             in  varchar2 default null,
          p_segment25             in  varchar2 default null,
          p_segment26             in  varchar2 default null,
          p_segment27             in  varchar2 default null,
          p_segment28             in  varchar2 default null,
          p_segment29             in  varchar2 default null,
          p_segment30             in  varchar2 default null,
          p_business_group_id     in  number,
 	  p_id_flex_num           in  number,
          p_analysis_criteria_id  out NOCOPY number) is
  --
  l_proc          varchar2(72) := g_package||'segment_combination_check';
  l_discard	  number;
  --
  -- the cursor ancsel ensures the id_flex_num must be valid, enabled for
  -- the id_flex_code 'PEA' and must exist within PER_SPECIAL_INFO_TYPES
  -- for the business group.
  --
  cursor ancsel is
    select   1
    from     per_special_info_types pc,
             fnd_id_flex_structures fs
    where    fs.id_flex_num           = pc.id_flex_num
    and      fs.id_flex_code          = 'PEA'
    and      pc.enabled_flag          = 'Y'
    and      pc.business_group_id + 0 = p_business_group_id
    and      pc.id_flex_num           = p_id_flex_num;
  --
  -- the cursor ancerrsel1 determines if the id_flex_num is valid
  -- note: only called when cursor ancsel fails
  --
  cursor ancerrsel1 is
    select 1
    from   fnd_id_flex_structures fs
    where  fs.id_flex_num           = p_id_flex_num
    and    fs.id_flex_code          = 'PEA';
  --
  -- the cursor ancerrsel2 determines if the id_flex_num is valid for
  -- per_special_info_types
  -- note: only called when cursor ancsel fails
  --
  cursor ancerrsel2 is
    select 1
    from   per_special_info_types pc
    where  pc.business_group_id + 0 = p_business_group_id
    and    pc.id_flex_num           = p_id_flex_num;

  --
  -- the cursor kfsel selects the analysis_criteria_id
  --
  cursor kfsel is
    select pac.analysis_criteria_id
    from   per_analysis_criteria pac
    where  pac.id_flex_num   = p_id_flex_num
    and    pac.enabled_flag  = 'Y'
    and   (pac.segment1      = p_segment1
    or    (pac.segment1      is null
    and    p_segment1        is null))
    and   (pac.segment2      = p_segment2
    or    (pac.segment2      is null
    and    p_segment2        is null))
    and   (pac.segment3      = p_segment3
    or    (pac.segment3      is null
    and    p_segment3        is null))
    and   (pac.segment4      = p_segment4
    or    (pac.segment4      is null
    and    p_segment4        is null))
    and   (pac.segment5      = p_segment5
    or    (pac.segment5      is null
    and    p_segment5        is null))
    and   (pac.segment6      = p_segment6
    or    (pac.segment6      is null
    and    p_segment6        is null))
    and   (pac.segment7      = p_segment7
    or    (pac.segment7      is null
    and    p_segment7        is null))
    and   (pac.segment8      = p_segment8
    or    (pac.segment8      is null
    and    p_segment8        is null))
    and   (pac.segment9      = p_segment9
    or    (pac.segment9      is null
    and    p_segment9        is null))
    and   (pac.segment10     = p_segment10
    or    (pac.segment10     is null
    and    p_segment10       is null))
    and   (pac.segment11     = p_segment11
    or    (pac.segment11     is null
    and    p_segment11       is null))
    and   (pac.segment12     = p_segment12
    or    (pac.segment12     is null
    and    p_segment12       is null))
    and   (pac.segment13     = p_segment13
    or    (pac.segment13     is null
    and    p_segment13       is null))
    and   (pac.segment14     = p_segment14
    or    (pac.segment14      is null
    and    p_segment14       is null))
    and   (pac.segment15      = p_segment15
    or    (pac.segment15     is null
    and    p_segment15       is null))
    and   (pac.segment16     = p_segment16
    or    (pac.segment16     is null
    and    p_segment16       is null))
    and   (pac.segment17     = p_segment17
    or    (pac.segment17     is null
    and    p_segment17       is null))
    and   (pac.segment18     = p_segment18
    or    (pac.segment18     is null
    and    p_segment18       is null))
    and   (pac.segment19     = p_segment19
    or    (pac.segment19     is null
    and    p_segment19       is null))
    and   (pac.segment20     = p_segment20
    or    (pac.segment20     is null
    and    p_segment20       is null))
    and   (pac.segment21     = p_segment21
    or    (pac.segment21     is null
    and    p_segment21       is null))
    and   (pac.segment22     = p_segment22
    or    (pac.segment22     is null
    and    p_segment22       is null))
    and   (pac.segment23     = p_segment23
    or    (pac.segment23     is null
    and    p_segment23       is null))
    and   (pac.segment24     = p_segment24
    or    (pac.segment24     is null
    and    p_segment24       is null))
    and   (pac.segment25     = p_segment25
    or    (pac.segment25     is null
    and    p_segment25       is null))
    and   (pac.segment26     = p_segment26
    or    (pac.segment26     is null
    and    p_segment26       is null))
    and   (pac.segment27     = p_segment27
    or    (pac.segment27     is null
    and    p_segment27       is null))
    and   (pac.segment28     = p_segment28
    or    (pac.segment28     is null
    and    p_segment28       is null))
    and   (pac.segment29     = p_segment29
    or    (pac.segment29     is null
    and    p_segment29       is null))
    and   (pac.segment30     = p_segment30
    or    (pac.segment30     is null
    and    p_segment30       is null));
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- ensure that the id_flex_num exists
  --
 --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'id_flex_num',
     p_argument_value => p_id_flex_num);
  --
  -- validate the business_group_id
  --
  hr_api.validate_bus_grp_id(p_business_group_id);
--
  -- determine if all the segments are null
  --
  if (p_segment1  is null  and
      p_segment2  is null  and
      p_segment3  is null  and
      p_segment4  is null  and
      p_segment5  is null  and
      p_segment6  is null  and
      p_segment7  is null  and
      p_segment8  is null  and
      p_segment9  is null  and
      p_segment10 is null  and
      p_segment11 is null  and
      p_segment12 is null  and
      p_segment13 is null  and
      p_segment14 is null  and
      p_segment15 is null  and
      p_segment16 is null  and
      p_segment17 is null  and
      p_segment18 is null  and
      p_segment19 is null  and
      p_segment20 is null  and
      p_segment21 is null  and
      p_segment22 is null  and
      p_segment23 is null  and
      p_segment24 is null  and
      p_segment25 is null  and
      p_segment26 is null  and
      p_segment25 is null  and
      p_segment26 is null  and
      p_segment27 is null  and
      p_segment28 is null  and
      p_segment29 is null  and
      p_segment30 is null) then
     --
     -- as the segments are null set the p_analysis_criteria_id
     -- explicitly to null.
     --
     hr_utility.set_location(l_proc, 10);
     p_analysis_criteria_id := null;
else
    --
    -- segments exists therefore validate the id_flex_num
    --
hr_utility.set_location(l_proc, 15);
    open ancsel;
    fetch ancsel into l_discard;
    if ancsel%notfound then
      close ancsel;
      --
      -- the flex structure has not been found therefore we must
      -- determine the error
      --
      open ancerrsel1;
      fetch ancerrsel1 into l_discard;
      if ancerrsel1%notfound then
        close ancerrsel1;
        hr_utility.set_message(801, 'HR_6039_ALL_CANT_GET_FFIELD');
        hr_utility.set_message_token('FLEXFIELD_STRUCTURE',
                                     p_id_flex_num);
        hr_utility.raise_error;
      end if;
      close ancerrsel1;
      open ancerrsel2;
      fetch ancerrsel2 into l_discard;
      if ancerrsel2%notfound then
      close ancerrsel2;
        --
        -- the row does not exist in PER_SPECIAL_INFO_TYPES
        --
        hr_utility.set_message(801, 'HR_51114_JBR_SPCIAL_NOT_EXIST');
        hr_utility.raise_error;
      end if;
      close ancerrsel2;
        --
        -- the row is not enabled in PER_SPECIAL_INFO_TYPES
        --
        hr_utility.set_message(801, 'HR_51115_JBR_SPCIAL_NOT_ENABLE');
        hr_utility.raise_error;
    end if;
    close ancsel;
    hr_utility.set_location(l_proc, 10);
    --
    -- open and execute the partial segment cursor. if no rows are returned
    -- then p_analysis_criteria_id must be set to -1 (indicating a
    -- new combination needs to be inserted.
    --
    hr_utility.set_location(l_proc, 20);
    open  kfsel;
    fetch kfsel into p_analysis_criteria_id;
    if kfsel%notfound then
    hr_utility.set_location(l_proc, 25);
      p_analysis_criteria_id := -1;
    end if;
    close kfsel;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
end segment_combination_check;
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
            (p_constraint_name in varchar2) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PER_ANALYSIS_CRITERIA_PK') Then
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
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
  p_analysis_criteria_id               in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		analysis_criteria_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
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
	segment20,
	segment21,
	segment22,
	segment23,
	segment24,
	segment25,
	segment26,
	segment27,
	segment28,
	segment29,
	segment30
    from	per_analysis_criteria
    where	analysis_criteria_id = p_analysis_criteria_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_analysis_criteria_id is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_analysis_criteria_id = g_old_rec.analysis_criteria_id
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
	p_analysis_criteria_id          in number,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
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
	p_segment20                     in varchar2,
	p_segment21                     in varchar2,
	p_segment22                     in varchar2,
	p_segment23                     in varchar2,
	p_segment24                     in varchar2,
	p_segment25                     in varchar2,
	p_segment26                     in varchar2,
	p_segment27                     in varchar2,
	p_segment28                     in varchar2,
	p_segment29                     in varchar2,
	p_segment30                     in varchar2
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
  l_rec.analysis_criteria_id             := p_analysis_criteria_id;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
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
  l_rec.segment21                        := p_segment21;
  l_rec.segment22                        := p_segment22;
  l_rec.segment23                        := p_segment23;
  l_rec.segment24                        := p_segment24;
  l_rec.segment25                        := p_segment25;
  l_rec.segment26                        := p_segment26;
  l_rec.segment27                        := p_segment27;
  l_rec.segment28                        := p_segment28;
  l_rec.segment29                        := p_segment29;
  l_rec.segment30                        := p_segment30;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_anc_shd;

/
