--------------------------------------------------------
--  DDL for Package Body PAY_BTL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BTL_SHD" as
/* $Header: pybtlrhi.pkb 120.7 2005/11/09 08:16:09 mkataria noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_btl_shd.';  -- Global package name

--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (
  p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PAY_BATCH_LINES_FK3') Then
    fnd_message.set_name('PAY', 'PAY_52680_BHT_INVALID_HEADER');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BATCH_LINES_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BCHL_BATCH_LINE_STATUS_CHK') Then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME','BATCH_LINE_STATUS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_BCHL_ENTRY_TYPE_CHK') Then
    fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
    fnd_message.set_token('COLUMN_NAME','ENTRY_TYPE');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_batch_line_id                        in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       batch_line_id
      ,cost_allocation_keyflex_id
      ,element_type_id
      ,assignment_id
      ,batch_id
      ,batch_line_status
      ,assignment_number
      ,batch_sequence
      ,concatenated_segments
      ,effective_date
      ,element_name
      ,entry_type
      ,reason
      ,segment1
      ,segment2
      ,segment3
      ,segment4
      ,segment5
      ,segment6
      ,segment7
      ,segment8
      ,segment9
      ,segment10
      ,segment11
      ,segment12
      ,segment13
      ,segment14
      ,segment15
      ,segment16
      ,segment17
      ,segment18
      ,segment19
      ,segment20
      ,segment21
      ,segment22
      ,segment23
      ,segment24
      ,segment25
      ,segment26
      ,segment27
      ,segment28
      ,segment29
      ,segment30
      ,value_1
      ,value_2
      ,value_3
      ,value_4
      ,value_5
      ,value_6
      ,value_7
      ,value_8
      ,value_9
      ,value_10
      ,value_11
      ,value_12
      ,value_13
      ,value_14
      ,value_15
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,entry_information_category
      ,entry_information1
      ,entry_information2
      ,entry_information3
      ,entry_information4
      ,entry_information5
      ,entry_information6
      ,entry_information7
      ,entry_information8
      ,entry_information9
      ,entry_information10
      ,entry_information11
      ,entry_information12
      ,entry_information13
      ,entry_information14
      ,entry_information15
      ,entry_information16
      ,entry_information17
      ,entry_information18
      ,entry_information19
      ,entry_information20
      ,entry_information21
      ,entry_information22
      ,entry_information23
      ,entry_information24
      ,entry_information25
      ,entry_information26
      ,entry_information27
      ,entry_information28
      ,entry_information29
      ,entry_information30
      ,date_earned
      ,personal_payment_method_id
      ,subpriority
      ,effective_start_date
      ,effective_end_date
      ,object_version_number
    from	pay_batch_lines
    where	batch_line_id = p_batch_line_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_batch_line_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_batch_line_id
        = pay_btl_shd.g_old_rec.batch_line_id and
        p_object_version_number
        = pay_btl_shd.g_old_rec.object_version_number
       ) Then
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
      Fetch C_Sel1 Into pay_btl_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> pay_btl_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_batch_line_id                        in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       batch_line_id
      ,cost_allocation_keyflex_id
      ,element_type_id
      ,assignment_id
      ,batch_id
      ,batch_line_status
      ,assignment_number
      ,batch_sequence
      ,concatenated_segments
      ,effective_date
      ,element_name
      ,entry_type
      ,reason
      ,segment1
      ,segment2
      ,segment3
      ,segment4
      ,segment5
      ,segment6
      ,segment7
      ,segment8
      ,segment9
      ,segment10
      ,segment11
      ,segment12
      ,segment13
      ,segment14
      ,segment15
      ,segment16
      ,segment17
      ,segment18
      ,segment19
      ,segment20
      ,segment21
      ,segment22
      ,segment23
      ,segment24
      ,segment25
      ,segment26
      ,segment27
      ,segment28
      ,segment29
      ,segment30
      ,value_1
      ,value_2
      ,value_3
      ,value_4
      ,value_5
      ,value_6
      ,value_7
      ,value_8
      ,value_9
      ,value_10
      ,value_11
      ,value_12
      ,value_13
      ,value_14
      ,value_15
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,entry_information_category
      ,entry_information1
      ,entry_information2
      ,entry_information3
      ,entry_information4
      ,entry_information5
      ,entry_information6
      ,entry_information7
      ,entry_information8
      ,entry_information9
      ,entry_information10
      ,entry_information11
      ,entry_information12
      ,entry_information13
      ,entry_information14
      ,entry_information15
      ,entry_information16
      ,entry_information17
      ,entry_information18
      ,entry_information19
      ,entry_information20
      ,entry_information21
      ,entry_information22
      ,entry_information23
      ,entry_information24
      ,entry_information25
      ,entry_information26
      ,entry_information27
      ,entry_information28
      ,entry_information29
      ,entry_information30
      ,date_earned
      ,personal_payment_method_id
      ,subpriority
      ,effective_start_date
      ,effective_end_date
      ,object_version_number
    from	pay_batch_lines
    where	batch_line_id = p_batch_line_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'BATCH_LINE_ID'
    ,p_argument_value     => p_batch_line_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pay_btl_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> pay_btl_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'pay_batch_lines');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_batch_line_id                  in number
  ,p_cost_allocation_keyflex_id     in number
  ,p_element_type_id                in number
  ,p_assignment_id                  in number
  ,p_batch_id                       in number
  ,p_batch_line_status              in varchar2
  ,p_assignment_number              in varchar2
  ,p_batch_sequence                 in number
  ,p_concatenated_segments          in varchar2
  ,p_effective_date                 in date
  ,p_element_name                   in varchar2
  ,p_entry_type                     in varchar2
  ,p_reason                         in varchar2
  ,p_segment1                       in varchar2
  ,p_segment2                       in varchar2
  ,p_segment3                       in varchar2
  ,p_segment4                       in varchar2
  ,p_segment5                       in varchar2
  ,p_segment6                       in varchar2
  ,p_segment7                       in varchar2
  ,p_segment8                       in varchar2
  ,p_segment9                       in varchar2
  ,p_segment10                      in varchar2
  ,p_segment11                      in varchar2
  ,p_segment12                      in varchar2
  ,p_segment13                      in varchar2
  ,p_segment14                      in varchar2
  ,p_segment15                      in varchar2
  ,p_segment16                      in varchar2
  ,p_segment17                      in varchar2
  ,p_segment18                      in varchar2
  ,p_segment19                      in varchar2
  ,p_segment20                      in varchar2
  ,p_segment21                      in varchar2
  ,p_segment22                      in varchar2
  ,p_segment23                      in varchar2
  ,p_segment24                      in varchar2
  ,p_segment25                      in varchar2
  ,p_segment26                      in varchar2
  ,p_segment27                      in varchar2
  ,p_segment28                      in varchar2
  ,p_segment29                      in varchar2
  ,p_segment30                      in varchar2
  ,p_value_1                        in varchar2
  ,p_value_2                        in varchar2
  ,p_value_3                        in varchar2
  ,p_value_4                        in varchar2
  ,p_value_5                        in varchar2
  ,p_value_6                        in varchar2
  ,p_value_7                        in varchar2
  ,p_value_8                        in varchar2
  ,p_value_9                        in varchar2
  ,p_value_10                       in varchar2
  ,p_value_11                       in varchar2
  ,p_value_12                       in varchar2
  ,p_value_13                       in varchar2
  ,p_value_14                       in varchar2
  ,p_value_15                       in varchar2
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_entry_information_category     in varchar2
  ,p_entry_information1             in varchar2
  ,p_entry_information2             in varchar2
  ,p_entry_information3             in varchar2
  ,p_entry_information4             in varchar2
  ,p_entry_information5             in varchar2
  ,p_entry_information6             in varchar2
  ,p_entry_information7             in varchar2
  ,p_entry_information8             in varchar2
  ,p_entry_information9             in varchar2
  ,p_entry_information10            in varchar2
  ,p_entry_information11            in varchar2
  ,p_entry_information12            in varchar2
  ,p_entry_information13            in varchar2
  ,p_entry_information14            in varchar2
  ,p_entry_information15            in varchar2
  ,p_entry_information16            in varchar2
  ,p_entry_information17            in varchar2
  ,p_entry_information18            in varchar2
  ,p_entry_information19            in varchar2
  ,p_entry_information20            in varchar2
  ,p_entry_information21            in varchar2
  ,p_entry_information22            in varchar2
  ,p_entry_information23            in varchar2
  ,p_entry_information24            in varchar2
  ,p_entry_information25            in varchar2
  ,p_entry_information26            in varchar2
  ,p_entry_information27            in varchar2
  ,p_entry_information28            in varchar2
  ,p_entry_information29            in varchar2
  ,p_entry_information30            in varchar2
  ,p_date_earned                    in date
  ,p_personal_payment_method_id     in number
  ,p_subpriority                    in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.batch_line_id                    := p_batch_line_id;
  l_rec.cost_allocation_keyflex_id       := p_cost_allocation_keyflex_id;
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.batch_id                         := p_batch_id;
  l_rec.batch_line_status                := p_batch_line_status;
  l_rec.assignment_number                := p_assignment_number;
  l_rec.batch_sequence                   := p_batch_sequence;
  l_rec.concatenated_segments            := p_concatenated_segments;
  l_rec.effective_date                   := p_effective_date;
  l_rec.element_name                     := p_element_name;
  l_rec.entry_type                       := p_entry_type;
  l_rec.reason                           := p_reason;
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
  l_rec.value_1                          := p_value_1;
  l_rec.value_2                          := p_value_2;
  l_rec.value_3                          := p_value_3;
  l_rec.value_4                          := p_value_4;
  l_rec.value_5                          := p_value_5;
  l_rec.value_6                          := p_value_6;
  l_rec.value_7                          := p_value_7;
  l_rec.value_8                          := p_value_8;
  l_rec.value_9                          := p_value_9;
  l_rec.value_10                         := p_value_10;
  l_rec.value_11                         := p_value_11;
  l_rec.value_12                         := p_value_12;
  l_rec.value_13                         := p_value_13;
  l_rec.value_14                         := p_value_14;
  l_rec.value_15                         := p_value_15;
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
  l_rec.entry_information_category       := p_entry_information_category;
  l_rec.entry_information1               := p_entry_information1;
  l_rec.entry_information2               := p_entry_information2;
  l_rec.entry_information3               := p_entry_information3;
  l_rec.entry_information4               := p_entry_information4;
  l_rec.entry_information5               := p_entry_information5;
  l_rec.entry_information6               := p_entry_information6;
  l_rec.entry_information7               := p_entry_information7;
  l_rec.entry_information8               := p_entry_information8;
  l_rec.entry_information9               := p_entry_information9;
  l_rec.entry_information10              := p_entry_information10;
  l_rec.entry_information11              := p_entry_information11;
  l_rec.entry_information12              := p_entry_information12;
  l_rec.entry_information13              := p_entry_information13;
  l_rec.entry_information14              := p_entry_information14;
  l_rec.entry_information15              := p_entry_information15;
  l_rec.entry_information16              := p_entry_information16;
  l_rec.entry_information17              := p_entry_information17;
  l_rec.entry_information18              := p_entry_information18;
  l_rec.entry_information19              := p_entry_information19;
  l_rec.entry_information20              := p_entry_information20;
  l_rec.entry_information21              := p_entry_information21;
  l_rec.entry_information22              := p_entry_information22;
  l_rec.entry_information23              := p_entry_information23;
  l_rec.entry_information24              := p_entry_information24;
  l_rec.entry_information25              := p_entry_information25;
  l_rec.entry_information26              := p_entry_information26;
  l_rec.entry_information27              := p_entry_information27;
  l_rec.entry_information28              := p_entry_information28;
  l_rec.entry_information29              := p_entry_information29;
  l_rec.entry_information30              := p_entry_information30;
  l_rec.date_earned                      := p_date_earned;
  l_rec.personal_payment_method_id       := p_personal_payment_method_id;
  l_rec.subpriority                      := p_subpriority;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
--
--type segment_value is varray(30) of varchar2(150);
--l_segment_value  segment_value ;
--
--

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< keyflex_comb >-----------------------------|
-- ----------------------------------------------------------------------------

Procedure keyflex_comb(
    p_dml_mode               in     varchar2  default hr_api.g_varchar2,
    p_appl_short_name        in     varchar2  default hr_api.g_varchar2,
    p_flex_code              in     varchar2  default hr_api.g_varchar2,
    p_segment1               in     varchar2  default hr_api.g_varchar2,
    p_segment2               in     varchar2  default hr_api.g_varchar2,
    p_segment3               in     varchar2  default hr_api.g_varchar2,
    p_segment4               in     varchar2  default hr_api.g_varchar2,
    p_segment5               in     varchar2  default hr_api.g_varchar2,
    p_segment6               in     varchar2  default hr_api.g_varchar2,
    p_segment7               in     varchar2  default hr_api.g_varchar2,
    p_segment8               in     varchar2  default hr_api.g_varchar2,
    p_segment9               in     varchar2  default hr_api.g_varchar2,
    p_segment10              in     varchar2  default hr_api.g_varchar2,
    p_segment11              in     varchar2  default hr_api.g_varchar2,
    p_segment12              in     varchar2  default hr_api.g_varchar2,
    p_segment13              in     varchar2  default hr_api.g_varchar2,
    p_segment14              in     varchar2  default hr_api.g_varchar2,
    p_segment15              in     varchar2  default hr_api.g_varchar2,
    p_segment16              in     varchar2  default hr_api.g_varchar2,
    p_segment17              in     varchar2  default hr_api.g_varchar2,
    p_segment18              in     varchar2  default hr_api.g_varchar2,
    p_segment19              in     varchar2  default hr_api.g_varchar2,
    p_segment20              in     varchar2  default hr_api.g_varchar2,
    p_segment21              in     varchar2  default hr_api.g_varchar2,
    p_segment22              in     varchar2  default hr_api.g_varchar2,
    p_segment23              in     varchar2  default hr_api.g_varchar2,
    p_segment24              in     varchar2  default hr_api.g_varchar2,
    p_segment25              in     varchar2  default hr_api.g_varchar2,
    p_segment26              in     varchar2  default hr_api.g_varchar2,
    p_segment27              in     varchar2  default hr_api.g_varchar2,
    p_segment28              in     varchar2  default hr_api.g_varchar2,
    p_segment29              in     varchar2  default hr_api.g_varchar2,
    p_segment30              in     varchar2  default hr_api.g_varchar2,
    p_concat_segments_in     in     varchar2  default hr_api.g_varchar2,
    p_batch_line_id          in     number  default hr_api.g_number,
    p_batch_id               in     number  default hr_api.g_number,
    --
    -- OUT parameter,
    -- l_rec.cost_allocation_keyflex_id may have a new value
    --
    p_ccid                   in out nocopy  number,
    p_concat_segments_out    out    nocopy  varchar2
    )    is

 cursor csr_bg_id(c_batch_id pay_batch_headers.batch_id%type) is
    select pbh.business_group_id
    from pay_batch_headers pbh
    where pbh.batch_id = c_batch_id;

 cursor csr_id_flex_num(c_business_group_id  pay_batch_headers.business_group_id%type)is
    select cost_allocation_structure
    from per_business_groups
    where business_group_id= c_business_group_id;

 cursor csr_batch_id (p_batch_line_id pay_batch_lines.batch_line_id%type) is
    select pbl.batch_id
    from pay_batch_lines pbl
    where pbl.batch_line_id = p_batch_line_id;

 cursor csr_get_concat_segments(c_ccid pay_batch_lines.cost_allocation_keyflex_id%type) is
    select concatenated_segments
    from pay_cost_allocation_keyflex
    where cost_allocation_keyflex_id = c_ccid;

    l_business_group_id     pay_batch_headers.business_group_id%type;
    l_ccid                  pay_batch_lines.cost_allocation_keyflex_id%type;
    l_concat_segments_out   pay_batch_lines.concatenated_segments%type;
    l_batch_id              pay_batch_headers.batch_id%type;
    l_check_segments        boolean;
    l_proc	            varchar2(72) := g_package||'keyflex_comb';
    l_id_flex_num           pay_cost_allocation_keyflex.id_flex_num%type;

--
begin
    hr_utility.set_location('Entering:'||l_proc, 5);


    l_ccid:= -1;
    l_concat_segments_out := p_concat_segments_out;

   hr_utility.set_location(l_proc, 10);

--

    if (p_dml_mode='UPDATE') then

      open csr_batch_id(p_batch_line_id);
      fetch csr_batch_id into l_batch_id;
      close csr_batch_id;
    elsif (p_dml_mode='INSERT') then
      l_batch_id := p_batch_id;

    end if;
  --
    hr_utility.set_location(l_proc, 20);

    open csr_bg_id(l_batch_id);
    fetch csr_bg_id into l_business_group_id;
    close csr_bg_id;
  --
    open csr_id_flex_num(l_business_group_id);
    fetch csr_id_flex_num into l_id_flex_num;
    close csr_id_flex_num;

  --
  pay_btl_shd.g_api_dml := true;  -- set the api dml status



if  p_dml_mode = 'UPDATE' then


    l_ccid :=
	  hr_entry.maintain_cost_keyflex(
            p_cost_keyflex_structure     => l_id_flex_num,
            p_cost_allocation_keyflex_id => l_ccid,
            p_concatenated_segments      => NULL,
            p_summary_flag               =>'N',
            p_start_date_active          => NULL,
            p_end_date_active            => NULL,
            p_segment1                   =>p_segment1,
            p_segment2                   =>p_segment2,
            p_segment3                   =>p_segment3,
            p_segment4                   =>p_segment4,
            p_segment5                   =>p_segment5,
            p_segment6                   =>p_segment6,
            p_segment7                   =>p_segment7,
            p_segment8                   =>p_segment8,
            p_segment9                   =>p_segment9,
            p_segment10                  =>p_segment10,
            p_segment11                  =>p_segment11,
            p_segment12                  =>p_segment12,
            p_segment13                  =>p_segment13,
            p_segment14                  =>p_segment14,
            p_segment15                  =>p_segment15,
            p_segment16                  =>p_segment16,
            p_segment17                  =>p_segment17,
            p_segment18                  =>p_segment18,
            p_segment19                  =>p_segment19,
            p_segment20                  =>p_segment20,
            p_segment21                  =>p_segment21,
            p_segment22                  =>p_segment22,
            p_segment23                  =>p_segment23,
            p_segment24                  =>p_segment24,
            p_segment25                  =>p_segment25,
            p_segment26                  =>p_segment26,
            p_segment27                  =>p_segment27,
            p_segment28                  =>p_segment28,
            p_segment29                  =>p_segment29,
            p_segment30                  =>p_segment30);
    --
    --
    elsif p_dml_mode = 'INSERT' then


  --
  -- insert flexfield segment
  --

  l_ccid :=
	  hr_entry.maintain_cost_keyflex(
            p_cost_keyflex_structure     => l_id_flex_num,
            p_cost_allocation_keyflex_id => l_ccid,
            p_concatenated_segments      => NULL,
            p_summary_flag               =>'N',
            p_start_date_active          => NULL,
            p_end_date_active            => NULL,
            p_segment1                   =>p_segment1,
            p_segment2                   =>p_segment2,
            p_segment3                   =>p_segment3,
            p_segment4                   =>p_segment4,
            p_segment5                   =>p_segment5,
            p_segment6                   =>p_segment6,
            p_segment7                   =>p_segment7,
            p_segment8                   =>p_segment8,
            p_segment9                   =>p_segment9,
            p_segment10                  =>p_segment10,
            p_segment11                  =>p_segment11,
            p_segment12                  =>p_segment12,
            p_segment13                  =>p_segment13,
            p_segment14                  =>p_segment14,
            p_segment15                  =>p_segment15,
            p_segment16                  =>p_segment16,
            p_segment17                  =>p_segment17,
            p_segment18                  =>p_segment18,
            p_segment19                  =>p_segment19,
            p_segment20                  =>p_segment20,
            p_segment21                  =>p_segment21,
            p_segment22                  =>p_segment22,
            p_segment23                  =>p_segment23,
            p_segment24                  =>p_segment24,
            p_segment25                  =>p_segment25,
            p_segment26                  =>p_segment26,
            p_segment27                  =>p_segment27,
            p_segment28                  =>p_segment28,
            p_segment29                  =>p_segment29,
            p_segment30                  =>p_segment30);
  --
  --
  end if;
  p_ccid := l_ccid;


  open csr_get_concat_segments(p_ccid);
    fetch csr_get_concat_segments into p_concat_segments_out;
    close csr_get_concat_segments;


exception
    when app_exception.application_exception then
      hr_message.provide_error;
       hr_utility.raise_error;

end keyflex_comb;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_flex_segs >----------------------------|
-- ----------------------------------------------------------------------------


procedure get_flex_segs
(
p_rec  in out nocopy g_rec_type
)
is


cursor csr_get_segs(c_ccid pay_batch_lines.cost_allocation_keyflex_id%type ) is
    select segment1,segment2,segment3,segment4,segment5,segment6,segment7,segment8,segment9,
           segment10,segment11,segment12,segment13,segment14,segment15,segment16,segment17,
           segment18,segment19,segment20,segment21,segment22,segment23,segment24,segment25,
           segment26,segment27,segment28,segment29,segment30
     from pay_cost_allocation_keyflex
     where cost_allocation_keyflex_id = c_ccid;

l_new_segments segment_value;
begin

open csr_get_segs( p_rec.cost_allocation_keyflex_id );
fetch csr_get_segs into         p_rec.segment1,
                                p_rec.segment2,
                                p_rec.segment3,
                                p_rec.segment4,
                                p_rec.segment5,
                                p_rec.segment6,
                                p_rec.segment7,
                                p_rec.segment8,
                                p_rec.segment9,
                                p_rec.segment10,
                                p_rec.segment11,
                                p_rec.segment12,
                                p_rec.segment13,
                                p_rec.segment14,
                                p_rec.segment15,
                                p_rec.segment16,
                                p_rec.segment17,
                                p_rec.segment18,
                                p_rec.segment19,
                                p_rec.segment20,
                                p_rec.segment21,
                                p_rec.segment22,
                                p_rec.segment23,
                                p_rec.segment24,
                                p_rec.segment25,
                                p_rec.segment26,
                                p_rec.segment27,
                                p_rec.segment28,
                                p_rec.segment29,
                                p_rec.segment30;
close csr_get_segs;
end get_flex_segs;
--
end pay_btl_shd;


/
