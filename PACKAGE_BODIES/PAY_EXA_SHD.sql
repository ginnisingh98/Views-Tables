--------------------------------------------------------
--  DDL for Package Body PAY_EXA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EXA_SHD" AS
/* $Header: pyexarhi.pkb 115.13 2003/09/26 06:48:50 tvankayl ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_exa_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
function return_api_dml_status return boolean is
  --
  l_proc    varchar2(72) := g_package||'return_api_dml_status';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return(nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
procedure constraint_error(
   p_constraint_name in all_constraints.constraint_name%TYPE
   ) is
--
  l_proc    varchar2(72) := g_package||'constraint_error';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PAY_EXTERNAL_ACCOUNTS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  Else
    -- [start of change: 40.5, Dave Harris]
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
    -- [ end of change: 40.5, Dave Harris]
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
function api_updating(
   p_external_account_id                in number
  ,p_object_version_number              in number
  )
  return boolean is
  --
  -- cursor selects the 'current' row from the HR schema
  --
  cursor C_Sel1 is
    SELECT external_account_id,
           territory_code,
           prenote_date,
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
           segment30,
           object_version_number
    FROM   PAY_EXTERNAL_ACCOUNTS
    WHERE  external_account_id = p_external_account_id
    ;
  --
  l_proc    varchar2(72)    := g_package||'api_updating';
  l_fct_ret boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- external account id null, must be I'ing, return false
  --
  If (p_external_account_id is null and
      p_object_version_number is null) Then
    l_fct_ret := false;
  --
  -- external account id NOT null, must be U'ing
  --
  Else
    If (p_external_account_id   = g_old_rec.external_account_id and
        p_object_version_number = g_old_rec.object_version_number) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- g_old_rec is current
      --
      l_fct_ret := true;
    Else
      --
      -- select the current row into g_old_rec
      --
      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;

      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- the primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;

      Close C_Sel1;

      --
      -- if the object version number just selected into g_old_rec does
      -- not match the object version number passed in,
      -- raise error
      --
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
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
procedure lck(
   p_external_account_id                in number
  ,p_object_version_number              in number
  ) is
  --
  -- cursor selects the 'current' row from the HR schema
  --
  Cursor C_Sel1 is
    select
        external_account_id,
        territory_code,
        prenote_date,
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
        segment30,
        object_version_number
    from    pay_external_accounts
    where   external_account_id = p_external_account_id
    for update nowait;
  --
  l_proc    varchar2(72) := g_package||'lck';
  --
begin
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
    hr_utility.set_message_token('TABLE_NAME', 'pay_external_accounts');
    hr_utility.raise_error;
end lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
function convert_args(
   p_external_account_id           in number
  ,p_territory_code                in varchar2
  ,p_prenote_date                  in date
  ,p_id_flex_num                   in number
  ,p_summary_flag                  in varchar2
  ,p_enabled_flag                  in varchar2
  ,p_start_date_active             in date
  ,p_end_date_active               in date
  ,p_segment1                      in varchar2
  ,p_segment2                      in varchar2
  ,p_segment3                      in varchar2
  ,p_segment4                      in varchar2
  ,p_segment5                      in varchar2
  ,p_segment6                      in varchar2
  ,p_segment7                      in varchar2
  ,p_segment8                      in varchar2
  ,p_segment9                      in varchar2
  ,p_segment10                     in varchar2
  ,p_segment11                     in varchar2
  ,p_segment12                     in varchar2
  ,p_segment13                     in varchar2
  ,p_segment14                     in varchar2
  ,p_segment15                     in varchar2
  ,p_segment16                     in varchar2
  ,p_segment17                     in varchar2
  ,p_segment18                     in varchar2
  ,p_segment19                     in varchar2
  ,p_segment20                     in varchar2
  ,p_segment21                     in varchar2
  ,p_segment22                     in varchar2
  ,p_segment23                     in varchar2
  ,p_segment24                     in varchar2
  ,p_segment25                     in varchar2
  ,p_segment26                     in varchar2
  ,p_segment27                     in varchar2
  ,p_segment28                     in varchar2
  ,p_segment29                     in varchar2
  ,p_segment30                     in varchar2
  ,p_object_version_number         in number
  )
  return g_rec_type is
  --
  l_rec   g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- convert arguments into local l_rec structure
  --
  l_rec.external_account_id              := p_external_account_id;
  l_rec.territory_code                   := p_territory_code;
  l_rec.prenote_date                     := p_prenote_date;
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
  l_rec.object_version_number            := p_object_version_number;
  --
  -- return the plsql record structure
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
  --
end convert_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< keyflex_comb >-----------------------------|
-- ----------------------------------------------------------------------------
procedure keyflex_comb(
   p_dml_mode                      in     varchar2 default null
  ,p_business_group_id             in     number
  ,p_appl_short_name               in     fnd_application.application_short_name%TYPE
  ,p_territory_code                in     varchar2 default null
  ,p_flex_code                     in     fnd_id_flex_segments.id_flex_code%TYPE
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_concat_segments_in            in     varchar2 default null
  ,p_ccid                          in out nocopy number
  ,p_concat_segments_out           out    nocopy varchar2
  ) is
  --
  l_proc  varchar2(72) := g_package||'keyflex_comb';
  --
  l_id_flex_num           pay_external_accounts.id_flex_num%type;
  --
  -- the cursor orgsel selects the valid id_flex_num (external account kf)
  -- for the specified business group
  --
  cursor csr_id_flex_num is
    SELECT  fnd_number.canonical_to_number(plr.rule_mode)
	FROM    PAY_LEGISLATION_RULES plr,
		PER_BUSINESS_GROUPS   pbg
	WHERE   plr.rule_type         = 'E'
	and     p_territory_code is null
	and     plr.legislation_code  = pbg.legislation_code
	and     pbg.business_group_id = p_business_group_id
    Union
    SELECT  fnd_number.canonical_to_number(plr.rule_mode)
	FROM    PAY_LEGISLATION_RULES plr
	WHERE   plr.rule_type         = 'E'
	and     p_territory_code is not null
	and     plr.legislation_code  = p_territory_code;

--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(l_proc, 10);
    open csr_id_flex_num;
    fetch csr_id_flex_num into l_id_flex_num;
    --
    if csr_id_flex_num%notfound then
      close csr_id_flex_num;
      --
      -- the flex structure has not been found therefore we must error
      --
      hr_utility.set_message(801, 'HR_7471_FLEX_PEA_INVALID_ID');
      hr_utility.raise_error;
    end if;
    close csr_id_flex_num;
  hr_utility.set_location(l_proc, 20);
  --
  hr_utility.trace('| l_id_flex_num>' || l_id_flex_num || '<');
  --
  -- do not want trigger to maintain object version number,
  -- will be done explicitly later by api
  --
  pay_exa_shd.g_api_dml := true;  -- set the api dml status
  --
  begin
    if p_dml_mode = 'INSERT' then
      hr_utility.trace('| doing insert interface processing');
        --
        -- ins_or_sel_keyflex_comb() does either an I or U, therefore
        -- l_external_account_id always has a value,
        -- nb. p_concat_segments, if specified, will take precedence over
        -- p_segment1 ... 30
        --
        hr_kflex_utility.ins_or_sel_keyflex_comb(
          p_appl_short_name        => 'PAY',
          p_flex_code              => 'BANK',
          p_flex_num               => l_id_flex_num,
          p_segment1               => p_segment1,
          p_segment2               => p_segment2,
          p_segment3               => p_segment3,
          p_segment4               => p_segment4,
          p_segment5               => p_segment5,
          p_segment6               => p_segment6,
          p_segment7               => p_segment7,
          p_segment8               => p_segment8,
          p_segment9               => p_segment9,
          p_segment10              => p_segment10,
          p_segment11              => p_segment11,
          p_segment12              => p_segment12,
          p_segment13              => p_segment13,
          p_segment14              => p_segment14,
          p_segment15              => p_segment15,
          p_segment16              => p_segment16,
          p_segment17              => p_segment17,
          p_segment18              => p_segment18,
          p_segment19              => p_segment19,
          p_segment20              => p_segment20,
          p_segment21              => p_segment21,
          p_segment22              => p_segment22,
          p_segment23              => p_segment23,
          p_segment24              => p_segment24,
          p_segment25              => p_segment25,
          p_segment26              => p_segment26,
          p_segment27              => p_segment27,
          p_segment28              => p_segment28,
          p_segment29              => p_segment29,
          p_segment30              => p_segment30,
          p_concat_segments_in     => p_concat_segments_in,
          --
          -- code combination id only passed in
          --
          p_ccid                   => p_ccid,
          p_concat_segments_out    => p_concat_segments_out
        );
    --
    elsif p_dml_mode = 'UPDATE' then
      hr_utility.trace('| doing update interface processing');
        --
        -- U of kff details for a given entity,
        -- ccid is used to build up a plsql table of segment values,
        -- this table is compared against IN parameters: segments 1 ... 30,
        -- create a new table which may contain U'ed segment values,
        -- then call check_segment_combination(), this will create a
        -- new combination row if required
        --
        hr_kflex_utility.upd_or_sel_keyflex_comb(
          p_appl_short_name        => 'PAY',
          p_flex_code              => 'BANK',
          p_flex_num               => l_id_flex_num,
          p_segment1               => p_segment1,
          p_segment2               => p_segment2,
          p_segment3               => p_segment3,
          p_segment4               => p_segment4,
          p_segment5               => p_segment5,
          p_segment6               => p_segment6,
          p_segment7               => p_segment7,
          p_segment8               => p_segment8,
          p_segment9               => p_segment9,
          p_segment10              => p_segment10,
          p_segment11              => p_segment11,
          p_segment12              => p_segment12,
          p_segment13              => p_segment13,
          p_segment14              => p_segment14,
          p_segment15              => p_segment15,
          p_segment16              => p_segment16,
          p_segment17              => p_segment17,
          p_segment18              => p_segment18,
          p_segment19              => p_segment19,
          p_segment20              => p_segment20,
          p_segment21              => p_segment21,
          p_segment22              => p_segment22,
          p_segment23              => p_segment23,
          p_segment24              => p_segment24,
          p_segment25              => p_segment25,
          p_segment26              => p_segment26,
          p_segment27              => p_segment27,
          p_segment28              => p_segment28,
          p_segment29              => p_segment29,
          p_segment30              => p_segment30,
          p_concat_segments_in     => p_concat_segments_in,
          --
          -- code combination id only passed in/out
          --
          p_ccid                   => p_ccid,
          p_concat_segments_out    => p_concat_segments_out
        );
    --
    else
      null;
      --
      -- stub - error, invalid mode
      --
    end if;
  exception
    when app_exception.application_exception then
      hr_message.provide_error;
      hr_utility.trace('*****' || p_territory_code);
      hr_utility.trace('*****' || hr_message.last_message_name);
      hr_utility.trace('*****' || hr_message.get_token_value('COLUMN'));

      --
      -- if any validation fails on a segment, the exception
      -- HR_FLEX_VALUE_INVALID is thrown,
      -- therefore still need to check the type of failure
      -- so the appropriate message, if it exists, can be passed
      -- to the client
      --

      --
      -- us segment 1
      --
      if p_territory_code = 'US' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT1' then
            if (length(p_segment1) > 60) then
              hr_utility.set_message(801, 'HR_51458_EXA_US_ACCT_NAME_LONG');
              hr_utility.raise_error;
            end if;
          end if;
        end if;
      end if;

      --
      -- us segment 2
      --
      if p_territory_code = 'US' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT2' then
            if (length(p_segment1) > 80) then
              hr_utility.set_message(801, 'HR_51459_EXA_US_ACCT_TYPE_LONG');
              hr_utility.raise_error;
            else
              declare
                cursor fnd_com_look is
                  select null
                  from   fnd_common_lookups
                  where  lookup_type = 'US_ACCOUNT_TYPE'
                  and    application_id = 800
                  and    lookup_code = p_segment2;
                l_dummy   number;
              begin
                --
                -- ensure that the p_segment2 is valid and exists
                --
                open fnd_com_look;
                fetch fnd_com_look into l_dummy;
                if fnd_com_look%notfound then
                  close fnd_com_look;
                  hr_utility.set_message(801,
                                          'HR_51460_EXA_US_ACC_TYP_UNKNOW');
                  hr_utility.raise_error;
                end if;
                close fnd_com_look;
              end;  -- end of anonymous block
            end if;
          end if;
        end if;
      end if;

      --
      -- us segment 3
      --
      if p_territory_code = 'US' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT3' then
            if (length(p_segment1) > 60) then
              hr_utility.set_message(801, 'HR_51461_EXA_US_ACCT_NO_LONG');
              hr_utility.raise_error;
            end if;
          end if;
        end if;
      end if;

      --
      -- us segment 4
      --
      if p_territory_code = 'US' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT4' then
            if (length(p_segment4) > 9) then
              hr_utility.set_message(801, 'HR_51462_EXA_US_TRAN_CODE_LONG');
              hr_utility.raise_error;
            end if;
          end if;
        end if;
      end if;

      --
      -- us segment 5
      --
      if p_territory_code = 'US' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT5' then
            if (length(p_segment5) > 60) then
              hr_utility.set_message(801, 'HR_51463_EXA_US_BANK_NAME_LONG');
              hr_utility.raise_error;
            end if;
          end if;
        end if;
      end if;

      --
      -- us segment 6
      --
      if p_territory_code = 'US' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT6' then
            if (length(p_segment6) > 60) then
              hr_utility.set_message(801, 'HR_51464_EXA_US_BANK_BRAN_LONG');
              hr_utility.raise_error;
            end if;
          end if;
        end if;
      end if;

      --
      -- stub - have not included us segment checks 7 to 30 as the tokens
      --        ARG_NAME and ARG_VALUE are populated dynamically
      --

--------------------------------------------------------------------------------

      --
      -- gb segment 1
      --
      if p_territory_code = 'GB' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT1' then
            if (length(p_segment1) > 30) then
              hr_utility.set_message(801, 'HR_51416_EXA_BANK_NAME_LONG');
              hr_utility.raise_error;
            else
              declare
                cursor hlsel is
                  select null
                  from   hr_lookups
                  where  lookup_type = 'GB_BANKS'
                  and    lookup_code = p_segment1;
                l_dummy   number;
              begin
                --
                -- ensure that the p_segment1 is valid and exists
                --
                open hlsel;
                fetch hlsel into l_dummy;
                if hlsel%notfound then
                  close hlsel;
                  hr_utility.set_message(801,
                                           'HR_51417_EXA_BANK_NAME_UNKNOWN');
                  hr_utility.raise_error;
                end if;
                close hlsel;
              end;  -- end of anonymous block
            end if;
          end if;
        end if;
      end if;

      --
      -- gb segment 2
      --
      if p_territory_code = 'GB' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT2' then
            if (length(p_segment1) > 35) then
              hr_utility.set_message(801, 'HR_51418_EXA_BANK_BRANCH_LONG');
              hr_utility.raise_error;
            end if;
          end if;
        end if;
      end if;

      --
      -- gb segment 3
      --
      if p_territory_code = 'GB' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT3' then
            --
            -- ensure that the length is 6
            --
            if (length(p_segment3) <> 6) then
              hr_utility.set_message(801, 'HR_51419_EXA_SORT_CODE_LENGTH');
              hr_utility.raise_error;
            --
            -- ensure that p_segment3 is +ve
            --
            elsif (to_number(p_segment3) < 0) then
              hr_utility.set_message(801, 'HR_51420_EXA_SORT_CODE_POSITVE');
              hr_utility.raise_error;
            end if;
          end if;
        end if;
      end if;

      --
      -- gb segment 4
      --
      if p_territory_code = 'GB' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT4' then
            --
            -- ensure that the length is 8
            --
            if (length(p_segment4) <> 8) then
              hr_utility.set_message(801, 'HR_51421_EXA_ACCOUNT_NO_LONG');
              hr_utility.raise_error;
            --
            -- ensure that p_segment4 is +ve
            --
            elsif (to_number(p_segment4) < 0) then
              hr_utility.set_message(801, 'HR_51422_EXA_ACCT_NO_POSITIVE');
              hr_utility.raise_error;
            end if;
          end if;
        end if;
      end if;

      --
      -- gb segment 5
      --
      if p_territory_code = 'GB' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT5' then
            --
            -- ensure that the length does not exceed 18
            --
            if (length(p_segment5) > 18) then
              hr_utility.set_message(801, 'HR_51423_EXA_ACCOUNT_NAME_LONG');
              hr_utility.raise_error;
            --
            -- ensure that the p_segment5 is in an upperformat format
            --
            elsif (p_segment5 <> upper(p_segment5)) then
              hr_utility.set_message(801, 'HR_51424_EXA_ACCOUNT_NAME_CASE');
              hr_utility.raise_error;
            end if;
          end if;
        end if;
      end if;

      --
      -- gb segment 6
      --
      if p_territory_code = 'GB' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT6' then
            --
            -- ensure that the length does not exceed 1
            --
            if (length(p_segment6) > 1) then
              hr_utility.set_message(801, 'HR_51425_EXA_ACCOUNT_TYPE_LONG');
              hr_utility.raise_error;
            --
            -- ensure that p_segment4 is in the range of: 0 -> 5
            --
            elsif (to_number(p_segment6) < 0 or
                   to_number(p_segment6) > 5) then
              hr_utility.set_message(801, 'HR_51426_EXA_ACCT_TYPE_RANGE');
              hr_utility.raise_error;
            end if;
          end if;
        end if;
      end if;

      --
      -- gb segment 7
      --
      if p_territory_code = 'GB' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT7' then
            --
            -- ensure that the length does not exceed 18
            --
            if (length(p_segment7) > 18) then
              hr_utility.set_message(801, 'HR_51427_EXA_BS_ACCT_NO_LONG');
              hr_utility.raise_error;
            --
            -- ensure that the p_segment7 is in an uppercase format
            --
            elsif (p_segment7 <> upper(p_segment7)) then
              hr_utility.set_message(801, 'HR_51428_EXA_BS_ACCT_NO_CASE');
              hr_utility.raise_error;
            end if;
          end if;
        end if;
      end if;

      --
      -- gb segment 8
      --
      if p_territory_code = 'GB' then
        if hr_message.last_message_name = 'HR_FLEX_VALUE_INVALID' then
          if hr_message.get_token_value('COLUMN') = 'SEGMENT8' then
            --
            -- ensure that the length does not exceed 20
            --
            if (length(p_segment8) > 20) then
              hr_utility.set_message(801, 'HR_51429_EXA_BANK_LOC_LONG');
              hr_utility.raise_error;
            else
              declare
                l_exists      varchar2(80);
                cursor csr_chk_hr_lookups is
                  select null
                  from hr_lookups
                  where LOOKUP_TYPE = 'GB_COUNTRY'
                  and   lookup_code = p_segment8;
              begin
                --
                -- ensure that the p_segment8 exists in hr_lookups where
                -- lookup_type = 'GB_COUNTRY'
                --
                open csr_chk_hr_lookups;
                fetch csr_chk_hr_lookups into l_exists;
                if csr_chk_hr_lookups%notfound then
                  close csr_chk_hr_lookups;
                  hr_utility.set_message(801,
                                          'HR_51430_EXA_BANK_LOC_UNKNOWN');
                  hr_utility.raise_error;
                end if;
                close csr_chk_hr_lookups;
              end;  -- end of anonymous block
            end if;
          end if;
        end if;
      end if;

      --
      -- stub - have not included us segment checks 9 to 30 as the tokens
      --        ARG_NAME and ARG_VALUE are populated dynamically
      --

      --
      -- do not trap any other errors
      --
      raise;
  end;  -- end of anonymous block
  --
  pay_exa_shd.g_api_dml := false;  -- set the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
--
end keyflex_comb;
END pay_exa_shd;

/
