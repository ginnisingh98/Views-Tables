--------------------------------------------------------
--  DDL for Package Body HR_SCL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SCL_SHD" as
/* $Header: hrsclrhi.pkb 115.3 2002/12/03 08:23:56 raranjan ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_scl_shd.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |------------------------< segment_combination_check >---------------------|
-- ----------------------------------------------------------------------------
procedure segment_combination_check
         (p_segment1               in  varchar2 default null,
          p_segment2               in  varchar2 default null,
          p_segment3               in  varchar2 default null,
          p_segment4               in  varchar2 default null,
          p_segment5               in  varchar2 default null,
          p_segment6               in  varchar2 default null,
          p_segment7               in  varchar2 default null,
          p_segment8               in  varchar2 default null,
          p_segment9               in  varchar2 default null,
          p_segment10              in  varchar2 default null,
          p_segment11              in  varchar2 default null,
          p_segment12              in  varchar2 default null,
          p_segment13              in  varchar2 default null,
          p_segment14              in  varchar2 default null,
          p_segment15              in  varchar2 default null,
          p_segment16              in  varchar2 default null,
          p_segment17              in  varchar2 default null,
          p_segment18              in  varchar2 default null,
          p_segment19              in  varchar2 default null,
          p_segment20              in  varchar2 default null,
          p_segment21              in  varchar2 default null,
          p_segment22              in  varchar2 default null,
          p_segment23              in  varchar2 default null,
          p_segment24              in  varchar2 default null,
          p_segment25              in  varchar2 default null,
          p_segment26              in  varchar2 default null,
          p_segment27              in  varchar2 default null,
          p_segment28              in  varchar2 default null,
          p_segment29              in  varchar2 default null,
          p_segment30              in  varchar2 default null,
          p_business_group_id      in  number,
          p_soft_coding_keyflex_id out nocopy number,
          p_concatenated_segments  out nocopy varchar2,
          p_id_flex_num            out nocopy number) is
  --
  l_id_flex_num   hr_soft_coding_keyflex.id_flex_num%type;
  l_proc          varchar2(72) := g_package||'segment_combination_check';
  --
  -- the cursor idsel selects the valid id_flex_num
  -- (scl keyflex) for the specified business group
  --
  cursor idsel is
    select plr.rule_mode                       id_flex_num
    from   pay_legislation_rules               plr,
           per_business_groups                 pbg
    where  pbg.business_group_id               = p_business_group_id
    and    plr.legislation_code                = pbg.legislation_code
    and    plr.rule_type                       = 'S'
    and    exists
          (select 1
           from   fnd_segment_attribute_values fsav
           where  fsav.id_flex_num             = plr.rule_mode
           and    fsav.application_id          = 800
           and    fsav.id_flex_code            = 'SCL'
           and    fsav.segment_attribute_type  = 'ASSIGNMENT'
           and    fsav.attribute_value         = 'Y')
    and    exists
          (select 1
           from   pay_legislation_rules        plr2
           where  plr2.legislation_code        = pbg.legislation_code
           and    plr2.rule_type               = 'SDL'
           and    plr2.rule_mode               = 'A') ;
  --
  -- the cursor sclsel selects the soft_coding_keyflex_id
  --
  cursor sclsel is
    select scl.soft_coding_keyflex_id,
           scl.concatenated_segments
    from   hr_soft_coding_keyflex scl
    where  scl.id_flex_num   = l_id_flex_num
    and    scl.enabled_flag  = 'Y'
    and   (scl.segment1      = p_segment1
    or    (scl.segment1      is null
    and    p_segment1        is null))
    and   (scl.segment2      = p_segment2
    or    (scl.segment2      is null
    and    p_segment2        is null))
    and   (scl.segment3      = p_segment3
    or    (scl.segment3      is null
    and    p_segment3        is null))
    and   (scl.segment4      = p_segment4
    or    (scl.segment4      is null
    and    p_segment4        is null))
    and   (scl.segment5      = p_segment5
    or    (scl.segment5      is null
    and    p_segment5        is null))
    and   (scl.segment6      = p_segment6
    or    (scl.segment6      is null
    and    p_segment6        is null))
    and   (scl.segment7      = p_segment7
    or    (scl.segment7      is null
    and    p_segment7        is null))
    and   (scl.segment8      = p_segment8
    or    (scl.segment8      is null
    and    p_segment8        is null))
    and   (scl.segment9      = p_segment9
    or    (scl.segment9      is null
    and    p_segment9        is null))
    and   (scl.segment10     = p_segment10
    or    (scl.segment10     is null
    and    p_segment10       is null))
    and   (scl.segment11     = p_segment11
    or    (scl.segment11     is null
    and    p_segment11       is null))
    and   (scl.segment12     = p_segment12
    or    (scl.segment12     is null
    and    p_segment12       is null))
    and   (scl.segment13     = p_segment13
    or    (scl.segment13     is null
    and    p_segment13       is null))
    and   (scl.segment14     = p_segment14
    or    (scl.segment14      is null
    and    p_segment14       is null))
    and   (scl.segment15      = p_segment15
    or    (scl.segment15     is null
    and    p_segment15       is null))
    and   (scl.segment16     = p_segment16
    or    (scl.segment16     is null
    and    p_segment16       is null))
    and   (scl.segment17     = p_segment17
    or    (scl.segment17     is null
    and    p_segment17       is null))
    and   (scl.segment18     = p_segment18
    or    (scl.segment18     is null
    and    p_segment18       is null))
    and   (scl.segment19     = p_segment19
    or    (scl.segment19     is null
    and    p_segment19       is null))
    and   (scl.segment20     = p_segment20
    or    (scl.segment20     is null
    and    p_segment20       is null))
    and   (scl.segment21     = p_segment21
    or    (scl.segment21     is null
    and    p_segment21       is null))
    and   (scl.segment22     = p_segment22
    or    (scl.segment22     is null
    and    p_segment22       is null))
    and   (scl.segment23     = p_segment23
    or    (scl.segment23     is null
    and    p_segment23       is null))
    and   (scl.segment24     = p_segment24
    or    (scl.segment24     is null
    and    p_segment24       is null))
    and   (scl.segment25     = p_segment25
    or    (scl.segment25     is null
    and    p_segment25       is null))
    and   (scl.segment26     = p_segment26
    or    (scl.segment26     is null
    and    p_segment26       is null))
    and   (scl.segment27     = p_segment27
    or    (scl.segment27     is null
    and    p_segment27       is null))
    and   (scl.segment28     = p_segment28
    or    (scl.segment28     is null
    and    p_segment28       is null))
    and   (scl.segment29     = p_segment29
    or    (scl.segment29     is null
    and    p_segment29       is null))
    and   (scl.segment30     = p_segment30
    or    (scl.segment30     is null
    and    p_segment30       is null));
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.validate_bus_grp_id(p_business_group_id);
  --
  -- Determine if all the segments are null
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
      p_segment27 is null  and
      p_segment28 is null  and
      p_segment29 is null  and
      p_segment30 is null) then
     --
     -- as the segments are null set the p_id_flex_num
     -- explicitly to null.
     --
     hr_utility.set_location(l_proc, 10);
     p_id_flex_num            := null;
     p_soft_coding_keyflex_id := null;
     p_concatenated_segments  := null;
  else
    --
    -- segments exists therefore select the id_flex_num
    --
    hr_utility.set_location(l_proc, 15);
    open idsel;
    fetch idsel into l_id_flex_num;
    if idsel%notfound then
      close idsel;
      --
      -- the flex structure has not been found therefore we must error
      --
      hr_utility.set_message(801, 'HR_7384_ASG_INV_KEYFLEX_LINK');
      hr_utility.raise_error;
    end if;
    close idsel;
    hr_utility.set_location(l_proc, 10);
    p_id_flex_num := l_id_flex_num;
    --
    -- open and execute the partial segment cursor. if no rows are returned
    -- then p_soft_coding_keyflex_id must be set to -1 (indicating a
    -- new combination needs to be inserted.
    --
    hr_utility.set_location(l_proc, 20);
    open  sclsel;
    fetch sclsel into  p_soft_coding_keyflex_id, p_concatenated_segments;
    if sclsel%notfound then
      hr_utility.set_location(l_proc, 25);
      p_soft_coding_keyflex_id := -1;
      p_concatenated_segments  := null;
    end if;
    close sclsel;
  end if;
  --
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
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'HR_SOFT_CODING_KEYFLEX_PK') Then
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
  (p_soft_coding_keyflex_id in number) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	soft_coding_keyflex_id,
	concatenated_segments,
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
    from  hr_soft_coding_keyflex
    where soft_coding_keyflex_id = p_soft_coding_keyflex_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_soft_coding_keyflex_id is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_soft_coding_keyflex_id = g_old_rec.soft_coding_keyflex_id) Then
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
	p_soft_coding_keyflex_id        in number,
	p_concatenated_segments         in varchar2,
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
  l_rec.soft_coding_keyflex_id           := p_soft_coding_keyflex_id;
  l_rec.concatenated_segments            := p_concatenated_segments;
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
end hr_scl_shd;

/
