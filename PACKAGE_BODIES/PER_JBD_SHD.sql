--------------------------------------------------------
--  DDL for Package Body PER_JBD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JBD_SHD" as
/* $Header: pejbdrhi.pkb 115.1 99/07/18 13:54:47 porting ship $ */
--
-- ---------------------------------------------------------------------------
-- |                    Private Global Definitions                           |
-- ---------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_jbd_shd.';  -- Global package name
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
          p_job_definition_id      out number,
          p_name                   out varchar2,
          p_id_flex_num            out number) is
  --
  l_id_flex_num   number;
  l_proc          varchar2(72) := g_package||'segment_combination_check';
  --
  cursor idsel is
    select  pbg.job_structure
    from    per_business_groups pbg
    where   pbg.business_group_id = p_business_group_id;
  --
-- the cursor pgsel selects the job_definition_id
  --
  cursor pgsel is
    select jbd.job_definition_id
    from   per_job_definitions jbd
    where  jbd.id_flex_num   = l_id_flex_num
    and    jbd.enabled_flag  = 'Y'
    and   (jbd.segment1      = p_segment1
    or    (jbd.segment1      is null
    and    p_segment1        is null))
    and   (jbd.segment2      = p_segment2
    or    (jbd.segment2      is null
    and    p_segment2        is null))
    and   (jbd.segment3      = p_segment3
    or    (jbd.segment3      is null
    and    p_segment3        is null))
    and   (jbd.segment4      = p_segment4
    or    (jbd.segment4      is null
    and    p_segment4        is null))
    and   (jbd.segment5      = p_segment5
    or    (jbd.segment5      is null
    and    p_segment5        is null))
    and   (jbd.segment6      = p_segment6
    or    (jbd.segment6      is null
    and    p_segment6        is null))
    and   (jbd.segment7      = p_segment7
    or    (jbd.segment7      is null
    and    p_segment7        is null))
    and   (jbd.segment8      = p_segment8
    or    (jbd.segment8      is null
    and    p_segment8        is null))
    and   (jbd.segment9      = p_segment9
    or    (jbd.segment9      is null
    and    p_segment9        is null))
    and   (jbd.segment10     = p_segment10
    or    (jbd.segment10     is null
    and    p_segment10       is null))
    and   (jbd.segment11     = p_segment11
    or    (jbd.segment11     is null
    and    p_segment11       is null))
    and   (jbd.segment12     = p_segment12
    or    (jbd.segment12     is null
    and    p_segment12       is null))
    and   (jbd.segment13     = p_segment13
    or    (jbd.segment13     is null
    and    p_segment13       is null))
    and   (jbd.segment14     = p_segment14
    or    (jbd.segment14      is null
    and    p_segment14       is null))
    and   (jbd.segment15      = p_segment15
    or    (jbd.segment15     is null
    and    p_segment15       is null))
    and   (jbd.segment16     = p_segment16
    or    (jbd.segment16     is null
    and    p_segment16       is null))
    and   (jbd.segment17     = p_segment17
    or    (jbd.segment17     is null
    and    p_segment17       is null))
    and   (jbd.segment18     = p_segment18
    or    (jbd.segment18     is null
    and    p_segment18       is null))
    and   (jbd.segment19     = p_segment19
    or    (jbd.segment19     is null
    and    p_segment19       is null))
    and   (jbd.segment20     = p_segment20
    or    (jbd.segment20     is null
    and    p_segment20       is null))
    and   (jbd.segment21     = p_segment21
    or    (jbd.segment21     is null
    and    p_segment21       is null))
    and   (jbd.segment22     = p_segment22
    or    (jbd.segment22     is null
    and    p_segment22       is null))
    and   (jbd.segment23     = p_segment23
    or    (jbd.segment23     is null
    and    p_segment23       is null))
    and   (jbd.segment24     = p_segment24
    or    (jbd.segment24     is null
    and    p_segment24       is null))
    and   (jbd.segment25     = p_segment25
    or    (jbd.segment25     is null
    and    p_segment25       is null))
    and   (jbd.segment26     = p_segment26
    or    (jbd.segment26     is null
    and    p_segment26       is null))
    and   (jbd.segment27     = p_segment27
    or    (jbd.segment27     is null
    and    p_segment27       is null))
    and   (jbd.segment28     = p_segment28
    or    (jbd.segment28     is null
    and    p_segment28       is null))
    and   (jbd.segment29     = p_segment29
    or    (jbd.segment29     is null
    and    p_segment29       is null))
    and   (jbd.segment30     = p_segment30
    or    (jbd.segment30     is null
    and    p_segment30       is null));
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
     p_id_flex_num           := null;
     p_name                  := null;
     p_job_definition_id     := null;
  else
    --
    -- segments exists therefore select the id_flex_num
    -- First validate the business group id is mandatory.
    --
    hr_api.mandatory_arg_error(
      p_api_name       => l_proc,
      p_argument       => 'business_group_id',
      p_argument_value => p_business_group_id);
    hr_utility.set_location(l_proc, 15);
    --
    -- Now get the id_flex_num (and validate the business_group_id specified
    -- is valid.
    --
    open idsel;
    fetch idsel into l_id_flex_num;
    if idsel%notfound then
      close idsel;
      --
      -- The business group does not exist.
      --
      hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
      hr_utility.raise_error;
    end if;
    close idsel;
    --
    -- Check the id_flex_num is not-null
    --
    if l_id_flex_num is null then
      hr_utility.set_message(800, 'HR_52151_FLEX_JBD_INVALID_ID');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc, 20);
    p_id_flex_num := l_id_flex_num;
    --
    -- open and execute the partial segment cursor. if no rows are returned
    -- then p_job_definition_id must be set to -1 (indicating a
    -- new combination needs to be inserted.
    --
    hr_utility.set_location(l_proc, 25);
    open  pgsel;
    fetch pgsel into p_job_definition_id;
    if pgsel%notfound then
       hr_utility.set_location(l_proc, 30);
       p_job_definition_id   := -1;
    end if;
    close pgsel;
    --
    -- we must derive the job name
    --
    p_name :=
      hr_api.return_concat_kf_segments
         (p_id_flex_num => l_id_flex_num,
          p_segment1    => p_segment1,
          p_segment2    => p_segment2,
          p_segment3    => p_segment3,
          p_segment4    => p_segment4,
          p_segment5    => p_segment5,
          p_segment6    => p_segment6,
          p_segment7    => p_segment7,
          p_segment8    => p_segment8,
          p_segment9    => p_segment9,
          p_segment10   => p_segment10,
          p_segment11   => p_segment11,
          p_segment12   => p_segment12,
          p_segment13   => p_segment13,
          p_segment14   => p_segment14,
          p_segment15   => p_segment15,
          p_segment16   => p_segment16,
          p_segment17   => p_segment17,
          p_segment18   => p_segment18,
          p_segment19   => p_segment19,
          p_segment20   => p_segment20,
          p_segment21   => p_segment21,
          p_segment22   => p_segment22,
          p_segment23   => p_segment23,
          p_segment24   => p_segment24,
          p_segment25   => p_segment25,
          p_segment26   => p_segment26,
          p_segment27   => p_segment27,
          p_segment28   => p_segment28,
          p_segment29   => p_segment29,
          p_segment30   => p_segment30,
          p_application_id => 800,
          p_id_flex_code => 'JOB');

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
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PER_JOB_DEFINITIONS_PK') Then
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME',p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating(p_job_definition_id in number) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	job_definition_id,
	id_flex_num,
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
    from	per_job_definitions
    where	job_definition_id = p_job_definition_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_job_definition_id is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_job_definition_id = g_old_rec.job_definition_id) Then
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
-- |-----------------------------< convert_args >------------------------------
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_job_definition_id             in number,
	p_id_flex_num                   in number,
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
  l_rec.job_definition_id                := p_job_definition_id;
  l_rec.id_flex_num                      := p_id_flex_num;
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
end per_jbd_shd;

/
