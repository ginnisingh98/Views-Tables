--------------------------------------------------------
--  DDL for Package Body HR_TRS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TRS_SHD" as
/* $Header: hrtrsrhi.pkb 120.2 2005/10/11 02:10:33 hpandya noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_trs_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc    varchar2(72) := g_package||'return_api_dml_status';
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
  l_proc    varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'HR_API_TRANSACTION_STEPS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'HR_API_TRANSACTION_STEPS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
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
  p_transaction_step_id                in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select transaction_step_id,
    transaction_id,
    api_name,
    api_display_name,
    processing_order,
    item_type,
    item_key,
    activity_id,
    creator_person_id,
    update_person_id,
    object_version_number,
    object_type,
    object_name,
    object_identifier,
    object_state,
    pk1,
    pk2,
    pk3,
    pk4,
    pk5,
    information_category,
    information1,
    information2,
    information3,
    information4,
    information5,
    information6,
    information7,
    information8,
    information9,
    information10,
    information11,
    information12,
    information13,
    information14,
    information15,
    information16,
    information17,
    information18,
    information19,
    information20,
    information21,
    information22,
    information23,
    information24,
    information25,
    information26,
    information27,
    information28,
    information29,
    information30
    from    hr_api_transaction_steps
    where   transaction_step_id = p_transaction_step_id;
--
  l_proc    varchar2(72)    := g_package||'api_updating';
  l_fct_ret boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
    p_transaction_step_id is null and
    p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
    p_transaction_step_id = g_old_rec.transaction_step_id and
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
  p_transaction_step_id                in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select  transaction_step_id,
    transaction_id,
    api_name,
    api_display_name,
    processing_order,
    item_type,
    item_key,
    activity_id,
    creator_person_id,
    update_person_id,
    object_version_number,
    object_type,
    object_name,
    object_identifier,
    object_state,
    pk1,
    pk2,
    pk3,
    pk4,
    pk5,
    information_category,
    information1,
    information2,
    information3,
    information4,
    information5,
    information6,
    information7,
    information8,
    information9,
    information10,
    information11,
    information12,
    information13,
    information14,
    information15,
    information16,
    information17,
    information18,
    information19,
    information20,
    information21,
    information22,
    information23,
    information24,
    information25,
    information26,
    information27,
    information28,
    information29,
    information30
    from    hr_api_transaction_steps
    where   transaction_step_id = p_transaction_step_id
    for update nowait;
--
  l_proc    varchar2(72) := g_package||'lck';
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
    hr_utility.set_message_token('TABLE_NAME', 'hr_api_transaction_steps');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
    (
    p_transaction_step_id           in number,
    p_transaction_id                in number,
    p_api_name                      in varchar2,
    p_api_display_name              in varchar2,
    p_processing_order              in number,
    p_item_type                     in varchar2,
    p_item_key                      in varchar2,
    p_activity_id                   in number,
    p_creator_person_id             in number,
    p_update_person_id              in number,
    p_object_version_number         in number,
    p_object_type                   in varchar2,
    p_object_name                   in varchar2,
    p_object_identifier             in  varchar2,
    p_object_state                  in varchar2,
    p_pk1                           in  varchar2,
    p_pk2                           in  varchar2,
    p_pk3                           in  varchar2,
    p_pk4                           in  varchar2,
    p_pk5                           in  varchar2,
    p_information_category	    in  varchar2,
    p_information1		    in  varchar2,
    p_information2		    in  varchar2,
    p_information3		    in  varchar2,
    p_information4		    in  varchar2,
    p_information5		    in  varchar2,
    p_information6		    in  varchar2,
    p_information7		    in  varchar2,
    p_information8		    in  varchar2,
    p_information9		    in  varchar2,
    p_information10		    in  varchar2,
    p_information11		    in  varchar2,
    p_information12		    in  varchar2,
    p_information13		    in  varchar2,
    p_information14		    in  varchar2,
    p_information15		    in  varchar2,
    p_information16		    in  varchar2,
    p_information17		    in  varchar2,
    p_information18		    in  varchar2,
    p_information19		    in  varchar2,
    p_information20		    in  varchar2,
    p_information21		    in  varchar2,
    p_information22		    in  varchar2,
    p_information23		    in  varchar2,
    p_information24		    in  varchar2,
    p_information25		    in  varchar2,
    p_information26		    in  varchar2,
    p_information27		    in  varchar2,
    p_information28		    in  varchar2,
    p_information29		    in  varchar2,
    p_information30		    in  varchar2

    )
    Return g_rec_type is
--
  l_rec   g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.transaction_step_id            := p_transaction_step_id;
  l_rec.transaction_id                 := p_transaction_id;
  l_rec.api_name                       := p_api_name;
  l_rec.api_display_name               := p_api_display_name;
  l_rec.processing_order               := p_processing_order;
  l_rec.item_type                      := p_item_type;
  l_rec.item_key                       := p_item_key;
  l_rec.activity_id                    := p_activity_id;
  l_rec.creator_person_id              := p_creator_person_id;
  l_rec.update_person_id               := p_update_person_id;
  l_rec.object_version_number          := p_object_version_number;
  l_rec.object_type                    := p_object_type;
  l_rec.object_name               	   := p_object_name;
  l_rec.object_identifier          	   := p_object_identifier;
  l_rec.object_state                   := p_object_state;
  l_rec.pk1                        	   := p_pk1;
  l_rec.pk2                        	   := p_pk2;
  l_rec.pk3                        	   := p_pk3;
  l_rec.pk4                        	   := p_pk4;
  l_rec.pk5                        	   := p_pk5;
  l_rec.information_category           	   := p_information_category;
  l_rec.information1               	   := p_information1;
  l_rec.information2               	   := p_information2;
  l_rec.information3               	   := p_information3;
  l_rec.information4               	   := p_information4;
  l_rec.information5               	   := p_information5;
  l_rec.information6               	   := p_information6;
  l_rec.information7               	   := p_information7;
  l_rec.information8               	   := p_information8;
  l_rec.information9               	   := p_information9;
  l_rec.information10               	   := p_information10;
  l_rec.information11               	   := p_information11;
  l_rec.information12               	   := p_information12;
  l_rec.information13               	   := p_information13;
  l_rec.information14               	   := p_information14;
  l_rec.information15               	   := p_information15;
  l_rec.information16               	   := p_information16;
  l_rec.information17               	   := p_information17;
  l_rec.information18               	   := p_information18;
  l_rec.information19               	   := p_information19;
  l_rec.information20               	   := p_information20;
  l_rec.information21               	   := p_information21;
  l_rec.information22               	   := p_information22;
  l_rec.information23               	   := p_information23;
  l_rec.information24              	   := p_information24;
  l_rec.information25              	   := p_information25;
  l_rec.information26               	   := p_information26;
  l_rec.information27               	   := p_information27;
  l_rec.information28               	   := p_information28;
  l_rec.information29              	   := p_information29;
  l_rec.information30               	   := p_information30;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end hr_trs_shd;

/
