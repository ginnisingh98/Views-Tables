--------------------------------------------------------
--  DDL for Package Body PER_POD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POD_SHD" as
/* $Header: pepodrhi.pkb 115.6 2002/12/04 10:56:05 eumenyio ship $ */
--
-- ---------------------------------------------------------------------------
-- |                    Private Global Definitions                           |
-- ---------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pod_shd.';  -- Global package name
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
          p_position_definition_id out nocopy number,
          p_name                   out nocopy varchar2,
          p_id_flex_num            out nocopy number) is
  --
  l_id_flex_num   number;
  l_proc          varchar2(72) := g_package||'segment_combination_check';

  --
  -- the cursor orgsel selects the valid id_flex_num (position def kf)
  -- for the specified business group
  --
  cursor idsel is
    select  pbg.position_structure
    from    per_business_groups pbg
    where   pbg.business_group_id = p_business_group_id;
  --
  -- Modified cursor definition Bug 2559439
    cursor pgsel is
    select pod.position_definition_id
      from per_positions pod
      where name = p_name
      and   exists (select 'x'
                    from  per_position_definitions ppd
                    where ppd.position_definition_id = pod.position_definition_id
                    and   ppd.id_flex_num   = l_id_flex_num
                    and   ppd.enabled_flag  = 'Y');

  -- the cursor pgsel selects the position_definition_id
  --
  --  cursor pgsel is
  --    select pod.position_definition_id
  --    from   per_position_definitions pod
  --    where  pod.id_flex_num   = l_id_flex_num
  --    and    pod.enabled_flag  = 'Y'
  --    and   (pod.segment1      = p_segment1
  --    or    (pod.segment1      is null
  --    and    p_segment1        is null))
  --    and   (pod.segment2      = p_segment2
  --    or    (pod.segment2      is null
  --    and    p_segment2        is null))
  --    and   (pod.segment3      = p_segment3
  --    or    (pod.segment3      is null
  --    and    p_segment3        is null))
  --    and   (pod.segment4      = p_segment4
  --    or    (pod.segment4      is null
  --    and    p_segment4        is null))
  --    and   (pod.segment5      = p_segment5
  --    or    (pod.segment5      is null
  --    and    p_segment5        is null))
  --    and   (pod.segment6      = p_segment6
  --    or    (pod.segment6      is null
  --    and    p_segment6        is null))
  --    and   (pod.segment7      = p_segment7
  --    or    (pod.segment7      is null
  --    and    p_segment7        is null))
  --    and   (pod.segment8      = p_segment8
  --    or    (pod.segment8      is null
  --    and    p_segment8        is null))
  --    and   (pod.segment9      = p_segment9
  --    or    (pod.segment9      is null
  --    and    p_segment9        is null))
  --    and   (pod.segment10     = p_segment10
  --    or    (pod.segment10     is null
  --    and    p_segment10       is null))
  --    and   (pod.segment11     = p_segment11
  --    or    (pod.segment11     is null
  --    and    p_segment11       is null))
  --    and   (pod.segment12     = p_segment12
  --    or    (pod.segment12     is null
  --    and    p_segment12       is null))
  --    and   (pod.segment13     = p_segment13
  --    or    (pod.segment13     is null
  --    and    p_segment13       is null))
  --    and   (pod.segment14     = p_segment14
  --    or    (pod.segment14      is null
  --    and    p_segment14       is null))
  --    and   (pod.segment15      = p_segment15
  --    or    (pod.segment15     is null
  --    and    p_segment15       is null))
  --    and   (pod.segment16     = p_segment16
  --    or    (pod.segment16     is null
  --    and    p_segment16       is null))
  --    and   (pod.segment17     = p_segment17
  --    or    (pod.segment17     is null
  --    and    p_segment17       is null))
  --    and   (pod.segment18     = p_segment18
  --    or    (pod.segment18     is null
  --    and    p_segment18       is null))
  --    and   (pod.segment19     = p_segment19
  --    or    (pod.segment19     is null
  --    and    p_segment19       is null))
  --    and   (pod.segment20     = p_segment20
  --    or    (pod.segment20     is null
  --    and    p_segment20       is null))
  --    and   (pod.segment21     = p_segment21
  --    or    (pod.segment21     is null
  --    and    p_segment21       is null))
  --    and   (pod.segment22     = p_segment22
  --    or    (pod.segment22     is null
  --    and    p_segment22       is null))
  --    and   (pod.segment23     = p_segment23
  --    or    (pod.segment23     is null
  --    and    p_segment23       is null))
  --    and   (pod.segment24     = p_segment24
  --    or    (pod.segment24     is null
  --    and    p_segment24       is null))
  --    and   (pod.segment25     = p_segment25
  --    or    (pod.segment25     is null
  --    and    p_segment25       is null))
  --    and   (pod.segment26     = p_segment26
  --    or    (pod.segment26     is null
  --    and    p_segment26       is null))
  --    and   (pod.segment27     = p_segment27
  --    or    (pod.segment27     is null
  --    and    p_segment27       is null))
  --    and   (pod.segment28     = p_segment28
  --    or    (pod.segment28     is null
  --    and    p_segment28       is null))
  --    and   (pod.segment29     = p_segment29
  --    or    (pod.segment29     is null
  --    and    p_segment29       is null))
  --    and   (pod.segment30     = p_segment30
  --    or    (pod.segment30     is null
  --    and    p_segment30       is null));
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
     p_id_flex_num           := null;
     p_name                  := null;
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
      hr_utility.set_message(801, 'HR_51054_FLEX_POD_INVALID_ID');
      hr_utility.raise_error;
    end if;
    close idsel;
    hr_utility.set_location(l_proc, 10);
    p_id_flex_num := l_id_flex_num;
--
    -- open and execute the partial segment cursor. if no rows are returned
    -- then p_position_definition_id must be set to -1 (indicating a
    -- new combination needs to be inserted.
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- we must derive the position name
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
          p_id_flex_code => 'POS');

    open  pgsel;
    fetch pgsel into p_position_definition_id;
    if pgsel%notfound then
      hr_utility.set_location(l_proc, 25);
      p_position_definition_id   := -1;
    end if;
    close pgsel;

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
  If (p_constraint_name = 'PER_POSITION_DEFINITIONS_PK') Then
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
Function api_updating(p_position_definition_id in number) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	position_definition_id,
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
    from	per_position_definitions
    where	position_definition_id = p_position_definition_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_position_definition_id is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_position_definition_id = g_old_rec.position_definition_id) Then
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
	p_position_definition_id        in number,
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
  l_rec.position_definition_id           := p_position_definition_id;
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
end per_pod_shd;

/
