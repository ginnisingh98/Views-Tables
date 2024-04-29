--------------------------------------------------------
--  DDL for Package Body PAY_PGP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PGP_SHD" as
/* $Header: pypgprhi.pkb 115.0 99/07/17 06:22:02 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pgp_shd.';  -- Global package name
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
          p_people_group_id       out number,
          p_group_name            out varchar2,
          p_id_flex_num           out number) is
  --
  l_id_flex_num   pay_people_groups.id_flex_num%type;
  l_proc          varchar2(72) := g_package||'segment_combination_check';
  --
  -- the cursor orgsel selects the valid id_flex_num (people group kf)
  -- for the specified business group
  --
  cursor idsel is
    select  pbg.people_group_structure
    from    per_business_groups pbg
    where   pbg.business_group_id = p_business_group_id;
  --
  -- the cursor pgsel selects the people_group_id
  --
  cursor pgsel is
    select pgp.people_group_id,
           pgp.group_name
    from   pay_people_groups pgp
    where  pgp.id_flex_num   = l_id_flex_num
    and    pgp.enabled_flag  = 'Y'
    and   (pgp.segment1      = p_segment1
    or    (pgp.segment1      is null
    and    p_segment1        is null))
    and   (pgp.segment2      = p_segment2
    or    (pgp.segment2      is null
    and    p_segment2        is null))
    and   (pgp.segment3      = p_segment3
    or    (pgp.segment3      is null
    and    p_segment3        is null))
    and   (pgp.segment4      = p_segment4
    or    (pgp.segment4      is null
    and    p_segment4        is null))
    and   (pgp.segment5      = p_segment5
    or    (pgp.segment5      is null
    and    p_segment5        is null))
    and   (pgp.segment6      = p_segment6
    or    (pgp.segment6      is null
    and    p_segment6        is null))
    and   (pgp.segment7      = p_segment7
    or    (pgp.segment7      is null
    and    p_segment7        is null))
    and   (pgp.segment8      = p_segment8
    or    (pgp.segment8      is null
    and    p_segment8        is null))
    and   (pgp.segment9      = p_segment9
    or    (pgp.segment9      is null
    and    p_segment9        is null))
    and   (pgp.segment10     = p_segment10
    or    (pgp.segment10     is null
    and    p_segment10       is null))
    and   (pgp.segment11     = p_segment11
    or    (pgp.segment11     is null
    and    p_segment11       is null))
    and   (pgp.segment12     = p_segment12
    or    (pgp.segment12     is null
    and    p_segment12       is null))
    and   (pgp.segment13     = p_segment13
    or    (pgp.segment13     is null
    and    p_segment13       is null))
    and   (pgp.segment14     = p_segment14
    or    (pgp.segment14      is null
    and    p_segment14       is null))
    and   (pgp.segment15      = p_segment15
    or    (pgp.segment15     is null
    and    p_segment15       is null))
    and   (pgp.segment16     = p_segment16
    or    (pgp.segment16     is null
    and    p_segment16       is null))
    and   (pgp.segment17     = p_segment17
    or    (pgp.segment17     is null
    and    p_segment17       is null))
    and   (pgp.segment18     = p_segment18
    or    (pgp.segment18     is null
    and    p_segment18       is null))
    and   (pgp.segment19     = p_segment19
    or    (pgp.segment19     is null
    and    p_segment19       is null))
    and   (pgp.segment20     = p_segment20
    or    (pgp.segment20     is null
    and    p_segment20       is null))
    and   (pgp.segment21     = p_segment21
    or    (pgp.segment21     is null
    and    p_segment21       is null))
    and   (pgp.segment22     = p_segment22
    or    (pgp.segment22     is null
    and    p_segment22       is null))
    and   (pgp.segment23     = p_segment23
    or    (pgp.segment23     is null
    and    p_segment23       is null))
    and   (pgp.segment24     = p_segment24
    or    (pgp.segment24     is null
    and    p_segment24       is null))
    and   (pgp.segment25     = p_segment25
    or    (pgp.segment25     is null
    and    p_segment25       is null))
    and   (pgp.segment26     = p_segment26
    or    (pgp.segment26     is null
    and    p_segment26       is null))
    and   (pgp.segment27     = p_segment27
    or    (pgp.segment27     is null
    and    p_segment27       is null))
    and   (pgp.segment28     = p_segment28
    or    (pgp.segment28     is null
    and    p_segment28       is null))
    and   (pgp.segment29     = p_segment29
    or    (pgp.segment29     is null
    and    p_segment29       is null))
    and   (pgp.segment30     = p_segment30
    or    (pgp.segment30     is null
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
     p_id_flex_num           := null;
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
      hr_utility.set_message(801, 'HR_7471_FLEX_PEA_INVALID_ID');
      hr_utility.raise_error;
    end if;
    close idsel;
    hr_utility.set_location(l_proc, 10);
    p_id_flex_num := l_id_flex_num;
    --
    -- open and execute the partial segment cursor. if no rows are returned
    -- then p_people_group_id must be set to -1 (indicating a
    -- new combination needs to be inserted.
    --
    hr_utility.set_location(l_proc, 20);
    open  pgsel;
    fetch pgsel into  p_people_group_id, p_group_name;
    if pgsel%notfound then
      hr_utility.set_location(l_proc, 25);
      p_people_group_id   := -1;
      p_group_name        := null;
    end if;
    close pgsel;
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
  If (p_constraint_name = 'PAY_PEOPLE_GROUPS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating(p_people_group_id in number) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	people_group_id,
	group_name,
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
    from	pay_people_groups
    where	people_group_id = p_people_group_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_people_group_id is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_people_group_id = g_old_rec.people_group_id) Then
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
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_people_group_id               in number,
	p_group_name                    in varchar2,
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
  l_rec.people_group_id                  := p_people_group_id;
  l_rec.group_name                       := p_group_name;
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
end pay_pgp_shd;

/
