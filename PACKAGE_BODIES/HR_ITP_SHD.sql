--------------------------------------------------------
--  DDL for Package Body HR_ITP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ITP_SHD" as
/* $Header: hritprhi.pkb 115.11 2003/12/03 07:01:45 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_itp_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc  varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK11') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK12') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK13') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK14') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK15') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','30');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK16') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','35');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK17') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','40');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','45');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','50');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK5') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','55');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK6') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','60');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK7') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','65');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK8') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','70');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_FK9') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','75');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','80');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'HR_ITEM_PROPERTIES_B_UK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','85');
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
  (p_item_property_id                     in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       item_property_id
      ,object_version_number
      ,form_item_id
      ,template_item_id
      ,template_item_context_id
      ,alignment
      ,bevel
      ,case_restriction
      ,enabled
      ,format_mask
      ,height
      ,information_formula_id
      ,information_parameter_item_id1
      ,information_parameter_item_id2
      ,information_parameter_item_id3
      ,information_parameter_item_id4
      ,information_parameter_item_id5
      ,insert_allowed
      ,prompt_alignment_offset
      ,prompt_display_style
      ,prompt_edge
      ,prompt_edge_alignment
      ,prompt_edge_offset
      ,prompt_text_alignment
      ,query_allowed
      ,required
      ,update_allowed
      ,validation_formula_id
      ,validation_parameter_item_id1
      ,validation_parameter_item_id2
      ,validation_parameter_item_id3
      ,validation_parameter_item_id4
      ,validation_parameter_item_id5
      ,visible
      ,width
      ,x_position
      ,y_position
      ,information_category
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,information11
      ,information12
      ,information13
      ,information14
      ,information15
      ,information16
      ,information17
      ,information18
      ,information19
      ,information20
      ,information21
      ,information22
      ,information23
      ,information24
      ,information25
      ,information26
      ,information27
      ,information28
      ,information29
      ,information30
      ,next_navigation_item_id
      ,previous_navigation_item_id
    from  hr_item_properties_b
    where item_property_id = p_item_property_id;
--
  l_fct_ret boolean;
--
Begin
  --
  If (p_item_property_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_item_property_id
        = hr_itp_shd.g_old_rec.item_property_id and
        p_object_version_number
        = hr_tdg_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hr_itp_shd.g_old_rec;
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
          <> hr_tdg_shd.g_old_rec.object_version_number) Then
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
  (p_item_property_id                     in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       item_property_id
      ,object_version_number
      ,form_item_id
      ,template_item_id
      ,template_item_context_id
      ,alignment
      ,bevel
      ,case_restriction
      ,enabled
      ,format_mask
      ,height
      ,information_formula_id
      ,information_parameter_item_id1
      ,information_parameter_item_id2
      ,information_parameter_item_id3
      ,information_parameter_item_id4
      ,information_parameter_item_id5
      ,insert_allowed
      ,prompt_alignment_offset
      ,prompt_display_style
      ,prompt_edge
      ,prompt_edge_alignment
      ,prompt_edge_offset
      ,prompt_text_alignment
      ,query_allowed
      ,required
      ,update_allowed
      ,validation_formula_id
      ,validation_parameter_item_id1
      ,validation_parameter_item_id2
      ,validation_parameter_item_id3
      ,validation_parameter_item_id4
      ,validation_parameter_item_id5
      ,visible
      ,width
      ,x_position
      ,y_position
      ,information_category
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,information11
      ,information12
      ,information13
      ,information14
      ,information15
      ,information16
      ,information17
      ,information18
      ,information19
      ,information20
      ,information21
      ,information22
      ,information23
      ,information24
      ,information25
      ,information26
      ,information27
      ,information28
      ,information29
      ,information30
      ,next_navigation_item_id
      ,previous_navigation_item_id
    from  hr_item_properties_b
    where item_property_id = p_item_property_id
    for update nowait;
--
  l_proc  varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ITEM_PROPERTY_ID'
    ,p_argument_value     => p_item_property_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name   => l_proc
    ,p_argument   => 'object_version_number'
    ,p_argument_value   => p_object_version_number
   );
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_itp_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  If (p_object_version_number
      <> hr_tdg_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hr_item_properties_b');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_item_property_id               in number
  ,p_object_version_number          in number
  ,p_form_item_id                   in number
  ,p_template_item_id               in number
  ,p_template_item_context_id       in number
  ,p_alignment                      in number
  ,p_bevel                          in number
  ,p_case_restriction               in number
  ,p_enabled                        in number
  ,p_format_mask                    in varchar2
  ,p_height                         in number
  ,p_information_formula_id         in number
  ,p_information_param_item_id1     in number
  ,p_information_param_item_id2     in number
  ,p_information_param_item_id3     in number
  ,p_information_param_item_id4     in number
  ,p_information_param_item_id5     in number
  ,p_insert_allowed                 in number
  ,p_prompt_alignment_offset        in number
  ,p_prompt_display_style           in number
  ,p_prompt_edge                    in number
  ,p_prompt_edge_alignment          in number
  ,p_prompt_edge_offset             in number
  ,p_prompt_text_alignment          in number
  ,p_query_allowed                  in number
  ,p_required                       in number
  ,p_update_allowed                 in number
  ,p_validation_formula_id          in number
  ,p_validation_param_item_id1      in number
  ,p_validation_param_item_id2      in number
  ,p_validation_param_item_id3      in number
  ,p_validation_param_item_id4      in number
  ,p_validation_param_item_id5      in number
  ,p_visible                        in number
  ,p_width                          in number
  ,p_x_position                     in number
  ,p_y_position                     in number
  ,p_information_category           in varchar2
  ,p_information1                   in varchar2
  ,p_information2                   in varchar2
  ,p_information3                   in varchar2
  ,p_information4                   in varchar2
  ,p_information5                   in varchar2
  ,p_information6                   in varchar2
  ,p_information7                   in varchar2
  ,p_information8                   in varchar2
  ,p_information9                   in varchar2
  ,p_information10                  in varchar2
  ,p_information11                  in varchar2
  ,p_information12                  in varchar2
  ,p_information13                  in varchar2
  ,p_information14                  in varchar2
  ,p_information15                  in varchar2
  ,p_information16                  in varchar2
  ,p_information17                  in varchar2
  ,p_information18                  in varchar2
  ,p_information19                  in varchar2
  ,p_information20                  in varchar2
  ,p_information21                  in varchar2
  ,p_information22                  in varchar2
  ,p_information23                  in varchar2
  ,p_information24                  in varchar2
  ,p_information25                  in varchar2
  ,p_information26                  in varchar2
  ,p_information27                  in varchar2
  ,p_information28                  in varchar2
  ,p_information29                  in varchar2
  ,p_information30                  in varchar2
  ,p_next_navigation_item_id        in number
  ,p_previous_navigation_item_id    in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.item_property_id                 := p_item_property_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.form_item_id                     := p_form_item_id;
  l_rec.template_item_id                 := p_template_item_id;
  l_rec.template_item_context_id         := p_template_item_context_id;
  l_rec.alignment                        := p_alignment;
  l_rec.bevel                            := p_bevel;
  l_rec.case_restriction                 := p_case_restriction;
  l_rec.enabled                          := p_enabled;
  l_rec.format_mask                      := p_format_mask;
  l_rec.height                           := p_height;
  l_rec.information_formula_id           := p_information_formula_id;
  l_rec.information_parameter_item_id1   := p_information_param_item_id1;
  l_rec.information_parameter_item_id2   := p_information_param_item_id2;
  l_rec.information_parameter_item_id3   := p_information_param_item_id3;
  l_rec.information_parameter_item_id4   := p_information_param_item_id4;
  l_rec.information_parameter_item_id5   := p_information_param_item_id5;
  l_rec.insert_allowed                   := p_insert_allowed;
  l_rec.prompt_alignment_offset          := p_prompt_alignment_offset;
  l_rec.prompt_display_style             := p_prompt_display_style;
  l_rec.prompt_edge                      := p_prompt_edge;
  l_rec.prompt_edge_alignment            := p_prompt_edge_alignment;
  l_rec.prompt_edge_offset               := p_prompt_edge_offset;
  l_rec.prompt_text_alignment            := p_prompt_text_alignment;
  l_rec.query_allowed                    := p_query_allowed;
  l_rec.required                         := p_required;
  l_rec.update_allowed                   := p_update_allowed;
  l_rec.validation_formula_id            := p_validation_formula_id;
  l_rec.validation_parameter_item_id1    := p_validation_param_item_id1;
  l_rec.validation_parameter_item_id2    := p_validation_param_item_id2;
  l_rec.validation_parameter_item_id3    := p_validation_param_item_id3;
  l_rec.validation_parameter_item_id4    := p_validation_param_item_id4;
  l_rec.validation_parameter_item_id5    := p_validation_param_item_id5;
  l_rec.visible                          := p_visible;
  l_rec.width                            := p_width;
  l_rec.x_position                       := p_x_position;
  l_rec.y_position                       := p_y_position;
  l_rec.information_category             := p_information_category;
  l_rec.information1                     := p_information1;
  l_rec.information2                     := p_information2;
  l_rec.information3                     := p_information3;
  l_rec.information4                     := p_information4;
  l_rec.information5                     := p_information5;
  l_rec.information6                     := p_information6;
  l_rec.information7                     := p_information7;
  l_rec.information8                     := p_information8;
  l_rec.information9                     := p_information9;
  l_rec.information10                    := p_information10;
  l_rec.information11                    := p_information11;
  l_rec.information12                    := p_information12;
  l_rec.information13                    := p_information13;
  l_rec.information14                    := p_information14;
  l_rec.information15                    := p_information15;
  l_rec.information16                    := p_information16;
  l_rec.information17                    := p_information17;
  l_rec.information18                    := p_information18;
  l_rec.information19                    := p_information19;
  l_rec.information20                    := p_information20;
  l_rec.information21                    := p_information21;
  l_rec.information22                    := p_information22;
  l_rec.information23                    := p_information23;
  l_rec.information24                    := p_information24;
  l_rec.information25                    := p_information25;
  l_rec.information26                    := p_information26;
  l_rec.information27                    := p_information27;
  l_rec.information28                    := p_information28;
  l_rec.information29                    := p_information29;
  l_rec.information30                    := p_information30;
  l_rec.next_navigation_item_id          := p_next_navigation_item_id;
  l_rec.previous_navigation_item_id      := p_previous_navigation_item_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_itp_shd;

/
